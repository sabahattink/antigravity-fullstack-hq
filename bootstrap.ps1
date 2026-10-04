# bootstrap.ps1 — Full Stack HQ one-line installer
#
# Preview first, without touching any host configuration:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sabahattink/antigravity-fullstack-hq/main/bootstrap.ps1))) -DryRun
#
# The script fetches a temporary shallow checkout, runs install.ps1 with the
# same parameters, and removes the checkout afterwards. Pin a release or commit
# with -Ref v1.3.0 or $env:FULL_STACK_HQ_REF.

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
    [string]$Ref = $(if ($env:FULL_STACK_HQ_REF) { $env:FULL_STACK_HQ_REF } else { "main" }),
    [string]$RepoUrl = $(if ($env:FULL_STACK_HQ_REPO_URL) { $env:FULL_STACK_HQ_REPO_URL } else { "https://github.com/sabahattink/antigravity-fullstack-hq.git" })
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Full Stack HQ needs git. Install git and run this command again."
}

function Invoke-Git {
    git @args
    if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed with exit code $LASTEXITCODE." }
}

$WorkDir = Join-Path ([System.IO.Path]::GetTempPath()) ("full-stack-hq-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $WorkDir | Out-Null

try {
    Write-Host "Fetching Full Stack HQ ($Ref) from $RepoUrl"
    Invoke-Git -C $WorkDir init -q
    Invoke-Git -C $WorkDir fetch -q --depth 1 $RepoUrl $Ref
    Invoke-Git -C $WorkDir -c advice.detachedHead=false checkout -q FETCH_HEAD
    Write-Host "Using commit $(git -C $WorkDir rev-parse --short HEAD)"

    # Run the installer in a child process so the session's execution policy
    # does not block the freshly fetched script. The bypass ends with that process.
    $InstallerArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Join-Path $WorkDir "install.ps1"))
    foreach ($Name in @("Force", "Backup", "DryRun", "Check", "NoLegacyPaths", "OnlyAntigravity", "OnlyClaude", "OnlyCodex")) {
        if ($PSBoundParameters.ContainsKey($Name) -and $PSBoundParameters[$Name]) { $InstallerArgs += "-$Name" }
    }
    if (-not [string]::IsNullOrWhiteSpace($TargetRoot)) {
        $InstallerArgs += @("-TargetRoot", $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetRoot))
    }

    $PowerShell = (Get-Process -Id $PID).Path
    & $PowerShell @InstallerArgs
    if ($LASTEXITCODE -ne 0) { throw "Full Stack HQ installer failed with exit code $LASTEXITCODE." }
} finally {
    Remove-Item -LiteralPath $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
}
