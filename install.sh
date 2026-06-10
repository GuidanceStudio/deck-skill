#!/usr/bin/env bash
set -euo pipefail

# deck skill installer — multi-assistant.
#
# `deck/` is a flat, assistant-neutral skill payload. This installer places it
# where your coding assistant looks for skills, or wraps it for assistants that
# use a different convention.
#
# Local mode:  ./install.sh [OPTIONS]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/Ymx1ZQ/deck/main/install.sh) --target claude

REPO_URL="${DECK_REPO_URL:-https://github.com/Ymx1ZQ/deck.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
CHECK=false
TARGET=""           # claude|codex|opencode|gemini|agents|manual|all (empty → menu/default)
AGENTS_DIR="$PWD"
CLEANUP_DIR=""

CLAUDE_DEST="$HOME/.claude/skills/deck"
CODEX_DEST="$HOME/.codex/skills/deck"
OPENCODE_DEST="$HOME/.config/opencode/skills/deck"
NEUTRAL_HOME="$HOME/.config/deck"
GEMINI_TOML="$HOME/.gemini/commands/deck.toml"

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

usage() {
    cat <<EOF
Install the deck skill into your coding assistant.

Usage:
    ./install.sh [OPTIONS]

Options:
    --target NAME   One of: claude, codex, opencode, gemini, agents, manual, all.
                    Omitted → interactive menu (or 'claude' when non-interactive).
    --agents-dir D  Directory the 'agents' target writes AGENTS.md into (default: \$PWD).
    --force         Overwrite an existing installation without prompting; also skip
                    the interactive dependency-warning prompt.
    --check         Compare the installed copy/wrapper against the source (no writes);
                    exits 1 and reports DRIFT on a difference or missing install.
    --help          Show this message.

Targets:
    claude    → ~/.claude/skills/deck/          (SKILL.md standard, verbatim)
    codex     → ~/.codex/skills/deck/           (SKILL.md standard, verbatim)
    opencode  → ~/.config/opencode/skills/deck/  (SKILL.md standard, verbatim)
    gemini    → ~/.gemini/commands/deck.toml     (TOML wrapper) + payload in ~/.config/deck
    agents    → AGENTS.md pointer (Cursor/Windsurf/Copilot/Aider/Continue) + payload in ~/.config/deck
    manual    → print the flat payload path; copy it wherever your tool reads skills

Runtime prerequisites (probed as a UX courtesy; render fails clearly without them):
    md2  +  a Chromium-family browser (or firefox 102+). See README → Requirements.

Environment:
    DECK_REPO_URL   Override the remote-mode clone URL.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=true; shift ;;
        --check) CHECK=true; shift ;;
        --target) TARGET="$2"; shift 2 ;;
        --agents-dir) AGENTS_DIR="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        claude|codex|opencode|gemini|agents|manual|all) TARGET="$1"; shift ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

# Resolve the source payload (local checkout or remote clone)
if [ -d "$SCRIPT_DIR/deck" ]; then
    SRC_ROOT="$SCRIPT_DIR/deck"
else
    if ! command -v git >/dev/null 2>&1; then
        echo "error: remote install requires 'git' on PATH" >&2
        exit 1
    fi
    CLEANUP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/deck-install-XXXXXX")"
    echo "Cloning deck into a temporary directory..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLEANUP_DIR/repo"
    SRC_ROOT="$CLEANUP_DIR/repo/deck"
    if [ ! -d "$SRC_ROOT" ]; then
        echo "error: cloned repo does not contain deck/" >&2
        exit 1
    fi
fi
SRC_PARENT="$(dirname "$SRC_ROOT")"

# --- dependency probe (UX layer; not part of the agentskills.io spec) -------

probe_deps() {
    local missing=()
    command -v md2 >/dev/null 2>&1 || missing+=("md2")
    local found=""
    for b in chromium google-chrome chromium-browser chrome brave-browser brave firefox; do
        command -v "$b" >/dev/null 2>&1 && { found="$b"; break; }
    done
    [ -z "$found" ] && missing+=("browser (chromium/chrome/brave/firefox)")
    [ ${#missing[@]} -eq 0 ] && return 0

    echo ""
    echo "Warning — missing runtime dependencies on \$PATH:"
    for m in "${missing[@]}"; do echo "  - $m"; done
    echo "See README.md → Requirements. The skill installs regardless, but"
    echo "/deck render will fail until these are present."
    if [ "$FORCE" != true ] && [ -t 0 ]; then
        printf "Continue installing? [y/N] "
        read -r reply
        [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
    fi
}

# --- helpers ---------------------------------------------------------------

src_sha() { git -C "$SRC_PARENT" rev-parse --short HEAD 2>/dev/null || true; }

copy_payload() {  # <dest>
    local dest="$1"
    if [ -d "$dest" ] && [ "$FORCE" != true ]; then
        printf "Target %s already exists. Overwrite? [y/N] " "$dest"
        read -r ans
        case "$ans" in y|Y|yes) ;; *) echo "Skipped $dest."; return 1 ;; esac
    fi
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -r "$SRC_ROOT" "$dest"
    [ -f "$dest/render/render.sh" ] && chmod +x "$dest/render/render.sh"
    local sha; sha="$(src_sha)"
    [ -n "$sha" ] && printf '%s\n' "$sha" > "$dest/.installed-from"
    echo "✅ Installed deck payload → $dest"
}

write_gemini_toml() {
    copy_payload "$NEUTRAL_HOME" || return 0
    mkdir -p "$(dirname "$GEMINI_TOML")"
    cat > "$GEMINI_TOML" <<TOML
description = "deck — build a business presentation (brief / draft / render)"
prompt = """
You are the deck skill. Follow the router and staged prompts in the skill
payload, reading files on demand as it directs.

Router: @{$NEUTRAL_HOME/SKILL.md}

User request: {{args}}
"""
TOML
    echo "✅ Wrote Gemini command → $GEMINI_TOML (payload in $NEUTRAL_HOME)"
}

AGENTS_MARK_START="<!-- deck:start -->"
AGENTS_MARK_END="<!-- deck:end -->"

write_agents_pointer() {  # <agents-dir>
    local dir="$1" file="$1/AGENTS.md"
    copy_payload "$NEUTRAL_HOME" || return 0
    mkdir -p "$dir"
    if [ -f "$file" ] && grep -qF "$AGENTS_MARK_START" "$file"; then
        sed -i "/$AGENTS_MARK_START/,/$AGENTS_MARK_END/d" "$file"
    fi
    cat >> "$file" <<AGENTS
$AGENTS_MARK_START
## deck skill

When asked to build a presentation/deck, act as the deck skill: read
\`$NEUTRAL_HOME/SKILL.md\` and follow its staged pipeline (brief / draft /
render). The render stage needs md2 + a Chromium-family browser.
$AGENTS_MARK_END
AGENTS
    echo "✅ Added deck pointer → $file (payload in $NEUTRAL_HOME)"
}

check_copy() {  # <dest> <label>
    local dest="$1" label="$2"
    if [ ! -d "$dest" ]; then echo "DRIFT: $label not installed at $dest"; return 1; fi
    local out; out="$(diff -r --exclude=.installed-from "$SRC_ROOT" "$dest" 2>&1)" || true
    if [ -n "$out" ]; then echo "DRIFT: $label at $dest differs from source:"; echo "$out" | head -10; return 1; fi
    echo "OK: $label matches the source tree ($dest)"; return 0
}

run_check() {  # <target>
    case "$1" in
        claude)   check_copy "$CLAUDE_DEST" "claude" ;;
        codex)    check_copy "$CODEX_DEST" "codex" ;;
        opencode) check_copy "$OPENCODE_DEST" "opencode" ;;
        gemini)
            [ -f "$GEMINI_TOML" ] || { echo "DRIFT: gemini command not installed at $GEMINI_TOML"; return 1; }
            check_copy "$NEUTRAL_HOME" "gemini payload" ;;
        agents)
            grep -qF "$AGENTS_MARK_START" "$AGENTS_DIR/AGENTS.md" 2>/dev/null \
                || { echo "DRIFT: AGENTS.md pointer missing in $AGENTS_DIR"; return 1; }
            check_copy "$NEUTRAL_HOME" "agents payload" ;;
        all)
            local rc=0
            run_check claude || rc=1; run_check codex || rc=1; run_check opencode || rc=1
            return $rc ;;
        *) echo "error: --check needs a --target (claude|codex|opencode|gemini|agents|all)" >&2; return 2 ;;
    esac
}

run_install() {  # <target>
    case "$1" in
        claude)   copy_payload "$CLAUDE_DEST" || true ;;
        codex)    copy_payload "$CODEX_DEST" || true ;;
        opencode) copy_payload "$OPENCODE_DEST" || true ;;
        gemini)   write_gemini_toml ;;
        agents)   write_agents_pointer "$AGENTS_DIR" ;;
        manual)
            echo "Flat skill payload:"
            echo "    $SRC_ROOT"
            echo "Copy that folder wherever your assistant reads skills." ;;
        all)
            run_install claude; run_install codex; run_install opencode ;;
        *) echo "unknown target: $1" >&2; usage >&2; exit 1 ;;
    esac
}

interactive_menu() {
    cat <<EOF
Where should deck be installed?
  1) claude     ~/.claude/skills/deck
  2) codex      ~/.codex/skills/deck
  3) opencode   ~/.config/opencode/skills/deck
  4) gemini     ~/.gemini/commands/deck.toml
  5) agents     AGENTS.md pointer (Cursor/Windsurf/Copilot/Aider/Continue)
  6) all        claude + codex + opencode
  7) manual     just print the folder path to copy yourself
EOF
    printf "Choice [1-7]: "
    read -r choice
    case "$choice" in
        1) echo claude ;; 2) echo codex ;; 3) echo opencode ;;
        4) echo gemini ;; 5) echo agents ;; 6) echo all ;; 7) echo manual ;;
        *) echo "error: invalid choice" >&2; exit 1 ;;
    esac
}

if [ -z "$TARGET" ]; then
    if [ -t 0 ]; then TARGET="$(interactive_menu)"; else TARGET="claude"; fi
fi

if [ "$CHECK" = true ]; then
    run_check "$TARGET"
    exit $?
fi

# Probe runtime deps for any target that actually installs the skill.
[ "$TARGET" != "manual" ] && probe_deps

run_install "$TARGET"
