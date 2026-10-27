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
| `~/.claude/skills/<skill>` | instalação publicada de usuário, independente da fonte em edição |
| `~/.claude/agents/<agente>.md` | agentes da instalação publicada de usuário |
| `~/.agents/skills/<skill>` | espelho da instalação publicada, lido pelo Codex e pelo omp |
| `~/.omp/agent/` | camada omp da instalação publicada, mais os arquivos do usuário |
| `.claude/skills/anvil-sync/` | a ferramenta de manutenção. É do repositório e **não vai no degit** |
| `.claude/settings.json` | o hook da guarda de merge deste repositório, que chama a guarda direto do payload, `anvil/.claude/skills/anvil-docs/scripts/guard-spec-merge.sh` |
| `anvil-skills.yaml` | o manifesto de curadoria. Também não vai no degit |
| `references/` — upstream vendorizado | submodule com pin, listado em `sources:` no manifesto. De onde vem o que é vendorizado: skills e, no caso do `unlazy`, material de terceiro dentro do `anvil-bench`. **O pin é a base do merge 3-way** |
| `references/` — sistema de referência | sistema de terceiro estudado para portar algo, fora do manifesto. Entra passageiro, fora do git por `.git/info/exclude`, ou versionado como submodule, com pin. **Não é base de merge**: o `mosk` — o toolkit de agentes-persona que o anvil sucede — está aqui |
| `docs/` | a documentação do próprio anvil |
| `workspace/` | projetos descartáveis para exercitar o toolkit. Fora do git |

O desenvolvimento usa um HOME privado por checkout, em
`workspace/anvil-dev/home/`. Prepare os links ou abra uma sessão explicitamente:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh --dry-run
bash .claude/skills/anvil-sync/scripts/dev-run.sh -- omp
# Ou: dev-run.sh -- claude / dev-run.sh -- codex
```

O launcher prepara o payload inteiro, mantém o `PATH` e muda `HOME` e os
diretórios de configuração dos três harnesses só para o processo e seus filhos.
Assim, skills, agentes, camada omp e comandos `~/.claude/skills/...` usam a fonte
deste checkout. A execução direta do `dev-link.sh` prepara o roster; `--all`
prepara o payload inteiro. Nenhuma dessas operações liga a fonte no HOME real.

Configuração, sessões e login dev são próprios. O launcher não copia nem liga
credenciais ou configurações pessoais; credenciais já no ambiente são herdadas,
sem serem impressas ou gravadas por ele. Ferramentas que procuram configuração no
HOME, como git e Docker, também precisam de configuração dev ou de variáveis
explícitas. Não é sandbox: caminhos absolutos e serviços do SO continuam acessíveis.
Não use login Console do Claude sem API key como fluxo isolado: ele pode alterar
a conta pessoal no serviço de credenciais do SO.

Skills de terceiros no HOME real ficam intactas e não são importadas para dev.
Entradas próprias no HOME dev são preservadas; colisão com destino gerenciado ou
ancestral symlink é recusada antes da escrita. Reabra a sessão para carregar uma
skill ou agente novo. Não rode `/anvil-update` dentro do launcher: a recusa do
reset protege os links para a fonte.

### Migrar a ligação dev antiga

Uma máquina que usava os links globais precisa retirá-los explicitamente, fora
do launcher, e instalar a versão publicada no usuário:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh --unlink --dry-run
bash .claude/skills/anvil-sync/scripts/dev-link.sh --unlink
TMP="$(mktemp -d)" && npx degit rogerznts/anvil/anvil "$TMP"
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --dry-run --from "$TMP"
# Revise o dry-run e aprove antes de executar:
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP"
```

O `--unlink` remove só os links antigos deste checkout no usuário e os links
históricos de projeto reconhecidos. Não apaga diretórios reais ou links de
terceiros e não instala a versão publicada. Daí em diante, `/anvil-update` fora
do launcher atualiza os projetos sem tocar na fonte dev.

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
