# dev-standards

> 🇧🇷 [Versão em português](README.pt-BR.md)

A template repository that gives a project a written development process and the
automation that enforces it, so that people and AI coding agents work by the same rules.

It covers:

- **Branches and releases.** `main` holds what was released and `develop` collects the work
  in progress. Every change arrives through a short-lived branch and a pull request, and
  releasing a version or shipping an urgent fix follows a step-by-step procedure.
- **A readable history.** Commit messages follow Conventional Commits with a scope, pull
  requests have a title and description format, and the CHANGELOG is kept in English and
  Portuguese.
- **Issues.** Forms for bugs, features and tasks, a small set of labels, and a format for
  asking another repository for a change.
- **Enforcement.** GitHub rulesets protect `main` and `develop`, and a check on every pull
  request validates branch names, titles and commit messages. The same check runs locally.
- **Guardrails for agents.** Claude Code hooks block risky commands, such as pushing to
  `main`, and ask before others, such as creating a tag, deleting files or touching
  production. Skills walk the agent through a release and a hotfix.

You adopt it with **Use this template** in a new repository, or with the installer in an
existing one, and update it later without overwriting what is specific to your project.

## What is in it

| Piece | Where | Enforcement |
|---|---|---|
| The process: branches, commits, PRs, merge, release, hotfix, issues, sensitive data, languages | [CONTRIBUTING.md](CONTRIBUTING.md) · [pt-BR](CONTRIBUTING.pt-BR.md) | Doc |
| What is agent-specific: session start, mandatory stops, parallel conversations | [CLAUDE.md](CLAUDE.md) | Doc |
| Per-project configuration | [.standards.json](.standards.json) | Auto |
| A visual map of every rule, with Mermaid diagrams (PT) | [docs/REGRAS.md](docs/REGRAS.md) | — |
| Release, hotfix and cross-repo runbooks | [.claude/skills/](.claude/skills/) | Skill |
| Agent guards: blocks pushes to `main`, asks before tags, production, deletions | [.claude/hooks/](.claude/hooks/) | Confirm · Blocked |
| PR checks: branch, title, commits, EN/PT parity, private IPs in Markdown | [.github/workflows/standards.yml](.github/workflows/standards.yml) | Auto |
| Issue forms, PR template, labels, branch rulesets | [.github/](.github/), [.standards/](.standards/) | Auto |

## Using it

### New project

1. On GitHub, **Use this template** → new repository.
2. Clone it and run:

   ```bash
   .standards/install.sh --here --name "My Project"
   git switch -c develop && git push -u origin develop
   .standards/labels.sh --prune
   .standards/rulesets.sh          # needs GitHub Pro for private repositories
   ```

3. Fill in `.standards.json` (scopes, `verify`, release, production) and the project
   sections of `CLAUDE.md` and `CONTRIBUTING*.md`.
4. First commit: `chore(standards): adopt dev-standards X.Y.Z`, through a PR into `develop`.

### Existing project

From a dev-standards checkout, on a branch of the project:

```bash
/path/to/dev-standards/.standards/install.sh --into /path/to/project --name "Project"
```

It copies what the standard owns, merges `CLAUDE.md` (the old content becomes the project
section) and `.claude/settings.json` (the standard hooks are added, everything else stays),
and creates `.standards.json`, `CHANGELOG.md` and the workflows only if missing. Nothing is
committed.

### Updating a project

Run the same `--into` command from a newer dev-standards tag. Files owned by the standard are
replaced; in Markdown, only the managed blocks change:

```markdown
<!-- standards:begin core v0.1.0 -->
…the standard's text: do not edit here…
<!-- standards:end -->

## Project-specific
…yours, never touched…
```

Open the result as `chore(standards): sync to vX.Y.Z`.

## Versioning

The standard follows SemVer and its own process: tags `vX.Y.Z`, a bilingual
[CHANGELOG](CHANGELOG.md), `develop` and `main`. Each project records the version it follows
in `standardsVersion`.

## Roadmap

- **Phase 1 (this version):** template, installer, guards, skills, PR checks, labels and
  rulesets.
- **Phase 2:** a `sync` that opens the update PR by itself and a CI check that flags edits
  inside managed blocks.
- **Phase 3:** skills and hooks shipped as a Claude Code plugin, if keeping copies in many
  repositories becomes a burden.
