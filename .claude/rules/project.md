# anvil

Toolkit de skills para Claude Code. Ele **não escreve as próprias skills de
trabalho**: curadoriza skills de repositórios upstream, mantidos como submodules
em `references/`, e as vendoriza com a adaptação registrada no manifesto
`anvil-skills.yaml`.

O que o toolkit impõe a um projeto é só **onde** o arquivo é salvo dentro de
`docs/`. Bateu dúvida, o padrão é o da skill original.

## Fonte e derivado

Este repositório é a fonte do toolkit, e é construído pelo próprio toolkit.
Confundir as duas coisas é o erro caro daqui.

| Caminho | O que é |
|---|---|
| `anvil/` | **o payload — a fonte.** É o que o `npx degit` copia para um projeto |
| `.claude/skills/anvil-*` | **symlinks** para `anvil/.claude/skills/*`. Editar a skill instalada **é** editar o payload |
| `.claude/skills/anvil-sync/` | a ferramenta de manutenção. É do repositório e **não vai no degit** |
| `anvil-skills.yaml` | o manifesto de curadoria. Também não vai no degit |
| `references/` — upstream vendorizado | submodule com pin, listado em `sources:` no manifesto. De onde vêm as skills vendorizadas. **O pin é a base do merge 3-way** |
| `references/` — sistema de referência | sistema de terceiro estudado para portar algo, fora do manifesto. Entra passageiro, fora do git por `.git/info/exclude`, ou versionado como submodule, com pin. **Não é base de merge**: o `mosk` está aqui |
| `docs/` | a documentação do próprio anvil |
| `workspace/` | projetos descartáveis para exercitar o toolkit. Fora do git |

Os symlinks se reconstroem com:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh
```

Só o roster de fluxo é ligado, não o payload inteiro — `--all` liga tudo,
`--unlink` desfaz. Uma skill ligada agora **só aparece na próxima sessão**, e
editá-la não muda a cópia que já está carregada nesta.

## Nunca rode `/anvil-update` aqui

Ele baixa o payload publicado do GitHub e instala por cima. Num projeto é o
caminho certo; aqui, escreveria a versão publicada por cima da fonte em
desenvolvimento. Ele não está entre as skills ligadas — não estar instalado é a
trava.

## Mudança em skill vendorizada

A cópia no payload não é arquivo livre: tem pin e registro de adaptação. O
catálogo é **fechado** — `rename`, `invocable`, `docs-remap`, `decursor`,
`keep`, `strip`, `extra`. Mudança que não cabe em nenhuma dessas não deveria estar sendo feita.

Nunca são adaptação: traduzir, enxugar, uniformizar vocabulário entre skills,
corrigir erro do upstream.

O julgamento está em `.claude/skills/anvil-sync/SKILL.md`, o catálogo em
`ADAPT-RULES.md` ao lado dele, e o registro em `anvil-skills.yaml`. Não duplique
nada disso aqui — são a fonte, isto é o ponteiro.

Skill autoral — `anvil-boot`, `anvil-update`, `anvil-docs`, `anvil-ui`,
`anvil-bench` e as `tea-*` — não tem upstream, e se edita direto no payload.

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

A guarda de merge vale para o branch de spec: bloqueia com ticket sem
`Status: resolved` ou com a spec fora de `docs/specs/archive/`. Ela olha o branch
**atual** na hora do comando, então o merge se dispara do branch da spec, num
comando só:

```bash
git switch main && git merge {tipo}/{NNN}-{nome}
```

Rodado já na `main`, o merge passa sem que a guarda olhe a spec. E ela é um hook
do Claude Code: só vê comando do agente, não o que se digita no terminal.
