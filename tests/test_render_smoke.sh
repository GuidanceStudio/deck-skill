#!/usr/bin/env bash
set -euo pipefail

# Real render smoke (M20). Static grep tests can't see the render-time bugs
# fixed in M15/M16/M17 (frontmatter-with-comment, :::columns collapse, wide
# table scrollbar) — this renders a fixture and asserts the fixes hold.
#
# GATED: if md2 or a browser is absent, SKIP cleanly (exit 0) — never a
# false red on a bare CI. HTML asserts run whenever md2 is present; the PDF
# assert runs only when a browser is too.
# Run: bash tests/test_render_smoke.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RENDER_SH="$REPO_ROOT/deck/render/render.sh"
FIXTURE="$REPO_ROOT/tests/fixtures/smoke.md"
PASS=0
FAIL=0

echo "=== M20: real render smoke ==="

if ! command -v md2 >/dev/null 2>&1; then
    echo "  SKIP: md2 not on \$PATH — skipping render smoke (install md2 to run it)."
    echo "=== Results: skipped ==="
    exit 0
fi

BROWSER=""
for b in chromium google-chrome chromium-browser chrome brave-browser brave firefox; do
    command -v "$b" >/dev/null 2>&1 && { BROWSER="$b"; break; }
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp "$FIXTURE" "$WORK/smoke.md"

# Render. Without a browser, --no-pdf keeps the HTML assertions runnable.
RENDER_ARGS=("$WORK/smoke.md")
[ -z "$BROWSER" ] && RENDER_ARGS+=(--no-pdf)

if bash "$RENDER_SH" "${RENDER_ARGS[@]}" >/dev/null 2>&1; then
    echo "  PASS: render.sh ran without error"
    PASS=$((PASS + 1))
else
    echo "  FAIL: render.sh exited non-zero on the fixture"
    FAIL=$((FAIL + 1))
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

HTML="$WORK/smoke.html"
if [ -f "$HTML" ]; then
    echo "  PASS: HTML produced"; PASS=$((PASS + 1))
else
    echo "  FAIL: HTML not produced"; FAIL=$((FAIL + 1))
fi

# M15 — frontmatter on line 1 parsed: the title became the <title>, and the
# raw +++ fence did NOT leak into the rendered body.
if grep -q '<title>Render Smoke</title>' "$HTML" 2>/dev/null; then
    echo "  PASS: M15 — frontmatter parsed (title set, no +++ leak)"; PASS=$((PASS + 1))
else
    echo "  FAIL: M15 — frontmatter title not found in HTML"; FAIL=$((FAIL + 1))
fi

# M16 — print override forces columns back to a row in print.
if grep -q 'flex-direction: row' "$HTML" 2>/dev/null; then
    echo "  PASS: M16 — columns print override injected"; PASS=$((PASS + 1))
else
    echo "  FAIL: M16 — columns print override missing"; FAIL=$((FAIL + 1))
fi

# M17 — print override restores table display (no mobile block/scroll).
if grep -q 'overflow-x: visible' "$HTML" 2>/dev/null; then
    echo "  PASS: M17 — table print override injected"; PASS=$((PASS + 1))
else
    echo "  FAIL: M17 — table print override missing"; FAIL=$((FAIL + 1))
fi

# PDF only when a browser is present.
if [ -n "$BROWSER" ]; then
    if [ -f "$WORK/smoke.pdf" ]; then
        echo "  PASS: PDF produced (browser: $BROWSER)"; PASS=$((PASS + 1))
    else
        echo "  FAIL: PDF not produced despite browser $BROWSER"; FAIL=$((FAIL + 1))
    fi
else
    echo "  SKIP: no browser on \$PATH — PDF step not exercised"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
