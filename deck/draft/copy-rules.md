# Copywriting rules

These are the rules that separate a deck that lands from a deck that drags. They apply when writing every slide — title, body, captions, takeaways.

When in doubt, cut. When the rule conflicts with the user's explicit request, follow the user.

---

## 0. Five procedures — do these, rather than avoiding their opposite

Everything from rule 1 down is a prohibition or a test. A prohibition needs you to catch yourself
mid-sentence, at the moment you write the line, while convinced the line is good — **and that is the
condition that fails.** Rules 1, 7 and 7b each describe this exact defect; all three were in force when a
client deck shipped with three lines the reader could not parse.

These five are different in kind: they change the **order of work**, so the empty line is never generated
and there is nothing to catch.

**(a) Write the takeaway sentence at full length before you build the slide.** Then build the slide to
carry it. **No sentence, no slide** — if you cannot write what the slide establishes, the slide has no
takeaway, and it is merged into its neighbour or cut. Writing the outline first and the sentences after
inverts this: the slot exists, so a line gets written to fill it.

**(b) A slide may end on its table.** Or its chart, or its facts. **There is no mandatory closing line.**
A layout slot that demands an assertion manufactures one — forty paragraph slots against twenty-five
things worth asserting is where fifteen invented assertions came from, and *"Condizione · previsione ·
forensica · ambiente"* was one of them: four abstract nouns, no verb, filling a required slot under a
table that already said it.

**(c) Over budget removes a fact, a row, or a whole slide. It never shortens a sentence.** Compression
takes out information first and cadence last, because cadence is what survives rewriting. Measured: the
offending slide was shortened five times to hit a page count, and every pass cut a clause of content and
preserved the rhythm. What finally fixed it was removing content outright — narrowing a column, deleting
a sentence whole. **A page that will not fit is carrying too much, not writing too long.**

**Definitions are the protected class here, and a term leaves with its gloss.** Measured 2026-07-28 while
repairing that same deck: five overflows, and every one was resolved by deleting an explanation. A
definition carries no number, so under page pressure it reads as the cheapest line on the slide, and it is
the first thing the eye offers up. It goes **last**. And when a term cannot afford its definition, **cut
the term too** — keeping the jargon and dropping the gloss is worse than dropping both, because the reader
is left with a word they cannot decode instead of one fact fewer.

**(d) The label test.** Show someone a label and **one** value under it. They must be able to say what
that value asserts. `Outage? / no` fails: the reader cannot tell whether `no` means the system did not go
down, or that outages are out of scope, or that the vendor does not report them.

This is the one test the others structurally cannot reach. **The delete test never gets to a label,
because a label cannot be deleted** — a table needs its headers, so an empty one survives every rule
above it. Apply it to **column headers and to every first-column row label**: `Fuori servizio` survived on
slide 3 of the failing deck *after being fixed on slide 2*, because only the header had been looked at.

**(e) The decode test.** Every term that names a method, a standard, a norm article, a material, an
instrument or a unit convention carries its meaning **in the same sentence or the next**, the first time it
appears. Read the line as the audience, not as yourself: someone who knows the client's business but not
this particular vertical must be able to restate what it asserts. `The Rietveld wants 3–4 g of solids`
fails; `Rietveld refinement — the computation that turns an X-ray diffraction pattern into percentages of
each mineral — needs 3–4 g of dried solids per sample` passes.

**This is the test the other four structurally cannot reach.** A dense jargon line **passes** the delete
test, because deleting it does lose information. It is not a label, so (d) never sees it. It states a fact,
so rule 4 approves of it. Every existing rule asks whether the line **says** something; this one asks
whether the reader can **decode** it, and a line can pass all of them and still be unreadable. Measured
2026-07-28 on a deck whose reader was the client himself: LIRA, XLPE, PILC, tan delta, partial discharge,
Mohs, XRD/Rietveld, ASTM G75 and specific speed all shipped undefined.

**Your own familiarity is not evidence.** You have spent the whole run inside this vertical and every term
in it is transparent to you by the time you draft. That is the same asymmetry as (a): you know what you
meant. Work from the brief's audience vocabulary, and where the brief does not settle it, define the term.

**A deck in a second language is re-drafted against the facts, not translated.** Translation preserves the
source deck's compression, and shorthand a domain-native reader absorbs in the original becomes opaque once
moved. This covers labels first — English `outage?` → Italian `Fuori servizio?` is faithful and worse,
because the English carried a domain convention the Italian does not, so **re-derive the label** from "what
does a value under this assert" — and it covers the prose the same way: every term gets the decode test
again in the new language, where the reader's shorthand is different.

---

## 1. Headline = the sentence that summarises what matters

The slide's `## H2` must state the **takeaway** — the thing the audience needs to know — not the **topic label**.

The audience reads the title first. If the title carries the conclusion, the body just backs it up. If the title is a generic label, they have to read the whole slide to work out what you're saying.

**There are two ways to get this wrong, and the second is the dangerous one.** A topic label says too little. A slogan says it with rhetoric instead of information — and because it *feels* sharper, it slips past review.

| ❌ Topic label | ❌ Slogan | ✅ Informative summary |
|---|---|---|
| "Market data" | "The market waits for no one" | "The Italian AI market is growing 50% a year" |
| "Q4 results" | "Q4: the quarter that got away" | "Q4 came in 12% under plan, driven by churn in enterprise" |
| "Competitive analysis" | "One competitor stands alone — and it's us" | "We are the only vendor of the four with EU-native hosting" |
| "Compliance" | "Compliance isn't a document you write later" | "Liability stays with the controller, even when a vendor processes the data" |

The right-hand column is longer than the middle one. That is expected and correct: it carries information rather than emphasis. **Never trade a fact for a cadence.**

Two tests, both of which must pass:

1. **Substitution test** — could this headline appear unchanged on three different decks about three different subjects? If yes, it's a label. Rewrite.
2. **Information test** — strip the rhetoric and ask what a reader now knows that they didn't before. If the answer is "nothing, but it sounded confident", it's a slogan. Rewrite.

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

## 7b. Banned constructions (rhetoric)

Rule 7 bans filler *phrases*. This rule bans **sentence shapes** — the ones that make copy sound like a keynote instead of a professional document. They are seductive precisely because they read as confident, so they survive review unless you look for them by name.

| Construction | What it looks like | Write instead |
|---|---|---|
| **Rhetorical triad** | "Seven acts, two hours, one terminal." | "Seven acts over two hours, run from the terminal." |
| **Antithesis for effect** | "You don't code the tool, you commission it." | "The tool is specified in a prompt rather than written by hand." |
| **Chiasmus** | "The slides carry the commands; the terminal does the work." | "The commands are printed on the slides and executed in the terminal." |
| **Fragment for emphasis** | "Live. No screenshots." | "Executed live during the session, with no screenshots." |
| **Aphorism** | "Approving is not rubber-stamping." | "At this point you add one constraint and let the model decide the rest." |
| **Wordplay on the subject** | "The expensive way to be right" | "Bulk edits should be batched rather than made cell by cell" |

**The tell:** if a line would work as a slide *title* in a conference talk, or if removing a comma would break its rhythm, it is doing rhetorical work instead of informational work. Rewrite it as a plain declarative sentence.

This applies to every text surface — slide titles, chapter/section subtitles, blockquote takeaways, cover subtitles, closing lines. **Chapter and section subtitles are where it surfaces most**, because a short framing line invites a flourish.

> Standing feedback from the skill's primary user, after a real deck shipped with all six of these: *"niente frasi da fuffaguru magic jargon fuffa. siamo una realtà professionale, non cazzari."* The rule is unconditional — it is **not** relaxed for board or investor audiences.

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
- Weak: *"Beyond the paperwork"* (a slogan — names a mood, not a subject; see rule 7b)

Pair it with a 1-line subtitle that says what the deck is *for*: *"Approval request for the Modena operating site, 24-month plan."* The subtitle is a statement of purpose, not a tagline.
