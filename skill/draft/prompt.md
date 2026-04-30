# `/deck draft` — Presentation Writer

## What this subcommand does

Read `presentation-brief.md` from the **current working directory** (CWD), fill any remaining content gaps, propose a narrative arc, map each beat to a slide pattern, then write a single artifact — `presentation.md` — to CWD. The output is md2-compliant markdown ready for `/deck render`.

## Inputs

- `presentation-brief.md` in CWD (produced by `/deck brief`).
- Optional follow-up answers from the user during gap-filling.

If `presentation-brief.md` is missing, stop and offer the user two paths:
1. Run `/deck brief` first.
2. Paste the brief content inline so we can proceed.

Never invent the brief silently.

## Output

A single file in CWD: `presentation.md`. If a file with the same name already exists, ask the user whether to overwrite, append, or write to a different filename. Never silently overwrite.

## Language

Language behavior is governed by the router (`SKILL.md`). Briefly: chat in the user's language, the artifact defaults to English unless the brief specified otherwise (the `## Brand → Artifact language` field of the brief is the source of truth).

## Knowledge files

This subcommand has four reference files in the same directory. **Load them lazily, on demand, only when relevant** — do not pre-load all of them up front.

| File                          | When to load                                                          |
|-------------------------------|----------------------------------------------------------------------|
| `slide-patterns.md`           | When choosing a slide pattern for a beat or writing a slide block.    |
| `copy-rules.md`               | When writing or revising slide copy (headlines, bullets, captions).    |
| `md2-cheatsheet.md`           | When writing md2 syntax (frontmatter, charts, columns, etc.).          |
| `print-constraints.md`        | When sizing content per slide (chart slides, pie sizing, table limits).|

These files are the source of truth for their respective domains. Don't paraphrase; quote or apply their rules directly.

## Procedure

### Step 1 — Read the brief

Read `presentation-brief.md`. Map each section to your working memory:
- Audience → drives tone, density, what to leave implicit.
- Objective → drives the narrative arc (next step).
- Format → drives slide density (presented vs leave-behind).
- Length budget → drives slide count.
- Brand → drives palette and language.
- Hard content → drives what *must* appear in the deck.
- Tone → drives word choice and sentence shape.

### Step 2 — Fill content gaps

Compare the brief against what the deck needs. Common gaps:
- Numbers mentioned in the brief but no source provided.
- Claims with no supporting data.
- An objective of "decide" or "approve" without a stated ask.
- Visuals referenced ("we have a chart of X") but no path/data given.

Ask **targeted** follow-up questions only for the gaps. Don't re-run the full interview. Two or three pointed questions are enough; if the user says "make it up", capture that decision and proceed.

### Step 3 — Propose a narrative arc

Choose a framework based on the objective. Present the arc to the user as a **1-line outline** (one bullet per slide, headline-as-punchline) before writing any markdown. Wait for the user's go-ahead or revisions.

| Objective class    | First-choice framework                                          |
|--------------------|----------------------------------------------------------------|
| Decide / Approve   | **Pyramid** (Minto): conclusion first, then 3 supporting groups |
| Persuade           | **SCQA** (Situation → Complication → Question → Answer)         |
| Update / Inform    | **3-act**: where we were → what changed → what's next           |
| Teach              | **Problem → Solution → Application**                            |

The narrative is a sequence of beats. A "beat" is one chunk of message; it usually maps to one slide, occasionally two.

### Step 4 — Map beats to slide patterns

For each beat in the outline, choose a slide pattern from `slide-patterns.md`. Use the *Quick selection guide* table at the end of that file as a starter.

Sanity checks:
- Cover (pattern 1) is always slide 1.
- Closing/CTA (pattern 13) is always the last slide.
- Section dividers (pattern 2) appear at most 2-3 times, only between major narrative blocks.
- Hero stats (pattern 3) appear at most 1-2 times, on the strongest numbers.

If two adjacent beats both want the same pattern, consider whether they should merge.

### Step 5 — Write `presentation.md`

Apply the rules from the knowledge files as you write:

- **Orientation comments**: at the very top of the file (BEFORE the `+++` frontmatter), emit two HTML comments preserving the brief's choice:

  ```markdown
  <!-- deck-orientation: landscape -->
  <!-- deck-paper: A4 -->
  ```

  These are read by `render.sh` to inject the right `@page` CSS at PDF time. md2 ignores HTML comments, so they don't affect the slides themselves. Use the values from the brief's `## Format → Orientation` and `## Format → Paper size` fields. If the brief is silent, default to `landscape` and `A4`.

- **Frontmatter**: write the `+++` TOML block AFTER the orientation comments, with `title`, `palette` (from brief), `lang` (from brief), and optional `dark`. See `md2-cheatsheet.md` for fields.
- **Cover**: pattern 1, with the title as a punchline (apply `copy-rules.md` rule 10).
- **Slide titles**: every `## H2` is a takeaway (`copy-rules.md` rule 1). Test each: could it appear unchanged on a different deck? If yes, rewrite.
- **Bullet density**: max 6 bullets, max ~6 words/bullet for presented decks; up to 10-12 words for leave-behind (`copy-rules.md` rule 6).
- **Numbers and sources**: every load-bearing number cites its source inline (`copy-rules.md` rule 8).
- **Chart slides**: at most 1-2 short lines of description alongside the chart. No second chart, no table on the same slide. Pie charts standalone (`print-constraints.md` rules 1-3).
- **Bar/column ratios**: keep largest:smallest ≤ 10x or split the chart (`print-constraints.md` rule 4).
- **No empty slides**: ≥ 1/3 of the page filled. Section dividers exempt (`print-constraints.md` rule 6).
- **Always H2**: never let a slide fall back to "Slide N" in the sidebar (`print-constraints.md` rule 7).

Do not pre-load all knowledge files; load each one when you reach the corresponding writing task.

### Step 6 — Self-check before declaring done

Before reporting completion, run through this checklist:

- [ ] Cover has a punchline title and a 1-line subtitle.
- [ ] Every slide has a `## H2` that states a takeaway.
- [ ] No slide has more than 6 bullets.
- [ ] Every chart slide has at most 2 short lines of description alongside.
- [ ] No bar/column chart has a value ratio > 10x.
- [ ] Pie chart slides are minimal (H2 + 1 line, no other content).
- [ ] Every load-bearing number has an inline source.
- [ ] No banned filler phrases (`copy-rules.md` rule 7).
- [ ] Closing slide states an ask, not just "Thank you".
- [ ] The deck ends with the file written to CWD as `presentation.md`.

If any check fails, fix it before reporting completion.

### Step 7 — Hand off

Report to the user:
- File written: `<absolute path>/presentation.md`.
- Slide count.
- Suggested next step: `/deck render` to produce HTML and PDF.
