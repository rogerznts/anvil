# 04: O `anvil-boot` configura o workz no projeto

**What to build:** No passo das rules, o `anvil-boot` pergunta se o projeto usa o workz para os worktrees dos implementers, propondo o comando econômico `workz sync --quiet` e oferecendo o isolado `workz sync --isolated --quiet`. Com sim: grava a seção `## Worktrees` do `.claude/rules/anvil.md` com a linha `provisionar:`; roda `workz init -y` quando o projeto não tem `.workz.toml`; e grava no `.claude/settings.json` do projeto os ganchos `WorktreeCreate` e `WorktreeRemove` do Claude Code, com `bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh" create` e `… remove`, mesclando com o que o arquivo tem e achando a entrada pelo comando exato. Depois, confere que o gancho dispara: um payload de teste no `create` devolve caminho existente, e o `remove` o apaga. Sem `workz` no `PATH`, não grava ganchos e manda rodar o `/anvil-update`. Num `anvil.md` que já tem a seção, o valor do projeto fica. Um ADR novo registra a exceção à regra "o boot não escreve hook no projeto", do passo 8 do boot: o `WorktreeCreate` substitui a criação de worktree inteira, e só o projeto que usa o workz deve tê-lo.

**Blocked by:** 02, 03

**Status:** resolved

- [x] A `SKILL.md` do `anvil-boot` tem a pergunta, o formato da seção `## Worktrees`, o `workz init -y` condicional, a gravação mesclada dos dois ganchos e a conferência de disparo, e o passo 8 cita a exceção.
- [x] Num projeto descartável, seguindo o passo à mão, o `.claude/settings.json` termina com os dois ganchos e com o que já tinha; rodar de novo não duplica a entrada.
- [x] O ADR novo existe, com status aceito, e está no índice dos ADRs em `docs/index.md`.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0, e o bloco `ANVIL:DIRECTIVES` do `CLAUDE.md` raiz continua igual ao `claude_boot.md`.

## Comments

- Implementado em `0e0ab06`, com o ADR-0025 no índice. Prova num projeto descartável com o HOME dev: o `.workz.toml` saiu do `workz init -y`; a mescla dos ganchos manteve o `PreToolUse` e as permissões que o arquivo tinha e, rodada duas vezes, não duplicou; a conferência do boot, com o comando exato por `$HOME`, imprimiu `gancho: cria …--worktree-anvil-boot-check` e `gancho: remove`.
