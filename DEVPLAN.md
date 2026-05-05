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
- [ ] Push to `origin/main`.
