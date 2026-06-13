# Copilot Instructions: Service Operations Portal

This repository is a training project for spec-driven development. Follow these conventions in all generated code, plans and documentation.

## Stack

- Java 25, Spring Boot 3.5, Maven
- Dependencies: spring-boot-starter-web, spring-boot-starter-validation, spring-boot-starter-test. Do not add other dependencies without asking.
- No database. All storage is in-memory using ConcurrentHashMap inside repository classes. Do not introduce JPA, JDBC or any persistence framework.
- No Lombok. Use Java records for immutable data.

## Architecture

Package root: `fi.blackbelt.portal`

- `api`: REST controllers and request/response DTOs. Controllers contain no business logic.
- `domain`: domain model (records and enums) and services. Services contain all business rules.
- `infra`: in-memory repository implementations.

Dependencies point inward: api depends on domain, infra depends on domain, domain depends on nothing else in this project.

## Code conventions

- Records for immutable data; enums for closed value sets.
- Constructor injection only; no field injection, no @Autowired on fields.
- Repository finders return Optional; never return null.
- Use java.time (Instant for timestamps, set by the server in UTC); never java.util.Date.
- Validate input at the API boundary with jakarta.validation annotations.
- Error responses use RFC 7807 problem details (Spring's ProblemDetail). Unknown resource: 404. Validation failure: 400 with the failing fields named.
- Keep classes small. If a class needs a comment to explain its sections, split it.

## Test conventions

- JUnit 5 with AssertJ assertions.
- Test naming: `should_<expected>_when_<condition>` (for example `should_return404_when_assetUnknown`).
- Every service method has at least one happy-path test and one failure-path test.
- Test the rules in the spec, not the framework. Do not test getters or Spring wiring.

## Spec-driven workflow

- Implement only what an approved specification in `docs/specs/` defines. The spec is the source of truth; the code is an output.
- If the spec is silent or ambiguous on something you need, stop and ask. Do not invent requirements, endpoints, fields or validation rules.
- Anything listed as out of scope in the spec must not appear in the code.
- Work in small, verifiable steps and present each step for review before continuing.
- Reference the spec ID (for example SPEC-SN-001) in commit messages.

## Compliance

- Compliance requirements live in `docs/compliance-requirements.md` with REG- identifiers.
- When a spec references a REG- requirement, the implementation must satisfy it, and the change description must state how, referencing the REG id.
- Before declaring REG-related work complete, request a review from the compliance-reviewer chat mode (`.github/chatmodes/compliance-reviewer.chatmode.md`).

## Etiquette

- Disclose AI assistance in commit messages and pull requests.
- Keep changes small enough to review. Never produce a single change touching more than roughly ten files without explicit approval.
