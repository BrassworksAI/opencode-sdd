# Coding Standards

## Go Conventions

### Package Structure

```text
cmd/ae/          # CLI entry point
internal/        # Private packages
  config/        # YAML config loading
  registry/      # Extension registry
  installer/     # Install/uninstall logic
  ui/            # Terminal UI (gum wrapper)
  detect/        # Environment detection
  embedded/      # Embedded filesystem
repository/      # Source content
  commands/      # Command markdown files
  skills/        # Skill directories
  hooks/         # Hook scripts
```

### Error Handling

- Wrap errors with context: `fmt.Errorf("doing X: %w", err)`
- Return errors, don't panic
- Check errors immediately after function calls

### Naming

- Use descriptive names over abbreviations
- Interfaces end in `-er` when appropriate
- Test files: `*_test.go`

## Markdown Files

### Validation Required

Run after every markdown edit:

```bash
markdownlint -f .
# or for a specific file
markdownlint -f <filename>.md
```

### Structure

- Commands go in `repository/commands/{name}.md`
- Skills go in `repository/skills/{name}/SKILL.md`
- Each skill can have additional helper files in its directory

## Configuration Files

### tools.yaml

Defines supported AI tools and their conventions:

```yaml
tools:
  tool-name:
    name: Display Name
    global_path: ~/.tool-name
    local_path: .tool-name
    conventions:
      skills: skills/{name}/SKILL.md  # or skills/{name}.md
      commands: commands/{name}.md
```

Commands and skills are automatically discovered from the `repository/` directory.
