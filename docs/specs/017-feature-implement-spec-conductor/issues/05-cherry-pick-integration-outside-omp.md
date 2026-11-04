# 05: Fora do omp, a `implement-spec` integra por cherry-pick, como a guarda prevê

**What to build:** Onde o harness não integra o trabalho dos implementers sozinho — Claude Code, Codex, ou omp sem a isolação no modo branch com worktree manual —, a `implement-spec` pede dois merges que a guarda de merge bloqueia enquanto a spec está aberta: o implementer que traz a ponta do branch de integração para o branch dele (passo 4) e o merger que traz o trabalho dele para o branch de integração (passo 5). A guarda prevê o `git cherry-pick` para integrar com a spec aberta. As diretivas do anvil, que todo harness carrega, traduzem os dois passos: o implementer faz `git rebase` sobre a ponta do branch de integração em vez do merge, e o merger faz `git cherry-pick` dos commits do implementer no branch de integração. Os branches dos implementers não levam o padrão `tipo/NNN-` no nome, para a guarda não os ler como spec. Achado P2 do ticket 01.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O bloco de diretivas do `claude_boot.md` traduz o merge dos passos 4 e 5 da `implement-spec` para rebase e cherry-pick, e diz que vale só onde o harness não integra sozinho; o bloco do `CLAUDE.md` da raiz fica igual byte a byte.
- [ ] O texto vendorizado da `implement-spec` não muda.
- [ ] Numa spec de dois tickets independentes, conduzida pela `implement-spec` no Claude Code com worktrees, os dois trabalhos chegam ao branch da spec sem a guarda bloquear nada.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
