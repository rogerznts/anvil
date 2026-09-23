---
name: anvil-update
description: "Update: reinstala o toolkit anvil do zero (reset + degit), apagando órfãos de versões anteriores, e resume o que mudou. Use ao atualizar ou sincronizar a versão do anvil no projeto."
---

# Update

Reinstala o payload do anvil e reporta o que mudou.

## O contrato

**Isto é um reset, não uma sobrescrita.** As skills e os agentes que o anvil
instalou são apagados e reinstalados. Ficam intactos: `.claude/rules/`,
`.claude/settings.json`, `docs/`, `CLAUDE.md`, e **qualquer skill ou agente que
você tenha escrito**. A ressalva é a skill ou o agente seu, fora do lock, com o
mesmo nome de um do payload: é sobrescrito, depois do destaque de colisão no
dry-run e do aviso do passo 4.

O espelho do Codex, `.agents/skills`, é refeito a partir do lock: um symlink para
`.claude/skills` por skill do payload. Ali, todo symlink com nome de skill do anvil
é do anvil e é refeito, aponte para onde apontar. **Diretório ou arquivo é seu e
fica intocado**, mesmo com nome de skill do anvil.

**Por que reset e não `degit --force`:** o `--force` sobrescreve arquivo a
arquivo e **nunca apaga**. Uma skill que deixou de existir upstream ficaria no
disco para sempre, e os agentes continuariam encontrando e tentando usar.
Atualizar sem reset acumula o entulho de todas as versões anteriores.

**Como os órfãos são calculados:** pelo `.claude/anvil.lock`, que lista o que
esta instalação possui, com uma linha `skill:` por skill e uma `agent:` por
agente. É o que substitui a detecção por prefixo do mosk — um lockfile diz a
verdade, um prefixo adivinha, e adivinha errado justamente nas skills que não
seguem o padrão de nome, como as `tea-*`.

Instalação sem lock não tem nada classificado como nosso. É a leitura segura —
nada é apagado — mas também significa que **órfão nenhum é limpo**. Se o preflight
não achar `.claude/anvil.lock`, **avise antes de seguir**: o reset vai instalar o
payload novo por cima e deixar no disco tudo que sobrou da versão anterior.

Nesse caso, ou o usuário aceita e o lock passa a existir a partir daqui, ou ele
escreve o lock com a lista atual antes de rodar, para o update ter o que comparar.
Tudo o que entra no lock é tratado como do anvil e apagado como órfão se o payload
novo não o trouxer. Por isso, antes, mostre as skills de `.claude/skills/` e os
agentes de `.claude/agents/` e **pergunte quais não vieram do anvil**. Eles entram
em `USER_SKILLS` e `USER_AGENTS` e ficam fora:

```bash
USER_SKILLS="minha-skill outra-skill"   # skills que não vieram do anvil; vazio se nenhuma
USER_AGENTS="meu-agente"                # agentes que não vieram do anvil, sem o .md; vazio se nenhum
{ echo "# anvil.lock — o que esta instalacao possui."
  echo "# Escrito antes do update. Nao edite a mao."
  ls .claude/skills | while read -r s; do
    case " $USER_SKILLS " in *" $s "*) ;; *) echo "skill: $s" ;; esac
  done
  ls .claude/agents 2>/dev/null | sed -n 's/\.md$//p' | while read -r a; do
    case " $USER_AGENTS " in *" $a "*) ;; *) echo "agent: $a" ;; esac
  done
} > .claude/anvil.lock
```

O lock novo aparece no `git status`, e o preflight pede árvore limpa: peça ao
usuário que commite o lock antes de seguir.

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

**No reset, rode a cópia recém-baixada, nunca a instalada.** O reset apaga o
próprio diretório onde o script vive. Rodar do `$TMP` também garante que a lógica
de reset é a nova, não a da versão velha. O `--unignore`, que só tira do
`.gitignore` o bloco de uma instalação antiga, pode rodar da cópia instalada — é o
que o `/anvil-boot` faz.

A saída classifica em quatro grupos: *substituídos* · *órfãos, serão removidos* ·
*não são do anvil, ficam intocados* · *preservados sempre*.

Skill aparece pelo nome, agente pelo caminho (`.claude/agents/{nome}.md`).

Com lock, o substituído que o lock não lista sai de novo logo abaixo, como
*possível colisão com arquivo do usuário*: pode ser uma skill ou um agente que o
usuário escreveu com o nome de um do payload. Ele será sobrescrito e passa a
constar do lock. Sem lock tudo está fora dele, não há como distinguir, e o
destaque não aparece.

Depois vem o bloco do espelho do Codex, `.agents/skills`: *symlinks novos* ·
*symlinks refeitos* · *órfãos, serão removidos* · *colisões* · *não são do anvil*.
Refeito é o symlink com nome de skill do payload que apontava para outro lugar,
como o link absoluto e pendurado que o degit deixa para o cache dele. Colisão no
espelho é diretório ou arquivo com nome de skill do payload. Ao contrário da
colisão de skill, ela **não** é substituída: fica como está, e o Codex lê essa
entrada, não a skill do anvil. Se `.agents` ou `.agents/skills` for symlink ou
arquivo, o espelho inteiro é do usuário: o bloco diz isso numa linha e nada ali é
tocado.

Por último vem o `.gitignore`. **O toolkit instalado fica versionado**, então nada
é escrito ali. Instalação de uma versão antiga tem um bloco `ANVIL:INSTALLED` que
ignorava as skills e os agentes: o reset o **remove**, e o dry-run avisa. Só o
bloco sai; o resto do `.gitignore` fica como estava.

### 4. Avisar e esperar

Diga numa frase o que será apagado e o que será preservado, **nomeando os
órfãos** e as **possíveis colisões**, que serão sobrescritas. Não continue com um
"talvez".

Colisão no espelho não é sobrescrita. Antes de executar, compare cada uma com a
skill instalada, que o dry-run ainda não trocou:

```bash
diff -r .agents/skills/{nome} .claude/skills/{nome}
```

Sem diferença, é uma cópia que um payload antigo deixou ali: versões anteriores
traziam `anvil-browser-qa` e `anvil-next` como diretório real. Diga isso e sugira
apagá-la antes do passo 5, para o update pôr o symlink no lugar. Com diferença, é
do usuário: diga que o Codex vai continuar lendo a versão dele.

### 5. Executar

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP" --to .
```

### 6. Relatar

- órfãos removidos, **por nome**
- o que mudou localmente: `git status --short` e `git diff --stat`
- o que há de novo no toolkit
- o que ficou no disco para você decidir
- `.gitignore`: o bloco `ANVIL:INSTALLED` removido, se havia um; diga que as
  skills e os agentes instalados passam a aparecer no `git status`
- **o que o update não toca e pode ter ficado para trás.** O reset troca
  `.claude/skills/`, `.claude/agents/` e o espelho `.agents/skills/`, e só. O
  bloco `ANVIL:DIRECTIVES` do `CLAUDE.md` e os perfis em `docs/agents/` são
  escritos pelo `/anvil-boot`, então uma versão nova do toolkit pode trazer
  diretiva ou perfil que este projeto ainda não tem. Confira os dois e, se algum
  acusar, **sugira rodar `/anvil-boot`**:

  ```bash
  awk '/ANVIL:DIRECTIVES:START/{f=1;next} /ANVIL:DIRECTIVES:END/{f=0} f' CLAUDE.md |
    diff -q - .claude/skills/anvil-boot/claude_boot.md >/dev/null ||
    echo "bloco de diretivas do CLAUDE.md diverge do claude_boot.md novo"
  if [ ! -f docs/agents/verification.md ]; then
    echo "sem docs/agents/verification.md — o critério de parada da verificação não chegou"
  elif ! cmp -s docs/agents/verification.md \
      .claude/skills/anvil-docs/templates/verification-anvil.md; then
    echo "docs/agents/verification.md diverge do template novo — mostre o diff"
  fi
  ```

  Perfil que existe e diverge do template **não** é sobrescrito: o projeto pode
  tê-lo ajustado. Mostre o diff e pergunte.
- se a estrutura de rules ou templates mudou, sugira rodar `/anvil-boot` de novo

**Nunca commite sozinho.** O diff é para o usuário revisar.

### 7. Limpar

```bash
rm -rf "$TMP"
```

## Regras

- Árvore suja não é resetada sem confirmação explícita.
- O dry-run vem antes de qualquer remoção, sempre.
- O reset do `reset-install.sh` roda do `$TMP`, nunca do projeto.
- Nada é apagado fora do conjunto que o script calcula. **Skill ou agente que o
  usuário escreveu não é do anvil para remover.**
- O lockfile é reescrito pelo script. Não edite à mão.
- Nenhum bloco é escrito no `.gitignore`. O toolkit instalado é versionado como o
  resto do projeto.
