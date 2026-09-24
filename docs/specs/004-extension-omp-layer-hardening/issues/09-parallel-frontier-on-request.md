# 09: Frontier em paralelo sob pedido

**What to build:** O operador com isolação pode pedir ao `/skill:anvil-run` que rode até N tickets do frontier ao mesmo tempo. Sem o pedido, a execução segue em série; sem isolação, o pedido é recusado e a execução segue em série. O relatório mede quantos tickets estavam prontos a cada rodada. É a linha A10 do acompanhamento, e revê em parte a alternativa descartada do ADR-0011.

**Blocked by:** 08

**Status:** ready-for-agent

- [ ] A `anvil-run` aceita um argumento de paralelo com N de 2 em diante.
- [ ] Com isolação, cada leva é uma chamada do `task` com até N itens, um por ticket do frontier, na ordem do script; o script roda de novo depois da leva, e cada ticket passa pela comparação de antes e depois da 003.
- [ ] Sem isolação, a primeira linha de andamento recusa o paralelo com o motivo, e a execução segue em série.
- [ ] O `frontier.sh` emite `ready:` com quantos tickets estão no frontier, e o relatório final traz a linha `ready` de cada rodada.
- [ ] A regra "nunca despachar dois tickets ao mesmo tempo" vale só sem isolação.
- [ ] Conferido na prática, num fixture, o que o omp faz quando o cherry-pick de uma leva conflita, registrado no `## Comments`: o ticket que não mudou de estado vai para `skipped`, e árvore suja dá `halt`.
- [ ] Cenário no S2: uma spec com dois tickets livres e independentes roda numa leva de dois, com isolação, e os dois chegam resolvidos ao branch da spec.
- [ ] Cenário no S2: pedido de paralelo sem isolação é recusado e a execução segue em série.
- [ ] O ADR-0012 registra a decisão do paralelo com a isolação do omp e o comportamento conferido no conflito, e revê em parte o ADR-0011.
- [ ] O manual `anvil-omp` troca o limite "o frontier é em série" pelo paralelo sob pedido, com isolação.
- [ ] O `verify` sai limpo.
