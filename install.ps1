# install.ps1 — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code + OpenAI Codex
# Usage:
#   .\install.ps1
#   .\install.ps1 -OnlyCodex -Force -Backup
#   .\install.ps1 -DryRun
#   .\install.ps1 -TargetRoot .\tmp\host-home -OnlyCodex -Force
#   .\install.ps1 -Check

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
    [switch]$OnlyCodex
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

$InstallAntigravity = -not ($OnlyClaude -or $OnlyCodex)
$InstallClaude = -not ($OnlyAntigravity -or $OnlyCodex)
$InstallCodex = -not ($OnlyAntigravity -or $OnlyClaude)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = if ([string]::IsNullOrWhiteSpace($TargetRoot)) {
    $env:USERPROFILE
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
