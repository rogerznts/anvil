---
name: anvil-update
description: "Update: reinstala o toolkit anvil do zero (reset + degit), apagando órfãos de versões anteriores, e resume o que mudou. Use ao atualizar ou sincronizar a versão do anvil no projeto."
---

# Update

Reinstala o payload do anvil e reporta o que mudou.

## O contrato

**Isto é um reset, não uma sobrescrita.** As skills que o anvil instalou são
apagadas e reinstaladas. Ficam intactos: `.claude/rules/`, `.claude/settings.json`,
`docs/`, `CLAUDE.md`, e **qualquer skill que você tenha escrito**.

**Por que reset e não `degit --force`:** o `--force` sobrescreve arquivo a
arquivo e **nunca apaga**. Uma skill que deixou de existir upstream ficaria no
disco para sempre, e os agentes continuariam encontrando e tentando usar.
Atualizar sem reset acumula o entulho de todas as versões anteriores.

**Como os órfãos são calculados:** pelo `.claude/anvil.lock`, que lista o que
esta instalação possui. É o que substitui a detecção por prefixo do mosk — um
lockfile diz a verdade, um prefixo adivinha, e adivinha errado justamente nas
skills que não seguem o padrão de nome, como as `tea-*`.

Instalação sem lock não tem nada classificado como nosso. É a leitura segura —
nada é apagado — mas também significa que **órfão nenhum é limpo**. Se o preflight
não achar `.claude/anvil.lock`, **avise antes de seguir**: o reset vai instalar o
payload novo por cima e deixar no disco tudo que sobrou da versão anterior.

Nesse caso, ou o usuário aceita e o lock passa a existir a partir daqui, ou ele
escreve o lock com a lista atual antes de rodar, para o update ter o que comparar:

```bash
ls .claude/skills | sed 's/^/skill: /' > /tmp/lock-atual
```

## Fluxo

### 1. Preflight

Confirme que é repositório git. Se não for, avise que o reset é irreversível sem
git e **pergunte** antes de seguir.

`git status --short`: árvore suja, **pare** e peça commit ou stash. Não há como
distinguir alteração sua de resíduo de versão antiga no meio de um reset.

### 2. Baixar, sem tocar no projeto

```bash
TMP="$(mktemp -d)"
npx degit rogerznts/anvil/anvil "$TMP"
```

### 3. Dry-run — obrigatório

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" \
     --dry-run --from "$TMP" --to .
```

**Rode a cópia recém-baixada, nunca a instalada.** O script apaga o próprio
diretório onde vive. Rodar do `$TMP` também garante que a lógica de reset é a
nova, não a da versão velha.

A saída classifica em quatro grupos: *substituídos* · *órfãos, serão removidos* ·
*não são do anvil, ficam intocados* · *preservados sempre*.

### 4. Avisar e esperar

Diga numa frase o que será apagado e o que será preservado, **nomeando os
órfãos**. Não continue com um "talvez".

### 5. Executar

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP" --to .
```

### 6. Relatar

- órfãos removidos, **por nome**
- o que mudou localmente: `git status --short` e `git diff --stat`
- o que há de novo no toolkit
- o que ficou no disco para você decidir
- se a estrutura de rules ou templates mudou, sugira rodar `/anvil-boot` de novo

**Nunca commite sozinho.** O diff é para o usuário revisar.

### 7. Limpar

```bash
rm -rf "$TMP"
```

## Regras

- Árvore suja não é resetada sem confirmação explícita.
- O dry-run vem antes de qualquer remoção, sempre.
- O `reset-install.sh` roda do `$TMP`, nunca do projeto.
- Nada é apagado fora do conjunto que o script calcula. **Skill que o usuário
  escreveu não é do anvil para remover.**
- O lockfile é reescrito pelo script. Não edite à mão.
