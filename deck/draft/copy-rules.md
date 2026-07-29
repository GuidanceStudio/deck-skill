# Copywriting rules

These are the rules that separate a deck that lands from a deck that drags. They apply when writing every slide — title, body, captions, takeaways.

When in doubt, cut. When the rule conflicts with the user's explicit request, follow the user.

---

## 0. Seven procedures — do these, rather than avoiding their opposite

Everything from rule 1 down is a prohibition or a test. A prohibition needs you to catch yourself
mid-sentence, at the moment you write the line, while convinced the line is good — **and that is the
condition that fails.** Rules 1, 7 and 7b each describe this exact defect; all three were in force when a
client deck shipped with three lines the reader could not parse.

These seven are different in kind: they change the **order of work**, so the empty line is never generated
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


**(f) Provenance — every claim carries its source class, and ours are labelled as ours.** Before a number
goes on a slide, name where it came from: **the vendor** · **a norm, a register or a public record** · **a
primary source we read** · **our own arithmetic** · **our own judgement** · **someone's word**. The first
three are stated plainly. Our arithmetic and our judgement are stated **and labelled as ours inside the
sentence** — "our multiplication", "our reading" — because otherwise our estimate and a published figure
come out in the same voice and the reader cannot separate them. Hearsay is verified or dropped; it never
ships. **And the hard case: never state a cost, a size or a timeline inside the audience's own domain
unless you read it somewhere.** They price it for a living, and being wrong there costs more than the
number was worth. Measured 2026-07-29: a client deck carried a `50–120 k€` civil-works estimate we had
never priced, and an unverified report about a named company's shareholders.

**(g) The actor — every open question, every imperative and every "we" names who acts.** A list of
questions with no subject is a homework assignment, and the reader will ask *who is supposed to ask these,
of whom, and why*. If we will go and get the answer, say so. If it belongs to the reader's own commercial
conversation, say that instead — and then ask whether they want us to run it. Measured 2026-07-29:
"what we would ask the two suppliers" read as us making the contact, on suppliers the client would be
negotiating with directly.

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

**A citation the reader cannot open is half a citation.** Three rules, all measured on one deck on
2026-07-29, where twenty-two companies were named and not one was reachable:

- **Every named company carries its URL, and every non-vendor claim carries a resolvable reference.** The
  reader's first instinct on an interesting supplier is to look at it. Operator, verbatim: *"ha senso che
  non abbiamo MAI messo il link al sito web??"*
- **Write them as markdown links, on the company name.** A bare `example.com` in body text renders as
  plain text and **is not clickable in the printed PDF** — the reader cannot follow it, which is the whole
  point. Verify it after rendering by extracting the anchors from the PDF, not by looking at the markdown.
- **Verify the URL resolves before you write it.** A guessed link is worse than no link: it fails in front
  of the reader. Where it cannot be verified, name the company without a link and say so — of fourteen
  supplier URLs on that deck, three could not be confirmed and were correctly left bare rather than
  invented.

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

---

## 11. Not their trade, and not our process

Two halves of the same failure: writing about the wrong subject.

**Do not explain the audience their own trade.** Their regulations, their assets, their standard practice
and the vocabulary of their own industry are not tutorials. It reads as condescension and it is the fastest
way to lose a technical reader — who will also be the one to catch it if the explanation is slightly wrong.
Measured 2026-07-29 on a deck for a utility: cross-linked polyethylene versus paper-insulated cable
explained to cable engineers, the national grid-connection rules explained to their grid department, and
*"1 bar is atmospheric pressure"* to a technical office. Operator, verbatim: *"mica possiamo noi dire a
edison cosa deve fare!! gli insegnamo il loro lavoro?"*

The test: **would this sentence be new to someone who does this job every day?** If not, cut it. What is
outside their trade — a specialist analytical method, a testing protocol from another industry — still gets
explained, and §0(e) still applies. The line is between *their* field and *the field you are reporting on*.

**Do not narrate our own process, our own corrections or our own diligence.** How hard we searched, how
many queries we ran, what we got wrong at first and fixed, that we checked the primary source rather than
the abstract, that we are being transparent about a limitation — none of it is content. It is either
self-praise or, worse, a confession the reader did not ask for and can only use against us. Measured on the
same deck: *"at the start we had it set up wrong"*, *"we had a reviewer attack the idea"*, `738 searches in
27 languages`, and three separate statements about our own honesty. Operator, verbatim: *"ma ti sembra che
al cliente dico un errore che stavo per fare??"*

The exception, and it is narrow: **§0(f) labelling.** "This is our arithmetic" is provenance, not
narration — it tells the reader how much weight to put on a number. One clause, inside the sentence that
carries the number. Never a paragraph about our method.

---

## 12. Which suppliers appear at all

**A supplier appears if it solves the reader's problem — whoever owns it — and the owner is named.**
Ownership, size and independence are procurement facts the reader weighs themselves; they are not our
grounds for hiding a working solution.

**A supplier dropped because it is defunct, or because it does not solve the problem, does not appear.** Not as a table row, not as a footnote. The reader cannot act on it, and a page of rejections
reads as activity reporting.

There is exactly one thing worth carrying from the rejected set, and it is the **pattern**, in one line:
*"none of the products that meet the specification has an independent supplier behind it"* is a finding.
The roster that produced it is not. Operator, verbatim: *"se una roba è stata scartata perché è fallita o
perché non risolveva il problema, che cazzo ci sta a fare nella presentazione?"*

Two consequences worth stating, because they are not obvious:

- **Rejected on our own selection criteria is not rejected for the reader.** "Acquired by a large group"
  is a scouting rule; the reader may buy from that group happily. Presenting it as a disqualification tells
  them we applied a rule of ours, not that the product is unfit for them.
- **A criterion that kills a supplier must be one the reader recognises.** If it is our threshold and not
  theirs, say so — see §0(f).
