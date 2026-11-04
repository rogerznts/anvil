# 04: Saem o `anvil-run`, o `anvil-implementer` e o `frontier.sh`

**What to build:** A camada omp deixa de ter o condutor `anvil-run`, o script `frontier.sh` dele e o agente `anvil-implementer`. O fim do `anvil-plan` e a linha `handoff` do `stage.sh` indicam a `implement-spec`. As menções no `roadmap.sh` saem. A cauda de roteamento do `claude_boot.md` troca o `anvil-run` pela `anvil-implement-spec` e tira a exceção que só existia para ele, com o bloco do `CLAUDE.md` do repositório igual ao `claude_boot.md`. O `anvil.lock` deixa de listá-los, e o update de uma instalação de usuário apaga a cópia instalada. README, overview, glossário e `docs/index.md` falam do condutor novo. Ver a spec, "O que sai" e "Documentação e decisão".

**Blocked by:** 02, 03

**Status:** ready-for-agent

- [x] Nenhuma referência viva ao `anvil-run`, ao `anvil-implementer` ou ao `frontier.sh` fora de ADRs antigos, specs arquivadas e `references/`.
- [x] Numa instalação de usuário descartável com a versão anterior, o `reset-install.sh` remove os três.
- [x] O `stage.sh` termina com o `handoff` para a `implement-spec`, e o `anvil-plan` indica essa skill no fim.
- [x] A cauda de roteamento no `claude_boot.md` e no `CLAUDE.md` do repositório lista a `anvil-implement-spec` e não o `anvil-run`.
- [x] README, overview, glossário e `docs/index.md` descrevem a `implement-spec` como o condutor nos três harnesses.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
