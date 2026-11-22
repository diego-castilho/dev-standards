# Recursos nativos do GitHub: o que vale para conta pessoal

Resumo da leitura da documentação do GitHub feita em 2026-11-22, que fundamenta o
[ADR-0001](../adr/0001-recursos-nativos-do-github-primeiro.md).

- **Fonte:** repo `github/docs`, commit `d7487f5` (2026-11-20), e o manual do `gh` 2.105.0
  (`gh help reference`).
- **Escopo:** Introdução, Conta e perfil, Notificações, Autenticação, Migrações, Política do
  site, Repositórios, Pull requests, Actions, Segurança de código, Issues, Projects, Apps,
  REST, GraphQL e Webhooks. Os artigos que tocam o padrão foram lidos por inteiro; o resto,
  por busca de termos.
- **Ponto de vista:** conta pessoal, repos privados, plano Pro. O que exige organização,
  Team ou Enterprise está marcado.

Recurso em preview pode mudar. Antes de depender de um, confira a documentação atual.

## Planos

- Free em repo privado tem recursos limitados. O Pro libera em privado: branch protegida,
  rulesets, code owners, revisores obrigatórios, autolinks customizados, wiki e insights.
- Nem o Pro libera em privado: detecção de segredos, bloqueio de push com segredo, padrões
  customizados, análise de código, CodeQL e dependency review. Isso exige organização com
  Team ou Enterprise e o pacote Advanced Security. Em repo **público** é grátis.
- Validação de metadados de commit (mensagem, nome de branch, e-mail) por ruleset: só
  Enterprise.
- Merge queue: só organização (repo público) ou Enterprise Cloud (privado). Nunca em conta
  pessoal.
- Workflow obrigatório, rulesets e workflow templates da conta: só organização.
- Artifact attestations em privado: só Enterprise Cloud.

## Conta

- **Code security:** liga grafo de dependências, alertas, atualizações de segurança e
  alertas de malware do Dependabot em todos os repos e como padrão para os novos.
- **E-mail:** "Keep my email addresses private" e "Block command line pushes that expose my
  email" (confere o último commit do push). O e-mail `noreply` nunca é desvinculado.
- **Vigilant mode:** marca como "Unverified" commit ou tag sem assinatura. Só ligar se tudo
  for assinado e o committer usar e-mail verificado.
- **Tipos de issue:** até 25 por conta; padrão Task, Bug e Feature. Desabilitar preserva o
  valor nas issues; apagar remove. API: `/user/issue-types`.
- **Campos de issue:** até 25; single-select, texto, número e data. Padrão: Priority
  (Urgent, High, Medium, Low), Effort, Start date e Target date. Fixados por tipo (até 10 por
  tipo), visibilidade Restricted ou Public, busca `field.priority:high`. Não podem ser
  preenchidos por template nem por URL; não existem em PR; o `gh` não tem opção própria
  (usar `gh api`). API: `/user/issue-fields` e `/repos/…/issues/{n}/issue-field-values`.
- **Nome da branch padrão** para repos novos: configurável.
- **Termos de Serviço:** conta é de pessoa; *machine account* é permitida (uma por pessoa,
  só para automação, com humano responsável). Conteúdo dado como entrada aos recursos de IA
  do GitHub pode ser usado para treino, salvo opt-out.
- **Credenciais:** chave SSH sem uso há um ano é apagada; token pessoal sem uso há um ano é
  revogado; token publicado em repo ou gist público é revogado.

## Assinatura

- Verificação persistente: o registro é gravado no push, e o commit continua "Verified"
  mesmo se a chave for trocada ou revogada depois.
- "Rebase and merge" no GitHub reescreve o commit sem assinatura. Squash e merge commit
  feitos no GitHub saem assinados pela chave do GitHub.
- `git config commit.gpgsign true`, `tag.gpgsign true` e `gpg.format ssh` fazem o Git
  assinar sem `-S`.

## Repositório

- **Merge:** mensagem do squash e do merge commit configurável (título do PR, título e
  descrição, padrão). API: `squash_merge_commit_title/message`, `merge_commit_title/message`.
  A versão 2026-03-10 da API removeu `use_squash_pr_title_as_default`.
- **Squash em branch de vida longa** faz os PRs seguintes repetirem commits e conflitos. O
  passo "`main` de volta para `develop`" após cada release evita isso.
- **Rulesets (Pro em privado):** até 75 por repo; estados Active, Evaluate e Disabled;
  agregam com a regra mais restritiva. Regras: restringir criação, atualização e remoção;
  histórico linear; commits assinados; exigir PR (aprovação pode ser zero); status checks;
  bloquear force-push. Tag ruleset trava `v*`. Administrador passa por cima se houver bypass.
- **Push policy (preview):** limita branches e tags por push (mínimo 2, recomendado 5) e
  bloqueia `git push --mirror`. Plano não informado.
- **Releases imutáveis:** tag não move, não é apagada enquanto a release existir e o nome
  nunca é reusado; anexos travados; título e notas editáveis; gera *release attestation*;
  vale só para releases futuras. Fluxo: rascunho, anexos, publicar. API:
  `/repos/…/immutable-releases`.
- **Notas automáticas** (`.github/release.yml`): agrupam por label de PR; não separam idiomas.
- **Template repository:** o repo novo começa com um commit; só a branch padrão ou todas;
  histórias sem relação.
- **`.gitattributes`** com `linguist-generated` esconde arquivo gerado no diff.
- **Topics:** até 20, minúsculas, números e hífen, até 50 caracteres. O nome do topic é
  sempre público, mesmo em repo privado.
- **Labels padrão:** todo repo novo nasce com 10. Só organização muda esse padrão.
- **Commit signoff (DCO):** vale só para commit feito na web; não é assinatura.

## Pull requests

- **Stacked PRs:** qualquer tronco (`gh stack init --base develop`); regras e CI avaliados
  contra o tronco; o rebase do stack gera commits assinados; exigem histórico linear entre
  as branches; aceitam os três métodos de merge. Extensão: `gh extension install
  github/gh-stack`.
- **Palavras de fechamento** (`close`, `fix`, `resolve` e variações) fecham a issue só quando
  o PR ou o commit entra na branch padrão. Funcionam também na mensagem de commit.
- **Ligação manual** pela barra lateral da issue aceita PR de outro repo; pela do PR, só do
  mesmo repo. Via GraphQL: `addCloseIssueReferences`.
- **Merge indireto:** o PR aparece como merged se os commits chegarem à base por outro
  caminho, mesmo sem cumprir a proteção.
- **Auto-merge** só aparece quando o PR não pode entrar na hora (exige proteção).

## Issues

- **Dependências:** `gh issue create --blocked-by`, `gh issue edit --add-blocked-by`,
  `gh issue view --json blockedBy,blocking`. O GraphQL (`addBlockedBy`) usa ID global, o que
  indica que aceita issue de outro repo; a documentação não confirma.
- **Sub-issues:** até 100 por issue e 8 níveis; podem estar em outro repo. `--parent`,
  `--add-sub-issue`. Substituem as *tasklists*, que foram aposentadas.
- **Artifacts (preview, `gh` 2.103+):** documentos versionados presos à issue (plano,
  documento, link, HTML). `gh issue artifact`.
- **Issue statuses (preview restrito):** Backlog, Todo, In progress, In review, Done, Not
  planned, Duplicate. PR ligado move para In progress; fechar marca Done, Not planned ou
  Duplicate.
- **Duplicata:** comentário "Duplicate of #N" ou `gh issue close --duplicate-of`.
- **Transferência:** entre repos do mesmo dono; mantém comentários e as labels que existirem
  no destino.
- **Milestones:** prazo, percentual concluído, ordenação.

## Projects

- Projeto de usuário reúne issues de vários repos; tabela, kanban e roadmap; até 50 campos;
  iteração; gráficos; status periódico ("On track", "At risk").
- Automações embutidas: fechado vai para Done, PR mergeado vai para Done; configuráveis.
- Entrada automática por filtro (`is`, `label`, `reason`, `assignee`, `no`): Free 1 regra,
  Pro 5.
- Campo de issue aparece no projeto e é a fonte da verdade; preferir a campo de projeto.
- `gh project item-edit` grava campo do projeto.

## Actions

- **Reusable workflow:** o `actions/checkout` dentro dele baixa o repo de quem chama.
  **Composite action** leva os próprios arquivos (`github.action_path`), mas não usa secrets.
- **Compartilhar entre repos privados da conta:** Settings → Actions → Access →
  "Accessible from repositories owned by …".
- **Workflow templates:** só organização.
- **Lockfile:** `gh extension install github/gh-actions-lock`; `gh actions-lock` gera
  `.github/workflows/actions.lock`, com SHA de cada action e das dependências dela. Não cobre
  reusable workflow (referenciar por SHA). Dependabot atualiza.
- **Pular CI:** `[skip ci]` ou o trailer `skip-checks: true` (só `push` e `pull_request`).
- **`GITHUB_TOKEN`:** evento criado por ele não dispara workflow (exceto dispatch).
- **Eventos de issue:** `typed`, `untyped`, `field_added`, `field_removed`, `status_changed`.
- **Runner próprio:** grátis; o custo é a máquina.
- **Agentic Workflows:** `gh extension install github/gh-aw`; workflows em Markdown com
  motor `claude`, `codex`, `gemini` ou `copilot`.

## Dependabot

- `commit-message: {prefix: chore, include: scope}` gera `chore(deps): …`.
- `target-branch` muda o alvo das atualizações de versão; as de segurança vão sempre para a
  branch padrão.
- Também: `labels`, `milestone`, `groups`, `cooldown`, `schedule`,
  `pull-request-branch-name`.

## API

- REST 2026-03-10 tem 1.281 operações. Sem o cabeçalho `X-GitHub-Api-Version`, a resposta
  vem na versão 2022-11-28. Cada versão vale por 24 meses depois da seguinte.
- Boas práticas: requisições em série; 1 s entre escritas em lote; respeitar `retry-after`
  e `x-ratelimit-reset`; usar `etag` (resposta 304 não conta no limite).
- Não existe webhook no nível da conta pessoal.
- **GitHub App:** identidade própria, token curto, permissões finas; o que ele faz pela API
  sai assinado. Não assina commit feito pelo `git` local.

## Comandos do `gh` que o padrão usa

| Comando | Para quê |
|---|---|
| `gh issue create/edit --type` | tipo de issue |
| `gh issue create --blocked-by`, `gh issue edit --add-blocked-by` | dependência |
| `gh issue create --parent`, `gh issue edit --add-sub-issue` | sub-issue |
| `gh issue develop N --base develop --name … --worktree …` | branch ligada e worktree |
| `gh issue close --reason … --duplicate-of …` | fechamento |
| `gh issue transfer` | mover issue |
| `gh issue artifact` | plano da issue |
| `gh label clone` | copiar labels |
| `gh repo edit --add-topic`, `--default-branch`, `--squash-merge-commit-message pr-title` | settings |
| `gh pr merge --match-head-commit` | merge travado no commit conferido |
| `gh release create --verify-tag --notes-from-tag` | release |
| `gh search issues --owner` | caixa de entrada da conta |
| `gh skill install --pin` | skills versionadas |
| `gh stack`, `gh actions-lock` (extensões) | stacked PRs, lockfile |
| `gh api -H 'X-GitHub-Api-Version: 2026-03-10'` | o resto |
