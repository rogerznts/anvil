# 08: `anvil-run` conduz a spec

**What to build:** No omp, o operador chama `/skill:anvil-run 003` e vê a spec implementada ticket a ticket, sem abrir uma sessão por ticket. A sessão principal vira o supervisor: deriva o frontier do disco, despacha um `anvil-implementer` por vez, relê o disco e recalcula, até não sobrar o que despachar. Termina com um relatório e o próximo passo, sem nunca fazer QA, archive ou PR.

**Blocked by:** 07

**Status:** ready-for-agent

- [ ] A skill fica em `.omp/skills/`, com trava de invocação.
- [ ] Sem argumento, resolve a spec pelo prefixo numérico do branch atual; fora do branch da spec, recusa e diz qual é o branch.
- [ ] Frontier: `Status:` diferente de `resolved`, todos os `Blocked by` resolvidos e não travado. Travado é o ticket cuja última linha `Review:` tem `round` 2 ou mais e `verdict=fail`.
- [ ] Despacha em série, sempre o menor número do frontier, e relê o disco depois de cada implementer.
- [ ] Implementer que terminou sem mudar o estado do ticket não é repetido na mesma execução.
- [ ] Nunca abre a terceira rodada, nunca dispara browser QA, archive ou PR.
- [ ] Mostra o andamento a cada ticket.
- [ ] Relatório final: com tudo resolvido, recomenda `/skill:anvil-browser-qa` quando a spec tem tela — existe `ui/` na pasta da spec ou uma user story descreve tela — e `/anvil-docs archive` quando não tem; com pendências, lista os travados com o P1 aberto e os que dependem deles.
- [ ] Rodar de novo depois de uma queda retoma pelo disco.
- [ ] Cenário S2: spec de fixture com três tickets e uma aresta despachada na ordem certa; ticket com `Review: round=2 … verdict=fail` pulado e o dependente listado; recusa fora do branch; recomendação com e sem `ui/`.
- [ ] A skill entra no lock como `omp:`; o `verify` sai limpo.
