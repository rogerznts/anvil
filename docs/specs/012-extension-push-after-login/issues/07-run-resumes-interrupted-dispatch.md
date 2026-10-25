# 07: A `anvil-run` retoma o despacho interrompido

**Blocked by:** 06

**Status:** ready-for-agent

**What to build:** parte da issue #8. Um despacho interrompido, o `task` do
`anvil-implementer` que volta sem os três campos, cancelado ou com erro, deixa de
parar a corrente. O supervisor da `anvil-run` primeiro tenta o agente vivo, por
`write agent://<id>` e `wait`, pedindo que termine e devolva os campos. Sem agente
vivo e sem isolação, despacha um implementer novo para o mesmo ticket, com a
retomada do despacho no `context`. Com isolação, o ticket fica pulado, como hoje. O
limite é de duas retomadas do despacho por ticket; passado ele, o ticket é pulado.
O implementer, na retomada, continua do disco, e sempre termina a resposta com os
três campos.

- [ ] Na `anvil-run`, o passo novo reconhece o despacho interrompido, tenta o
      agente vivo, despacha o implementer novo sem isolação, conta até duas
      retomadas por ticket e roda o `frontier.sh` com `--resume NN` na leitura
      seguinte; as exceções ao "nunca despache um pulado de novo" e ao "não termine
      o trabalho dele" ficam escritas, e a seção "Retomada" da skill diz a
      diferença entre a retomada e a retomada do despacho.
- [ ] Cada retomada do despacho sai na linha de andamento, com o ticket e a
      tentativa; o ticket pulado pelo limite aparece entre os pulados do relatório.
- [ ] No `anvil-implementer`: com retomada no `context`, o fixed point da rodada 1
      é o `HEAD` de antes do primeiro despacho, que o `context` traz, e ele continua
      dos commits desde esse `HEAD` e da árvore suja, sem `git checkout`,
      `git stash` nem `git reset`; os três campos são a última coisa da resposta,
      também quando ele para antes de terminar. A regra "verificação antes de cada
      commit" fica como está.
- [ ] Prova S2 pelo helper, com `/skill:anvil-run`, num diretório novo de
      `workspace/`, com `workspace/54-auto-skip/` como prior art: fixture sem
      isolação com um `anvil-implementer` falso em `.omp/agents/` do projeto, que no
      primeiro despacho suja a árvore e termina sem os três campos e no segundo
      resolve o ticket. O ticket termina resolvido, sem `halt`, com a retomada na
      linha de andamento. Vermelho: o payload de `4271efd`, que para no `halt`.
- [ ] Prova S2 do limite, com um falso que cai sempre: depois de duas retomadas do
      despacho, o ticket é pulado, e o falso foi despachado três vezes.
- [ ] O caminho do agente vivo fica sem prova, e o `## Comments` diz por quê.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
