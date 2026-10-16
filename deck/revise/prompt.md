# `/deck revise` — read the finished deck as the audience will

> **This stage exists because the author cannot do it.** Not through carelessness — through position. You
> know what you meant, so you read the meaning back into the line whether or not the words carry it.

## What this subcommand does

Read the **rendered** deck, run nine checks against it, write the findings to `presentation-revision.md`,
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
| `presentation-brief.md` (CWD) | if present | **the `## Audience` block and the slide count target under `## Length`, nothing else** |

If `presentation.pdf` is missing, stop and run `/deck render` first — checks (c) and (e) have nothing to
act on without it. If the brief is missing, say so in the report and run check (d) against a stated
assumption about the audience rather than silently against your own vocabulary.

## The isolation rule — read before anything else

**Whoever runs the checks gets the deck and not the reasoning behind it.** No brief beyond the `## Audience`
block and the slide count target, no research notes, no source material, no chat history, no "here is why
that slide is there".

Prefer to **spawn a fresh sub-agent** for the nine checks, handed exactly the rendered deck, the PDF, the
audience block and the slide count target. If the runtime has no sub-agents, run them yourself — but then
say so in the report, because the pass is weaker by exactly the amount you remember. A self-run pass that
finds nothing is not evidence the deck is clean.

**The audience block is not reasoning.** It says who reads this and what words they have; it says nothing
about why any card is on any slide. The slide count target is a number that check (i) measures the deck
against. Handing over the justification is what turns a review into a review of our own argument.

## The nine checks

Run all nine. **Run (i) first**, on the deck as a whole, before any other check: once you have read the slides
closely, you fill in what the opening leaves out, as the author does. Then run (a)–(h) slide by slide, in
printed order.

### (i) The story

Checks (a)–(h) read one line or one slide at a time, so a deck of correct slides in an order the reader cannot
follow passes all of them. Measured 2026-10-16: on a 54-page deck the line checks reported 33 findings and
passed pages 2–8. The reader then said the deck opened on numbers of little use to him, never stated the
research question or how the analysis was structured and why, and gave the most weight to a score whose
construction it never explained.

1. **Read only the slide titles**, in printed order:

   ```bash
   grep '^## ' presentation.md
   ```

2. **Then read the first quarter of the deck**: PDF pages 1 to ⌈pages ÷ 4⌉, which is pages 1–14 of a
   54-page deck. Stop there.
3. **Write four answers in your own words**, from what you have read and from nothing else:
   1. **The question.** Which question the deck answers, or which decision it asks the reader to take.
   2. **The method.** How the content was produced and why it was produced that way: for an analysis, what
      was measured or asked, of whom or of what, how many, and why that design; for a report on work, what
      was done and why that way. Write it when the deck reports on work or an analysis; for any other deck,
      mark it as not applicable.
   3. **The numbers.** For every number that appears in a slide title: what it counts or measures, its unit
      or scale, and which direction is better.
   4. **The conclusions.** The 3–5 things the reader should know at the end, one sentence each.

   Name the page each answer comes from. If you drafted the deck yourself, you already know all four: write
   only what the titles and the first quarter state.

**A deck-level finding is any of the four that the first quarter does not give you**: one you cannot write at
all, or one you could write only from a title further on. While running (a)–(h), look for each of these in the
rest of the deck and record the page where it first appears, or that it appears nowhere.

**Also flag, as deck-level findings:**

- a number in the opening pages that answers no question the reader has at that point;
- a first result that does not serve the deck's question, such as a ranking or a detail shown before the
  answer;
- a title built on a score or an index that no earlier slide explains: what it combines, its scale, and what
  a high value means;
- a slide count more than 25% over the brief's target, which is more than 25 slides against a target of 20.
  Without a target in the brief, this item does not apply.

**Fix deck-level findings by moving slides or adding one**, in `presentation.md`: the question, the method and
how to read each score go before the first result, and the conclusions go inside the first quarter. An added
slide changes the page count that (e) checks.

Write the four answers into the revision file's `## The story` section before reading the rest of the deck,
and leave them as written: they record what the opening tells a reader.

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

**Then scan for soft wraps — a line the renderer broke, not the author** (`print-constraints.md` rule
10). Compare the rendered lines against the markdown source lines: a rendered line that is a proper
prefix of a source line, with the continuation on the next rendered line, is a soft wrap. Fix by
hand-breaking the source line at a phrase boundary or by removing words from it — never by accepting the
renderer's break point. Check titles, subtitles, body lines, bullets and blockquotes with the
comparison, and table headers and row labels by eye: the comparison cannot see inside table cells.
Chapter titles render in a monospace font at ~21 characters per line — the tightest ceiling in the deck.

**Fix page overflow by removing a fact, a row or a whole slide. Never by shortening a sentence.** Compression takes out
information first and cadence last, so a shortened line keeps its shape and loses its content.
**Definitions go last**, and a term that cannot afford its definition is cut along with it.

### (f) Provenance

For every number, comparison and conclusion on the slide, name where it came from: the vendor · a norm,
register or public record · a primary source we read · **our arithmetic** · **our judgement** · hearsay.

- The first three are stated plainly.
- Our arithmetic and our judgement must be **labelled as ours inside the sentence**. If a slide shows an
  estimate, an extrapolation or an inference in the same voice as a published figure, flag it.
- Hearsay does not ship. If a claim about a third party cannot be sourced, it comes out.
- **Any cost, size or timeline inside the audience's own domain is a defect unless it was read somewhere.**

**Then open every link and check that the page carries the number attributed to it.** This is the check
that catches the most, and it cannot be done from the markdown. Measured 2026-07-29 on one deck: of the
suppliers the reader would actually contact, most carried a figure the linked page did not contain — a
reach quoted as 16 km where the vendor page said 2–15 km, an installed base of 3 300 where the cited
page said 3 100, accuracy figures on pages that never mention accuracy, and a published-literature
citation whose paper **contradicted** the claim it was cited for. A technical readership clicks.

### (g) The actor

Every open question, every imperative and every "we": name who acts. A list of questions with no subject
is a homework assignment. If we will get the answer, the slide says so; if it belongs to the reader's own
commercial conversation, the slide says that instead.

Also flag: anything that explains the audience their own trade, and any sentence that narrates our own process, effort, corrections or diligence. Both are writing about the wrong subject.

### (h) The cover

The cover title is the front matter `title`; only when `title` is missing is it the `# H1` on the
first line of the cover. Check that this title names the subject.

**An H1 that differs from `title` is text that will not be printed**: md2 drops the cover's first `# `
line whenever `title` is set, in every template. Flag it, decide which wording is right, put it in
`title`, and make the H1 identical to it. A `# ` line further down the cover stays in the cover text and
prints as a second heading under the title: flag it too, and move its words into `title` or the subtitle
paragraph.

## Output

Write `presentation-revision.md` in CWD:

```markdown
# Revision pass — <date>

Run by: <fresh sub-agent | the drafting agent, no isolation available>
Audience vocabulary: <from the brief | assumed, stated here>

## The story

From the titles and pages 1–<N> only, in the reviewer's words, as written before the line checks:

1. Question or decision: <answer> (p. <n>) | cannot be written
2. How the content was produced, and why: <answer> (p. <n>) | cannot be written | not applicable
3. How to read the numbers in the titles: <one line per number: what it measures, unit or scale, which
   direction is better> (p. <n>) | cannot be written for <number>
4. Conclusions: <3–5 sentences> (p. <n>) | cannot be written

## Findings

| Slide | Check | Line or label | What is wrong | Fix applied |
|---|---|---|---|---|
| deck | i | "Supplier index 72/100" (title, slide 3) | the index is first explained on slide 31 | slide explaining the index moved before slide 3 |
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
