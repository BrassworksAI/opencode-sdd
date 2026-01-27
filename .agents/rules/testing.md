# Testing Requirements

## Running Tests

```bash
# Run all tests
go test ./internal/... -v

# Run with coverage
go test ./internal/... -cover

# Run specific package
go test ./internal/installer/... -v
```

## Test Structure

### Unit Tests

Located alongside source files as `*_test.go`:

- `internal/config/config_test.go`
- `internal/registry/registry_test.go`
- `internal/detect/detect_test.go`

### Integration Tests

The installer package contains integration tests that verify the full install/uninstall matrix:

- `internal/installer/installer_test.go`

## Test Isolation

**Critical:** All tests must use `t.TempDir()` for filesystem operations.

```go
func TestSomething(t *testing.T) {
    globalDir := t.TempDir()   // Isolated global path
    projectRoot := t.TempDir() // Isolated local path
    // ... test code
}
```

This ensures:

- Tests never touch real `~/.factory`, `~/.claude`, etc.
- Tests are isolated from each other
- Temp directories auto-cleanup after tests

## Coverage Targets

| Package | Target |
|---------|--------|
| config | >85% |
| registry | >95% |
| installer | >85% |
| detect | >90% |

## What to Test

### Install/Uninstall Matrix

Every combination of:

- Tool conventions (directory-based skills, single-file skills, prompts-style commands)
- Categories (all defined in extensions.yaml)
- Scopes (global, local, both)

### Edge Cases

- Unknown tool names
- Unknown category names
- Re-installing (overwrite)
- Installing multiple categories
- Empty directory cleanup on uninstall
- Symlink integrity (points to valid cache files)
- Cache content matches source
