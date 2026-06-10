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

Quarterly progress, milestones missed and hit, plan for Q1.

**Audience:** Board · **Date:** 2026-04-29
```

---

## 2. Section divider

**When to use**: marking a major transition between parts of the deck (e.g. *"Now: the numbers"* → *"Next: the ask"*). One per major section, max 2-3 per deck.

**Anti-pattern**: don't use a divider every 2-3 slides; it kills momentum.

**md2 syntax** (slide with only an H2, no body):

```markdown
## The numbers
```

---

## 3. Hero stat (big number)

**When to use**: a single number is the headline insight (e.g. "+50% YoY", "€1.8B market"). Maximum 1-2 per deck — they lose impact if overused.

**Anti-pattern**: don't pile multiple big numbers on one slide; that's a stat-grid pattern (use bullets or a table instead).

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

:::chart column --labels --show-data --title "Annual revenue (€)"
| Year | Revenue |
|------|---------|
| 2027 | 350000  |
| 2028 | 520000  |
| 2029 | 696000  |
| 2030 | 882800  |
| 2031 | 1085440 |
:::
```

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

## Quick selection guide

| Beat in the narrative                       | First-choice pattern        |
|---------------------------------------------|----------------------------|
| Open the deck                              | 1. Cover                    |
| Mark a section transition                  | 2. Section divider          |
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
