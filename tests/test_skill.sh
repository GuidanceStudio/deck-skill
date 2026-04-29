#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies SKILL.md contracts (M2).
# Run: bash tests/test_skill.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_MD="$REPO_ROOT/skill/SKILL.md"
PASS=0
FAIL=0

assert_grep() {
    local pattern="$1" label="$2" file="${3:-$SKILL_MD}"
    if grep -qE "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

assert_frontmatter() {
    local first_fence second_fence
    first_fence=$(head -1 "$SKILL_MD")
    if [ "$first_fence" != "---" ]; then
        echo "  FAIL: frontmatter must start with --- on line 1"
        FAIL=$((FAIL + 1))
        return
    fi
    echo "  PASS: frontmatter opens with ---"
    PASS=$((PASS + 1))

    second_fence=$(awk 'NR>1 && /^---$/{print NR; exit}' "$SKILL_MD")
    if [ -z "$second_fence" ]; then
        echo "  FAIL: frontmatter has no closing ---"
        FAIL=$((FAIL + 1))
        return
    fi
    echo "  PASS: frontmatter closes with ---"
    PASS=$((PASS + 1))

    local fm
    fm=$(sed -n "2,$((second_fence - 1))p" "$SKILL_MD")

    # name: deck (lowercase, no hyphens at edges, no consecutive hyphens) — agentskills.io spec
    if echo "$fm" | grep -qE '^name:[[:space:]]*deck[[:space:]]*$'; then
        echo "  PASS: frontmatter declares name: deck"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: frontmatter missing 'name: deck'"
        FAIL=$((FAIL + 1))
    fi

    # description: non-empty, ≤1024 chars (agentskills.io spec)
    local desc
    desc=$(echo "$fm" | sed -n 's/^description:[[:space:]]*\(.*\)$/\1/p')
    if [ -n "$desc" ]; then
        echo "  PASS: frontmatter declares non-empty description"
        PASS=$((PASS + 1))
        if [ "${#desc}" -le 1024 ]; then
            echo "  PASS: description within 1024 char limit (${#desc} chars)"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: description exceeds 1024 chars (${#desc})"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: frontmatter missing description"
        FAIL=$((FAIL + 1))
    fi

    # compatibility: present, ≤500 chars (agentskills.io spec, optional but required for our skill)
    local compat
    compat=$(echo "$fm" | sed -n 's/^compatibility:[[:space:]]*\(.*\)$/\1/p')
    if [ -n "$compat" ]; then
        echo "  PASS: frontmatter declares compatibility"
        PASS=$((PASS + 1))
        if [ "${#compat}" -le 500 ]; then
            echo "  PASS: compatibility within 500 char limit (${#compat} chars)"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: compatibility exceeds 500 chars (${#compat})"
            FAIL=$((FAIL + 1))
        fi
        if echo "$compat" | grep -qiE 'md2'; then
            echo "  PASS: compatibility mentions md2"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: compatibility must mention md2"
            FAIL=$((FAIL + 1))
        fi
        if echo "$compat" | grep -qiE 'chrom'; then
            echo "  PASS: compatibility mentions Chromium-family browser"
            PASS=$((PASS + 1))
        else
            echo "  FAIL: compatibility must mention Chromium browser"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "  FAIL: frontmatter missing compatibility"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M2: SKILL.md ==="

if [ ! -s "$SKILL_MD" ]; then
    echo "  FAIL: SKILL.md is empty or missing"
    FAIL=$((FAIL + 1))
    echo ""
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

assert_frontmatter

# Body has Prerequisites section
assert_grep '^##[[:space:]]+[Pp]rerequisites' "body has ## Prerequisites section"

# Language rules
assert_grep '[Ll]anguage' "body mentions language"
assert_grep '[Cc]hat' "body mentions chat language rule"
assert_grep '[Aa]rtifact' "body mentions artifact language rule"
assert_grep '[Ee]nglish' "body mentions English default"

# Routing — each subcommand must be explicitly routed
assert_grep '\bbrief\b' "routes brief"
assert_grep '\bdraft\b' "routes draft"
assert_grep '\brender\b' "routes render"
assert_grep 'brief/prompt\.md' "points to brief/prompt.md"
assert_grep 'draft/prompt\.md' "points to draft/prompt.md"
assert_grep 'render/prompt\.md' "points to render/prompt.md"

# Fallback for missing / unknown arg
assert_grep '[Nn]o arg|no argument|missing|unknown|menu' "handles missing/unknown arg"

# Pipeline artifact filenames
assert_grep 'presentation-brief\.md' "mentions presentation-brief.md artifact"
assert_grep 'presentation\.md' "mentions presentation.md artifact"
assert_grep 'presentation\.(html|pdf)' "mentions presentation.html or .pdf artifact"

# CWD reference
assert_grep '[Cc]urrent working directory|CWD|cwd' "references CWD for artifacts"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
