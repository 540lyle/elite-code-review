#!/usr/bin/env bash
set -euo pipefail

tmpfile="${TMPDIR:-/tmp}/elite_review_diff.txt"

has_output() {
  local cmd="$1"
  if eval "$cmd" >"$tmpfile" 2>/dev/null; then
    if [ -s "$tmpfile" ]; then
      cat "$tmpfile"
      return 0
    fi
  fi
  return 1
}

emit_untracked_diffs() {
  local found=0
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    git diff --no-index -- /dev/null "$path" || true
    found=1
  done < <(git ls-files --others --exclude-standard)

  if [ "$found" -eq 1 ]; then
    return 0
  fi

  return 1
}

if has_output "git diff --staged --patch --find-renames --find-copies"; then
  exit 0
fi

if has_output "git diff --patch --find-renames --find-copies"; then
  exit 0
fi

if has_output "git diff origin/main...HEAD --patch --find-renames --find-copies"; then
  exit 0
fi

if has_output "git diff origin/master...HEAD --patch --find-renames --find-copies"; then
  exit 0
fi

if has_output "git show --stat --patch --find-renames --find-copies --format=fuller HEAD"; then
  exit 0
fi

if emit_untracked_diffs; then
  exit 0
fi

echo "No meaningful diff could be determined." >&2
exit 1
