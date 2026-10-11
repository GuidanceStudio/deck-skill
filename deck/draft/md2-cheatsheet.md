# md2 cheatsheet

Compact reference for the [md2](https://github.com/guidance-studio/md2) markdown-to-presentation syntax. Everything the draft stage needs without fetching md2's full README.

> **Heads-up — frontmatter delimiter.** md2 frontmatter uses `+++` (TOML), NOT `---` (YAML — that's the Claude SKILL.md convention). The `---` in md2 is the **slide separator**. Don't mix them: if you wrap the frontmatter in `---`, md2 treats it as a slide and the rendering breaks silently.
>
> **Heads-up — frontmatter must start on line 1.** md2 only parses `+++` as frontmatter when it's the very first thing in the file. Any HTML comment, blank line, or text above it makes md2 silently treat the whole `+++` block as body content (you'll see the raw `+++ … +++` on the cover slide and the page title falls back to `Presentation`).

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

Any other key is ignored by md2 and handed to the template as `meta.<key>`. The `guidance-modern`
template reads six of them for its cover and header strip — see
[The `guidance-modern` template](#the-guidance-modern-template).

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

## Column layout (`:::columns`)

Wrap two to four `:::col` blocks in a `:::columns` block; a fifth `:::col` and everything after it is dropped. On mobile (< 768px) they stack vertically; in print they stay side-by-side. For cards and a highlighted column, see [`:::columns cards`](#columns-cards-and-col-highlight).

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

## Chapter cover (`:::chapter`)

Turn a whole slide into a full-height "act divider" — vertically centered, left-aligned, one type-step smaller than the cover. Use it to open a major section of a multi-part deck (slide pattern 2b).

```
:::chapter
# What you can automate
Concrete workflows, ranked by effort-to-impact.
:::
```

Parsing inside the fence:

- The `# ` **H1** line is the **title** (also the sidebar nav label).
- Everything **after** the H1 is the **subtitle** (optional, rendered as normal markdown).

Only an explicit `:::chapter` fence triggers a chapter slide — a bare `# ` H1 inside an ordinary slide (the hero-stat pattern) stays a normal heading. Like any slide, the fenced block needs a blank line and `---` before and after it.

In `guidance-modern` the subtitle can be a bullet list instead, rendered as a row of topics, and the label
`Part N of T` (`Parte N di T` when `lang = "it"`) and the large chapter number are added automatically —
do not write them:

```
:::chapter
# Demand
- Daily passengers
- Seasonality
- Commuter share
:::
```

---

## The `guidance-modern` template

`guidance-modern` draws every slide as a full A4 landscape page and is the template that designs the
constructs in this section. md2 parses them with any template, so they never break a render, but only
`guidance-modern` styles them. Select it with `<!-- deck-template: guidance-modern -->` at the end of the
file (see `prompt.md` Step 5) or with `render.sh --template guidance-modern`.

| Construct | `guidance-modern` | md2 `default` | `guidance`, `forestvalley` |
|---|---|---|---|
| Cover keys (`kicker`, `client`, …) | cover and header strip | ignored | ignored |
| `^` eyebrow | label above the slide title | dropped | dropped |
| `:::columns cards`, `:::col highlight` | grey cards, tinted highlight | boxed columns | unstyled columns |
| `:::take`, `:::source`, `:::timeline` | key-point box, source line in the bottom margin, row of phases | minimal styling | unstyled plain text |
| `:::statement` | dark full page, large sentence, numbered columns | large text, no title | ordinary slide titled with its first line |
| `` `code` `` in text, bold first table cell | pill, tinted row | code, bold | code, bold |

**Do not use these constructs with `guidance` or `forestvalley`.** Both are full copies of an older md2
default: the constructs come out unstyled, as plain paragraphs and lists, and the eyebrow line disappears.

### Cover front matter

```toml
+++
title = "Harbor Lane Ferries"
lang = "en"
palette = "guidance-modern"
client = "Harbor Lane Ferries"
subject = "Route review"
confidential = "Confidential"
kicker = "Route review · March 2027"
cover_meta = [["For", "Harbor Lane Ferries"], ["Prepared by", "Strategy team"], ["Date", "12 March 2027"]]
+++
```

| Key | Where it shows |
|---|---|
| `title` | the cover title and the HTML `<title>`; when `title` is set, the cover's `# H1` is not shown |
| `client`, `subject` | the header strip on every page: `GUIDANCE × <client> · <subject>` |
| `confidential` | the header strip, right side, before the page number `NN/TT` |
| `kicker` | the small line above the cover title |
| `cover_meta` | the label/value row at the foot of the cover, as `[label, value]` pairs |
| `palette` | chart colours; it is installed with the template, and md2 stops with `Palette 'guidance-modern' not found` when it is missing — remove the line in that case |

Every key is optional, and a missing one leaves no empty element behind. The cover subtitle is the
paragraph under `# H1`, as in every template. The cover title is HTML-escaped, so a `<br>` in it prints
as text: `print-constraints.md` rule 10 gives its length.

### Eyebrow (`^`)

```markdown
^ The question
## Four questions decide the next crossing
```

A `^ ` line as the first line of the slide, directly above the `## ` title with no blank line between,
becomes the small-capitals label over the title. Without one, `guidance-modern` shows `NN · <chapter
title>` of the latest `:::chapter`, and nothing before the first chapter. A `^ ` line anywhere else stays
slide text.

### Lede

The first paragraph under the `## ` title is the lede: grey, 12pt, set closer to the title. It needs no
syntax. Write it as one full sentence of one or two lines.

### `:::columns cards` and `:::col highlight`

```markdown
:::columns cards

:::col
# 2,400
### passengers a day
On the Northpoint crossing,
the busiest of the three.

:::col highlight
# 61%
### are commuters
They travel on weekdays
in every month of the year.

:::col
# 18 min
### saved per trip
Against the bridge route
at the evening peak.

:::
```

`cards` turns each column into a grey card, all of the same height; `:::col highlight` tints one of them.
Inside a column, `# ` is the figure (a number, a percentage, or `# 1` … `# 4` for a numbered agenda),
`### ` is the card title, and the paragraph under it is the card text. Two to four columns: the more
cards, the shorter each line has to be (`print-constraints.md` rule 10).

### `:::take`

```markdown
:::take Key point
The Northpoint crossing keeps its boats full outside the summer season.
:::
```

A tinted box at the foot of the slide's content, for the one sentence the slide establishes. The text
after `:::take` is an optional label in small capitals (`Key point`, `Il punto`). The block closes at the
first `:::` on its own line.

### `:::source`

```markdown
:::source
Source: ticket counts and passenger survey, 2026.
:::
```

One line of mono capitals in the bottom margin, under the take box: the same-slide citation
`copy-rules.md` rule 8 asks for. It sits in the margin, so it must fit on one line.

### `:::timeline`

```markdown
:::timeline
1. **Counts** Ticket and gate data
2. **Survey** 1,200 passengers asked
3. **Costs** Berths, crews, fuel
4. **Decision** One crossing for 2028
:::
```

Wraps a list. Each item becomes a column on a line of dots, the last dot filled; a `**bold**` lead-in at
the start of an item is the phase name. Three to five items; rule 10 gives the line lengths for each count.

### `:::statement`

```markdown
:::statement
The Northpoint crossing
**pays back in four years**,
with two boats.

1. **Demand** 2,400 passengers a day,
   61% of them commuters.
2. **Competition** No bus or ferry
   serves the evening peak.
3. **Cost** Two boats and one berth,
   leased from the port.
:::
```

The fence covers the whole slide, from its first line to its last, and the slide has no `## ` title. The
first paragraph is the thesis in large type, with `**bold**` in the accent colour; an ordered list becomes
three numbered columns at the foot, and a `**bold**` lead-in in each item becomes that column's label. The
sidebar uses the first line of text as the slide's name. Inside a slide with other content, `:::statement`
stays text. A `:::source` may follow the list inside the fence.

### Inline code and tables

`` `inline code` `` in text or in a table cell renders as a pill: use it for short tags such as
`` `evening boats` ``, not for code. A table row whose first cell is entirely bold (`| **Northpoint** | … |`)
is tinted, to mark the row the slide is about. A `---:` column is right-aligned with even-width figures.

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
