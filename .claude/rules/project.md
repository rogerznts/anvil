# anvil

Toolkit de skills para Claude Code. Ele **não escreve as próprias skills de
trabalho**: curadoriza skills de repositórios upstream e as vendoriza com a
adaptação registrada no manifesto `anvil-skills.yaml`. Os upstreams são
submodules em `references/`, mas nem tudo em `references/` é upstream: a tabela
abaixo separa os dois.

O que o toolkit impõe a um projeto é só **onde** o arquivo é salvo dentro de
`docs/`. Bateu dúvida, o padrão é o da skill original.

## Fonte e derivado

Este repositório é a fonte do toolkit, e é construído pelo próprio toolkit.
Confundir as duas coisas é o erro caro daqui.

| Caminho | O que é |
|---|---|
| `anvil/` | **o payload — a fonte.** É o que o `npx degit` copia para um projeto |
| `.claude/skills/anvil-*` | **symlinks** para `anvil/.claude/skills/*`. Editar a skill instalada **é** editar o payload |
| `.claude/agents/*.md` | **symlinks** para `anvil/.claude/agents/*.md`, do mesmo jeito |
| `.agents/skills/*` | o espelho do Codex: **symlinks** para `.claude/skills/*`, um por skill ligada. Fora do git |
| `.claude/skills/anvil-sync/` | a ferramenta de manutenção. É do repositório e **não vai no degit** |
| `anvil-skills.yaml` | o manifesto de curadoria. Também não vai no degit |
| `references/` — upstream vendorizado | submodule com pin, listado em `sources:` no manifesto. De onde vem o que é vendorizado: skills e, no caso do `unlazy`, material de terceiro dentro do `anvil-bench`. **O pin é a base do merge 3-way** |
| `references/` — sistema de referência | sistema de terceiro estudado para portar algo, fora do manifesto. Entra passageiro, fora do git por `.git/info/exclude`, ou versionado como submodule, com pin. **Não é base de merge**: o `mosk` — o toolkit de agentes-persona que o anvil sucede — está aqui |
| `docs/` | a documentação do próprio anvil |
| `workspace/` | projetos descartáveis para exercitar o toolkit. Fora do git |

Os symlinks se reconstroem com:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh
```

Das skills, só o roster de fluxo é ligado, não o payload inteiro — `--all` liga
tudo, `--unlink` desfaz. Os agentes do payload são ligados todos. Uma skill ou um
agente ligado agora **só aparece na próxima sessão**, e editá-lo não muda a cópia
que já está carregada nesta.

## Nunca rode `/anvil-update` aqui

Ele baixa o payload publicado do GitHub e instala por cima. Num projeto é o
caminho certo; aqui, escreveria a versão publicada por cima da fonte em
desenvolvimento. Ele não está entre as skills ligadas — não estar instalado é a
trava.

## Mudança em skill vendorizada

A cópia no payload não é arquivo livre: tem pin e registro de adaptação. O
catálogo é **fechado** — `rename`, `invocable`, `docs-remap`, `decursor`,
`tracker-profile`, `keep`, `strip`, `extra`. Mudança que não cabe em nenhuma dessas não deveria estar sendo feita.

Nunca são adaptação: traduzir, enxugar, uniformizar vocabulário entre skills,
corrigir erro do upstream.

O julgamento está em `.claude/skills/anvil-sync/SKILL.md`, o catálogo em
`ADAPT-RULES.md` ao lado dele, e o registro em `anvil-skills.yaml`. Não duplique
nada disso aqui — são a fonte, isto é o ponteiro.

Skill autoral — `anvil-boot`, `anvil-update`, `anvil-docs`, `anvil-ui`,
`anvil-distill`, `anvil-bench` e as `tea-*` — não tem upstream, e se
edita direto no payload. A ressalva é o
`anvil-bench`: o que está em `anvil-bench/unlazy/` é material do
`unlazy`, que vem de upstream com pin e registro no manifesto, e segue a regra de
skill vendorizada.

## Como se verifica

Não há suíte: o repositório não é um pacote de código, e não existe
`package.json`. O que faz as vezes, e roda antes de commitar:

```bash
bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
```

Os cenários de infraestrutura — degit, corrida do `new-spec.sh`,
`reset-install.sh`, guarda de merge, boot, adopt, scaffold, lock — são manuais e
vivem em `workspace/01-…08-`, fora do git de propósito.

## Fluxo git

Trabalho com spec vai num branch `{tipo}/{NNN}-{nome}`. Fecha com
`/anvil-docs archive` no próprio branch e `git merge` local na `main`, sem PR.
Trabalho sem spec vai direto na `main`.

O fechamento segue o perfil do tracker, `docs/agents/issue-tracker.md`, menos o
passo `/tea-open-pr`: aqui não há PR, e a spec fecha com o merge local. O que a
guarda de merge exige para liberar está no mesmo perfil. Ela confere o `git
merge` disparado da `main` ou do branch da spec, e é um hook do Claude Code: só vê
comando do agente, não o que se digita no terminal.
