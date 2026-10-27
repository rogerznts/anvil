# 07: O manual diz a saída que passa na conferência do merge

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=23e0a55843bc917eebbbf3bf6cadf66bd2d5db61; scope=full; verdict=pass; p1=none

**What to build:** o manual `anvil-omp` descreve a conferência do merge com a regra
que o piloto segue: passa com `0` fora do bench e, no bench, com a saída que vale o
`PASS` pela regra do `GATE.md`. Hoje ele diz "saindo `0`" sem a exceção do bench.

- [x] A frase da conferência do merge no `anvil-omp` diz `0` fora do bench e a
      saída que vale o `PASS` no bench, e qualquer outra saída aborta o merge.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Review round=1 · P3 (Spec): a frase do fechamento com `PASS` no `anvil-omp` (`SKILL.md:112-115`), fora deste ticket, ainda diz "saindo `0`" e põe o `--reverify` no lugar do comando no bench — quem lê só o manual pode achar que o `exit: 1` só com gates manuais de specs fechadas impede o fechamento, embora o piloto siga o `GATE.md`.
- Review round=1 · P3 (Standards): a frase nova junta dois apostos seguidos e repete "no bench, o `--reverify`" da frase anterior — nada quebra, o leitor só precisa de uma segunda leitura.
- Review round=1 · P3 (Standards): o critério "`vendor-sync.sh verify` sai `0`" está marcado sem a saída registrada no ticket — nada quebra, o leitor só não tem a prova à mão.
