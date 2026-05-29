# Pressure Test — Protocol

This is the tool-agnostic protocol followed by both Claude (via the `/pressure-test` skill) and Codex (via paste). Same instructions, same output shape, same filenames — so the two tools can rotate as reviewers without drift.

## Purpose

Iterate on a plan file across multiple review passes until it is **split-ready** — clean enough that `/breakdown-issues` can cut vertical slices without inventing anything. Then extract a clean PRD.

The plan and review history live as two interleaved file series in one folder:

| Series | Pattern | Role |
|---|---|---|
| Plan | `<topic>-plan.md` (v1), then `<topic>-plan-v<N>.md` for N≥2 | The plan itself, each version supersedes the last |
| Chat | `<topic>-chat-<N>[-<reviewer>].md` | The critical review behind each plan jump. Reviewer suffix is `-claude` or `-codex` |

## Two modes

### Mode 1 — Iteration review (default)

Run this each time a new plan version exists and you want it reviewed.

1. **Find the folder.** User points you at a directory. If not given, ask.
2. **Discover the latest pair.**
   - Latest plan = file matching `*-plan-v<N>.md` with the highest `N`, or `*-plan.md` if no `-v<N>` exists.
   - Latest chat = file matching `*-chat-<N>*.md` with the highest `N`.
   - Topic slug = the common prefix (e.g. `stallions-rebuild`).
3. **Read the latest plan in full.** Read the latest chat for context on what the prior reviewer flagged. Skim earlier chats only if the latest plan references them.
4. **Score the plan** across six dimensions, weighted for splittability:

   | Dimension | Weight | What it measures |
   |---|---|---|
   | Decision completeness | 20 | Stack, libs, strategies named — no "TBD" on load-bearing choices |
   | Scope discipline | 20 | In/out-of-scope explicit and item-level, not "the auth stuff" |
   | Acceptance criteria | 20 | Each criterion is testable — no "fast" / "user-friendly" |
   | Dependency clarity | 15 | Blocking inputs and prereqs named; ordering computable |
   | Problem clarity | 10 | Problem stated unambiguously |
   | Risk awareness | 10 | Unknowns surfaced honestly |
   | Overall coherence | 5 | Plan-level smell test |
   | **Total** | **100** | |

5. **Classify every open item** as one of:
   - **Locked** — decided, no further work.
   - **Parked** — open, but non-critical-path AND has a one-line guardrail (what's open + what bounds it). Acceptable for split.
   - **Blocking** — open AND critical-path. Gate fails. Must resolve before split.

6. **Apply the hard gate.** Split-ready requires **all** of:
   - **Zero Blocking items.**
   - **Stack named** (language / runtime / framework / major libs / DB — no TBDs on the critical path).
   - **Every acceptance criterion testable** (no aspirational phrasing).

   A 95/100 score still fails the gate if any hard rule fails.

7. **Write the next chat file.** Filename: `<topic>-chat-<N+1>-<reviewer>.md` in the same folder. `<reviewer>` is `claude` or `codex` depending on which tool is running you.

   Body shape (verbatim):

   ```
   # <Topic> — Conversation <N+1> Synthesis (<Reviewer>)

   **Date:** YYYY-MM-DD
   **Reviewing:** <latest-plan-filename>
   **Prior chat:** <latest-chat-filename>

   ---

   ## Score: <N>/100

   <one-sentence justification naming the 2–3 dimensions that cost the most points>

   ## Split-ready: <YES | NO>

   <if NO, one-line reason quoting the failing gate rule(s) and/or Blocking items>

   ## Gaps
   - ...

   ## Risks
   - ...

   ## Open items
   ### Locked (n)
   - ...
   ### Parked (n) — non-critical, guardrailed
   - **<item>** — guardrail: <one line>
   ### Blocking (n) — must resolve before split
   - **<item>** — why critical: <one line>

   ## Fix list (priority order)
   1. ...
   2. ...

   ## Next moves
   1. Want me to /grill-me on the Blocking items?
   2. Want me to draft revised wording for the top fixes?
   3. Want me to re-score after you revise?
   4. <if Split-ready: YES> Want me to extract a clean PRD?
   ```

8. **Report back to the user** with the chat written and the verdict line. Offer the four next moves.

### Mode 2 — PRD extraction (only when Mode 1 returned `Split-ready: YES`)

Trigger: user invokes the skill again on the same folder and asks for PRD extraction, or accepts "next move #4" from the last Mode 1 pass.

1. **Read the final plan version.**
2. **Strip iteration scaffolding** — drop "what changed from v3" sections, version comparisons, supersedes lines, review history.
3. **Restructure to the office PRD shape**:
   - Problem
   - Solution
   - User stories
   - Modules / agents affected
   - In-scope
   - Out-of-scope
   - Definition of done (acceptance criteria, testable)
   - Open risks (parked items only — Blocking items shouldn't exist at this point)
4. **Write the PRD** to:
   ```
   /home/ziroock/stallions/office/meeting-room/inbox/executive-charles/<YYYY-MM-DD>_<HHMM>_PDT_from-<reviewer>_prd-<topic>.md
   ```
5. **Tell the user the PRD landed** and that the next step is `/breakdown-issues <prd-path>`.

## Tone rules

- Blunt. No "great start but...".
- Intent is to help the user succeed, not to win the review.
- Don't pad. If a section has nothing material, write "nothing material" and move on.
- Never invent gaps to fill a quota. Honest "this is solid" beats fluff.

## Tool identity

- Running as a Claude `/pressure-test` skill invocation → use `-claude` suffix.
- Running from PROTOCOL.md pasted into Codex → use `-codex` suffix.
- Never use both suffixes. Never omit the suffix on chats from v2 onward (the original `chat-1.md` may be suffix-less; later chats must declare provenance).
