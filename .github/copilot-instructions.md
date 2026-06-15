# Copilot Instructions: Service Operations Portal

Coding standards for this repository. These apply to every generated change. Workflow (what order to do things in, when to review, when to run a compliance check) lives in the agent files under `.github/agents/` and in the lab instructions under `labs/`, not here.

## Stack

- Java 25, Spring Boot 3.5, Maven
- Dependencies: spring-boot-starter-web, spring-boot-starter-validation, spring-boot-starter-test, and com.microsoft.playwright (test scope, UI tests only). Do not add other dependencies without asking.
- No database. All storage is in-memory using ConcurrentHashMap inside repository classes. Do not introduce JPA, JDBC or any persistence framework.
- No Lombok. Use Java records for immutable data.
- The UI is a single static page at `src/main/resources/static/index.html`. No frontend frameworks, no build tooling, no npm.

## Language

- All code, comments, test names, identifiers and commit messages: English only. Finnish may appear in prompts and discussion, never in the source.
- No single-letter variables, no unexplained abbreviations. Permitted acronyms: ID, URL, API, DTO, UI.

## Architecture

Package root: `fi.blackbelt.portal`

- `api`: REST controllers and request/response DTOs. Controllers contain no business logic.
- `domain`: domain model (records and enums) and services. Services contain all business rules.
- `infra`: in-memory repository implementations.
- `ui` (test sources only): Playwright UI tests.

Dependencies point inward: api depends on domain, infra depends on domain, domain depends on nothing else in this project.

## Code conventions

- Records for immutable data; enums for closed value sets.
- Constructor injection only; no field injection, no @Autowired on fields.
- Repository finders return Optional; never return null.
- Use java.time (Instant for timestamps, set by the server in UTC); never java.util.Date.
- Validate input at the API boundary with jakarta.validation annotations.
- Error responses use RFC 7807 problem details (Spring's ProblemDetail). Unknown resource: 404. Validation failure: 400 with the failing fields named.
- No file exceeds 300 lines. A service over roughly 200 lines probably has more than one responsibility; split it.

## Comments

- Comments explain why, never what. The code states the what; a comment restating the adjacent line is noise and must not be generated.
- Default to no comment. Add one only where the reason for the code is not visible in the code: a non-obvious rule, a deliberate trade-off, a workaround.
- When implementing a specific spec rule or compliance clause, reference its id (for example `// SPEC-SN-001 AC-4` or `// REG-01: same-operation audit write`). These references are the traceability thread from code back to spec.
- No commented-out code, ever. Delete it; version control remembers.
- Javadoc only on public service methods whose contract is not obvious from the signature and the spec. No Javadoc on getters, records or trivial methods.

## Key enum values

Suggest these exact strings, not alternatives:

| Enum | Values |
|---|---|
| `AssetType` | `DEVICE`, `TOOL`, `VEHICLE` |
| `AssetStatus` | `ACTIVE`, `IN_SERVICE`, `RETIRED` |

Enum values are stored and transmitted uppercase, exactly as above.

## Unit test conventions

- JUnit 5 with AssertJ assertions.
- Test class: `{ClassUnderTest}Test` (for example `AssetServiceTest`).
- Test naming: `should_<expected>_when_<condition>` (for example `should_return404_when_assetUnknown`).
- Structure every test as arrange, act, assert. One behaviour per test.
- Every service method has at least one happy-path test and one failure-path test.
- Service tests are plain JUnit, no Spring context. Use Spring's test support (MockMvc) only for API-boundary tests.
- Test the rules in the spec, not the framework. Do not test getters or Spring wiring.
- No real personal data in test fixtures: placeholder names and serial numbers only.

## UI test conventions (Playwright)

- UI tests use Playwright for Java, live in `fi.blackbelt.portal.ui`, and are tagged `@Tag("ui")`.
- UI tests are excluded from the default build. Run them with `mvn verify -Pui-tests` (requires Playwright browsers installed; see README).
- Selectors: `page.getByTestId(...)` exclusively. Never CSS selectors, never visible-text queries; text changes, test ids are a contract.
- `data-testid` register: `{domain}-{component}-{variant}` in kebab-case (for example `asset-form-submit`, `note-list-item`). Every interactive element and every dynamic list in `index.html` carries one.
- When adding UI elements, add the `data-testid` in the same change.
- UI tests cover user flows (add an asset, see it listed), not styling. Keep them few; the unit tests carry the rule coverage.

## Working from a spec

- Implement only what an approved specification in `docs/specs/` defines. The spec is the source of truth; the code is an output.
- Do not invent endpoints, fields or validation rules. Anything the spec lists as out of scope must not appear in the code.
- If the spec is silent or ambiguous on something you need, ask rather than invent.
- Reference the spec ID (for example SPEC-SN-001) in commit messages.

## Compliance and traceability

- Compliance requirements live in `docs/compliance-requirements.md` with REG- identifiers.
- When a spec references a REG- requirement, the implementation must satisfy it and reference the REG id in the code (per the Comments rule) and in the change description.
- The audit trail is append-only: never generate an API or code path that edits or deletes an audit entry (REG-01).

## Commit authorship (repository policy)

- Do not add a `Co-authored-by: Copilot` (or any tool) trailer to commits. Authorship trailers name people; the commit history is an IPR and audit record. The workspace setting `git.addAICoAuthor` is `off` in `.vscode/settings.json`; this is a deliberate repository policy, not a personal habit.
- Keep changes small enough to review: never produce a single change touching more than roughly ten files without explicit approval.

## Anti-patterns: never suggest these

- ❌ Business logic in a controller method
- ❌ JPA, JDBC, H2 or any persistence dependency; storage is in-memory by design
- ❌ Returning null from a repository finder; use Optional
- ❌ java.util.Date or SimpleDateFormat; use java.time
- ❌ Field injection or @Autowired on fields
- ❌ Endpoints, fields or validation rules not present in the approved spec
- ❌ Implementing anything the spec lists as out of scope (for example note editing or deletion)
- ❌ Any API that modifies or deletes audit entries; the audit trail is append-only (REG-01)
- ❌ Lowercasing enum values (`active`, `Device`); the wire format is uppercase
- ❌ CSS or visible-text selectors in UI tests; `getByTestId` only
- ❌ UI tests without the `@Tag("ui")` annotation; untagged UI tests break the default build for everyone without browsers installed
- ❌ Adding frontend frameworks, npm or a build step to the static UI
- ❌ Narrating comments that restate the code (`// loop over assets`, `// return the result`)
- ❌ Commented-out code left in the source
- ❌ A `Co-authored-by: Copilot` (or any tool) trailer in a commit
