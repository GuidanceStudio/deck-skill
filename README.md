# `deck` — Claude Code skill

Generate a business presentation in three staged artifacts: **brief → draft (md2 markdown) → rendered HTML/PDF**. Each stage reads the previous one, so you can iterate on positioning and narrative before touching the visual output.

The skill bakes in:
- A **library of slide patterns** (cover, hero stat, two-column compare, quote, process, chart, table, …) with ready-to-paste md2 syntax.
- **Copywriting rules** for headlines, parallel bullets, concrete numbers, no filler — the kind of thing that makes a deck land in a board meeting.
- **Print-aware constraints** that prevent the most common bugs: charts spilling to the next page, label truncation when value ratios exceed ~10x, slides with too much copy + visual at once.

## Install

### Local (from this repo)

```bash
bash install.sh
```

Use `--force` to overwrite an existing installation without a prompt.

### Remote (no clone)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/deck/main/install.sh)
```

Both modes land at `~/.claude/skills/deck/`. Restart Claude Code to pick up the skill.

## Requirements

The skill orchestrates two external tools. The installer checks both and warns if missing.

### md2 — markdown → HTML presentation converter

```bash
# Clone and run the bundled installer
git clone https://github.com/<OWNER>/md2.git
cd md2 && bash install.sh
```

This puts `md2` in `~/.local/bin/`. Make sure that's on your `$PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Browser for HTML → PDF

The render script auto-detects, in this order: `chromium`, `google-chrome`, `chromium-browser`, `chrome`, `firefox` (102+).

Chromium-family is preferred (higher CSS fidelity in print). Firefox is a working fallback.

- **Linux**: `sudo apt install chromium-browser` — or distro equivalent.
- **macOS**: install Google Chrome from [chrome.google.com](https://chrome.google.com).
- **Already have Chrome installed?** No action needed.

If neither browser is available, you can still use `/deck render --no-pdf` to generate the HTML only.

## Usage

Run the three subcommands in order, from your project directory:

| Command          | Input (read from CWD)        | Output (written to CWD)                |
|------------------|------------------------------|----------------------------------------|
| `/deck brief`    | — (interactive interview)    | `presentation-brief.md`                |
| `/deck draft`    | `presentation-brief.md`      | `presentation.md` (md2-compliant)      |
| `/deck render`   | `presentation.md`            | `presentation.html` + `presentation.pdf` |

`/deck` without arguments shows the menu.

### What each subcommand does

- **`/deck brief`** — short structured interview: audience, objective, format (deck vs leave-behind), length budget, brand palette, mandatory vs optional content, language.
- **`/deck draft`** — reads the brief, walks you through content gathering (key data, claims, sources), proposes a narrative arc (Pyramid / SCQA / 3-act), maps each beat to a slide pattern, then writes the full md2 markdown applying copywriting and print-stamp constraints.
- **`/deck render`** — runs `md2` for HTML, then headless Chrome for PDF. Optionally checks for empty/spill issues and reports them.

### Language

- **Chat** replies are always in the user's language.
- **Artifact files** default to English. Tell the skill at any point ("rispondi in italiano", "artifact en español") and it will honour it.

## Repo layout

```
skill/                          # copied to ~/.claude/skills/deck/ by install.sh
├── SKILL.md                    # router + language rules
├── brief/
│   └── prompt.md               # interview script
├── draft/
│   ├── prompt.md               # writer (orchestrates the others)
│   ├── slide-patterns.md       # 12+ patterns with md2 examples
│   ├── copy-rules.md           # headline-first, 6x6, parallel bullets
│   ├── md2-cheatsheet.md       # frontmatter, columns, charts syntax
│   └── print-constraints.md    # chart ratios, page-break, pie sizing
└── render/
    ├── prompt.md               # how to invoke render.sh + handle errors
    └── render.sh               # md → html → pdf pipeline

install.sh                      # local + remote installer
tests/                          # bash test suite
DEVPLAN.md                      # planned work, milestone-by-milestone
```

## Tests

```bash
bash tests/test_all.sh
```
