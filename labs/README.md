Day 2 Labs — Service Operations Portal

Agentic Software Development Training, Day 2 (Topcon Healthcare, Black Belt Consulting × AO Finland).

These labs build one feature, Service Notes, end to end. Each lab is one stage of the agentic pipeline you saw demonstrated in the morning: you do by hand what each agent did. Nothing is throwaway; each lab feeds the next.

Starting point: the Asset API foundation

The labs extend an existing system. The Service Notes feature attaches notes to assets (`POST /api/assets/{assetId}/notes`, and an unknown asset returns 404), so the Asset API has to exist first. You generate it yourself at the start of Lab 3 (Exercise 3.0), using the same prompt the morning's Demo 3.1 used. It takes a few minutes and gives you assets to attach notes to. There is nothing to check out: you build the foundation, then build Service Notes on top of it.

The arc

| Lab | Stage | You are the... | Output | Time |
|---|---|---|---|---|
| Lab 3 | Specify | Spec-Plan agent (part 1) | docs/specs/spec-lab.md | 13:00–13:40 |
| Lab 4 | Plan | Spec-Plan agent (part 2) | docs/plans/plan-lab.md | 13:40–14:15 |
| Lab 5 | Implement and extend | Code agent (+ Compliance) | code under src/, REG-01 trail | 14:30–15:00 |
| Lab 6 | Document | Doc agent | docs/changelog.md, docs | 15:00–15:15 |
| Lab 7 | Design | the architect | an agent architecture canvas | 15:15–16:00 |

The handoffs

Each lab's output is the next lab's input, so the path names matter:

    Lab 3 saves docs/specs/spec-lab.md, which Lab 4 reads.
    Lab 4 saves docs/plans/plan-lab.md, which Lab 5 reads.
    Lab 5 implements under src/ and extends the spec and plan for REG-01.
    Lab 6 documents what Lab 5 built.
    Lab 7 designs the workflow you just lived.

Modes used

    Ask mode (Lab 3): read-only exploration, no changes.
    Plan mode (Lab 4): produce an implementation plan from a spec.
    Agent mode (Labs 5 and 6): the supervised, multi-step build, on Default Approvals (not Autopilot) so the review gate stays real.

Meeting the agents (building toward the morning pipeline)

You do each stage by hand first, then meet the agent that automates it. The custom agents live in .github/agents/.

    Labs 4, 5, 6 each end by opening the matching agent file (spec-plan, code, doc) and reading it: the role you just performed, written down. Read-only, nothing to run on your lab files.
    Lab 5 runs one agent for real: the compliance-reviewer (read-only, so it reviews your work cleanly).
    Lab 7 runs the whole pipeline as a capstone: the orchestrator dispatches all the agents on a separate demo ticket. This is the slide 5 reveal from the morning, now hands-on, with every agent recognisable.

The five pipeline agents are wired for the demo-ticket flow (a ticket in docs/decisions/), not for your lab files, which is why you read them in Labs 4 to 6 and only run the full set in the Lab 7 capstone. The compliance-reviewer is the exception: it is read-only and works on whatever is in the workspace, so Lab 5 runs it on your code.

The feature and the reference

The lab feature is Service Notes. The starting point is the deliberately vague docs/specs/spec-service-notes-POOR.md. A reference specification, docs/specs/spec-service-notes-GOOD.md, exists for the self-check in Lab 3; do not open it before writing your own.

The Module 4 demo feature (the Maintenance Activity Report) is a different feature, so the demo does not give away the lab.
