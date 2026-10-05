#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TARGET_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-smoke.XXXXXX")"
BOOTSTRAP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-bootstrap.XXXXXX")"
PROJECT_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-project.XXXXXX")"
trap 'rm -rf -- "$TARGET_ROOT" "$BOOTSTRAP_ROOT" "$PROJECT_ROOT"' EXIT

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
echo "  Bootstrap from the committed HEAD (piped, as with curl | bash)"
FULL_STACK_HQ_REPO_URL="file://$REPO_ROOT" FULL_STACK_HQ_REF="$(git -C "$REPO_ROOT" rev-parse HEAD)" \
    bash -s -- --only-codex --force --target-root "$BOOTSTRAP_ROOT" < "$REPO_ROOT/bootstrap.sh"
assert_path "$BOOTSTRAP_ROOT/.codex/AGENTS.md" "Bootstrap Codex global rules"
assert_count "$BOOTSTRAP_ROOT/.codex/agents" '*.toml' "$expected_agents" "Bootstrap Codex custom agents"

echo
echo "  Project mode (existing AGENTS.md is preserved)"
printf '# Existing project\n\nKeep this line.\n' > "$PROJECT_ROOT/AGENTS.md"
cp "$PROJECT_ROOT/AGENTS.md" "$PROJECT_ROOT/AGENTS.md.orig"
bash "$REPO_ROOT/install.sh" --project "$PROJECT_ROOT" > /dev/null
grep -qxF 'Keep this line.' "$PROJECT_ROOT/AGENTS.md" || { echo "[FAIL] Project install dropped existing content" >&2; exit 1; }
grep -qF 'PLAN APPROVED' "$PROJECT_ROOT/AGENTS.md" || { echo "[FAIL] Project AGENTS.md is missing the shared rules" >&2; exit 1; }
grep -qxF '@AGENTS.md' "$PROJECT_ROOT/CLAUDE.md" || { echo "[FAIL] Project CLAUDE.md does not import AGENTS.md" >&2; exit 1; }
grep -qxF '@./AGENTS.md' "$PROJECT_ROOT/GEMINI.md" || { echo "[FAIL] Project GEMINI.md does not import AGENTS.md" >&2; exit 1; }
echo "  [OK]   Project rules written; existing content kept"
cp "$PROJECT_ROOT/AGENTS.md" "$PROJECT_ROOT/AGENTS.md.first"
bash "$REPO_ROOT/install.sh" --project "$PROJECT_ROOT" > /dev/null
cmp -s "$PROJECT_ROOT/AGENTS.md" "$PROJECT_ROOT/AGENTS.md.first" || { echo "[FAIL] Project install is not idempotent" >&2; exit 1; }
echo "  [OK]   Re-running the project install changes nothing"
bash "$REPO_ROOT/install.sh" --project "$PROJECT_ROOT" --uninstall > /dev/null
cmp -s "$PROJECT_ROOT/AGENTS.md" "$PROJECT_ROOT/AGENTS.md.orig" || { echo "[FAIL] Project uninstall did not restore AGENTS.md" >&2; exit 1; }
[[ ! -e "$PROJECT_ROOT/CLAUDE.md" && ! -e "$PROJECT_ROOT/GEMINI.md" ]] || { echo "[FAIL] Project uninstall left generated files behind" >&2; exit 1; }
echo "  [OK]   Project uninstall restores the original files"

echo
echo "  Smoke test passed."
