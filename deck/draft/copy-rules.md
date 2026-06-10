# Copywriting rules

These are the rules that separate a deck that lands from a deck that drags. They apply when writing every slide — title, body, captions, takeaways.

When in doubt, cut. When the rule conflicts with the user's explicit request, follow the user.

---

## 1. Headline = punchline, not topic

The slide's `## H2` must state the **takeaway**, not the **topic**.

The audience reads the title first; if the title is the conclusion, the body just needs to back it up. If the title is generic, the audience has to read the whole slide to figure out what you're saying.

| Bad headline (topic) | Good headline (punchline) |
|---|---|
| "Market data" | "AI market in Italy is growing +50% YoY" |
| "Q4 results" | "Q4 missed plan by 12%, here's why" |
| "Competitive analysis" | "Only one competitor has EU-native hosting — and it's us" |
| "Team" | "Three founders, eight years building AI for SMBs" |

If the headline could appear unchanged on three different decks about three different products, it's too generic. Rewrite.

---

## 2. Pyramid principle: state the conclusion first

**Conclusion-first**, not chronological. The cover and the first content slide should already give the audience the bottom line; the rest of the deck proves it.

Audiences who agree after the first 3 slides stop arguing. Audiences who have to wait until slide 22 for the conclusion start arguing on slide 4 about a piece of evidence they don't yet know is relevant.

This works even for "informational" decks: the first slide should tell the audience what they'll know by the end.

---

## 3. One idea per slide

Test: *"If this were the only slide the audience saw, what would they take away?"* If you can't answer in one sentence, the slide has more than one idea — split it.

Common signs you're packing too much:
- The slide has more than one chart, or a chart plus a table.
- The bullets cover two unrelated themes.
- You find yourself writing "and also" or "additionally" between bullets.

Splitting two ideas into two slides almost always reads better than cramming both onto one.

---

## 4. Numbers > adjectives

Adjectives are noise. Concrete numbers carry weight.

| Vague                      | Concrete                                      |
|----------------------------|----------------------------------------------|
| "Massive growth"           | "+50% YoY"                                  |
| "Many customers"           | "247 paying customers, +89 last quarter"     |
| "Significantly faster"     | "3x faster: 12 ms → 4 ms median"             |
| "Industry-leading"         | "#1 by ARR in Italian SMB segment, Q4 2025"  |

If you can't find a number, prefer a concrete scenario over a vague claim. *"A 30-person law firm replaced two SaaS tools and saved €18k/year"* beats *"saves money for law firms"*.

Always cite the source inline when credibility matters: *"+50% YoY (Osservatorio AI PoliMI, 2025)"*.

---

## 5. Parallel bullets

When you write a list, every bullet should follow the **same shape** — same starting verb form, same length, same level of abstraction.

```markdown
<!-- Bad: mixed shapes -->
- Adopt the new pricing model
- Customer satisfaction
- Going to invest in EU hosting

<!-- Good: all start with a verb, all action items -->
- Adopt flat pricing (no per-seat minimum)
- Track NPS quarterly with real customer interviews
- Migrate hosting to EU-region datacenter
```

Parallel structure makes lists scannable. The eye finds the differences faster when the shape is constant.

---

## 6. 6×6 ceiling — not target

Maximum 6 bullets per slide, max 6 words per bullet (rough guide). This is a **ceiling**, not a target. Three bullets of four words usually beats six bullets of six words.

If you're hitting the ceiling, the slide is doing too much. Split it.

For leave-behind decks (read alone, no presenter), bullets can be a bit longer (10-12 words) because the slide must stand alone — but never exceed 1 line per bullet at standard font size.

---

## 7. Banned phrases (filler)

These signal nervousness or lack of confidence. Cut them. Always.

- *"In conclusione…"* / *"In conclusion…"* — the audience can see the slide is the last one.
- *"Come abbiamo visto…"* / *"As we saw earlier…"* — if they need reminding, the previous slide failed.
- *"Vorrei sottolineare…"* / *"I'd like to emphasize…"* — just emphasize it.
- *"È importante notare…"* / *"It's important to note…"* — if it weren't, you wouldn't say it.
- *"In altre parole…"* / *"In other words…"* — say it well the first time.
- *"Ovviamente…"* / *"Obviously…"* — if it's obvious, skip it; if it isn't, "obviously" insults the audience.

Replace these with the substantive sentence you'd write next.

---

## 8. Inline source citations

When a number or claim is load-bearing, cite the source on the same slide. Audiences trust numbers with sources; they discount numbers without.

Format options:
- Parenthetical: *"€1.8B (ISTAT, 2025)"*
- Footnote in md2: *"€1.8B [^1]"* with `[^1]: ISTAT 2025` at the bottom of the slide.
- Caption under a chart: *"Source: Osservatorio AI PoliMI, 2025"*

Don't bury sources in a "Sources" appendix slide alone — readers won't navigate back. Inline, every time.

---

## 9. Active voice

Active is shorter and more direct than passive.

- "We launched in March" > "The launch was completed in March."
- "The team owns reliability" > "Reliability is owned by the team."

Passive is fine when the actor genuinely doesn't matter or is unknown ("The data was collected in 2024"), but in a business deck the actor almost always does matter.

---

## 10. The cover headline test

The cover's H1 should be specific enough that the audience knows the deck's domain in 2 seconds. Test:

- Strong: *"Vantio — Innovafondo €280k application"*
- Weak: *"Project Update"*
- Weak: *"Q4 Review"* (no project, no team, no quarter dates)

Pair it with a 1-line subtitle that says what the deck is *for*: *"Approval request for the Modena operating site, 24-month plan."*
