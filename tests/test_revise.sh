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

# Negative checks read the file as one line, so a phrase wrapped across two
# source lines cannot slip past them.
assert_no_grep() {
    local file="$1" pattern="$2" label="$3"
    if tr '\n' ' ' < "$file" | grep -qiE -e "$pattern"; then
        echo "  FAIL: $(basename "$file") — $label — pattern still present: $pattern"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: $(basename "$file") — $label"
        PASS=$((PASS + 1))
    fi
}

# Order checks: the first line matching $first must come before the first line
# matching $second. A missing match is a FAIL, never a set -e abort.
assert_before() {
    local file="$1" first="$2" second="$3" label="$4" a b
    a=$( { grep -nE "$first" "$file" || true; } | head -1 | cut -d: -f1)
    b=$( { grep -nE "$second" "$file" || true; } | head -1 | cut -d: -f1)
    if [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; then
        echo "  PASS: $(basename "$file") — $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $(basename "$file") — $label — '$first' (line ${a:-none}) not before '$second' (line ${b:-none})"
        FAIL=$((FAIL + 1))
    fi
}

# Section checks read only the lines from the first match of $start up to, not
# including, the next line matching $end.
assert_section_no_grep() {
    local file="$1" start="$2" end="$3" pattern="$4" label="$5"
    if awk -v s="$start" -v e="$end" '$0 ~ s {on=1; print; next} on && $0 ~ e {exit} on' "$file" \
        | grep -qiE -e "$pattern"; then
        echo "  FAIL: $(basename "$file") — $label — pattern present in section: $pattern"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: $(basename "$file") — $label"
        PASS=$((PASS + 1))
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

assert_grep "$DECK/draft/copy-rules.md" '[Ss]even procedures'      "§0 lists every procedure"
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
echo "=== M28: provenance, actor and cover checks ==="

assert_grep "$REVISE/prompt.md" '\(f\) Provenance'                    "check (f) — provenance"
assert_grep "$REVISE/prompt.md" 'our arithmetic|our judgement'        "our own claims are a named source class"
assert_grep "$REVISE/prompt.md" 'Hearsay does not ship'               "hearsay is dropped, not hedged"
assert_grep "$REVISE/prompt.md" 'cost, size or timeline'              "no numbers in the audience's own domain"
assert_grep "$REVISE/prompt.md" 'open every link'                     "links are opened, not assumed"
assert_grep "$REVISE/prompt.md" 'carries the number attributed to it' "the page must carry the figure"
assert_grep "$REVISE/prompt.md" '\(g\) The actor'                     "check (g) — the actor"
assert_grep "$REVISE/prompt.md" 'homework assignment'                 "questions with no subject are flagged"
assert_grep "$REVISE/prompt.md" 'own trade'                           "not explaining the audience their trade"
assert_grep "$REVISE/prompt.md" 'narrates our own process'            "not narrating our process"
assert_grep "$REVISE/prompt.md" '\(h\) The cover'                     "check (h) — the cover"

echo ""
echo "=== M34: the cover check describes the cover md2 prints ==="

assert_grep "$REVISE/prompt.md" 'cover title is the front ?matter .title.' \
    "the cover title is the front matter title"
assert_grep "$REVISE/prompt.md" 'only when .title. is missing[^.]*# H1' \
    "the # H1 is the cover title only when title is missing"
assert_grep "$REVISE/prompt.md" 'H1 that differs from .title. is text that will not be printed' \
    "an H1 different from title is flagged as unprinted text"
assert_grep "$REVISE/prompt.md" 'second heading' \
    "a # line further down the cover prints as a second heading"
assert_no_grep "$REVISE/prompt.md" 'prints? +both' \
    "no claim that the template prints both title and H1"
assert_no_grep "$REVISE/prompt.md" 'must not repeat +the +front ?matter' \
    "repeating title in the H1 is no longer a defect"

echo ""
echo "=== M35: check (i) reads the deck as a sequence, before the line checks ==="

assert_grep "$REVISE/prompt.md" '^### \(i\) The story'                 "check (i) — the story"
assert_grep "$REVISE/prompt.md" 'nine checks'                          "count updated to nine"
assert_no_grep "$REVISE/prompt.md" 'eight checks|Run all eight'        "no stale count of eight"
assert_grep "$REVISE/prompt.md" 'Run \(i\) first'                      "check (i) runs first"
assert_before "$REVISE/prompt.md" '^### \(i\) The story' '^### \(a\) The takeaway' \
    "check (i) is written before check (a)"
assert_grep "$REVISE/prompt.md" 'Read only the slide titles'           "reads the titles first"
assert_grep "$REVISE/prompt.md" 'first quarter of the deck'            "then the first quarter"
assert_grep "$REVISE/prompt.md" 'in your own words'                    "answers in the reviewer's words"

echo ""
echo "=== M35: the answers that M36 kept ==="

assert_grep "$REVISE/prompt.md" 'Which question the deck answers, or which decision' \
    "the question or decision, for a deck that reports no work"
assert_grep "$REVISE/prompt.md" 'when the deck reports on work or an analysis' \
    "the method answers apply only to a deck that reports on work or an analysis"
assert_grep "$REVISE/prompt.md" 'every number that appears in a slide title' \
    "how to read every number in a title"
assert_grep "$REVISE/prompt.md" 'The 3–5 things the reader should know' "the 3–5 conclusions"

echo ""
echo "=== M35: deck-level findings and their fix ==="

assert_grep "$REVISE/prompt.md" 'answers no question the reader has' "an opening number with no question"
assert_grep "$REVISE/prompt.md" 'first result that does not serve the deck.s question' \
    "a first result off the deck's question"
assert_grep "$REVISE/prompt.md" 'score or an index that no earlier slide explains' \
    "a title built on an unexplained score"
assert_grep "$REVISE/prompt.md" 'more than 25% over the brief.s target' "slide count over target by 25%"
assert_grep "$REVISE/prompt.md" 'slide count target under .## Length.' \
    "the slide count target is an allowed input"
assert_grep "$REVISE/prompt.md" 'moving slides or adding one'          "fixed by reordering or adding a slide"

echo ""
echo "=== M35: the revision file carries the story ==="

assert_grep "$REVISE/prompt.md" '^## The story'                        "story section in the output format"
assert_before "$REVISE/prompt.md" '^## The story' '^## Findings' \
    "the story comes before the findings table"
assert_grep "$REVISE/prompt.md" 'leave them as written'                "answers are not corrected afterwards"
assert_grep "$REVISE/prompt.md" '^\| deck \| i \|'                      "deck-level finding row in the table"
assert_grep "$DECK/SKILL.md" '## Audience. block and slide count target' \
    "SKILL.md lists the slide count target as a revise input"

echo ""
echo "=== M36: check (i) asks five answers, method before results ==="

assert_grep "$REVISE/prompt.md" 'Write five answers in your own words' "five answers"
assert_no_grep "$REVISE/prompt.md" 'four answers|any of the four|all four' "no stale count of four"
assert_grep "$REVISE/prompt.md" '\*\*What was done, and to what end\.\*\*' \
    "(1) what was done and to what end"
assert_grep "$REVISE/prompt.md" '\*\*Where the inputs come from and how they were organi[sz]ed\.\*\*' \
    "(2) where the inputs come from and how they were organised"
assert_grep "$REVISE/prompt.md" '\*\*What was asked or measured\.\*\*' "(3) what was asked or measured"
assert_grep "$REVISE/prompt.md" 'only after the first result' \
    "(3) shown only after the first result is a finding"
assert_grep "$REVISE/prompt.md" '\*\*The numbers\.\*\*' "(4) how to read the numbers"
assert_grep "$REVISE/prompt.md" '\*\*The conclusions\.\*\*' "(5) the conclusions"
assert_before "$REVISE/prompt.md" '\*\*What was done, and to what end' '\*\*Where the inputs come from' \
    "answer 1 before answer 2"
assert_before "$REVISE/prompt.md" '\*\*Where the inputs come from' '\*\*What was asked or measured' \
    "answer 2 before answer 3"
assert_before "$REVISE/prompt.md" '\*\*What was asked or measured' '\*\*The numbers' \
    "answer 3 before answer 4"
assert_before "$REVISE/prompt.md" '\*\*The numbers' '\*\*The conclusions' \
    "answer 4 before answer 5"
assert_grep "$REVISE/prompt.md" 'deck-level finding is any of the five that the first quarter does not give you' \
    "a missing or late answer is a deck-level finding"

echo ""
echo "=== M36: the opening does not frame the work from one side ==="

assert_grep "$REVISE/prompt.md" 'presents the subject from one side only' "a one-sided opening is flagged"
assert_grep "$REVISE/prompt.md" 'only its risks or only its benefits' "one side means only risks or only benefits"
assert_grep "$REVISE/prompt.md" 'when the content covers both' "flagged only when the content covers both"
assert_grep "$REVISE/prompt.md" 'slide on what is at stake placed before the slide that says what was done' \
    "a stakes slide before the what-was-done slide is flagged"
assert_grep "$REVISE/prompt.md" 'goes after the slide that says what was done' \
    "the fix puts the stakes slide after what was done"
assert_grep "$REVISE/prompt.md" 'one-sided opening is rewritten' "the fix rewrites a one-sided opening"
assert_section_no_grep "$REVISE/prompt.md" '^### \(i\) The story' '^### \(a\) ' '\b(he|him|his)\b' \
    "check (i) refers to the reader as they"

echo ""
echo "=== M36: the revision file carries the five answers ==="

assert_grep "$REVISE/prompt.md" '^1\. What was done, and to what end'  "answer 1 in the template"
assert_grep "$REVISE/prompt.md" '^2\. Where the inputs come from and how they were organi[sz]ed:' \
    "answer 2 in the template"
assert_grep "$REVISE/prompt.md" '^3\. What was asked or measured:'     "answer 3 in the template"
assert_grep "$REVISE/prompt.md" '^4\. How to read the numbers in the titles:' "answer 4 in the template"
assert_grep "$REVISE/prompt.md" '^5\. Conclusions:'                    "answer 5 in the template"
assert_no_grep "$REVISE/prompt.md" '1\. Question or decision:'        "no stale template line for answer 1"
assert_grep "$REVISE/prompt.md" 'Write the five answers into the revision file' \
    "the five answers go into the revision file"

echo ""
echo "=== M28: copy-rules carries the new procedures and rules ==="

assert_grep "$DECK/draft/copy-rules.md" 'Seven procedures'                  "§0 is seven procedures"
assert_grep "$DECK/draft/copy-rules.md" '\(f\) Provenance'                  "procedure (f)"
assert_grep "$DECK/draft/copy-rules.md" '\(g\) The actor'                   "procedure (g)"
assert_grep "$DECK/draft/copy-rules.md" 'cannot open is half a citation'    "§8 reachability"
assert_grep "$DECK/draft/copy-rules.md" 'not clickable in the printed PDF'  "bare domains do not print as links"
assert_grep "$DECK/draft/copy-rules.md" 'Verify the URL resolves'           "URLs verified before writing"
assert_grep "$DECK/draft/copy-rules.md" 'Not their trade, and not our process' "§11"
assert_grep "$DECK/draft/copy-rules.md" 'Which suppliers appear at all'     "§12"
assert_grep "$DECK/draft/copy-rules.md" 'does not appear'                    "defunct/unfit suppliers are not listed"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
