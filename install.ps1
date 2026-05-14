# install.ps1 — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code
# Usage:
#   .\install.ps1                  # install both
#   .\install.ps1 -OnlyAntigravity
#   .\install.ps1 -OnlyClaude
#   .\install.ps1 -Force           # overwrite existing configs

param(
    [switch]$Force,
    [switch]$OnlyAntigravity,
    [switch]$OnlyClaude
)

$ErrorActionPreference = "Stop"

# ── Flags ─────────────────────────────────────────────────────────────────────
$InstallAntigravity = -not $OnlyClaude
$InstallClaude      = -not $OnlyAntigravity

# ── Paths ─────────────────────────────────────────────────────────────────────
$ScriptDir         = Split-Path -Parent $MyInvocation.MyCommand.Path
$GeminiHome        = "$env:USERPROFILE\.gemini"
$GeminiSkillsDir   = "$GeminiHome\antigravity\skills"
$GeminiWorkflowDir = "$GeminiHome\antigravity\workflows"
$GeminiAgentsDir   = "$GeminiHome\antigravity\agents"
$ClaudeHome        = "$env:USERPROFILE\.claude"
$ClaudeSkillsDir   = "$ClaudeHome\skills"
$ClaudeAgentsDir   = "$ClaudeHome\agents"

# ── Helpers ───────────────────────────────────────────────────────────────────
function Write-Header([string]$Text) {
    Write-Host ""
    Write-Host "  $Text" -ForegroundColor Yellow
    Write-Host "  $('─' * 60)" -ForegroundColor DarkGray
}
function Write-Ok([string]$Text)   { Write-Host "  ✓ $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "  ⚠ $Text" -ForegroundColor Yellow }
function Write-Skip([string]$Text) { Write-Host "  → $Text" -ForegroundColor DarkGray }

# ── Banner ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║          FULL STACK HQ — INSTALLATION                        ║" -ForegroundColor Cyan
Write-Host "  ║          Google Antigravity + Claude Code                    ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ── Pre-flight ────────────────────────────────────────────────────────────────
Write-Header "Pre-flight Checks"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  ✗ Git not found. Install git first." -ForegroundColor Red; exit 1
}
Write-Ok "git found"

if (Get-Command antigravity -ErrorAction SilentlyContinue) { Write-Ok "Antigravity detected" }
else { Write-Warn "Antigravity not detected — installing files anyway" }

if (Get-Command claude -ErrorAction SilentlyContinue) { Write-Ok "Claude Code detected" }
else { Write-Warn "Claude Code not detected — installing files anyway" }

# ──────────────────────────────────────────────────────────────────────────────
# ANTIGRAVITY
# ──────────────────────────────────────────────────────────────────────────────
if ($InstallAntigravity) {
    Write-Header "Installing for Google Antigravity IDE  (target: ~/.gemini/)"

    $SkipGemini = $false
    if ((Test-Path "$GeminiHome\GEMINI.md") -and (-not $Force)) {
        Write-Warn "GEMINI.md already exists"
        $resp = Read-Host "  Overwrite? (y/N)"
        if ($resp -ne "y" -and $resp -ne "Y") { $SkipGemini = $true }
    }

    New-Item -ItemType Directory -Force -Path $GeminiHome,$GeminiSkillsDir,$GeminiWorkflowDir,$GeminiAgentsDir | Out-Null

    if (-not $SkipGemini) {
        Copy-Item "$ScriptDir\gemini\GEMINI.md" "$GeminiHome\GEMINI.md" -Force
        Write-Ok "GEMINI.md"
    } else {
        Write-Skip "GEMINI.md (kept existing)"
    }

    $agentCount = 0
    Get-ChildItem "$ScriptDir\agents" -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName "$GeminiAgentsDir\" -Force; $agentCount++
    }
    Write-Ok "Agents: $agentCount files"

    $skillCount = 0
    Get-ChildItem "$ScriptDir\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName "$GeminiSkillsDir\" -Recurse -Force; $skillCount++
    }
    Write-Ok "Skills: $skillCount modules"

    $wfCount = 0
    Get-ChildItem "$ScriptDir\workflows" -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName "$GeminiWorkflowDir\" -Force; $wfCount++
    }
    Write-Ok "Workflows: $wfCount files"
}

# ──────────────────────────────────────────────────────────────────────────────
# CLAUDE CODE
# ──────────────────────────────────────────────────────────────────────────────
if ($InstallClaude) {
    Write-Header "Installing for Claude Code  (target: ~/.claude/)"

    New-Item -ItemType Directory -Force -Path $ClaudeHome,$ClaudeAgentsDir,$ClaudeSkillsDir | Out-Null

    if ((Test-Path "$ClaudeHome\CLAUDE.md") -and (-not $Force)) {
        Write-Warn "CLAUDE.md already exists"
        $resp = Read-Host "  Overwrite? (y/N)"
        if ($resp -eq "y" -or $resp -eq "Y") {
            Copy-Item "$ScriptDir\claude\CLAUDE.md" "$ClaudeHome\CLAUDE.md" -Force
            Write-Ok "CLAUDE.md (overwritten)"
        } else {
            Write-Skip "CLAUDE.md (kept existing)"
        }
    } else {
        Copy-Item "$ScriptDir\claude\CLAUDE.md" "$ClaudeHome\CLAUDE.md" -Force
        Write-Ok "CLAUDE.md"
    }

    $agentCount = 0
    Get-ChildItem "$ScriptDir\agents" -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName "$ClaudeAgentsDir\" -Force; $agentCount++
    }
    Write-Ok "Agents: $agentCount files"

    $skillCount = 0
    Get-ChildItem "$ScriptDir\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName "$ClaudeSkillsDir\" -Recurse -Force; $skillCount++
    }
    Write-Ok "Skills: $skillCount modules"
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                   INSTALLATION COMPLETE!                    ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

if ($InstallAntigravity) {
    Write-Host "  Antigravity:" -ForegroundColor Cyan
    Write-Host "    GEMINI.md  → $GeminiHome\GEMINI.md"
    Write-Host "    Agents     → $GeminiAgentsDir\"
    Write-Host "    Skills     → $GeminiSkillsDir\"
    Write-Host "    Workflows  → $GeminiWorkflowDir\"
    Write-Host ""
}

if ($InstallClaude) {
    Write-Host "  Claude Code:" -ForegroundColor Cyan
    Write-Host "    CLAUDE.md  → $ClaudeHome\CLAUDE.md"
    Write-Host "    Agents     → $ClaudeAgentsDir\"
    Write-Host "    Skills     → $ClaudeSkillsDir\"
    Write-Host ""
}

Write-Host "  Next steps:" -ForegroundColor Yellow
if ($InstallAntigravity) { Write-Host "    1. Restart Antigravity IDE" }
if ($InstallClaude)      { Write-Host "    2. Restart Claude Code" }
Write-Host "    3. Test: 'Create a React component called UserCard'"
Write-Host "    4. Agent should ask for approval before creating"
Write-Host ""
