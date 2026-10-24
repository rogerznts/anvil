# 07: O manual diz a saída que passa na conferência do merge

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** o manual `anvil-omp` descreve a conferência do merge com a regra
que o piloto segue: passa com `0` fora do bench e, no bench, com a saída que vale o
`PASS` pela regra do `GATE.md`. Hoje ele diz "saindo `0`" sem a exceção do bench.

- [x] A frase da conferência do merge no `anvil-omp` diz `0` fora do bench e a
      saída que vale o `PASS` no bench, e qualquer outra saída aborta o merge.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments
