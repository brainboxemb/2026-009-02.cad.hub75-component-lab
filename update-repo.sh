#!/usr/bin/env bash
set -euo pipefail

mode="${1:-update}"
case "$mode" in
  update) command_name="repo-update" ;;
  status) command_name="repo-status" ;;
  *) echo "Usage: ./update-repo.sh [update|status]" >&2; exit 2 ;;
esac

command -v git >/dev/null 2>&1 || {
  echo "Git was not found in PATH." >&2
  exit 1
}

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$root" ]] || {
  echo "Run update-repo.sh from inside a Git repository." >&2
  exit 1
}

scad_tool="$root/tools/tool.scad-project/scad-project.sh"
[[ -f "$scad_tool" ]] || {
  echo "tool.scad-project is not initialized. Run ./bootstrap.sh first." >&2
  exit 1
}

"$scad_tool" --project "$root/project.yml" "$command_name"
