package installer

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"github.com/shanepadgett/agent-extensions/internal/config"
	"github.com/shanepadgett/agent-extensions/internal/registry"
)

type Scope string

const (
	ScopeGlobal Scope = "global"
	ScopeLocal  Scope = "local"
	ScopeBoth   Scope = "both"
)

type Installer struct {
	Registry    *registry.Registry
	ProjectRoot string
}

type InstallResult struct {
	Tool     string
	Scope    Scope
	Commands int
	Skills   int
	Errors   []error
}

func New(reg *registry.Registry, projectRoot string) *Installer {
	return &Installer{
		Registry:    reg,
		ProjectRoot: projectRoot,
	}
}

func (i *Installer) cacheDir(scope Scope) string {
	if scope == ScopeGlobal {
		home, _ := os.UserHomeDir()
		return filepath.Join(home, ".agents", ".cache", "agent-extensions")
	}
	return filepath.Join(i.ProjectRoot, ".agents", ".cache", "agent-extensions")
}

func (i *Installer) cacheRoot(scope Scope) string {
	if scope == ScopeGlobal {
		home, _ := os.UserHomeDir()
		return filepath.Join(home, ".agents")
	}
	return filepath.Join(i.ProjectRoot, ".agents")
}

func (i *Installer) Install(toolName string, scope Scope) (*InstallResult, error) {
	tool, ok := i.Registry.GetTool(toolName)
	if !ok {
		return nil, fmt.Errorf("unknown tool: %s", toolName)
	}

	result := &InstallResult{
		Tool:  toolName,
		Scope: scope,
	}

	commands := i.Registry.GetAllCommands()
	skills := i.Registry.GetAllSkills()

	scopes := []Scope{scope}
	if scope == ScopeBoth {
		scopes = []Scope{ScopeGlobal, ScopeLocal}
	}

	for _, s := range scopes {
		cache := i.cacheDir(s)

		var target string
		if s == ScopeGlobal {
			target = tool.ResolveGlobalPath()
		} else {
			target = tool.ResolveLocalPath(i.ProjectRoot)
		}

		// Install commands
		for _, cmd := range commands {
			if err := i.installCommand(cmd, cache, target, tool.Conventions); err != nil {
				result.Errors = append(result.Errors, fmt.Errorf("command %s: %w", cmd, err))
			} else {
				result.Commands++
			}
		}

		// Install skills
		for _, skill := range skills {
			if err := i.installSkill(skill, cache, target, tool.Conventions); err != nil {
				result.Errors = append(result.Errors, fmt.Errorf("skill %s: %w", skill, err))
			} else {
				result.Skills++
			}
		}
	}

	return result, nil
}

func (i *Installer) installCommand(name, cacheDir, targetBase string, conv config.Conventions) error {
	if !i.Registry.CommandExists(name) {
		return fmt.Errorf("command not found: %s", name)
	}

	// Read from embedded FS
	data, err := i.Registry.ReadCommand(name)
	if err != nil {
		return fmt.Errorf("reading command: %w", err)
	}

	// Write to cache
	cacheDest := filepath.Join(cacheDir, "commands", name+".md")
	if err := writeFile(cacheDest, data); err != nil {
		return fmt.Errorf("writing to cache: %w", err)
	}

	// Symlink from tool location to cache
	destPath := conv.CommandPath(name)
	dest := filepath.Join(targetBase, destPath)

	return createSymlink(cacheDest, dest)
}

func (i *Installer) installSkill(name, cacheDir, targetBase string, conv config.Conventions) error {
	if !i.Registry.SkillExists(name) {
		return fmt.Errorf("skill not found: %s", name)
	}

	// Copy skill directory from embedded FS to cache
	cacheDest := filepath.Join(cacheDir, "skills", name)
	if err := i.copySkillToCache(name, cacheDest); err != nil {
		return fmt.Errorf("copying to cache: %w", err)
	}

	destPath := conv.SkillPath(name)
	dest := filepath.Join(targetBase, destPath)

	// For single-file skills (e.g., Augment style: skills/{name}.md)
	if filepath.Ext(destPath) == ".md" && filepath.Base(destPath) == name+".md" {
		cacheSkillFile := filepath.Join(cacheDest, "SKILL.md")
		if _, err := os.Stat(cacheSkillFile); err == nil {
			return createSymlink(cacheSkillFile, dest)
		}
		return fmt.Errorf("SKILL.md not found in %s", cacheDest)
	}

	// For directory-based skills, symlink the directory
	destDir := filepath.Dir(dest)
	return createSymlink(cacheDest, destDir)
}

func (i *Installer) copySkillToCache(skillName, cacheDest string) error {
	if err := os.RemoveAll(cacheDest); err != nil {
		return err
	}

	srcPath := i.Registry.SkillSourcePath(skillName)
	return fs.WalkDir(i.Registry.FS, srcPath, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		relPath, _ := filepath.Rel(srcPath, path)
		destPath := filepath.Join(cacheDest, relPath)

		if d.IsDir() {
			return os.MkdirAll(destPath, 0755)
		}

		data, err := fs.ReadFile(i.Registry.FS, path)
		if err != nil {
			return err
		}

		return writeFile(destPath, data)
	})
}

func createSymlink(src, dest string) error {
	if err := os.MkdirAll(filepath.Dir(dest), 0755); err != nil {
		return fmt.Errorf("creating parent dir: %w", err)
	}

	if _, err := os.Lstat(dest); err == nil {
		if err := os.RemoveAll(dest); err != nil {
			return fmt.Errorf("removing existing: %w", err)
		}
	}

	if err := os.Symlink(src, dest); err != nil {
		return fmt.Errorf("creating symlink: %w", err)
	}

	return nil
}

func writeFile(dest string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(dest), 0755); err != nil {
		return err
	}
	return os.WriteFile(dest, data, 0644)
}

func (i *Installer) Uninstall(toolName string, scope Scope) (*InstallResult, error) {
	tool, ok := i.Registry.GetTool(toolName)
	if !ok {
		return nil, fmt.Errorf("unknown tool: %s", toolName)
	}

	result := &InstallResult{
		Tool:  toolName,
		Scope: scope,
	}

	commands := i.Registry.GetAllCommands()
	skills := i.Registry.GetAllSkills()

	scopes := []Scope{scope}
	if scope == ScopeBoth {
		scopes = []Scope{ScopeGlobal, ScopeLocal}
	}

	for _, s := range scopes {
		var target string
		if s == ScopeGlobal {
			target = tool.ResolveGlobalPath()
		} else {
			target = tool.ResolveLocalPath(i.ProjectRoot)
		}

		cache := i.cacheDir(s)

		// Uninstall commands
		for _, cmd := range commands {
			destPath := tool.Conventions.CommandPath(cmd)
			dest := filepath.Join(target, destPath)
			if _, err := os.Lstat(dest); err == nil {
				if err := os.RemoveAll(dest); err == nil {
					result.Commands++
					cleanEmptyParents(filepath.Dir(dest), target)
				}
			}
			// Also remove from cache
			cachePath := filepath.Join(cache, "commands", cmd+".md")
			os.RemoveAll(cachePath)
		}

		// Uninstall skills
		for _, skill := range skills {
			destPath := tool.Conventions.SkillPath(skill)
			dest := filepath.Join(target, destPath)

			// Check if this is a single-file skill pattern (e.g., skills/{name}.md)
			// vs directory-based (e.g., skills/{name}/SKILL.md)
			isSingleFile := filepath.Ext(destPath) == ".md" && filepath.Base(destPath) == skill+".md"

			if isSingleFile {
				// Single-file skill - remove the .md file
				if _, err := os.Lstat(dest); err == nil {
					if err := os.RemoveAll(dest); err == nil {
						result.Skills++
						cleanEmptyParents(filepath.Dir(dest), target)
					}
				}
			} else {
				// Directory-based skill - the symlink is at the skill directory level
				// e.g., for skills/{name}/SKILL.md, the symlink is at skills/{name}
				skillDir := filepath.Dir(dest)
				if _, err := os.Lstat(skillDir); err == nil {
					if err := os.RemoveAll(skillDir); err == nil {
						result.Skills++
						cleanEmptyParents(filepath.Dir(skillDir), target)
					}
				}
			}
			// Also remove from cache
			cachePath := filepath.Join(cache, "skills", skill)
			os.RemoveAll(cachePath)
		}

		// Clean up empty cache directories up to .agents
		cleanEmptyParents(filepath.Join(cache, "commands"), i.cacheRoot(s))
		cleanEmptyParents(filepath.Join(cache, "skills"), i.cacheRoot(s))
		cleanEmptyParents(cache, i.cacheRoot(s))
	}

	return result, nil
}

// cleanEmptyParents removes empty directories from dir up to and including stopAt
func cleanEmptyParents(dir, stopAt string) {
	for {
		if dir == "/" || dir == "." {
			return
		}
		entries, err := os.ReadDir(dir)
		if err != nil || len(entries) > 0 {
			return
		}
		if err := os.Remove(dir); err != nil {
			return
		}
		if dir == stopAt {
			return
		}
		dir = filepath.Dir(dir)
	}
}
