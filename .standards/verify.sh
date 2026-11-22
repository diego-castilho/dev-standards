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

echo "· modelo do standards.yml"
# Dependabot updates the workflows but not the template the installer copies.
want="$(grep -Eo 'actions/checkout@[^[:space:]]+' .github/workflows/standards.yml)"
have="$(grep -Eo 'actions/checkout@[^[:space:]]+' .standards/templates/standards.yml)"
if [ "$want" != "$have" ]; then
  echo "  ✗ .standards/templates/standards.yml usa $have; o workflow usa $want" >&2; exit 1
fi
echo "  ✓ $want"

echo "· travas"
bash .standards/test-guard-bash.sh

echo "· checagens"
bash .standards/test-check.sh

echo "· padrão"
bash .standards/check.sh all-local
