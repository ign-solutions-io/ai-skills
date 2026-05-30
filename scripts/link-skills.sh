#!/usr/bin/env bash
set -euo pipefail

# Links all live skills in the repository into a coding agent's personal
# skills directory, so they can be used locally.
#
# Usage: scripts/link-skills.sh [cursor|claude]
#   cursor -> ~/.cursor/skills
#   claude -> ~/.claude/skills   (default)
#
# Skips the deprecated/ and in-progress/ buckets; only live skills are linked.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

agent="${1:-claude}"
case "$agent" in
  cursor) DEST="$HOME/.cursor/skills" ;;
  claude) DEST="$HOME/.claude/skills" ;;
  *)
    echo "error: unknown agent '$agent' (expected 'cursor' or 'claude')" >&2
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

find "$REPO/skills" -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' \
  -not -path '*/in-progress/*' \
  -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  # Replace a stale plain-copy directory (from a previous non-symlink install).
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$src" "$target"
  echo "linked $name -> $src"
done
