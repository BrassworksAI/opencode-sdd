# OpenCode SDD Installer (Windows PowerShell)
# Downloads and installs the Spec-Driven Development process for OpenCode

$ErrorActionPreference = "Stop"

$RepoOwner = "BrassworksAI"
$RepoName = "opencode-sdd"
$Branch = "main"
$ArchiveUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/heads/$Branch.zip"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red; exit 1 }

# Find git root by walking up directories (no git required)
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

# Main
function Main {
    Write-Host ""
    Write-Host "  OpenCode SDD Installer"
    Write-Host "  ======================"
    Write-Host ""

    # Choose install mode
    Write-Host "Where would you like to install?"
    Write-Host "  1) Global (~/.config/opencode)"
    Write-Host "  2) Local (current repo's .opencode folder)"
    Write-Host ""
    $choice = Read-Host "Enter choice [1/2]"

    switch ($choice) {
        "1" {
            $InstallMode = "global"
            $TargetRoot = Join-Path $HOME ".config/opencode"
        }
        "2" {
            $InstallMode = "local"
            $GitRoot = Find-GitRoot
            if (-not $GitRoot) {
                Write-Err "Not inside a git repository. Cannot determine repo root for local install."
            }
            $TargetRoot = Join-Path $GitRoot ".opencode"
        }
        default {
            Write-Err "Invalid choice. Please enter 1 or 2."
        }
    }

    Write-Info "Install mode: $InstallMode"
    Write-Info "Target: $TargetRoot"
    Write-Host ""

    # Create temp directory
    $TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

    try {
        Write-Info "Downloading archive..."

        $ZipPath = Join-Path $TmpDir "repo.zip"
        Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ZipPath -UseBasicParsing

        Write-Info "Extracting archive..."
        Expand-Archive -Path $ZipPath -DestinationPath $TmpDir -Force

        # Find extracted directory (GitHub names it <repo>-<branch>)
        $ExtractedDir = Join-Path $TmpDir "$RepoName-$Branch"
        $PayloadDir = Join-Path $ExtractedDir "opencode"

        if (-not (Test-Path $PayloadDir)) {
            Write-Err "Payload directory 'opencode/' not found in archive"
        }

        Write-Success "Downloaded and extracted"

        # Build file list and detect conflicts
        Write-Info "Scanning for conflicts..."
        $Conflicts = @()

        $Files = Get-ChildItem -Path $PayloadDir -Recurse -File
        foreach ($file in $Files) {
            $relativePath = $file.FullName.Substring($PayloadDir.Length + 1)
            $destPath = Join-Path $TargetRoot $relativePath
            if (Test-Path $destPath) {
                $Conflicts += $relativePath
            }
        }

        # Handle conflicts
        if ($Conflicts.Count -gt 0) {
            Write-Host ""
            Write-Warn "Found $($Conflicts.Count) conflicting file(s) that would be overwritten:"
            Write-Host ""
            $Conflicts | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
            if ($Conflicts.Count -gt 20) {
                Write-Host "  ... and $($Conflicts.Count - 20) more"
            }
            Write-Host ""
            Write-Warn "Back up any files you want to keep before proceeding."
            Write-Host ""
            $confirm = Read-Host "Overwrite ALL conflicting files? [y/N]"
            if ($confirm -notmatch "^[Yy]") {
                Write-Err "Installation aborted by user"
            }
            Write-Host ""
        } else {
            Write-Success "No conflicts detected"
        }

        # Copy files
        Write-Info "Installing files..."

        foreach ($file in $Files) {
            $relativePath = $file.FullName.Substring($PayloadDir.Length + 1)
            $destPath = Join-Path $TargetRoot $relativePath
            $destDir = Split-Path $destPath -Parent

            # Create parent directories if needed
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }

            Copy-Item -Path $file.FullName -Destination $destPath -Force
        }

        Write-Host ""
        Write-Success "Installation complete!"
        Write-Host ""
        Write-Info "Installed to: $TargetRoot"
        Write-Host ""

        if ($InstallMode -eq "global") {
            Write-Host "SDD commands are now available globally in OpenCode."
        } else {
            Write-Host "SDD commands are now available for this repository."
        }
        Write-Host ""

    } finally {
        # Cleanup
        if (Test-Path $TmpDir) {
            Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
