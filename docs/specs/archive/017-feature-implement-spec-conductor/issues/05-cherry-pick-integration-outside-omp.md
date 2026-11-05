# 05: Fora do omp, a `implement-spec` integra por cherry-pick, como a guarda prevê

**What to build:** Onde o harness não integra o trabalho dos implementers sozinho — Claude Code, Codex, ou omp sem a isolação no modo branch com worktree manual —, a `implement-spec` pede dois merges que a guarda de merge bloqueia enquanto a spec está aberta: o implementer que traz a ponta do branch de integração para o branch dele (passo 4) e o merger que traz o trabalho dele para o branch de integração (passo 5). A guarda prevê o `git cherry-pick` para integrar com a spec aberta. As diretivas do anvil, que todo harness carrega, traduzem os dois passos: o implementer faz `git rebase` sobre a ponta do branch de integração em vez do merge, e o merger faz `git cherry-pick` dos commits do implementer no branch de integração. Os branches dos implementers não levam o padrão `tipo/NNN-` no nome, para a guarda não os ler como spec. Achado P2 do ticket 01.

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=500ec49; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=a3224c3; scope=diff:ca56e46..a3224c3; verdict=pass; p1=none

- [x] O bloco de diretivas do `claude_boot.md` traduz o merge dos passos 4 e 5 da `implement-spec` para rebase e cherry-pick, e diz que vale só onde o harness não integra sozinho; o bloco do `CLAUDE.md` da raiz fica igual byte a byte.
- [x] O texto vendorizado da `implement-spec` não muda.
- [x] Numa spec de dois tickets independentes, conduzida pela `implement-spec` no Claude Code com worktrees, os dois trabalhos chegam ao branch da spec sem a guarda bloquear nada.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Prova no Claude Code real, `workspace/97-implement-spec-claude/out/`: worktree e branch `impl-001-t01`/`impl-001-t02` por implementer; `git rebase feature/001-carrinho` nos dois; integração por `git cherry-pick` (`76d168e`, `64a6410`); 20 chamadas `PreToolUse:Bash` com `hook_success` e nenhum bloqueio; `node --test` 5/5. Controle à mão: `git merge impl-001-t01` na fixture sai 2 com "Bloqueado"; `cherry-pick` e `rebase` saem 0.
- Review round=1 · P1 (Standards): a frase do nome dos branches dos implementers ("não leva o padrão `tipo/NNN-` no nome, como `impl-017-t01`") se lê como se `impl-017-t01` fosse o nome bloqueado — quem mantém o fluxo pode renomear branches ou desligar a regra por um risco que não existe.
- Review round=1 · P2 (Spec) contestado: "integração sem método comprovado" — o `session.jsonl` da prova tem os comandos `git rebase feature/001-carrinho` e `git cherry-pick $(git merge-base …)..impl-001-t02`, citados no relatório da prova; o revisor não leu o jsonl até o fim.
- Review round=1 · P3 (Spec): o `guard-controle.txt` registra `rc=141` (SIGPIPE do `| head`) ao lado do `rc=2` do controle sem `head` — quem lê pode duvidar do código de saída do bloqueio.
- Fora do ticket · P2: na prova, a rodada 1 achou só P3 e a sessão não despachou correção, embora o passo 7 da `implement-spec` diga "Fix all issues"; o bench fazia o mesmo antes de `b1bc1e2`. Fora do bench, um P2/P3 achado pode ficar sem correção.
- Review round=2 · P3 (Standards): "sem barra seguida de número" é mais largo que o padrão `[a-z]+/[0-9]{3}-` da guarda — só desaconselha nomes que passariam, sem efeito no fluxo.
