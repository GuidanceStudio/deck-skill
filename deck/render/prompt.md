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

  Optional flags: `--no-pdf`, `--landscape`, `--portrait`, `--paper A4`, `--paper letter`, `--template NAME`, `--embed-images`, `--page-css FILE`, `--post-html CMD`. They are documented in `render.sh --help`.

- Surface the script's `stdout` and `stderr` to the user **verbatim**. Do not paraphrase. Do not silently swallow output. The script is the source of truth — its messages and exit code drive the user-facing report.

- Trust the exit code. If the script returns 0, both files exist as expected. If non-zero, follow the exit-code table below.

**Do not:**

- Do not invoke `md2` directly. The script does it.
- Do not invoke `chromium`, `google-chrome`, `chrome`, `chromium-browser`, `brave-browser`, `brave`, or `firefox` directly. The script does it.
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
| Use a custom md2 template               | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --template guidance` |
| Supply the print CSS yourself           | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --page-css brand-print.css` |
| Post-process the HTML before the PDF    | `bash ~/.claude/skills/deck/render/render.sh "$(pwd)/presentation.md" --post-html ./fix-images.sh` |

Orientation and paper size are usually picked up automatically from the `<!-- deck-orientation: ... -->` and `<!-- deck-paper: ... -->` comments at the top of `presentation.md` (written by `/deck draft`). The CLI flags are an override, used only when the user explicitly asks for a different orientation than what the deck declared.

The md2 **template** follows the same precedence: a CLI `--template NAME` flag wins; otherwise `render.sh` reads a `<!-- deck-template: NAME -->` comment from `presentation.md` (emitted by `/deck draft` only when a custom template is wanted); if neither is present, md2 uses its default template. `--template` is supported **by render.sh** — passing it is not improvising. You still call only `render.sh`; never invoke `md2 --template` yourself.

## Error handling

The script exits with distinct codes per failure mode. Surface the error message verbatim to the user, then explain the fix:

| Exit code | Meaning                                  | What to tell the user                                                |
|-----------|------------------------------------------|---------------------------------------------------------------------|
| 1         | Missing or unreadable input file         | Confirm the filename; suggest running `/deck draft`.                  |
| 2         | `md2` not on `$PATH`                     | Point them to the README → Requirements → md2 install instructions.   |
| 3         | No supported browser found               | Point them to install chromium / chrome / brave (preferred) or firefox 102+, or re-run with `--no-pdf`. |

If the script exits 0, both the HTML and (if requested) the PDF were generated successfully.

## Reporting completion

On success, report to the user:
- The two file paths produced.
- **Whether `/deck revise` has run on this deck yet, and if not, that the deck is not deliverable until it
  has.** This is the first render of the loop `draft` → `render` → `revise` → `render`: the revision pass
  needs the PDF, because page-fit compression and printed reading order are only visible once printed.
- A short hint for the eyeball pass that is worth doing anyway: "Open the PDF and check for empty slides,
  truncated chart labels, soft-wrapped lines — a line the renderer broke mid-phrase — or charts on lonely
  pages — if you see any, note them for the revise pass."

Do not tell the user the deck is finished on the strength of a clean render. The script's exit code proves
the files were produced, not that the copy can be read. That is `/deck revise`, and the reason it is a
separate stage rather than a hint here is in `revise/prompt.md`.

## `--page-css` and `--post-html` (M25)

Two extension points, so a caller with its own house pipeline does not have to fork this script.

**`--page-css FILE`** injects the file's contents **instead of** the built-in `@page` block —
`${PAPER}` and `${ORIENTATION}` are expanded in it. It replaces rather than appends, because a template
that draws its own print footer (as the `forestvalley` one does, via `.slide::before/::after`) prints the
footer twice if a second `@page` block is also injected. **A missing or unreadable file is a hard error:**
falling back to the default would render a deck in the wrong style and report success.

**`--post-html CMD`** runs `CMD <html> <input.md>` after the HTML exists and before any CSS injection.
**A non-zero exit aborts and no PDF is written.** That failure path is the point of the flag, not a
detail — a hook exists to reject an HTML that is not fit to print, and a hook that could not stop the PDF
would be decoration.

## `--embed-images` — when the deck leaves this machine (M32)

Off by default. Without it the HTML **references** local images: the ones the author wrote as a relative
path, and the template's own assets — the `guidance` and `forestvalley` templates point at their logo with
an absolute `file:///home/<user>/.md2/templates/<name>/assets/logo.png`. That resolves only where that
exact path exists, so the same file opened from a tablet, mailed to a client, or viewed by a colleague shows
an empty box where the logo should be, and nothing in the page says an image is missing.

`--embed-images` passes the flag through to md2, which inlines every local image as a base64 data URI. The
result is a single self-contained file that opens anywhere with no server.

**Pass it when the HTML is the deliverable** — emailed, opened on another device, handed to someone else,
or published. **Leave it off when the deck stays here**: it multiplies the payload once per occurrence, and
a logo on every slide adds up.

Two behaviours worth knowing, both md2's:

- **An image that does not resolve is an error.** md2 exits non-zero without writing the HTML, `set -e`
  propagates it, and no PDF is produced. A deck that ships with silently missing images while reporting
  success is the failure this prevents — the same reasoning as `--post-html` above.
- **No downscaling.** md2 warns on stderr when a single asset is large enough to matter, naming the file,
  its weight and how many times it appears. The fix is a right-sized asset, not a flag: a 5001×5001 logo
  displayed at 150px is 4.8 MB of output on a 16-slide deck. Report the warning to the user rather than
  swallowing it.

The PDF does not need this flag — headless Chromium reads the local files directly. It exists for the HTML.
