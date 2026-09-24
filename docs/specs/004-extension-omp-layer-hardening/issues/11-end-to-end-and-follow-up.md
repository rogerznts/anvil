# 11: Ponta a ponta e acompanhamento

**What to build:** O caminho inteiro da 003 roda de novo com a camada desta spec, sem isolação, e passa: a troca de chaves e as regras novas não mudaram a condução. O acompanhamento passa a dizer só o que continua aberto.

**Blocked by:** 02, 03, 04, 05, 06, 07, 09, 10

**Status:** ready-for-agent

- [ ] O ponta a ponta da 003 (`workspace/35-omp-e2e/`) roda do degit ao relatório da `anvil-run` com o payload deste branch, e o `check.sh` passa, ajustado só para as chaves novas.
- [ ] As linhas A1 a A11 saem de `docs/project/acompanhamento.md`, e fica uma linha para o adaptador de tracker, com origem nesta spec.
- [ ] O README e o `overview.md` citam o paralelo sob pedido com isolação onde descrevem a camada omp.
- [ ] O `verify` sai limpo.
