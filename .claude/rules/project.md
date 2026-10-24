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
| `anvil/` | **o payload — a fonte.** É o que o `/anvil-update` instala no diretório de usuário de uma máquina comum |
| `~/.claude/skills/<skill>` | **symlinks** para `anvil/.claude/skills/<skill>`, um por skill ligada. Editar a skill instalada **é** editar o payload. Fora do repositório |
| `~/.claude/agents/<agente>.md` | **symlinks** para `anvil/.claude/agents/<agente>.md`, do mesmo jeito |
| `~/.agents/skills/<skill>` | o espelho do Codex, que o omp também lê: **symlinks** direto para `anvil/.claude/skills/<skill>`, um por skill ligada |
| `~/.omp/agent/` | a camada omp: **symlinks** para `anvil/.claude/skills/anvil-update/.omp-layer/`, um por arquivo, em `skills/`, `rules/`, `agents/` e `hooks/pre/`. O resto de `~/.omp/agent` é do omp |
| `.claude/skills/anvil-sync/` | a ferramenta de manutenção. É do repositório e **não vai no degit** |
| `.claude/settings.json` | o hook da guarda de merge deste repositório, que chama a guarda direto do payload, `anvil/.claude/skills/anvil-docs/scripts/guard-spec-merge.sh` |
| `anvil-skills.yaml` | o manifesto de curadoria. Também não vai no degit |
| `references/` — upstream vendorizado | submodule com pin, listado em `sources:` no manifesto. De onde vem o que é vendorizado: skills e, no caso do `unlazy`, material de terceiro dentro do `anvil-bench`. **O pin é a base do merge 3-way** |
| `references/` — sistema de referência | sistema de terceiro estudado para portar algo, fora do manifesto. Entra passageiro, fora do git por `.git/info/exclude`, ou versionado como submodule, com pin. **Não é base de merge**: o `mosk` — o toolkit de agentes-persona que o anvil sucede — está aqui |
| `docs/` | a documentação do próprio anvil |
| `workspace/` | projetos descartáveis para exercitar o toolkit. Fora do git |

Os symlinks se reconstroem com:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh
```

Eles moram no diretório do usuário, não no repositório: **todo projeto da máquina
roda a fonte em edição**, e uma skill editada pela metade chega a todos. Das
skills, só o roster de fluxo é ligado, não o payload inteiro — `--all` liga tudo,
`--dry-run` mostra sem alterar. Os agentes do payload e os arquivos da camada omp
são ligados todos. Symlink com o nome de uma peça do payload que aponta para outro
lugar é refeito; diretório ou arquivo real é pulado, e numa máquina com a
instalação publicada tirá-la para ligar a fonte é à mão.

O `--unlink` tira só os symlinks que apontam para o payload deste repositório, e
deixa a máquina pronta para receber a instalação publicada. Ao ligar e no
`--unlink`, saem também os symlinks que o `dev-link` antigo criava no projeto, em
`.claude/skills`, `.claude/agents`, `.agents/skills` e `.omp/`; a `anvil-sync`
fica.

O `dev-link` não liga o resto da instalação de usuário: o bloco de diretivas do
`~/.claude/CLAUDE.md`, a rule `~/.omp/agent/rules/anvil-directives.md` e o hook da
guarda no `~/.claude/settings.json`. Aqui, as diretivas vêm do `CLAUDE.md` da raiz
e a guarda vem do `.claude/settings.json`; nos outros projetos da máquina, a sessão
roda sem as diretivas e, no Claude Code, sem a guarda.

Uma skill ou um agente ligado agora **só aparece na próxima sessão**, e editá-lo
não muda a cópia que já está carregada nesta.

## Nunca rode `/anvil-update` aqui

Ele baixa o payload publicado do GitHub e o instala no diretório do usuário. Numa
máquina comum é o caminho certo; nesta, a instalação de usuário é feita de
symlinks para a fonte, e instalar por cima escreveria a versão publicada dentro da
fonte em desenvolvimento, através do link. Ele não está entre as skills ligadas —
não estar instalado é a primeira trava. A segunda é a recusa: o `reset-install`
não instala quando alguma skill, agente ou arquivo da camada omp do payload é
symlink no diretório do usuário. A recusa vem antes de qualquer escrita, no
dry-run também, e aponta o `dev-link.sh --unlink`. Para voltar à instalação
publicada, rode o `--unlink` e depois a instalação de máquina nova — o
`/anvil-update` não serve, porque não está instalado aqui:

```bash
TMP="$(mktemp -d)" && npx degit rogerznts/anvil/anvil "$TMP"
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --dry-run --from "$TMP"
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP"
```

São os comandos da seção de instalação que o `anvil-boot/SKILL.md` escreve no
`anvil.md` dos projetos: o segundo mostra o que entra e o que fica; o terceiro
instala.

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
`anvil-distill`, `anvil-bench`, `anvil-commit`, `anvil-open-pr`,
`anvil-open-fast-pr` e `anvil-prune-branches` — não tem upstream, e se
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
passo `/anvil-open-pr`: aqui não há PR, e a spec fecha com o merge local. O que a
guarda de merge exige para liberar está no mesmo perfil. Ela confere o `git
merge` disparado da `main` ou do branch da spec, e é um hook do Claude Code: só vê
comando do agente, não o que se digita no terminal.
