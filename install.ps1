# Agent Extensions Install (Windows PowerShell)
# Creates global symlinks and local copies of the repo's folders
# Local copies avoid repo-specific symlinks checked into git

$ErrorActionPreference = "Stop"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red; exit 1 }

function Confirm-YesNo {
    param([string]$Prompt)
    $answer = Read-Host "$Prompt [y/N]"
    return $answer -match "^[Yy]"
}

function Find-GitRoot {
    $dir = (Get-Location).Path
    while ($true) {
        if (Test-Path (Join-Path $dir ".git")) { return $dir }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

# Template variable storage
$script:TemplateVars = @{}

function Set-TemplateVars {
    param(
        [string]$Tool,
        [string]$Mode
    )

    $script:TemplateVars = @{}

    switch ("$Tool`:$Mode") {
        "opencode:global" {
            $script:TemplateVars["SKILL_INSTALL_PATH"] = '$HOME/.config/opencode/skill'
            $script:TemplateVars["SKILL_LOCAL_PATH"] = '.opencode/skill'
            $script:TemplateVars["SKILL_GLOBAL_PATH"] = '~/.config/opencode/skill'
        }
        "opencode:local" {
            $script:TemplateVars["SKILL_INSTALL_PATH"] = './.opencode/skill'
            $script:TemplateVars["SKILL_LOCAL_PATH"] = '.opencode/skill'
            $script:TemplateVars["SKILL_GLOBAL_PATH"] = '~/.config/opencode/skill'
        }
        "codex:global" {
            $script:TemplateVars["SKILL_INSTALL_PATH"] = '$HOME/.codex/skills'
            $script:TemplateVars["SKILL_LOCAL_PATH"] = '.codex/skills'
            $script:TemplateVars["SKILL_GLOBAL_PATH"] = '~/.codex/skills'
        }
        "codex:local" {
            $script:TemplateVars["SKILL_INSTALL_PATH"] = './.codex/skills'
            $script:TemplateVars["SKILL_LOCAL_PATH"] = '.codex/skills'
            $script:TemplateVars["SKILL_GLOBAL_PATH"] = '~/.codex/skills'
        }
        default {
            Write-Err "Unknown tool/mode combination: $Tool`:$Mode"
        }
    }
}

function Render-Template {
    param(
        [string]$SrcFile,
        [string]$DestFile
    )

    $destDir = Split-Path $DestFile -Parent
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $content = Get-Content $SrcFile -Raw -Encoding UTF8
    foreach ($key in $script:TemplateVars.Keys) {
        $pattern = [regex]::Escape("{{{$key}}}")
        $content = $content -replace $pattern, $script:TemplateVars[$key]
    }
    Set-Content -Path $DestFile -Value $content -NoNewline -Encoding UTF8
}

function Install-Skills {
    param(
        [string]$TargetDir,
        [string]$SkillsSrc,
        [string]$CacheDir,
        [string]$Tool,
        [string]$Mode,
        [string]$Label,
        [string]$InstallType  # "symlink" or "copy"
    )

    if (-not (Test-Path $SkillsSrc)) {
        Write-Warn "Skills directory '$SkillsSrc' not found, skipping $Label"
        return $false
    }

    Write-Info "Installing $Label to: $TargetDir"

    # Set template variables for this tool/mode
    Set-TemplateVars -Tool $Tool -Mode $Mode

    # Clear and recreate cache directory for this tool
    $toolCache = Join-Path $CacheDir $Tool
    if (Test-Path $toolCache) {
        Remove-Item $toolCache -Recurse -Force
    }
    New-Item -ItemType Directory -Path $toolCache -Force | Out-Null

    # Process each skill directory
    $skillDirs = Get-ChildItem -Path $SkillsSrc -Directory
    foreach ($skillDir in $skillDirs) {
        $skillName = $skillDir.Name
        $skillTarget = Join-Path $TargetDir $skillName
        $skillSrcPath = $skillDir.FullName

        # Check for conflict: both SKILL.md and SKILL.tmpl.md
        $hasSkillMd = Test-Path (Join-Path $skillSrcPath "SKILL.md")
        $hasSkillTmplMd = Test-Path (Join-Path $skillSrcPath "SKILL.tmpl.md")
        if ($hasSkillMd -and $hasSkillTmplMd) {
            Write-Err "Conflict: both SKILL.md and SKILL.tmpl.md exist in $skillSrcPath"
        }

        # Determine if this skill uses templates
        $hasTemplates = $false
        if ($hasSkillTmplMd) {
            $hasTemplates = $true
        } else {
            # Check for any .tmpl.md files in subdirectories
            $tmplFiles = Get-ChildItem -Path $skillSrcPath -Recurse -Filter "*.tmpl.md" -File
            if ($tmplFiles.Count -gt 0) {
                $hasTemplates = $true
            }
        }

        if ($hasTemplates) {
            # Skill has templates - render to cache, then symlink/copy from cache
            $skillCache = Join-Path $toolCache $skillName
            New-Item -ItemType Directory -Path $skillCache -Force | Out-Null

            # Process all files in the skill directory
            $files = Get-ChildItem -Path $skillSrcPath -Recurse -File |
                Where-Object { $_.Name -notin @(".DS_Store", "Thumbs.db") }

            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($skillSrcPath.Length + 1)
                $srcFile = $file.FullName

                # Determine destination filename (strip .tmpl if present)
                if ($relativePath -match "\.tmpl\.md$") {
                    $destRelPath = $relativePath -replace "\.tmpl\.md$", ".md"
                    $destFile = Join-Path $skillCache $destRelPath
                    # Render template
                    Render-Template -SrcFile $srcFile -DestFile $destFile
                } else {
                    # Non-template file - copy to cache as-is
                    $destFile = Join-Path $skillCache $relativePath
                    $destDir = Split-Path $destFile -Parent
                    if (-not (Test-Path $destDir)) {
                        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                    }
                    Copy-Item -Path $srcFile -Destination $destFile -Force
                }
            }

            # Now symlink/copy from cache to target
            if (-not (Test-Path $skillTarget)) {
                New-Item -ItemType Directory -Path $skillTarget -Force | Out-Null
            }

            $cacheFiles = Get-ChildItem -Path $skillCache -Recurse -File
            foreach ($file in $cacheFiles) {
                $relativePath = $file.FullName.Substring($skillCache.Length + 1)
                $cacheFile = $file.FullName
                $targetFile = Join-Path $skillTarget $relativePath
                $targetFileDir = Split-Path $targetFile -Parent

                if (-not (Test-Path $targetFileDir)) {
                    New-Item -ItemType Directory -Path $targetFileDir -Force | Out-Null
                }

                if (Test-Path $targetFile) {
                    Remove-Item $targetFile -Force
                }

                if ($InstallType -eq "symlink") {
                    New-Item -ItemType SymbolicLink -Path $targetFile -Target $cacheFile | Out-Null
                } else {
                    Copy-Item -Path $cacheFile -Destination $targetFile -Force
                }
            }
        } else {
            # No templates - symlink/copy directly from source
            if (-not (Test-Path $skillTarget)) {
                New-Item -ItemType Directory -Path $skillTarget -Force | Out-Null
            }

            $files = Get-ChildItem -Path $skillSrcPath -Recurse -File |
                Where-Object { $_.Name -notin @(".DS_Store", "Thumbs.db") }

            foreach ($file in $files) {
                $relativePath = $file.FullName.Substring($skillSrcPath.Length + 1)
                $srcFile = $file.FullName
                $targetFile = Join-Path $skillTarget $relativePath
                $targetFileDir = Split-Path $targetFile -Parent

                if (-not (Test-Path $targetFileDir)) {
                    New-Item -ItemType Directory -Path $targetFileDir -Force | Out-Null
                }

                if (Test-Path $targetFile) {
                    Remove-Item $targetFile -Force
                }

                if ($InstallType -eq "symlink") {
                    New-Item -ItemType SymbolicLink -Path $targetFile -Target $srcFile | Out-Null
                } else {
                    Copy-Item -Path $srcFile -Destination $targetFile -Force
                }
            }
        }
    }

    Write-Success "Skills installed for $Label at: $TargetDir"
    return $true
}

function Install-Symlinks {
    param(
        [string]$TargetRoot,
        [string]$PayloadDir,
        [string]$Label
    )

    if (-not (Test-Path $PayloadDir)) {
        Write-Warn "Payload directory '$PayloadDir' not found, skipping $Label"
        return $false
    }

    Write-Info "Installing $Label to: $TargetRoot"

    $files = Get-ChildItem -Path $PayloadDir -Recurse -File |
        Where-Object { $_.Name -notin @(".DS_Store", "Thumbs.db") } |
        ForEach-Object { $_.FullName.Substring($PayloadDir.Length + 1) }

    $conflicts = @()
    foreach ($file in $files) {
        $dest = Join-Path $TargetRoot $file
        if (Test-Path $dest) {
            if ((Get-Item $dest -ErrorAction SilentlyContinue).LinkType) {
                $existingTarget = (Get-Item $dest).Target
                $src = Join-Path $PayloadDir $file
                if ($existingTarget -eq $src) { continue }
            }
            $conflicts += $file
        }
    }

    if ($conflicts.Count -gt 0) {
        Write-Host ""
        Write-Warn "Found $($conflicts.Count) conflicting file(s)/symlink(s) for $Label:"
        Write-Host ""
        $conflicts | Select-Object -First 20 | ForEach-Object { Write-Host $_ }
        if ($conflicts.Count -gt 20) {
            Write-Host "  ... and $($conflicts.Count - 20) more"
        }
        Write-Host ""
        Write-Warn "These will be replaced with symlinks to the repo."
        Write-Host ""
        if (-not (Confirm-YesNo "Replace ALL conflicting files with symlinks for $Label?")) {
            Write-Warn "Skipping $Label install"
            return $false
        }
        Write-Host ""
    }

    Write-Info "Creating symlinks for $Label..."

    foreach ($file in $files) {
        $src = Join-Path $PayloadDir $file
        $dest = Join-Path $TargetRoot $file
        $destDir = Split-Path $dest -Parent

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        if (Test-Path $dest) {
            Remove-Item $dest -Force
        }

        New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
    }

    Write-Success "Symlinks created for $Label at: $TargetRoot"
    return $true
}

function Install-Copies {
    param(
        [string]$TargetRoot,
        [string]$PayloadDir,
        [string]$Label
    )

    if (-not (Test-Path $PayloadDir)) {
        Write-Warn "Payload directory '$PayloadDir' not found, skipping $Label"
        return $false
    }

    Write-Info "Installing $Label to: $TargetRoot"

    $files = Get-ChildItem -Path $PayloadDir -Recurse -File |
        Where-Object { $_.Name -notin @(".DS_Store", "Thumbs.db") } |
        ForEach-Object { $_.FullName.Substring($PayloadDir.Length + 1) }

    $conflicts = @()
    foreach ($file in $files) {
        $dest = Join-Path $TargetRoot $file
        if (Test-Path $dest) {
            $conflicts += $file
        }
    }

    if ($conflicts.Count -gt 0) {
        Write-Host ""
        Write-Warn "Found $($conflicts.Count) existing file(s) that will be overwritten:"
        Write-Host ""
        $conflicts | Select-Object -First 20 | ForEach-Object { Write-Host $_ }
        if ($conflicts.Count -gt 20) {
            Write-Host "  ... and $($conflicts.Count - 20) more"
        }
        Write-Host ""
        if (-not (Confirm-YesNo "Overwrite ALL conflicting files for $Label?")) {
            Write-Warn "Skipping $Label install"
            return $false
        }
        Write-Host ""
    }

    Write-Info "Copying files for $Label..."

    foreach ($file in $files) {
        $src = Join-Path $PayloadDir $file
        $dest = Join-Path $TargetRoot $file
        $destDir = Split-Path $dest -Parent

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        if (Test-Path $dest) {
            Remove-Item $dest -Force
        }

        Copy-Item -Path $src -Destination $dest -Force
    }

    Write-Success "Files copied for $Label at: $TargetRoot"
    return $true
}

function Main {
    Write-Host ""
    Write-Host "  Agent Extensions Install"
    Write-Host "  ========================"
    Write-Host ""

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    Write-Info "Source directory: $scriptDir"
    Write-Host ""

    Write-Host "Which tool(s) would you like to install extensions for?"
    Write-Host "  1) OpenCode"
    Write-Host "  2) Augment (Auggie)"
    Write-Host "  3) Codex"
    Write-Host "  4) OpenCode + Augment"
    Write-Host "  5) OpenCode + Codex"
    Write-Host "  6) Augment + Codex"
    Write-Host "  7) All (OpenCode + Augment + Codex)"
    Write-Host ""
    $toolChoice = Read-Host "Enter choice [1/2/3/4/5/6/7]"

    $InstallOpenCode = $false
    $InstallAugment = $false
    $InstallCodex = $false

    switch ($toolChoice) {
        "1" { $InstallOpenCode = $true }
        "2" { $InstallAugment = $true }
        "3" { $InstallCodex = $true }
        "4" { $InstallOpenCode = $true; $InstallAugment = $true }
        "5" { $InstallOpenCode = $true; $InstallCodex = $true }
        "6" { $InstallAugment = $true; $InstallCodex = $true }
        "7" { $InstallOpenCode = $true; $InstallAugment = $true; $InstallCodex = $true }
        default { Write-Err "Invalid choice. Please enter 1, 2, 3, 4, 5, 6, or 7." }
    }

    Write-Host ""
    Write-Host "Where would you like to install?"
    Write-Host "  1) Global (user config directory)"
    Write-Host "  2) Local (current repo)"
    Write-Host "  3) Both global and local"
    Write-Host ""
    $scopeChoice = Read-Host "Enter choice [1/2/3]"

    $InstallGlobal = $false
    $InstallLocal = $false

    switch ($scopeChoice) {
        "1" { $InstallGlobal = $true }
        "2" { $InstallLocal = $true }
        "3" { $InstallGlobal = $true; $InstallLocal = $true }
        default { Write-Err "Invalid choice. Please enter 1, 2, or 3." }
    }

    if ($InstallLocal) {
        $gitRoot = Find-GitRoot
        if (-not $gitRoot) { Write-Err "Not inside a git repository. Cannot determine repo root for local install." }
    }

    Write-Host ""

    $installedCount = 0

    if ($InstallOpenCode -and $InstallGlobal) {
        $opencodePayload = Join-Path $scriptDir "opencode"
        $opencodeTarget = Join-Path $HOME ".config\opencode"
        if (Install-Symlinks -TargetRoot $opencodeTarget -PayloadDir $opencodePayload -Label "OpenCode (global)") {
            $installedCount++
        }

        $opencodeSkillsSrc = Join-Path $scriptDir "skills"
        $opencodeSkillsTarget = Join-Path $opencodeTarget "skill"
        $opencodeCache = Join-Path $scriptDir ".cache\skills-rendered"
        if (Install-Skills -TargetDir $opencodeSkillsTarget -SkillsSrc $opencodeSkillsSrc -CacheDir $opencodeCache -Tool "opencode" -Mode "global" -Label "OpenCode skills (global)" -InstallType "symlink") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($InstallOpenCode -and $InstallLocal) {
        $opencodePayload = Join-Path $scriptDir "opencode"
        $opencodeTarget = Join-Path $gitRoot ".opencode"
        if (Install-Copies -TargetRoot $opencodeTarget -PayloadDir $opencodePayload -Label "OpenCode (local)") {
            $installedCount++
        }

        $opencodeSkillsSrc = Join-Path $scriptDir "skills"
        $opencodeSkillsTarget = Join-Path $opencodeTarget "skill"
        $opencodeCache = Join-Path $scriptDir ".cache\skills-rendered"
        if (Install-Skills -TargetDir $opencodeSkillsTarget -SkillsSrc $opencodeSkillsSrc -CacheDir $opencodeCache -Tool "opencode" -Mode "local" -Label "OpenCode skills (local)" -InstallType "copy") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($InstallAugment -and $InstallGlobal) {
        $augmentPayload = Join-Path $scriptDir "augment"
        $augmentTarget = Join-Path $HOME ".augment"
        if (Install-Symlinks -TargetRoot $augmentTarget -PayloadDir $augmentPayload -Label "Augment (global)") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($InstallAugment -and $InstallLocal) {
        $augmentPayload = Join-Path $scriptDir "augment"
        $augmentTarget = Join-Path $gitRoot ".augment"
        if (Install-Copies -TargetRoot $augmentTarget -PayloadDir $augmentPayload -Label "Augment (local)") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($InstallCodex -and $InstallGlobal) {
        $codexPayload = Join-Path $scriptDir "codex"
        $codexTarget = Join-Path $HOME ".codex"
        if (Install-Symlinks -TargetRoot $codexTarget -PayloadDir $codexPayload -Label "Codex (global)") {
            $installedCount++
        }

        $codexSkillsSrc = Join-Path $scriptDir "skills"
        $codexSkillsTarget = Join-Path $codexTarget "skills"
        $codexCache = Join-Path $scriptDir ".cache\skills-rendered"
        if (Install-Skills -TargetDir $codexSkillsTarget -SkillsSrc $codexSkillsSrc -CacheDir $codexCache -Tool "codex" -Mode "global" -Label "Codex skills (global)" -InstallType "symlink") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($InstallCodex -and $InstallLocal) {
        $codexPayload = Join-Path $scriptDir "codex"
        $codexTarget = Join-Path $gitRoot ".codex"
        if (Install-Copies -TargetRoot $codexTarget -PayloadDir $codexPayload -Label "Codex (local)") {
            $installedCount++
        }

        $codexSkillsSrc = Join-Path $scriptDir "skills"
        $codexSkillsTarget = Join-Path $codexTarget "skills"
        $codexCache = Join-Path $scriptDir ".cache\skills-rendered"
        if (Install-Skills -TargetDir $codexSkillsTarget -SkillsSrc $codexSkillsSrc -CacheDir $codexCache -Tool "codex" -Mode "local" -Label "Codex skills (local)" -InstallType "copy") {
            $installedCount++
        }
        Write-Host ""
    }

    if ($installedCount -eq 0) { Write-Err "No installations completed" }

    Write-Success "Install complete!"
    Write-Host ""
    Write-Info "Source files at: $scriptDir"
    Write-Host ""
    Write-Host "Global installs use symlinks to the repo."
    Write-Host "Local installs copy files into the repo."
    Write-Host ""
}

Main
