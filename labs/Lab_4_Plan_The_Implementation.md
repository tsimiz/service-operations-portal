Lab 4 — Plan the implementation
Turn an approved spec into a plan you would actually follow

Time: 13:40–14:15
Audience: Everyone. Reviewing a plan is a skill, not a coding task; non-technical participants take full part.

Purpose

In the morning, the Spec-Plan agent did two jobs: it wrote the spec, and it turned the spec into a step-by-step plan. Lab 3 was the first job. This lab is the second: feed your approved specification to Copilot in Plan mode and produce an implementation plan, then review it critically.

The point of this lab is the review. A plan an agent produces is a draft, not an instruction you must obey. In the morning pipeline there was a plan-review gate: the pipeline stopped and waited for a human to approve, edit, or reject the plan before any code was written. This lab is you being that gate.

Learning objectives

By the end of this lab, you can:

    use Copilot in Plan mode to produce an implementation plan from a spec
    read a generated plan critically rather than accepting it
    judge whether each step is small enough to verify on its own
    reject or reorder a step, and say why
    confirm a test strategy maps back to the spec's acceptance criteria

What you will read, produce, and save

Read (your output from Lab 3):

docs/specs/spec-lab.md

Produce and save:

docs/plans/plan-lab.md

Lab 5 reads this exact file, so the path matters. The docs/plans/ folder already exists in the repo.

Required files

    docs/specs/spec-lab.md  (your approved spec from Lab 3)
    .github/copilot-instructions.md  (conventions, applied automatically)

Important training design

Plan mode researches the spec and the codebase and outlines a multi-step plan. It still produces a plan a human rejects or reorders. Plan mode is not auto-approval. The plan-review gate is the whole point of this lab, so do not skip the review and jump to Lab 5.

Exercise 4.1 — Generate the plan

Time: 13:40–13:50
Step 4.1.1 — Switch to Plan mode

In the Copilot Chat panel, select Plan mode from the mode picker.

Step 4.1.2 — Run the planning prompt

Open docs/specs/spec-lab.md so it is in context, then paste this prompt exactly:

    Read docs/specs/spec-lab.md and produce an implementation plan at docs/plans/plan-lab.md. Include ordered implementation steps, each small enough to verify on its own, and a test strategy mapped to the spec's acceptance criteria. Do not write any code.

Let it produce the plan file. Do not implement anything yet.

Validation

[ ] Copilot is in Plan mode
[ ] docs/plans/plan-lab.md was produced
[ ] No application code under src/ was created or changed in this exercise
[ ] The plan contains ordered steps and a test strategy

Exercise 4.2 — Review the plan critically

Time: 13:50–14:05
Step 4.2.1 — Read every step

Read the plan as if you will have to follow it. For each step ask:

    Is this step small enough that I could implement it and verify it on its own?
    Does it depend on something not yet built? Is the order right?
    Does it stay inside the spec, or does it add something the spec did not ask for?

Step 4.2.2 — Change at least one thing

Find at least one step to improve, and make the change yourself in plan-lab.md (or ask Copilot to revise that step). Reasonable changes: split a step that does too much, reorder two steps whose dependency is backwards, remove a step that implements something out of scope, or add a missing step (for example wiring or a test).

Write a one-line note in the plan saying what you changed and why. That note is the record of the review gate doing its job.

Validation

[ ] You read every step of the plan
[ ] You changed at least one step (split, reordered, removed, or added)
[ ] You recorded what you changed and why
[ ] The revised plan stays within the spec (nothing out-of-scope crept in)

Exercise 4.3 — Confirm the test strategy traces to the spec

Time: 14:05–14:15

Look at the plan's test strategy. For each acceptance criterion in spec-lab.md, find the test step that covers it. If a criterion has no test, add one. If a test covers nothing in the spec, question why it is there.

This is the traceability thread starting to form: spec criterion, plan test step, and in Lab 5, the actual test. A criterion with no test is a gap you want to find now, not in Lab 5.

Validation

[ ] Every acceptance criterion in spec-lab.md maps to at least one test step in the plan
[ ] Any criterion that lacked a test now has one
[ ] The plan is saved at docs/plans/plan-lab.md (Lab 5 reads it)

Exercise 4.4 — Meet the agent that automates this

Time: read-only, do at the end if time allows

You have now done the Spec-Plan agent's whole job by hand: the specification in Lab 3 and the plan here. Open the agent that automates it and read it.

Open .github/agents/spec-plan.agent.md. It is not magic; it is the instructions for the job you just did, written down. Notice the difference in plumbing: that agent reads a ticket from docs/decisions/ and writes its own scratch files, whereas you wrote spec-lab.md and plan-lab.md by hand. Same job, two ways. You will run this agent, and the rest of the pipeline, as the capstone in Lab 7.

Validation

[ ] You read spec-plan.agent.md and can say in one sentence what it automates

Done when

You have:

[ ] Produced docs/plans/plan-lab.md in Plan mode from your spec
[ ] Read the plan critically, step by step
[ ] Changed at least one step and recorded why
[ ] Confirmed every acceptance criterion maps to a test step
[ ] Saved plan-lab.md at the exact path docs/plans/plan-lab.md (Lab 5 reads it)
[ ] Read spec-plan.agent.md, the agent that automates Labs 3 and 4
