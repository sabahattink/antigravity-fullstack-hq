#!/usr/bin/env bash
set -euo pipefail

# install.sh — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code + OpenAI Codex

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT=""
USER_HOME="${USERPROFILE:-$HOME}"
CODEX_HOME_VALUE="${CODEX_HOME:-$USER_HOME/.codex}"

FORCE=false
BACKUP=false
DRY_RUN=false
CHECK=false
NO_LEGACY_PATHS=false
ONLY_ANTIGRAVITY=false
ONLY_CLAUDE=false
ONLY_CODEX=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Install Full Stack HQ for all supported hosts, or select one host.

Options:
  --only-antigravity   Install Google Antigravity files only
  --only-claude        Install Claude Code files only
  --only-codex         Install OpenAI Codex files only
  -f, --force          Replace existing managed files without prompting
  --backup             Back up replaced files beside their original path
  --dry-run            Show planned changes without writing target files
  --target-root DIR    Install into an isolated home-like directory for testing
  --no-legacy-paths    Do not refresh an existing Antigravity legacy path
  --check              Validate the repository and adapter renderers
  -h, --help           Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) FORCE=true ;;
        --backup) BACKUP=true ;;
        --dry-run) DRY_RUN=true ;;
        --check) CHECK=true ;;
        --no-legacy-paths) NO_LEGACY_PATHS=true ;;
        --target-root)
            [[ $# -ge 2 ]] || { echo "--target-root needs a value" >&2; exit 2; }
            TARGET_ROOT="$2"
            shift
            ;;
        --only-antigravity) ONLY_ANTIGRAVITY=true ;;
        --only-claude) ONLY_CLAUDE=true ;;
        --only-codex) ONLY_CODEX=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown parameter: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

if [[ -n "$TARGET_ROOT" ]]; then
    if [[ "$DRY_RUN" == true || "$CHECK" == true ]]; then
        USER_HOME="$TARGET_ROOT"
    else
        mkdir -p "$TARGET_ROOT"
        USER_HOME="$(cd -- "$TARGET_ROOT" && pwd)"
    fi
    CODEX_HOME_VALUE="$USER_HOME/.codex"
fi

only_count=0
[[ "$ONLY_ANTIGRAVITY" == true ]] && only_count=$((only_count + 1))
[[ "$ONLY_CLAUDE" == true ]] && only_count=$((only_count + 1))
[[ "$ONLY_CODEX" == true ]] && only_count=$((only_count + 1))
[[ "$only_count" -le 1 ]] || { echo "Choose at most one --only-* option." >&2; exit 2; }

INSTALL_ANTIGRAVITY=true
INSTALL_CLAUDE=true
INSTALL_CODEX=true
if [[ "$ONLY_ANTIGRAVITY" == true ]]; then INSTALL_CLAUDE=false; INSTALL_CODEX=false; fi
if [[ "$ONLY_CLAUDE" == true ]]; then INSTALL_ANTIGRAVITY=false; INSTALL_CODEX=false; fi
if [[ "$ONLY_CODEX" == true ]]; then INSTALL_ANTIGRAVITY=false; INSTALL_CLAUDE=false; fi

GEMINI_HOME="$USER_HOME/.gemini"
GEMINI_CONFIG_HOME="$GEMINI_HOME/config"
GEMINI_OFFICIAL_AGENTS_DIR="$GEMINI_CONFIG_HOME/agents"
GEMINI_OFFICIAL_SKILLS_DIR="$GEMINI_CONFIG_HOME/skills"
GEMINI_OFFICIAL_WORKFLOWS_DIR="$GEMINI_CONFIG_HOME/workflows"
GEMINI_LEGACY_HOME="$GEMINI_HOME/antigravity"

CLAUDE_HOME="$USER_HOME/.claude"
CLAUDE_AGENTS_DIR="$CLAUDE_HOME/agents"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"

CODEX_AGENTS_DIR="$CODEX_HOME_VALUE/agents"
CODEX_SKILLS_DIR="$USER_HOME/.agents/skills"

log_ok() { echo -e "  \033[0;32m✓ $1\033[0m"; }
log_warn() { echo -e "  \033[1;33m⚠ $1\033[0m"; }
log_skip() { echo -e "  \033[0;90m→ $1\033[0m"; }
log_plan() { echo -e "  \033[0;36m• $1\033[0m"; }
section() { echo; echo -e "\033[1;33m▸ $1\033[0m"; }

backup_path() {
    local path="$1"
    local stamp candidate index
    stamp="$(date +%Y%m%d-%H%M%S)"
    candidate="$path.full-stack-hq-backup-$stamp"
    index=1
    while [[ -e "$candidate" ]]; do
        candidate="$path.full-stack-hq-backup-$stamp-$index"
        index=$((index + 1))
    done
    printf '%s' "$candidate"
}

copy_file() {
    local source="$1"
    local destination="$2"
    local label="$3"
    local prompt="${4:-false}"
    local exists=false
    [[ -e "$destination" ]] && exists=true

    if [[ "$exists" == true && -d "$destination" ]]; then
        echo "Destination is a directory; refusing to replace it with a file: $destination" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        if [[ "$exists" == true ]]; then log_plan "replace $destination"; else log_plan "create $destination"; fi
        return 0
    fi

    if [[ "$exists" == true && "$FORCE" != true ]]; then
        if [[ "$prompt" == true ]]; then
            log_warn "$label already exists"
            read -r -p "  Replace? (y/N) " response
            if [[ "$response" != "y" && "$response" != "Y" ]]; then
                log_skip "$label (kept existing)"
                return 0
            fi
        else
            log_skip "$label (kept existing; use --force to replace)"
            return 0
        fi
    fi

    mkdir -p "$(dirname "$destination")"
    if [[ "$exists" == true && "$BACKUP" == true ]]; then
        local target_backup
        target_backup="$(backup_path "$destination")"
        cp -p "$destination" "$target_backup"
        log_ok "$label backup → $target_backup"
    fi
    cp -f "$source" "$destination"
    log_ok "$label"
}

copy_tree() {
    local source_root="$1"
    local destination_root="$2"
    local label="$3"
    [[ -d "$source_root" ]] || return 0
    while IFS= read -r -d '' source_file; do
        local relative destination
        relative="${source_file#"$source_root"/}"
        destination="$destination_root/$relative"
        copy_file "$source_file" "$destination" "$label/$relative"
    done < <(find "$source_root" -type f -print0)
}

file_count() {
    find "$1" -type f 2>/dev/null | wc -l | tr -d ' '
}

if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Run this installer from a local checkout." >&2
    exit 1
fi

echo
echo -e "\033[0;36m╔════════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;36m║             FULL STACK HQ — INSTALLATION                      ║\033[0m"
echo -e "\033[0;36m║       Antigravity IDE + Claude Code + OpenAI Codex            ║\033[0m"
echo -e "\033[0;36m╚════════════════════════════════════════════════════════════════╝\033[0m"
section "Pre-flight checks"
log_ok "Git found"

if [[ "$CHECK" == true ]]; then
    bash "$SCRIPT_DIR/scripts/validate.sh"
    exit $?
fi

if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    if command -v antigravity >/dev/null 2>&1; then log_ok "Antigravity detected"; else log_warn "Antigravity command not detected — installing files anyway"; fi
fi
if [[ "$INSTALL_CLAUDE" == true ]]; then
    if command -v claude >/dev/null 2>&1; then log_ok "Claude Code detected"; else log_warn "Claude Code command not detected — installing files anyway"; fi
fi
if [[ "$INSTALL_CODEX" == true ]]; then
    if command -v codex >/dev/null 2>&1; then log_ok "Codex detected"; else log_warn "Codex command not detected — installing files anyway"; fi
    if [[ -f "$CODEX_HOME_VALUE/AGENTS.override.md" ]]; then
        log_warn "AGENTS.override.md exists — Codex will prioritize it over AGENTS.md"
    fi
fi
[[ "$DRY_RUN" == true ]] && log_warn "Dry-run mode: no target files will be changed"
[[ "$BACKUP" == true ]] && log_ok "Backups enabled for replaced files"

BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/full-stack-hq-install.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
bash "$SCRIPT_DIR/scripts/build-adapters.sh" --output-dir "$BUILD_DIR"

if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    section "Google Antigravity IDE"
    copy_file "$BUILD_DIR/antigravity/GEMINI.md" "$GEMINI_HOME/GEMINI.md" "GEMINI.md" true
    copy_tree "$SCRIPT_DIR/agents" "$GEMINI_OFFICIAL_AGENTS_DIR" "Antigravity agents"
    copy_tree "$SCRIPT_DIR/skills" "$GEMINI_OFFICIAL_SKILLS_DIR" "Antigravity skills"
    copy_tree "$BUILD_DIR/workflow-skills" "$GEMINI_OFFICIAL_SKILLS_DIR" "Antigravity workflow skills"
    copy_tree "$SCRIPT_DIR/workflows" "$GEMINI_OFFICIAL_WORKFLOWS_DIR" "Antigravity legacy workflows"
    log_ok "Official paths: agents=$(file_count "$SCRIPT_DIR/agents"), skills=$(( $(file_count "$SCRIPT_DIR/skills") + $(file_count "$BUILD_DIR/workflow-skills") )), workflows=$(file_count "$SCRIPT_DIR/workflows")"

    if [[ "$NO_LEGACY_PATHS" != true && -d "$GEMINI_LEGACY_HOME" ]]; then
        section "Antigravity legacy compatibility bridge"
        copy_tree "$SCRIPT_DIR/agents" "$GEMINI_LEGACY_HOME/agents" "Legacy Antigravity agents"
        copy_tree "$SCRIPT_DIR/skills" "$GEMINI_LEGACY_HOME/skills" "Legacy Antigravity skills"
        copy_tree "$SCRIPT_DIR/workflows" "$GEMINI_LEGACY_HOME/workflows" "Legacy Antigravity workflows"
        log_ok "Existing legacy paths refreshed"
    elif [[ "$NO_LEGACY_PATHS" != true ]]; then
        log_skip "Legacy Antigravity paths not present; official paths only"
    fi
fi

if [[ "$INSTALL_CLAUDE" == true ]]; then
    section "Claude Code"
    copy_file "$BUILD_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md" "CLAUDE.md" true
    copy_tree "$SCRIPT_DIR/agents" "$CLAUDE_AGENTS_DIR" "Claude agents"
    copy_tree "$SCRIPT_DIR/skills" "$CLAUDE_SKILLS_DIR" "Claude skills"
    copy_tree "$BUILD_DIR/workflow-skills" "$CLAUDE_SKILLS_DIR" "Claude workflow skills"
    log_ok "Installed: agents=$(file_count "$SCRIPT_DIR/agents"), skills=$(( $(file_count "$SCRIPT_DIR/skills") + $(file_count "$BUILD_DIR/workflow-skills") ))"
fi

if [[ "$INSTALL_CODEX" == true ]]; then
    section "OpenAI Codex"
    copy_file "$BUILD_DIR/codex/AGENTS.md" "$CODEX_HOME_VALUE/AGENTS.md" "AGENTS.md" true
    copy_tree "$BUILD_DIR/codex/agents" "$CODEX_AGENTS_DIR" "Codex custom agents"
    copy_tree "$SCRIPT_DIR/skills" "$CODEX_SKILLS_DIR" "Codex skills"
    copy_tree "$BUILD_DIR/workflow-skills" "$CODEX_SKILLS_DIR" "Codex workflow skills"
    log_ok "Installed: agents=$(file_count "$BUILD_DIR/codex/agents"), skills=$(( $(file_count "$SCRIPT_DIR/skills") + $(file_count "$BUILD_DIR/workflow-skills") ))"
fi

echo
echo -e "\033[0;32mInstallation complete.\033[0m"
[[ "$INSTALL_ANTIGRAVITY" == true ]] && echo "  Antigravity rules → $GEMINI_HOME/GEMINI.md"
[[ "$INSTALL_CLAUDE" == true ]] && echo "  Claude rules       → $CLAUDE_HOME/CLAUDE.md"
[[ "$INSTALL_CODEX" == true ]] && echo "  Codex rules        → $CODEX_HOME_VALUE/AGENTS.md"
echo
echo "Restart the host application and start a new conversation."
echo "Use --dry-run to preview future changes; use --backup with --force for safe replacement."
