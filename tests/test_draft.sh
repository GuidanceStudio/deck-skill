#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies draft/* contracts (M4 + M5).
# Run: bash tests/test_draft.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRAFT="$REPO_ROOT/skill/draft"
PASS=0
FAIL=0

assert_grep() {
    local file="$1" pattern="$2" label="$3"
    if grep -qiE "$pattern" "$DRAFT/$file"; then
        echo "  PASS: $file — $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $file — $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

assert_nonempty() {
    local file="$1"
    if [ -s "$DRAFT/$file" ]; then
        echo "  PASS: $file is non-empty"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $file is empty or missing"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M4: draft/ knowledge files ==="

assert_nonempty "slide-patterns.md"
assert_nonempty "copy-rules.md"
assert_nonempty "md2-cheatsheet.md"
assert_nonempty "print-constraints.md"
assert_nonempty "prompt.md"

# --- slide-patterns.md ---
echo ""
echo "--- slide-patterns.md ---"
assert_grep "slide-patterns.md" '\bcover\b' "covers the cover pattern"
assert_grep "slide-patterns.md" 'section divider|section.div' "covers section divider"
assert_grep "slide-patterns.md" 'hero stat|big number|hero number' "covers hero stat"
assert_grep "slide-patterns.md" 'bullet list|bullet[ -]points' "covers bullet list"
assert_grep "slide-patterns.md" 'two[ -]column|compare|columns' "covers two-column compare"
assert_grep "slide-patterns.md" '\bquote\b|testimonial' "covers quote/testimonial"
assert_grep "slide-patterns.md" 'process|steps' "covers process/steps"
assert_grep "slide-patterns.md" 'timeline' "covers timeline"
assert_grep "slide-patterns.md" 'single chart|chart slide' "covers single chart"
assert_grep "slide-patterns.md" 'table' "covers table"
assert_grep "slide-patterns.md" 'diagram|image' "covers diagram/image"
assert_grep "slide-patterns.md" 'people|team' "covers team/people"
assert_grep "slide-patterns.md" 'closing|CTA|next steps' "covers closing/CTA"
assert_grep "slide-patterns.md" ':::chart' "shows :::chart syntax"
assert_grep "slide-patterns.md" ':::columns' "shows :::columns syntax"
assert_grep "slide-patterns.md" 'when (not|to use)|anti-?pattern' "documents when-to-use / anti-patterns"

# --- copy-rules.md ---
echo ""
echo "--- copy-rules.md ---"
assert_grep "copy-rules.md" '\bheadline\b' "covers headline rule"
assert_grep "copy-rules.md" 'punchline|takeaway|conclusion' "headline-as-punchline concept"
assert_grep "copy-rules.md" 'parallel|same verb|same shape' "parallel bullets rule"
assert_grep "copy-rules.md" 'number|concrete|specific' "numbers > adjectives rule"
assert_grep "copy-rules.md" 'one idea|single idea|one message' "one idea per slide"
assert_grep "copy-rules.md" '6x6|6.bullets|6.words|word.limit' "word/bullet ceiling rule"
assert_grep "copy-rules.md" 'banned|avoid|filler|do not|don.t' "banned phrases / filler"
assert_grep "copy-rules.md" 'pyramid|conclusion[- ]first' "pyramid principle / conclusion-first"

# --- md2-cheatsheet.md ---
echo ""
echo "--- md2-cheatsheet.md ---"
assert_grep "md2-cheatsheet.md" '\+\+\+|frontmatter' "documents frontmatter +++ block"
assert_grep "md2-cheatsheet.md" 'palette' "documents palette field"
assert_grep "md2-cheatsheet.md" 'default.*warm.*cool|warm.*cool.*mono|cool.*mono|vivid|pastel' "lists builtin palettes"
assert_grep "md2-cheatsheet.md" ':::chart' "documents :::chart"
assert_grep "md2-cheatsheet.md" '\bbar\b' "chart type: bar"
assert_grep "md2-cheatsheet.md" '\bcolumn\b' "chart type: column"
assert_grep "md2-cheatsheet.md" '\bline\b' "chart type: line"
assert_grep "md2-cheatsheet.md" '\bpie\b' "chart type: pie"
assert_grep "md2-cheatsheet.md" ':::columns' "documents :::columns"
assert_grep "md2-cheatsheet.md" 'H1|# .*cover|# title' "documents H1 cover convention"
assert_grep "md2-cheatsheet.md" 'H2|## .*slide title' "documents H2 slide title convention"
assert_grep "md2-cheatsheet.md" 'footnote|blockquote' "documents footnotes / blockquote"
assert_grep "md2-cheatsheet.md" 'inline HTML|iframe|<img' "documents inline HTML"

# --- print-constraints.md ---
echo ""
echo "--- print-constraints.md ---"
assert_grep "print-constraints.md" 'one chart per slide|single chart' "rule: one chart per slide"
assert_grep "print-constraints.md" 'spill|break|overflow|page.break' "rule: chart spill / page break"
assert_grep "print-constraints.md" 'ratio|10x|10 times' "rule: chart value ratio limit"
assert_grep "print-constraints.md" '\bpie\b' "rule: pie chart sizing"
assert_grep "print-constraints.md" 'word|line|character|character.limit' "word/line limits next to charts"
assert_grep "print-constraints.md" 'table.*takeaway|blockquote.*table|takeaway' "tables + takeaway"
assert_grep "print-constraints.md" 'empty|sparse|short slide' "avoid empty slides"
assert_grep "print-constraints.md" 'H2|## ' "always H2 per slide"

# --- prompt.md (M5: orchestrator) ---
echo ""
echo "--- prompt.md (orchestrator) ---"
assert_grep "prompt.md" 'presentation-brief\.md' "reads presentation-brief.md"
assert_grep "prompt.md" 'presentation\.md' "writes presentation.md"
assert_grep "prompt.md" 'current working directory|CWD|cwd' "references CWD"
assert_grep "prompt.md" 'slide-patterns\.md' "references slide-patterns.md"
assert_grep "prompt.md" 'copy-rules\.md' "references copy-rules.md"
assert_grep "prompt.md" 'md2-cheatsheet\.md' "references md2-cheatsheet.md"
assert_grep "prompt.md" 'print-constraints\.md' "references print-constraints.md"
assert_grep "prompt.md" 'pyramid|SCQA|3-act|narrative arc|narrative' "proposes narrative arc / framework"
assert_grep "prompt.md" 'gap|missing|content gather|fill' "fills content gaps from brief"
assert_grep "prompt.md" 'lazy|on demand|when needed' "lazy-load knowledge files"
assert_grep "prompt.md" 'SKILL\.md|router' "delegates language to SKILL.md"
assert_grep "prompt.md" 'frontmatter|\+\+\+' "writes md2 frontmatter"

# v0.2 — M10: emits deck-orientation / deck-paper HTML comments
assert_grep "prompt.md" 'deck-orientation' "emits deck-orientation HTML comment"
assert_grep "prompt.md" 'deck-paper' "emits deck-paper HTML comment"

# v0.2 — M12: Gotchas + self-validation
assert_grep "prompt.md" '[Gg]otchas' "has a Gotchas section"
assert_grep "prompt.md" '\+\+\+.*---|TOML.*YAML|frontmatter.*\+\+\+' "warns about +++ (TOML) vs --- (YAML)"
assert_grep "prompt.md" 'blank line' "warns about blank lines around separators/directives"
assert_grep "prompt.md" '[Ss]elf-validation|run md2|md2 .*verify' "self-validation step (run md2)"
assert_grep "prompt.md" 'retr(y|ies)|fix.*re-run|max.*retries' "retry on md2 error"

# md2-cheatsheet.md callout about +++ vs ---
assert_grep "md2-cheatsheet.md" '\+\+\+.*---|TOML.*YAML|NOT.*---' "callout: +++ (TOML) NOT --- (YAML)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
