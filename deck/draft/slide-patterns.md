# Slide patterns

A curated catalog of slide types that map cleanly to md2 syntax. Each pattern documents *when to use it*, *when not to* (anti-pattern), and a copy-paste md2 block.

When drafting, pick the right pattern for each beat of the narrative. Don't force a pattern that doesn't fit — a slide with a single quote is fine if it's the right beat.

---

## 1. Cover

**When to use**: opening of every deck. Always.

**Anti-pattern**: don't put bullets, charts, or sources on the cover. It's the door, not the room.

**md2 syntax** (the H1 + paragraph *before* the first `---`):

```markdown
+++
title = "Project Aurora — Q4 Review"
palette = "cool"
lang = "en"
+++

# Project Aurora — Q4 Review

Progress against the Q4 plan, the two milestones that slipped, and the Q1 schedule.

**Audience:** Board · **Date:** 2026-04-29
```

---

## 2. Section divider

**When to use**: marking a major transition between parts of the deck (e.g. *"Now: the numbers"* → *"Next: the ask"*). One per major section, max 2-3 per deck.

**Anti-pattern**: don't use a divider every 2-3 slides; it kills momentum. And never ship a divider as a bare title — a slide with only the H2 and no body is not allowed (see `print-constraints.md` rule 6). Every divider must carry at least one line of subtitle/context under the H2 to frame what's coming.

**md2 syntax** (H2 + one framing line — never the H2 alone):

```markdown
## Revenue after three quarters is 12% below plan

The gap, where it came from, and what closing it in Q4 would require.
```

The H2 still states a takeaway — a divider is not an exemption from rule 1. The framing line says what is coming, in plain terms; it is not a teaser (see `copy-rules.md` rule 7b).

---

## 2b. Chapter cover (act divider)

**When to use**: opening a *major* section or act of a multi-part deck — the heavyweight sibling of the section divider (pattern 2). Gives a long deck clear chapters: "Part 1 — The problem", "Part 2 — The solution", "Part 3 — The ask". One per major act; a deck with 3-4 acts gets 3-4 of these. It renders full-height, vertically centered, left-aligned — clearly distinct from the cover.

**Anti-pattern**: don't overuse. This is a full-page act break, not a per-topic transition. For a lighter transition between two slides *inside* the same act, use the section divider (pattern 2) instead. If a chapter cover appears every few slides it kills pacing. The two coexist: chapter cover = act boundary, section divider = in-act beat.

**md2 syntax** (a `:::chapter` fence wrapping the whole slide — a `# ` H1 title, optional subtitle line(s) *after* it):

```markdown
:::chapter
# What you can automate
Concrete workflows, ranked by effort-to-impact.
:::
```

The `# ` H1 is the chapter title (and the sidebar nav label); the line(s) below it are an optional subtitle. Only an explicit `:::chapter` fence triggers this — a bare `# ` H1 inside an ordinary slide (the hero-stat pattern) stays a normal heading.

> ⚠️ **The subtitle is where rhetorical copy creeps in.** A short framing line under a big title invites a flourish, and the result reads as a keynote slogan rather than a document. Write it as a plain statement of what the act contains: *"Come è stato prodotto questo materiale, e l'indice delle due ore"* — **not** *"Sette atti, due ore, un terminale."* See `copy-rules.md` rule 7b.

---

## 3. Hero stat (big number)

**When to use**: a single number is the headline insight (e.g. "+50% YoY", "€1.8B market"). Maximum 1-2 per deck — they lose impact if overused.

**Anti-pattern**: don't pile multiple big numbers on one slide; that's a stat-grid pattern (use bullets or a table instead — or, with `guidance-modern`, the stat row in [With the `guidance-modern` template](#with-the-guidance-modern-template)).

**md2 syntax** (H2 takeaway + an H1 inside the slide as the big number + 1 framing sentence):

```markdown
## The market is exploding

# +50%

Italian AI market YoY growth, 2024 → 2025. Source: Osservatorio AI PoliMI.
```

---

## 4. Bullet list

**When to use**: 3-5 parallel points the audience must remember. The classic. Most slides default here.

**Anti-pattern**: don't go past 6 bullets; if you need more, split the slide. Don't mix levels of abstraction in the same list.

**md2 syntax**:

```markdown
## Three levers for next quarter

- **Pricing**: switch from per-seat to flat. Lifts ACV by ~30%.
- **Onboarding**: cut time-to-value from 3 weeks to 72 hours.
- **Channel**: enable system integrators in the Mezzogiorno.
```

---

## 5. Two-column compare

**When to use**: A vs B, before/after, problem/solution, today/tomorrow. The contrast is the message.

**Anti-pattern**: don't use columns when the two halves don't symmetrically compare; use a table instead.

**md2 syntax** (uses md2's `:::columns` directive):

```markdown
## Before vs after

:::columns

:::col
**Before**
- Manual reconciliation: 12 h/week
- Shadow IT on consumer ChatGPT
- No GDPR audit trail

:::col
**After**
- Automated MCP: 2 h/week
- Private LLM, EU-hosted
- Granular audit log per request

:::
```

---

## 6. Quote / testimonial

**When to use**: a customer or expert validates the story in their own words. Strongest right before an ask.

**Anti-pattern**: don't paraphrase — keep the original wording, even if a bit awkward. Anonymous quotes lose 80% of impact.

**md2 syntax** (H2 + blockquote + attribution):

```markdown
## What customers say

> "We replaced three vendors with one tool and got our quarter back. The audit log alone is worth the contract."

— Maria F., COO, mid-size accounting firm (40 employees)
```

---

## 7. Process / steps

**When to use**: a sequence the audience needs to follow or visualize (rollout plan, framework, methodology).

**Anti-pattern**: don't number steps if they aren't actually sequential — use bullets instead.

**md2 syntax** (H2 + numbered list):

```markdown
## How onboarding works

1. **Day 1** — provision dedicated VPS in EU region.
2. **Day 2** — install MCP connectors for the customer's stack.
3. **Day 3-5** — run anonymization policy tests on real data.
4. **Day 7** — pilot user activates the assistant.
```

---

## 8. Timeline

**When to use**: milestones over time, roadmap, history of the company/project. Discrete dates with discrete events.

**Anti-pattern**: don't draw a timeline when the events overlap or run in parallel — use a Gantt-style table instead.

**md2 syntax** (H2 + table OR `:::columns` with date/event pairs). Table form is usually clearer in print:

```markdown
## 24-month roadmap

| Quarter | Milestone                                      |
|---------|-----------------------------------------------|
| Q1      | Hire core team, open Modena office              |
| Q2      | First 5 pilot customers in Emilia-Romagna             |
| Q3      | ISO 27001 audit kickoff                       |
| Q4      | 30 customers, ARR €300k                       |
| Q5      | Expand to Mezzogiorno                         |
| Q8      | 80 customers, ARR €1M, project close          |
```

---

## 9. Single chart slide

**When to use**: a chart that carries the whole message of the slide. Funnel, trend, ratio, distribution.

**Anti-pattern**: don't combine a chart with a long paragraph or a table on the same slide — see `print-constraints.md` for why this breaks the print layout. One chart, one short caption.

**md2 syntax** (H2 + 1-line context + `:::chart`):

```markdown
## Revenue projection

Conservative scenario: +25% YoY through 2031, no external funding.

:::chart column --title "Annual revenue (€)"
| Year | Revenue |
|------|---------|
| 2027 | 350000  |
| 2028 | 520000  |
| 2029 | 696000  |
| 2030 | 882800  |
| 2031 | 1085440 |
:::
```

**Radar variant**: use `:::chart radar` to compare the profile of 3–8 dimensions that share one scale
(scores from 1 to 5, shares of 100%), with 2–3 series. It shows which entity is stronger on which
dimension at a glance.

**When not to use a radar**: to read *how much* a value moved, use side-by-side bars (`:::chart bar`
with one series per period) — polygon areas and ring distances cannot be read to a number. A radar that
compares two periods goes beside the bars (`:::columns`, radar in one `:::col`, bars with their values in
the other); it is never the only place a change is readable. Dimensions on different units or scales do not
belong on one radar; more than 8 axes or 3 series turns the polygons into noise.

---

## 10. Table slide

**When to use**: structured comparison data (features matrix, financials, KPIs by segment). Tables can carry more text than a chart slide.

**Anti-pattern**: don't make a table when the message is a single number (use hero stat) or a comparison of two things (use two-column).

**md2 syntax** (H2 + table + optional `> takeaway` blockquote):

```markdown
## Pricing vs. competitors

| Vendor          | Min seats | Year 1 cost | EU hosting | Italian gestionali |
|-----------------|-----------|-------------|------------|-------------------|
| Vantio            | 1         | €15k        | ✅          | ✅                |
| ChatGPT Ent.    | 150       | €100k+      | optional   | ❌                |
| Glean           | varies    | €300k+      | optional   | ❌                |

> Of the three, only Vantio is sized for a small Italian firm and integrates with TeamSystem, Zucchetti, Danea out of the box.
```

---

## 11. Diagram / image

**When to use**: architecture diagrams, screenshots, photos, charts you've drawn outside md2 (Excalidraw, Figma exports, etc.).

**Anti-pattern**: don't dump a high-res image without a caption — the audience won't know what they're looking at.

**md2 syntax** (H2 + Markdown image, optional caption):

```markdown
## System architecture

![Vantio architecture](assets/architecture.png)

*Each customer gets a dedicated VPS. The Control Plane handles masking, routing, and audit logs across all tenants.*
```

---

## 12. People / team

**When to use**: introducing the team behind the project, board members, advisors. One slide, max 6 people; if more, group by role across slides.

**Anti-pattern**: don't put 12 photos on one slide — they become unreadable thumbnails.

**md2 syntax** (H2 + `:::columns` with photo + bio per col):

```markdown
## The team

:::columns

:::col
![Paolo Meola](assets/paolo.jpg)

**Paolo Meola** — CEO & Founder
Founder of Instilla. 15 years in digital + AI for SMBs.

:::col
![Andrea Colla](assets/andrea.jpg)

**Andrea Colla** — Tech Lead
Architect of the Control Plane. Ex-Instilla.

:::
```

---

## 13. Closing / CTA

**When to use**: last slide. Always. The audience leaves with one of: a decision, a contact, a next step.

**Anti-pattern**: don't end on "Thank you" alone — that's wasted real estate. State the ask.

**md2 syntax**:

```markdown
## Next steps

- **Decision**: approve €280k Innovafondo application by 2026-05-15.
- **Pilot**: identify 3 candidate customers in Emilia-Romagna for Q3 onboarding.
- **Contact**: paolo@guidance.studio · linkedin.com/in/paolomeola

*Q&A welcome.*
```

---

## With the `guidance-modern` template

`guidance-modern` styles a set of md2 constructs that the other templates print as plain text (syntax in
`md2-cheatsheet.md`, "The `guidance-modern` template"). When the deck uses that template, the patterns
above take these forms. With `guidance` or `forestvalley`, keep the plain forms above: the constructs come
out unstyled there.

| Pattern | Construct in `guidance-modern` |
|---|---|
| 1. Cover | front matter `kicker`, `client`, `subject`, `confidential`, `cover_meta` |
| 2b. Chapter cover | `:::chapter` with `# Title` and a bullet list of the act's topics; `Part N of T` is added |
| 3. Hero stat | unchanged: `# 92%` in the content, the next paragraph is its caption |
| Stat row: two to four numbers | `:::columns cards`, a `# ` figure and a `### ` label per card; `:::col highlight` on the number the title is about |
| Agenda, or the questions the deck answers | `:::columns cards` with `# 1` … `# 4` |
| 5. Two-column compare | `:::columns cards` with two cards; `:::col highlight` on the recommended side |
| 7. Process / 8. Timeline | `:::timeline` over a list of three to five items, each opening with a `**Phase**` lead-in |
| 10. Table | a bold first cell tints the row the slide is about; `` `tag` `` pills for short categorical values |
| Thesis or recommendation in one sentence | `:::statement`: the sentence, then three numbered reasons |
| The sentence a slide establishes | `:::take` instead of a closing `>` blockquote |
| The source of the slide's numbers | `:::source`, one line in the bottom margin |
| Any content slide | `^ ` eyebrow above the `## ` title; without one, the current chapter is shown |

**md2 syntax** (stat row: eyebrow, cards, take, source):

```markdown
^ Demand
## Commuters fill the boats all year

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

:::take Key point
The Northpoint crossing keeps its boats full outside the summer season.
:::

:::source
Source: ticket counts and passenger survey, 2026.
:::
```

**Anti-patterns**:

- A `:::take` on every slide. The box carries a sentence the slide already has; it is not a slot to fill
  (`copy-rules.md` §0 procedure (b)). A slide that ends on its table or its cards needs none.
- More than one `:::statement` per act. Each one presents itself as the act's conclusion, so a second
  one leaves the reader to choose between them.
- A thesis written for effect. The `:::statement` sentence carries a fact, like a title (`copy-rules.md`
  rules 1 and 7b).

---

## Quick selection guide

| Beat in the narrative                       | First-choice pattern        |
|---------------------------------------------|----------------------------|
| Open the deck                              | 1. Cover                    |
| Mark a section transition                  | 2. Section divider          |
| Open a major act / chapter                 | 2b. Chapter cover           |
| Anchor a key number in memory              | 3. Hero stat                |
| Three things you must remember             | 4. Bullet list              |
| Compare today vs tomorrow                  | 5. Two-column compare       |
| Customer voice / external validation       | 6. Quote                    |
| Sequential rollout / methodology           | 7. Process                  |
| Roadmap / milestones over time             | 8. Timeline                 |
| Show data → conclusion                     | 9. Single chart             |
| Structured comparison across 4+ dimensions | 10. Table                   |
| Architecture / screenshot                  | 11. Diagram / image         |
| Introduce the team                         | 12. People                  |
| Close with the ask                         | 13. Closing / CTA           |
| Two to four numbers side by side           | Stat row (`guidance-modern`) |
| The answer in one sentence                 | `:::statement` (`guidance-modern`) |
