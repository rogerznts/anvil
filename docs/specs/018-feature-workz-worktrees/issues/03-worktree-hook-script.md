# 03: O script `workz-worktree.sh` cria e remove o worktree do implementer

**What to build:** `anvil/.claude/skills/anvil-docs/scripts/workz-worktree.sh`, com dois verbos. `create` lê do stdin o JSON do `WorktreeCreate` do Claude Code e tira o nome de `name`, depois `branch`, depois o nome-base de `worktree_path`. Cria o branch `worktree-<nome>` a partir do `HEAD` do checkout principal, no caminho `<pai do repo>/<repo>--worktree-<nome>` — a convenção que o `workz done` deduz do branch —, roda dentro dele o comando da linha `provisionar:` da seção `## Worktrees` do `.claude/rules/anvil.md`, manda toda saída para stderr e imprime no stdout só o caminho absoluto, sem `.` nem `..`. Sai diferente de `0`, sem caminho no stdout, quando a seção falta, quando não há `workz` no `PATH` ou quando o `provisionar` falha; nesse último caso, desfaz o worktree e o branch que criou. Um nome que já tem worktree é reusado, como o `claude-hook` do workz faz. `remove` recebe o caminho — pelo campo `worktree_path` do JSON do `WorktreeRemove` no stdin, ou como argumento — e roda `workz done <branch> --force --delete-branch`. Só usa comandos da `v0.11.0` do workz.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Num repositório descartável com `node_modules`, `.env` ignorados e a seção `## Worktrees` com `provisionar: workz sync --quiet`, `printf '{"name":"t1"}' | workz-worktree.sh create` imprime uma linha só, o caminho `<pai>/<repo>--worktree-t1`, que existe, está no branch `worktree-t1`, tem o `.env` e o `node_modules` do checkout principal.
- [ ] Com `provisionar: workz sync --isolated --quiet`, o worktree criado tem `.env.local` com o bloco gerenciado do workz.
- [ ] `printf '{"worktree_path":"<caminho>"}' | workz-worktree.sh remove` remove o worktree e o branch `worktree-t1`; `workz-worktree.sh remove <caminho>` faz o mesmo.
- [ ] Sem a seção `## Worktrees`, sem `workz` no `PATH`, ou com um `provisionar` que sai 1, o `create` sai diferente de `0`, não imprime nada no stdout e não deixa worktree nem branch.
- [ ] Um segundo `create` com o mesmo nome devolve o mesmo caminho, sem erro.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments
