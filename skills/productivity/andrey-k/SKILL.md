---
name: andrey-k
description: Zaprin's four-principle coding/decision filter (think before coding, simplicity first, surgical changes, goal-driven execution). Invoke when the user types /andrey-k, asks for "the andrey-k principles", or says to re-evaluate a recommendation against these guidelines. Use to re-examine a plan, question, or decision and strip out speculation, assumptions, and complexity that isn't justified.
---

# Andrey-K Principles

Four guidelines that bias toward caution over speed. For trivial tasks, use judgment. For anything load-bearing, apply all four.

When invoked, **re-examine the current recommendation or plan against each principle in order**, name where it violated each one, and produce a minimal revised answer. Don't restate the principles abstractly — apply them concretely to the thing on the table.

---

## 1. Think before coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask or check the code.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

**Common violation:** recommending an architecture based on what the code "probably" does instead of grepping it.

## 2. Simplicity first

**Minimum that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- No defense-in-depth that protects against a vibe instead of a named failure mode.

**Common violation:** adding knobs ("free defense in depth," "easy to extend later") for benefits you can't name concretely.

Ask: *would a senior engineer call this overcomplicated?* If yes, cut.

## 3. Surgical changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove orphans *your* changes created. Don't remove pre-existing dead code unless asked.

**The test:** every changed line traces directly to the user's request.

## 4. Goal-driven execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Refactor X" → ensure tests pass before and after.

For multi-step tasks, state a brief plan with a verify step per item:

```
1. <step> → verify: <check>
2. <step> → verify: <check>
```

**Common violation:** recommending a lock without a one-line test that would prove the lock holds.

---

## How to apply this skill

When invoked on a recommendation, plan, or open question:

1. Name where the current proposal violates each principle (be specific — quote the speculative bit).
2. Produce a minimal revised proposal.
3. For each lock in the revised proposal, add a one-line verify step.
4. Flag anything that genuinely stays open and why.

Bias toward cutting. The win condition is fewer knobs, not more.

---

## Attribution

`andrey-k` is **not** original work by Zaprin Ignatiev (`ziroock`) — it is curated into this repository as part of an encyclopedia of useful skills. The four principles are derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls, by way of the [`karpathy-guidelines`](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/skills/karpathy-guidelines/SKILL.md) skill in [`multica-ai/andrej-karpathy-skills`](https://github.com/multica-ai/andrej-karpathy-skills) (MIT licensed). The `andrey-k` framing, wording, and "how to apply" workflow are this fork's adaptation; full credit for the underlying ideas belongs upstream.
