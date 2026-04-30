# md2 cheatsheet

Compact reference for the [md2](https://github.com/) markdown-to-presentation syntax. Everything the draft stage needs without fetching md2's full README.

> **Heads-up — frontmatter delimiter.** md2 frontmatter uses `+++` (TOML), NOT `---` (YAML — that's the Claude SKILL.md convention). The `---` in md2 is the **slide separator**. Don't mix them: if you wrap the frontmatter in `---`, md2 treats it as a slide and the rendering breaks silently.

---

## File structure

A md2 file has three regions:

1. **Frontmatter** — TOML inside `+++` fences. Optional but recommended.
2. **Cover** — everything before the first `---` separator (H1 + paragraph).
3. **Slides** — separated by `---` on its own line, with blank lines above and below.

```markdown
+++
title = "My Deck"
palette = "cool"
lang = "en"
+++

# My Deck

Subtitle paragraph for the cover slide.

---

## First slide title

Body content of slide 1.

---

## Second slide title

Body content of slide 2.
```

---

## Frontmatter fields

| Field     | Type             | Default       | Notes                                                |
|-----------|------------------|---------------|------------------------------------------------------|
| `title`   | string           | from H1       | Sets `<title>` and the presentation title            |
| `palette` | string           | `"default"`   | Built-in name or path to user palette                |
| `colors`  | array of strings | —             | Override the first N colors of the chosen palette    |
| `lang`    | string           | `"it"`        | HTML `lang` attribute                                |
| `dark`    | bool             | `false`       | Dark mode default                                    |

CLI flags `--lang` and `--dark` override the frontmatter when passed.

---

## Built-in palettes

`default`, `warm`, `cool`, `mono`, `vivid`, `pastel`. Custom palettes go in `~/.md2/palettes/<name>.toml` (user palettes override built-ins of the same name).

A palette TOML:

```toml
name = "warm"

colors = [
  "#d45d00",
  "#e8910c",
  "#f5c542",
  "#e15759",
]

[dark]
colors = [
  "#f0a050",
  "#f5b84c",
  "#fce08a",
  "#f28e8e",
]
```

If the `[dark]` block is absent, dark variants are computed automatically.

---

## Heading levels

| Level    | Where                 | Effect                                                       |
|----------|----------------------|--------------------------------------------------------------|
| `# H1`   | Cover only            | Presentation title (also the page `<title>` if no frontmatter) |
| `## H2`  | One per slide         | Slide title; appears in the sidebar nav                      |
| `### H3` | Within a slide        | Sub-section                                                  |
| `#### H4`| Within a slide        | Lower sub-section                                            |

If a slide has no H2, md2 falls back to "Slide N" — which breaks navigation. **Always include an H2** (the section divider pattern uses an H2-only slide, no body).

---

## Charts (`:::chart`)

Turn a markdown table into a visual chart. The first column is the label axis; subsequent columns are data series.

```
:::chart TYPE [--option] [--option "value"]
| Label   | Series A |
|---------|----------|
| Item 1  | 42       |
| Item 2  | 73       |
:::
```

### Chart types

| Type           | Use for                                |
|----------------|----------------------------------------|
| `bar`          | Horizontal bars — good for ranked lists |
| `column`       | Vertical bars — good for time series   |
| `line`         | Trend lines                            |
| `line filled` | Trend with area below filled (alias `area`) |
| `pie`          | Proportions, single series only        |

### Options

| Option         | Effect                                                |
|----------------|-------------------------------------------------------|
| `--labels`     | Show the first-column labels on the axis              |
| `--legend`     | Show a legend (useful for multi-series charts)        |
| `--stacked`    | Stack bars/columns instead of grouping side-by-side   |
| `--show-data`  | Show numeric values on/over the bars                  |
| `--title "…"` | Caption above the chart                                |

### Multi-series example

```
:::chart column --labels --legend --show-data --title "Revenue vs Costs"
| Quarter | Revenue | Costs |
|---------|---------|-------|
| Q1      | 100     | 80    |
| Q2      | 150     | 90    |
| Q3      | 130     | 110   |
:::
```

### Sizing defaults

| Type                       | Height                            | Width      |
|----------------------------|----------------------------------|------------|
| `bar`                      | grows with rows                   | 100%       |
| `column`, `line`, `area`   | `min(300px, 40vh)`                | 100%       |
| `pie`                      | `min(50vh, 50vw)` centered       | matches H  |

Pie is the largest — see `print-constraints.md` for why this affects what you can put alongside it.

---

## Two-column layout (`:::columns`)

Wrap two `:::col` blocks in a `:::columns` block. Max two columns. On mobile (< 768px) they stack vertically; in print they stay side-by-side.

```markdown
:::columns

:::col
Left column content.

- Bullet
- Bullet

:::col
Right column content (chart, table, image, anything).

:::
```

---

## Other supported markdown

- **Bold**: `**text**` → **text**
- *Italic*: `*text*` → *text*
- `Inline code`: backticks
- Links: `[label](url)` (URLs alone are auto-linked too)
- Images: `![alt](url)` — centered, supports inline HTML `<img>` with `width`/`height`
- Lists: `-` / `*` / `1.` (nested with indentation)
- Tables: standard markdown tables with `|` and `---`. Alignment via `:---`, `:---:`, `---:`.
- Blockquotes: `> text` — renders with a left blue border
- Footnotes: `[^1]` in body, `[^1]: text` at the bottom of the slide
- Fenced code blocks: triple backticks with language hint
- Single newline → `<br>` (no double-space at end of line needed)

---

## Inline HTML (allowed)

Safe HTML tags are preserved. Use this for:
- `<iframe>` — embed videos, maps, external pages
- `<img>` with `src`, `alt`, `width`, `height`

Dangerous tags (`<script>`, `onclick`, `javascript:`) are stripped automatically.

Example:

```markdown
<iframe width="560" height="315" src="https://www.youtube.com/embed/..." frameborder="0"></iframe>
```

---

## Keyboard shortcuts (in the rendered HTML)

Useful to mention to the user when handing off the deck:

| Key                | Action                  |
|--------------------|-------------------------|
| `↓` / `→` / `PgDn`| Next slide              |
| `↑` / `←` / `PgUp`| Previous slide          |
| `Home`             | Cover                   |
| `End`              | Last slide              |
| `S`                | Toggle sidebar          |
| `D`                | Toggle dark/light       |
| `Ctrl+P`           | Print (clean PDF layout) |
