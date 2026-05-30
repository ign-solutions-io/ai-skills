#!/usr/bin/env bash
set -euo pipefail

# Links all live skills in the repository into a coding agent's personal
# skills directory, so they can be used locally.
#
# Usage: scripts/link-skills.sh [cursor|claude|codex]
#   cursor -> ~/.cursor/skills
#   claude -> ~/.claude/skills   (default)
#   codex  -> ~/.codex/skills
#
# Skips the deprecated/ and in-progress/ buckets; only live skills are linked.
#
# Per-agent targeting: a skill may declare an `agents:` field in its SKILL.md
# frontmatter to restrict which agents it links into, e.g.
#
#     agents: [claude]
#     agents: cursor
#
# A skill with no `agents:` field is shared and links into every agent.
# A skill whose `agents:` list omits the target agent is skipped.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

agent="${1:-claude}"
case "$agent" in
  cursor) DEST="$HOME/.cursor/skills" ;;
  claude) DEST="$HOME/.claude/skills" ;;
  codex) DEST="$HOME/.codex/skills" ;;
  *)
    echo "error: unknown agent '$agent' (expected 'cursor', 'claude', or 'codex')" >&2
    exit 1
    ;;
esac

# If DEST is a symlink that resolves into this repo, we'd end up writing the
# per-skill symlinks back into the repo's own skills/ tree. Detect and bail out
# instead of polluting the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST"

# Prune stale symlinks that point back into this repo. This removes links for
# skills that have been deleted, renamed, or retagged so they no longer apply
# to this agent. Real directories and symlinks pointing elsewhere are left
# untouched.
for link in "$DEST"/*; do
  [ -L "$link" ] || continue
  case "$(readlink "$link")" in
    "$REPO"/*) rm -f "$link" ;;
  esac
done

# Returns 0 (link) or 1 (skip) for a given SKILL.md based on its `agents:` field.
applies_to_agent() {
  local skill_md="$1"
  # Pull the `agents:` value from the frontmatter (first match wins).
  local agents_line
  agents_line="$(sed -n 's/^agents:[[:space:]]*//p' "$skill_md" | head -1)"
  # No `agents:` field => shared => applies to every agent.
  [ -z "$agents_line" ] && return 0
  # Strip list punctuation so "[claude, cursor]" and "claude" both work.
  agents_line="${agents_line//[/ }"
  agents_line="${agents_line//]/ }"
  agents_line="${agents_line//,/ }"
  for a in $agents_line; do
    [ "$a" = "$agent" ] && return 0
  done
  return 1
}

find "$REPO/skills" -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' \
  -not -path '*/in-progress/*' \
  -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  if ! applies_to_agent "$skill_md"; then
    echo "skipped $name (not tagged for $agent)"
    continue
  fi

  # Replace a stale plain-copy directory (from a previous non-symlink install).
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$src" "$target"
  echo "linked $name -> $src"
done
