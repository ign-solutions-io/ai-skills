---
name: pressure-test
description: Iterate critical reviews on a plan file (and its prior chat history) until it is split-ready, then extract a clean PRD. Takes a folder containing paired plan + chat files (`<topic>-plan-v<N>.md` and `<topic>-chat-<N>-<reviewer>.md`), reads the latest pair, produces the next review chat with a readiness score (1–100), gap list, risk list, fix list, and Locked/Parked/Blocking classification of every open item. Final pass extracts a clean PRD to the office inbox. Use when the user wants to stress-test a plan, mentions "pressure test", "readiness check", "split-ready", "tear my plan apart", points at a folder of plan/chat iterations, or wants to finalize a plan into a PRD before breakdown-issues.
---

# Pressure Test

Critically iterate on a plan file across multiple review passes until it is split-ready for `/breakdown-issues`, then extract a clean PRD. Tool-agnostic — Claude and Codex follow the same protocol so they can rotate as reviewers.

## How to use

**Read [PROTOCOL.md](PROTOCOL.md) in this same folder. Follow it exactly.** It contains the full protocol: file discovery rules, scoring rubric, gate logic, output filename convention, and PRD extraction format. Both Claude and Codex follow the same protocol — the only difference is the reviewer suffix on the chat filename (`-claude` for you, `-codex` for the other tool).

## Quick orientation

- **Input:** path to a folder containing `<topic>-plan*.md` and `<topic>-chat-*.md` files. If no folder given, ask which one.
- **Mode 1 (default):** review the latest plan, write the next chat file, return a `Split-ready: YES/NO` verdict.
- **Mode 2 (terminal):** when the last pass returned `Split-ready: YES`, extract a clean PRD to `office/meeting-room/inbox/executive-charles/`.

## Tone

Blunt. Intent is to help the user succeed — push hard on the plan, not on them. Don't pad. Never invent gaps.

## Composition with other skills

- `/grill-me` — handoff target when Blocking items need user input to resolve.
- `/breakdown-issues` — next pipeline step after PRD extraction.
- `/write-prd` — alternative entry point if the user is starting from a conversation, not a plan file.

## Attribution

`pressure-test` is an original skill authored by **Zaprin Ignatiev** (aka `ziroock`). It is not part of the upstream [`mattpocock/skills`](https://github.com/mattpocock/skills) repository — it is custom development added in the [`ign-solutions-io/ai-skills`](https://github.com/ign-solutions-io/ai-skills) fork. It composes with several upstream skills (`/grill-me`, `/breakdown-issues`, `/write-prd`) but the protocol, scoring rubric, and PRD-extraction flow are this fork's own contribution.
