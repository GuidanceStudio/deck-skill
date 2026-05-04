---
name: deck
description: Generate a business presentation in three staged artifacts — brief, md2-compliant markdown, and rendered HTML/PDF. Use `/deck brief` to capture audience, objective, format, brand, and content; `/deck draft` to turn the brief into a deck following slide patterns, copywriting rules, and print constraints; `/deck render` to produce the HTML and PDF via md2 and headless Chrome. Each stage reads the previous artifact from the current working directory.
compatibility: Requires md2 (markdown-to-HTML presentation converter) and a Chromium-family browser (chromium, google-chrome, chromium-browser, chrome, brave-browser, or brave) on $PATH; firefox 102+ works as a last-resort fallback. Designed for Claude Code or compatible agents.
---

# Deck — Router

This skill builds a business presentation in three stages. Each stage produces a file that feeds the next.

## Prerequisites

This skill orchestrates two external tools. If either is missing, `/deck render` will fail with a clear message.

- **md2** — markdown-to-HTML presentation converter. Install: clone the md2 repo and run its installer (e.g. `bash install.sh`). It typically lands `md2` in `~/.local/bin/`. Make sure that directory is on `$PATH`.
- **Chromium-family browser** — for HTML-to-PDF rendering. The skill auto-detects, in this order: `chromium`, `google-chrome`, `chromium-browser`, `chrome`, `brave-browser`, `brave`. Firefox 102+ is supported as a last-resort fallback (slower; may hang on Linux snap installs). On Linux: `apt install chromium-browser` (or distro equivalent). On macOS: install Google Chrome or Brave.

The README in this skill's repository has the long-form install instructions.

## Artifact pipeline

All artifacts land in the user's **current working directory** (CWD) with fixed filenames:

| Command         | Reads (CWD)                  | Writes (CWD)                                  |
|-----------------|------------------------------|-----------------------------------------------|
| `/deck brief`   | user interview               | `presentation-brief.md`                       |
| `/deck draft`   | `presentation-brief.md`      | `presentation.md`                             |
| `/deck render`  | `presentation.md`            | `presentation.html` and `presentation.pdf`    |

If the required input file is missing from CWD, stop and offer the user two paths: (a) run the previous subcommand first, or (b) paste the content inline. Never invent input silently.

## Language rules (apply to every subcommand)

- **Chat**: reply in the user's language — always.
- **Artifact (the generated file)**: English by default. At the start of a session, if the user has not specified a language yet, ask once: *"Artifact language? (default: English)"*. If the user has already indicated a language (e.g., "rispondi in italiano", "artifact in spagnolo"), honor it without asking.
- The user can change artifact language any time during the session; honor the latest instruction.

## Routing

Parse the first argument after `/deck`:

- `brief` → read `brief/prompt.md` and follow it end-to-end.
- `draft` → read `draft/prompt.md` and follow it end-to-end. The draft prompt references `draft/slide-patterns.md`, `draft/copy-rules.md`, `draft/md2-cheatsheet.md`, and `draft/print-constraints.md`; load each one lazily, only when the prompt directs you to.
- `render` → read `render/prompt.md` and follow it end-to-end.
- **no argument, or an unknown argument** → show this 3-line menu and ask which one to run:
  - `brief`  — interview about audience, objective, format, brand; write `presentation-brief.md`
  - `draft`  — turn the brief into a md2-compliant deck; write `presentation.md`
  - `render` — convert the deck to HTML and PDF; write `presentation.html` and `presentation.pdf`

## Subcommand isolation

Each branch reads only its own folder. Do not pre-load other subcommands' files. The `draft/` knowledge files are loaded only when in the `draft` branch, lazily as the prompt references them.

## Source of truth

The instructions inside each subcommand's `prompt.md` (and the sibling knowledge files in `draft/`) are the source of truth for that subcommand's behavior. This router file only dispatches — it does not override subcommand rules.
