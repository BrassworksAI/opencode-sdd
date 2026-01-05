# Agent Extensions Installer (Windows PowerShell)
# Downloads and installs the Spec-Driven Development process for OpenCode and/or Augment

$ErrorActionPreference = "Stop"

$RepoOwner = "BrassworksAI"
$RepoName = "agent-extensions"
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

# Install files from payload to target
function Install-Files {
    param(
        [string]$PayloadDir,
        [string]$TargetRoot,
        [string]$Label
    )

    if (-not (Test-Path $PayloadDir)) {
        Write-Warn "Payload directory '$PayloadDir' not found, skipping $Label"
        return $false
    }

    Write-Info "Installing $Label to: $TargetRoot"

    # Build file list and detect conflicts
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
        Write-Warn "Found $($Conflicts.Count) conflicting file(s) for ${Label}:"
        Write-Host ""
        $Conflicts | Select-Object -First 20 | ForEach-Object { Write-Host "  $_" }
        if ($Conflicts.Count -gt 20) {
            Write-Host "  ... and $($Conflicts.Count - 20) more"
        }
        Write-Host ""
        $confirm = Read-Host "Overwrite conflicting files for ${Label}? [y/N]"
        if ($confirm -notmatch "^[Yy]") {
            Write-Warn "Skipping $Label install"
            return $false
        }
        Write-Host ""
    }

    # Copy files
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

    Write-Success "Installed $Label to: $TargetRoot"
    return $true
}

# Main
function Main {
    Write-Host ""
    Write-Host "  Agent Extensions Installer"
    Write-Host "  ==========================="
    Write-Host ""

    # Choose tool
    Write-Host "Which tool(s) would you like to install extensions for?"
    Write-Host "  1) OpenCode"
    Write-Host "  2) Augment (Auggie)"
    Write-Host "  3) Both"
    Write-Host ""
    $toolChoice = Read-Host "Enter choice [1/2/3]"

    $InstallOpenCode = $false
    $InstallAugment = $false

    switch ($toolChoice) {
        "1" { $InstallOpenCode = $true }
        "2" { $InstallAugment = $true }
        "3" { $InstallOpenCode = $true; $InstallAugment = $true }
        default { Write-Err "Invalid choice. Please enter 1, 2, or 3." }
    }

    # Choose install mode
    Write-Host ""
    Write-Host "Where would you like to install?"
    Write-Host "  1) Global (user config directory)"
    Write-Host "  2) Local (current repo)"
    Write-Host ""
    $scopeChoice = Read-Host "Enter choice [1/2]"

    $InstallMode = ""
    $GitRoot = ""

    switch ($scopeChoice) {
        "1" { $InstallMode = "global" }
        "2" {
            $InstallMode = "local"
            $GitRoot = Find-GitRoot
            if (-not $GitRoot) {
                Write-Err "Not inside a git repository. Cannot determine repo root for local install."
            }
        }
        default { Write-Err "Invalid choice. Please enter 1 or 2." }
    }

    # Set target directories based on choices
    if ($InstallMode -eq "global") {
        $OpenCodeTarget = Join-Path $HOME ".config/opencode"
        $AugmentTarget = Join-Path $HOME ".augment"
    } else {
        $OpenCodeTarget = Join-Path $GitRoot ".opencode"
        $AugmentTarget = Join-Path $GitRoot ".augment"
    }

    Write-Host ""
    Write-Info "Install mode: $InstallMode"
    if ($InstallOpenCode) { Write-Info "OpenCode target: $OpenCodeTarget" }
    if ($InstallAugment) { Write-Info "Augment target: $AugmentTarget" }
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

        Write-Success "Downloaded and extracted"
        Write-Host ""

        $InstalledCount = 0

        # Install OpenCode if requested
        if ($InstallOpenCode) {
            $OpenCodePayload = Join-Path $ExtractedDir "opencode"
            if (Install-Files -PayloadDir $OpenCodePayload -TargetRoot $OpenCodeTarget -Label "OpenCode") {
                $InstalledCount++
            }
            Write-Host ""
        }

        # Install Augment if requested
        if ($InstallAugment) {
            $AugmentPayload = Join-Path $ExtractedDir "augment"
            if (Install-Files -PayloadDir $AugmentPayload -TargetRoot $AugmentTarget -Label "Augment") {
                $InstalledCount++
            }
            Write-Host ""
        }

        if ($InstalledCount -eq 0) {
            Write-Err "No installations completed"
        }

        Write-Success "Installation complete!"
        Write-Host ""

        if ($InstallMode -eq "global") {
            Write-Host "SDD commands are now available globally."
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
