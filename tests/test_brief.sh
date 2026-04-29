#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies brief/prompt.md contracts (M3).
# Run: bash tests/test_brief.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="$REPO_ROOT/skill/brief/prompt.md"
PASS=0
FAIL=0

assert_grep() {
    local pattern="$1" label="$2"
    if grep -qiE "$pattern" "$PROMPT"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M3: brief/prompt.md ==="

if [ ! -s "$PROMPT" ]; then
    echo "  FAIL: brief/prompt.md is empty or missing"
    FAIL=$((FAIL + 1))
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

# Interview axes (each must be explicitly covered)
assert_grep '\baudience\b' "interview covers audience"
assert_grep '\bobjective\b|\bgoal\b' "interview covers objective/goal"
assert_grep '\bformat\b' "interview covers format (deck vs leave-behind)"
assert_grep 'leave-behind|presented|live deck' "format distinguishes presented vs leave-behind"
assert_grep '\blength\b|\bslide count\b|\btime\b' "interview covers length budget"
assert_grep '\bbrand\b|\bpalette\b' "interview covers brand/palette"
assert_grep '\bcontent\b|\bdata\b|\bclaim\b|\bsource\b' "interview gathers hard content/data/sources"
assert_grep '\btone\b' "interview covers tone"
assert_grep '\blanguage\b' "interview covers language"

# Output contract
assert_grep 'presentation-brief\.md' "declares output filename presentation-brief.md"
assert_grep 'current working directory|CWD|cwd' "references CWD"

# Language delegation to SKILL.md
assert_grep 'SKILL\.md|router' "delegates language to SKILL.md / router"

# Output template structure
assert_grep 'template|structure|sections|schema' "describes output template/structure"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
