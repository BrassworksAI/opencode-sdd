package registry

import (
	"io/fs"
	"path/filepath"

	"github.com/shanepadgett/agent-extensions/internal/config"
)

type Registry struct {
	FS         fs.FS
	Tools      *config.ToolsConfig
	Extensions *config.ExtensionsConfig
}

func New(fsys fs.FS) (*Registry, error) {
	tools, err := config.LoadToolsConfigFromFS(fsys, "tools.yaml")
	if err != nil {
		return nil, err
	}

	extensions, err := config.LoadExtensionsConfigFromFS(fsys, "extensions.yaml")
	if err != nil {
		return nil, err
	}

	return &Registry{
		FS:         fsys,
		Tools:      tools,
		Extensions: extensions,
	}, nil
}

func (r *Registry) GetCategoryNames() []string {
	names := make([]string, 0, len(r.Extensions.Categories))
	for name := range r.Extensions.Categories {
		names = append(names, name)
	}
	return names
}

func (r *Registry) GetToolNames() []string {
	names := make([]string, 0, len(r.Tools.Tools))
	for name := range r.Tools.Tools {
		names = append(names, name)
	}
	return names
}

func (r *Registry) GetCategory(name string) (config.Category, bool) {
	cat, ok := r.Extensions.Categories[name]
	return cat, ok
}

func (r *Registry) GetTool(name string) (config.Tool, bool) {
	tool, ok := r.Tools.Tools[name]
	return tool, ok
}

func (r *Registry) CommandSourcePath(commandName string) string {
	return filepath.Join("repository", "commands", commandName+".md")
}

func (r *Registry) SkillSourcePath(skillName string) string {
	return filepath.Join("repository", "skills", skillName)
}

func (r *Registry) CommandExists(name string) bool {
	_, err := fs.Stat(r.FS, r.CommandSourcePath(name))
	return err == nil
}

func (r *Registry) SkillExists(name string) bool {
	_, err := fs.Stat(r.FS, r.SkillSourcePath(name))
	return err == nil
}

func (r *Registry) ReadCommand(name string) ([]byte, error) {
	return fs.ReadFile(r.FS, r.CommandSourcePath(name))
}

func (r *Registry) ReadSkillFile(skillName, fileName string) ([]byte, error) {
	return fs.ReadFile(r.FS, filepath.Join(r.SkillSourcePath(skillName), fileName))
}

func (r *Registry) ListSkillFiles(skillName string) ([]fs.DirEntry, error) {
	return fs.ReadDir(r.FS, r.SkillSourcePath(skillName))
}
