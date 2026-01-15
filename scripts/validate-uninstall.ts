import { readdir, readFile } from "node:fs/promises";
import { join, posix } from "node:path";

type ToolName = "opencode" | "augment" | "codex";

type DiffResult = {
  tool: ToolName;
  payloadCount: number;
  allowlistCount: number;
  missing: string[];
  extra: string[];
};

type ScriptName = "uninstall.sh" | "uninstall.ps1";

type ScriptResult = {
  script: ScriptName;
  results: DiffResult[];
};

const REPO_ROOT = posix.normalize(process.cwd().replaceAll("\\", "/"));
const UNINSTALL_SH = join(REPO_ROOT, "uninstall.sh");
const UNINSTALL_PS1 = join(REPO_ROOT, "uninstall.ps1");

function toPosixPath(path: string): string {
  return path.replaceAll("\\", "/");
}

async function listFilesRecursive(rootAbs: string): Promise<string[]> {
  const results: string[] = [];

  async function walk(dirAbs: string): Promise<void> {
    const entries = await readdir(dirAbs, { withFileTypes: true });
    for (const entry of entries) {
      const abs = join(dirAbs, entry.name);
      if (entry.isDirectory()) {
        await walk(abs);
        continue;
      }

      if (!entry.isFile()) continue;
      results.push(abs);
    }
  }

  await walk(rootAbs);
  return results;
}

async function getPayload(tool: ToolName): Promise<Set<string>> {
  const root = join(REPO_ROOT, tool);
  const files = await listFilesRecursive(root);

  const rel = files
    .map((abs) => {
      const normalized = toPosixPath(abs);
      const relative = normalized.startsWith(REPO_ROOT + "/")
        ? normalized.slice(REPO_ROOT.length + 1)
        : normalized;
      return relative.startsWith(tool + "/") ? relative.slice(tool.length + 1) : relative;
    })
    .filter((p) => !p.endsWith("/.DS_Store") && !p.endsWith(".DS_Store"));

  const payload = new Set(rel);

  if (tool === "opencode" || tool === "codex") {
    const skillsRoot = join(REPO_ROOT, "skills");
    const skillsFiles = await listFilesRecursive(skillsRoot);
    const skillsRel = skillsFiles
      .map((abs) => {
        const normalized = toPosixPath(abs);
        const relative = normalized.startsWith(toPosixPath(skillsRoot) + "/")
          ? normalized.slice(toPosixPath(skillsRoot).length + 1)
          : normalized;
        return relative;
      })
      .filter((p) => !p.endsWith("/.DS_Store") && !p.endsWith(".DS_Store"))
      // Convert .tmpl.md to .md since that's what gets installed
      .map((p) => p.replace(/\.tmpl\.md$/, ".md"));

    const prefix = tool === "opencode" ? "skill/" : "skills/";
    for (const file of skillsRel) {
      payload.add(`${prefix}${file}`);
    }
  }

  return payload;
}

function headerForTool(tool: ToolName): string {
  return tool === "opencode"
    ? "OpenCode"
    : tool === "augment"
      ? "Augment"
      : "Codex";
}

function extractShellAllowlist(uninstallSh: string, tool: ToolName): Set<string> {
  const header = `# ${headerForTool(tool)} file list`;

  const headerIndex = uninstallSh.indexOf(header);
  if (headerIndex === -1) {
    throw new Error(`Could not find allowlist header for ${tool}: ${header}`);
  }

  const filesIndex = uninstallSh.indexOf('files="', headerIndex);
  if (filesIndex === -1) {
    throw new Error(`Could not find files=\" block for ${tool}`);
  }

  const start = filesIndex + 'files="'.length;
  const end = uninstallSh.indexOf('"\n\n  for file in $files;', start);
  if (end === -1) {
    throw new Error(`Could not find end of files block for ${tool}`);
  }

  const block = uninstallSh.slice(start, end);
  const entries = block
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .filter((line) => !line.startsWith("#"));

  return new Set(entries);
}

function extractPowerShellAllowlist(uninstallPs1: string, tool: ToolName): Set<string> {
  const header = `# ${headerForTool(tool)} file list`;
  const headerIndex = uninstallPs1.indexOf(header);
  if (headerIndex === -1) {
    throw new Error(`Could not find allowlist header for ${tool} in uninstall.ps1: ${header}`);
  }

  const listStart = uninstallPs1.indexOf("$files = @(", headerIndex);
  if (listStart === -1) {
    throw new Error(`Could not find $files = @( block for ${tool} in uninstall.ps1`);
  }

  const start = listStart + "$files = @(".length;
  const end = uninstallPs1.indexOf(")", start);
  if (end === -1) {
    throw new Error(`Could not find end of $files array for ${tool} in uninstall.ps1`);
  }

  const block = uninstallPs1.slice(start, end);
  const entries = block
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .map((line) => line.replace(/,$/, ""))
    .filter((line) => line.startsWith('"') && line.endsWith('"'))
    .map((line) => line.slice(1, -1))
    .map((p) => p.replaceAll("\\", "/"));

  return new Set(entries);
}

function diff(tool: ToolName, payload: Set<string>, allowlist: Set<string>): DiffResult {
  const missing = [...payload].filter((p) => !allowlist.has(p)).sort();
  const extra = [...allowlist].filter((p) => !payload.has(p)).sort();

  return {
    tool,
    payloadCount: payload.size,
    allowlistCount: allowlist.size,
    missing,
    extra,
  };
}

function printResult(script: ScriptName, result: DiffResult): void {
  const title = result.tool.toUpperCase();
  console.log(`=== ${title} (${script}) ===`);
  console.log(`payload_count ${result.payloadCount}`);
  console.log(`allowlist_count ${result.allowlistCount}`);

  if (result.missing.length === 0 && result.extra.length === 0) {
    console.log("OK\n");
    return;
  }

  if (result.missing.length > 0) {
    console.log(`missing_count ${result.missing.length}`);
    for (const item of result.missing) console.log(`MISSING ${item}`);
  } else {
    console.log("missing_count 0");
  }

  if (result.extra.length > 0) {
    console.log(`extra_count ${result.extra.length}`);
    for (const item of result.extra) console.log(`EXTRA ${item}`);
  } else {
    console.log("extra_count 0");
  }

  console.log("");
}

async function validateScript(script: ScriptName): Promise<ScriptResult> {
  const tools: ToolName[] = ["opencode", "augment", "codex"];
  const results: DiffResult[] = [];

  if (script === "uninstall.sh") {
    const uninstallSh = await readFile(UNINSTALL_SH, "utf8");
    for (const tool of tools) {
      const payload = await getPayload(tool);
      const allowlist = extractShellAllowlist(uninstallSh, tool);
      results.push(diff(tool, payload, allowlist));
    }

    return { script, results };
  }

  const uninstallPs1 = await readFile(UNINSTALL_PS1, "utf8");
  for (const tool of tools) {
    const payload = await getPayload(tool);
    const allowlist = extractPowerShellAllowlist(uninstallPs1, tool);
    results.push(diff(tool, payload, allowlist));
  }

  return { script, results };
}

async function main(): Promise<void> {
  const scriptResults = await Promise.all([validateScript("uninstall.sh"), validateScript("uninstall.ps1")]);

  for (const { script, results } of scriptResults) {
    for (const result of results) printResult(script, result);
  }

  const hasGaps = scriptResults.some(({ results }) =>
    results.some((r) => r.missing.length > 0 || r.extra.length > 0),
  );

  if (hasGaps) {
    console.error("One or more uninstall allowlists are out of sync with payload directories.");
    process.exit(1);
  }

  console.log("All uninstall allowlists match payload directories (sh + ps1).");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
