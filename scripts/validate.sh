#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
FAILURES=()

fail() { FAILURES+=("$1"); }

frontmatter() {
    awk 'BEGIN { section=0 } /^---$/ { section++; if (section == 2) exit; next } section == 1 { print }' "$1"
}

body() {
    awk 'BEGIN { section=0 } /^---$/ { section++; next } section >= 2 { print }' "$1"
}

metadata() {
    local key="$1"
    local path="$2"
    frontmatter "$path" | sed -n -E "s/^${key}:[[:space:]]*//p" | head -n 1 | sed -E "s/^[\"']//; s/[\"']$//"
}

validate_document() {
    local path="$1"
    local kind="$2"
    local name expected description body_text
    if ! grep -q '^---$' "$path"; then fail "Missing YAML frontmatter: $path"; return; fi
    name="$(metadata name "$path")"
    description="$(metadata description "$path")"
    [[ -n "$name" ]] || fail "Missing name: $path"
    [[ -n "$description" ]] || fail "Missing description: $path"
    [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]] || fail "Invalid $kind name: $path"
    expected="$(basename "$path")"
    if [[ "$kind" == "skill" ]]; then expected="$(basename "$(dirname "$path")")"; else expected="${expected%.md}"; fi
    [[ "$name" == "$expected" ]] || fail "$kind name does not match path: $path"
    body_text="$(body "$path")"
    [[ -n "$body_text" ]] || fail "Empty $kind body: $path"
}

for required in AGENTS.md plugin.json core/rules/common.md adapters/claude/rules.md adapters/antigravity/rules.md adapters/codex/rules.md scripts/build-adapters.ps1 scripts/build-adapters.sh; do
    [[ -f "$REPO_ROOT/$required" ]] || fail "Missing required file: $required"
done

plugin_json="$REPO_ROOT/plugin.json"
if [[ -f "$plugin_json" ]]; then
    grep -Eq '"\$schema"[[:space:]]*:[[:space:]]*"https://agent-plugins\.org/schemas/1\.0\.0/plugin\.schema\.json"' "$plugin_json" || fail "Plugin manifest has an invalid schema URL"
    grep -Eq '"name"[[:space:]]*:[[:space:]]*"full-stack-hq"' "$plugin_json" || fail "Plugin manifest name must be full-stack-hq"
    grep -Eq '"version"[[:space:]]*:[[:space:]]*"[0-9]+\.[0-9]+\.[0-9]+"' "$plugin_json" || fail "Plugin manifest version is not semver"
    grep -Eq '"description"[[:space:]]*:[[:space:]]*"[^"].*"' "$plugin_json" || fail "Plugin manifest description is missing"
fi

while IFS= read -r -d '' path; do
    validate_document "$path" agent
done < <(find "$REPO_ROOT/agents" -type f -name '*.md' -print0)

while IFS= read -r -d '' path; do
    validate_document "$path" skill
done < <(find "$REPO_ROOT/skills" -type f -name 'SKILL.md' -print0)

while IFS= read -r -d '' path; do
    validate_document "$path" workflow
    workflow_name="$(metadata name "$path")"
    [[ ! -d "$REPO_ROOT/skills/$workflow_name" ]] || fail "Workflow name collides with canonical skill directory: $path"
    if grep -Eq '^\s*trigger:' "$path"; then fail "Use command metadata consistently: $path"; fi
    grep -Eq '^command:[[:space:]]*/[a-z0-9-]+' "$path" || fail "Missing command metadata: $path"
done < <(find "$REPO_ROOT/workflows" -maxdepth 1 -type f -name '*.md' -print0)

while IFS= read -r -d '' path; do
    if grep -nE 'GEMINI\.md|CLAUDE\.md|\.gemini|\.claude|\.codex|Antigravity|Claude Code|OpenAI Codex' "$path"; then
        fail "Host-specific reference in canonical content: $path"
    fi
done < <(find "$REPO_ROOT/core/rules" "$REPO_ROOT/agents" -type f -print0)

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-validation.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
bash "$REPO_ROOT/scripts/build-adapters.sh" --output-dir "$BUILD_DIR"

antigravity_chars="$(wc -m < "$BUILD_DIR/antigravity/GEMINI.md" | tr -d ' ')"
[[ "$antigravity_chars" -le 12000 ]] || fail "Antigravity global rules exceed 12000 characters: $antigravity_chars"
agent_count="$(find "$REPO_ROOT/agents" -type f -name '*.md' | wc -l | tr -d ' ')"
codex_agent_count="$(find "$BUILD_DIR/codex/agents" -type f -name '*.toml' | wc -l | tr -d ' ')"
[[ "$agent_count" == "$codex_agent_count" ]] || fail "Codex agent adapter count mismatch"

while IFS= read -r -d '' path; do
    grep -q '^name = "' "$path" || fail "Invalid Codex agent adapter: $path"
    grep -q '^description = "' "$path" || fail "Invalid Codex agent adapter: $path"
    grep -q "^developer_instructions = '''" "$path" || fail "Invalid Codex agent adapter: $path"
done < <(find "$BUILD_DIR/codex/agents" -type f -name '*.toml' -print0)

workflow_count="$(find "$REPO_ROOT/workflows" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
workflow_skill_count="$(find "$BUILD_DIR/workflow-skills" -mindepth 2 -name SKILL.md -type f | wc -l | tr -d ' ')"
[[ "$workflow_count" == "$workflow_skill_count" ]] || fail "Workflow skill adapter count mismatch"

while IFS= read -r -d '' path; do
    ! grep -Eq '^\s*(command|trigger):' "$path" || fail "Legacy command metadata leaked into skill: $path"
done < <(find "$BUILD_DIR/workflow-skills" -type f -name SKILL.md -print0)

if [[ "${#FAILURES[@]}" -gt 0 ]]; then
    echo "Validation failed:" >&2
    printf '  - %s\n' "${FAILURES[@]}" >&2
    exit 1
fi

echo "Full Stack HQ validation passed."
