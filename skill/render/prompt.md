# `/deck render` — Convert markdown deck to HTML + PDF

## What this subcommand does

Read `presentation.md` from the **current working directory** (CWD), invoke the bundled `render.sh` script, and produce two files: `presentation.html` and `presentation.pdf` (also in CWD). Report both paths back to the user.

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

The render script lives at `~/.claude/skills/deck/render/render.sh` after install. Invoke it via Bash with the **absolute path** to the input markdown:

```bash
~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md"
```

If the user explicitly asked for HTML-only (no PDF), pass `--no-pdf`:

```bash
~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --no-pdf
```

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
