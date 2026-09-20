[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$TargetRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("full-stack-hq-smoke-" + [guid]::NewGuid().ToString("N"))

function Assert-Path([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label is missing: $Path"
    }
    Write-Host "  [OK]   $Label" -ForegroundColor Green
}

function Assert-Count([string]$Path, [string]$Pattern, [int]$Expected, [string]$Label) {
    $Actual = @(Get-ChildItem -LiteralPath $Path -Filter $Pattern -File -Recurse -ErrorAction Stop).Count
    if ($Actual -ne $Expected) {
        throw "$Label expected $Expected but found $Actual in $Path"
    }
    Write-Host "  [OK]   $Label ($Actual)" -ForegroundColor Green
}

try {
    New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    Write-Host ""
    Write-Host "  FULL STACK HQ — WINDOWS INSTALL SMOKE TEST" -ForegroundColor Cyan
    Write-Host "  Isolated target: $TargetRoot" -ForegroundColor DarkGray
    Write-Host ""

    $global:LASTEXITCODE = 0
    & (Join-Path $RepoRoot "install.ps1") -TargetRoot $TargetRoot -Force
    if ($LASTEXITCODE -ne 0) { throw "Installer exited with code $LASTEXITCODE" }

    Assert-Path (Join-Path $TargetRoot ".gemini\GEMINI.md") "Antigravity global rules"
    Assert-Path (Join-Path $TargetRoot ".claude\CLAUDE.md") "Claude global rules"
    Assert-Path (Join-Path $TargetRoot ".codex\AGENTS.md") "Codex global rules"
    Assert-Path (Join-Path $TargetRoot ".gemini\config\workflows") "Antigravity workflows"
    Assert-Path (Join-Path $TargetRoot ".agents\skills") "Shared user skills"

    $ExpectedAgents = @(Get-ChildItem (Join-Path $RepoRoot "agents") -Filter "*.md" -File).Count
    $ExpectedSkills = @(Get-ChildItem (Join-Path $RepoRoot "skills") -Directory).Count
    $ExpectedWorkflows = @(Get-ChildItem (Join-Path $RepoRoot "workflows") -Filter "*.md" -File).Count
    $ExpectedSkillAdapters = $ExpectedSkills + $ExpectedWorkflows

    Assert-Count (Join-Path $TargetRoot ".gemini\config\agents") "*.md" $ExpectedAgents "Antigravity agents"
    Assert-Count (Join-Path $TargetRoot ".gemini\config\skills") "SKILL.md" $ExpectedSkillAdapters "Antigravity skills"
    Assert-Count (Join-Path $TargetRoot ".gemini\config\workflows") "*.md" $ExpectedWorkflows "Antigravity legacy workflows"
    Assert-Count (Join-Path $TargetRoot ".claude\agents") "*.md" $ExpectedAgents "Claude agents"
    Assert-Count (Join-Path $TargetRoot ".claude\skills") "SKILL.md" $ExpectedSkillAdapters "Claude skills"
    Assert-Count (Join-Path $TargetRoot ".codex\agents") "*.toml" $ExpectedAgents "Codex custom agents"
    Assert-Count (Join-Path $TargetRoot ".agents\skills") "SKILL.md" $ExpectedSkillAdapters "Codex skills"

    Write-Host ""
    Write-Host "  Smoke test passed." -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $TargetRoot) {
        Remove-Item -LiteralPath $TargetRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
