#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies render/ contracts (M6).
# Run: bash tests/test_render.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RENDER_SH="$REPO_ROOT/skill/render/render.sh"
PROMPT="$REPO_ROOT/skill/render/prompt.md"
PASS=0
FAIL=0

assert_grep() {
    local file="$1" pattern="$2" label="$3"
    if grep -qE -e "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

assert_grep_i() {
    local file="$1" pattern="$2" label="$3"
    if grep -qiE -e "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M6: render/render.sh ==="

if [ ! -s "$RENDER_SH" ]; then
    echo "  FAIL: render.sh is empty or missing"
    FAIL=$((FAIL + 1))
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

# Static contract checks
assert_grep "$RENDER_SH" '#!/usr/bin/env bash' "shebang line"
assert_grep "$RENDER_SH" 'set -euo pipefail' "strict bash mode"
assert_grep "$RENDER_SH" '\bmd2\b' "invokes md2"
assert_grep "$RENDER_SH" 'chromium|google-chrome|chrome' "probes Chromium-family browser"
assert_grep "$RENDER_SH" '--print-to-pdf|--headless' "uses Chrome headless print-to-pdf"
assert_grep "$RENDER_SH" '\.html\b' "produces HTML"
assert_grep "$RENDER_SH" '\.pdf\b' "produces PDF"
assert_grep "$RENDER_SH" '--no-pdf|--html-only|skip.pdf' "supports flag to skip PDF"

# v0.2 — M10: orientation + paper flags
assert_grep "$RENDER_SH" '\-\-landscape' "supports --landscape flag"
assert_grep "$RENDER_SH" '\-\-portrait' "supports --portrait flag"
assert_grep "$RENDER_SH" '\-\-paper' "supports --paper flag"
assert_grep "$RENDER_SH" 'deck-orientation' "parses deck-orientation HTML comment"
assert_grep "$RENDER_SH" 'deck-paper' "parses deck-paper HTML comment"
assert_grep "$RENDER_SH" '@page' "injects @page CSS rule"

# Executable
if [ -x "$RENDER_SH" ]; then
    echo "  PASS: render.sh is executable"
    PASS=$((PASS + 1))
else
    echo "  FAIL: render.sh is not executable (chmod +x)"
    FAIL=$((FAIL + 1))
fi

# Behavioral checks: run the script with various conditions and check exit codes
echo ""
echo "--- Behavioral ---"

TMPDIR_T="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_T"' EXIT

# Test: missing input file → non-zero exit
if "$RENDER_SH" "$TMPDIR_T/does-not-exist.md" 2>/dev/null; then
    echo "  FAIL: render.sh should fail when input file is missing"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: render.sh fails on missing input"
    PASS=$((PASS + 1))
fi

# Test: no argument → non-zero exit
if "$RENDER_SH" 2>/dev/null; then
    echo "  FAIL: render.sh should fail when called with no argument"
    FAIL=$((FAIL + 1))
else
    echo "  PASS: render.sh fails when called with no argument"
    PASS=$((PASS + 1))
fi

# v0.2 — Behavioral: @page CSS injection from HTML comments
if command -v md2 >/dev/null 2>&1; then
    DECK_LANDSCAPE="$TMPDIR_T/deck-landscape.md"
    cat > "$DECK_LANDSCAPE" <<'DECK'
<!-- deck-orientation: landscape -->
<!-- deck-paper: A4 -->
+++
title = "Landscape Test"
+++

# Landscape Test

---

## A slide

Body.
DECK
    if "$RENDER_SH" "$DECK_LANDSCAPE" --no-pdf >/dev/null 2>&1; then
        if grep -qE '@page[[:space:]]*\{[^}]*A4[[:space:]]+landscape' "$TMPDIR_T/deck-landscape.html"; then
            echo "  PASS: HTML contains @page rule with 'A4 landscape' from comment"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: HTML missing @page rule with A4 landscape"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: render.sh --no-pdf failed on landscape deck"
        FAIL=$((FAIL + 1))
    fi

    DECK_PORTRAIT="$TMPDIR_T/deck-portrait.md"
    cat > "$DECK_PORTRAIT" <<'DECK'
<!-- deck-orientation: portrait -->
<!-- deck-paper: letter -->
+++
title = "Portrait Test"
+++

# Portrait Test

---

## A slide

Body.
DECK
    if "$RENDER_SH" "$DECK_PORTRAIT" --no-pdf >/dev/null 2>&1; then
        if grep -qE '@page[[:space:]]*\{[^}]*letter[[:space:]]+portrait' "$TMPDIR_T/deck-portrait.html"; then
            echo "  PASS: HTML contains @page rule with 'letter portrait' from comment"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: HTML missing @page rule with letter portrait"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: render.sh --no-pdf failed on portrait deck"
        FAIL=$((FAIL + 1))
    fi

    # CLI override beats comment
    DECK_OVERRIDE="$TMPDIR_T/deck-override.md"
    cat > "$DECK_OVERRIDE" <<'DECK'
<!-- deck-orientation: portrait -->
<!-- deck-paper: A4 -->
+++
title = "Override Test"
+++

# Override Test

---

## A slide

Body.
DECK
    if "$RENDER_SH" "$DECK_OVERRIDE" --landscape --paper letter --no-pdf >/dev/null 2>&1; then
        if grep -qE '@page[[:space:]]*\{[^}]*letter[[:space:]]+landscape' "$TMPDIR_T/deck-override.html"; then
            echo "  PASS: CLI flags override the HTML comment values"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: CLI override should produce 'letter landscape' but didn't"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: render.sh failed when CLI flags applied"
        FAIL=$((FAIL + 1))
    fi

    # Default when no comments + no flags: landscape A4
    DECK_DEFAULT="$TMPDIR_T/deck-default.md"
    cat > "$DECK_DEFAULT" <<'DECK'
+++
title = "Default Test"
+++

# Default Test

---

## A slide

Body.
DECK
    if "$RENDER_SH" "$DECK_DEFAULT" --no-pdf >/dev/null 2>&1; then
        if grep -qE '@page[[:space:]]*\{[^}]*A4[[:space:]]+landscape' "$TMPDIR_T/deck-default.html"; then
            echo "  PASS: default orientation/paper is 'A4 landscape'"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: default should be 'A4 landscape' but isn't"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: render.sh failed on default deck"
        FAIL=$((FAIL + 1))
    fi
else
    echo "  SKIP: behavioral @page tests skipped — md2 not installed"
fi

# Test: missing md2 (simulate via PATH stripping) → non-zero exit + clear message
TEST_MD="$TMPDIR_T/test.md"
echo -e "# Test\n\n---\n\n## Slide\n\nbody" > "$TEST_MD"

# Strip md2 and chromium from PATH; provide minimal PATH for coreutils
EMPTY_PATH="/usr/bin:/bin"
out=$(env PATH="$EMPTY_PATH" "$RENDER_SH" "$TEST_MD" 2>&1 || true)
if echo "$out" | grep -qiE 'md2'; then
    echo "  PASS: error message mentions md2 when missing"
    PASS=$((PASS + 1))
else
    echo "  FAIL: error message should mention md2 when md2 is missing. Got: $out"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== M6: render/prompt.md ==="

if [ ! -s "$PROMPT" ]; then
    echo "  FAIL: prompt.md is empty or missing"
    FAIL=$((FAIL + 1))
else
    assert_grep "$PROMPT" 'render\.sh' "references render.sh"
    assert_grep "$PROMPT" 'presentation\.md' "reads presentation.md"
    assert_grep "$PROMPT" 'presentation\.html' "produces presentation.html"
    assert_grep "$PROMPT" 'presentation\.pdf' "produces presentation.pdf"
    assert_grep_i "$PROMPT" 'current working directory|CWD|cwd' "references CWD"
    assert_grep_i "$PROMPT" 'error|fail|missing|surface' "surfaces errors to user"
    assert_grep_i "$PROMPT" 'SKILL\.md|router' "delegates language to SKILL.md"

    # v0.2 — M11: explicit guardrails to prevent agent improvisation
    assert_grep_i "$PROMPT" 'do not|don.t' "uses 'do not' / 'don't' for forbidden actions"
    assert_grep_i "$PROMPT" 'playwright' "explicitly forbids playwright"
    assert_grep_i "$PROMPT" 'weasyprint' "explicitly forbids weasyprint"
    assert_grep_i "$PROMPT" 'pandoc|wkhtmltopdf|puppeteer' "explicitly forbids other PDF tools"
    assert_grep "$PROMPT" '~/\.claude/skills/deck/render/render\.sh' "shows exact render.sh invocation path"
    assert_grep_i "$PROMPT" 'one job|do not improvise|exactly one' "directive against improvisation"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
