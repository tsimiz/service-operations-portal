# Compliance Requirements: Service Operations Portal

These are written compliance requirements for the training project. They simulate the kind of regulatory constraints a healthcare device maintenance system operates under. Each requirement has a stable identifier; specifications reference these identifiers, and implementations must show traceability from requirement to spec to code to test.

---

## REG-01: Audit trail for state-changing operations

**Requirement.** Every operation that creates or changes the state of an asset, maintenance record, work order or service note must produce an immutable audit entry recording:

1. what happened (operation type and entity)
2. which entity was affected (entity type and id)
3. who performed it (the author or actor supplied with the request)
4. when it happened (server-set UTC timestamp)

**Constraints.**
- Audit entries are append-only. There is no API to modify or delete them.
- The audit entry is written in the same operation as the state change: if the state change succeeds, the entry exists; if the operation fails, no entry is written.
- Audit entries are readable through `GET /api/audit` (newest first) so an auditor can inspect the trail.

**Verification.** Tests must demonstrate, at minimum: an entry is produced by each state-changing operation; failed operations produce no entry; entries cannot be altered through any public API.

**Traceability.** Specifications introducing or modifying state-changing operations must reference REG-01. Commits and change descriptions implementing it must state how the requirement is satisfied.

---

## REG-02 (reserve, use only if a group finishes early): Validation evidence

**Requirement.** Every rejected request (validation failure) must be answerable: the error response must name each failing field and the rule it violated, so that operator input problems can be investigated afterwards without guesswork.

**Verification.** Tests assert that a request violating two rules reports both fields and both rules in the problem-detail response.

---

*Training note: REG-01 arrives in Lab 5 as a change to the approved specification. The point of the exercise is that the SDD flow absorbs a regulatory change like any other requirement, and the written trail (spec → plan → code → test → audit entry) proves compliance by construction.*
