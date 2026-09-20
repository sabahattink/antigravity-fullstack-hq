#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TARGET_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-smoke.XXXXXX")"
trap 'rm -rf -- "$TARGET_ROOT"' EXIT

assert_path() {
    local path="$1" label="$2"
    [[ -e "$path" ]] || { echo "[FAIL] $label is missing: $path" >&2; exit 1; }
    echo "  [OK]   $label"
}

assert_count() {
    local path="$1" pattern="$2" expected="$3" label="$4"
    local actual
    actual="$(find "$path" -type f -name "$pattern" | wc -l | tr -d ' ')"
    [[ "$actual" == "$expected" ]] || { echo "[FAIL] $label expected $expected but found $actual in $path" >&2; exit 1; }
    echo "  [OK]   $label ($actual)"
}

echo
echo "  FULL STACK HQ — BASH INSTALL SMOKE TEST"
echo "  Isolated target: $TARGET_ROOT"
echo

bash "$REPO_ROOT/install.sh" --target-root "$TARGET_ROOT" --force

assert_path "$TARGET_ROOT/.gemini/GEMINI.md" "Antigravity global rules"
assert_path "$TARGET_ROOT/.claude/CLAUDE.md" "Claude global rules"
assert_path "$TARGET_ROOT/.codex/AGENTS.md" "Codex global rules"
assert_path "$TARGET_ROOT/.gemini/config/workflows" "Antigravity workflows"
assert_path "$TARGET_ROOT/.agents/skills" "Shared user skills"

expected_agents="$(find "$REPO_ROOT/agents" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
expected_skills="$(find "$REPO_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
expected_workflows="$(find "$REPO_ROOT/workflows" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
expected_skill_adapters=$((expected_skills + expected_workflows))

assert_count "$TARGET_ROOT/.gemini/config/agents" '*.md' "$expected_agents" "Antigravity agents"
assert_count "$TARGET_ROOT/.gemini/config/skills" 'SKILL.md' "$expected_skill_adapters" "Antigravity skills"
assert_count "$TARGET_ROOT/.gemini/config/workflows" '*.md' "$expected_workflows" "Antigravity legacy workflows"
assert_count "$TARGET_ROOT/.claude/agents" '*.md' "$expected_agents" "Claude agents"
assert_count "$TARGET_ROOT/.claude/skills" 'SKILL.md' "$expected_skill_adapters" "Claude skills"
assert_count "$TARGET_ROOT/.codex/agents" '*.toml' "$expected_agents" "Codex custom agents"
assert_count "$TARGET_ROOT/.agents/skills" 'SKILL.md' "$expected_skill_adapters" "Codex skills"

echo
echo "  Smoke test passed."
