#!/usr/bin/env bun

import { existsSync, mkdirSync, readdirSync } from 'node:fs';
import { cp } from 'node:fs/promises';
import path from 'node:path';

type Args = {
  runsDir: string;
  slug: string;
  fromVersion?: number;
  toVersion?: number;
};

function usageAndExit(message?: string): never {
  if (message) {
    console.error(message);
  }

  console.error(
    [
      'Usage:',
      '  bun run opencode/skill/design-case-study-generator/scripts/copy-version.ts -- --slug <series-slug> [--runsDir design-system/runs] [--from vN] [--to vN]',
      '',
      'Examples:',
      '  bun run opencode/skill/design-case-study-generator/scripts/copy-version.ts -- --slug landing-page-bold-noir --from v1',
      '  bun run opencode/skill/design-case-study-generator/scripts/copy-version.ts -- --slug landing-page-bold-noir --from v2 --to v3',
    ].join('\n'),
  );

  process.exit(1);
}

function parseVersion(text: string, flagName: string): number {
  const match = /^v(\d+)$/.exec(text.trim());
  if (!match) usageAndExit(`Invalid ${flagName}: expected vN, got ${text}`);
  return Number.parseInt(match[1]!, 10);
}

function parseArgs(argv: string[]): Args {
  const args: Args = {
    runsDir: 'design-system/runs',
    slug: '',
  };

  for (let index = 0; index < argv.length; index++) {
    const token = argv[index];
    if (!token) continue;

    if (token === '--runsDir') {
      args.runsDir = argv[++index] ?? '';
      continue;
    }

    if (token === '--slug') {
      args.slug = argv[++index] ?? '';
      continue;
    }

    if (token === '--from') {
      const fromText = argv[++index] ?? '';
      args.fromVersion = parseVersion(fromText, '--from');
      continue;
    }

    if (token === '--to') {
      const toText = argv[++index] ?? '';
      args.toVersion = parseVersion(toText, '--to');
      continue;
    }

    if (token === '--help' || token === '-h') {
      usageAndExit();
    }

    usageAndExit(`Unknown argument: ${token}`);
  }

  if (!args.slug) usageAndExit('Missing required --slug');

  return args;
}

function findHighestVersion(seriesDir: string): number {
  if (!existsSync(seriesDir)) return 0;

  let highest = 0;
  for (const entry of readdirSync(seriesDir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const match = /^v(\d+)$/.exec(entry.name);
    if (!match) continue;
    const number = Number.parseInt(match[1]!, 10);
    if (Number.isFinite(number) && number > highest) highest = number;
  }

  return highest;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  const seriesDir = path.resolve(args.runsDir, args.slug);
  const fromVersion = args.fromVersion ?? findHighestVersion(seriesDir);

  if (fromVersion <= 0) {
    usageAndExit(
      `No existing versions found under ${path.relative(process.cwd(), seriesDir)}; create v1 first.`,
    );
  }

  const toVersion = args.toVersion ?? fromVersion + 1;

  const fromDir = path.join(seriesDir, `v${fromVersion}`);
  const toDir = path.join(seriesDir, `v${toVersion}`);

  if (!existsSync(fromDir)) {
    usageAndExit(`Source version does not exist: ${path.relative(process.cwd(), fromDir)}`);
  }

  if (existsSync(toDir)) {
    usageAndExit(`Target version already exists: ${path.relative(process.cwd(), toDir)}`);
  }

  mkdirSync(seriesDir, { recursive: true });

  await cp(fromDir, toDir, {
    recursive: true,
    errorOnExist: true,
    force: false,
  });

  console.log(path.relative(process.cwd(), toDir));
}

await main();
