# Compliance Requirements: Service Operations Portal

> **Training simulation, not legal advice or a real compliance specification.**
> This document encodes *plausible, simplified* regulatory requirements so the lab
> exercise feels authentic. It is written by trainers for teaching purposes. The
> real MDR, HIPAA and other obligations that apply to an actual Topcon product are
> defined by Topcon's regulatory, quality and legal functions, not by this file and
> not by an AI tool. The teaching point is deliberate: **AI helps you satisfy and
> trace a requirement that a human authority has defined; it does not get to decide
> what the requirement is.**

These requirements simulate the kind of constraints a healthcare device maintenance
system operates under. Each has a stable identifier; specifications reference these
identifiers, and implementations must show traceability from requirement to spec to
code to test.

---

## Regulatory background (why these requirements exist)

Two regimes are named here because they are the ones Topcon raised. Both are
summarised at the level a developer needs, not at the level a regulatory affairs
specialist works at.

**EU MDR (Regulation (EU) 2017/745), for medical devices placed on the EU market.**
The relevant idea for software work: total-lifecycle **traceability** between
requirements, design, implementation, verification and post-market activity.
Incomplete traceability is one of the most common audit findings. The practical
consequence we simulate: a change to regulated behaviour must be traceable from the
written requirement through to the code and the test that proves it, and that trail
must be reconstructable on demand.

**HIPAA (US, for protected health information).** The relevant idea for this project:
where a system touches PHI, who-did-what-when must be recorded in an audit trail, and
access to records is controlled and logged. **Scope note for this training:** our
portal deliberately manages *devices, not patients*, so no PHI flows through it. We
still simulate the audit-trail discipline HIPAA expects, because the same mechanism
(an append-only record of state changes and access) is what both regimes rely on.

**How this maps to the lab:** REG-01 below is the concrete, codeable expression of
the traceability and audit-trail principles above. It is intentionally small enough
to implement in a lab while being recognisably the real thing.

*If Topcon wants additional regimes reflected (for example specific MDR Annex
references, ISO 13485, FDA 21 CFR Part 820/QMSR), they can be added here before the
session as further REG- entries. Keep them simplified and labelled as simulation.*

---

## REG-01: Audit trail for state-changing operations

*Derives from: MDR lifecycle traceability + HIPAA audit-trail discipline (see background).*

**Requirement.** Every operation that creates or changes the state of an asset,
maintenance record, work order or service note must produce an immutable audit entry
recording:

1. what happened (operation type and entity)
2. which entity was affected (entity type and id)
3. who performed it (the author or actor supplied with the request)
4. when it happened (server-set UTC timestamp)

**Constraints.**
- Audit entries are append-only. There is no API to modify or delete them.
- The audit entry is written in the same operation as the state change: if the state
  change succeeds, the entry exists; if the operation fails, no entry is written.
- Audit entries are readable through `GET /api/audit` (newest first) so an auditor can
  inspect the trail.

**Verification.** Tests must demonstrate, at minimum: an entry is produced by each
state-changing operation; failed operations produce no entry; entries cannot be
altered through any public API.

**Traceability.** Specifications introducing or modifying state-changing operations
must reference REG-01. Commits and change descriptions implementing it must state how
the requirement is satisfied, and code implementing it carries a `// REG-01` reference
(see the Comments rule in the conventions file).

---

## REG-02 (reserve, use only if a group finishes early): Validation evidence

*Derives from: the general regulatory expectation that rejected actions are explainable
after the fact.*

**Requirement.** Every rejected request (validation failure) must be answerable: the
error response must name each failing field and the rule it violated, so that operator
input problems can be investigated afterwards without guesswork.

**Verification.** Tests assert that a request violating two rules reports both fields
and both rules in the problem-detail response.

---

*Training note: REG-01 arrives in Lab 5 as a change to the approved specification. The
point of the exercise is that the SDD flow absorbs a regulatory change like any other
requirement, and the written trail (spec to plan to code to test to audit entry)
proves compliance by construction, which is exactly what MDR traceability and the
HIPAA audit-trail discipline ask for.*
