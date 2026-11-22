#!/usr/bin/env bash
# ============================================================================
# Creates, updates and migrates the standard labels (CONTRIBUTING, "Issues
# e labels"). Idempotent, and it never takes a label off an issue.
#
#   1. Migrates old names to the standard ones (MIGRATE below): if the new
#      label does not exist yet, the old one is renamed, which keeps every
#      issue and PR; if both exist, each issue and PR gets the new label and
#      only then the old one is deleted.
#   2. Creates or updates the labels of .standards/labels.json.
#   3. With xrepo.enabled, creates xrepo, parity and one from:<repo> per
#      repository in the group (this one and xrepo.repos).
#   4. With --prune, deletes the GitHub default labels the standard does not
#      use — only those with no issue or PR at all. One in use is listed and
#      kept.
#
# Usage: .standards/labels.sh [owner/repo] [--prune] [--dry-run]
# ============================================================================
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
config=".standards.json"

repo=""; prune=0; dry=0
for a in "$@"; do
  case "$a" in --prune) prune=1 ;; --dry-run) dry=1 ;; *) repo="$a" ;; esac
done
[ -z "$repo" ] && repo="$(jq -r '.project.repo // empty' "$config")"
[ -z "$repo" ] && { echo "Informe owner/repo ou defina project.repo em $config" >&2; exit 2; }

# old name → standard name
MIGRATE=(
  "bug=type:bug"
  "enhancement=type:feature"
  "documentation=type:docs"
  "question=type:question"
  "needs-decision=status:needs-decision"
  "type:api-contract=type:contract"
)
# GitHub defaults the standard does not use (deleted by --prune when unused)
DEFAULTS=(duplicate "good first issue" "help wanted" invalid wontfix)

run() { if [ "$dry" -eq 1 ]; then printf '  (dry-run) %s\n' "$*"; else "$@"; fi; }
# Read the list into a variable: piping gh into grep -q under pipefail fails
# whenever grep stops early, and the label would look missing.
exists() { local all; all="$(gh label list --repo "$repo" --limit 300 --json name -q '.[].name')"; printf '%s\n' "$all" | grep -qxF -- "$1"; }
numbers_with() { # issues and PRs, any state
  { gh issue list --repo "$repo" --label "$1" --state all --limit 1000 --json number -q '.[].number'
    gh pr list    --repo "$repo" --label "$1" --state all --limit 1000 --json number -q '.[].number'; } | sort -un
}
label() { run gh label create "$1" --repo "$repo" --color "$2" --description "$3" --force >/dev/null; echo "  $1"; }

echo "Labels em $repo$([ "$dry" -eq 1 ] && echo ' (dry-run)'):"

echo "· migração"
for pair in "${MIGRATE[@]}"; do
  old="${pair%%=*}"; new="${pair#*=}"
  exists "$old" || continue
  if ! exists "$new"; then
    run gh label edit "$old" --repo "$repo" --name "$new" >/dev/null
    echo "  renomeada: $old → $new"
  else
    nums="$(numbers_with "$old")"
    for nmb in $nums; do run gh issue edit "$nmb" --repo "$repo" --add-label "$new" --remove-label "$old" >/dev/null; done
    run gh label delete "$old" --repo "$repo" --yes >/dev/null
    echo "  mesclada: $old → $new ($(printf '%s\n' $nums | grep -c . || true) issues e PRs)"
  fi
done

echo "· padrão"
jq -r '.[] | [.name, .color, .description] | @tsv' .standards/labels.json |
while IFS=$'\t' read -r name color desc; do label "$name" "$color" "$desc"; done

if [ "$(jq -r '.xrepo.enabled // false' "$config")" = "true" ]; then
  echo "· entre repositórios"
  label "xrepo"  "5319e7" "Pedido entre repositórios / Cross-repo request"
  label "parity" "fbca04" "A mesma regra nos dois lados / Same rule on both sides"
  { jq -r '.xrepo.self // empty' "$config"; jq -r '.xrepo.repos[]? | split("/")[-1]' "$config"; } |
  while IFS= read -r r; do
    [ -n "$r" ] && label "from:$r" "1d76db" "Aberta por $r / Opened by $r"
  done
fi

if [ "$prune" -eq 1 ]; then
  echo "· limpeza"
  for d in "${DEFAULTS[@]}"; do
    exists "$d" || continue
    used="$(numbers_with "$d" | grep -c . || true)"
    if [ "$used" -gt 0 ]; then
      echo "  mantida: $d (em $used issues ou PRs; migre à mão)"
    else
      run gh label delete "$d" --repo "$repo" --yes >/dev/null; echo "  removida: $d"
    fi
  done
fi
