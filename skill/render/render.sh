#!/usr/bin/env bash
# render.sh — convert a md2 markdown deck to HTML and PDF.
#
# Usage:   render.sh <input.md> [--no-pdf]
# Output:  <input>.html and <input>.pdf next to the input file.
#
# Dependencies (must be on $PATH):
#   - md2                  (markdown → HTML)
#   - chromium / google-chrome / chromium-browser / chrome /
#     brave-browser / brave / firefox
#                          (HTML → PDF via headless print-to-pdf;
#                           Chromium-family is preferred for higher fidelity
#                           — chromium and chrome detected first, brave as a
#                           chromium-derivative fallback. Firefox is the
#                           last-resort fallback and may hang on Linux snap
#                           installs; install a chromium-family browser to
#                           avoid that path.)
#
# Flags:
#   --no-pdf            Generate the HTML only, skip the PDF step.
#   --landscape         Force landscape orientation (overrides deck-orientation comment).
#   --portrait          Force portrait orientation (overrides deck-orientation comment).
#   --paper A4|letter   Force paper size (overrides deck-paper comment).
#
# Orientation/paper precedence (highest first):
#   1. CLI flag
#   2. <!-- deck-orientation: ... --> / <!-- deck-paper: ... --> at the top of input.md
#   3. defaults: landscape, A4

set -euo pipefail

# --- Argument parsing -------------------------------------------------------

INPUT=""
NO_PDF=false
ORIENTATION_OVERRIDE=""
PAPER_OVERRIDE=""

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <input.md> [--no-pdf] [--landscape|--portrait] [--paper A4|letter]" >&2
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --no-pdf|--html-only)
            NO_PDF=true
            shift
            ;;
        --landscape)
            ORIENTATION_OVERRIDE="landscape"
            shift
            ;;
        --portrait)
            ORIENTATION_OVERRIDE="portrait"
            shift
            ;;
        --paper)
            shift
            if [ $# -eq 0 ]; then
                echo "Error: --paper requires a value (A4 or letter)" >&2
                exit 1
            fi
            case "$1" in
                A4|a4|letter|Letter|LETTER)
                    PAPER_OVERRIDE="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
                    [ "$PAPER_OVERRIDE" = "a4" ] && PAPER_OVERRIDE="A4"
                    [ "$PAPER_OVERRIDE" = "letter" ] && PAPER_OVERRIDE="letter"
                    ;;
                *)
                    echo "Error: --paper must be A4 or letter (got '$1')" >&2
                    exit 1
                    ;;
            esac
            shift
            ;;
        --help|-h)
            sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            if [ -z "$INPUT" ]; then
                INPUT="$1"
            else
                echo "Error: unexpected argument '$1'" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$INPUT" ]; then
    echo "Error: missing input file. Usage: $(basename "$0") <input.md> [--no-pdf]" >&2
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "Error: input file not found: $INPUT" >&2
    exit 1
fi

# --- Resolve absolute paths -------------------------------------------------

INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
HTML="${INPUT_ABS%.md}.html"
PDF="${INPUT_ABS%.md}.pdf"

# --- Step 1: md → HTML ------------------------------------------------------

if ! command -v md2 >/dev/null 2>&1; then
    cat >&2 <<'EOF'
Error: md2 is not on $PATH.

Install it from the md2 repository, then make sure ~/.local/bin is on $PATH:
  export PATH="$HOME/.local/bin:$PATH"
EOF
    exit 2
fi

md2 "$INPUT_ABS"

if [ ! -f "$HTML" ]; then
    echo "Error: md2 ran but did not produce $HTML" >&2
    exit 2
fi

# --- Step 1.5: inject @page CSS for orientation/paper -----------------------

# Resolve orientation: CLI override → comment in source md → default landscape
ORIENTATION="$ORIENTATION_OVERRIDE"
if [ -z "$ORIENTATION" ]; then
    ORIENTATION="$(grep -m1 -oE 'deck-orientation:[[:space:]]*(landscape|portrait)' "$INPUT_ABS" 2>/dev/null \
        | sed -E 's/.*:[[:space:]]*//' || true)"
fi
[ -z "$ORIENTATION" ] && ORIENTATION="landscape"

# Resolve paper size: CLI override → comment in source md → default A4
PAPER="$PAPER_OVERRIDE"
if [ -z "$PAPER" ]; then
    PAPER="$(grep -m1 -oE 'deck-paper:[[:space:]]*(A4|a4|letter|Letter|LETTER)' "$INPUT_ABS" 2>/dev/null \
        | sed -E 's/.*:[[:space:]]*//' || true)"
    # Normalize case
    case "$PAPER" in
        A4|a4) PAPER="A4" ;;
        letter|Letter|LETTER) PAPER="letter" ;;
    esac
fi
[ -z "$PAPER" ] && PAPER="A4"

# Inject @page rule before </head>. Single substitution; idempotent if rerun
# because md2 regenerates the HTML from scratch each time.
PAGE_CSS="<style>@page { size: ${PAPER} ${ORIENTATION}; margin: 12mm; }</style>"
# Use a non-/ delimiter to avoid escaping the / in </head>
sed -i "s|</head>|${PAGE_CSS}</head>|" "$HTML"

echo "Generated: $HTML"
echo "  Orientation: $ORIENTATION · Paper: $PAPER"

# --- Step 2: HTML → PDF (optional) ------------------------------------------

if $NO_PDF; then
    exit 0
fi

BROWSER=""
BROWSER_FAMILY=""
for cmd in chromium google-chrome chromium-browser chrome brave-browser brave; do
    if command -v "$cmd" >/dev/null 2>&1; then
        BROWSER="$cmd"
        BROWSER_FAMILY="chromium"
        break
    fi
done

if [ -z "$BROWSER" ] && command -v firefox >/dev/null 2>&1; then
    BROWSER="firefox"
    BROWSER_FAMILY="firefox"
    echo "Warning: no chromium-family browser found, falling back to firefox (may hang on Linux snap installs; install chromium/chrome/brave to avoid)." >&2
fi

if [ -z "$BROWSER" ]; then
    cat >&2 <<'EOF'
Error: no supported browser found on $PATH.

Install one of:
  - chromium / chromium-browser / google-chrome / chrome (preferred, higher fidelity)
  - brave-browser / brave (chromium-derivative, also supported)
  - firefox 102+ (last-resort fallback; may hang on Linux snap installs)

On Linux:   apt install chromium-browser   (or distro equivalent)
On macOS:   install Google Chrome from chrome.google.com

Or re-run with --no-pdf to skip the PDF step.
EOF
    exit 3
fi

echo "  Using: $BROWSER ($BROWSER_FAMILY)"

# Headless print-to-pdf. Flags differ per browser family.
if [ "$BROWSER_FAMILY" = "chromium" ]; then
    # --no-sandbox is required on some Linux setups (Docker, restricted users);
    # on others it's a no-op.
    "$BROWSER" \
        --headless \
        --disable-gpu \
        --no-sandbox \
        --no-pdf-header-footer \
        --print-to-pdf="$PDF" \
        "file://$HTML" \
        >/dev/null 2>&1
else
    # Firefox 102+ headless print-to-pdf
    "$BROWSER" \
        --headless \
        --print-to-pdf="$PDF" \
        "file://$HTML" \
        >/dev/null 2>&1
fi

if [ ! -f "$PDF" ]; then
    echo "Error: $BROWSER ran but did not produce $PDF" >&2
    exit 3
fi

echo "Generated: $PDF"
