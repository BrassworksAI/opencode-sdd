package embedded

import (
	"embed"
	"io/fs"
)

// Content will be populated at build time using -ldflags or by copying files
// For now, we use a generate script to copy files before build
//
//go:embed content
var Content embed.FS

// FS returns the embedded filesystem rooted at "content"
func FS() (fs.FS, error) {
	return fs.Sub(Content, "content")
}
