# ADR-0001 — Recursos nativos do GitHub primeiro; script só onde o GitHub não chega

- **Status:** aceita
- **Data:** 2026-11-22
- **Issue / PR:** (preenchido no PR)

## Contexto

A versão 0.2.0 do padrão nasceu das regras de um projeto pessoal e resolveu quase tudo com arquivos e
scripts próprios: labels `type:*`, `status:blocked`, workflow copiado em cada repo, regra
"nunca `Fixes #N`", worktree criado à mão, skills copiadas pelo `install.sh`.

Em 2026-11-22 a documentação do GitHub (repo `github/docs`, commit `d7487f5`) foi lida por
seção, junto com o manual completo do `gh` 2.105.0. Boa parte do que fazíamos à mão já
existe como recurso nativo, e alguns recursos novos ajudam a acompanhar os projetos. O
resumo do que foi lido, com o que vale e o que não vale para conta pessoal, está em
[docs/referencias/github-nativo.md](../referencias/github-nativo.md).

Restrições que moldam a decisão:

- Os repos são de **conta pessoal**, não de organização. Workflow templates, rulesets e
  webhooks no nível da conta, merge queue e custom properties são exclusivos de organização.
- A conta passa a ter os recursos do **GitHub Pro** (Student Developer Pack) a partir de
  2026-11-25. Até lá, repo privado não tem ruleset nem branch protegida.
- Validação de mensagem de commit e de nome de branch por ruleset é exclusiva do
  **Enterprise**. Detecção de segredos e análise de código em repo privado exigem
  **organização** com Team ou Enterprise.
- Quem trabalha nos repos são agentes, pelo `gh` e pelo `git` local. Recurso que só existe
  na tela não serve para eles.

## Decisão

Usamos o recurso nativo do GitHub sempre que ele existir para a conta pessoal e puder ser
operado pelo `gh` (comando próprio ou `gh api`). Escrevemos script só onde o GitHub não
chega, e cada script restante diz por que existe.

### Conta (configurada uma vez, vale para todos os repos)

| Recurso | Uso no padrão |
|---|---|
| Tipos de issue | `Bug`, `Feature`, `Task`, `Docs`, `Question`. Substituem as labels `type:*` |
| Campos de issue | `Priority` (`Urgent`, `High`, `Medium`, `Low`). Substitui as labels `priority:*`; gravado por `gh api` |
| Code security da conta | grafo de dependências, alertas e atualizações de segurança do Dependabot em todos os repos e nos novos |
| E-mail privado | "Keep my email addresses private" e "Block command line pushes that expose my email" |
| Vigilant mode | ligado; o `install.sh` confere `commit.gpgsign` e `tag.gpgsign` |
| Notificação de Actions | só em falha |

### Repo (aplicado por script via API, com `X-GitHub-Api-Version` fixado)

| Recurso | Uso no padrão |
|---|---|
| Merge | squash e merge commit com o título do PR; rebase-merge desligado, porque o GitHub reescreve o commit sem assinatura; apagar a branch após o merge |
| Rulesets (a partir de 2026-11-25) | `main` só por PR, com CI e assinatura; `develop` por PR, com CI e assinatura; sem force-push nem remoção; tags `v*` travadas; **sem bypass** |
| Releases imutáveis | tag não move nem é reusada; release criada como rascunho e publicada depois |
| Push policy (preview) | limite de branches e tags por push; bloqueia `git push --mirror` |
| Labels | limpar as 10 padrão; ficam só `status:*`, `needs-verification`, `xrepo`, `from:<repo>`, `parity`, `contract` |
| `.gitattributes` | `linguist-generated` em arquivo gerado |
| Topics | `dev-standards` e `std-X-Y-Z`, para `gh repo list --topic` responder quem segue o padrão e em que versão |
| Milestones | um por versão `vX.Y.Z`; substitui o "Sai em" do comentário de resolução |

### Issues e fluxo

| Recurso | Uso no padrão |
|---|---|
| Dependências | `--blocked-by`; substitui `status:blocked` (inclusive entre repos, se o teste confirmar) |
| Sub-issues | épicos, inclusive com filhas em outro repo |
| Branch ligada à issue | `gh issue develop N --base develop --name <tipo>/N-slug --worktree <dir>` |
| Palavras de fechamento | `Fixes #N` em issue local (fecha no merge para `develop`, que é a branch padrão); `Refs` só em pedido xrepo, que tem comentário de resolução e verificação |
| Duplicata e transferência | `gh issue close --duplicate-of`, `gh issue transfer` |
| Artifacts da issue (preview) | o plano de implementação de uma issue mora nela; ADR e contrato continuam em `docs/` |
| Início de sessão | `gh search issues --owner <dono>` em vez de uma consulta por repo |

### PR, release e CI

| Recurso | Uso no padrão |
|---|---|
| Stacked PRs | substituem a regra de PRs empilhados, com tronco `develop` (se o teste em repo privado passar) |
| Merge travado | `gh pr merge --match-head-commit <sha>` |
| Release | `gh release create --verify-tag --notes-from-tag`; as notas bilíngues vêm da tag anotada e assinada |
| CI do padrão | composite action do dev-standards fixada por tag, no lugar do workflow copiado |
| Lockfile de Actions | `gh actions-lock` gera `.github/workflows/actions.lock` |
| Dependabot | commits `chore(deps): …`, PRs para `develop` |
| Templates de issue | `type:` no formulário; ficam no repo público `.github` e valem para todos os repos |
| Skills | `gh skill install … --pin vX.Y.Z`, a partir do dev-standards público |
| Markdown | alerts (`> [!CAUTION]`) marcam as paradas obrigatórias |

### Acompanhamento (novo)

| Recurso | Uso no padrão |
|---|---|
| Projects | um por produto. Produto com dois repositórios (web e app) tem um Project só, com entrada automática dos pedidos xrepo e coluna "Aguardando verificação" |
| Milestones | progresso por versão |
| Topics | inventário do padrão |

### Repositórios do padrão

`dev-standards` e `.github` passam a ser **públicos**: não guardam nada sensível, ganham
detecção de segredos e análise de código, e o `.github` só funciona como fonte de templates
se for público. Projeto novo nasce do template mínimo `project-template` e recebe o padrão
pelo `install.sh`.

### O que continua nosso, e por quê

| Peça | Motivo |
|---|---|
| `check.sh` (commit, branch, título do PR) | validação de metadados por ruleset é só Enterprise |
| Checagem de IP em docs | detecção de segredos em repo privado exige organização |
| Hooks de tag, produção, `rm`, banco e escrita em outro repo | o GitHub não vê ações locais |
| CHANGELOG bilíngue | notas automáticas agrupam só por label de PR e não separam idiomas |
| Labels `status:*` e `needs-verification` | não há equivalente fora do preview de issue statuses |
| `install.sh` e blocos gerenciados de `CLAUDE.md` e `CONTRIBUTING` | não são do GitHub |

## Alternativas consideradas

- **Manter tudo em script (0.2.0).** Descartada: duplica o que o GitHub faz, não aparece nas
  telas nativas (filtro de tipo, ícone de bloqueio, Projects) e exige manutenção nossa.
- **Prioridade como label.** Descartada: o campo nativo tem busca própria
  (`field.priority:high`) e aparece nos Projects. Custo aceito: o `gh` não tem opção para
  campo, então o padrão leva um script pequeno sobre `gh api`.
- **Reusable workflow para o CI.** Descartada: o checkout dentro dele baixa o repo de quem
  chama, e os scripts do dev-standards não ficam disponíveis. Composite action leva os
  próprios arquivos.
- **dev-standards como template repository.** Descartada: o repo novo herdaria o CHANGELOG e
  o histórico do próprio padrão. Template mínimo separado.
- **Organização em vez de conta pessoal.** Adiada: daria workflow templates e labels padrão,
  mas no plano gratuito os repos privados continuam limitados.
- **GitHub App como identidade dos agentes.** Adiada: o app assina o que faz pela API, mas
  não o commit feito pelo `git` local.
- **Agentic Workflows (`gh aw`).** No backlog: custo de API e segredo no repo; reavaliar com
  o padrão estável.
- **Issue statuses.** Adiado: preview restrito a contas inscritas.

## Consequências

- O padrão fica menor e mais visível: tipo, prioridade, bloqueio e progresso aparecem nas
  telas e filtros do GitHub, para pessoa e agente.
- Configurar uma conta nova exige o escopo `user` no `gh` (`gh auth refresh -s user`), por
  causa dos tipos e campos de issue.
- Até 2026-11-25 os repos privados seguem sem ruleset; os hooks continuam sendo a única trava.
  Depois, as travas de `main` e `develop` passam ao GitHub e saem do `guard-bash`.
- Sem bypass no ruleset, nem o dono passa por cima. A exceção é desligar a regra de forma
  consciente.
- Recurso em preview (push policy, artifacts, stacked PRs) pode mudar; o padrão registra a
  versão em que foi testado.
- Nome de topic é sempre público, mesmo em repo privado. Topic nunca revela conteúdo.
- Pendente de teste antes de entrar: stacked PRs em repo privado, push policy, dependência
  entre repos e escrita de campo de issue via `gh api`. Composite action e `gh skill` vêm do
  dev-standards público, então não dependem de acesso a repo privado.
