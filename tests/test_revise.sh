#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies revise/* contracts (M27 T5/T6).
# Run: bash tests/test_revise.sh
#
# The stage exists because the drafting agent cannot review its own copy. These
# assertions pin the parts that make it a different pass and not a re-read:
# isolation, the five checks, and the fact that it runs after a render.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REVISE="$REPO_ROOT/deck/revise"
DECK="$REPO_ROOT/deck"
PASS=0
FAIL=0

assert_grep() {
    local file="$1" pattern="$2" label="$3"
    if grep -qiE "$pattern" "$file"; then
        echo "  PASS: $(basename "$file") — $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $(basename "$file") — $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

assert_nonempty() {
    local file="$1"
    if [ -s "$file" ]; then
        echo "  PASS: $(basename "$file") is non-empty"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $(basename "$file") is empty or missing"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M27: revise/ exists ==="

assert_nonempty "$REVISE/prompt.md"

echo ""
echo "=== M27: the five checks are all present ==="

assert_grep "$REVISE/prompt.md" 'takeaway'                        "check (a) — the takeaway sentence"
assert_grep "$REVISE/prompt.md" '[Dd]elete test'                  "check (b) — the delete test"
assert_grep "$REVISE/prompt.md" '[Ll]abel test'                   "check (c) — the label test"
assert_grep "$REVISE/prompt.md" '[Dd]ecode test'                  "check (d) — the decode test"
assert_grep "$REVISE/prompt.md" 'budget|overflow|pdfinfo'         "check (e) — the page budget"

echo ""
echo "=== M27: the label test covers row labels, not just headers ==="

assert_grep "$REVISE/prompt.md" 'first-column row label'          "row labels in scope"
assert_grep "$REVISE/prompt.md" 'every slide'                     "checked on every slide, not the first hit"

echo ""
echo "=== M27: the decode test is read from the audience, not the reviewer ==="

assert_grep "$REVISE/prompt.md" 'familiarity is not evidence|not.*your own vocabulary|as the audience' \
    "the reviewer's own vocabulary is not the yardstick"
assert_grep "$REVISE/prompt.md" 'audience vocabulary|## Audience'  "reads the brief's audience block"

echo ""
echo "=== M27: isolation — the reviewer gets the deck, not the reasoning ==="

assert_grep "$REVISE/prompt.md" '[Ii]solation'                     "isolation rule is stated"
assert_grep "$REVISE/prompt.md" 'sub-agent|subagent|fresh'         "prefers a fresh reader"
assert_grep "$REVISE/prompt.md" 'no research notes|not the reasoning|no chat history' \
    "the reasoning is withheld"
assert_grep "$REVISE/prompt.md" 'say so in the report|weaker'      "a self-run pass declares itself weaker"

echo ""
echo "=== M27: runs on the RENDERED deck ==="

assert_grep "$REVISE/prompt.md" 'presentation\.pdf'                "requires the PDF"
assert_grep "$REVISE/prompt.md" 'run .*/deck render. first|render first|stop and run' \
    "stops if the PDF is missing"

echo ""
echo "=== M27: over-budget removes content, never shortens ==="

assert_grep "$REVISE/prompt.md" '[Nn]ever by shortening|never shortens' "no shortening to fit"
assert_grep "$REVISE/prompt.md" '[Dd]efinitions go last|definition.*last' \
    "definitions are the protected class"

echo ""
echo "=== M27: output contract ==="

assert_grep "$REVISE/prompt.md" 'presentation-revision\.md'        "writes the findings file"
assert_grep "$REVISE/prompt.md" 'Slides with no findings'          "clean slides are listed, not omitted"
assert_grep "$REVISE/prompt.md" 'in full|summarized .looks fine.'  "findings are reported in full"

echo ""
echo "=== M27: second-language decks get their own pass ==="

assert_grep "$REVISE/prompt.md" 're-drafted, not translated' "a second language is re-drafted"

echo ""
echo "=== M27 T6: wiring ==="

assert_grep "$DECK/SKILL.md"          'revise'                     "SKILL.md routes revise"
assert_grep "$DECK/SKILL.md"          'revise/prompt\.md'          "SKILL.md points at revise/prompt.md"
assert_grep "$DECK/SKILL.md"          'after .render|not deliverable until' \
    "SKILL.md states the order and the gate"
assert_grep "$DECK/render/prompt.md"  'revise'                     "render hands off to revise"
assert_grep "$DECK/draft/prompt.md"   'revise'                     "draft hands off toward revise"

echo ""
echo "=== M27 T1/T2: copy-rules carries the decode test and the protected class ==="

assert_grep "$DECK/draft/copy-rules.md" '[Ff]ive procedures'       "§0 is five procedures now"
assert_grep "$DECK/draft/copy-rules.md" '\(e\) The decode test'    "procedure (e) exists"
assert_grep "$DECK/draft/copy-rules.md" '[Dd]efinitions are the protected class' \
    "definitions protected under (c)"
assert_grep "$DECK/draft/copy-rules.md" 're-drafted against the facts, not translated' \
    "second-language rule widened past labels"

echo ""
echo "=== M27 T4: the brief captures the audience's vocabulary ==="

assert_grep "$DECK/brief/prompt.md" 'terms does this audience use daily' "vocabulary question asked"
assert_grep "$DECK/brief/prompt.md" 'Vocabulary they use daily'          "template field present"
assert_grep "$DECK/brief/prompt.md" 'have to look up'                    "the look-up list is captured"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
