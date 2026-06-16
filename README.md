# Service Operations Portal

Training repository for **Agentic Software Development Training, Day 2** (Topcon Healthcare · Black Belt Consulting × AO Finland).

This is the project used in the live demonstrations and in Labs 3 to 7. You clone it once; everything the afternoon needs is already inside.

## Prerequisites (check before the training)

- JDK 25 (`java --version`); if your default is JDK 17, see "Getting Java 25 without disturbing your system Java" below
- Maven 3.9+ (`mvn --version`)
- VS Code with the GitHub Copilot and GitHub Copilot Chat extensions, signed in with your GitHub Copilot licence
- A GitHub account

## Getting Java 25 without disturbing your system Java

The labs target **JDK 25**. If your machine defaults to another JDK (for example a corporate JDK 17), you do not need to change it. This repo ships a `.sdkmanrc` file that pins Java 25 for this project only, using [SDKMAN](https://sdkman.io). SDKMAN installs into your home folder, needs no admin rights, and leaves your system default Java untouched.

> **Windows users:** SDKMAN runs in **Git Bash** or WSL, not in PowerShell or CMD. Git Bash is included with Git for Windows (already a prerequisite), so open **Git Bash** for the steps below and for running `mvn`.

One-time install of SDKMAN (Git Bash / WSL / macOS / Linux):

```bash
curl -s "https://get.sdkman.io" | bash
exec "$SHELL"        # or just close and reopen the terminal
```

Then, from the repo root, install and switch to Java 25:

```bash
cd service-operations-portal
sdk env install      # reads .sdkmanrc, installs JDK 25 if missing, switches this shell
java -version        # should report 25
mvn verify           # builds on Java 25
```

`sdk env` switches only the current shell and only inside this project, so your default Java returns the moment you close the terminal. If `25.0.1-tem` is not offered, run `sdk list java` and put any `25.x-tem` build in `.sdkmanrc`.

### Windows fallback (no Git Bash or WSL)

Install **Eclipse Temurin 25** (MSI) or the **Microsoft Build of OpenJDK 25**, then point the current shell at it:

```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-25"   # adjust to your install path
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version    # should report 25
```

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

On Windows, if a strict execution policy blocks any of this repo's PowerShell scripts, run them unblocked for one session (this does not change any system setting):

```powershell
powershell -ExecutionPolicy Bypass -File .\check-setup.ps1
powershell -ExecutionPolicy Bypass -File .\check-setup.ps1 -Build
powershell -ExecutionPolicy Bypass -File .\reset-demo.ps1        # trainer helper
powershell -ExecutionPolicy Bypass -File .\make-fallback.ps1 -Name <branch> -Message <msg>   # trainer helper
powershell -ExecutionPolicy Bypass -File .\prep-demo-folders.ps1                              # trainer helper
```

The scripts are unsigned by design; the bypass above is the supported way to run them.

Do this **before** you travel: the first build downloads a few hundred megabytes, and dozens of people downloading at once on venue WiFi will queue. FIX lines must be resolved; WARN lines are fine to leave.

Two things the checker is deliberately lenient about, because they vary by version and machine:
- **Copilot** may be a built-in in recent VS Code and not show in the extension list; the checker says WARN and asks you to confirm the Chat view opens, rather than failing.
- **Java present but "not found"** usually means JDK 25 is installed but not on this shell's PATH / JAVA_HOME. The checker detects that case and prints the exact command to set it.

## UI tests (optional, recommended)

UI tests use Playwright for Java and are excluded from the default build, so the project stays green without browsers. To enable them, install the Chromium browser once (a one-time download) and run with the profile:

```bash
mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install chromium" -Dexec.classpathScope=test
mvn verify -Pui-tests
```

If you skip this, everything else in the labs still works.

## What is where

| Path | What it is |
|---|---|
| `.github/copilot-instructions.md` | The repository conventions (coding standards only). Copilot reads these automatically; so should you. |
| `.github/agents/` | Custom agents. The pipeline agents (orchestrator, spec-plan, code, doc, verdict) that the morning demonstration runs, plus `compliance-reviewer.agent.md`, the read-only reviewer used in the Lab 5 extension. |
| `docs/decisions/` | Decision documents (maintenance tickets). The orchestrator runs the pipeline from one of these. |
| `labs/` | The Day 2 lab instructions (Labs 3 to 7), one Markdown file each. Start at `labs/README.md`. |
| `docs/specs/` | Specifications. The demo specs are here; your Lab 3 spec will live here too. |
| `docs/plans/` | Implementation plans (Lab 4 output). |
| `docs/compliance-requirements.md` | Written compliance requirements (REG-01, REG-02). Used in Lab 5. |
| `docs/demo-material/` | Inputs used in the morning demonstrations. |
| `legacy/MaintenanceLog.java` | A 2006-era class used in the refactoring demonstration. Not part of the Maven build. Yes, it really compiles. |
| `src/main/resources/static/index.html` | The portal UI, one static page with no build tooling. It opens at http://localhost:8080 and shows friendly errors until the APIs exist: the day's job is to make this page come alive. |
| `check-setup.sh` / `check-setup.ps1` | One-shot readiness checker. Run before the labs. |
| `reset-demo.sh` / `reset-demo.ps1` | Trainer helper: reset the working tree to a clean demo baseline (shows a preview and asks before deleting). Not needed by participants. |
| `make-fallback.sh` / `make-fallback.ps1` | Trainer helper: capture the current demo result as a fallback branch (commit + label in one call). Not needed by participants. |
| `prep-demo-folders.sh` / `prep-demo-folders.ps1` | Trainer helper: build the three Module 4 demo folders (good / poor / noconv). Not needed by participants. |
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
