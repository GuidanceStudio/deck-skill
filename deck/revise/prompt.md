# `/deck revise` — read the finished deck as the audience will

> **This stage exists because the author cannot do it.** Not through carelessness — through position. You
> know what you meant, so you read the meaning back into the line whether or not the words carry it.

## What this subcommand does

Read the **rendered** deck, run five checks against it, write the findings to `presentation-revision.md`,
apply the fixes to `presentation.md`, and tell the user to re-render. A deck is not deliverable until this
has run.

## Why this stage exists

The skill used to run `brief` → `draft` → `render`, and nothing between draft and render read the copy
again. Every line was therefore written exactly once — under page pressure, by an author who knew what they
meant.

Measured twice, on the same deck. On 2026-07-27 a client deck shipped with three lines the reader could not
parse; two of them were rewritten on the spot, and **one of the replacements was also unparseable to him.**
Same author, same hour, rule in hand, immediately after being corrected. The conclusion is not that the
author was careless. It is that re-reading your own draft is not a check: you supply the missing meaning
from memory, every time, which is why the reader saw all three lines in seconds and the author saw none.

## Inputs

| File | Required | What you may use it for |
|---|---|---|
| `presentation.md` (CWD) | yes | the copy under review |
| `presentation.pdf` (CWD) | yes | page-fit pressure and the printed reading order |
| `presentation-brief.md` (CWD) | if present | **the `## Audience` block only** |

If `presentation.pdf` is missing, stop and run `/deck render` first — checks (c) and (e) have nothing to
act on without it. If the brief is missing, say so in the report and run check (d) against a stated
assumption about the audience rather than silently against your own vocabulary.

## The isolation rule — read before anything else

**Whoever runs the checks gets the deck and not the reasoning behind it.** No brief beyond the `## Audience`
block, no research notes, no source material, no chat history, no "here is why that slide is there".

Prefer to **spawn a fresh sub-agent** for the five checks, handed exactly the rendered deck, the PDF and the
audience block. If the runtime has no sub-agents, run them yourself — but then say so in the report, because
the pass is weaker by exactly the amount you remember. A self-run pass that finds nothing is not evidence
the deck is clean.

**The audience block is not reasoning.** It says who reads this and what words they have; it says nothing
about why any card is on any slide. Handing over the justification is what turns a review into a review of
our own argument.

## The five checks

Run all five. Go slide by slide, in printed order.

### (a) The takeaway

Per slide, write the one sentence that slide establishes.

- **Cannot be written** → the slide has no takeaway. Merge it into its neighbour, or cut it.
- **Can be written but is not on the slide** → put it on the slide.
- **Written and already there** → done, move on.

### (b) The delete test

For every line that is not a fact: delete it, and ask what the reader no longer knows. If the answer is
nothing, leave it deleted. A line earns its place by telling the reader something they did not know and can
act on.

### (c) The label test

**Column headers and every first-column row label.** Show yourself the label and **one** value under it —
you must be able to say what that value asserts. `Outage? / no` fails: the reader cannot tell whether `no`
means the measurement needs no outage, or the asset is not currently out of service.

Check **every slide**, not the first one you find a problem on. A label fixed on slide 2 survives on slide 3,
because only the header was looked at.

### (d) The decode test

**Name every term the deck uses without defining it** — a method, a standard, a norm article, a material, an
instrument, a unit convention, an acronym — and every line you can only read because you already know the
field.

Test each against the brief's audience vocabulary. Where the brief does not settle it, the term needs its
meaning in the same sentence or the next, the first time it appears.

> **Your own familiarity is not evidence.** You know what XRD, PILC and Mohs are. The audience is a person
> who runs the client's business and has never worked in this supplier market. A line like `The Rietveld
> wants 3–4 g of solids` will not feel like a problem to you, and it is one. When in doubt, define it.

### (e) The budget

Count the pages against the slides:

```bash
pdfinfo presentation.pdf | grep Pages          # expected: 1 cover + one per ## H2
grep -c '^## ' presentation.md
```

A mismatch means at least one slide overflowed. Find which:

```bash
pdftotext -layout presentation.pdf - | awk 'BEGIN{RS="\f"} {p++; split($0,L,"\n"); for(i=1;i<=length(L);i++){ if(L[i] ~ /[A-Za-z]/){ printf "%2d: %s\n", p, substr(L[i],1,70); break } } }'
```

A page whose first line is not a slide title is a spill from the page before it.

**Fix by removing a fact, a row or a whole slide. Never by shortening a sentence.** Compression takes out
information first and cadence last, so a shortened line keeps its shape and loses its content.
**Definitions go last**, and a term that cannot afford its definition is cut along with it.

## Output

Write `presentation-revision.md` in CWD:

```markdown
# Revision pass — <date>

Run by: <fresh sub-agent | the drafting agent, no isolation available>
Audience vocabulary: <from the brief | assumed, stated here>

## Findings

| Slide | Check | Line or label | What is wrong | Fix applied |
|---|---|---|---|---|
| 4 | d | "Rietveld refinement" | names a method the audience does not use | defined inline |
| 7 | c | `Outage?` | value cannot be read from the label | renamed to "Does the line go out of service?" |

## Slides with no findings
<list them by number — a clean slide is a result, not an omission>

## Not fixed, and why
<anything left, with the reason; an empty section is fine and must still be present>
```

Then **apply the fixes to `presentation.md`.**

## Reporting completion

Report to the user, in their language:

- how many slides were checked and how many carried findings;
- the findings themselves, **in full** — a summarized "looks fine" destroys the point of the pass;
- whether isolation was available;
- and that `/deck render` must run again, because the fixes changed the page budget.

**Do not report the deck as finished while a finding is open.** An unresolved finding is the user's call to
waive, not yours.

## Language

Governed by the router (`SKILL.md`). Chat in the user's language; the revision file follows the deck's
artifact language.

**A deck in a second language is re-drafted, not translated, and gets its own revise pass.** The pass on the
source language cannot see a defect the translation has not introduced yet: `outage?` → `Fuori servizio?`
is faithful and worse, and the English pass had already run clean.
