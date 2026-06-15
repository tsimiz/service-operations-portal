Lab 7 — Agentic development workshop
Design the agent workflow you just lived

Time: 15:15–16:00
Audience: Everyone, in small mixed groups.

Purpose

You just built, by hand, what the pipeline did at the start of the day. Lab 3 was the Spec-Plan agent's spec. Lab 4 was its plan, with a review gate. Lab 5 was the Code agent, with per-edit approval, and you split out a compliance agent for the regulatory extension. Lab 6 was the Doc agent. You lived every stage, every review gate, and the audit trail.

This workshop is the pivot from doing to designing. In small groups, sketch the agent workflow for this project: which agents, which human approval points, what governance, what documentation. The goal is not a perfect design. The goal is to make the need for structure felt, so that when we name the formal methodologies next, you recognise them as answers to a problem you just had.

Learning objectives

By the end of this workshop, you can:

    map a feature's lifecycle onto a set of agents with clear responsibilities
    place human approval gates where they belong and say why
    name what each agent may and may not do (its boundary)
    describe the documentation and traceability a regulated context needs
    recognise the formal methodologies as answers to this design problem

What you will produce

A single-page agent architecture canvas per group. Paper or a shared screen is fine. This is a sketch, not a specification.

Required files

None. This is a design workshop. You may refer back to:

    your spec-lab.md, plan-lab.md, changelog, and the compliance review from Labs 3 to 6
    the agentic-development-pipeline diagram shown this morning (slide 7)

Important training design

This is a facilitated canvas, ten to fifteen minutes of sketching, then one insight per group. It is not a full design exercise. In a remote-heavy room, sketch on paper or talk it through and take volunteers; the goal is to raise interest, not to produce a finished architecture.

Exercise 7.1 — Form groups and recall the stages

Time: 15:15–15:20
Step 7.1.1 — Group up

Form small mixed groups (technical and non-technical together; the non-technical view on approval gates and documentation is valuable here).

Step 7.1.2 — List the stages you lived

As a group, list the stages you went through across Labs 3 to 6: specify, plan, implement, check compliance, document. For each, note who or what did the work and where a human decided.

Validation

[ ] Groups formed, mixed where possible
[ ] The group has listed the stages from Labs 3 to 6
[ ] For each stage, the group noted where a human approved or decided

Exercise 7.2 — Sketch the canvas

Time: 15:20–15:35

On one page, sketch the agent workflow for this project. Include:

    Agents: one box per agent, with a one-line responsibility. (Spec-Plan, Code, Test, Doc, Compliance, Verdict is a reasonable starting set; your group may split or merge.)
    Human approval gates: mark where a human must approve, adjust, or reject. The plan-review gate and per-edit approval you used are natural examples.
    Boundaries: for at least two agents, note what they may not do (for example: the compliance agent reviews but never writes code; the doc agent never touches src/).
    Documentation and traceability: what each stage produces, and how the trail from requirement to spec to code to test is kept.

Approval gates and review gates are the natural examples to argue about; that argument is the point.

Validation

[ ] The canvas names the agents and a responsibility for each
[ ] Human approval gates are marked, with at least one the group can justify
[ ] At least two agents have an explicit boundary (what they may not do)
[ ] The canvas shows what is produced and how traceability is kept

Exercise 7.3 — One insight per group

Time: 15:35–15:50

Each group shares one insight: the approval gate they argued about most, the boundary they found hardest to draw, or the agent they were unsure whether to include. One per group keeps it moving; in a remote-heavy room, take volunteers rather than forcing every group.

Validation

[ ] Each group (or volunteers) shared one insight
[ ] The insights were captured for the methodologies discussion that follows

Exercise 7.4 — Name the methodology

Time: 15:50–16:00

The canvas made the need for structure felt. The industry has formalised exactly this. As the trainer names the methodologies (GitHub Spec Kit, OpenSpec, the Black Belt and AO Finland method, and the wider field), match each back to a part of your canvas: the Constitution is your agent boundaries and conventions, the role-divided agents and decision documents are your stages and gates, the traceability spine is your requirement-to-test trail.

This is the closing connection: the structured method you just sketched is the same one running in production at a regulated client, and the simplified version of it ran in front of you this morning.

Validation

[ ] The group matched at least one methodology element back to their canvas
[ ] The group can name which methodology fits this stack most naturally and why

Exercise 7.5 — Capstone (optional): run the whole pipeline

Time: only if the room is ahead, or as a trainer-led closing demo

You have done every stage by hand and met every agent. Now run the whole thing and watch the pipeline from this morning (slide 5) execute end to end.

Step 7.5.1 — Run the orchestrator

Select the orchestrator agent in the agent picker, and give it the ticket:

    Run the pipeline for the ticket at docs/decisions/2026-06-16-maintenance-due-flag.md.

This ticket is a different, small feature (a maintenanceDue flag on Asset), deliberately separate from your Service Notes work, so the pipeline runs on its own without disturbing what you built.

Step 7.5.2 — Watch the stages and the gates

Watch the orchestrator dispatch the agents you met this afternoon: spec-plan produces the spec and plan, the pipeline pauses at the plan-review gate for your approval, code implements under Default Approvals, doc updates the changelog, and verdict checks the acceptance criteria and the compliance note, then says COMPLETE and stops. This is the morning's reveal, and you can now read every agent it runs, because each one is a job you did today.

Note for the trainer: with a large room, run this once at the front as a closing callback rather than having all 71 people run it; the GIF from the morning is the fallback if the live run is slow.

Validation

[ ] The orchestrator ran the pipeline end to end on the demo ticket
[ ] You saw the plan-review gate and at least one Default Approvals prompt
[ ] The pipeline ended at a COMPLETE verdict and stopped
[ ] You can name which lab taught each agent in the pipeline

Done when

You have:

[ ] Listed the stages you lived in Labs 3 to 6
[ ] Sketched an agent architecture canvas with agents, gates, boundaries, and traceability
[ ] Shared one insight with the room
[ ] Connected your canvas to at least one formal methodology
[ ] (Optional) Run, or watched, the full orchestrated pipeline on the demo ticket
