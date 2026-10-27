---
name: anvil-update
description: "Update: reinstala do zero o toolkit anvil na instalação de usuário (reset + degit), apagando órfãos de versões anteriores, migra o projeto instalado do jeito antigo de onde roda, e resume o que mudou. Use ao atualizar ou sincronizar a versão do anvil na máquina."
---

# Update

Reinstala o payload do anvil na instalação de usuário e reporta o que mudou.

## O contrato

**O toolkit é instalado uma vez por usuário**, e um update vale para todos os
projetos da máquina de uma vez. O destino é o diretório do usuário:

| Peça | Onde |
|---|---|
| skills do payload | `~/.claude/skills/` |
| agentes do payload | `~/.claude/agents/` |
| lock de usuário | `~/.claude/anvil.lock`, ao lado das skills |
| espelho | `~/.agents/skills/`, um symlink por skill, lido pelo Codex e pelo omp |
| camada omp | `~/.omp/agent/{skills,rules,agents,hooks/pre}` |
| diretivas | o bloco `ANVIL:DIRECTIVES` do `~/.claude/CLAUDE.md` e, no omp, a rule `~/.omp/agent/rules/anvil-directives.md` |
| guarda de merge | no Claude Code, um hook `PreToolUse`/`Bash` no `~/.claude/settings.json` que chama o `guard-spec-merge.sh` das skills instaladas; no omp, o hook da camada |

O que é de cada projeto — `.claude/rules/`, os perfis em `docs/agents/` e o resto
de `docs/` — não é tocado. O update **nunca commita**. A única escrita em projeto é
a migração do passo 5, que tira de um projeto instalado do jeito antigo a cópia
local do toolkit.

**Isto é um reset, não uma sobrescrita.** As skills e os agentes que o anvil
instalou são apagados e reinstalados. Ficam intactos: **qualquer skill ou agente
que você tenha escrito** em `~/.claude/`, as suas settings fora da entrada da
guarda de merge, o `~/.claude/CLAUDE.md`
fora do bloco do anvil e os seus arquivos em `~/.omp/agent/`. A ressalva é a skill
ou o agente seu, fora do lock, com o mesmo nome de um do payload: é sobrescrito,
depois do destaque de colisão no dry-run e do aviso do passo 3.

O espelho `~/.agents/skills` é refeito a partir do lock: um symlink para
`~/.claude/skills` por skill do payload. Ali, todo symlink com nome de skill do
anvil é do anvil e é refeito, aponte para onde apontar. **Diretório ou arquivo é
seu e fica intocado**, mesmo com nome de skill do anvil.

A **camada omp**, em `~/.omp/agent/`, entra quando há sinal de omp: o binário
`omp` no `PATH`, o diretório `~/.omp/` ou uma linha `omp:` no lock. Qualquer um
basta, e o último torna a camada pegajosa: um update rodado sem os outros dois a
mantém. Ela vem de `anvil-update/.omp-layer/` no payload, uma pasta oculta porque o
Codex acha `SKILL.md` em subpasta de skill e só pula pasta oculta. Nesta versão
ela traz o hook da guarda de merge em `hooks/pre/`, a rule `anvil-harness` em
`rules/`, que traduz o vocabulário do Claude Code nas skills, a rule
`anvil-directives`, gerada do `claude_boot.md`, o agente `anvil-implementer` em
`agents/`, que implementa um ticket e roda o review, e quatro skills em `skills/`:
os condutores `anvil-plan` e `anvil-run`, que encadeiam o fluxo e despacham o
implementer, o piloto automático `anvil-auto`, que leva o roteiro de várias specs
do grill ao fechamento, e o manual `anvil-omp`. Os seus arquivos em `~/.omp/agent/` —
`config.yml`, agentes, rules, skills — ficam intocados. Para tirar a camada, siga
o manual, em `~/.omp/agent/skills/anvil-omp/SKILL.md`.

As **diretivas** saem do mesmo `claude_boot.md` do payload para os dois lugares. No
`~/.claude/CLAUDE.md`, só o que está entre os marcadores `ANVIL:DIRECTIVES` muda;
sem marcador, o bloco entra no topo, e sem o arquivo, ele é criado. Marcador fora
de um único par `START..END` para o reset antes de qualquer escrita. No omp, a
diretiva é a rule `alwaysApply` da camada, porque o omp não lê o `CLAUDE.md` de
usuário; sem camada omp, ela não é escrita.

A **guarda de merge** é instalada uma vez por usuário e roda em todo repositório
da máquina, mas só age em projeto anvil — o que tem `.claude/rules/anvil.md`. No
`~/.claude/settings.json`, o reset acrescenta a `hooks.PreToolUse` uma entrada
`Bash` com o comando `bash "$HOME/.claude/skills/anvil-docs/scripts/guard-spec-merge.sh"`,
e só ela: a entrada é achada por esse comando, rodar de novo não a duplica, e o
resto do arquivo fica. Settings que não é um objeto JSON com `hooks.PreToolUse` em
lista, ou máquina sem `python3`, deixa o arquivo intocado, e o dry-run diz o
comando para registrar à mão. No omp, a guarda é o hook da camada em
`~/.omp/agent/hooks/pre/`.

**Por que reset e não `degit --force`:** o `--force` sobrescreve arquivo a
arquivo e **nunca apaga**. Uma skill que deixou de existir upstream ficaria no
disco para sempre, e os agentes continuariam encontrando e tentando usar.
Atualizar sem reset acumula o entulho de todas as versões anteriores.

**Como os órfãos são calculados:** pelo `~/.claude/anvil.lock`, que lista o que
esta instalação possui, com uma linha `skill:` por skill, uma `agent:` por
agente e uma `omp:` por arquivo da camada omp, com o caminho relativo a
`~/.omp/agent/`. É o que substitui a detecção por prefixo do mosk — um lockfile
diz a verdade, um prefixo adivinha, e adivinha errado justamente nas skills que
não seguem o padrão de nome, como as `tea-*`, que viraram `anvil-*` e só saem
pelo lock.

Sem lock, é a primeira instalação de usuário: nada é do anvil, nada é apagado, e
toda skill ou agente do payload que já estiver em `~/.claude/` sai como colisão.

## Fluxo

Roda de qualquer diretório. Fora de um projeto, só atualiza o usuário. Dentro de
um projeto anvil — o que tem `.claude/rules/anvil.md` —, confere os perfis de
`docs/agents/` contra o template novo. Dentro de um projeto instalado do jeito
antigo, com cópia do toolkit nele, migra esse projeto na mesma execução, no passo
5, com dry-run e aprovação próprios.

### 1. Baixar, sem tocar em nada

```bash
TMP="$(mktemp -d)"
npx degit rogerznts/anvil/anvil "$TMP"
```

### 2. Dry-run — obrigatório

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --dry-run --from "$TMP"
```

**No reset, rode a cópia recém-baixada, nunca a instalada.** O reset apaga o
próprio diretório onde o script vive. Rodar do `$TMP` também garante que a lógica
de reset é a nova, não a da versão velha. O `--unignore`, que só tira do
`.gitignore` de um projeto o bloco de uma instalação antiga, pode rodar da cópia
instalada — é o que o `/anvil-boot` faz.

**Instalação de desenvolvimento.** Se uma skill, um agente ou um arquivo da
camada do payload for symlink em `~/.claude/` ou em `~/.omp/agent/`, o dry-run
recusa antes de escrever: instalar por cima alcançaria a fonte através do link.
Pare e repasse a recusa; não apague symlink nenhum por conta própria.

- **Dentro do `dev-run.sh`**, com `ANVIL_DEV_ROOT` no ambiente: este é o HOME
  privado do checkout. Peça para abrir uma sessão normal, fora do launcher, e
  atualizar a instalação publicada lá. Não proponha retirar os links privados.
- **Fora do launcher:** pode ser a ligação dev global antiga. O diagnóstico
  aponta `bash .claude/skills/anvil-sync/scripts/dev-link.sh --unlink`, executado
  na raiz do repositório do anvil, não no subdiretório `anvil/`. A retirada é
  explícita, separada da instalação publicada; nunca faça isso automaticamente.

O diretório do usuário não tem git por trás, então o dry-run **lista por nome**
tudo que será substituído, removido e preservado. A saída classifica as skills e
os agentes em quatro grupos: *substituídos* · *órfãos, serão removidos* · *não são
do anvil, ficam intocados* · *preservados sempre*. Skill aparece pelo nome, agente
pelo caminho (`~/.claude/agents/{nome}.md`). Uma `tea-*` órfã sai com o nome novo
ao lado — `tea-open-pr — agora anvil-open-pr` —, porque as skills de git do anvil
mudaram de nome e o comando a digitar mudou com elas.

O substituído que o lock não lista sai de novo logo abaixo, como *possível colisão
com arquivo do usuário*: pode ser uma skill ou um agente que você escreveu com o
nome de um do payload. Ele será sobrescrito e passa a constar do lock.

Depois vem o bloco do espelho, `~/.agents/skills`: *symlinks novos* · *symlinks
refeitos* · *órfãos, serão removidos* · *colisões* · *não são do anvil*. Refeito é
o symlink com nome de skill do payload que apontava para outro lugar. Colisão no
espelho é diretório ou arquivo com nome de skill do payload. Ao contrário da
colisão de skill, ela **não** é substituída: fica como está, e o Codex e o omp
leem essa entrada, não a skill do anvil. Se `~/.agents` ou `~/.agents/skills` for
symlink ou arquivo, o espelho inteiro é seu: o bloco diz isso numa linha e nada
ali é tocado.

Depois vem o bloco da camada omp, que começa pelo que decidiu: *nova neste
update* ou *mantida*, com os sinais achados, ou *não instalada*, sem sinal
nenhum. Os grupos são os das skills, com o caminho em `~/.omp/agent/`: *arquivos
novos* · *substituídos* · *colisões* · *órfãos, serão removidos* · *não são do
anvil*. Colisão aqui é arquivo seu com o caminho de um arquivo da camada e fora do
lock: **será substituído**. Se `~/.omp/agent`, ou uma pasta no caminho da camada,
for symlink ou arquivo, ou se um arquivo da camada for diretório, a camada inteira
é sua: o bloco diz qual caminho impediu, nada em `~/.omp/agent/` é tocado e as
linhas `omp:` do lock ficam como estavam.

Depois, as diretivas do `~/.claude/CLAUDE.md`: arquivo novo, bloco novo no topo,
bloco em dia ou bloco que será substituído. E a guarda de merge do
`~/.claude/settings.json`: arquivo novo, hook novo, hook em dia, ou um `ATENÇÃO`
quando o arquivo fica intocado.

Por último, o projeto: *fora de projeto anvil*, ou o projeto onde roda, com uma
linha `BOOT PENDENTE` para cada perfil de `docs/agents/` ausente ou divergente do
template novo.

### 3. Avisar e esperar

Diga numa frase o que será apagado e o que será preservado, **nomeando os
órfãos** e as **possíveis colisões**, de skill, de agente e da camada omp, que
serão sobrescritas. Órfã com nome novo vai com o nome novo: é o único aviso ao
usuário de que o `/tea-*` que ele digitava deixou de existir. Não continue com um
"talvez".

Colisão no espelho não é sobrescrita. Antes de executar, compare cada uma com a
skill instalada, que o dry-run ainda não trocou:

```bash
diff -r ~/.agents/skills/{nome} ~/.claude/skills/{nome}
```

Sem diferença, é uma cópia que ficou ali. Diga isso e sugira apagá-la antes do
passo 4, para o update pôr o symlink no lugar. Com diferença, é sua: diga que o
Codex e o omp vão continuar lendo a sua versão.

### 4. Executar

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP"
```

### 5. Migrar o projeto instalado do jeito antigo

A instalação antiga copiava o toolkit para o projeto. Uma cópia velha no projeto
fica inerte no Claude Code, onde a skill de usuário vence, mas no omp a camada do
projeto pode vencer a de usuário; por isso ela sai. A migração cuida só do projeto
de onde o update roda, e não procura outros. Da raiz dele:

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/migrate-project.sh" --dry-run
```

- **Nada a migrar** → siga para o passo 6. É o caso fora de projeto e no projeto
  já migrado.
- **Árvore suja** → o script para sem tocar em nada. Peça commit ou stash: o diff
  da migração precisa mostrar só a remoção. Depois, rode o dry-run de novo.
- **Com `.claude/anvil.lock` no projeto** → o dry-run lista por nome o que sai:
  as skills e os agentes do lock, o próprio lock, os symlinks de `.agents/skills`
  com nome de skill do lock, os arquivos de `.omp/` das linhas `omp:`, a entrada
  do hook que chama `.claude/hooks/guard-spec-merge.sh` no `.claude/settings.json`,
  a cópia da guarda e o bloco `ANVIL:DIRECTIVES` do `CLAUDE.md`. E o que fica:
  skill, agente e arquivo de `.omp/` fora do lock, rules, `docs/`, o resto do
  settings e do `CLAUDE.md`. Diga isso numa frase e **espere aprovação**.
- **Sem lock** → o script sai com código 3 e lista as skills de `.claude/skills/`
  e os agentes de `.claude/agents/` sem apagar nada, com uma marca nos que têm
  conteúdo fora do git: se o item sair, esse conteúdo não volta pelo git. Mostre a
  lista com as marcas e **pergunte quais não vieram do anvil**. A resposta volta
  nos dois parâmetros, e tudo fora deles sai: rode o dry-run de novo com eles e
  espere aprovação.

  ```bash
  bash "$TMP/.claude/skills/anvil-update/scripts/migrate-project.sh" --dry-run \
       --keep-skills "minha-skill outra-skill" --keep-agents "meu-agente"
  ```

O que sai fica em duas partes. O que o git conhece aparece no `git status` depois
da execução. O que está fora do git sai junto e aparece só no relatório, arquivo
por arquivo, no grupo **"sai junto, fora do git, sem volta pelo git"**: o item sem
nada versionado, como o toolkit que um `.gitignore` antigo, o `.git/info/exclude`
ou o excludes global ignora, e o arquivo ignorado dentro de item versionado, como
um `.DS_Store` ou um `__pycache__/`. Ao pedir a aprovação, nomeie esse grupo: o
que está nele não volta com `git checkout`. A regra de ignore não faz a migração
parar, venha de onde vier, e o `.gitignore` fica como está.

O `CLAUDE.md` e o `.claude/settings.json` que são symlink com o alvo dentro do
repositório, como o comum `CLAUDE.md → AGENTS.md`, têm o alvo editado pelas
mesmas regras, e a mudança aparece no `git status`. O grupo **"passa por
symlink"** lista o que ficou intocado: o item cujo caminho passa por diretório
symlink e o `CLAUDE.md` ou o settings com o alvo fora do repositório. Diga ao
usuário que o item ficou porque a migração não escreve fora do projeto. Se o
alvo é do próprio projeto, ele tira à mão o bloco `ANVIL:DIRECTIVES` ou a entrada
do hook da guarda; se é da instalação de usuário (`~/.claude/CLAUDE.md`,
`~/.claude/settings.json`), deixa como está.

Aprovado, execute, com os mesmos `--keep-*` quando houve a pergunta:

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/migrate-project.sh"
```

A migração **nunca commita**: a remoção do que era versionado fica no
`git status` para o usuário revisar e commitar.

Em qualquer projeto, migrado ou não, o dry-run também acusa com `BOOT PENDENTE` o
perfil de `docs/agents/` que cita script pelo caminho da instalação por projeto,
como `.claude/skills/anvil-to-spec/scripts/new-spec.sh`. Esse caminho não existe
sem a cópia: aponte o `/anvil-boot`, que traz o perfil do template.

### 6. Relatar

- órfãos removidos, **por nome**, inclusive os do espelho e da camada omp
- as colisões que foram sobrescritas, por nome
- o projeto migrado, se houve: o que saiu dele; o que era versionado está no
  `git status`, esperando o commit do usuário; o que estava fora do git foi
  listado no dry-run
- a camada omp: nova, mantida ou não instalada, e o sinal que decidiu
- as diretivas: o bloco do `~/.claude/CLAUDE.md` criado, trocado ou em dia
- a guarda de merge: o hook do `~/.claude/settings.json` registrado agora, já em
  dia, ou o `ATENÇÃO` com o comando para registrar à mão
- o que há de novo no toolkit
- o que ficou no disco para você decidir
- **o que o update não toca e pode ter ficado para trás.** Os perfis em
  `docs/agents/` são do projeto e escritos pelo `/anvil-boot`, então uma versão
  nova do toolkit pode trazer perfil que um projeto ainda não tem. Rodado de
  dentro de um projeto, os dry-runs já acusaram com `BOOT PENDENTE`, inclusive o
  perfil que cita script pelo caminho antigo. Perfil que existe e diverge do
  template **não** é sobrescrito: o projeto pode tê-lo
  ajustado. Mostre o diff contra o template instalado e pergunte:

  ```bash
  diff docs/agents/verification.md ~/.claude/skills/anvil-docs/templates/verification-anvil.md
  ```

- se a estrutura de rules ou templates mudou, sugira rodar `/anvil-boot` nos
  projetos

**Nunca commite.** Nem a migração do projeto, nem nada no diretório do usuário,
que não tem git.

### 7. Limpar

```bash
rm -rf "$TMP"
```

## Regras

- O dry-run vem antes de qualquer remoção, sempre, e a execução espera a
  aprovação.
- O reset do `reset-install.sh` roda do `$TMP`, nunca da instalação de usuário.
- Nada é apagado fora do conjunto que o script calcula. **Skill ou agente que o
  usuário escreveu não é do anvil para remover.**
- O lockfile é reescrito pelo script. Não edite à mão.
- Fora da migração do passo 5, nada é escrito em projeto. Nada é commitado.
