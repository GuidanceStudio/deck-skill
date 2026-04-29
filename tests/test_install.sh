#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies install.sh contracts (M7).
# Run: bash tests/test_install.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
README="$REPO_ROOT/README.md"
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

echo "=== M7: install.sh ==="

if [ ! -s "$INSTALL_SH" ]; then
    echo "  FAIL: install.sh is empty or missing"
    FAIL=$((FAIL + 1))
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

# Static contract checks
assert_grep "$INSTALL_SH" '#!/usr/bin/env bash' "shebang line"
assert_grep "$INSTALL_SH" 'set -euo pipefail' "strict bash mode"
assert_grep "$INSTALL_SH" '\-\-force' "supports --force flag"
assert_grep "$INSTALL_SH" '\-\-help' "supports --help flag"
assert_grep "$INSTALL_SH" '\.claude/skills/deck' "installs to ~/.claude/skills/deck/"
assert_grep "$INSTALL_SH" 'cp -r' "copies skill files (cp -r)"
assert_grep "$INSTALL_SH" 'git clone' "supports remote install via git clone"
assert_grep "$INSTALL_SH" '\bskill\b' "references skill/ source directory"

# Dependency probes (soft check — UX layer)
assert_grep_i "$INSTALL_SH" 'md2' "probes md2 dependency"
assert_grep_i "$INSTALL_SH" 'chromium|chrome|firefox' "probes browser dependency"

# Executable
if [ -x "$INSTALL_SH" ]; then
    echo "  PASS: install.sh is executable"
    PASS=$((PASS + 1))
else
    echo "  FAIL: install.sh is not executable (chmod +x)"
    FAIL=$((FAIL + 1))
fi

# Behavioral: --help should not error
echo ""
echo "--- Behavioral ---"
if "$INSTALL_SH" --help >/dev/null 2>&1; then
    echo "  PASS: --help exits cleanly"
    PASS=$((PASS + 1))
else
    echo "  FAIL: --help should exit 0"
    FAIL=$((FAIL + 1))
fi

# Behavioral: install with --force into a temp HOME
TMPHOME="$(mktemp -d)"
trap 'rm -rf "$TMPHOME"' EXIT

# Run install.sh with HOME pointed at temp; should copy files in non-interactive mode (--force).
if env HOME="$TMPHOME" "$INSTALL_SH" --force >/dev/null 2>&1; then
    if [ -f "$TMPHOME/.claude/skills/deck/SKILL.md" ]; then
        echo "  PASS: install copies SKILL.md to ~/.claude/skills/deck/"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: SKILL.md not copied to expected destination"
        FAIL=$((FAIL + 1))
    fi
    if [ -f "$TMPHOME/.claude/skills/deck/render/render.sh" ]; then
        echo "  PASS: install copies render/render.sh"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: render.sh not copied"
        FAIL=$((FAIL + 1))
    fi
    if [ -x "$TMPHOME/.claude/skills/deck/render/render.sh" ]; then
        echo "  PASS: render.sh remains executable after copy"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: render.sh lost +x bit during copy"
        FAIL=$((FAIL + 1))
    fi
else
    echo "  FAIL: install.sh --force exited non-zero in temp HOME"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== M7: README.md (Requirements section) ==="

if [ ! -s "$README" ]; then
    echo "  FAIL: README.md is empty or missing"
    FAIL=$((FAIL + 1))
else
    assert_grep_i "$README" '^##.*[Rr]equirements' "has Requirements section"
    assert_grep_i "$README" 'md2' "Requirements mentions md2"
    assert_grep_i "$README" 'chromium|google-chrome|chrome|firefox' "Requirements mentions browser"
    assert_grep "$README" '/deck brief' "documents /deck brief"
    assert_grep "$README" '/deck draft' "documents /deck draft"
    assert_grep "$README" '/deck render' "documents /deck render"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
