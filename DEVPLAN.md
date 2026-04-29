# DEVPLAN — `deck` skill

## Goal

Build a Claude Code skill named `deck` exposing three subcommands (`brief`, `draft`, `render`) via runtime routing. Each subcommand produces a file artifact that feeds the next one, forming a pipeline:

```
presentation-brief.md  →  presentation.md  →  presentation.html + presentation.pdf
```

The skill packages **three things** that today live only in the head of someone who already knows how to make a deck and how to wrestle md2 into producing print-clean PDFs:

1. **Slide-pattern library** (12+ patterns with copy-paste md2 syntax).
2. **Copywriting rules** that make a business deck land (headline-first, parallel bullets, concrete numbers, no filler).
3. **Print-aware constraints** that prevent the recurring bugs we hit when rendering md2 to PDF: charts with extreme value ratios truncating labels, too much text alongside a chart pushing it to the next page, empty/half-filled slides, pie chart sizing.

Ship with a local installer modelled on `landing/install.sh` (same local/remote detection, same `--force` / `--help` flags). Tests follow the `landing/tests/` pattern (bash + grep contract checks).

## Non-goals (v0.1)

- Online raw-install hosting — structure compatible, not implemented.
- Symlink-based install.
- Visual self-review loop (render PDF → re-read → fix overflow). Documented as a v0.2 idea.
- Multi-document branding — one palette per run.
- Brand asset ingestion (logo extraction, palette auto-detect from URL/PDF).
- Image generation. Users embed their own images via `![](path)` or `<img>`.
- Translation pipeline — language is user-driven mid-session.
- Automatic data-source ingestion (e.g. read a CSV → propose a chart). User pastes data inline.

## File layout (final)

```
~/Documents/software/skills/deck/
├── DEVPLAN.md
├── README.md
├── .gitignore
├── install.sh                            # local/remote installer (adapted from landing)
├── skill/                                # lands at ~/.claude/skills/deck/
│   ├── SKILL.md                          # frontmatter, routing, language rules
│   ├── brief/
│   │   └── prompt.md                     # interview about audience/goal/style/brand
│   ├── draft/
│   │   ├── prompt.md                     # main writing instructions (orchestrator)
│   │   ├── slide-patterns.md             # 12+ patterns with md2 examples
│   │   ├── copy-rules.md                 # headline-first, 6x6, parallel bullets
│   │   ├── md2-cheatsheet.md             # md2 syntax (frontmatter, charts, columns)
│   │   └── print-constraints.md          # chart ratios, page-break, pie sizing
│   └── render/
│       ├── prompt.md                     # invocation + error handling
│       └── render.sh                     # md → html → pdf pipeline (Chrome headless)
└── tests/
    ├── test_all.sh                       # runs the rest
    ├── test_structure.sh                 # filesystem layout
    ├── test_skill.sh                     # SKILL.md frontmatter + routing contracts
    ├── test_brief.sh                     # brief/prompt.md required sections
    ├── test_draft.sh                     # draft/* knowledge files contracts
    ├── test_render.sh                    # render.sh syntax + flag handling
    └── test_install.sh                   # installer dry-run contracts
```

Naming rationale:
- `prompt.md` per subcommand = the instructions Claude reads after routing (mirrors `landing`).
- Knowledge files in `draft/` keep short domain names (`slide-patterns.md`, `copy-rules.md`, etc.) — the subcommand prompt loads them lazily as needed.
- `render.sh` is a separate executable so we can also call it manually from the shell, decoupled from Claude.

## Artifact pipeline

All artifacts land in the user's current working directory (CWD) with fixed filenames:

| Subcommand     | Reads (CWD)                       | Writes (CWD)                                |
|----------------|-----------------------------------|---------------------------------------------|
| `/deck brief`  | user interview                    | `presentation-brief.md`                     |
| `/deck draft`  | `presentation-brief.md`           | `presentation.md`                           |
| `/deck render` | `presentation.md`                 | `presentation.html` + `presentation.pdf`    |

If the expected input file is missing in CWD, the subcommand:
1. Tells the user it needs `<filename>`.
2. Offers two paths: (a) run the previous subcommand first, or (b) paste/point to the input inline.
3. Does not silently invent content.

## Runtime behavior

`SKILL.md` frontmatter declares name + description (trigger). Body contains:

1. **Language rules** (global):
   - Chat: always reply in the user's language.
   - Artifacts: English by default. Ask once per session *"Artifact language? (default: English)"* unless the user has already specified. User can override any time mid-session.

2. **Routing table** — reads the argument after `/deck`:
   - `brief` → read `brief/prompt.md`.
   - `draft` → read `draft/prompt.md`, then lazy-load `draft/slide-patterns.md`, `draft/copy-rules.md`, `draft/md2-cheatsheet.md`, `draft/print-constraints.md` as referenced.
   - `render` → read `render/prompt.md`, invoke `render/render.sh`.
   - no arg / unknown arg → 3-line menu.

3. **Subcommand isolation** — each branch reads only its own folder (the `draft/` knowledge files are loaded only when in the `draft` branch).

## Framework: what the skill bakes in (the value-add)

### Slide patterns (`draft/slide-patterns.md`)

The skill ships a curated catalog. Each pattern documents:
- Name + when to use.
- md2 syntax block (copy-paste ready).
- Anti-patterns (when NOT to use).

Initial set (v0.1):

1. **Cover** — H1 + 1-2 lines (presenter, date, context).
2. **Section divider** — slide with only H2, big and centered.
3. **Hero stat** — H2 takeaway + single big number (`# 50%` inside slide) + 1 framing sentence.
4. **Bullet list** — H2 + 3-5 bullets with selective `**bold**`.
5. **Two-column compare** — `:::columns` with `:::col` × 2 (vs / before-after / problem-solution).
6. **Quote / testimonial** — H2 + `> blockquote` + attribution.
7. **Process / steps** — H2 + numbered list `1. 2. 3.`.
8. **Timeline** — H2 + table OR `:::columns` with date/event pairs.
9. **Single chart** — H2 + 1-line context + `:::chart`.
10. **Table** — H2 + table + optional `> takeaway` blockquote.
11. **Diagram / image** — H2 + `![](path)`.
12. **People / team** — H2 + `:::columns` with photo + bio per col.
13. **Closing / CTA** — H2 + 2-3 next-step bullets + contacts.

### Copywriting rules (`draft/copy-rules.md`)

- **Headline = punchline**: the slide's `## H2` must state the takeaway, not the topic. *"Mercato IA cresce +50% YoY"* > *"Dati di mercato"*.
- **Pyramid principle**: top of the deck states the conclusion; the rest proves it.
- **One idea per slide** (test: "if this were the only slide, what would the audience remember?").
- **Numbers > adjectives**: *"+50% YoY"* > *"crescita esplosiva"*.
- **Inline source citations** where credibility matters: *"+50% YoY (Osservatorio AI PoliMI 2025)"*.
- **6x6 rule** as a ceiling, not a target — max 6 bullets × 6 words per bullet.
- **Parallel bullets**: same verb tense, same length, same shape.
- **Banned phrases**: *"in conclusione"*, *"come abbiamo visto"*, *"vorrei sottolineare"*, *"è importante notare"*. They are filler that signals lack of confidence.

### md2 cheatsheet (`draft/md2-cheatsheet.md`)

Compact reference — the skill never has to fetch md2's README:
- Frontmatter (`+++` block, fields: `title`, `palette`, `colors`, `lang`, `dark`).
- Built-in palettes (`default`, `warm`, `cool`, `mono`, `vivid`, `pastel`).
- `:::chart TYPE [--options]` syntax with all 5 chart types.
- `:::columns` / `:::col` layout.
- Heading levels (H1 cover, H2 slide title, H3/H4 sub-sections).
- Footnotes, blockquotes, fenced code blocks.
- Inline HTML allowed (iframes for embeds, `<img>`).

### Print constraints (`draft/print-constraints.md`)

The bug catalog we hit while iterating on the Emilia-Romagna deck:

- **One chart per slide**. Charts have `break-inside: avoid` in print CSS — combining a chart with a long text block pushes the chart to a new page.
- **Description text alongside a chart: max 1-2 short lines** (≈ 30-50 words). Above that the chart spills.
- **Pie chart**: 50vh tall + horizontal legend = barely fits a print page on its own. Description must be ≤ 1 line. Prefer pie only when the slice ratios actually carry the message (otherwise use a bar/column).
- **Bar / column charts: avoid value ratios > 10x in a single chart**. The smallest bar's data label gets clipped/truncated (e.g. "350" rendered vertically as "3 5 0" when the largest is "50000"). Either split the chart, switch to percentages, or drop the smallest value to text.
- **Tables can carry more text + a `> takeaway` blockquote** (2 lines max) without spilling.
- **Avoid empty slides**: if a section has < 30 words or 1 short bullet, fold it into the previous or next slide.
- **Section dividers are exempt** from the "no empty slide" rule — they're intentional pauses.
- **Always `## H2` per slide** — md2 falls back to "Slide N" otherwise, breaking the sidebar nav.

## Render pipeline (`render/render.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:?Usage: render.sh <input.md>}"
[ -f "$INPUT" ] || { echo "File not found: $INPUT" >&2; exit 1; }

HTML="${INPUT%.md}.html"
PDF="${INPUT%.md}.pdf"

# Step 1: md → HTML via md2
command -v md2 >/dev/null || { echo "md2 not on PATH" >&2; exit 2; }
md2 "$INPUT"

# Step 2: HTML → PDF via Chromium-family headless
BROWSER=""
for cmd in chromium google-chrome chrome chromium-browser; do
  if command -v "$cmd" >/dev/null; then BROWSER="$cmd"; break; fi
done
[ -n "$BROWSER" ] || { echo "Need chromium/google-chrome on PATH" >&2; exit 3; }

"$BROWSER" --headless --disable-gpu --no-sandbox \
  --print-to-pdf-no-header \
  --print-to-pdf="$PDF" \
  "file://$(realpath "$HTML")" 2>/dev/null

echo "Generated: $HTML"
echo "Generated: $PDF"
```

## Milestones

### M1 — Scaffold directory structure ✅

- [x] Create `skill/` with subfolders `brief/`, `draft/`, `render/`.
- [x] Create empty placeholder files per the layout.
- [x] Create `tests/` directory.
- [x] Create `.gitignore`, `install.sh` (placeholder), `README.md`, `DEVPLAN.md`.
- [x] Verify tree matches.

Note: no git remote configured — commits stay local. User can add a remote later.

### M2 — `SKILL.md` (routing + language rules + prerequisites) ✅

- [x] Frontmatter: `name: deck`, `description: <trigger covering brief/draft/render pipeline + business deck context>`.
- [x] Frontmatter: `compatibility: Requires md2 (markdown→HTML presentation converter) and a Chromium-family browser (chromium, google-chrome, chrome) on $PATH` — per [agentskills.io spec](https://agentskills.io/specification#compatibility-field) (max 500 char).
- [x] Body: `## Prerequisites` section with concrete install hints for both `md2` and a Chromium-family browser, and a pointer to README.md → Requirements for the long form.
- [x] Language rules block.
- [x] Routing table with 3 branches + menu fallback.
- [x] Note on artifact pipeline (input filename expected in CWD per step).
- [x] Subcommand isolation rule (draft knowledge files load lazily inside the draft branch).
- [x] Keep short — heavy content lives in subcommand prompts.

### M3 — `brief/prompt.md` ✅

- [x] Interview script with these required sections:
  - **Audience**: who's in the room? what do they already know? what do they care about?
  - **Objective**: decision to take, action to ask for, awareness to build, learning to share.
  - **Format**: live deck (presented), leave-behind (read alone), or hybrid? affects density per slide.
  - **Length budget**: target slide count or time slot.
  - **Brand**: palette (built-in or custom), logo if any, language for artifact.
  - **Hard content**: data, claims, quotes the user wants in. Sources for credibility.
  - **Tone**: formal/casual/punchy?
- [x] Output template: `presentation-brief.md` with structured sections matching the interview.
- [x] Filename enforcement: must write `presentation-brief.md` to CWD.
- [x] Delegate language to `SKILL.md`.

### M4 — `draft/` knowledge files ✅

- [x] `slide-patterns.md`: write the catalog of 13 patterns documented above. Each pattern has: name, when to use, md2 syntax block, anti-pattern note.
- [x] `copy-rules.md`: write the rule list documented above. Examples (good vs bad) for each rule.
- [x] `md2-cheatsheet.md`: distilled reference (frontmatter, palettes, charts, columns, headings, footnotes, inline HTML).
- [x] `print-constraints.md`: write the bug catalog with concrete numbers (≤ 50 words next to a chart, value ratios ≤ 10x, etc.).

### M5 — `draft/prompt.md` (writer) ✅

- [x] Reads `presentation-brief.md` from CWD; if missing, offers to run `/deck brief` or accept inline content.
- [x] Walks user through content gathering only for the gaps the brief left open.
- [x] Proposes a narrative arc — chooses among Pyramid / SCQA / 3-act based on the brief's objective; presents the arc as a 1-line outline before writing.
- [x] Maps each beat to a slide pattern from `slide-patterns.md`.
- [x] Writes md2 markdown to `presentation.md` in CWD, applying:
  - The pattern syntax from `slide-patterns.md`.
  - Copy rules from `copy-rules.md`.
  - Print constraints from `print-constraints.md`.
  - Frontmatter palette from the brief.
- [x] Lazy-load knowledge files (read each one only when it becomes relevant in the conversation).
- [x] Delegate language to `SKILL.md`.

### M6 — `render/` (script + prompt) ✅

- [x] `render.sh`: write the pipeline script documented above. Make executable.
- [x] `render.sh`: handle missing `md2`, missing browser, missing input file with clear errors.
- [x] `render.sh`: support `--no-pdf` flag to skip PDF generation if user only wants HTML.
- [x] `prompt.md`: instructs Claude to invoke `~/.claude/skills/deck/render/render.sh <presentation.md>`; on error, surface the message; on success, report both file paths to the user.
- [x] **Bonus**: `render.sh` falls back to `firefox` if no Chromium-family browser is available (Firefox 102+ supports `--headless --print-to-pdf`). Chromium-family is preferred for higher CSS fidelity.

Note: on the dev machine the user's Firefox is installed via snap and has missing shared-object dependencies, so the live PDF generation hangs. The script is spec-correct; installing chromium (`apt install chromium-browser`) is the recommended fix and is documented in README → Requirements.

### M7 — `install.sh` + `README.md` polish

- [ ] Adapt `landing/install.sh` to a single-target install: source `skill/` → dest `~/.claude/skills/deck/`.
- [ ] Keep local/remote detection, `--force`, `--help`.
- [ ] Add **dependency check** (UX layer, not part of the agentskills.io standard): probe `md2` on `$PATH`; probe `chromium` / `google-chrome` / `chromium-browser` / `chrome`. If anything is missing, print the install hints and ask `Continue installing the skill anyway? [y/N]` (soft-fail so CI / build environments aren't blocked).
- [ ] Print post-install summary with the three `/deck <cmd>` invocations and the pipeline order.
- [ ] `README.md`: refine after implementation lands. Ensure the **Requirements** section gives concrete install commands for `md2` and the browser; cross-reference the SKILL.md `compatibility` field as the source of truth.

### M8 — Tests

- [ ] `tests/test_structure.sh`: filesystem checks (every required file exists and is non-empty).
- [ ] `tests/test_skill.sh`: SKILL.md frontmatter (`name: deck`, non-empty description, `compatibility:` present and ≤500 char per agentskills.io spec), routing references all 3 subcommands, mentions all 3 artifact filenames, references CWD, body has `## Prerequisites` section.
- [ ] `tests/test_skill.sh`: optionally, if `skills-ref` is on `$PATH`, run `skills-ref validate skill/` and assert green. Skip cleanly if not installed (per [agentskills.io](https://agentskills.io/specification#validation)).
- [ ] `tests/test_brief.sh`: brief/prompt.md mentions audience, objective, format, length, brand, language; declares output filename `presentation-brief.md`.
- [ ] `tests/test_draft.sh`: draft/prompt.md references slide-patterns.md, copy-rules.md, md2-cheatsheet.md, print-constraints.md; each knowledge file contains its core invariants (e.g. slide-patterns.md mentions cover/hero/compare/chart; copy-rules.md mentions headline; print-constraints.md mentions ratio + spill).
- [ ] `tests/test_render.sh`: render.sh has `set -euo pipefail`, handles missing `md2`, handles missing browser, accepts a `.md` argument and writes `.html` + `.pdf` paths.
- [ ] `tests/test_install.sh`: install.sh handles `--force`, `--help`, copies `skill/` to `~/.claude/skills/deck/`; dependency check prints the right install hints when probes fail.
- [ ] `tests/test_all.sh`: runs all the above and aggregates pass/fail counts.

### M9 — Smoke test

- [ ] `bash install.sh --force` → `~/.claude/skills/deck/` populated with SKILL.md + all subcommand files.
- [ ] `bash tests/test_all.sh` → all suites green.
- [ ] **Manual smoke (user-side)**: in a fresh test CWD, run `/deck brief`, then `/deck draft`, then `/deck render`. Open the resulting PDF. Verify: no empty slides, no spilled charts, no truncated labels.
- [ ] **Regression smoke**: re-render the existing `<project-dir>/target-research.md` through the skill's render pipeline; confirm same output as the manual `md2` + Chrome run we did today.

## Out of scope for v0.1 (parked for later)

- **M10 — Visual self-review loop**: after `/deck render`, optionally let Claude read the PDF, detect empty slides / clipped chart labels / overflows, propose targeted edits to `presentation.md`.
- **M11 — Brand ingestion**: extract palette from a logo file or a URL screenshot.
- **M12 — Custom palette wizard**: `/deck palette` to create `~/.md2/palettes/<brand>.toml` interactively.
- **M13 — Multi-deck**: same brief, different audiences (sales vs board vs investor) → multiple decks in one run.
- **M14 — Online one-liner install** (requires hosted repo).
- **M15 — Versioning / update detection** in installer.
