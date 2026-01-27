package config

import (
	"os"
	"path/filepath"
	"testing"
	"testing/fstest"
)

func TestLoadToolsConfig(t *testing.T) {
	content := `tools:
  test-tool:
    name: Test Tool
    global_path: ~/.test-tool
    local_path: .test-tool
    conventions:
      skills: skills/{name}/SKILL.md
      commands: commands/{name}.md
  another-tool:
    name: Another Tool
    global_path: ~/.another
    local_path: .another
    conventions:
      skills: skills/{name}.md
      commands: prompts/{name}.md
`
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "tools.yaml")
	if err := os.WriteFile(configPath, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write test config: %v", err)
	}

	cfg, err := LoadToolsConfig(configPath)
	if err != nil {
		t.Fatalf("LoadToolsConfig failed: %v", err)
	}

	if len(cfg.Tools) != 2 {
		t.Errorf("expected 2 tools, got %d", len(cfg.Tools))
	}

	tool, ok := cfg.Tools["test-tool"]
	if !ok {
		t.Fatal("test-tool not found")
	}

	if tool.Name != "Test Tool" {
		t.Errorf("expected name 'Test Tool', got %q", tool.Name)
	}
	if tool.GlobalPath != "~/.test-tool" {
		t.Errorf("expected global_path '~/.test-tool', got %q", tool.GlobalPath)
	}
	if tool.LocalPath != ".test-tool" {
		t.Errorf("expected local_path '.test-tool', got %q", tool.LocalPath)
	}
	if tool.Conventions.Skills != "skills/{name}/SKILL.md" {
		t.Errorf("expected skills convention 'skills/{name}/SKILL.md', got %q", tool.Conventions.Skills)
	}
	if tool.Conventions.Commands != "commands/{name}.md" {
		t.Errorf("expected commands convention 'commands/{name}.md', got %q", tool.Conventions.Commands)
	}
}

func TestLoadToolsConfigFromFS(t *testing.T) {
	content := `tools:
  fs-tool:
    name: FS Tool
    global_path: ~/.fs-tool
    local_path: .fs-tool
    conventions:
      skills: skills/{name}/SKILL.md
      commands: commands/{name}.md
`
	fsys := fstest.MapFS{
		"tools.yaml": &fstest.MapFile{Data: []byte(content)},
	}

	cfg, err := LoadToolsConfigFromFS(fsys, "tools.yaml")
	if err != nil {
		t.Fatalf("LoadToolsConfigFromFS failed: %v", err)
	}

	if len(cfg.Tools) != 1 {
		t.Errorf("expected 1 tool, got %d", len(cfg.Tools))
	}

	tool, ok := cfg.Tools["fs-tool"]
	if !ok {
		t.Fatal("fs-tool not found")
	}
	if tool.Name != "FS Tool" {
		t.Errorf("expected name 'FS Tool', got %q", tool.Name)
	}
}

func TestLoadToolsConfig_InvalidYAML(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "tools.yaml")
	if err := os.WriteFile(configPath, []byte("invalid: yaml: content: ["), 0644); err != nil {
		t.Fatalf("failed to write test config: %v", err)
	}

	_, err := LoadToolsConfig(configPath)
	if err == nil {
		t.Error("expected error for invalid YAML, got nil")
	}
}

func TestLoadToolsConfig_FileNotFound(t *testing.T) {
	_, err := LoadToolsConfig("/nonexistent/path/tools.yaml")
	if err == nil {
		t.Error("expected error for missing file, got nil")
	}
}

func TestLoadExtensionsConfig(t *testing.T) {
	content := `categories:
  dev:
    description: Developer tools
    commands:
      - cmd-one
      - cmd-two
    skills:
      - skill-one
  product:
    description: Product tools
    commands:
      - cmd-three
    skills:
      - skill-two
      - skill-three
`
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "extensions.yaml")
	if err := os.WriteFile(configPath, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write test config: %v", err)
	}

	cfg, err := LoadExtensionsConfig(configPath)
	if err != nil {
		t.Fatalf("LoadExtensionsConfig failed: %v", err)
	}

	if len(cfg.Categories) != 2 {
		t.Errorf("expected 2 categories, got %d", len(cfg.Categories))
	}

	dev, ok := cfg.Categories["dev"]
	if !ok {
		t.Fatal("dev category not found")
	}

	if dev.Description != "Developer tools" {
		t.Errorf("expected description 'Developer tools', got %q", dev.Description)
	}
	if len(dev.Commands) != 2 {
		t.Errorf("expected 2 commands, got %d", len(dev.Commands))
	}
	if len(dev.Skills) != 1 {
		t.Errorf("expected 1 skill, got %d", len(dev.Skills))
	}
}

func TestLoadExtensionsConfigFromFS(t *testing.T) {
	content := `categories:
  test:
    description: Test category
    commands:
      - test-cmd
    skills:
      - test-skill
`
	fsys := fstest.MapFS{
		"extensions.yaml": &fstest.MapFile{Data: []byte(content)},
	}

	cfg, err := LoadExtensionsConfigFromFS(fsys, "extensions.yaml")
	if err != nil {
		t.Fatalf("LoadExtensionsConfigFromFS failed: %v", err)
	}

	if len(cfg.Categories) != 1 {
		t.Errorf("expected 1 category, got %d", len(cfg.Categories))
	}
}

func TestLoadExtensionsConfig_InvalidYAML(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "extensions.yaml")
	if err := os.WriteFile(configPath, []byte("invalid: yaml: ["), 0644); err != nil {
		t.Fatalf("failed to write test config: %v", err)
	}

	_, err := LoadExtensionsConfig(configPath)
	if err == nil {
		t.Error("expected error for invalid YAML, got nil")
	}
}

func TestLoadExtensionsConfig_FileNotFound(t *testing.T) {
	_, err := LoadExtensionsConfig("/nonexistent/path/extensions.yaml")
	if err == nil {
		t.Error("expected error for missing file, got nil")
	}
}

func TestTool_ResolveGlobalPath(t *testing.T) {
	home, _ := os.UserHomeDir()

	tests := []struct {
		name       string
		globalPath string
		want       string
	}{
		{
			name:       "tilde expansion",
			globalPath: "~/.test-tool",
			want:       filepath.Join(home, ".test-tool"),
		},
		{
			name:       "absolute path",
			globalPath: "/opt/test-tool",
			want:       "/opt/test-tool",
		},
		{
			name:       "nested tilde path",
			globalPath: "~/.config/test-tool",
			want:       filepath.Join(home, ".config/test-tool"),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tool := Tool{GlobalPath: tt.globalPath}
			got := tool.ResolveGlobalPath()
			if got != tt.want {
				t.Errorf("ResolveGlobalPath() = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestTool_ResolveLocalPath(t *testing.T) {
	tests := []struct {
		name        string
		localPath   string
		projectRoot string
		want        string
	}{
		{
			name:        "simple local path",
			localPath:   ".test-tool",
			projectRoot: "/projects/myproject",
			want:        "/projects/myproject/.test-tool",
		},
		{
			name:        "nested local path",
			localPath:   ".config/test-tool",
			projectRoot: "/home/user/project",
			want:        "/home/user/project/.config/test-tool",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tool := Tool{LocalPath: tt.localPath}
			got := tool.ResolveLocalPath(tt.projectRoot)
			if got != tt.want {
				t.Errorf("ResolveLocalPath() = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestConventions_SkillPath(t *testing.T) {
	tests := []struct {
		name      string
		pattern   string
		skillName string
		want      string
	}{
		{
			name:      "directory-based skill",
			pattern:   "skills/{name}/SKILL.md",
			skillName: "my-skill",
			want:      "skills/my-skill/SKILL.md",
		},
		{
			name:      "single-file skill",
			pattern:   "skills/{name}.md",
			skillName: "my-skill",
			want:      "skills/my-skill.md",
		},
		{
			name:      "custom directory",
			pattern:   "custom/skills/{name}/SKILL.md",
			skillName: "test",
			want:      "custom/skills/test/SKILL.md",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			conv := Conventions{Skills: tt.pattern}
			got := conv.SkillPath(tt.skillName)
			if got != tt.want {
				t.Errorf("SkillPath() = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestConventions_CommandPath(t *testing.T) {
	tests := []struct {
		name        string
		pattern     string
		commandName string
		want        string
	}{
		{
			name:        "standard commands directory",
			pattern:     "commands/{name}.md",
			commandName: "my-command",
			want:        "commands/my-command.md",
		},
		{
			name:        "prompts directory",
			pattern:     "prompts/{name}.md",
			commandName: "my-command",
			want:        "prompts/my-command.md",
		},
		{
			name:        "workflows directory",
			pattern:     "workflows/{name}.md",
			commandName: "test",
			want:        "workflows/test.md",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			conv := Conventions{Commands: tt.pattern}
			got := conv.CommandPath(tt.commandName)
			if got != tt.want {
				t.Errorf("CommandPath() = %q, want %q", got, tt.want)
			}
		})
	}
}
