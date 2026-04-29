# Print constraints

These are the rules that prevent the recurring bugs we hit when md2 decks are exported to PDF (Chrome print or `Ctrl+P` → Save as PDF). They were derived from real iterations on real decks; each one fixes a specific failure mode we observed.

When in doubt, follow them. They prefer page-correctness over information density.

---

## 1. One chart per slide

**Rule**: a slide may contain at most one `:::chart` block.

**Why**: charts have `break-inside: avoid` in md2's print CSS. If a chart and other heavy content (long paragraph, table, second chart) compete for space on the page and the total exceeds one print page, the chart gets pushed to the next page entirely — leaving the previous page half-empty and producing a "ghost slide" that's just the chart with no header.

**Fix when violated**: split into two slides. The first carries the context/setup; the second carries the chart with a 1-line caption.

---

## 2. Chart slides: max 1-2 short lines of description

**Rule**: alongside a chart, the only allowed text is the slide's `## H2` and at most 1-2 short sentences (≈ 30-50 words combined).

**Why**: Chrome's print engine sizes the chart based on viewport units (`vh`); if the surrounding text pushes it past one printed page, see rule 1. Tested empirically: more than ~50 words next to a default-size chart triggers an overflow on standard letter/A4 paper.

**Fix when violated**: move the longer explanation to a follow-up slide (the "reading" slide pattern is fine: H2 + paragraph + blockquote, no chart).

---

## 3. Pie charts: standalone or near-standalone

**Rule**: a slide containing a `:::chart pie` should have the H2 + at most 1 short line of description. No blockquotes, no other content.

**Why**: pie charts size themselves to `min(50vh, 50vw)` and include a horizontal legend below. They occupy roughly half the printed page on their own. Add anything more than a 1-liner above and the pie gets pushed.

**Fix when violated**: move the description to the previous slide as setup. Keep the pie slide minimal.

---

## 4. Bar/column charts: avoid value ratios > 10x

**Rule**: in a single bar or column chart, the largest value should be at most ~10x the smallest. Above that, the smaller bars become unreadable and their data labels get clipped or rendered vertically as individual digits ("3 5 0" stacked).

**Why**: Charts.css uses linear scales; there's no log option. A 50000:350 ratio (143x) renders the 350 as a sliver narrower than its label, so the label wraps character-by-character.

**Fixes when violated**:
- Split into two charts (e.g., one for the macro values, one for the micro).
- Convert to **percentages of a base** (e.g., "% of TAM").
- Move the smallest values to text below the chart, keeping only the comparable values in the visualization.
- Drop the smallest value entirely if it doesn't carry the message.

---

## 5. Tables can carry more than charts

**Rule**: a slide with a markdown table may also include a 2-line `> blockquote` takeaway below it, plus a 1-2 sentence intro above. This is fine.

**Why**: tables compress more than charts; they don't have viewport-unit sizing and they break across pages cleanly if needed (md2's print CSS preserves the colored header on each break).

**Fix when violated**: tables rarely violate. If a table is so long it spans 2 pages, consider whether you really need every row or if a summary row + appendix would be better.

---

## 6. Avoid empty / sparse slides

**Rule**: every slide must carry roughly 1/3 to 2/3 of the printable area in content. Slides with one short bullet and 80% blank space waste real estate and look like placeholders.

**Why**: short slides feel unfinished in print; in live presentation they look like the speaker forgot to fill them in.

**Fix when violated**:
- Merge with the adjacent slide if both are sparse and on the same theme.
- Promote the content to a hero stat or quote pattern (which intentionally use whitespace for emphasis).
- Cut the slide entirely if the content is fluff.

**Exception**: section dividers (pattern 2) are intentionally sparse — they're a visual pause, not a content slide. Limit to 2-3 dividers per deck.

---

## 7. Always `## H2` per slide

**Rule**: every slide must start with a `## H2` heading.

**Why**: md2 falls back to "Slide N" when no H2 is present, which breaks the sidebar nav and makes the deck look unprofessional in print (the H2 is the visible slide title in print).

**Fix when violated**: add the H2. If you can't think of a meaningful H2 for the slide, the slide probably shouldn't exist (see rule 6).

---

## 8. Render → review → adjust loop

After generating `presentation.md`, the `/deck render` step produces both an HTML and a PDF. Open the PDF (not the HTML) and check for:

- Empty bottom halves of pages (rule 6) → compact or merge.
- Charts on lonely pages without their slide title above them (rules 1-3) → reduce text alongside.
- Truncated chart labels, especially on small bars (rule 4) → split or drop the smallest values.
- Sidebar / nav showing "Slide N" entries (rule 7) → add missing H2s.

A v0.2 of this skill plans a `/deck review` step that automates this check; until then, do it by eye.
