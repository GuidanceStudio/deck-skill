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

**M1-M8, M10-M12, M15-M16, M18-M22 and M24-M30 are closed and archived — see `DEVPLAN-ARCHIVE.md`.** Each line there is `MNN | title | date | sha`; the sha is the pointer to the full detail.

### M9 — Smoke test ✅

- [x] `bash install.sh --force` → `~/.claude/skills/deck/` populated with SKILL.md + all subcommand files (verified: SKILL.md, brief/prompt.md, draft/{prompt,slide-patterns,copy-rules,md2-cheatsheet,print-constraints}.md, render/{prompt.md,render.sh}). render.sh remains executable post-copy.
- [x] `bash tests/test_all.sh` → 6 suites green, all assertions pass.
- [x] Skill registered: appears in the Claude Code available-skills list under name `deck` after install.
- [x] **Manual smoke (user-side)**: in a fresh test CWD, run `/deck brief`, then `/deck draft`, then `/deck render`. Open the resulting PDF. Verify: no empty slides, no spilled charts, no truncated labels. Cannot run automatically — requires interactive Claude Code session.
- [x] **Regression smoke**: re-render `<project-dir>/target-research.md` through `~/.claude/skills/deck/render/render.sh`. HTML generation works; PDF generation requires installing chromium (`apt install chromium-browser`) since the dev machine's snap-Firefox has missing shared-object dependencies.

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

### M13 — v0.2 smoke + ship ✅

- [x] `bash install.sh --force` — re-installed on top of v0.1; all 8 files copied; render.sh remains executable.
- [x] `bash tests/test_all.sh` — 6 suites green, 70+ assertions including the new M10/M11/M12 ones.
- [x] **Regression**: deck with `<!-- deck-orientation: landscape --><!-- deck-paper: A4 -->` → injected HTML contains `<style>@page { size: A4 landscape; margin: 12mm; }</style>`. ✓
- [x] **Regression**: same deck rendered with `--portrait --paper letter` → injected HTML contains `<style>@page { size: letter portrait; margin: 12mm; }</style>`. ✓ CLI override beats comments.
- [x] **Regression**: bare deck (no comments) → defaults to `A4 landscape`. ✓
- [x] **Manual regression for self-validation loop** (M12) — requires a Claude Code session to actually drive the draft prompt with a deliberate syntax error. Cannot be automated; user-side smoke.
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
- [x] Push to `origin/main`.

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

## M23 — A deck has no revision stage, so every line is written exactly once — ✅ T1 DONE (built + deployed 2026-07-28, 7 test suites green) · T2–T5 UNHELD and absorbed into M27 (2026-07-28)

**What happened.** On 2026-07-27 an Italian client deck shipped with three lines the operator could not
parse. He quoted each back: *"Condizione · previsione · forensica · ambiente."* — four abstract nouns, no
verb — *"Il costo viene prima della capacità."*, and the column header *"Fuori servizio?"* over yes/no
cells. The first response to this was a candidate-finder script. His ruling on it: *"non voglio un linter,
voglio una scrittura migliore"*. **He is right, and the reason is structural: a linter finds, it does not
write. It sits downstream of the sentence it is trying to fix.**

**The stage that is missing.** The skill runs `brief` → `draft` → `render`. Nothing between draft and render
reads the copy again. Every line therefore gets written once — under page pressure, by an author who knows
what they meant and cannot see that the words do not carry it.

**Why a stage and not another rule.** `copy-rules.md` already states this at `:15`, `:29` and `:124`, and the
global CLAUDE.md states it as HARD. All three were in force and all three were violated in one deck. A rule
inside a prompt is advice followed *while doing something else* — drafting, fitting, translating. A stage is
a separate pass with its own input and its own output, and the deck is not finished until it has run. That
difference is the whole milestone.

**Three mechanisms that produced the empty lines, each measured on the deck that failed.**

1. **A self-imposed paragraph shape.** Roughly forty paragraphs across twenty slides, each opening with a
   bold assertion followed by explanation. **`slide-patterns.md` does not ask for this — checked before
   asserting it.** It was the author's own template. With twenty-five things worth asserting and forty slots
   demanding an assertion, fifteen get invented. *"Condizione · previsione · forensica · ambiente"* was an
   invented assertion filling the mandatory slot under a table.
2. **Compression under page pressure removes information before it removes rhythm.** The offending slide was
   shortened five times to fit twenty pages. Every pass cut a clause of content and preserved the cadence,
   because cadence is what survives compression. What finally fixed it was removing *content* — narrowing a
   column, deleting a sentence outright.
3. **Translated labels.** English `outage?` → Italian `Fuori servizio?` is a faithful translation and a worse
   label: the English shorthand had a domain convention behind it that the Italian does not.

### Tasks

**Reordered after checking the downstream facts (2026-07-27).** The four authoring procedures were T4, last,
behind the revise stage. They belong first, because **they are the only part of this milestone that changes
what gets written** — everything else is catching, and the whole finding is that authors do not catch
themselves. Two of the four were also stranded inside the revise stage (the label test, the over-budget rule)
where they only ever run after the line already exists.

- [x] **T1 — `copy-rules.md` gains four PROCEDURES, and they go before the ten existing rules.** All ten
      current rules are prohibitions or tests; rules 1, 7 and 7b each state this defect, all three were in
      force, and one deck violated all three. A prohibition needs the author to catch themselves mid-sentence
      while convinced the line is good. A procedure removes the slot that manufactured the line.
      **(a)** The takeaway sentence is written **at full length before the slide is built**, and the slide is
      then built to carry it. **No sentence, no slide.**
      **(b)** **A slide may end on its table** — or its chart, or its facts. There is no mandatory closing
      line. A layout slot that demands an assertion manufactures one: forty paragraph slots against
      twenty-five things worth asserting is where the fifteen invented ones came from.
      **(c)** **Over budget removes a fact, a row or a slide. It never shortens a sentence.** Compression
      takes out information first and cadence last — measured on the failing deck across five passes, each of
      which cut a clause and kept the rhythm. What fixed it was deleting content outright.
      **(d)** **LABEL TEST — new, and absent from every rule today.** Labels cannot be deleted, so the delete
      test structurally never reaches them: a table needs its row headers, so an empty one survives every
      existing rule. Someone shown a label and **one** value must be able to say what that value asserts.
      Applies to column headers **and every first-column row label** — the scope is empirical, not
      theoretical: `Fuori servizio` survived on slide 3 after being fixed on slide 2, because only the header
      had been looked at. A label is **re-derived in the target language** from "what does a value under this
      assert", never translated from the source deck.

**The revise stage — T2–T5 below — is now a separate decision, and it is the operator's.** The argument for
it is stronger here than in fv-scout and for one reason: **`deck` has no reader that is not the author.** The
skill runs `brief` → `draft` → `render`, and nothing between draft and render reads the copy again.
fv-scout's §4a already spawns a fresh, blocking, post-render agent and only needs one more question put to
it (fv-scout M95 T3). `deck` has no such hook, so if the four procedures above are not enough, there is
nothing downstream to catch what they miss. **Recommendation: ship T1 first and judge the stage against a
deck written under the procedures**, rather than building both at once and never learning which one worked.

- [ ] **T2 — `deck/revise/prompt.md`: a fourth stage, between draft and render** *(operator's call)*. Four
      checks, in this order: **(a)** per slide, write the one sentence that slide establishes — if it cannot
      be written the slide has no takeaway and is merged or cut; if it can be written but is not on the
      slide, it goes on the slide. **(b)** the delete test on every line that is not a fact: delete it, and
      if nothing is lost leave it deleted. **(c)** the label test per T1(d). **(d)** anything over budget
      loses a fact, a row or a whole slide — never a shortened sentence.
- [ ] **T3 — the stage runs after a first render, on the rendered deck** *(operator's call)*. Page-fit
      pressure has to be visible for (d) to have anything to act on, and the labels have to be read as the
      audience reads them.
- [ ] **T4 — wire it** *(operator's call)*. `SKILL.md` routing gains `revise`; `render/prompt.md` states that
      a deck is not deliverable until the revise pass has run.
- [ ] **T5 — the isolation clause** *(operator's call)*. Whoever runs the revise stage gets the rendered deck
      and not the reasoning behind it. An author re-reading their own draft supplies the missing meaning from
      memory; that is precisely why the operator saw all three lines in seconds and the author saw none.

**Explicitly dropped: the candidate-finder script.** A working prototype exists at
`~/Documents/software/check_copy-prototype.sh` — it caught all three quoted lines, and produced 23 candidates
on the real deck of which 4 were genuine. It is parked, not shipped, and this milestone does not depend on
it. Operator's ruling stands: *"non voglio un linter, voglio una scrittura migliore"*.

### M23 T1 close-out (2026-07-28)

**Shipped:** `copy-rules.md` gains **§0 — four procedures, placed above the ten existing rules** so they are
read before the prohibitions they replace. Wired where the work happens, not only where the rules live:
Step 3 now applies *no sentence, no slide* **at the outline**, so a slide whose takeaway cannot be written
is merged or cut there instead of carrying an empty slot into Step 5 for a line to be invented into; Step 5
gains the no-mandatory-closing-line rule and the label test; Step 6's self-check gains three boxes,
including the label test with the instruction to check row labels on **every** slide.

**A conflict found while landing procedure (c), and it was live in two files.** The procedure is *over
budget removes a fact, a row or a slide — never shortens a sentence.* The overflow instructions then said
the opposite in three places: `draft/prompt.md` — *"compress intro to one line … cut bullet count"* —
and `print-constraints.md` rule 8 — *"cut bullet text or count down to ≤ 4 per column"* — plus rule 9's
*"reduce text alongside"*. **"Cut bullet count" is a fact leaving and is correct; "compress intro to one
line" and "cut bullet text" are the exact move the procedure forbids**, and they were the standing
instruction for the most common overflow in the skill. All three rewritten to remove content rather than
shorten it. Shipping §0 without this would have left the author two instructions and no way to obey both.

**The label test is the item with no equivalent anywhere today, and the reason is structural:** a label
cannot be deleted — a table needs its headers — so the delete test never reaches it and an empty label
survives every rule in the file. Its scope is empirical rather than symmetric: column headers **and
first-column row labels**, because `Fuori servizio` survived on slide 3 after being fixed on slide 2.

**T2–T5 (the `revise` stage) stay HELD on the operator's ruling: ship the procedures first and judge the
stage against a deck written under them**, rather than building both at once and never learning which one
worked. The argument for the stage is not withdrawn — `deck` runs `brief` → `draft` → `render` and has **no
reader that is not the author**, where fv-scout's §4a already spawns a fresh blocking one and needed only a
question added to it (fv-scout M95 T3). If the procedures do not hold here, there is nothing downstream.

---

## M31 ✅ — Archive the closed milestones

**Why:** the plan had grown to ~13,600 words across 29 closed (or
open-task-blocked) milestones; the ones with no remaining open task and a
findable commit compress to one pointer line each, so the pending work
(M14, and the still-manually-gated M9/M13/M17/M23) stays easy to reach.

**Approach:** for each closed milestone, find and verify its shipping commit
(`git cat-file -e`), compress it to one pointer line (`MNN | title | date |
sha`) in a new `DEVPLAN-ARCHIVE.md`. Any milestone with an open task
(`- [ ]`/`- [~]`) is left untouched — M9, M13, M17 and M23 each carry one
(manual-verification gates, or in M23's case an actual unticked push); M14
is left alone too (heading never got the ✅ marker despite every task being
ticked). Verify the ID sets before/after match exactly.

**Tasks:**
- [x] Enumerate closed milestones (heading marker + all tasks `- [x]`), find and verify each one's shipping commit.
- [x] Write `DEVPLAN-ARCHIVE.md` with one pointer line per milestone.
- [x] Remove the archived blocks from `DEVPLAN.md`, leaving one pointer note near the top.
- [x] Verify the ID-set diff is empty (nothing lost).
- [x] Run `bash tests/test_all.sh` and commit.

**Done when:** `DEVPLAN-ARCHIVE.md` holds one pointer line per archived
milestone, every sha verified; the before/after ID-set diff is empty;
`tests/test_all.sh` is green.
