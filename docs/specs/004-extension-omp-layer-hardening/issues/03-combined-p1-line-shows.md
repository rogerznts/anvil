# 03: P1 do travado em linha combinada

**What to build:** O relatório do ticket travado passa a trazer o P1 mesmo quando a linha do `## Comments` combina classes, como "Review round=2 · P2 (Standards) e P1 (Spec)". O operador decide a terceira rodada vendo o achado que travou. É a linha A3 do acompanhamento.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Conta toda linha da última rodada que começa por `Review round=N ·` e tem `P1` em posição de classe, seguido de espaço e parêntese ou de dois-pontos, em qualquer ponto depois do ponto médio.
- [ ] "Review round=2 · P2 (Standards): prova fraca do P1 anterior" não conta.
- [ ] Travado sem linha P1 continua dizendo isso por extenso.
- [ ] A mesma saída em `LC_ALL=C` e em UTF-8, e nos dois bash, por fixture em `/tmp`.
- [ ] O `verify` sai limpo.
