---
name: anvil-update
description: "Update: reinstala o toolkit anvil do zero (reset + degit), apagando órfãos de versões anteriores, e resume o que mudou. Use ao atualizar ou sincronizar a versão do anvil no projeto."
---

<!-- STATUS: stub. Implementação prevista para a Fase 6 do plano. -->

Esta skill ainda não está implementada. Ela existe no payload para reservar o
nome e o contrato; rodá-la hoje não faz nada.

## O contrato

**Isto é um reset, não uma sobrescrita.** As skills que o anvil instalou são
apagadas e reinstaladas. Ficam intactos: `.claude/rules/`, `.claude/settings.json`,
`docs/`, `CLAUDE.md` e qualquer skill que o usuário tenha escrito.

**Por que reset e não `degit --force`:** o `--force` sobrescreve arquivo a
arquivo e **nunca apaga**. Uma skill que deixou de existir upstream ficaria no
disco para sempre, e os agentes continuariam encontrando e tentando usar. Atualizar
sem reset acumula o entulho de todas as versões anteriores.

**Como os órfãos são calculados:** pelo `.claude/anvil.lock`, que lista o que
esta instalação possui. É o que substitui a detecção por prefixo do mosk — um
lockfile diz a verdade, um prefixo adivinha.

## Fluxo previsto

1. **Preflight** — confirmar que é repositório git; se a árvore estiver suja,
   parar e pedir commit ou stash. O reset é irreversível sem git.
2. **Baixar sem tocar no projeto** — `TMP="$(mktemp -d)"` e
   `npx degit rogerznts/anvil/anvil "$TMP"`.
3. **Dry-run obrigatório** — rodar o `reset-install.sh` **recém-baixado**, nunca
   o instalado: o script apaga o próprio diretório onde vive, e rodar a partir
   do `$TMP` garante que a lógica de reset é a nova, não a da versão velha.
4. **Avisar e esperar** — dizer numa frase o que será apagado e o que será
   preservado, **nomeando os órfãos**. Não continuar com um "talvez".
5. **Executar** o reset.
6. **Relatar** — órfãos removidos, o que mudou localmente (`git status --short`,
   `git diff --stat`), o que há de novo, e o que ficou no disco para o usuário
   decidir. Nunca commitar sozinho.
7. `rm -rf "$TMP"`.

## Onde está a implementação de origem

O `reset-install.sh` do mosk é a base: cálculo do conjunto a apagar, lista de
protegidos e o guard de `--from == --to`. Ele vive no submodule `references/mosk`
do repositório do anvil, sob os scripts do toolkit, e precisa ser portado
trocando a detecção por prefixo pelo lockfile.
