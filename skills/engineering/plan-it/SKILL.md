---
name: plan-it
description: Turn a raw project idea into a build-ready "Plan v1 (hardened)" markdown document via a grill session. Use whenever someone wants to plan a new software project, says "plan this project", "make a plan v1", "grill my idea", "help me scope this app", "create a build-ready plan", or shares a project idea and asks how to start building it. Also trigger when someone wants to harden, pressure-test, or upgrade an existing plan-v0 draft into a locked, build-ready version.
---

# Hardened Project Plan (Plan v1)

Produce a single build-ready plan document. Output file: `plan-v1.md` in the user's working folder.

## Workflow rules

1. **Grill before you write.** Never draft from the raw idea. Run a "grill session" first: interrogate scope, users, hosting, data sources, hard constraints (budget, hardware, legal), and what v1 explicitly excludes. Challenge weak assumptions. Write the plan only once the big decisions are settled. Use AskUserQuestion where available.
2. **Match depth and rigor, not decisions.** If the user shares a previous plan as an example, treat it purely as a quality calibration. Nothing domain-specific from it may leak into the new plan.
3. **Every locked decision states three things:** the choice, the rejected alternative(s), and the reason. "We use X" is not a decision; "We use X over Y because Z" is.
4. **Add guards, not just features.** For anything that can fail or mislead (bad data, edge cases, abuse), write the guard into the plan: thresholds, grace periods, manual-review flags.
5. **Standing rule — built-but-mocked:** any integration needing real credentials is wired with the real shape but mocked keys, so the app works end-to-end before secrets exist.
6. **Park ruthlessly.** Anything not needed for v1 goes to *Parked ideas* with an explicit "reconsider if …" trigger — never silently dropped.
7. **Success conditions are testable user outcomes:** "User can …" or "System does …" — never vague goals like "good UX".
8. **One file,** in the exact structure below.

## Output structure

# [project-name] — Plan v1 (hardened)

> Supersedes `plan-v0.md` (if any). Build-ready plan after a full grill session.
> Parked ideas (with "reconsider if" triggers) live in the *Parked* section below.

## Project

2–4 sentences: what it is, who it's for (specific names/roles), what it replaces, where it runs. One bold line defining **v1 scope** — what's in, implying everything else is out.

## Locked decisions

Group into 3–6 subsections that fit the project. Common ones:

### Data / inputs
Where data comes from, how often, fallbacks, politeness/limits, change detection. Quality bar: name the exact mechanism (e.g. "upsert on natural key; deltas appended to a history table; not-seen-for-N-runs → inactive with grace period").

### Data model
Core tables/entities, what's a column vs. flexible JSON, normalization choices, storage budgets with real numbers if disk/cost matters.

### Runtime / stack
Hosting, runtime, framework, database, queue/cron — each with the rejected alternative and why. Prefer fewer stateful services.

### Features
Each major feature: what it does, the mechanism (not just the outcome), and its guard. Scoring/ranking features must be transparent and tunable, with explicit weights and a manual-review flag for outliers.

### Quality
The single validate command (typecheck + lint + tests). Where tests focus: components where bugs actually hurt. What's deliberately NOT tested. The built-but-mocked rule.

## v1 success conditions

Numbered list, 5–10 items, each independently checkable. First: core loop runs against real data. Last: `validate` passes with no errors.

## Parked for after the core ships

Bullets: name + one-line "reconsider if [trigger]".

## Useful artifacts discovered during the grill

Concrete facts unearthed while planning that the builder will need: URL patterns, API quirks, encodings, IDs, gotchas — anything you'd otherwise rediscover painfully.
