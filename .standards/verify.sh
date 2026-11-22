#!/usr/bin/env bash
# verify for the dev-standards repository itself: what CI runs, run it
# locally before a PR. Projects set their own `verify` in .standards.json.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "· sintaxe dos scripts"
for f in .standards/*.sh .claude/hooks/*.sh; do bash -n "$f"; done
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning .standards/*.sh .claude/hooks/*.sh
else
  echo "  (shellcheck ausente; pulado)"
fi

echo "· JSON"
for f in .standards.json .claude/settings.json .standards/templates/*.json .standards/labels.json; do
  [ -f "$f" ] && jq empty "$f"
done

echo "· travas"
bash .standards/test-guard-bash.sh

echo "· checagens"
bash .standards/test-check.sh

echo "· padrão"
bash .standards/check.sh all-local
