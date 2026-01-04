# OpenCode SDD Uninstaller (Windows PowerShell)
# Removes the Spec-Driven Development process for OpenCode

$ErrorActionPreference = "Stop"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red; exit 1 }

# Find git root by walking up directories
function Find-GitRoot {
    $dir = Get-Location
    while ($dir -ne $null -and $dir.Path -ne "") {
        $gitDir = Join-Path $dir.Path ".git"
        if (Test-Path $gitDir) {
            return $dir.Path
        }
        $parent = Split-Path $dir.Path -Parent
        if ($parent -eq $dir.Path) { break }
        $dir = Get-Item $parent -ErrorAction SilentlyContinue
    }
    return $null
}

# Remove SDD files from a target directory
function Remove-SDDFiles {
    param($Target)
    $removed = 0

    $paths = @(
        "$Target\agent\sdd",
        "$Target\agent\search",
        "$Target\agent\librarian.md",
        "$Target\command\sdd",
        "$Target\skill\spec-format",
        "$Target\skill\sdd-state-management",
        "$Target\skill\research",
        "$Target\skill\architecture-fit-check",
        "$Target\skill\architecture-workshop"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force
            $removed++
        }
    }

    return $removed
}

# Main
function Main {
    Write-Host ""
    Write-Host "  OpenCode SDD Uninstaller"
    Write-Host "  ========================"
    Write-Host ""

    # Check what installations exist
    $GlobalRoot = Join-Path $HOME ".config\opencode"
    $LocalRoot = $null

    $GitRoot = Find-GitRoot
    if ($GitRoot) {
        $LocalRoot = Join-Path $GitRoot ".opencode"
    }

    $GlobalExists = $false
    $LocalExists = $false

    if ((Test-Path "$GlobalRoot\agent\sdd") -or (Test-Path "$GlobalRoot\command\sdd")) {
        $GlobalExists = $true
    }

    if ($LocalRoot -and ((Test-Path "$LocalRoot\agent\sdd") -or (Test-Path "$LocalRoot\command\sdd"))) {
        $LocalExists = $true
    }

    if (-not $GlobalExists -and -not $LocalExists) {
        Write-Host "No SDD installation found."
        Write-Host ""
        Write-Host "Checked:"
        Write-Host "  - Global: $GlobalRoot"
        if ($LocalRoot) {
            Write-Host "  - Local:  $LocalRoot"
        } else {
            Write-Host "  - Local:  (not in a git repository)"
        }
        Write-Host ""
        exit 0
    }

    Write-Host "Found SDD installation(s):"
    Write-Host ""
    if ($GlobalExists) {
        Write-Host "  1) Global ($GlobalRoot)"
    }
    if ($LocalExists) {
        Write-Host "  2) Local ($LocalRoot)"
    }
    Write-Host ""

    # Determine what to uninstall
    $UninstallGlobal = $false
    $UninstallLocal = $false

    if ($GlobalExists -and $LocalExists) {
        Write-Host "What would you like to uninstall?"
        Write-Host "  1) Global only"
        Write-Host "  2) Local only"
        Write-Host "  3) Both"
        Write-Host ""
        $choice = Read-Host "Enter choice [1/2/3]"
        switch ($choice) {
            "1" { $UninstallGlobal = $true; $UninstallLocal = $false }
            "2" { $UninstallGlobal = $false; $UninstallLocal = $true }
            "3" { $UninstallGlobal = $true; $UninstallLocal = $true }
            default { Write-Err "Invalid choice" }
        }
    } elseif ($GlobalExists) {
        $UninstallGlobal = $true
    } else {
        $UninstallLocal = $true
    }

    Write-Host ""
    Write-Warn "This will remove SDD agents, commands, and skills."
    Write-Warn "Your project files (changes/, docs/specs/, etc.) will NOT be affected."
    Write-Host ""

    $confirm = Read-Host "Proceed with uninstall? [y/N]"
    if ($confirm -notmatch "^[Yy]") {
        Write-Host "Aborted."
        exit 0
    }

    Write-Host ""

    # Perform uninstall
    if ($UninstallGlobal) {
        Write-Info "Removing global installation..."
        $count = Remove-SDDFiles -Target $GlobalRoot
        Write-Success "Removed $count items from $GlobalRoot"
    }

    if ($UninstallLocal) {
        Write-Info "Removing local installation..."
        $count = Remove-SDDFiles -Target $LocalRoot
        Write-Success "Removed $count items from $LocalRoot"
    }

    Write-Host ""
    Write-Success "SDD uninstalled successfully!"
    Write-Host ""
}

Main
