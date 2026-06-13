# Service Operations Portal

Training repository for **Agentic Software Development Training, Day 2** (Topcon Healthcare · Black Belt Consulting × AO Finland).

This is the project used in the live demonstrations and in Labs 3 to 7. You clone it once; everything the afternoon needs is already inside.

## Prerequisites (check before the training)

- JDK 25 (`java --version`)
- Maven 3.9+ (`mvn --version`)
- VS Code with the GitHub Copilot and GitHub Copilot Chat extensions, signed in with your GitHub Copilot licence
- A GitHub account

## Getting started

```bash
git clone <REPO_URL>
cd service-operations-portal
mvn verify
```

`mvn verify` must finish green before the labs start. If it does not, raise a hand early.

### Quick check: am I ready?

Run the setup checker from the repo root. It verifies Java, Maven (or the wrapper), Git, VS Code and the Copilot extensions, and prints OK / WARN / FIX per line.

```bash
# macOS / Linux
./check-setup.sh            # fast checks only
./check-setup.sh --build    # also runs a green-build smoke test (downloads dependencies)
```
```powershell
# Windows
.\check-setup.ps1           # fast checks only
.\check-setup.ps1 -Build    # also runs a green-build smoke test
```

Do this **before** you travel: the first build downloads a few hundred megabytes, and dozens of people downloading at once on venue WiFi will queue. FIX lines must be resolved; WARN lines are fine to leave.

## UI tests (optional, recommended)

UI tests use Playwright for Java and are excluded from the default build, so the project stays green without browsers. To enable them, install the Chromium browser once (a one-time download) and run with the profile:

```bash
mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install chromium"
mvn verify -Pui-tests
```

If you skip this, everything else in the labs still works.

## What is where

| Path | What it is |
|---|---|
| `.github/copilot-instructions.md` | The repository conventions. Copilot reads these automatically; so should you. |
| `.github/chatmodes/compliance-reviewer.chatmode.md` | The compliance reviewer agent used in the Lab 5 extension. |
| `docs/specs/` | Specifications. The demo specs are here; your Lab 3 spec will live here too. |
| `docs/plans/` | Implementation plans (Lab 4 output). |
| `docs/compliance-requirements.md` | Written compliance requirements (REG-01, REG-02). Used in Lab 5. |
| `docs/demo-material/` | Inputs used in the morning demonstrations. |
| `legacy/MaintenanceLog.java` | A 2006-era class used in the refactoring demonstration. Not part of the Maven build. Yes, it really compiles. |
| `src/main/resources/static/index.html` | The portal UI, one static page with no build tooling. It opens at http://localhost:8080 and shows friendly errors until the APIs exist: the day's job is to make this page come alive. |
| `check-setup.sh` / `check-setup.ps1` | One-shot readiness checker. Run before the labs. |
| `src/test/java/.../ui/` | Playwright UI tests, tagged `ui`, opt-in via `-Pui-tests`. |
| `src/` | The application. Nearly empty on purpose: the afternoon fills it. |

## The afternoon at a glance

1. **Lab 3, specify:** refine a skeleton spec in `docs/specs/` into an approved feature specification.
2. **Lab 4, plan:** generate an implementation plan from your approved spec into `docs/plans/`.
3. **Lab 5, implement:** build the feature from the plan with GitHub Copilot, in pairs (driver and navigator). Then a compliance requirement arrives; the spec absorbs it and the trail proves it.
4. **Lab 6, document:** generate an AI-ready documentation package from the implemented feature.
5. **Lab 7, workshop:** sketch the agent workflow you would want around this project.

## House rules

- The spec is the source of truth. If Copilot invents something the spec does not define, that is your cue to review, not accept.
- Small steps. Review each step before the next.
- You are the reviewer. "Copilot did it" is not a review.
