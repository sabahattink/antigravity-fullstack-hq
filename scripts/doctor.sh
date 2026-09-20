#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TARGET_ROOT=""
STRICT=false
ONLY_HOST=""
FAILURES=0
WARNINGS=0

usage() {
    cat <<'EOF'
Usage: bash scripts/doctor.sh [options]

Read-only diagnostics for the repository and selected host installation.

Options:
  --only-antigravity   Inspect Google Antigravity paths only
  --only-claude        Inspect Claude Code paths only
  --only-codex         Inspect OpenAI Codex paths only
  --target-root DIR    Inspect an isolated home-like directory
  --strict             Treat warnings as a failed result
  -h, --help           Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only-antigravity)
            [[ -z "$ONLY_HOST" ]] || { echo "Choose at most one --only-* option." >&2; exit 2; }
            ONLY_HOST="antigravity"
            ;;
        --only-claude)
            [[ -z "$ONLY_HOST" ]] || { echo "Choose at most one --only-* option." >&2; exit 2; }
            ONLY_HOST="claude"
            ;;
        --only-codex)
            [[ -z "$ONLY_HOST" ]] || { echo "Choose at most one --only-* option." >&2; exit 2; }
            ONLY_HOST="codex"
            ;;
        --target-root)
            [[ $# -ge 2 ]] || { echo "--target-root needs a value" >&2; exit 2; }
            TARGET_ROOT="$2"
            shift
            ;;
        --strict) STRICT=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown parameter: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

USER_HOME="${TARGET_ROOT:-${USERPROFILE:-$HOME}}"
if [[ -n "$TARGET_ROOT" ]]; then
    CODEX_HOME_VALUE="$USER_HOME/.codex"
else
    CODEX_HOME_VALUE="${CODEX_HOME:-$USER_HOME/.codex}"
fi

ok() { echo "  [OK]   $1"; }
warn() { WARNINGS=$((WARNINGS + 1)); echo "  [WARN] $1"; }
fail() { FAILURES=$((FAILURES + 1)); echo "  [FAIL] $1" >&2; }

check_required() {
    local path="$1" label="$2"
    if [[ -e "$path" ]]; then ok "$label"; else fail "$label — missing: $path"; fi
}

check_installed() {
    local path="$1" label="$2"
    if [[ -e "$path" ]]; then ok "$label"; else warn "$label — not installed at: $path"; fi
}

check_command() {
    local name="$1"
    if command -v "$name" >/dev/null 2>&1; then ok "$name command detected"; else warn "$name command not detected; files can still be prepared"; fi
}

check_host() {
    local host="$1"
    echo
    echo "  ${host^^}"
    case "$host" in
        antigravity)
            check_command antigravity
            check_installed "$USER_HOME/.gemini/GEMINI.md" "Global rules"
            check_installed "$USER_HOME/.gemini/config/agents" "Official agent directory"
            check_installed "$USER_HOME/.gemini/config/skills" "Official skill directory"
            check_installed "$USER_HOME/.gemini/config/workflows" "Legacy workflow directory"
            ;;
        claude)
            check_command claude
            check_installed "$USER_HOME/.claude/CLAUDE.md" "Global rules"
            check_installed "$USER_HOME/.claude/agents" "Agent directory"
            check_installed "$USER_HOME/.claude/skills" "Skill directory"
            ;;
        codex)
            check_command codex
            check_installed "$CODEX_HOME_VALUE/AGENTS.md" "Global rules"
            check_installed "$CODEX_HOME_VALUE/agents" "Custom-agent directory"
            check_installed "$USER_HOME/.agents/skills" "User skill directory"
            if [[ -e "$CODEX_HOME_VALUE/AGENTS.override.md" ]]; then
                warn "AGENTS.override.md takes precedence over AGENTS.md: $CODEX_HOME_VALUE/AGENTS.override.md"
            else
                ok "No AGENTS.override.md shadowing the global rules"
            fi
            ;;
    esac
}

echo
echo "  FULL STACK HQ — READ-ONLY DOCTOR"
echo "  Source: $REPO_ROOT"
echo "  Target home: $USER_HOME"
if [[ -n "$ONLY_HOST" ]]; then echo "  Selected host: $ONLY_HOST"; else echo "  Selected hosts: antigravity, claude, codex"; fi
echo
echo "  Source checks"
check_required "$REPO_ROOT/AGENTS.md" "Repository guidance"
check_required "$REPO_ROOT/plugin.json" "Portable plugin manifest"
check_required "$REPO_ROOT/core/rules/common.md" "Shared rule core"
check_required "$REPO_ROOT/adapters" "Host adapter directory"
check_required "$REPO_ROOT/agents" "Canonical agent directory"
check_required "$REPO_ROOT/skills" "Canonical skill directory"
check_required "$REPO_ROOT/workflows" "Canonical workflow directory"

if bash "$SCRIPT_DIR/validate.sh"; then
    ok "Source and adapter validator passed"
else
    fail "Source and adapter validator failed"
fi

if [[ -n "$ONLY_HOST" ]]; then
    check_host "$ONLY_HOST"
else
    check_host antigravity
    check_host claude
    check_host codex
fi

echo
if [[ "$FAILURES" -gt 0 ]]; then
    echo "  Doctor result: FAILED ($FAILURES failure(s), $WARNINGS warning(s))" >&2
    exit 1
fi
if [[ "$WARNINGS" -gt 0 ]]; then
    echo "  Doctor result: READY WITH WARNINGS ($WARNINGS)"
    if [[ "$STRICT" == true ]]; then exit 1; fi
    exit 0
fi
echo "  Doctor result: READY"
exit 0
