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

- **Headline = the sentence that summarises what matters**: the slide's `## H2` states the takeaway, not the topic label — and not a slogan. *"Mercato IA cresce +50% YoY"* > *"Dati di mercato"* (label) and > *"Il mercato non aspetta i lenti"* (slogan). See also rule 7b, banned rhetorical constructions.
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

### M7 — `install.sh` + `README.md` polish ✅

- [x] Adapt `landing/install.sh` to a single-target install: source `skill/` → dest `~/.claude/skills/deck/`.
- [x] Keep local/remote detection, `--force`, `--help`.
- [x] Add **dependency check** (UX layer, not part of the agentskills.io standard): probe `md2` on `$PATH`; probe `chromium` / `google-chrome` / `chromium-browser` / `chrome` / `firefox`. If anything is missing, print the install hints and ask `Continue installing? [y/N]` (soft-fail so CI / build environments aren't blocked).
- [x] Print post-install summary with the three `/deck <cmd>` invocations and the pipeline order.
- [x] `README.md`: concrete install commands for `md2` and the browser; cross-references the SKILL.md `compatibility` field.

### M8 — Tests ✅

Note: in TDD mode, each test file was written BEFORE the corresponding implementation milestone (M2-M7). M8 ships only the aggregator and the optional `skills-ref` validation hook.

- [x] `tests/test_structure.sh`: filesystem checks (every required file exists and is non-empty). Written in M2.
- [x] `tests/test_skill.sh`: SKILL.md frontmatter (`name: deck`, non-empty description, `compatibility:` present and ≤500 char per agentskills.io spec), routing references all 3 subcommands, mentions all 3 artifact filenames, references CWD, body has `## Prerequisites` section. Written in M2.
- [x] `tests/test_skill.sh`: optionally, if `skills-ref` is on `$PATH`, run `skills-ref validate skill/` and assert green. Skip cleanly if not installed.
- [x] `tests/test_brief.sh`: brief/prompt.md mentions audience, objective, format, length, brand, language; declares output filename `presentation-brief.md`. Written in M3.
- [x] `tests/test_draft.sh`: draft/prompt.md references slide-patterns.md, copy-rules.md, md2-cheatsheet.md, print-constraints.md; each knowledge file contains its core invariants. Written in M4-M5.
- [x] `tests/test_render.sh`: render.sh has `set -euo pipefail`, handles missing `md2`, handles missing browser, accepts a `.md` argument, supports `--no-pdf`. Written in M6.
- [x] `tests/test_install.sh`: install.sh handles `--force`, `--help`, copies `skill/` to `~/.claude/skills/deck/`; dependency probes work. Written in M7.
- [x] `tests/test_all.sh`: runs all the above and aggregates pass/fail counts.

### M9 — Smoke test ✅ (automated portion)

- [x] `bash install.sh --force` → `~/.claude/skills/deck/` populated with SKILL.md + all subcommand files (verified: SKILL.md, brief/prompt.md, draft/{prompt,slide-patterns,copy-rules,md2-cheatsheet,print-constraints}.md, render/{prompt.md,render.sh}). render.sh remains executable post-copy.
- [x] `bash tests/test_all.sh` → 6 suites green, all assertions pass.
- [x] Skill registered: appears in the Claude Code available-skills list under name `deck` after install.
- [ ] **Manual smoke (user-side)**: in a fresh test CWD, run `/deck brief`, then `/deck draft`, then `/deck render`. Open the resulting PDF. Verify: no empty slides, no spilled charts, no truncated labels. Cannot run automatically — requires interactive Claude Code session.
- [ ] **Regression smoke**: re-render `<project-dir>/target-research.md` through `~/.claude/skills/deck/render/render.sh`. HTML generation works; PDF generation requires installing chromium (`apt install chromium-browser`) since the dev machine's snap-Firefox has missing shared-object dependencies.

## Backlog (no version assigned yet)

- **Visual self-review loop**: after `/deck render`, optionally let Claude read the PDF, detect empty slides / clipped chart labels / overflows, propose targeted edits to `presentation.md`.
- **Brand ingestion**: extract palette from a logo file or a URL screenshot.
- **Custom palette wizard**: `/deck palette` to create `~/.md2/palettes/<brand>.toml` interactively.
- **Multi-deck**: same brief, different audiences (sales vs board vs investor) → multiple decks in one run.
- **Versioning / update detection** in installer.

---

# v0.2 milestones

User feedback after v0.1 ship surfaced two issues:
1. **No orientation control.** The first deck rendered portrait by default; the user wanted landscape (16:9 standard for slides). md2 has no orientation flag, so we have to control it via `@page` CSS at render time.
2. **Agent improvises the render step.** When `/deck render` ran, the agent occasionally bypassed the bundled `render.sh` and tried alternative tools (e.g. playwright) or assembled its own md2 + browser invocation chain, sometimes hitting errors. The render prompt needs to be strictly prescriptive.

v0.2 also folds in a Gotchas section to prevent the most common md2 syntax mistakes (frontmatter delimiter confusion, chart formatting) and a self-validation step that catches them before the file is handed off.

## v0.2 file changes

```
skill/
├── brief/prompt.md            # +Orientation, +Paper size questions; output template extends Format
├── draft/
│   ├── prompt.md              # +Gotchas section; +self-validation step (run md2, fix on error, retry once)
│   ├── md2-cheatsheet.md      # +note on `+++` (TOML) vs `---` (YAML) confusion
│   └── slide-patterns.md      # (no change)
└── render/
    ├── prompt.md              # Hard rules: invoke ONLY render.sh; no playwright/weasyprint/pandoc/etc.
    └── render.sh              # +--landscape/--portrait flags, +--paper A4|letter, +CSS injection for @page
```

`presentation.md` produced by `/deck draft` carries the orientation as an HTML comment so re-renders are deterministic:

```markdown
<!-- deck-orientation: landscape -->
<!-- deck-paper: A4 -->
+++
title = "..."
+++

# ...
```

`render.sh` parses these comments before invoking the browser; CLI flags override.

## Milestones

### M10 — Orientation + paper size support ✅

- [x] **brief/prompt.md**: add to the interview, in `Format` section: orientation (landscape default), paper size (A4 default).
- [x] **brief/prompt.md**: extend the output template under `## Format` with `Orientation:` and `Paper size:` fields.
- [x] **draft/prompt.md**: emit `<!-- deck-orientation: ... -->` and `<!-- deck-paper: ... -->` HTML comments at the very top of `presentation.md` (before the `+++` frontmatter).
- [x] **render/render.sh**: CLI flags `--landscape` / `--portrait` / `--paper A4|letter`; `--help` updated.
- [x] **render/render.sh**: parses HTML comments from input md when no CLI flag set; defaults landscape A4.
- [x] **render/render.sh**: after `md2`, injects `<style>@page { size: <paper> <orientation>; margin: 12mm; }</style>` before `</head>` via `sed`.
- [x] **tests/test_brief.sh**: covers orientation/landscape/portrait/paper/A4 patterns.
- [x] **tests/test_draft.sh**: covers `deck-orientation` / `deck-paper` emission.
- [x] **tests/test_render.sh**: covers CLI flags + behavioral check that generated HTML contains `@page A4 landscape`, `@page letter portrait`, CLI override, default-when-no-comments. 4 behavioral cases all green.

### M11 — Tighter `render/prompt.md` to prevent agent improvisation ✅

- [x] **render/prompt.md** — added "Hard rules" section with explicit Do / Do not lists; forbids playwright, puppeteer, weasyprint, pandoc, wkhtmltopdf, custom Python/Node wrappers, direct invocation of md2/chromium/firefox, and reading HTML during render.
- [x] **render/prompt.md** — exit-code table preserved; cross-linked.
- [x] **render/prompt.md** — top-of-file directive: *"This subcommand has exactly one job: invoke the bundled render.sh and report. Do not improvise. Do not invent an alternative pipeline."*
- [x] **tests/test_render.sh** — asserts the forbidden-tool list, the exact invocation pattern, and the no-improvise directive. 6 new assertions, all green.

### M12 — Gotchas + self-validation in `draft/prompt.md` ✅

- [x] **draft/prompt.md** — `## Gotchas (md2 syntax pitfalls)` section with all 9 documented pitfalls (frontmatter delimiter, blank lines around `---` and `:::`, table column counts, pie-positive values, no nested directives, ratio reminder, comment placement).
- [x] **draft/prompt.md** — `Step 7 — Self-validation` step before hand-off: runs `md2 presentation.md`, fixes & retries (max 2), surfaces error verbatim if still failing, post-check on slide count.
- [x] **md2-cheatsheet.md** — top-of-file callout about `+++` (TOML) vs `---` (YAML) and the slide separator distinction.
- [x] **tests/test_draft.sh** — 6 new assertions: Gotchas section, frontmatter warning, blank-line warning, self-validation step, retry behavior, cheatsheet callout. All green.

### M13 — v0.2 smoke + ship ✅

- [x] `bash install.sh --force` — re-installed on top of v0.1; all 8 files copied; render.sh remains executable.
- [x] `bash tests/test_all.sh` — 6 suites green, 70+ assertions including the new M10/M11/M12 ones.
- [x] **Regression**: deck with `<!-- deck-orientation: landscape --><!-- deck-paper: A4 -->` → injected HTML contains `<style>@page { size: A4 landscape; margin: 12mm; }</style>`. ✓
- [x] **Regression**: same deck rendered with `--portrait --paper letter` → injected HTML contains `<style>@page { size: letter portrait; margin: 12mm; }</style>`. ✓ CLI override beats comments.
- [x] **Regression**: bare deck (no comments) → defaults to `A4 landscape`. ✓
- [ ] **Manual regression for self-validation loop** (M12) — requires a Claude Code session to actually drive the draft prompt with a deliberate syntax error. Cannot be automated; user-side smoke.
- [x] Update README.md mentioning the new flags and the orientation behavior.
- [x] Push to `origin/main` after each milestone.

### M14 — Brave browser support in render pipeline

Motivation: on systems where only Brave (Chromium-based) is installed, `render.sh` falls back to Firefox; Firefox snap headless `--print-to-pdf` hangs for several minutes on Ubuntu 25.10, leaving the PDF unproduced. Detecting `brave-browser` directly in the chromium-family loop avoids the slow fallback. Order honors the user's preference: `chromium → google-chrome → chromium-browser → chrome → brave-browser → brave`, with Firefox kept as last-resort fallback.

- [x] **render/render.sh** — extend the chromium-family detection loop to: `chromium google-chrome chromium-browser chrome brave-browser brave`. Brave inherits the existing chromium flag set (`--headless --disable-gpu --no-sandbox --no-pdf-header-footer --print-to-pdf=...`), which it accepts natively as a chromium derivative.
- [x] **render/render.sh** — header dependency comment block: list brave alongside chromium/chrome variants.
- [x] **render/render.sh** — print which browser was selected before invoking it: `echo "  Using: $BROWSER ($BROWSER_FAMILY)"`. Aids debugging silent hangs (today's firefox-snap incident).
- [x] **render/render.sh** — when falling back to firefox, emit a `>&2` warning: `Warning: no chromium-family browser found, falling back to firefox (may hang on Linux snap installs).` so the user knows why a render is slow.
- [x] **render/prompt.md** — extend the "Do not invoke ... directly" list (line ~30) to include `brave-browser` / `brave`.
- [x] **render/prompt.md** — exit-code 3 row in the error-handling table: widen the user-facing hint to mention brave as a valid install option.
- [x] **skill/SKILL.md** — Prerequisites section: include brave in the chromium-family bullet.
- [x] **skill/SKILL.md** — frontmatter `compatibility:` field: append brave to the listed binaries.
- [x] **README.md** — Requirements → Browser section: document the new detection order and mention brave.
- [x] **install.sh** — extend the prerequisite-probe browser loop to match render.sh detection order; update the help-text dependency list.
- [x] **tests/test_render.sh** — extend the `assert_grep` regex on line 49 to include `brave-browser`/`brave`; assert "Using: $BROWSER" diagnostic and the firefox fallback warning.
- [x] `bash install.sh --force` to redeploy.
- [x] `bash tests/test_all.sh` — confirm all suites green after the changes (6 suites, 0 failed).
- [x] Manual smoke: `render.sh` on `cfoaas/crediti-2026-05/presentation.md` with only chromium-derivative `brave-browser` available — selected `brave-browser (chromium)`, PDF generated in seconds (no firefox fallback hang).

### M15 — Fix: leading HTML comments break frontmatter parsing ✅

Bug observed in the wild on the Magis Energia deck. md2 only parses `+++` as TOML frontmatter when it appears on line 1; placing the `<!-- deck-orientation -->` and `<!-- deck-paper -->` comments above the frontmatter (as M10's instructions told writers to do) silently fell back to `<title>Presentation</title>` and rendered the entire `+++ … +++` block as visible body text on the cover slide. Empirically verified: comments **after** frontmatter (or at end of file) preserve correct parsing; `render.sh` greps the markers from the source `.md` regardless of position, so the @page CSS injection still works.

- [x] **skill/draft/prompt.md** — invert the instruction in the writing rules: `+++` must be on line 1 (no comments, no blank lines above); orientation/paper comments go at the **end of the file**, after the last slide.
- [x] **skill/draft/prompt.md** — gotchas section: replace the misleading "HTML comments before `+++` are fine" with an explicit warning describing the `Presentation`-fallback failure mode.
- [x] **skill/draft/md2-cheatsheet.md** — second "Heads-up" callout under the existing frontmatter-delimiter one: frontmatter must start on line 1.
- [x] `bash install.sh --force` — redeployed.
- [x] Push to `origin/main`.

### M16 — Fix: `:::columns` collapse to vertical stacking in print PDF ✅

Bug observed on the Storie di Transizione deck. Slides using `:::columns` rendered in print PDF with the two `:::col` blocks stacked vertically instead of side-by-side, even when content was light enough to fit on one A4 landscape page. Root cause is a CSS cascade collision in md2's stylesheet:

- The base rule sets `.md2-columns { display: flex; ... }` (default `flex-direction: row`).
- The `@media print` rule re-declares `.md2-columns { display: flex; gap: 20px; }` but does **not** restate `flex-direction`.
- The later `@media (max-width: 768px)` rule sets `.md2-columns { flex-direction: column; }`.

When headless Chromium prints to PDF without an explicit `--window-size`, the layout viewport can fall at or below 768px (Chromium's headless default has shifted across versions); both the print and the mobile media queries match. Because the mobile rule comes after the print rule in the stylesheet and explicitly sets `flex-direction: column`, it wins — columns stack.

Secondary issue surfaced in the same deck: column slides with H2 + intro paragraph + two columns + closing blockquote can exceed the printable area of A4 landscape; `break-inside: avoid` on `.md2-columns` then pushes the columns to a second page, leaving the H2 + intro orphan on the first. This is content-density, not CSS, but it is the same failure mode from the user's point of view (slide rendered "wrong"), so address both in this milestone.

- [x] **skill/render/render.sh** — extend the `PAGE_CSS` injection to add a print-only override that forces row layout on `.md2-columns`. The current single-line `<style>@page {...}</style>` becomes a multi-rule block that also contains `@media print { .md2-columns { flex-direction: row !important; gap: 20px; } }`. The `!important` is necessary to win over the later `@media (max-width: 768px)` rule when both match.
- [x] **skill/draft/print-constraints.md** — add a new rule "Column slide density on A4 landscape" warning that combining `:::columns` with H2 + multi-line intro + closing blockquote can overflow the page; recommend max one short intro sentence, max four short bullets per column, drop the closing blockquote on column slides, or split into two slides.
- [x] **skill/draft/prompt.md** — extend Step 7 (md2 self-validation) to also run `pdfinfo "$PDF" | grep Pages` after `/deck render` and verify page count equals slide count. Mismatch means a slide overflowed; surface to the user with a recommendation to lighten the offending slide.
- [x] **skill/draft/prompt.md** — gotchas section: add an entry about the columns-collapse failure mode and the content-density risk on column slides, pointing readers to the new `print-constraints.md` rule.
- [x] `bash install.sh --force` — redeploy.
- [x] Smoke test: re-render `<project-dir>/presentation.md` and verify (a) slide 4 columns are side-by-side, (b) PDF page count equals 12.
- [x] Push to `origin/main`.

### M17 — Fix: HTML table scrollbars and truncated columns in print PDF ✅

Bug observed on the the telco client deck (`<project-dir>/`). Slides containing markdown tables rendered in the print PDF with a visible grey scrollbar below the table and the rightmost column truncated — verified visually on slide 6 (portfolio the telco client) and slide 8 (timeline 30 giorni). Same root cause family as M16: a mobile-only CSS rule in md2's stylesheet leaks into print because its media query lacks the `screen` qualifier.

The offending rule is `~/.local/share/uv/tools/md2-presenter/lib/python3.12/site-packages/md2/templates/default/style.css:646-649`:

```css
@media (max-width: 768px) {
    .slide table {
        display: block; overflow-x: auto; white-space: nowrap;
        margin: 30px 0; width: 100%;
    }
    /* ... */
}
```

Headless Chromium's print layout viewport falls at or below 768px → mobile rule matches in print → tables become `display: block` with `overflow-x: auto` and `white-space: nowrap` → wide tables overflow horizontally, Chrome renders a visible scrollbar at the bottom of the table in the PDF, and the content past the viewport's right edge is clipped/truncated. Exactly the same failure shape that bit `.md2-columns` in M16; M16 patched only the columns side.

The proper upstream fix is to scope the entire `@media (max-width: 768px)` block to `screen` only (tracked separately in `md2/DEVPLAN.md` as M70). That fix is the right one but propagates only after md2 is reinstalled in the user's environment, so this milestone also lands a defensive override in `render.sh` mirroring the M16 columns workaround, so all deck renders are robust regardless of which md2 build is installed locally.

- [x] **skill/render/render.sh** — extended the `PAGE_CSS` injection's `@media print { ... }` block with a print-only table override on the same pattern as the existing `.md2-columns` override:

  ```css
  .slide table {
    display: table !important;
    overflow-x: visible !important;
    white-space: normal !important;
    width: auto !important;
    max-width: 100% !important;
    margin: 30px auto !important;
  }
  ```

  The `!important` is necessary to win over the later `@media (max-width: 768px)` rule when both match. The override restores the default screen-mode table behaviour (`display: table`, content wraps, sized to fit) instead of mobile's block-with-horizontal-scroll layout.
- [x] **skill/draft/print-constraints.md** — extended rule 5 ("Tables can carry more than charts") with a "Width caveat" paragraph explaining that wide tables on A4 landscape should still fit within the printable area; if the message is "long table that needs scrolling", a table slide is the wrong pattern — split into two slides, drop a column, or convert to a vertical list. Horizontal scroll is a screen-only affordance that does not survive print.
- [x] **skill/tests/test_render.sh** — added two new assertions: one for the existing M16 `.md2-columns` override (was missing), one for the new M17 `.slide table` override. `bash tests/test_render.sh` → 40 passed, 0 failed.
- [x] `bash install.sh --force` — redeployed.
- [x] Smoke test: re-rendered `<project-dir>/presentation.md`; verified with `pdftoppm` that slide 6 ("Il portfolio climate the telco client…") and slide 9 ("I prossimi 30 giorni") show full tables, no scrollbar, content wraps naturally inside cells, rightmost column fully visible. PDF page count 10 = slide count 10.
- [ ] Push to `origin/main`.

---

# v0.3 milestones — packaging parity + real render smoke

Apply the same treatment given to the `code-audit` and `devplan` skills
in this session: flatten-for-manual-copy consistency, de-Claudize, a
broad multi-assistant installer with `--check`, and close the two real
gaps the audit lens surfaced — no test actually renders (the M14–M17
bugs were render-time and grep tests can't see them), and md2's install
URL is a literal `<OWNER>` placeholder.

Research basis (verified this session): `SKILL.md` is the cross-assistant
agentskills.io standard — Claude Code, Codex, opencode read the same
folder verbatim; Gemini uses TOML commands; AGENTS.md covers the
Cursor/Windsurf/Copilot/Aider/Continue tier.

Order: M18 → M19 → M20 → M21.

## M18 — Flatten consistency + de-Claudize ✅

**Why:** The payload dir is `skill/` — generic, so a manual
`cp -r skill ~/somewhere` is ambiguous. The other two skills use
`<skill-name>/` as the payload dir (self-describing). README is titled
"Claude Code skill" and SKILL.md frames invocation as Claude-only.

**Approach:** `git mv skill deck` so the payload folder names itself.
Update `install.sh` (`$SCRIPT_DIR/skill` → `deck`; remote-clone
`$SRC_ROOT/skill` → `deck`), every test's `REPO_ROOT/skill/...` path,
and the README repo-layout block. De-Claudize wording: README title →
neutral; SKILL.md `compatibility` and invocation phrased
assistant-agnostically (slash command / @-mention / however your
assistant invokes skills); keep the frontmatter (shared standard).

**Tasks:**
- [x] `git mv skill deck`; chmod-preserve `deck/render/render.sh`
- [x] Update `install.sh` source paths (local + remote) to `deck/`
- [x] Update all `tests/*.sh` paths `skill/` → `deck/`
- [x] De-Claudize README title + SKILL.md invocation wording
- [x] `bash tests/test_all.sh` green

**Done when:** payload is a self-describing top-level `deck/`, the suite
is green, and the wording no longer implies Claude-only.

## M19 — Multi-assistant installer ✅

**Why:** Match code-audit/devplan — install for whichever assistant the
user runs, plus manual copy, with drift detection.

**Approach:** Rewrite `install.sh` on the same design: `--target
claude|codex|opencode|gemini|agents|manual|all` (interactive menu when
no target on a TTY; default claude otherwise; keep bare-word
back-compat). claude/codex/opencode → verbatim copy of `deck/`;
gemini → `~/.gemini/commands/deck.toml` + payload in `~/.config/deck`;
agents → idempotent AGENTS.md pointer + payload in `~/.config/deck`;
manual → print the flat path. Preserve the md2/browser dependency-probe
UX (run it for the copy/gemini/agents targets, not manual). Add
`--check` per target and the `.installed-from` SHA stamp. Keep
remote-clone mode + `DECK_REPO_URL`. `render.sh` stays executable after
copy.

**Tasks:**
- [x] Rewrite `install.sh` with multi-target dispatch + menu + `--check` + SHA stamp
- [x] Gemini TOML emitter + AGENTS.md pointer (idempotent) + manual print
- [x] Preserve md2/browser dependency probes; keep render.sh +x after copy
- [x] Rewrite/extend `tests/test_install.sh` for the multi-target model (per-target install + drift, gemini toml, agents idempotency, manual no-write, render.sh executable, dep-probe present)
- [x] README install section rewritten for the `--target` flow
- [x] `bash tests/test_all.sh` green

**Done when:** `install.sh --target <x>` installs correctly for
claude/codex/opencode/gemini/agents/manual, `--check` detects drift per
target, render.sh stays executable, and the suite is green.

## M20 — Real render smoke (gated on deps) ✅

**Why:** Every test is a static grep; the M14–M17 fixes were render-time
bugs (columns collapsing, table scrollbars, frontmatter-with-comment
parsing) a grep cannot catch. A real render of a crafted fixture pins
them.

**Approach:** Add `tests/fixtures/smoke.md` exercising the regression
shapes: a leading HTML comment before frontmatter (M15), a `:::columns`
block (M16), and a wide table (M17). Add `tests/test_render_smoke.sh`:
if `md2` and a browser are absent → print SKIP and exit 0 (never a false
red on a bare CI); else run `deck/render/render.sh` on the fixture and
assert (a) HTML produced, (b) the injected print overrides present in
the HTML (`flex-direction: row`, the `.slide table` display override),
(c) PDF produced when a browser is present. Wire it into
`tests/test_all.sh`.

**Tasks:**
- [x] `tests/fixtures/smoke.md` covering the M15/M16/M17 shapes
- [x] `tests/test_render_smoke.sh` — gated skip when deps absent; real render + asserts when present
- [x] Wire into `tests/test_all.sh`
- [x] Runs green locally (with deps) and SKIPs cleanly without

**Done when:** with md2 + a browser present, the smoke renders the
fixture and asserts the print fixes hold; without them it SKIPs with a
0 exit.

## M21 — Fix md2 docs-integrity ✅

**Why:** The md2 install instructions are unfollowable: README clones
`github.com/<OWNER>/md2.git` (literal placeholder) and
`md2-cheatsheet.md` links a bare `https://github.com/`. md2 is a hard
dependency of render.

**Approach:** Replace both with the real URL
`https://github.com/guidance-studio/md2` (verified from the local md2
checkout's `origin`). Note md2 installs via its own `bash install.sh`
(uv tool install) landing binaries in `~/.local/bin`.

**Tasks:**
- [x] README md2 clone URL → `https://github.com/guidance-studio/md2.git`
- [x] `deck/draft/md2-cheatsheet.md` link → the real md2 repo URL
- [x] Verify no other `<OWNER>`/placeholder URLs remain
- [x] Suite green

**Done when:** a fresh reader can clone and install md2 from the
documented URL; no placeholder URLs remain.

## M22 — CI: run the test suite on push ✅

**Why:** code-audit got GitHub Actions in its v0.3; deck's suite only
runs locally. The 6 structural/install suites need no external deps and
should guard every push; the render smoke self-gates, so it runs for
real when md2 + a browser install on the runner and SKIPs cleanly
otherwise — no false reds.

**Approach:** `.github/workflows/tests.yml` on push-to-main + PR,
ubuntu-latest. Best-effort install of chromium (apt) and md2 (uv +
clone guidance-studio/md2 + its installer), each guarded with `|| true`
so a private-repo / network failure can't red the build — the render
smoke skips in that case. Then `bash tests/test_all.sh`. README gains a
one-line CI note.

**Tasks:**
- [x] `.github/workflows/tests.yml` — checkout, best-effort chromium + md2, run test_all.sh
- [x] Guard dep installs with `|| true`; export `~/.local/bin` on PATH for md2
- [x] README: note CI runs the suite on push (render smoke gated on deps)
- [x] Local `bash tests/test_all.sh` still green; workflow YAML is valid

**Done when:** the workflow runs `tests/test_all.sh` on push; the
structural/install suites are guarded on every push, and the render
smoke runs when deps are available, skips otherwise — the build never
reds on missing md2/browser.

## Out of scope for v0.3

- Per-assistant behavior divergence (one flat payload).
- Native non-SKILL.md integrations beyond Gemini TOML + AGENTS.md.
- Bundling/vendoring md2 or the browser; uninstall; telemetry.

---

# 2026-06-27 — Authoring rules + render template support

Three changes landed together this session:

1. **No title-only slides.** A slide carrying only its `## H2` (a bare section divider / pure transition) is no longer allowed. Every slide — transitions included — must carry at least one line of framing/body under the title.
   - `deck/draft/slide-patterns.md` — pattern 2 (Section divider) rewritten: example now shows H2 + one framing line; bare-H2 is called out as not allowed.
   - `deck/draft/print-constraints.md` — rule 6 exception that exempted section dividers removed; replaced with a "no title-only slides" rule (dividers still capped at 2-3 per deck).
   - `deck/draft/prompt.md` — Step 4 sanity check, Step 5 writing rule, and Step 6 self-check all updated to forbid title-only slides.

2. **Landscape is the explicit default.** Portrait is chosen only when necessary (e.g. a printed report-style leave-behind) or when the user explicitly asks.
   - `deck/brief/prompt.md` — Step 3 Orientation reworded to make landscape the default-for-almost-everything and portrait the exception.
   - `deck/draft/prompt.md` — Step 5 orientation comment guidance reinforced accordingly.

3. **`render.sh` supports custom md2 templates.** Resolution precedence: CLI `--template NAME` → `<!-- deck-template: NAME -->` comment in the source md → none (md2's default template). The no-template path is byte-for-byte the previous `md2 "$INPUT_ABS"` call, so existing renders/tests are unaffected.
   - `deck/render/render.sh` — `--template NAME` flag parsing (value-required, like `--paper`), template resolution before the md2 call, conditional `md2 --template`/`md2` invocation, usage/help comment block + `--help` range updated.
   - `deck/render/prompt.md` — documents `--template NAME` and the `<!-- deck-template: NAME -->` comment with the CLI → comment → none precedence; keeps the "only render.sh, don't improvise" stance.
   - `deck/draft/prompt.md` — Step 5 notes that an optional `<!-- deck-template: NAME -->` comment can be emitted at the end of the file alongside the orientation/paper comments.

---

# 2026-07-05 — Fix: print `.slide table` override breaks chart tables

**Bug:** the M17 defensive print override in `render.sh` — added to stop
long markdown tables from getting a scrollbar/truncated columns in print
(mobile media query leaking into print, see md2 M70/M17) — targets
`.slide table` with `!important`:

```css
.slide table { display: table !important; overflow-x: visible !important;
  white-space: normal !important; width: auto !important;
  max-width: 100% !important; margin: 30px auto !important; }
```

`table.charts-css` (md2's bar/column/pie/line chart markup) is *also* a
`<table>` inside `.slide`, so this selector catches it too. `width: auto
!important` / `max-width: 100% !important` override the chart's own
sizing rules, which Charts.css needs to correctly compute `--size`
percentages for bars/columns. Result: in print, chart tables collapse
to a tiny fraction of their intended width — bars render as slivers,
and data-value text (e.g. "4.3") wraps character-by-character inside
the collapsed cell instead of fitting on one line.

Confirmed by rendering a real deck (Subaru BEV benchmark) with a
`:::chart bar` block: with `render.sh`'s injected override in place,
every bar rendered as a narrow, disproportionate strip regardless of
its data value. Stripping just that `<style>` block from the generated
HTML and re-printing to PDF made the bars render correctly (full width,
correct relative proportions) — isolating the override as the cause.

**Fix:** exclude chart tables from the override — `.slide table:not(.charts-css)`.
Regular markdown tables (the M17 target) don't carry the `charts-css`
class, so they're unaffected; chart tables now fall through to their
own CSS.

**Tasks:**
- [x] `deck/render/render.sh`: `.slide table` → `.slide table:not(.charts-css)` in the injected print `<style>` block.
- [x] `tests/test_render.sh`: existing M17 assertion still matches (substring, unaffected by `:not()`); added a behavioral test rendering a deck with a `:::chart bar` block and asserting the injected CSS doesn't apply to `table.charts-css`.
- [x] Re-rendered the real Subaru deck via `render.sh`, confirmed bars fill available width proportionally in the printed PDF.
- [x] Full test suite green.

**Done when:** `render.sh`'s print override no longer touches chart
tables; a deck with both a markdown table and a `:::chart` block prints
correctly for both.

---

# 2026-07-18 — M23: kill "punchline", the headline rule is producing guru copy

**Reported by Paolo, on a real deck** (Edison training session). The `deck`
skill drafted an act divider reading *"Sette atti, due ore, un terminale. Le
slide portano i comandi; il lavoro lo fa il terminale."* — a rhetorical triad
followed by a chiasmus. His verdict: *"niente frasi da fuffaguru magic jargon
fuffa. siamo una realtà professionale, non cazzari."*

**Root cause: the skill instructs this.** `copy-rules.md` rule 1 is titled
"Headline = punchline, not topic". "Punchline" names a *joke's payoff*, so a
model optimising for it produces wordplay, antithesis, sentence fragments for
emphasis, and triads. The rule's actual intent — say the conclusion, not the
label — is correct and stays. Only the word and the register it summons are wrong.

**Scope correction from Paolo:** this is NOT "punchy for boards, plain for
training". *"neanche davanti al board voglio punchline, voglio una frase che
sintetizzi le cose importanti da sapere."* So the fix is unconditional — no
audience-dependent switch, no register toggle.

**The replacement concept:** a headline is **the sentence that summarises what
matters on the slide**. Three-way distinction to teach, since the failure mode
is drifting past the target into slogan:

| ❌ Topic label | ❌ Slogan / punchline | ✅ Informative summary |
|---|---|---|
| "Dati di mercato" | "Il mercato non aspetta i lenti" | "Il mercato IA italiano cresce del 50% annuo" |
| "Compliance" | "La compliance non è un documento" | "La responsabilità resta al titolare, anche usando un fornitore" |

**Tasks:**
- [x] `deck/draft/copy-rules.md` rule 1 — retitle to "Headline = the sentence that summarises what matters"; replace the 2-column bad/good table with the 3-column table above so the slogan column is explicitly rejected; keep the "could this appear unchanged on another deck?" test.
- [x] `deck/draft/copy-rules.md` — new **banned constructions** subsection alongside rule 7 (which today bans filler *phrases* but permits these): rhetorical triads, antithesis for effect, chiasmus, sentence fragments for emphasis, aphorisms, wordplay on the subject matter.
- [x] `deck/draft/copy-rules.md` rule 10 — "cover headline test" drops "punchline" phrasing.
- [x] `deck/draft/prompt.md` ×3 — step 3 ("headline-as-punchline" outline), step 5 (cover as punchline), step 6 checklist item.
- [x] `deck/draft/slide-patterns.md` — check pattern 1 (cover), 2 (section divider) and 2b (chapter cover) example copy for the same register; chapter subtitles are where it surfaced.
- [x] `DEVPLAN.md` line ~124 — the "Headline = punchline" summary line.
- [x] Tests: `tests/test_draft.sh:66` asserts `punchline|takeaway|conclusion` — an alternation, so it stays green on "takeaway". Add an assertion that the banned-constructions rule exists, so this can't silently regress.
- [x] `./install.sh --force`, then re-run the full suite.

**⚠️ Precondition:** the dev tree already carries uncommitted WIP not from this
session (`DEVPLAN.md`, `deck/render/render.sh`, `tests/test_render.sh` — the
chart-table print fix). Commit or stash that first so M23 lands as its own diff.

**Done when:** no file in the skill instructs "punchline"; the rule teaches the
three-way distinction; banned constructions are listed explicitly; suite green
and deployed.
