# 05: A `implement-spec` prepara e remove os worktrees pelo workz

**What to build:** A diretiva "Integração na `anvil-implement-spec`" do `claude_boot.md` — e o bloco igual do `CLAUDE.md` raiz — manda, num projeto com a seção `## Worktrees`, criar o worktree de cada implementer com `printf '{"name":"<nome>"}' | bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh" create`, em vez de `git worktree add`, e passar no brief o caminho que ele imprime; no passo 9, remover cada um com o `remove` do script. A razão: na prova da 017 no Claude Code, o condutor criou os worktrees pelo Bash, e o `WorktreeCreate` não dispara nesse caminho. O gancho fica para o worktree que o Claude Code cria sozinho. A rule de harness da camada omp, `anvil-update/.omp-layer/rules/anvil-harness.md`, manda o brief do implementer isolado rodar o `provisionar:` da seção na raiz da cópia antes de começar; a isolação do omp continua criando e removendo. O texto vendorizado da `implement-spec` não muda.

**Blocked by:** 03, 04

**Status:** ready-for-agent

- [ ] A diretiva do `claude_boot.md` e a rule de harness do omp dizem o que este ticket descreve, e o bloco do `CLAUDE.md` raiz é igual ao `claude_boot.md`.
- [ ] Prova no Claude Code real, com `claude-sonnet-5-5`: a `implement-spec` sobre uma spec de dois tickets independentes num projeto descartável com uma dependência ignorada pelo git que a suíte importa, um `.env` que a suíte lê e a seção `## Worktrees`. Cada implementer roda a suíte no próprio worktree, criado pelo `create` do script, sem instalar dependência, e no fim nenhum worktree nem branch `worktree-*` de implementer sobra.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments
