[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Message) {
    $Failures.Add($Message)
}

function Read-Normalized([string]$Path) {
    return (Get-Content -LiteralPath $Path -Raw).Replace("`r`n", "`n")
}

function Read-Document([string]$Path) {
    $Text = Read-Normalized $Path
    $Match = [regex]::Match($Text, '(?s)\A---\n(.*?)\n---\n?(.*)\z')
    if (-not $Match.Success) {
        Add-Failure "Missing YAML frontmatter: $Path"
        return $null
    }
    $Front = $Match.Groups[1].Value
    $Name = [regex]::Match($Front, '(?m)^name:\s*(.+)$')
    $Description = [regex]::Match($Front, '(?m)^description:\s*(.+)$')
    if (-not $Name.Success) { Add-Failure "Missing name: $Path" }
    if (-not $Description.Success) { Add-Failure "Missing description: $Path" }
    return [pscustomobject]@{
        Name = if ($Name.Success) { $Name.Groups[1].Value.Trim().Trim('"').Trim("'") } else { "" }
        Description = if ($Description.Success) { $Description.Groups[1].Value.Trim() } else { "" }
        Front = $Front
        Body = $Match.Groups[2].Value.Trim()
    }
}

function Validate-Directory([string]$Directory, [string]$Pattern, [string]$Kind) {
    $Files = @(Get-ChildItem -LiteralPath $Directory -Filter $Pattern -File -ErrorAction SilentlyContinue)
    if ($Files.Count -eq 0) { Add-Failure "No $Kind files found in $Directory" }
    return $Files
}

foreach ($Required in @(
    "AGENTS.md",
    "plugin.json",
    "core\rules\common.md",
    "adapters\claude\rules.md",
    "adapters\antigravity\rules.md",
    "adapters\codex\rules.md",
    "scripts\build-adapters.ps1",
    "scripts\build-adapters.sh"
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $Required))) {
        Add-Failure "Missing required file: $Required"
    }
}

try {
    $Plugin = Get-Content -LiteralPath (Join-Path $RepoRoot "plugin.json") -Raw | ConvertFrom-Json
    foreach ($Property in @("`$schema", "name", "version", "description")) {
        if (-not ($Plugin.PSObject.Properties.Name -contains $Property) -or
            [string]::IsNullOrWhiteSpace([string]$Plugin.$Property)) {
            Add-Failure "Plugin manifest is missing '$Property'"
        }
    }
    if ([string]$Plugin.name -ne "full-stack-hq") { Add-Failure "Plugin manifest name must be full-stack-hq" }
    if ([string]$Plugin.version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') { Add-Failure "Plugin manifest version is not semver" }
}
catch {
    Add-Failure "Invalid plugin manifest: $($_.Exception.Message)"
}

$Agents = Validate-Directory (Join-Path $RepoRoot "agents") "*.md" "agent"
foreach ($File in $Agents) {
    $Document = Read-Document $File.FullName
    if ($null -eq $Document) { continue }
    if ($Document.Name -ne $File.BaseName) { Add-Failure "Agent name does not match filename: $File" }
    if ($Document.Name -notmatch '^[a-z0-9][a-z0-9-]*$') { Add-Failure "Invalid agent name: $File" }
    if ([string]::IsNullOrWhiteSpace($Document.Body)) { Add-Failure "Empty agent body: $File" }
}

$SkillDirectories = @(Get-ChildItem (Join-Path $RepoRoot "skills") -Directory)
if ($SkillDirectories.Count -eq 0) { Add-Failure "No skill directories found" }
foreach ($Directory in $SkillDirectories) {
    $SkillFile = Join-Path $Directory.FullName "SKILL.md"
    if (-not (Test-Path -LiteralPath $SkillFile)) {
        Add-Failure "Missing SKILL.md: $Directory"
        continue
    }
    $Document = Read-Document $SkillFile
    if ($null -eq $Document) { continue }
    if ($Document.Name -ne $Directory.Name) { Add-Failure "Skill name does not match directory: $SkillFile" }
    if ($Document.Name -notmatch '^[a-z0-9][a-z0-9-]*$') { Add-Failure "Invalid skill name: $SkillFile" }
    if ([string]::IsNullOrWhiteSpace($Document.Body)) { Add-Failure "Empty skill body: $SkillFile" }
}

$Workflows = Validate-Directory (Join-Path $RepoRoot "workflows") "*.md" "workflow"
foreach ($File in $Workflows) {
    $Document = Read-Document $File.FullName
    if ($null -eq $Document) { continue }
    if ($Document.Name -ne $File.BaseName) { Add-Failure "Workflow name does not match filename: $File" }
    if ($SkillDirectories.Name -contains $Document.Name) { Add-Failure "Workflow name collides with canonical skill directory: $File" }
    if ($Document.Front -match '(?m)^\s*trigger:') { Add-Failure "Use command metadata consistently: $File" }
    if ($Document.Front -notmatch '(?m)^\s*command:\s*/[a-z0-9-]+') { Add-Failure "Missing command metadata: $File" }
}

foreach ($NeutralPath in @(
    (Join-Path $RepoRoot "core\rules"),
    (Join-Path $RepoRoot "agents")
)) {
    $Leak = Get-ChildItem $NeutralPath -Recurse -File | Select-String -Pattern 'GEMINI\.md|CLAUDE\.md|\.gemini|\.claude|\.codex|Antigravity|Claude Code|OpenAI Codex'
    if ($Leak) {
        foreach ($Hit in $Leak) { Add-Failure "Host-specific reference in canonical content: $($Hit.Path):$($Hit.LineNumber)" }
    }
}

$BuildDir = Join-Path ([System.IO.Path]::GetTempPath()) ("full-stack-hq-validation-" + [guid]::NewGuid().ToString("N"))
try {
    & (Join-Path $RepoRoot "scripts\build-adapters.ps1") -OutputDir $BuildDir | Out-Host
    $AntigravityRules = Join-Path $BuildDir "antigravity\GEMINI.md"
    $AntigravityChars = (Read-Normalized $AntigravityRules).Length
    if ($AntigravityChars -gt 12000) { Add-Failure "Antigravity global rules exceed 12000 characters: $AntigravityChars" }
    $CodexAgents = @(Get-ChildItem (Join-Path $BuildDir "codex\agents") -Filter "*.toml" -File)
    if ($CodexAgents.Count -ne $Agents.Count) { Add-Failure "Codex agent adapter count mismatch" }
    foreach ($File in $CodexAgents) {
        $Text = Read-Normalized $File.FullName
        foreach ($RequiredPattern in @('(?m)^name = "', '(?m)^description = "', "(?m)^developer_instructions = '''")) {
            if ($Text -notmatch $RequiredPattern) { Add-Failure "Invalid Codex custom agent adapter: $File" }
        }
    }
    $WorkflowSkills = @(Get-ChildItem (Join-Path $BuildDir "workflow-skills") -Directory)
    if ($WorkflowSkills.Count -ne $Workflows.Count) { Add-Failure "Workflow skill adapter count mismatch" }
    foreach ($Directory in $WorkflowSkills) {
        $SkillFile = Join-Path $Directory.FullName "SKILL.md"
        if (-not (Test-Path -LiteralPath $SkillFile)) { Add-Failure "Missing generated workflow skill: $Directory" }
        else {
            $Text = Read-Normalized $SkillFile
            if ($Text -match '(?m)^\s*(command|trigger):') { Add-Failure "Legacy command metadata leaked into skill: $SkillFile" }
        }
    }
}
catch {
    Add-Failure "Adapter build failed: $($_.Exception.Message)"
}
finally {
    if (Test-Path -LiteralPath $BuildDir) {
        Remove-Item -LiteralPath $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($Failures.Count -gt 0) {
    Write-Host "Validation failed:" -ForegroundColor Red
    $Failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Full Stack HQ validation passed." -ForegroundColor Green
