Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `in-progress/`, and `deprecated/` must not appear in either.

## Supported agents

These skills target both **Claude Code** and **Cursor**. The `SKILL.md` format (frontmatter + markdown body) is shared by both, so a skill is cross-agent by default.

- **Install locally**: `bun run setup:cursor` / `bun run setup:claude` (or `scripts/link-skills.sh <claude|cursor>` directly) symlinks the live buckets into `~/.cursor/skills` or `~/.claude/skills`. Re-run after adding, renaming, or retagging a skill.
- **Install via the `skills` CLI**: `bunx skills add ign-solutions-io/ai-skills -a <cursor|claude-code> -g` installs straight from GitHub for end users who aren't cloning the repo.
- **Agent-specific skills**: a skill that only works on one agent declares an `agents:` frontmatter field, e.g. `agents: [claude]`. The linker skips it for any agent not listed. A skill with no `agents:` field is shared and links everywhere. Keep this list as small as possible — prefer cross-agent skills.
- **`.claude-plugin/plugin.json` is Claude-only.** It is the Claude Code plugin manifest; Cursor discovers skills directly from `~/.cursor/skills`, so there is no Cursor equivalent to maintain. Only list cross-agent or Claude-tagged skills there — never a `cursor`-only skill.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.
