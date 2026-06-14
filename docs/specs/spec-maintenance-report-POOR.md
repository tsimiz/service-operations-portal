# Poor prompt: maintenance report (DEMO, deliberately under-specified)

This is not a specification. It is the kind of one-line request people actually paste into an AI tool. It is used for two demo runs: once with the repository conventions present (case 2), and once from a folder with no conventions (case 3). Paste it as the prompt; do not add detail.

---

> Add a maintenance report page to the portal. It should show the maintenance history in a nice way, grouped and also detailed, and look professional. Make it production ready.

---

## Why this is poor (facilitator notes, do not paste)

Every phrase here is a silence the model must fill, and it fills them confidently:

- **"maintenance history"** — history of what? It may invent fields the portal does not have (cost, downtime, technician hours, a status or severity, a category), and render them in the UI as columns that should not exist.
- **"grouped and also detailed"** — grouped by what? By asset (correct), or by date, by technician, by a guessed category? The grouping axis is a coin flip.
- **"look professional" / "nice way"** — invites heavy UI: charts, a date-range filter, a search box, pagination, none of which were asked for and none backed by data.
- **"production ready"** — the loud word that fights the quiet convention. It tempts the model to add a database (JPA/H2), authentication, export buttons (CSV/PDF), and configuration. With conventions present (case 2), some of this is suppressed and you point that out. Without conventions (case 3), it runs wild.
- **No seed data mentioned** — so the report is empty on first load. The good spec seeds demo data; the poor prompt does not, so the professional-looking page renders with nothing in it, or the model invents its own random data inconsistently.

The contrast to land: with the good spec the report shows real grouped activity with seeded data and exactly the columns defined; with the poor prompt the model guesses the shape, invents columns, and (case 3) may not even run cleanly.
