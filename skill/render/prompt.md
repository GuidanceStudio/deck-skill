# `/deck render` — Convert markdown deck to HTML + PDF

> **This subcommand has exactly one job: invoke the bundled `render.sh` and report. Do not improvise. Do not invent an alternative pipeline.**

## What this subcommand does

Read `presentation.md` from the **current working directory** (CWD), invoke the bundled `render.sh` script, and produce two files: `presentation.html` and `presentation.pdf` (also in CWD). Report both paths back to the user.

## Hard rules (read before doing anything)

These rules exist because past runs occasionally drifted — the agent reached for `playwright`, `weasyprint`, custom Python wrappers, or hand-rolled `chrome --headless` invocations instead of using the bundled script. The script already handles browser detection, error codes, paper size, orientation, and CSS injection. There is nothing to be gained by rolling your own.

**Do:**

- Call exactly this command (substituting the optional flags as needed):

  ```bash
  bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md"
  ```

  Optional flags: `--no-pdf`, `--landscape`, `--portrait`, `--paper A4`, `--paper letter`. They are documented in `render.sh --help`.

- Surface the script's `stdout` and `stderr` to the user **verbatim**. Do not paraphrase. Do not silently swallow output. The script is the source of truth — its messages and exit code drive the user-facing report.

- Trust the exit code. If the script returns 0, both files exist as expected. If non-zero, follow the exit-code table below.

**Do not:**

- Do not invoke `md2` directly. The script does it.
- Do not invoke `chromium`, `google-chrome`, `chrome`, `chromium-browser`, or `firefox` directly. The script does it.
- Do not install or use `playwright`, `puppeteer`, `weasyprint`, `pandoc`, `wkhtmltopdf`, or any other markdown/HTML-to-PDF tool. None of them are part of this skill.
- Do not write a custom Python or Node script that wraps the pipeline. The bash script is the pipeline.
- Do not Read the generated HTML to "double-check" before render.sh has finished — the script's exit code is the source of truth.
- Do not retry on partial errors with different tools. Either run the same command again, or surface the error to the user.

## Inputs

- `presentation.md` in CWD (produced by `/deck draft`).

If the file is missing, stop and offer two paths:
1. Run `/deck draft` first.
2. Point to a different filename and we'll use that as input.

## Outputs

- `<input>.html` (always)
- `<input>.pdf` (unless `--no-pdf` requested)

For the standard `presentation.md`, that means `presentation.html` and `presentation.pdf` next to it.

## Language

Language behavior is governed by the router (`SKILL.md`). Chat in the user's language; this subcommand produces no human-readable artifact text on its own beyond the success/error report.

## How to invoke

The render script lives at `~/.claude/skills/deck/render/render.sh` after install. Always pass the **absolute path** to the input markdown.

Standard call:

```bash
bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md"
```

With optional flags:

| Use case                                | Command                                                                                  |
|-----------------------------------------|-----------------------------------------------------------------------------------------|
| HTML only, no PDF                       | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --no-pdf`         |
| Force landscape (override deck comment) | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --landscape`      |
| Force portrait                          | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --portrait`       |
| Force paper size                        | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --paper letter`   |

Orientation and paper size are usually picked up automatically from the `<!-- deck-orientation: ... -->` and `<!-- deck-paper: ... -->` comments at the top of `presentation.md` (written by `/deck draft`). The CLI flags are an override, used only when the user explicitly asks for a different orientation than what the deck declared.

## Error handling

The script exits with distinct codes per failure mode. Surface the error message verbatim to the user, then explain the fix:

| Exit code | Meaning                                  | What to tell the user                                                |
|-----------|------------------------------------------|---------------------------------------------------------------------|
| 1         | Missing or unreadable input file         | Confirm the filename; suggest running `/deck draft`.                  |
| 2         | `md2` not on `$PATH`                     | Point them to the README → Requirements → md2 install instructions.   |
| 3         | No Chromium-family browser found         | Point them to install Chrome/Chromium, or re-run with `--no-pdf`.    |

If the script exits 0, both the HTML and (if requested) the PDF were generated successfully.

## Reporting completion

On success, report to the user:
- The two file paths produced.
- A short hint: "Open the PDF and visually check for empty slides, truncated chart labels, or charts on lonely pages — if you see any, run `/deck draft` again with the issue noted."

This keeps the loop tight: render → human eyeball → if needed, re-draft.
