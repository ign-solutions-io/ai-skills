---
name: pass
description: Summarize the current brainstorm, grill, or planning session into a self-contained baton-pass prompt for a NAMED next agent (Codex, Claude, etc.) to pick up a defined next step. Use when the user wants to hand work to another agent or model, mentions "pass this to Codex/Claude", "write a prompt for the next agent", or wants a paste-ready prompt to continue/critique the session's output elsewhere.
argument-hint: "<target agent> — <what the next step is>  (e.g. 'codex — adversarially review the plan')"
---

Produce a **paste-ready prompt** that hands this session's work to another agent so it can do a
defined next step. Unlike `handoff` (which compacts the conversation for a fresh continuation of
*your* work), `pass` is outward-facing and task-defining: the recipient is a *named other agent*,
possibly a different model, doing a *specific* next move.

## Steps

1. **Resolve the two arguments — the recipient and the task.** Parse them from the arguments if
   given; otherwise ask, in one question: *which agent* (e.g. Codex, Claude, a fresh session) and
   *what next step* (e.g. adversarial review, implement, continue planning, critique). Do not
   proceed without both.
2. **Identify the artifacts this session produced or touched** — plans, PRDs, ADRs, docs, code,
   issues, commits, diffs. The pass-prompt must **reference these by path/URL, not restate them.**
   Re-paste content only when the recipient cannot read the repo.
3. **Write the pass-prompt** with the structure below, tailored to the recipient and task.
4. **Output it in a fenced code block** for copy-paste, and also save a copy to a path from
   `mktemp -t pass-XXXXXX.md` (read the file before writing). Tell the user both: the block to
   paste and the saved path.

## The pass-prompt must contain (omit a section only if truly N/A)

- **Role + framing** — who the recipient is in this hand-off (e.g. "alternating second author —
  review adversarially, don't rubber-stamp"; "implementer — build, don't redesign"). Set the stance.
- **Read first** — an ordered list of artifacts to read (by path/URL), most important first,
  including the source intent and the project conventions (e.g. CLAUDE.md) when relevant.
- **Verify, don't trust** — if the work makes claims about code or facts, tell the recipient to
  check them against the source rather than assume they're correct.
- **The task** — what to do, in one tight paragraph. Name the highest-leverage thing to attack or
  build first (carry forward any flags/risks/open questions this session deliberately left open).
- **Output contract** — exactly what to produce, in what format, and the file path to write it to.
  Match an existing convention in the repo if one exists (cite an example file).
- **Bar** — what "done well" means, so the recipient can self-check.

## Rules

- Self-contained: the recipient gets only this prompt + the repo. No "as we discussed."
- Honest about soft spots: surface the unresolved decisions and risks, don't paper over them — the
  point of a pass is often to get a second mind onto exactly those.
- Keep it short. A pass-prompt is a baton, not a recap of the whole session.
- Don't invent a task the session didn't lead to. If the next step is genuinely unclear, ask.
