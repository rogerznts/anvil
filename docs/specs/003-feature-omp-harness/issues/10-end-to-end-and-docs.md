# 10: Ponta a ponta e documentação

**What to build:** O caminho inteiro funciona num projeto de verdade, e quem chega ao anvil entende que há três harnesses e só um automatiza. Num projeto descartável: degit do payload local, `/skill:anvil-boot`, `/skill:anvil-plan` até os tickets e `/skill:anvil-run` até o relatório. O README ganha a seção do omp e do Codex, o `overview.md` cita a camada de harness, e o manifesto registra as peças autorais da camada.

**Blocked by:** 02, 04, 06, 08, 09

**Status:** ready-for-agent

- [ ] Cenário ponta a ponta em `workspace/` roda do degit ao relatório da `anvil-run`, com a camada instalada pelo boot e a guarda bloqueando um merge prematuro.
- [ ] O mesmo projeto aberto no Claude Code mostra a mesma lista de skills de antes da spec.
- [ ] O README tem uma seção curta: o que o omp ganha, como a camada chega, os comandos, o que segue manual no Claude Code e no Codex.
- [ ] O `overview.md` cita a camada de harness.
- [ ] O manifesto registra `anvil-plan`, `anvil-run`, `anvil-omp` e `anvil-implementer` como autorais da camada omp.
- [ ] O `verify` sai limpo.
