# `deck` — presentation skill

Generate a business presentation in three staged artifacts: **brief → draft (md2 markdown) → rendered HTML/PDF**. Each stage reads the previous one, so you can iterate on positioning and narrative before touching the visual output.

Assistant-neutral — the `deck/` folder is the whole skill; install it into Claude Code, Codex, opencode, Gemini CLI, or any tool that reads skills (see [Install](#install)).

The skill bakes in:
- A **library of slide patterns** (cover, hero stat, two-column compare, quote, process, chart, table, …) with ready-to-paste md2 syntax.
- **Copywriting rules** for headlines, parallel bullets, concrete numbers, no filler — the kind of thing that makes a deck land in a board meeting.
- **Print-aware constraints** that prevent the most common bugs: charts spilling to the next page, label truncation when value ratios exceed ~10x, slides with too much copy + visual at once.

## Install

The installer is multi-assistant. Run it with no target for an
interactive menu, or pass `--target`:

```bash
git clone https://github.com/GuidanceStudio/deck-skill.git && cd deck-skill
./install.sh                      # interactive menu
./install.sh --target claude      # ~/.claude/skills/deck/
./install.sh --target codex        # ~/.codex/skills/deck/
./install.sh --target opencode     # ~/.config/opencode/skills/deck/
./install.sh --target gemini        # ~/.gemini/commands/deck.toml (+ payload)
./install.sh --target agents        # AGENTS.md pointer for Cursor/Windsurf/Copilot/Aider/Continue
./install.sh --target all           # claude + codex + opencode
./install.sh --target manual        # print the folder path; copy it yourself
```

Remote one-liner (no clone; needs `git` + `curl`):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/GuidanceStudio/deck-skill/main/install.sh) --target claude
```

`claude`, `codex`, and `opencode` get the `deck/` folder copied verbatim
— it's the shared [agentskills.io](https://agentskills.io) `SKILL.md`
standard, so one payload serves all three. `gemini` gets a generated
TOML command; `agents` writes an [`AGENTS.md`](https://agents.md)
pointer for the broad tier. Flags: `--force` (overwrite + skip the
dependency prompt), `--check` (report `OK`/`DRIFT` vs source, per
`--target`), `--agents-dir DIR`. The installer probes for md2 + a
browser and warns if missing. Or skip it — `deck/` is self-contained,
copy it anywhere your tool reads skills.

## Requirements

The skill orchestrates two external tools — a markdown converter and a browser. The installer checks both
and warns if missing. Everything here is bash, so on Windows that is the first thing to sort out.

| What | Why | Linux | macOS | Windows |
|---|---|---|---|---|
| **bash** | `install.sh`, `render.sh` | native | native | **WSL2** (recommended — then follow the Linux column inside it) or **Git Bash** |
| **uv** | installs md2 | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | same | `powershell -c "irm https://astral.sh/uv/install.ps1 \| iex"` |
| **md2** | markdown → HTML | `uv tool install md2-presenter` | same | same |
| **a browser** | HTML → PDF | `sudo apt install chromium-browser` | Chrome or Brave | **Edge is already there**; inside WSL2, `sudo apt install chromium-browser` |

### md2

`md2-presenter` is on **PyPI** as a pure-Python wheel (Python ≥ 3.9), so one command installs it on all
three systems with no account and no clone:

```bash
uv tool install md2-presenter
```

`uv` puts the executable on your `PATH` itself. To work *on* md2 rather than just use it, clone
`github.com/guidance-studio/md2` and run its `install.sh`, which does `uv tool install .` from source.

**The wheel ships one template, `default`.** Brand templates are separate — they install into
`~/.md2/templates/` and are selected with `<!-- deck-template: NAME -->` or `--template NAME`. The Forest
Valley one lives at `fv-institute/md2-template-forestvalley` (private); Guidance Studio's is in
`gitlab.com/guidance-studio/templates/md2`. **md2 fails loudly on a template it cannot find**, so a
missing brand template is an error, not a silent fallback.

Brand templates load their fonts from Google Fonts **at render time**. An offline machine renders with
fallback system fonts.

### Browser for HTML → PDF

The render script auto-detects, in this order: `chromium`, `google-chrome`, `chromium-browser`, `chrome`,
`brave-browser`, `brave`, `msedge`, `msedge.exe`, `firefox` (102+).

Chromium-family is preferred (higher CSS fidelity in print). Brave and **Edge** are chromium derivatives
and produce identical output — which is why nothing extra needs installing on Windows. Firefox is a
last-resort fallback: it works, but on Linux snap installs `firefox --headless --print-to-pdf` can hang
for several minutes, so install any chromium-family browser to avoid that path.

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
- **`/deck render`** — runs `md2` for HTML, then headless Chrome / Firefox for PDF. Honors orientation and paper-size choices captured in the brief (default landscape A4); CLI flags `--landscape` / `--portrait` / `--paper A4|letter` override on a one-off basis. Pass `--no-pdf` to produce HTML only.

### Language

- **Chat** replies are always in the user's language.
- **Artifact files** default to English. Tell the skill at any point ("rispondi in italiano", "artifact en español") and it will honour it.

## Repo layout

```
deck/                           # the flat skill payload (copied verbatim by install.sh)
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

CI (GitHub Actions) runs the suite on every push and PR. The structural
and install suites need no external tools; the render smoke runs for
real when md2 + a browser install on the runner and skips cleanly
otherwise, so a missing dependency never reds the build.
