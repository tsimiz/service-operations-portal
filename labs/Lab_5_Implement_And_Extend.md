Lab 5 — Implement, then extend with a regulatory check
Build the feature under a review gate, then make it traceable

Time: 14:30–15:00
Audience: Technical users, power users, and their paired non-technical navigator. Work in pairs.

Purpose

In the morning, the Code agent implemented the plan step by step, and Default Approvals showed a human review gate at each file write. This lab is you being the Code agent: implement your plan in Agent mode, reviewing each change before it is applied.

Then you extend the feature. A written compliance requirement arrives (REG-01, an append-only audit trail), and you make the change satisfy it and prove that it did. This is the Topcon-relevant moment of the day: where traceability stops being a slide and becomes a trail you can point at, from the written requirement, through the spec and the code, to the test.

You are building on the Asset API you generated in Lab 3 (Exercise 3.0), not from nothing. Service Notes attach to assets, so your plan implements against that existing Asset API. If you do not see the Asset classes under src/main, generate them first with the Lab 3 setup prompt, then implement the notes.

Learning objectives

By the end of this lab, you can:

    implement a plan in Agent mode under Default Approvals, reviewing each edit
    keep generation scoped so the build stays green at every step
    work as a driver and navigator pair
    absorb a new compliance requirement as a spec change, not a code hack
    request a compliance review from the compliance-reviewer agent
    point at the trail from requirement to spec to code to test

What you will use

Read:

    docs/plans/plan-lab.md  (your plan from Lab 4)
    docs/specs/spec-lab.md  (your spec from Lab 3)
    docs/compliance-requirements.md  (used in the extension, Exercise 5.4)

Use as a reviewer:

    .github/agents/compliance-reviewer.agent.md  (the compliance-reviewer agent, in the same .github/agents/ folder as the pipeline agents)

Produce:

    application code under src/main/, tests under src/test/
    an updated spec and plan for the REG-01 extension

Required files

    docs/plans/plan-lab.md  (your plan)
    docs/specs/spec-lab.md  (your spec)
    .github/copilot-instructions.md  (conventions, applied automatically)
    docs/compliance-requirements.md  (REG-01, for the extension)

Important training design

Keep Copilot on Default Approvals for this lab, not Autopilot. Default Approvals means every file write asks you to approve before it applies. That approval click is the review gate, and the review gate is the lesson. Pairs share the work: the driver runs Copilot and types, the navigator reads every diff before the driver approves it.

Exercise 5.1 — Set up the pair and the mode

Time: 14:30–14:34
Step 5.1.1 — Pick roles

Decide who is the driver (runs Copilot, approves edits) and who is the navigator (reads each diff, catches problems). Swap halfway if you like.

Step 5.1.2 — Switch to Agent mode, confirm Default Approvals

In the Copilot Chat panel, select Agent mode. Confirm Default Approvals is on and Autopilot is off, so each file write asks for approval.

Validation

[ ] Driver and navigator roles assigned
[ ] Copilot is in Agent mode
[ ] Default Approvals is on (an edit will prompt for approval), Autopilot is off

Exercise 5.2 — Implement step by step

Time: 14:34–14:52
Step 5.2.1 — Start the build

Open docs/plans/plan-lab.md so it is in context, then prompt:

    Read docs/plans/plan-lab.md and implement step 1. Run the tests after. Wait for my approval before continuing to step 2.

Step 5.2.2 — Review each step before approving

For each step: the navigator reads the diff, the driver approves only if it is right. After each step, the build runs. If a step is red, fix it before moving on. Do not let the plan run ahead of the build.

Keep generation scoped: one step at a time. If Copilot tries to do three steps at once, stop it and ask for one.

Validation

[ ] Each plan step was reviewed before its edits were approved
[ ] The build is green after the last step (mvn verify, or the wrapper ./mvnw verify in Git Bash)
[ ] The feature works: the endpoints from spec-lab.md respond as the acceptance criteria require
[ ] Nothing out-of-scope was generated (check against the spec's out-of-scope section)

Exercise 5.3 — Checkpoint before the extension

Time: 14:52–14:54

Confirm the base feature is done and green before adding the compliance requirement. A clean checkpoint here makes the extension a clear, separate change, which is exactly what makes it traceable.

Validation

[ ] The base feature is complete and the build is green
[ ] You can name which test covers each acceptance criterion

Exercise 5.4 — The regulatory extension (REG-01)

Time: 14:54–14:58
Step 5.4.1 — Read the requirement

Open docs/compliance-requirements.md and read REG-01 (the append-only audit trail). This requirement was written by a human authority (here, the trainers simulating Topcon's regulatory function). The agent does not get to decide what the requirement is; it helps you satisfy and trace it.

Step 5.4.2 — Absorb it as a spec change first

Do not jump straight to code. Add the REG-01 requirement to your spec-lab.md: a new acceptance criterion that references REG-01, and a test scenario for it. Then add the implementing step to your plan. Only then implement it, in Agent mode, under Default Approvals as before.

The order matters: requirement, then spec, then plan, then code, then test. That order is the trail.

Validation

[ ] spec-lab.md now has an acceptance criterion that references REG-01
[ ] plan-lab.md has the implementing step
[ ] The code writes an append-only audit entry when the regulated state changes
[ ] There is no endpoint or code path that edits or deletes an audit entry
[ ] A test proves the audit entry is written; the build is green

Exercise 5.5 — Request a compliance review

Time: 14:58–15:00
Step 5.5.1 — Run the compliance-reviewer agent

Select the compliance-reviewer agent (from .github/agents/compliance-reviewer.agent.md) in the agent picker, and ask it to review your change against REG-01. It is a read-only reviewer: it reports, it does not write code.

Step 5.5.2 — Read the verdict and the trail

The reviewer reports PASS, PASS WITH FINDINGS, or FAIL, and names the trail from requirement to spec to code to test. If it finds a gap, close it. This is the same compliance check the morning pipeline's Verdict agent did, now pulled out into its own agent, because in a regulated system you want compliance as an explicit, separately-owned gate.

Validation

[ ] The compliance-reviewer produced a verdict
[ ] Any findings it raised were closed
[ ] You can point at the trail: REG-01 in the requirements, the criterion in the spec, the code with the REG-01 reference, the test that proves it

Done when

You have:

[ ] Implemented your plan in Agent mode under Default Approvals, reviewing each step
[ ] A green build with the base feature working to spec
[ ] Added REG-01 as a spec change, then a plan step, then code, then a test
[ ] An append-only audit trail with no edit or delete path
[ ] A passing compliance review from the compliance-reviewer agent
[ ] A trail you can point at from requirement to spec to code to test

Optional, read-only, if your pair is ahead: open .github/agents/code.agent.md. It is the role you just played, written down: implement the plan step by step, scoped to src/, under per-edit review. The Default Approvals gate you used is a rule inside it. You ran one custom agent for real today (the compliance-reviewer); in Lab 7 you run the whole pipeline.
