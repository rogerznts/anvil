# 08: Implementer isolado e retomada

**What to build:** Com a isolação de tarefas do omp ligada, o `/skill:anvil-run` despacha cada implementer num workspace isolado, e o trabalho volta ao branch da spec como commits, pelo modo branch do omp. A sobra de um implementer que caiu não chega ao branch da spec, e rodar de novo retoma. Sem isolação, tudo segue como na 003, e a parada passa a dizer como sair dela. É a linha A2 do acompanhamento.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O supervisor olha se o `task` oferece o campo `isolated`. Com ele, todo despacho sai com `isolated: true`; sem ele, o laço é o da 003.
- [ ] O relatório abre dizendo se a execução rodou com ou sem isolação.
- [ ] A linha `halt` diz como sair da parada, com `git stash` ou com um commit do operador.
- [ ] O manual `anvil-omp` ganha a seção de isolação: o que ela muda na retomada, que o paralelo depende dela, que precisa do modo branch, e como ligá-la na configuração do omp.
- [ ] Cenário no S2 com a isolação ligada: os tickets resolvidos chegam ao branch da spec como commits, e a árvore da spec fica limpa.
- [ ] Cenário no S2 com a isolação ligada e um implementer que termina sem mudar o estado: a árvore da spec fica limpa, o ticket vai para `skipped`, e uma segunda execução o despacha de novo.
- [ ] Cenário no S2 com a isolação em modo patch, se o omp permitir configurá-lo: a árvore suja resultante dá `halt` e o relatório aponta a configuração.
- [ ] O S2 sem isolação passa como antes.
- [ ] O `verify` sai limpo.
