#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies the project layout (M1 + ongoing).
# Run: bash tests/test_structure.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

assert_file() {
    local path="$1" label="${2:-$1}"
    if [ -f "$REPO_ROOT/$path" ]; then
        echo "  PASS: $label exists"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label missing — expected at $path"
        FAIL=$((FAIL + 1))
    fi
}

assert_nonempty() {
    local path="$1" label="${2:-$1}"
    if [ -s "$REPO_ROOT/$path" ]; then
        echo "  PASS: $label is non-empty"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label is empty"
        FAIL=$((FAIL + 1))
    fi
}

assert_dir() {
    local path="$1" label="${2:-$1}"
    if [ -d "$REPO_ROOT/$path" ]; then
        echo "  PASS: $label/ exists"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label/ missing"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Project layout ==="

# Top-level files
assert_file "README.md"
assert_file "DEVPLAN.md"
assert_file ".gitignore"
assert_file "install.sh"

# Directories
assert_dir "skill"
assert_dir "skill/brief"
assert_dir "skill/draft"
assert_dir "skill/render"
assert_dir "tests"

# Skill files (existence; content tested by other suites)
assert_file "skill/SKILL.md"
assert_file "skill/brief/prompt.md"
assert_file "skill/draft/prompt.md"
assert_file "skill/draft/slide-patterns.md"
assert_file "skill/draft/copy-rules.md"
assert_file "skill/draft/md2-cheatsheet.md"
assert_file "skill/draft/print-constraints.md"
assert_file "skill/render/prompt.md"
assert_file "skill/render/render.sh"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
