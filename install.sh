#!/usr/bin/env bash
set -euo pipefail

# deck skill installer
# Copies the skill files into the target tool's skill directory.
#
# Local mode:  ./install.sh [OPTIONS]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/Ymx1ZQ/deck/main/install.sh)

REPO_URL="${DECK_REPO_URL:-https://github.com/Ymx1ZQ/deck.git}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
CLEANUP_DIR=""

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Install the `deck` skill into ~/.claude/skills/deck/.

OPTIONS:
  --force   Overwrite existing installation without prompting; also skip the
            interactive dependency-warning prompt.
  --help    Show this help message

REMOTE INSTALL (no clone needed):
  bash <(curl -fsSL https://raw.githubusercontent.com/Ymx1ZQ/deck/main/install.sh)

ENVIRONMENT:
  DECK_REPO_URL   Override the repo URL used in remote mode
                  (default: https://github.com/Ymx1ZQ/deck.git)

PREREQUISITES (checked at install time as a UX courtesy):
  - md2                                  (markdown → HTML)
  - chromium / google-chrome / firefox    (HTML → PDF)
EOF
}

# --- Parse arguments ---

for arg in "$@"; do
    case "$arg" in
        --force)  FORCE=true ;;
        --help)   usage; exit 0 ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# --- Detect local vs remote mode ---

if [ -d "$SCRIPT_DIR/skill" ]; then
    SRC_ROOT="$SCRIPT_DIR"
else
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is required for remote install." >&2
        exit 1
    fi
    CLEANUP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/deck-install-XXXXXX")"
    echo "Cloning deck into temporary directory..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLEANUP_DIR/repo"
    SRC_ROOT="$CLEANUP_DIR/repo"
    if [ ! -d "$SRC_ROOT/skill" ]; then
        echo "Error: skill/ directory not found in the cloned repo." >&2
        exit 1
    fi
fi

SRC="$SRC_ROOT/skill"
DEST="$HOME/.claude/skills/deck"

# --- Dependency probes (UX layer; not part of the agentskills.io spec) ---

MISSING=()
command -v md2 >/dev/null 2>&1 || MISSING+=("md2")

BROWSER_FOUND=""
for b in chromium google-chrome chromium-browser chrome firefox; do
    if command -v "$b" >/dev/null 2>&1; then
        BROWSER_FOUND="$b"
        break
    fi
done
[ -z "$BROWSER_FOUND" ] && MISSING+=("browser (chromium/chrome/firefox)")

if [ ${#MISSING[@]} -gt 0 ]; then
    echo ""
    echo "Warning — missing dependencies on \$PATH:"
    for m in "${MISSING[@]}"; do
        echo "  - $m"
    done
    echo ""
    echo "See README.md → Requirements for install instructions."
    echo "The skill will install regardless, but /deck render will fail at runtime"
    echo "until the missing dependencies are installed."
    if [ "$FORCE" != true ]; then
        echo ""
        printf "Continue installing? [y/N] "
        read -r reply
        if [[ ! "$reply" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi
fi

# --- Confirm overwrite if not --force ---

if [ -d "$DEST" ] && [ "$FORCE" != true ]; then
    printf "deck skill already exists at %s\nOverwrite? [y/N] " "$DEST"
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# --- Install ---

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -r "$SRC" "$DEST"

# Ensure render.sh is executable (preserves +x but be defensive)
[ -f "$DEST/render/render.sh" ] && chmod +x "$DEST/render/render.sh"

echo ""
echo "Installed deck skill → $DEST"
echo ""
echo "Pipeline (run in the order below, from your project directory):"
echo "  /deck brief   — interview about audience, objective, format, brand;"
echo "                  writes presentation-brief.md"
echo "  /deck draft   — turn the brief into a md2-compliant deck;"
echo "                  writes presentation.md"
echo "  /deck render  — convert the deck to HTML and PDF;"
echo "                  writes presentation.html and presentation.pdf"
echo ""
echo "Run /deck without arguments to see the menu."
