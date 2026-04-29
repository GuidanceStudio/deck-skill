# `/deck brief` — Presentation Brief Interview

## What this subcommand does

Run a short structured interview with the user, then write a single artifact — `presentation-brief.md` — to the **current working directory** (CWD). This file is the input for `/deck draft`.

The brief should capture everything the writer needs to make slide-by-slide decisions later: who the deck is for, what it must achieve, what content is mandatory, and what visual frame applies.

## Inputs

- The user (interactive interview).
- Nothing read from disk.

## Output

A single file in CWD: `presentation-brief.md`, with the schema defined below.

If a file with the same name already exists in CWD, ask the user whether to overwrite, append, or write to a different filename. Never silently overwrite.

## Language

Language behavior is governed by the router (`SKILL.md`). Briefly: chat in the user's language, the artifact defaults to English unless the user has indicated otherwise.

## Interview procedure

Run the interview in this order. Ask one or two questions at a time, not the whole list at once. Skip nothing — if the user is unsure on an item, capture "unknown" and move on; the draft stage will surface the gap.

### 1. Audience

- Who is in the room? (Roles, seniority, function — board, exec team, prospects, internal team, conference, etc.)
- What do they already know about the topic? (Cold, warm, expert.)
- What do they care about? (KPIs, risk, status, vision, learning, decision, funding.)

### 2. Objective

- What is the single most important outcome of this deck? Pick one:
  - **Decide** — the audience is asked to make a specific decision.
  - **Approve / fund** — the audience is asked to greenlight or release budget.
  - **Update** — the audience needs status, no decision required.
  - **Persuade** — change a belief or commit to an action later.
  - **Inform / teach** — share knowledge with no immediate ask.
- If "decide" or "approve": what is the exact ask?

### 3. Format

- Will the deck be **presented live** by a speaker, **read alone** as a leave-behind, or **both** (hybrid)? This dictates slide density:
  - Presented live → fewer words per slide, headlines do the talking, the speaker fills the gaps.
  - Leave-behind → more body text per slide, slide must stand alone with no narrator.
  - Hybrid → middle ground; favor leave-behind density, with strong headlines.

### 4. Length budget

- Target slide count, OR
- Target time slot (10 min ≈ 8-12 slides; 30 min ≈ 15-25 slides; board update 5-10 slides).
- Hard limits if any (e.g., "must fit in 5 minutes", "max 1 page when printed").

### 5. Brand

- Palette: any of md2's built-ins (`default`, `warm`, `cool`, `mono`, `vivid`, `pastel`), or a custom palette in `~/.md2/palettes/`?
- Logo to embed? (Optional. Path to image file.)
- Language for the artifact (overrides the SKILL.md default if specified).

### 6. Hard content

This is where most decks fail. Force the user to state the facts up front so the draft stage doesn't invent them.

- **Numbers / data** the deck must include (e.g., "MRR is €120k", "5 customers signed last quarter").
- **Claims** the user wants to make ("we're 3x faster than X").
- **Sources** for credibility (URLs, reports, internal docs).
- **Quotes / testimonials** to include.
- **Visuals** the user already has (charts, screenshots, diagrams).
- **Mandatory sections** the user wants in the deck.
- **Things to avoid** (sensitive topics, competitors not to name, etc.).

### 7. Tone

- Formal, neutral, casual, punchy?
- One example sentence the user thinks "sounds right" for this deck.

### 8. Confirm and write

- Recap the brief in 5-10 lines and ask the user to confirm.
- Then write `presentation-brief.md` to CWD using the template below.

## Output template

Write the artifact in this structure. Use markdown headings exactly. Keep entries terse — bullets and short sentences, not paragraphs.

```markdown
# Presentation Brief

## Audience
- Who: ...
- What they know: ...
- What they care about: ...

## Objective
- Outcome class: <decide|approve|update|persuade|inform>
- Specific ask: ...

## Format
- Format: <presented|leave-behind|hybrid>
- Density implication: ...

## Length
- Slide count target: ...
- Time slot: ...
- Hard limits: ...

## Brand
- Palette: ...
- Logo: <path or "none">
- Artifact language: ...

## Hard content

### Data and numbers
- ...

### Claims
- ...

### Sources
- ...

### Quotes
- ...

### Visuals provided
- ...

### Mandatory sections
- ...

### Avoid
- ...

## Tone
- Register: <formal|neutral|casual|punchy>
- Reference sentence: "..."

## Notes
- Anything else relevant to the draft stage.
```

## Quality checks before writing

Before writing the file, verify:
- Audience is concrete, not generic ("the board" + names of execs > "stakeholders").
- Objective names a single primary outcome class.
- Format is one of the three values, not "depends".
- At least one Hard Content item is filled (numbers, claims, or sources).

If any of those is empty after the interview, ask one more targeted question before writing.
