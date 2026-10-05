# install.ps1 — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code + OpenAI Codex
# Usage:
#   .\install.ps1
#   .\install.ps1 -OnlyCodex -Force -Backup
#   .\install.ps1 -DryRun
#   .\install.ps1 -TargetRoot .\tmp\host-home -OnlyCodex -Force
#   .\install.ps1 -Check
#   .\install.ps1 -Project ..\my-repo
#   .\install.ps1 -Project ..\my-repo -Uninstall

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Backup,
    [switch]$DryRun,
    [switch]$Check,
    [switch]$NoLegacyPaths,
    [string]$TargetRoot,
    [switch]$OnlyAntigravity,
    [switch]$OnlyClaude,
    [switch]$OnlyCodex,
    [string]$Project,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

$OnlyFlags = @(
    $OnlyAntigravity,
    $OnlyClaude,
    $OnlyCodex
) | Where-Object { $_ }
if ($OnlyFlags.Count -gt 1) {
    throw "Choose at most one of -OnlyAntigravity, -OnlyClaude, or -OnlyCodex."
}

if ($Uninstall -and [string]::IsNullOrWhiteSpace($Project)) {
    throw "-Uninstall works with -Project. For the Claude Code plugin run: claude plugin uninstall full-stack-hq@full-stack-hq. Global installs are removed manually; see docs/SETUP.md#uninstallation."
}
$ProjectDir = $null
if (-not [string]::IsNullOrWhiteSpace($Project)) {
    if (-not [string]::IsNullOrWhiteSpace($TargetRoot)) { throw "Choose either -Project or -TargetRoot." }
    if (-not (Test-Path -LiteralPath $Project -PathType Container)) { throw "Project directory not found: $Project" }
    $ProjectDir = (Resolve-Path -LiteralPath $Project).Path
}

$InstallAntigravity = -not ($OnlyClaude -or $OnlyCodex)
$InstallClaude = -not ($OnlyAntigravity -or $OnlyCodex)
$InstallCodex = -not ($OnlyAntigravity -or $OnlyClaude)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = if ([string]::IsNullOrWhiteSpace($TargetRoot)) {
    if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) { $HOME } else { $env:USERPROFILE }
} else {
    [System.IO.Path]::GetFullPath($TargetRoot)
}
$CodexHomeEnv = $env:CODEX_HOME
$CodexHome = if (-not [string]::IsNullOrWhiteSpace($TargetRoot)) {
    Join-Path $UserHome ".codex"
} elseif ([string]::IsNullOrWhiteSpace($CodexHomeEnv)) {
    Join-Path $UserHome ".codex"
} else {
    $CodexHomeEnv
}

$GeminiHome = Join-Path $UserHome ".gemini"
$GeminiConfigHome = Join-Path $GeminiHome "config"
$GeminiOfficialAgentsDir = Join-Path $GeminiConfigHome "agents"
$GeminiOfficialSkillsDir = Join-Path $GeminiConfigHome "skills"
$GeminiOfficialWorkflowsDir = Join-Path $GeminiConfigHome "workflows"
$GeminiLegacyHome = Join-Path $GeminiHome "antigravity"
$ClaudeHome = Join-Path $UserHome ".claude"
$ClaudeAgentsDir = Join-Path $ClaudeHome "agents"
$ClaudeSkillsDir = Join-Path $ClaudeHome "skills"
$CodexAgentsDir = Join-Path $CodexHome "agents"
$CodexSkillsDir = Join-Path $UserHome ".agents\skills"

function Write-Header([string]$Text) {
    Write-Host ""
    Write-Host "  $Text" -ForegroundColor Yellow
    Write-Host "  $('─' * 64)" -ForegroundColor DarkGray
}
function Write-Ok([string]$Text) { Write-Host "  ✓ $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "  ⚠ $Text" -ForegroundColor Yellow }
function Write-Skip([string]$Text) { Write-Host "  → $Text" -ForegroundColor DarkGray }
function Write-Plan([string]$Text) { Write-Host "  • $Text" -ForegroundColor Cyan }

function Get-BackupPath([string]$Path) {
    $Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $Candidate = "$Path.full-stack-hq-backup-$Stamp"
    $Index = 1
    while (Test-Path -LiteralPath $Candidate) {
        $Candidate = "$Path.full-stack-hq-backup-$Stamp-$Index"
        $Index++
    }
    return $Candidate
}

function Copy-ManagedFile([string]$Source, [string]$Destination, [string]$Label, [switch]$Prompt) {
    $Exists = Test-Path -LiteralPath $Destination
    if ($Exists -and (Get-Item -LiteralPath $Destination).PSIsContainer) {
        throw "Destination is a directory; refusing to replace it with a file: $Destination"
    }

    if ($DryRun) {
        $Action = if ($Exists) { "replace" } else { "create" }
        Write-Plan "$Action $Destination"
        return $true
    }

    if ($Exists -and -not $Force) {
        if ($Prompt) {
            Write-Warn "$Label already exists"
            $Response = Read-Host "  Replace? (y/N)"
            if ($Response -notin @("y", "Y")) {
                Write-Skip "$Label (kept existing)"
                return $false
            }
        } else {
            Write-Skip "$Label (kept existing; use -Force to replace)"
            return $false
        }
    }

    $Parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $Parent | Out-Null
    if ($Exists -and $Backup) {
        $BackupPath = Get-BackupPath $Destination
        Copy-Item -LiteralPath $Destination -Destination $BackupPath -Force
        Write-Ok "$Label backup → $BackupPath"
    }
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Ok $Label
    return $true
}

function Copy-ManagedTree([string]$SourceRoot, [string]$DestinationRoot, [string]$Label) {
    if (-not (Test-Path -LiteralPath $SourceRoot)) { return 0 }
    $Count = 0
    $SourcePrefix = $SourceRoot.TrimEnd('\', '/')
    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
        $Relative = $_.FullName.Substring($SourcePrefix.Length).TrimStart('\', '/')
        $Destination = Join-Path $DestinationRoot $Relative
        if (Copy-ManagedFile $_.FullName $Destination "$Label/$Relative") { [void]($Count++) }
    }
    return $Count
}

# Project mode owns only the lines between these markers, so content the
# repository already has in AGENTS.md, CLAUDE.md, or GEMINI.md is preserved.
$BlockStart = "<!-- full-stack-hq:start -->"
$BlockEnd = "<!-- full-stack-hq:end -->"

function Read-TextLines([string]$Path) {
    $Text = [System.IO.File]::ReadAllText($Path)
    $NewLine = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $Lines = [System.Collections.Generic.List[string]]::new()
    if ($Text.Length -gt 0) {
        $Parts = [regex]::Split($Text, "\r?\n")
        if ($Text.EndsWith("`n")) { $Parts = $Parts[0..($Parts.Length - 2)] }
        foreach ($Part in $Parts) { $Lines.Add($Part) }
    }
    return [pscustomobject]@{ Lines = $Lines; NewLine = $NewLine }
}

function Get-BlockRange($Lines) {
    $Starts = @(); $Ends = @()
    for ($Index = 0; $Index -lt $Lines.Count; $Index++) {
        if ($Lines[$Index] -ceq $BlockStart) { $Starts += $Index }
        if ($Lines[$Index] -ceq $BlockEnd) { $Ends += $Index }
    }
    if ($Starts.Count -eq 0 -and $Ends.Count -eq 0) { return [pscustomobject]@{ Kind = "none" } }
    if ($Starts.Count -eq 1 -and $Ends.Count -eq 1 -and $Starts[0] -lt $Ends[0]) {
        return [pscustomobject]@{ Kind = "ok"; Start = $Starts[0]; End = $Ends[0] }
    }
    return [pscustomobject]@{ Kind = "broken" }
}

function Save-ProjectFile([string]$Path, $Lines, [string]$NewLine, [string]$Label) {
    $Text = ($Lines -join $NewLine) + $NewLine
    if ((Test-Path -LiteralPath $Path) -and ([System.IO.File]::ReadAllText($Path) -ceq $Text)) {
        Write-Skip "$Label (already up to date)"
        return
    }
    if ((Test-Path -LiteralPath $Path) -and $Backup) {
        $BackupPath = Get-BackupPath $Path
        Copy-Item -LiteralPath $Path -Destination $BackupPath -Force
        Write-Ok "$Label backup → $BackupPath"
    }
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
    Write-Ok $Label
}

function Write-ProjectBlock([string]$Path, [string[]]$BodyLines, [string]$Label) {
    $Exists = Test-Path -LiteralPath $Path
    $Document = if ($Exists) { Read-TextLines $Path } else { [pscustomobject]@{ Lines = [System.Collections.Generic.List[string]]::new(); NewLine = "`n" } }
    $Range = Get-BlockRange $Document.Lines
    if ($Range.Kind -eq "broken") { throw "Malformed Full Stack HQ markers in $Path; fix or remove them and run again." }
    if ($DryRun) {
        if (-not $Exists) { Write-Plan "create $Path" }
        elseif ($Range.Kind -eq "ok") { Write-Plan "update the Full Stack HQ block in $Path" }
        else { Write-Plan "append a Full Stack HQ block to $Path" }
        return
    }
    $Block = @($BlockStart) + $BodyLines + @($BlockEnd)
    $Result = [System.Collections.Generic.List[string]]::new()
    if ($Range.Kind -eq "ok") {
        for ($Index = 0; $Index -lt $Range.Start; $Index++) { $Result.Add($Document.Lines[$Index]) }
        foreach ($Line in $Block) { $Result.Add($Line) }
        for ($Index = $Range.End + 1; $Index -lt $Document.Lines.Count; $Index++) { $Result.Add($Document.Lines[$Index]) }
    } else {
        foreach ($Line in $Document.Lines) { $Result.Add($Line) }
        if ($Document.Lines.Count -gt 0) { $Result.Add("") }
        foreach ($Line in $Block) { $Result.Add($Line) }
    }
    Save-ProjectFile $Path $Result $Document.NewLine $Label
}

function Remove-ProjectBlock([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) { Write-Skip "$Label (no Full Stack HQ block)"; return }
    $Document = Read-TextLines $Path
    $Range = Get-BlockRange $Document.Lines
    if ($Range.Kind -eq "none") { Write-Skip "$Label (no Full Stack HQ block)"; return }
    if ($Range.Kind -eq "broken") { throw "Malformed Full Stack HQ markers in $Path; fix or remove them and run again." }
    # Drop the block and the blank separator line written in front of it.
    $Result = [System.Collections.Generic.List[string]]::new()
    for ($Index = 0; $Index -lt $Range.Start; $Index++) { $Result.Add($Document.Lines[$Index]) }
    if ($Result.Count -gt 0 -and $Result[$Result.Count - 1] -eq "") { $Result.RemoveAt($Result.Count - 1) }
    for ($Index = $Range.End + 1; $Index -lt $Document.Lines.Count; $Index++) { $Result.Add($Document.Lines[$Index]) }
    $HasContent = ($Result | Where-Object { $_.Trim().Length -gt 0 }).Count -gt 0
    if ($DryRun) {
        if ($HasContent) { Write-Plan "remove the Full Stack HQ block from $Path" }
        else { Write-Plan "delete $Path (it only holds the Full Stack HQ block)" }
        return
    }
    if ($HasContent) {
        Save-ProjectFile $Path $Result $Document.NewLine $Label
        return
    }
    if ($Backup) {
        $BackupPath = Get-BackupPath $Path
        Copy-Item -LiteralPath $Path -Destination $BackupPath -Force
        Write-Ok "$Label backup → $BackupPath"
    }
    Remove-Item -LiteralPath $Path -Force
    Write-Ok "$Label removed (it only held the Full Stack HQ block)"
}

Write-Host ""
Write-Host "  ╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║             FULL STACK HQ — INSTALLATION                      ║" -ForegroundColor Cyan
Write-Host "  ║       Antigravity IDE + Claude Code + OpenAI Codex            ║" -ForegroundColor Cyan
Write-Host "  ╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Header "Pre-flight checks"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git not found. Run this installer from a local checkout."
}
Write-Ok "Git found"
if ($Check) {
    & (Join-Path $ScriptDir "scripts\validate.ps1")
    exit $LASTEXITCODE
}

if ($InstallAntigravity) {
    if (Get-Command antigravity -ErrorAction SilentlyContinue) { Write-Ok "Antigravity detected" }
    else { Write-Warn "Antigravity command not detected — installing files anyway" }
}
if ($InstallClaude) {
    if (Get-Command claude -ErrorAction SilentlyContinue) { Write-Ok "Claude Code detected" }
    else { Write-Warn "Claude Code command not detected — installing files anyway" }
}
if ($InstallCodex) {
    if (Get-Command codex -ErrorAction SilentlyContinue) { Write-Ok "Codex detected" }
    else { Write-Warn "Codex command not detected — installing files anyway" }
    $CodexOverridePath = Join-Path $CodexHome "AGENTS.override.md"
    if (Test-Path -LiteralPath $CodexOverridePath) {
        Write-Warn "AGENTS.override.md exists — Codex will prioritize it over AGENTS.md"
    }
}
if ($DryRun) { Write-Warn "Dry-run mode: no target files will be changed" }
if ($Backup) { Write-Ok "Backups enabled for replaced files" }
if (-not [string]::IsNullOrWhiteSpace($TargetRoot)) { Write-Ok "Target root: $UserHome" }

$BuildDir = Join-Path ([System.IO.Path]::GetTempPath()) ("full-stack-hq-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
try {
    & (Join-Path $ScriptDir "scripts\build-adapters.ps1") -OutputDir $BuildDir | Out-Host

    if ($ProjectDir) {
        if ($Uninstall) {
            Write-Header "Remove Full Stack HQ from $ProjectDir"
            if ($InstallClaude) { Remove-ProjectBlock (Join-Path $ProjectDir "CLAUDE.md") "CLAUDE.md" }
            if ($InstallAntigravity) { Remove-ProjectBlock (Join-Path $ProjectDir "GEMINI.md") "GEMINI.md" }
            Remove-ProjectBlock (Join-Path $ProjectDir "AGENTS.md") "AGENTS.md"
            Write-Host ""
            Write-Host "  Project uninstall complete." -ForegroundColor Green
            return
        }
        Write-Header "Project rules → $ProjectDir"
        $ProjectRules = (Read-TextLines (Join-Path $BuildDir "project\AGENTS.md")).Lines
        Write-ProjectBlock (Join-Path $ProjectDir "AGENTS.md") $ProjectRules "AGENTS.md (Codex, Cursor, GitHub Copilot)"
        if ($InstallClaude) { Write-ProjectBlock (Join-Path $ProjectDir "CLAUDE.md") @("@AGENTS.md") "CLAUDE.md (Claude Code, imports AGENTS.md)" }
        if ($InstallAntigravity) { Write-ProjectBlock (Join-Path $ProjectDir "GEMINI.md") @("@./AGENTS.md") "GEMINI.md (Gemini CLI, imports AGENTS.md)" }
        Write-Host ""
        Write-Host "  Project install complete." -ForegroundColor Green
        Write-Host "  Commit AGENTS.md, CLAUDE.md, and GEMINI.md so everyone on the project shares the rules."
        Write-Host "  Re-run the same command to update; add -Uninstall to remove the blocks."
        return
    }

    if ($InstallAntigravity) {
        Write-Header "Google Antigravity IDE"
        Copy-ManagedFile (Join-Path $BuildDir "antigravity\GEMINI.md") (Join-Path $GeminiHome "GEMINI.md") "GEMINI.md" -Prompt | Out-Null
        $AgentCount = Copy-ManagedTree (Join-Path $ScriptDir "agents") $GeminiOfficialAgentsDir "Antigravity agents"
        $SkillCount = Copy-ManagedTree (Join-Path $ScriptDir "skills") $GeminiOfficialSkillsDir "Antigravity skills"
        $WorkflowSkillCount = Copy-ManagedTree (Join-Path $BuildDir "workflow-skills") $GeminiOfficialSkillsDir "Antigravity workflow skills"
        $WorkflowCount = Copy-ManagedTree (Join-Path $ScriptDir "workflows") $GeminiOfficialWorkflowsDir "Antigravity legacy workflows"
        Write-Ok "Official paths: agents=$AgentCount, skills=$($SkillCount + $WorkflowSkillCount), workflows=$WorkflowCount"

        if (-not $NoLegacyPaths -and (Test-Path -LiteralPath $GeminiLegacyHome)) {
            Write-Header "Antigravity legacy compatibility bridge"
            $LegacyAgents = Copy-ManagedTree (Join-Path $ScriptDir "agents") (Join-Path $GeminiLegacyHome "agents") "Legacy Antigravity agents"
            $LegacySkills = Copy-ManagedTree (Join-Path $ScriptDir "skills") (Join-Path $GeminiLegacyHome "skills") "Legacy Antigravity skills"
            $LegacyWorkflows = Copy-ManagedTree (Join-Path $ScriptDir "workflows") (Join-Path $GeminiLegacyHome "workflows") "Legacy Antigravity workflows"
            Write-Ok "Legacy paths refreshed: agents=$LegacyAgents, skills=$LegacySkills, workflows=$LegacyWorkflows"
        } elseif (-not $NoLegacyPaths) {
            Write-Skip "Legacy Antigravity paths not present; official paths only"
        }
    }

    if ($InstallClaude) {
        Write-Header "Claude Code"
        Copy-ManagedFile (Join-Path $BuildDir "claude\CLAUDE.md") (Join-Path $ClaudeHome "CLAUDE.md") "CLAUDE.md" -Prompt | Out-Null
        $AgentCount = Copy-ManagedTree (Join-Path $ScriptDir "agents") $ClaudeAgentsDir "Claude agents"
        $SkillCount = Copy-ManagedTree (Join-Path $ScriptDir "skills") $ClaudeSkillsDir "Claude skills"
        $WorkflowSkillCount = Copy-ManagedTree (Join-Path $BuildDir "workflow-skills") $ClaudeSkillsDir "Claude workflow skills"
        Write-Ok "Installed: agents=$AgentCount, skills=$($SkillCount + $WorkflowSkillCount)"
    }

    if ($InstallCodex) {
        Write-Header "OpenAI Codex"
        Copy-ManagedFile (Join-Path $BuildDir "codex\AGENTS.md") (Join-Path $CodexHome "AGENTS.md") "AGENTS.md" -Prompt | Out-Null
        $AgentCount = Copy-ManagedTree (Join-Path $BuildDir "codex\agents") $CodexAgentsDir "Codex custom agents"
        $SkillCount = Copy-ManagedTree (Join-Path $ScriptDir "skills") $CodexSkillsDir "Codex skills"
        $WorkflowSkillCount = Copy-ManagedTree (Join-Path $BuildDir "workflow-skills") $CodexSkillsDir "Codex workflow skills"
        Write-Ok "Installed: agents=$AgentCount, skills=$($SkillCount + $WorkflowSkillCount)"
    }

    Write-Host ""
    Write-Host "  Installation complete." -ForegroundColor Green
    if ($InstallAntigravity) { Write-Host "  Antigravity rules → $(Join-Path $GeminiHome 'GEMINI.md')" }
    if ($InstallClaude) { Write-Host "  Claude rules       → $(Join-Path $ClaudeHome 'CLAUDE.md')" }
    if ($InstallCodex) { Write-Host "  Codex rules        → $(Join-Path $CodexHome 'AGENTS.md')" }
    Write-Host ""
    Write-Host "  Restart the host application and start a new conversation." -ForegroundColor Yellow
    Write-Host "  Use -DryRun to preview future changes; use -Backup with -Force for safe replacement."
}
finally {
    if (Test-Path -LiteralPath $BuildDir) {
        Remove-Item -LiteralPath $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
