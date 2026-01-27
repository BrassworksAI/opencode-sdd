package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"

	"github.com/shanepadgett/agent-extensions/internal/embedded"
	"github.com/shanepadgett/agent-extensions/internal/installer"
	"github.com/shanepadgett/agent-extensions/internal/registry"
	"github.com/shanepadgett/agent-extensions/internal/ui"
	"github.com/spf13/cobra"
)

var version = "dev"

func main() {
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

var rootCmd = &cobra.Command{
	Use:   "ae",
	Short: "Agent Extensions CLI",
	Long:  "Manage installation of commands and skills for AI coding agents",
}

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Install extensions to agent tools",
	RunE:  runInstall,
}

var uninstallCmd = &cobra.Command{
	Use:   "uninstall",
	Short: "Uninstall extensions from agent tools",
	RunE:  runUninstall,
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List available extensions and tools",
	RunE:  runList,
}

var doctorCmd = &cobra.Command{
	Use:   "doctor",
	Short: "Check installation health and diagnose issues",
	RunE:  runDoctor,
}

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update repository and refresh installed extensions",
	RunE:  runUpdate,
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version information",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("ae version %s\n", version)
	},
}

var (
	flagCategory string
	flagTools    []string
	flagScope    string
	flagYes      bool
)

func init() {
	installCmd.Flags().StringVarP(&flagCategory, "category", "c", "", "Category to install (product, dev)")
	installCmd.Flags().StringSliceVarP(&flagTools, "tools", "t", nil, "Tools to install to (comma-separated)")
	installCmd.Flags().StringVarP(&flagScope, "scope", "s", "", "Installation scope (global, local, both)")
	installCmd.Flags().BoolVarP(&flagYes, "yes", "y", false, "Skip confirmation")

	uninstallCmd.Flags().StringVarP(&flagCategory, "category", "c", "", "Category to uninstall")
	uninstallCmd.Flags().StringSliceVarP(&flagTools, "tools", "t", nil, "Tools to uninstall from (comma-separated)")
	uninstallCmd.Flags().StringVarP(&flagScope, "scope", "s", "", "Uninstallation scope (global, local, both)")
	uninstallCmd.Flags().BoolVarP(&flagYes, "yes", "y", false, "Skip confirmation")

	rootCmd.AddCommand(installCmd)
	rootCmd.AddCommand(uninstallCmd)
	rootCmd.AddCommand(listCmd)
	rootCmd.AddCommand(doctorCmd)
	rootCmd.AddCommand(updateCmd)
	rootCmd.AddCommand(versionCmd)
}

func getRegistry() (*registry.Registry, error) {
	fsys, err := embedded.FS()
	if err != nil {
		return nil, fmt.Errorf("loading embedded content: %w", err)
	}
	return registry.New(fsys)
}

func getProjectRoot() string {
	cwd, _ := os.Getwd()
	return cwd
}

func runInstall(cmd *cobra.Command, args []string) error {
	u := ui.New()

	u.Title()

	reg, err := getRegistry()
	if err != nil {
		return fmt.Errorf("loading registry: %w", err)
	}

	var selectedCategories []string
	var selectedTools []string
	var scope string

	// Use flags if provided, otherwise interactive
	if flagCategory != "" {
		selectedCategories = strings.Split(flagCategory, ",")
	} else {
		categories := reg.GetCategoryNames()
		sort.Strings(categories)

		// Build category options with aligned columns
		categoryOptions := make([]string, len(categories))
		for i, catName := range categories {
			cat, _ := reg.GetCategory(catName)
			categoryOptions[i] = fmt.Sprintf("%-8s │ %2d commands, %2d skills │ %s",
				catName, len(cat.Commands), len(cat.Skills), cat.Description)
		}

		selected, err := u.ChooseMulti("Select packages to install:", categoryOptions)
		if err != nil {
			return err
		}
		// Extract category names from selections
		for _, sel := range selected {
			parts := strings.Split(sel, " │ ")
			if len(parts) > 0 {
				selectedCategories = append(selectedCategories, strings.TrimSpace(parts[0]))
			}
		}
	}

	// Collect all commands and skills from selected categories
	totalCommands := 0
	totalSkills := 0
	for _, catName := range selectedCategories {
		cat, ok := reg.GetCategory(catName)
		if !ok {
			return fmt.Errorf("unknown category: %s", catName)
		}
		totalCommands += len(cat.Commands)
		totalSkills += len(cat.Skills)
	}

	fmt.Println()
	u.Info(fmt.Sprintf("Selected: %s (%d commands, %d skills)",
		strings.Join(selectedCategories, ", "), totalCommands, totalSkills))

	if len(flagTools) > 0 {
		selectedTools = flagTools
	} else {
		tools := reg.GetToolNames()
		sort.Strings(tools)
		fmt.Println()
		selectedTools, err = u.ChooseMulti("Select tools to install to:", tools)
		if err != nil {
			return err
		}
	}

	if flagScope != "" {
		scope = flagScope
	} else {
		fmt.Println()
		scope, err = u.Choose("Select scope:", []string{"global", "local", "both"})
		if err != nil {
			return err
		}
	}

	var installScope installer.Scope
	switch scope {
	case "global":
		installScope = installer.ScopeGlobal
	case "local":
		installScope = installer.ScopeLocal
	case "both":
		installScope = installer.ScopeBoth
	default:
		return fmt.Errorf("unknown scope: %s", scope)
	}

	// Confirm
	fmt.Println()
	if !flagYes {
		confirmMsg := fmt.Sprintf("Install %d commands and %d skills to %d tools (%s)?",
			totalCommands, totalSkills, len(selectedTools), scope)
		confirmed, err := u.Confirm(confirmMsg)
		if err != nil {
			return err
		}
		if !confirmed {
			u.Warn("Installation cancelled")
			return nil
		}
	}

	// Install
	inst := installer.New(reg, getProjectRoot())

	fmt.Println()
	installedCommands := 0
	installedSkills := 0

	for _, toolName := range selectedTools {
		for _, catName := range selectedCategories {
			result, err := inst.Install(toolName, installScope, catName)
			if err != nil {
				u.Error(fmt.Sprintf("%s: %v", toolName, err))
				continue
			}

			if len(result.Errors) > 0 {
				for _, e := range result.Errors {
					u.Warn(fmt.Sprintf("%s: %v", toolName, e))
				}
			}

			tool, _ := reg.GetTool(toolName)
			u.Success(fmt.Sprintf("%s [%s]: %d commands, %d skills", tool.Name, catName, result.Commands, result.Skills))
			installedCommands += result.Commands
			installedSkills += result.Skills
		}
	}

	fmt.Println()
	u.Success(fmt.Sprintf("Installed %d commands and %d skills total", installedCommands, installedSkills))

	return nil
}

func runUninstall(cmd *cobra.Command, args []string) error {
	u := ui.New()

	u.Title()

	reg, err := getRegistry()
	if err != nil {
		return fmt.Errorf("loading registry: %w", err)
	}

	var selectedCategories []string
	var selectedTools []string
	var scope string

	if flagCategory != "" {
		selectedCategories = strings.Split(flagCategory, ",")
	} else {
		categories := reg.GetCategoryNames()
		sort.Strings(categories)

		categoryOptions := make([]string, len(categories))
		for i, catName := range categories {
			cat, _ := reg.GetCategory(catName)
			categoryOptions[i] = fmt.Sprintf("%-8s │ %2d commands, %2d skills │ %s",
				catName, len(cat.Commands), len(cat.Skills), cat.Description)
		}

		selected, err := u.ChooseMulti("Select packages to uninstall:", categoryOptions)
		if err != nil {
			return err
		}
		for _, sel := range selected {
			parts := strings.Split(sel, " │ ")
			if len(parts) > 0 {
				selectedCategories = append(selectedCategories, strings.TrimSpace(parts[0]))
			}
		}
	}

	// Validate categories
	totalCommands := 0
	totalSkills := 0
	for _, catName := range selectedCategories {
		cat, ok := reg.GetCategory(catName)
		if !ok {
			return fmt.Errorf("unknown category: %s", catName)
		}
		totalCommands += len(cat.Commands)
		totalSkills += len(cat.Skills)
	}

	fmt.Println()
	u.Info(fmt.Sprintf("Selected: %s (%d commands, %d skills)",
		strings.Join(selectedCategories, ", "), totalCommands, totalSkills))

	if len(flagTools) > 0 {
		selectedTools = flagTools
	} else {
		tools := reg.GetToolNames()
		sort.Strings(tools)
		fmt.Println()
		selectedTools, err = u.ChooseMulti("Select tools to uninstall from:", tools)
		if err != nil {
			return err
		}
	}

	if flagScope != "" {
		scope = flagScope
	} else {
		fmt.Println()
		scope, err = u.Choose("Select scope:", []string{"global", "local", "both"})
		if err != nil {
			return err
		}
	}

	var uninstallScope installer.Scope
	switch scope {
	case "global":
		uninstallScope = installer.ScopeGlobal
	case "local":
		uninstallScope = installer.ScopeLocal
	case "both":
		uninstallScope = installer.ScopeBoth
	default:
		return fmt.Errorf("unknown scope: %s", scope)
	}

	// Confirm
	fmt.Println()
	if !flagYes {
		confirmed, err := u.Confirm(fmt.Sprintf("Uninstall %d commands and %d skills from %d tools?",
			totalCommands, totalSkills, len(selectedTools)))
		if err != nil {
			return err
		}
		if !confirmed {
			u.Warn("Uninstallation cancelled")
			return nil
		}
	}

	// Uninstall
	inst := installer.New(reg, getProjectRoot())

	fmt.Println()
	removedCommands := 0
	removedSkills := 0

	for _, toolName := range selectedTools {
		for _, catName := range selectedCategories {
			result, err := inst.Uninstall(toolName, uninstallScope, catName)
			if err != nil {
				u.Error(fmt.Sprintf("%s: %v", toolName, err))
				continue
			}

			tool, _ := reg.GetTool(toolName)
			u.Success(fmt.Sprintf("%s [%s]: removed %d commands, %d skills", tool.Name, catName, result.Commands, result.Skills))
			removedCommands += result.Commands
			removedSkills += result.Skills
		}
	}

	fmt.Println()
	u.Success(fmt.Sprintf("Removed %d commands and %d skills total", removedCommands, removedSkills))

	return nil
}

func runList(cmd *cobra.Command, args []string) error {
	u := ui.New()

	reg, err := getRegistry()
	if err != nil {
		return fmt.Errorf("loading registry: %w", err)
	}

	projectRoot := getProjectRoot()
	tools := reg.GetToolNames()
	sort.Strings(tools)
	categories := reg.GetCategoryNames()
	sort.Strings(categories)

	// Check installation status per category per tool
	type installStatus struct {
		global bool
		local  bool
	}

	// category -> tool -> status
	catStatus := make(map[string]map[string]installStatus)
	for _, catName := range categories {
		catStatus[catName] = make(map[string]installStatus)
	}

	for _, toolKey := range tools {
		tool, _ := reg.GetTool(toolKey)
		globalPath := tool.ResolveGlobalPath()
		localPath := tool.ResolveLocalPath(projectRoot)

		for _, catName := range categories {
			cat, _ := reg.GetCategory(catName)
			status := installStatus{}

			// Check if any command from this category is installed
			for _, c := range cat.Commands {
				cmdPath := tool.Conventions.CommandPath(c)
				if _, err := os.Stat(filepath.Join(globalPath, cmdPath)); err == nil {
					status.global = true
				}
				if _, err := os.Stat(filepath.Join(localPath, cmdPath)); err == nil {
					status.local = true
				}
			}

			// Check if any skill from this category is installed
			for _, s := range cat.Skills {
				skillPath := tool.Conventions.SkillPath(s)
				globalSkillPath := filepath.Join(globalPath, skillPath)
				localSkillPath := filepath.Join(localPath, skillPath)

				if filepath.Ext(skillPath) != ".md" {
					globalSkillPath = filepath.Dir(globalSkillPath)
					localSkillPath = filepath.Dir(localSkillPath)
				}

				if _, err := os.Stat(globalSkillPath); err == nil {
					status.global = true
				}
				if _, err := os.Stat(localSkillPath); err == nil {
					status.local = true
				}
			}

			catStatus[catName][toolKey] = status
		}
	}

	statusIcon := func(s installStatus) string {
		if s.global && s.local {
			return "GL"
		} else if s.global {
			return "G "
		} else if s.local {
			return " L"
		}
		return "  "
	}

	u.Header("\nInstallation Status")
	fmt.Println("G=global  L=local  GL=both\n")

	// Build tool header
	toolAbbr := make([]string, len(tools))
	for i, t := range tools {
		tool, _ := reg.GetTool(t)
		abbr := tool.Name
		if len(abbr) > 4 {
			abbr = abbr[:4]
		}
		toolAbbr[i] = fmt.Sprintf("%-4s", abbr)
	}

	fmt.Printf("%-10s %s\n", "", strings.Join(toolAbbr, " "))
	fmt.Printf("%-10s %s\n", "", strings.Repeat("---- ", len(tools)))

	for _, catName := range categories {
		cat, _ := reg.GetCategory(catName)
		statuses := make([]string, len(tools))
		for i, t := range tools {
			s := catStatus[catName][t]
			statuses[i] = fmt.Sprintf("[%s]", statusIcon(s))
		}
		fmt.Printf("%-10s %s\n", catName, strings.Join(statuses, " "))
		fmt.Printf("%-10s %d commands, %d skills\n", "", len(cat.Commands), len(cat.Skills))
	}

	fmt.Println()
	return nil
}

func runDoctor(cmd *cobra.Command, args []string) error {
	u := ui.New()

	u.Header("\n  Agent Extensions Doctor\n")

	reg, err := getRegistry()
	if err != nil {
		u.Error(fmt.Sprintf("Config: %v", err))
		return nil
	}
	u.Success("Config: tools.yaml and extensions.yaml loaded (embedded)")

	// Check gum (try running it to handle mise/shim scenarios)
	gumCmd := exec.Command("gum", "--version")
	if out, err := gumCmd.Output(); err != nil {
		u.Error("gum: not found (required for interactive mode)")
	} else {
		u.Success(fmt.Sprintf("gum: %s", strings.TrimSpace(string(out))))
	}

	// Check each tool's global path
	u.Header("\nTool Paths:")
	tools := reg.GetToolNames()
	sort.Strings(tools)

	for _, name := range tools {
		tool, _ := reg.GetTool(name)
		globalPath := tool.ResolveGlobalPath()

		if _, err := os.Stat(globalPath); err == nil {
			u.Success(fmt.Sprintf("%s: %s exists", tool.Name, tool.GlobalPath))
		} else {
			u.Warn(fmt.Sprintf("%s: %s not found (tool may not be installed)", tool.Name, tool.GlobalPath))
		}
	}

	// Check cache directories
	u.Header("\nCache:")
	home, _ := os.UserHomeDir()
	globalCache := filepath.Join(home, ".agents", ".cache", "agent-extensions")
	localCache := filepath.Join(getProjectRoot(), ".agents", ".cache", "agent-extensions")

	if _, err := os.Stat(globalCache); err == nil {
		u.Success(fmt.Sprintf("Global cache: %s", globalCache))
	} else {
		u.Info(fmt.Sprintf("Global cache: not created yet (%s)", globalCache))
	}

	if _, err := os.Stat(localCache); err == nil {
		u.Success(fmt.Sprintf("Local cache: %s", localCache))
	} else {
		u.Info(fmt.Sprintf("Local cache: not created yet (%s)", localCache))
	}

	// Check for broken symlinks
	u.Header("\nSymlink Health:")
	brokenLinks := 0

	for _, name := range tools {
		tool, _ := reg.GetTool(name)
		globalPath := tool.ResolveGlobalPath()

		// Check commands dir
		cmdDir := filepath.Join(globalPath, filepath.Dir(tool.Conventions.CommandPath("test")))
		if entries, err := os.ReadDir(cmdDir); err == nil {
			for _, entry := range entries {
				fullPath := filepath.Join(cmdDir, entry.Name())
				if info, err := os.Lstat(fullPath); err == nil && info.Mode()&os.ModeSymlink != 0 {
					if _, err := os.Stat(fullPath); err != nil {
						u.Warn(fmt.Sprintf("Broken symlink: %s", fullPath))
						brokenLinks++
					}
				}
			}
		}
	}

	if brokenLinks == 0 {
		u.Success("No broken symlinks found")
	} else {
		u.Warn(fmt.Sprintf("Found %d broken symlinks (run 'ae install' to fix)", brokenLinks))
	}

	fmt.Println()
	return nil
}

func runUpdate(cmd *cobra.Command, args []string) error {
	u := ui.New()

	u.Title()

	u.Info(fmt.Sprintf("ae version %s", version))
	u.Info("Extensions are embedded in the binary. To get new extensions, update the ae binary itself.")
	fmt.Println()

	reg, err := getRegistry()
	if err != nil {
		return fmt.Errorf("loading registry: %w", err)
	}

	projectRoot := getProjectRoot()
	tools := reg.GetToolNames()
	categories := reg.GetCategoryNames()

	// Find what's currently installed and refresh symlinks
	inst := installer.New(reg, projectRoot)

	fmt.Println()
	u.Info("Refreshing installed extensions...")

	refreshedCount := 0
	for _, toolKey := range tools {
		tool, _ := reg.GetTool(toolKey)
		globalPath := tool.ResolveGlobalPath()
		localPath := tool.ResolveLocalPath(projectRoot)

		for _, catName := range categories {
			cat, _ := reg.GetCategory(catName)

			// Check if category is installed globally
			globalInstalled := false
			for _, c := range cat.Commands {
				cmdPath := tool.Conventions.CommandPath(c)
				if _, err := os.Stat(filepath.Join(globalPath, cmdPath)); err == nil {
					globalInstalled = true
					break
				}
			}

			// Check if category is installed locally
			localInstalled := false
			for _, c := range cat.Commands {
				cmdPath := tool.Conventions.CommandPath(c)
				if _, err := os.Stat(filepath.Join(localPath, cmdPath)); err == nil {
					localInstalled = true
					break
				}
			}

			// Refresh installations
			if globalInstalled {
				if _, err := inst.Install(toolKey, installer.ScopeGlobal, catName); err == nil {
					refreshedCount++
				}
			}
			if localInstalled {
				if _, err := inst.Install(toolKey, installer.ScopeLocal, catName); err == nil {
					refreshedCount++
				}
			}
		}
	}

	fmt.Println()
	if refreshedCount > 0 {
		u.Success(fmt.Sprintf("Refreshed %d installation(s)", refreshedCount))
	} else {
		u.Info("No extensions currently installed")
	}

	return nil
}
