# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Todas as mudanças notáveis deste projeto serão documentadas neste arquivo.
O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

---

## [Unreleased]

### 🇧🇷 Português

#### Adicionado
- **ADR-0001: recursos nativos do GitHub primeiro.** Registra, a partir da leitura da documentação do GitHub e do manual do `gh`, o que o padrão passa a usar de nativo (tipos e campos de issue, dependências, sub-issues, rulesets, releases imutáveis, Projects, milestones, topics, stacked PRs, composite action, lockfile de Actions) e o que continua script, com o motivo. O resumo da leitura fica em `docs/referencias/github-nativo.md`.
- **Mapa visual das regras** em `docs/REGRAS.md`, com diagramas Mermaid que o GitHub desenha: onde vive cada regra, o ciclo de uma mudança, o gitflow com hotfix, branches, commits, PR e merge, release, hotfix, o ciclo de vida de uma issue, os pedidos entre repositórios, o trabalho com agentes e as travas. Cada regra diz como é garantida e aponta para a sua fonte. O instalador leva o mapa aos projetos, com uma seção própria no fim que o sync não altera.

#### Alterado
- **Repositório público, com histórico recomeçado.** O padrão passa a viver num repositório público, e o anterior fica privado e arquivado. O histórico começa num commit de importação para não publicar e-mail pessoal nem nomes de projetos privados; as versões 0.1.0 e 0.2.0 continuam descritas abaixo.

### 🇺🇸 English

#### Added
- **ADR-0001: native GitHub features first.** Records, from a read of GitHub's documentation and the `gh` manual, what the standard now uses natively (issue types and fields, dependencies, sub-issues, rulesets, immutable releases, Projects, milestones, topics, stacked PRs, a composite action, the Actions lockfile) and what stays a script, and why. The reading summary lives in `docs/referencias/github-nativo.md`.
- **Visual map of the rules** in `docs/REGRAS.md`, with Mermaid diagrams GitHub renders: where each rule lives, a change's lifecycle, gitflow with hotfix, branches, commits, PRs and merges, release, hotfix, an issue's lifecycle, cross-repo requests, working with agents and the guards. Each rule says how it is enforced and points to its source. The installer ships the map to projects, with a project section at the end that the sync leaves alone.

#### Changed
- **Public repository, with a fresh history.** The standard now lives in a public repository, and the previous one stays private and archived. History starts at an import commit so that no personal email or private project name is published; versions 0.1.0 and 0.2.0 are still described below.

## [0.2.0] - 2026-11-22

### 🇧🇷 Português

#### Adicionado
- **Skill `/xrepo`** para pedidos entre repositórios irmãos: caixa de entrada, abrir pedido no outro repo, tratar pedido recebido e verificar o que o outro lado resolveu, com os comandos `gh` e parada antes de escrever no outro repositório. Esses comandos viviam só no `CLAUDE.md` do projeto de origem.
- **`check.sh docs`:** o CI recusa IP de rede privada (RFC 1918) em Markdown. Endereços de documentação (RFC 5737) passam.
- **`verifyRunsIn: "local"`** no `.standards.json`, para projetos cujo `verify` só roda numa máquina específica (Xcode num Mac): o CI pula o passo e o resultado vai na Verificação do PR. E `docs.auditDir`, para a pasta dos registros de auditoria.
- **`install.sh --replace-hooks`**, que tira os hooks de guarda anteriores do projeto antes de pôr os do padrão; sem a opção, o instalador lista os hooks que vão rodar junto.

#### Alterado
- **Commits medidos contra o histórico real dos projetos que usam o padrão.** O assunto mira 72 caracteres e só é recusado acima de 100 (acima de 72, o CI avisa). O escopo é obrigatório em `feat`, `fix`, `perf` e `refactor` e opcional nos demais. Passam também os assuntos `release: vX.Y.Z` e `hotfix: vX.Y.Z`, que chegam à `develop` pelo merge de volta, e as branches `claude/…` e `dependabot/…`. Com as regras da 0.1.0, cerca de metade dos commits dos dois repositórios seria recusada.
- **Pendência nunca vive num `BACKLOG.md`** ou num plano: um documento pode agrupar pendências, mas cada item aberto aponta para a sua issue.
- **A conferência de assinatura aceita PGP**, que é como o GitHub assina os merges e squashes que faz.
- **O template xrepo passa a ser `xrepo-request.md`** e é do projeto depois de criado, porque cada repositório diz quem lhe manda pedidos.

#### Corrigido
- **O tipo `style` passa a ser aceito** nos commits, para formatação sem mudança de comportamento, como no Conventional Commits. A checagem recusava um `style(import): …` real de um projeto que usa o padrão.
- **`labels.sh` não tira mais label de issue.** Com `--prune` ele apagava `bug`, `enhancement` e `documentation`, que num projeto real classificavam 60 issues. Agora migra cada nome antigo para o do padrão (`bug` → `type:bug`, `enhancement` → `type:feature`, `documentation` → `type:docs`, `question` → `type:question`, `needs-decision` → `status:needs-decision`, `type:api-contract` → `type:contract`), renomeando ou passando cada issue e PR para a label nova antes de apagar a velha, e o `--prune` só remove padrões do GitHub sem uso. `--dry-run` mostra o plano.
- **`rulesets.sh` num repositório privado sem GitHub Pro.** A listagem dos rulesets responde 403 com uma mensagem de erro, e o script tomava essa mensagem como o id de um ruleset e tentava um `PUT` numa URL inválida. Agora ele confere antes se os rulesets estão disponíveis e, se não estiverem, diz que exigem GitHub Pro e para.
- **O escopo `changelog` passa a ser aceito** no `.standards.json` padrão e neste repositório. A ordem spec → implementação → changelog produz um commit só de CHANGELOG, e a checagem de PR o recusava.

### 🇺🇸 English

#### Added
- **`/xrepo` skill** for requests between sibling repositories: the inbox, opening a request in the other repo, handling one that arrived and verifying what the other side resolved, with the `gh` commands and a stop before writing to the other repository. These commands lived only in the original project's `CLAUDE.md`.
- **`check.sh docs`:** CI rejects private network addresses (RFC 1918) in Markdown. Documentation addresses (RFC 5737) pass.
- **`verifyRunsIn: "local"`** in `.standards.json`, for projects whose `verify` only runs on a specific machine (Xcode on a Mac): CI skips the step and the result goes in the PR's Verification section. And `docs.auditDir`, for the audit records folder.
- **`install.sh --replace-hooks`**, which removes the project's earlier guard hooks before adding the standard ones; without it the installer lists the hooks that will run alongside.

#### Changed
- **Commit rules measured against the real history of the projects that use the standard.** The subject aims at 72 characters and is only rejected above 100 (above 72, CI warns). A scope is required in `feat`, `fix`, `perf` and `refactor` and optional in the others. The `release: vX.Y.Z` and `hotfix: vX.Y.Z` subjects, which reach `develop` through the merge back, pass too, as do `claude/…` and `dependabot/…` branches. Under the 0.1.0 rules about half the commits of both repositories would be rejected.
- **Pending work never lives in a `BACKLOG.md`** or a plan: a document may group pending work, but each open item points to its issue.
- **The signature check accepts PGP**, which is how GitHub signs the merges and squashes it makes.
- **The xrepo template becomes `xrepo-request.md`** and belongs to the project once created, because each repository says who sends it requests.

#### Fixed
- **The `style` type is now accepted** in commits, for formatting with no behavior change, as in Conventional Commits. The check rejected a real `style(import): …` from a project that uses the standard.
- **`labels.sh` no longer takes labels off issues.** With `--prune` it deleted `bug`, `enhancement` and `documentation`, which classified 60 issues in a real project. It now migrates each old name to the standard one (`bug` → `type:bug`, `enhancement` → `type:feature`, `documentation` → `type:docs`, `question` → `type:question`, `needs-decision` → `status:needs-decision`, `type:api-contract` → `type:contract`), renaming it or moving each issue and PR to the new label before deleting the old one, and `--prune` only removes unused GitHub defaults. `--dry-run` shows the plan.
- **`rulesets.sh` on a private repository without GitHub Pro.** Listing rulesets answers 403 with an error message, and the script took that message for a ruleset id and tried a `PUT` on an invalid URL. It now checks first whether rulesets are available and, if not, says they need GitHub Pro and stops.
- **The `changelog` scope is now accepted** in the default `.standards.json` and in this repository. The spec → implementation → changelog order produces a CHANGELOG-only commit, and the PR check rejected it.

## [0.1.0] - 2026-11-22

### 🇧🇷 Português

#### Adicionado
- **O processo, num lugar só.** `CONTRIBUTING.md` (EN) e `CONTRIBUTING.pt-BR.md` (PT), com as mesmas seções: princípios, onde vive cada regra, gitflow com `main` e `develop`, nomes de branch, PRs empilhados, Conventional Commits com escopo e a seção do CHANGELOG de cada tipo, PRs, merge, release, **hotfix** (que não existia nas regras de origem), SemVer, CHANGELOG bilíngue, issues e labels, coordenação entre repositórios, documentação, ADR, auditorias, dados sensíveis e idiomas.
- **Regras de agente** no `CLAUDE.md`: início de sessão, paradas obrigatórias, conversas em paralelo em worktrees e commits feitos com o mantenedor ausente.
- **Configuração por projeto** em `.standards.json`: escopos, `verify`, arquivos de versão, gates de release, produção, repositórios irmãos e dados sensíveis.
- **Travas do agente** (`.claude/hooks/`): bloqueiam push na `main`, force-push na `develop` e merge de PR com base `main` que não seja de release ou de hotfix; pedem confirmação antes de tag, GitHub Release, produção, remoções, drop no banco e escrita em outro repositório. Funcionam no Linux e no macOS. Testes em `.standards/test-guard-bash.sh`.
- **Skills `/release` e `/hotfix`**, com as paradas de cada passo.
- **Checagem de PR** (`standards.yml`): formato e base da branch, título, assunto de cada commit e paridade das seções EN/PT. A mesma lógica roda local em `.standards/check.sh`.
- **Taxonomia única de labels** com prefixos (`type:*`, `priority:*`, `status:*`), criada por `.standards/labels.sh`; **rulesets** de `main` e `develop` e `develop` como branch padrão, por `.standards/rulesets.sh`.
- **Formulários de issue** (bug, funcionalidade, tarefa, pedido entre repositórios), issue em branco desligada, template de PR e de ADR.
- **Instalador** `.standards/install.sh`: finaliza um repositório criado do template (`--here`), adota o padrão num projeto existente ou o atualiza (`--into`), trocando só os blocos gerenciados nos Markdown.

### 🇺🇸 English

#### Added
- **The process, in one place.** `CONTRIBUTING.md` (EN) and `CONTRIBUTING.pt-BR.md` (PT), with the same sections: principles, where each rule lives, gitflow with `main` and `develop`, branch names, stacked PRs, Conventional Commits with scopes and each type's CHANGELOG section, PRs, merge, release, **hotfix** (missing from the original rules), SemVer, a bilingual CHANGELOG, issues and labels, cross-repository coordination, documentation, ADRs, audits, sensitive data and languages.
- **Agent rules** in `CLAUDE.md`: session start, mandatory stops, parallel conversations in worktrees and commits made while the maintainer is away.
- **Per-project configuration** in `.standards.json`: scopes, `verify`, version files, release gates, production, sibling repositories and sensitive data.
- **Agent guards** (`.claude/hooks/`): block pushes to `main`, force-pushes to `develop` and merging a `main`-based PR that is neither a release nor a hotfix; ask before tags, GitHub Releases, production, deletions, database drops and writes to another repository. They work on Linux and macOS. Tests in `.standards/test-guard-bash.sh`.
- **`/release` and `/hotfix` skills**, with the stops at each step.
- **PR checks** (`standards.yml`): branch format and base, title, every commit subject and EN/PT section parity. The same logic runs locally in `.standards/check.sh`.
- **A single label taxonomy** with prefixes (`type:*`, `priority:*`, `status:*`), created by `.standards/labels.sh`; **rulesets** for `main` and `develop`, and `develop` as the default branch, through `.standards/rulesets.sh`.
- **Issue forms** (bug, feature, task, cross-repo request), blank issues disabled, PR and ADR templates.
- **Installer** `.standards/install.sh`: finalizes a repository created from the template (`--here`), adopts the standard in an existing project or updates it (`--into`), replacing only the managed blocks in Markdown files.
