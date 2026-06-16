# Day 2 Demo Runbook v2: the pipeline reveal, Modules 3 and 4

**Service Operations Portal · VS Code + GitHub Copilot · prepared by Black Belt Consulting**

This v2 adds the pipeline reveal (the slide 5 destination demo) and corrects the slide numbers for the v4 deck (the three new opening slides shifted everything by three). The Module 3 and Module 4 demo content is unchanged from v1; only the slide references and a few cross-links moved.

All demos run in one repository against one domain, so the afternoon labs feel familiar before they start. Every live-generation demo has a fallback (a branch with the finished result, or a GIF) in case the network misbehaves.

Slide map (v4 deck):
- Pipeline reveal: slide 5 (with slides 6 and 7, the future-state pipeline)
- Module 3 demos: slide 23
- Module 4 demos: slide 30
- Labs 3 to 7: slides 32 to 38

---

## The pipeline reveal (slide 5): the destination demo

This is the new opening beat. Before the landscape and the tools, you show the finished machine: the orchestrated five-agent pipeline running on a maintenance ticket, ending at a COMPLETE verdict. Five to seven minutes including narration. It is the anchor for the whole day, so do not rush it, and fall back to the GIF the moment a live run looks slow.

### What runs

The agents live in `.github/agents/` (orchestrator, spec-plan, code, doc, verdict, plus compliance-reviewer). The ticket is `docs/decisions/2026-06-16-maintenance-due-flag.md`: a small Mode 3 maintenance increment that adds a derived `maintenanceDue` flag (true when an asset's status is IN_SERVICE) to the asset list.

### One-time prep (before the day): a pipeline base branch

The ticket is a *maintenance* increment, so it needs the Asset API to already exist. Build it once, ahead of the day, onto a dedicated branch, exactly like the demo fallback branches.

```bash
git checkout main
git checkout -B pipeline-base
```

Then generate the Asset API once (this is Demo 3.1's prompt; run it now so the base is ready):

> Implement the Asset API described in docs/demo-material/requirements-asset.md. Follow the repository conventions: production code only (domain model, repository, controller, error handling) and the unit tests. Work in small steps.

Confirm the build is green, then commit:

```bash
git add -A
git commit -m "pipeline-base: Asset API (SPEC, demo 3.1 output) for the reveal"
```

`pipeline-base` is now a clean starting point: the Asset API exists, ready for the maintenance increment. (If you prefer, `demo-m3-1-done` already holds the Asset API and can serve as the base instead.)

### Running the reveal (live, at slide 5)

```bash
git checkout pipeline-base
git checkout -B pipeline-demo      # throwaway branch for the live run
```

Confirm Default Approvals is on (not Autopilot). Then, in Copilot Chat, select the **orchestrator** agent and give it:

> Run the pipeline for the ticket at docs/decisions/2026-06-16-maintenance-due-flag.md.

Narrate each stage as it fires:
- **spec-plan** writes the spec and the plan.
- The pipeline **pauses at the plan-review gate**: approve it out loud, so the room sees the human gate.
- **code** implements the derivation under Default Approvals; approve each edit.
- **doc** updates the changelog.
- **verdict** checks the acceptance criteria and the compliance note, says COMPLETE, and stops.

Line to land: "This afternoon you do each of those stages yourselves. By 15:00 you understand everything you just watched."

### Reset after the reveal

```bash
git checkout main
git checkout -B live-demo
git clean -xfd
```

The reveal ran on `pipeline-demo` (throwaway); `pipeline-base` stays intact for a re-run or for the Lab 7 capstone. `main` is back to the pristine skeleton for Module 3.

### Fallbacks

- Capture a **GIF** of a clean reveal run before the day; play it if the live run stalls.
- `pipeline-demo` built from a good run is itself a fallback: check it out and walk the diffs.
- Build the GIF and a known-good branch the same sitting you freeze the agents and the ticket, so they cannot drift.

### Controlling which agents run

There is no config file. The orchestrator decides the sequence from its own instructions, and the set it can call is the `agents:` list in `.github/agents/orchestrator.agent.md`. To run a single stage instead (as Lab 5 does with the compliance-reviewer), pick that one agent from the picker rather than the orchestrator.

---

## Repository layout (already prepared in the repo)

```
service-operations-portal/
├── .github/
│   ├── copilot-instructions.md        # coding standards (always in context)
│   └── agents/                        # custom agents
│       ├── orchestrator.agent.md
│       ├── spec-plan.agent.md
│       ├── code.agent.md
│       ├── doc.agent.md
│       ├── verdict.agent.md
│       └── compliance-reviewer.agent.md
├── docs/
│   ├── compliance-requirements.md     # REG-01, used in the Lab 5 extension
│   ├── decisions/
│   │   └── 2026-06-16-maintenance-due-flag.md   # the pipeline reveal ticket
│   ├── specs/
│   │   ├── spec-maintenance-report-GOOD.md
│   │   ├── spec-maintenance-report-POOR.md
│   │   ├── spec-service-notes-GOOD.md           # the lab feature reference
│   │   └── spec-service-notes-POOR.md           # the lab starting point
│   ├── plans/                         # Lab 4 output lands here
│   └── demo-material/
│       └── requirements-asset.md      # Demo 3.1 input
├── labs/                              # Labs 3 to 7 (Markdown)
├── legacy/
│   └── MaintenanceLog.java            # pre-generated, Java 7 style (Demo 3.2)
├── src/main/java/fi/blackbelt/portal/ # nearly empty before demos
├── src/main/resources/static/
│   └── index.html                     # the portal UI; served at http://localhost:8080
└── pom.xml                            # Java 25, Spring Boot 3.5, web + validation + test
```

**Prep checklist (test run before Monday):**
- [ ] Repo builds clean: `mvn verify` (or `./mvnw verify`) on the skeleton
- [ ] `pipeline-base` branch built (Asset API present) for the slide 5 reveal; reveal dry-run reaches COMPLETE; GIF captured
- [ ] `legacy/MaintenanceLog.java` compiles in isolation
- [ ] Fallback branches: `demo-m3-1-done`, `demo-m3-2-done`, `demo-m3-3-done`, `demo-m4-good`, `demo-m4-poor`, `demo-m4-plan`
- [ ] Three Module 4 demo folders built via `prep-demo-folders` (`portal-good`, `portal-poor`, `portal-noconv`) and smoke-tested
- [ ] Copilot agent mode works on the demo machine; time each generation, target under 90 seconds per step
- [ ] Conventions file is picked up (ask Copilot "what are this repo's conventions?")
- [ ] Custom agents appear in the agent picker (check the Agent Customizations panel)
- [ ] Browser tab staged on `http://localhost:8080` (empty-skeleton "comes alive" state, the before picture)

---

## Running the demos (branch model and reset)

The whole live-coding day runs on one rule: **`main` is the pristine skeleton and you never demo on it.** It is exactly what participants clone. Every demo happens on a throwaway branch cut from `main` (or from `pipeline-base` for the reveal), so resetting to a clean state is one deterministic action.

### Once, in the morning

```bash
git checkout main
./mvnw verify          # warms the dependency cache and confirms a green baseline
```

That download lands in `~/.m2`, outside the repository. Warm it once and it stays warm all day. The wrapper files (`mvnw`, `.mvn/`) are committed on `main`, so they survive every reset.

### To start a demo

```bash
git checkout -B live-demo   # -B recreates the branch fresh from wherever you are
```

### To reset between demos

```bash
git checkout main
git checkout -B live-demo
git clean -xfd              # removes untracked generated files AND build output
```

`git clean -xfd` is the part that matters: plain checkout restores tracked files but leaves everything Copilot created. First time, dry-run it with `git clean -xfdn` and eyeball the list.

Keep `reset-demo.sh` on `main` as a one-liner so you are not typing three commands in front of the room.

### Reset rule: at module boundaries, not between chained steps

The Module 3 demos chain (3.3 generates tests against 3.1's output), so do not reset between them; let them accumulate on `live-demo`. Reset only at module boundaries. If a mid-chain step fails, recover from the known-good fallback branch rather than starting over.

### Keep `git status` visible

In the VS Code source-control panel. It is your safety net before any clean, and it doubles as a teaching prop: the room sees exactly which files Copilot created, which reinforces "you are the reviewer."

### Building the fallback branches

Each demo names a fallback branch: a pre-built, committed, known-good result you check out live if generation stalls. Build them all in one sitting after you freeze the specs, conventions and prompts, so they cannot drift out of sync with a live run. A drifted fallback is worse than none; if you cannot guarantee a branch matches current inputs, delete it and talk through the result instead.

---

## Module 3 demos (slide 23, ~15 min total)

### Demo 3.1: Generate code from requirements (~6 min)

**Input:** `docs/demo-material/requirements-asset.md` (Asset: id, name, type, serial number, status; GET all, GET one with 404, POST create; in-memory).

**Live prompt (Copilot Chat, agent mode):**

> Implement the Asset API described in docs/demo-material/requirements-asset.md. Follow the repository conventions, but in this step implement the production code only: domain model, repository, controller, and error handling. Do not write tests yet; we will generate tests in a later step. Work in small steps and show me each before continuing.

**Talk track:** point at three things while it generates: it follows the conventions file without being told the stack; small steps let you review each piece; the requirements file is doing the steering, not the prompt.

**Why "do not write tests yet":** the conventions file tells Copilot every service method gets tests, so without this line it generates them here and demo 3.3 has nothing left to do. Scoping the output deliberately, even against a standing convention, is itself the lesson.

**Fallback:** `git checkout demo-m3-1-done`

### Demo 3.2: Refactor legacy code (~4 min)

**Live prompt:**

> Refactor legacy/MaintenanceLog.java to modern Java 25 following the repository conventions: records, java.time, Optional, streams, immutability where sensible. Explain the three most important changes you made.

**Talk track:** the explanation matters as much as the refactor; this is review skill. Bridge line: "this is the kind of legacy a real device fleet accumulates; this afternoon you build its modern equivalent from a spec." Hidden thread-safety bug (shared SimpleDateFormat) is a good catch to fish for.

**Fallback:** `git checkout demo-m3-2-done`

### Demo 3.3: Generate unit tests (~4 min)

Runs against Demo 3.1's output, which chains the block. Frame it as completing what the conventions require: 3.1 stopped at production code, so now Copilot adds the tests the house rules call for.

**Live prompt:**

> Generate unit tests for AssetService following the repository test conventions. Cover the happy path and the failure cases for each method. Then run the tests.

**Talk track:** tests follow the naming convention; a failing test is a gift, review and fix live.

**Fallback:** `git checkout demo-m3-3-done`

### Demo 3.3b (optional stretch, ~3 min): generate a UI test

Only if ahead and Playwright browsers are installed.

**Live prompt:**

> Write a Playwright UI test following the repository UI test conventions: add an asset through the form and assert it appears in the asset list. Use getByTestId selectors only.

**Talk track:** point at the data-testid register; the test cannot break when wording changes. Mention `@Tag("ui")` keeps it out of the default build.

**Fallback:** skip entirely; nothing later depends on it.

---

## Module 4 demos (slide 30, ~22 min total)

The strongest moment of the morning. One feature, the **Maintenance Activity Report**, built three ways from three prepared folders, each on its own port, so all three run at once and the degradation is on screen simultaneously.

| Run | Folder (port) | Spec | Conventions | Expected on screen |
|---|---|---|---|---|
| 4.1 | `portal-good` (8081) | Good SDD spec | present | Correct: grouped summary, seeded data, only the defined columns |
| 4.2 | `portal-poor` (8082) | Poor one-liner | present | Drifts: invented columns, guessed grouping, empty (no seed) |
| 4.3 | `portal-noconv` (8083) | Poor one-liner | absent | Breaks loudly: invented database, auth, or a non-rendering page |

Present good-first to establish the target, then watch it degrade. Build the three folders once with `prep-demo-folders` before training; each has its `.git` removed and a distinct `server.port` baked in.

### Demo 4.1: Good spec, conventions present (~8 min)

Run from `portal-good` (http://localhost:8081). Seeds its own demo data, so it needs nothing from Module 3.

**Live prompt:**

> Implement the Maintenance Activity Report described in docs/specs/spec-maintenance-report-GOOD.md. Follow the repository conventions. Implement only what the spec defines, including the report page UI and the startup seed data.

**Talk track:** point at the spec doing the steering (named columns, named grouping axis, seed data, out-of-scope killing export and filters). The grouped table with exactly the defined columns is the reference screen for the next two runs.

**Fallback:** `git checkout demo-m4-good`

### Demo 4.2: Poor prompt, conventions present (~6 min)

Run from `portal-poor` (http://localhost:8082). No spec in the folder, so Copilot must build from the vague prompt alone.

**Live prompt (verbatim, add nothing):**

> Add a maintenance report page to the portal. It should show the maintenance history in a nice way, grouped and also detailed, and look professional. Make it production ready.

**Talk track:** hunt the differences against the 4.1 reference, with the room: invented columns, a guessed grouping axis, UI over-reach, and an empty report (the poor prompt never mentioned seed data). Name the cause: "the prompt was silent, so the model decided, confidently." Then the nuance: what the conventions caught (no database, in-memory, thin controller) and what they could not (only the spec knows what a maintenance record contains).

**Fallback:** `git checkout demo-m4-poor`

### Demo 4.3: Poor prompt, no conventions (~5 min, the explosive beat)

Run from `portal-noconv` (http://localhost:8083). Same poor prompt as 4.2.

**Port note:** with nothing constraining it, Copilot may write its own `application.properties` and overwrite `server.port=8083`, often to 8080. Stop the 8080 staging app before this run, or say plainly "that is a port collision I caused; the real breakage is what the model invented" and move on.

**Talk track:** the loud one. Expect a JPA/H2 dependency, an invented auth layer, a different page shape. If it does not render, that is the demo, not a failure. Three-screen recap: good spec plus conventions (correct), poor plus conventions (drifted but contained), poor alone (broken).

**Fallback:** `portal-noconv` is itself the prepared state; keep a pre-generated screenshot.

### Demo 4.4 (optional): Generate an implementation plan (~5 min)

Produces the artifact shape Lab 4 will use.

**Live prompt:**

> Read docs/specs/spec-maintenance-report-GOOD.md and produce an implementation plan as docs/plans/plan-maintenance-report.md. Include ordered implementation steps, a task breakdown where each task is small enough to verify on its own, and a test strategy mapped to the spec's test scenarios. Do not write any code.

**Talk track:** review the plan critically on screen, reject or reorder one step live. Planning is a review skill.

**Fallback:** `git checkout demo-m4-plan`

---

## Timing and risk notes

- Pipeline reveal: 5 to 7 min, GIF fallback ready.
- Total live generation across the six Module 3 and 4 demos: aim under 8 minutes of actual waiting. Everything else is talk track over the results.
- If the venue network is slow, run Module 3 from fallback branches and keep live generation for Module 4; the poor-vs-good comparison is the demo that must run live.
- The Module 4 browser payoff costs no generation time: the UI ships per run, it is a reveal, not a build.
