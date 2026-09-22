#!/usr/bin/env bash
# Managed-Source: brainboxemb/tool.git-project/bootstrap/consumer-update.sh
# Managed-Source-Version: 0.2.10
# Managed-Source-Revision: 65b1b06a2178e51d0ce07d5771a3e55cd15db0ba
# Managed-Local-Patch: none
set -euo pipefail
mode="${1:-update}"
tool_path="tools/tool.git-project"
root="$(git rev-parse --show-toplevel)"
tool="$root/$tool_path/git-project.sh"
[[ -x "$tool" ]] || { echo "tool.git-project is not initialized. Run ./bootstrap.sh first." >&2; exit 1; }
case "$mode" in
  update|status) "$tool" "$mode" --repo "$root" ;;
  *) echo "Usage: ./update.sh [update|status]" >&2; exit 2 ;;
esac
