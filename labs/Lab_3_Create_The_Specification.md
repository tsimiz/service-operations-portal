Lab 3 — Create the specification
Turn a vague request into a spec an agent can build from

Time: 13:00–13:40
Audience: Everyone. Spec writing is not coding, so non-technical participants take full part.

Purpose

This afternoon you build one feature end to end, the same way the morning pipeline did, one stage per lab. In the morning you watched the Spec-Plan agent read a ticket and produce a specification. This lab is you doing the agent's first job by hand: turning a vague one-line request into a specification clear enough that an agent could build from it without guessing.

The goal is not a long document. The goal is a specification with testable acceptance criteria, stated non-functional requirements, and an explicit out-of-scope section, so that the next stage (Lab 4, the plan) and the stage after (Lab 5, the code) have something unambiguous to work from.

Learning objectives

By the end of this lab, you can:

    read a vague request and name what is missing from it
    use Copilot in Ask mode to explore a repository read-only, without changing anything
    write a user story and testable acceptance criteria
    state non-functional requirements instead of leaving them implied
    name out-of-scope items explicitly, so the agent does not invent them
    self-check a specification before approving it

What you will read, write, and save

This lab uses the repository you cloned (service-operations-portal). You read two files, you write one.

Read (the starting point):

docs/specs/spec-service-notes-POOR.md

This is the request as it usually arrives: one paragraph, vague, with everything important left unsaid. It is deliberately poor.

Read (the conventions, for context):

.github/copilot-instructions.md

The house rules. The spec does not need to repeat these (the agent already follows them), but knowing them tells you what you do not have to specify.

Write and save (your output):

docs/specs/spec-lab.md

Your refined specification. Lab 4 reads this exact file, so the path matters.

Required files

    docs/specs/spec-service-notes-POOR.md  (the vague starting point)
    .github/copilot-instructions.md  (the conventions, read-only context)
    docs/specs/spec-service-notes-GOOD.md  (a reference to check against AFTER you write yours; do not open it first)

Important training design

The starting request is deliberately vague. That is the point. The things it does not say are the things an agent will decide for you, confidently and often wrongly, exactly as you saw in the Module 4 poor-prompt demo this morning. Your job is to remove the silence.

A reference specification exists (spec-service-notes-GOOD.md). Do not open it before you write your own. It is there for the self-check in Exercise 3.4, so you can compare your spec to one that works. Opening it first turns the lab into copying.

Exercise 3.1 — Explore in Ask mode

Time: 13:00–13:08
Step 3.1.1 — Switch Copilot to Ask mode

In the Copilot Chat panel, select Ask mode from the mode picker. Ask mode is read-only: it explores and explains, it never edits files. This is the safe mode for understanding a codebase before you change it.

Step 3.1.2 — Explore the request and the conventions

Open docs/specs/spec-service-notes-POOR.md and .github/copilot-instructions.md, then ask Copilot:

    Read docs/specs/spec-service-notes-POOR.md and .github/copilot-instructions.md. What does this request leave unspecified that an implementer would have to decide? List the open questions.

Read the answer critically. It is a starting list, not the truth. You own the decisions; Copilot is input.

Validation

[ ] Copilot is in Ask mode (the mode picker shows Ask)
[ ] No files were changed by this exercise
[ ] You have a list of open questions the vague request leaves open

Exercise 3.2 — Draft the specification

Time: 13:08–13:25
Step 3.2.1 — Create the file

Create a new file at docs/specs/spec-lab.md.

Step 3.2.2 — Write the four parts

Write the specification with these sections. Keep it short and concrete; testable beats long.

    A user story, in the form: As a [role], I want to [action] so that [benefit].
    Acceptance criteria, numbered, each one testable. A criterion is testable when you could write a pass or fail check for it. Name the endpoint, the inputs, the expected response, and the error behaviour.
    Non-functional requirements, stated not implied. For example: concurrency safety for in-memory storage, the error-response format, validation limits.
    An out-of-scope section, naming explicitly what this feature does not include.

You may ask Copilot (still in Ask mode) to help you phrase a criterion, but you decide what goes in. Do not ask it to write the whole spec; that is the skill you are practising.

Validation

[ ] docs/specs/spec-lab.md exists
[ ] It has a user story in the As a / I want / so that form
[ ] It has numbered, testable acceptance criteria
[ ] It states at least two non-functional requirements
[ ] It has an explicit out-of-scope section

Exercise 3.3 — Add test scenarios

Time: 13:25–13:33

Add a short Test scenarios section to spec-lab.md: a handful of named scenarios (T1, T2, ...) covering the happy path, the validation failures, and the not-found case. These become the test strategy in Lab 4 and the tests in Lab 5, so the trail starts here.

Each scenario is one line: what is set up, what is done, what is expected.

Validation

[ ] A Test scenarios section exists with at least four named scenarios
[ ] At least one scenario covers a validation failure (bad input)
[ ] At least one scenario covers the not-found case (unknown asset)
[ ] Each scenario names an observable expected result, not just "works"

Exercise 3.4 — Self-check against what good looks like

Time: 13:33–13:40
Step 3.4.1 — Check your own spec

Before approving, run the checklist from the slides against your spec:

    Are the acceptance criteria testable, with no ambiguity an agent could misread?
    Are non-functional requirements stated, not implied?
    Is out-of-scope named explicitly, so the agent cannot invent it?
    Are the test scenarios concrete?

Step 3.4.2 — Compare to the reference

Now open docs/specs/spec-service-notes-GOOD.md and compare. You are not looking for a match; you are looking for things it named that you left silent. If it specifies something important you missed (a field length, the timestamp being server-set, immutability), add it to your spec-lab.md and note why it matters.

Validation

[ ] You ran the self-check against your own spec
[ ] You compared to the reference and closed any important gaps you found
[ ] spec-lab.md is saved and ready for Lab 4

Done when

You have:

[ ] Explored the request in Ask mode without changing files
[ ] Written docs/specs/spec-lab.md with a user story
[ ] Testable, numbered acceptance criteria
[ ] Non-functional requirements stated explicitly
[ ] An explicit out-of-scope section
[ ] Named test scenarios
[ ] Self-checked and compared to the reference
[ ] Saved spec-lab.md at the exact path docs/specs/spec-lab.md (Lab 4 reads it)
