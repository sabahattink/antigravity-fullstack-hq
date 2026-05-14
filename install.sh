#!/bin/bash
# install.sh — Full Stack HQ
# Supports: Google Antigravity IDE + Claude Code
# Usage:
#   ./install.sh                  # install both
#   ./install.sh --only-antigravity
#   ./install.sh --only-claude
#   ./install.sh --force          # overwrite existing configs

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GEMINI_HOME="$HOME/.gemini"
GEMINI_SKILLS_DIR="$GEMINI_HOME/antigravity/skills"
GEMINI_WORKFLOWS_DIR="$GEMINI_HOME/antigravity/workflows"
GEMINI_AGENTS_DIR="$GEMINI_HOME/antigravity/agents"

CLAUDE_HOME="$HOME/.claude"
CLAUDE_SKILLS_DIR="$CLAUDE_HOME/skills"
CLAUDE_AGENTS_DIR="$CLAUDE_HOME/agents"

# ── Flags ─────────────────────────────────────────────────────────────────────
FORCE=false
INSTALL_ANTIGRAVITY=true
INSTALL_CLAUDE=true

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force)             FORCE=true ;;
        --only-antigravity)     INSTALL_CLAUDE=false ;;
        --only-claude)          INSTALL_ANTIGRAVITY=false ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║          FULL STACK HQ — INSTALLATION                        ║${NC}"
echo -e "${CYAN}${BOLD}║          Google Antigravity + Claude Code                    ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Pre-flight ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}${BOLD}▸ Pre-flight Checks${NC}"

if ! command -v git &>/dev/null; then
    echo -e "  ${RED}✗ Git not found. Install git first.${NC}"; exit 1
fi
echo -e "  ${GREEN}✓ git found${NC}"

ANTIGRAVITY_AVAILABLE=false
CLAUDE_AVAILABLE=false

if command -v antigravity &>/dev/null || [[ -d "$GEMINI_HOME" ]]; then
    ANTIGRAVITY_AVAILABLE=true
    echo -e "  ${GREEN}✓ Antigravity detected${NC}"
fi

if command -v claude &>/dev/null || [[ -d "$CLAUDE_HOME" ]]; then
    CLAUDE_AVAILABLE=true
    echo -e "  ${GREEN}✓ Claude Code detected${NC}"
fi

if [[ "$ANTIGRAVITY_AVAILABLE" == false && "$INSTALL_ANTIGRAVITY" == true ]]; then
    echo -e "  ${YELLOW}⚠ Antigravity not detected — installing files anyway${NC}"
fi
if [[ "$CLAUDE_AVAILABLE" == false && "$INSTALL_CLAUDE" == true ]]; then
    echo -e "  ${YELLOW}⚠ Claude Code not detected — installing files anyway${NC}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# ANTIGRAVITY
# ──────────────────────────────────────────────────────────────────────────────
if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    echo ""
    echo -e "${BLUE}${BOLD}▸ Installing for Google Antigravity IDE${NC}"
    echo -e "  ${CYAN}Target: ~/.gemini/${NC}"

    # Prompt for existing GEMINI.md
    if [[ -f "$GEMINI_HOME/GEMINI.md" ]] && [[ "$FORCE" != true ]]; then
        echo -e "  ${YELLOW}⚠ GEMINI.md already exists${NC}"
        read -rp "  Overwrite? (y/N) " resp
        if [[ "$resp" != "y" && "$resp" != "Y" ]]; then
            echo -e "  ${NC}→ Keeping existing GEMINI.md${NC}"
            SKIP_GEMINI=true
        fi
    fi

    mkdir -p "$GEMINI_HOME" "$GEMINI_SKILLS_DIR" "$GEMINI_WORKFLOWS_DIR" "$GEMINI_AGENTS_DIR"

    if [[ "${SKIP_GEMINI:-false}" != true ]]; then
        cp "$SCRIPT_DIR/gemini/GEMINI.md" "$GEMINI_HOME/GEMINI.md"
        echo -e "  ${GREEN}✓ GEMINI.md${NC}"
    fi

    # Agents
    agent_count=0
    for f in "$SCRIPT_DIR/agents"/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$GEMINI_AGENTS_DIR/"
        ((agent_count++))
    done
    echo -e "  ${GREEN}✓ Agents: $agent_count files${NC}"

    # Skills
    skill_count=0
    for d in "$SCRIPT_DIR/skills"/*/; do
        [[ -d "$d" ]] || continue
        cp -r "$d" "$GEMINI_SKILLS_DIR/"
        ((skill_count++))
    done
    echo -e "  ${GREEN}✓ Skills: $skill_count modules${NC}"

    # Workflows
    workflow_count=0
    for f in "$SCRIPT_DIR/workflows"/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$GEMINI_WORKFLOWS_DIR/"
        ((workflow_count++))
    done
    echo -e "  ${GREEN}✓ Workflows: $workflow_count files${NC}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# CLAUDE CODE
# ──────────────────────────────────────────────────────────────────────────────
if [[ "$INSTALL_CLAUDE" == true ]]; then
    echo ""
    echo -e "${BLUE}${BOLD}▸ Installing for Claude Code${NC}"
    echo -e "  ${CYAN}Target: ~/.claude/${NC}"

    # Prompt for existing CLAUDE.md
    if [[ -f "$CLAUDE_HOME/CLAUDE.md" ]] && [[ "$FORCE" != true ]]; then
        echo -e "  ${YELLOW}⚠ CLAUDE.md already exists${NC}"
        read -rp "  Overwrite? (y/N) " resp
        if [[ "$resp" == "y" || "$resp" == "Y" ]]; then
            cp "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
            echo -e "  ${GREEN}✓ CLAUDE.md (overwritten)${NC}"
        else
            echo -e "  ${NC}→ Keeping existing CLAUDE.md${NC}"
        fi
    else
        mkdir -p "$CLAUDE_HOME"
        cp "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
        echo -e "  ${GREEN}✓ CLAUDE.md${NC}"
    fi

    # Agents
    mkdir -p "$CLAUDE_AGENTS_DIR"
    agent_count=0
    for f in "$SCRIPT_DIR/agents"/*.md; do
        [[ -f "$f" ]] || continue
        cp "$f" "$CLAUDE_AGENTS_DIR/"
        ((agent_count++))
    done
    echo -e "  ${GREEN}✓ Agents: $agent_count files${NC}"

    # Skills
    mkdir -p "$CLAUDE_SKILLS_DIR"
    skill_count=0
    for d in "$SCRIPT_DIR/skills"/*/; do
        [[ -d "$d" ]] || continue
        cp -r "$d" "$CLAUDE_SKILLS_DIR/"
        ((skill_count++))
    done
    echo -e "  ${GREEN}✓ Skills: $skill_count modules${NC}"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                   INSTALLATION COMPLETE!                    ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    echo -e "${CYAN}Antigravity:${NC}"
    echo "  GEMINI.md  → ~/.gemini/GEMINI.md"
    echo "  Agents     → ~/.gemini/antigravity/agents/"
    echo "  Skills     → ~/.gemini/antigravity/skills/"
    echo "  Workflows  → ~/.gemini/antigravity/workflows/"
    echo ""
fi

if [[ "$INSTALL_CLAUDE" == true ]]; then
    echo -e "${CYAN}Claude Code:${NC}"
    echo "  CLAUDE.md  → ~/.claude/CLAUDE.md"
    echo "  Agents     → ~/.claude/agents/"
    echo "  Skills     → ~/.claude/skills/"
    echo ""
fi

echo -e "${YELLOW}Next steps:${NC}"
if [[ "$INSTALL_ANTIGRAVITY" == true ]]; then
    echo "  1. Restart Antigravity IDE"
fi
if [[ "$INSTALL_CLAUDE" == true ]]; then
    echo "  2. Restart Claude Code"
fi
echo "  3. Test: 'Create a React component called UserCard'"
echo "  4. Agent should ask for approval before creating"
echo ""
