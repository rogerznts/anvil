# 02: O grill pergunta pela ferramenta do harness, em blocos de 10, com recomendada e custom

**What to build:** O `anvil-grilling` recebe o delta da regra `ask-rounds`, só no seam do formato da rodada. Árvore, frontier, fatos buscados por subagente e término ficam verbatim. O comportamento novo:

- Antes do primeiro bloco, o grill anuncia a estimativa de perguntas, e anuncia de novo quando ela cresce.
- A frontier é quebrada em blocos de até 10, sem trazer para o bloco pergunta com pré-requisito aberto.
- Cada bloco sai pelo `AskUserQuestion`, com o `request_user_input` citado como equivalente no Codex. Ele é quebrado em quantas chamadas o limite do harness exigir.
- Toda pergunta traz a opção recomendada primeiro, marcada e com uma linha de porquê, e a opção custom: a nativa da ferramenta, quando existe, senão "Escrever minha resposta", nunca as duas. Pergunta sem opinião do grill recomenda a opção mais conservadora.
- Sem ferramenta, o bloco sai no fallback em texto compacto, e o operador responde `1a 2c 3x: <texto>`.
- Com a frontier vazia, o último prompt traz o resumo das decisões e as opções confirmar (a recomendada), ajustar e custom. Esse prompt substitui a confirmação em prosa.
- O `anvil-bench` continua com uma pergunta por vez, agora como blocos de 1.

Ver a spec, "Implementation Decisions › O delta no `anvil-grilling`" e "Interação com quem chama o grill".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Num grill com mais de 10 decisões, no Claude Code, a estimativa é anunciada antes da primeira pergunta. O primeiro bloco tem 10 perguntas, em chamadas de até 4, e a estimativa nova aparece quando a árvore cresce.
- [ ] No omp, pelo `dev-run.sh -- omp`, o mesmo grill manda o bloco numa chamada do `ask`.
- [ ] No Codex em modo padrão, o bloco sai no fallback em texto compacto. `1a 2c` é lido como escolha, e `3x: <texto>` ou texto que não casa com nenhuma letra é lido como resposta custom.
- [ ] Nos três harnesses, inclusive no último prompt, toda pergunta mostra uma opção marcada como recomendada e uma custom, e nenhuma das duas aparece em dobro.
- [ ] O último prompt traz o resumo de todas as decisões. "Ajustar" reabre a decisão escolhida e volta àquele ramo. Nada é feito antes de "confirmar".
- [ ] Nenhum bloco traz pergunta cuja resposta dependa de outra ainda aberta.
- [ ] O `anvil-bench` faz uma pergunta por vez, pela ferramenta, com recomendada e custom.
- [ ] O delta do `anvil-grilling` contra o pin fica restrito ao seam declarado no catálogo, e `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
