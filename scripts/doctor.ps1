[CmdletBinding()]
param(
    [switch]$OnlyAntigravity,
    [switch]$OnlyClaude,
    [switch]$OnlyCodex,
    [string]$TargetRoot,
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$FailureCount = 0
$WarningCount = 0

$OnlyFlags = @($OnlyAntigravity, $OnlyClaude, $OnlyCodex) | Where-Object { $_ }
if ($OnlyFlags.Count -gt 1) {
    throw "Choose at most one of -OnlyAntigravity, -OnlyClaude, or -OnlyCodex."
}

$SelectedHosts = if ($OnlyAntigravity) {
    @("antigravity")
} elseif ($OnlyClaude) {
    @("claude")
} elseif ($OnlyCodex) {
    @("codex")
} else {
    @("antigravity", "claude", "codex")
}

$UserHome = if ([string]::IsNullOrWhiteSpace($TargetRoot)) {
    if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) { $HOME } else { $env:USERPROFILE }
} else {
    [System.IO.Path]::GetFullPath($TargetRoot)
}
$CodexHome = if ([string]::IsNullOrWhiteSpace($TargetRoot) -and -not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
    $env:CODEX_HOME
} else {
    Join-Path $UserHome ".codex"
}

function Write-Ok([string]$Text) {
    Write-Host "  [OK]   $Text" -ForegroundColor Green
}

function Write-WarnStatus([string]$Text) {
    $script:WarningCount++
    Write-Host "  [WARN] $Text" -ForegroundColor Yellow
}

function Write-Fail([string]$Text) {
    $script:FailureCount++
    Write-Host "  [FAIL] $Text" -ForegroundColor Red
}

function Check-RequiredPath([string]$Path, [string]$Label) {
    if (Test-Path -LiteralPath $Path) {
        Write-Ok $Label
    } else {
        Write-Fail "$Label — missing: $Path"
    }
}

function Check-InstalledPath([string]$Path, [string]$Label) {
    if (Test-Path -LiteralPath $Path) {
        Write-Ok $Label
    } else {
        Write-WarnStatus "$Label — not installed at: $Path"
    }
}

function Check-Command([string]$Name) {
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Ok "$Name command detected"
    } else {
        Write-WarnStatus "$Name command not detected; files can still be prepared"
    }
}

Write-Host ""
Write-Host "  FULL STACK HQ — READ-ONLY DOCTOR" -ForegroundColor Cyan
Write-Host "  Source: $RepoRoot" -ForegroundColor DarkGray
Write-Host "  Target home: $UserHome" -ForegroundColor DarkGray
Write-Host "  Selected hosts: $($SelectedHosts -join ', ')" -ForegroundColor DarkGray
Write-Host ""

Write-Host "  Source checks" -ForegroundColor Yellow
Check-RequiredPath (Join-Path $RepoRoot "AGENTS.md") "Repository guidance"
Check-RequiredPath (Join-Path $RepoRoot "plugin.json") "Portable plugin manifest"
Check-RequiredPath (Join-Path $RepoRoot "core\rules\common.md") "Shared rule core"
Check-RequiredPath (Join-Path $RepoRoot "adapters") "Host adapter directory"
Check-RequiredPath (Join-Path $RepoRoot "agents") "Canonical agent directory"
Check-RequiredPath (Join-Path $RepoRoot "skills") "Canonical skill directory"
Check-RequiredPath (Join-Path $RepoRoot "workflows") "Canonical workflow directory"

$PowerShellCommand = Get-Command pwsh -ErrorAction SilentlyContinue
if ($null -eq $PowerShellCommand) {
    $PowerShellCommand = Get-Command powershell -ErrorAction SilentlyContinue
}
if ($null -eq $PowerShellCommand) {
    Write-Fail "PowerShell runtime not found; source validator could not run"
} else {
    & $PowerShellCommand.Source -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "validate.ps1")
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Source and adapter validator passed"
    } else {
        Write-Fail "Source and adapter validator failed"
    }
}

foreach ($HostName in $SelectedHosts) {
    Write-Host ""
    Write-Host "  $($HostName.ToUpperInvariant())" -ForegroundColor Yellow
    switch ($HostName) {
        "antigravity" {
            Check-Command "antigravity"
            Check-InstalledPath (Join-Path $UserHome ".gemini\GEMINI.md") "Global rules"
            Check-InstalledPath (Join-Path $UserHome ".gemini\config\agents") "Official agent directory"
            Check-InstalledPath (Join-Path $UserHome ".gemini\config\skills") "Official skill directory"
            Check-InstalledPath (Join-Path $UserHome ".gemini\config\workflows") "Legacy workflow directory"
        }
        "claude" {
            Check-Command "claude"
            Check-InstalledPath (Join-Path $UserHome ".claude\CLAUDE.md") "Global rules"
            Check-InstalledPath (Join-Path $UserHome ".claude\agents") "Agent directory"
            Check-InstalledPath (Join-Path $UserHome ".claude\skills") "Skill directory"
        }
        "codex" {
            Check-Command "codex"
            Check-InstalledPath (Join-Path $CodexHome "AGENTS.md") "Global rules"
            Check-InstalledPath (Join-Path $CodexHome "agents") "Custom-agent directory"
            Check-InstalledPath (Join-Path $UserHome ".agents\skills") "User skill directory"
            $OverridePath = Join-Path $CodexHome "AGENTS.override.md"
            if (Test-Path -LiteralPath $OverridePath) {
                Write-WarnStatus "AGENTS.override.md takes precedence over AGENTS.md: $OverridePath"
            } else {
                Write-Ok "No AGENTS.override.md shadowing the global rules"
            }
        }
    }
}

Write-Host ""
if ($FailureCount -gt 0) {
    Write-Host "  Doctor result: FAILED ($FailureCount failure(s), $WarningCount warning(s))" -ForegroundColor Red
    exit 1
}
if ($WarningCount -gt 0) {
    Write-Host "  Doctor result: READY WITH WARNINGS ($WarningCount)" -ForegroundColor Yellow
    if ($Strict) { exit 1 }
    exit 0
}
Write-Host "  Doctor result: READY" -ForegroundColor Green
exit 0
