# 05: A `implement-spec` prepara e remove os worktrees pelo workz

**What to build:** A diretiva "Integração na `anvil-implement-spec`" do `claude_boot.md` — e o bloco igual do `CLAUDE.md` raiz — ganha a limpeza: num projeto com a seção `## Worktrees`, no passo 9 quem conduz roda `bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh" remove <caminho>` para cada worktree de implementer, porque o Claude Code não chama o `WorktreeRemove` para subagente. A rule de harness da camada omp, `anvil-update/.omp-layer/rules/anvil-harness.md`, manda o brief do implementer rodar o `provisionar:` da seção no próprio worktree antes de começar, quando o projeto a tem; a isolação do omp continua criando e removendo. O texto vendorizado da `implement-spec` não muda.

**Blocked by:** 03, 04

**Status:** ready-for-agent

- [ ] A diretiva do `claude_boot.md` e a rule de harness do omp dizem o que este ticket descreve, e o bloco do `CLAUDE.md` raiz é igual ao `claude_boot.md`.
- [ ] Prova no Claude Code real, com `claude-sonnet-5-5`: a `implement-spec` sobre uma spec de dois tickets independentes num projeto descartável com `node_modules`, `.env` e a seção `## Worktrees` configurada pelo passo do boot. Cada implementer roda a suíte no próprio worktree sem instalar dependência, o gancho `WorktreeCreate` do projeto foi quem criou os worktrees, e no fim nenhum worktree nem branch `worktree-*` de implementer sobra.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments
