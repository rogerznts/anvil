# 07: A `anvil-run` retoma o despacho interrompido

**Blocked by:** 06

**Status:** resolved

**What to build:** parte da issue #8. Um despacho interrompido, o `task` do
`anvil-implementer` que volta sem os três campos, cancelado ou com erro, deixa de
parar a corrente. O supervisor da `anvil-run` primeiro tenta o agente vivo, por
`write agent://<id>` e `wait`, pedindo que termine e devolva os campos. Sem agente
vivo e sem isolação, despacha um implementer novo para o mesmo ticket, com a
retomada do despacho no `context`. Com isolação, o ticket fica pulado, como hoje. O
limite é de duas retomadas do despacho por ticket; passado ele, o ticket é pulado.
O implementer, na retomada, continua do disco, e sempre termina a resposta com os
três campos.

- [x] Na `anvil-run`, o passo novo reconhece o despacho interrompido, tenta o
      agente vivo, despacha o implementer novo sem isolação, conta até duas
      retomadas por ticket e roda o `frontier.sh` com `--resume NN` na leitura
      seguinte; as exceções ao "nunca despache um pulado de novo" e ao "não termine
      o trabalho dele" ficam escritas, e a seção "Retomada" da skill diz a
      diferença entre a retomada e a retomada do despacho.
- [x] Cada retomada do despacho sai na linha de andamento, com o ticket e a
      tentativa; o ticket pulado pelo limite aparece entre os pulados do relatório.
- [x] No `anvil-implementer`: com retomada no `context`, o fixed point da rodada 1
      é o `HEAD` de antes do primeiro despacho, que o `context` traz, e ele continua
      dos commits desde esse `HEAD` e da árvore suja, sem `git checkout`,
      `git stash` nem `git reset`; os três campos são a última coisa da resposta,
      também quando ele para antes de terminar. A regra "verificação antes de cada
      commit" fica como está.
- [x] Prova S2 pelo helper, com `/skill:anvil-run`, num diretório novo de
      `workspace/`, com `workspace/54-auto-skip/` como prior art: fixture sem
      isolação com um `anvil-implementer` falso em `.omp/agents/` do projeto, que no
      primeiro despacho suja a árvore e termina sem os três campos e no segundo
      resolve o ticket. O ticket termina resolvido, sem `halt`, com a retomada na
      linha de andamento. Vermelho: o payload de `4271efd`, que para no `halt`.
- [x] Prova S2 do limite, com um falso que cai sempre: depois de duas retomadas do
      despacho, o ticket é pulado, e o falso foi despachado três vezes.
- [x] O caminho do agente vivo fica sem prova, e o `## Comments` diz por quê.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Execução: fixed point da rodada 1 `bd48ef1893511abfd6a4d3be27c280533071c301`. Seam S2 já acordada no ticket e na spec: `/skill:anvil-run` pelo helper real, observando despachos, árvore, ticket e andamento, sem conferir o texto da skill. Plano: medir o vermelho em `4271efd`; atualizar o supervisor e o implementer; medir a recuperação e o limite; verificar e revisar em dois eixos.
- Implementação: o supervisor reconhece o despacho interrompido antes da comparação de estado, guarda o `HEAD` inicial por ticket, relê com `--resume NN`, conta no máximo duas retomadas e registra ticket e tentativa no andamento. Resultado `completed` com id não é tomado por agente ainda em execução; retorno cancelado ou com erro de estado incerto consulta `agent://<id>`. O implementer retomado preserva commits e árvore suja, usa o `HEAD` original na rodada 1 e fecha também as paradas antecipadas com os três campos. O manual `anvil-omp` distingue a retomada do despacho da execução nova após queda da sessão.
- Prova S2 em `workspace/88-run-resume/s2.sh` e `check.py`, fora do git, pelo helper e pelo `/skill:anvil-run` real. Prior art: `workspace/54-auto-skip/`. O falso em `.omp/agents/anvil-implementer.md` ganha do agente de usuário pelo nome; `.omp/config.yml` desliga a isolação só na fixture. A contagem fica em `.git/despachos`, fora da árvore, e o arquivo `trabalho.txt` permanece sujo após a primeira resposta sem os três campos.
- Vermelho da recuperação: `RED=4271efd OUT=out-red bash workspace/88-run-resume/s2.sh`, com o payload histórico materializado por `git archive` no diretório temporário do helper e carregado pelo overlay, sem mexer na fonte nem nos links de usuário. Modelo confirmado `anthropic/claude-sonnet-4-5`; código do helper `1`, oito conferências falhando: um despacho apenas, arquivo incompleto, ticket aberto e `halt`. O caminho absoluto do `frontier.sh` usa o link de usuário atual, mas sem `--resume` mantém exatamente a parada antiga pela árvore suja, observada no resultado.
- Verde da recuperação: `OUT=out-resolve-green bash workspace/88-run-resume/s2.sh`, código do helper `0`, modelo confirmado `anthropic/claude-sonnet-4-5` na principal e nos dois filhos. Dois despachos reais de implementers novos, `--resume 01`, andamento com ticket 01 e tentativa 1/2, `HEAD` original no segundo `context`, primeira linha preservada, arquivo concluído, ticket `resolved`, árvore limpa e nenhuma leitura com `halt`. As saídas brutas, os comandos, os contextos e os vereditos ficam em `out-red/` e `out-resolve-green/`.
- Calibração da prova: em `out-resolve/`, o supervisor acordou por mensagem um falso já `completed`; isso não mede o ramo sem agente vivo. A skill passou a distinguir id retornado de agente ainda em execução. Em `out-resolve-final/`, a recuperação já usou implementer novo, mas a linha de andamento omitiu o ticket; a skill passou a dar a linha completa a preencher. Essas duas execuções saíram `1` e não contam como verde final.
- O caminho do agente vivo fica sem prova: o falso termina a resposta e não permanece em execução como o implementer real da issue #8. Acordar um falso já encerrado não reproduz esse caminho; a tentativa intermediária acima não é apresentada como prova dele. Não há typecheck nem suíte automatizada neste repositório; a verificação prescrita é `vendor-sync.sh verify`.
- Vermelho do limite: `CASO=limite RED=4271efd OUT=out-red-limite bash workspace/88-run-resume/s2.sh`, modelo confirmado `anthropic/claude-sonnet-4-5`, código do helper `1`, oito falhas: só um despacho, nenhuma retomada e parada no `halt`. A primeira execução do limite com o texto novo (`out-limite/`) fez os três despachos e pulou após as duas retomadas, mas o terceiro falso confundiu a âncora `1:2` do `read` com o valor do contador e gravou `2` de novo; saiu `1`. O falso passou a ler `.git/despachos:raw`; a conferência da contagem real de chamadas `task` foi mantida junto da conferência do contador.
- Verde do limite: `CASO=limite OUT=out-limite-green bash workspace/88-run-resume/s2.sh`, código do helper `0`, modelo confirmado `anthropic/claude-sonnet-4-5` na principal e nos três filhos. O falso foi despachado três vezes, o contador terminou `3`, o andamento identificou ticket 01 e tentativas 1/2 e 2/2, e a leitura final com `--skip "01"` deixou o ticket pulado no relatório pelo limite, sem quarto despacho. Nenhum caso usou fallback de modelo.
- Verificação antes do commit de implementação: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` saiu `0`, com `verify: limpo`.
