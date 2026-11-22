# dev-standards

> 🇺🇸 [English version](README.md)

Um repositório-modelo que dá a um projeto um processo de desenvolvimento escrito e a
automação que o garante, para que pessoas e agentes de IA trabalhem pelas mesmas regras.

Ele cobre:

- **Branches e versões.** A `main` guarda o que foi lançado e a `develop` reúne o trabalho em
  andamento. Toda mudança chega por uma branch curta e um pull request, e lançar uma versão
  ou publicar uma correção urgente segue um roteiro passo a passo.
- **Um histórico legível.** As mensagens de commit seguem o Conventional Commits com escopo,
  os pull requests têm formato de título e de descrição, e o CHANGELOG é mantido em inglês
  e em português.
- **Issues.** Formulários para bug, funcionalidade e tarefa, um conjunto pequeno de labels e
  um formato para pedir mudança a outro repositório.
- **Garantia.** Rulesets do GitHub protegem a `main` e a `develop`, e uma checagem em todo
  pull request valida nome de branch, título e mensagens de commit. A mesma checagem roda
  na máquina.
- **Travas para agentes.** Hooks do Claude Code bloqueiam comandos arriscados, como push na
  `main`, e pedem confirmação antes de outros, como criar tag, apagar arquivos ou mexer em
  produção. Skills conduzem o agente por um release e por um hotfix.

Você adota com **Use this template** num repositório novo, ou com o instalador num que já
existe, e atualiza depois sem sobrescrever o que é próprio do seu projeto.

## O que tem aqui

| Peça | Onde | Garantia |
|---|---|---|
| O processo: branches, commits, PRs, merge, release, hotfix, issues, dados sensíveis, idiomas | [CONTRIBUTING.pt-BR.md](CONTRIBUTING.pt-BR.md) · [en](CONTRIBUTING.md) | Doc |
| O que é de agente: início de sessão, paradas obrigatórias, conversas em paralelo | [CLAUDE.md](CLAUDE.md) | Doc |
| Configuração por projeto | [.standards.json](.standards.json) | Auto |
| Mapa visual de todas as regras, com diagramas Mermaid | [docs/REGRAS.md](docs/REGRAS.md) | — |
| Roteiros de release, hotfix e pedidos entre repos | [.claude/skills/](.claude/skills/) | Skill |
| Travas do agente: bloqueia push na `main`, pede confirmação antes de tag, produção, remoções | [.claude/hooks/](.claude/hooks/) | Confirma · Bloqueado |
| Checagem de PR: branch, título, commits, paridade EN/PT, IP privado em Markdown | [.github/workflows/standards.yml](.github/workflows/standards.yml) | Auto |
| Formulários de issue, template de PR, labels, rulesets das branches | [.github/](.github/), [.standards/](.standards/) | Auto |

## Como usar

### Projeto novo

1. No GitHub, **Use this template** → repositório novo.
2. Clone e rode:

   ```bash
   .standards/install.sh --here --name "Meu Projeto"
   git switch -c develop && git push -u origin develop
   .standards/issue-types.sh setup  # uma vez por conta ou organização
   .standards/labels.sh --prune
   .standards/rulesets.sh          # em repositório privado, exige GitHub Pro
   ```

3. Preencha o `.standards.json` (escopos, `verify`, release, produção) e as seções do
   projeto no `CLAUDE.md` e nos `CONTRIBUTING*.md`.
4. Primeiro commit: `chore(standards): adopt dev-standards X.Y.Z`, por PR para a `develop`.

### Projeto que já existe

De um checkout do dev-standards, numa branch do projeto:

```bash
/caminho/do/dev-standards/.standards/install.sh --into /caminho/do/projeto --name "Projeto"
```

Ele copia o que é do padrão, mescla o `CLAUDE.md` (o conteúdo antigo vira a seção do
projeto) e o `.claude/settings.json` (entram os hooks do padrão, o resto fica), e cria o
`.standards.json`, o `CHANGELOG.md` e os workflows só se não existirem. Nada é commitado.

### Atualizar um projeto

Rode o mesmo `--into` a partir de uma tag mais nova do dev-standards. Os arquivos do padrão
são substituídos; no Markdown, só os blocos gerenciados mudam:

```markdown
<!-- standards:begin core v0.1.0 -->
…o texto do padrão: não edite aqui…
<!-- standards:end -->

## Específico deste projeto
…o seu, nunca alterado…
```

Abra o resultado como `chore(standards): sync to vX.Y.Z`.

## Versionamento

O padrão segue o SemVer e o próprio processo: tags `vX.Y.Z`, [CHANGELOG](CHANGELOG.md)
bilíngue, `develop` e `main`. Cada projeto registra a versão que segue em
`standardsVersion`.

## Próximas fases

- **Fase 1 (esta versão):** template, instalador, travas, skills, checagem de PR, labels e
  rulesets.
- **Fase 2:** um `sync` que abre o PR de atualização sozinho e uma checagem no CI que acusa
  edição dentro dos blocos gerenciados.
- **Fase 3:** skills e hooks distribuídos como plugin do Claude Code, se manter cópias em
  muitos repositórios começar a pesar.
