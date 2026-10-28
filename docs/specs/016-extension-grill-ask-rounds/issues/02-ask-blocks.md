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

**Status:** resolved

- [x] Num grill com mais de 10 decisões, no Claude Code, a estimativa é anunciada antes da primeira pergunta. O primeiro bloco tem 10 perguntas, em chamadas de até 4, e a estimativa nova aparece quando a árvore cresce.
- [x] No omp, pelo `dev-run.sh -- omp`, o mesmo grill manda o bloco numa chamada do `ask`.
- [x] No Codex em modo padrão, o bloco sai no fallback em texto compacto. `1a 2c` é lido como escolha, e `3x: <texto>` ou texto que não casa com nenhuma letra é lido como resposta custom.
- [x] Nos três harnesses, inclusive no último prompt, toda pergunta mostra uma opção marcada como recomendada e uma custom, e nenhuma das duas aparece em dobro.
- [x] O último prompt traz o resumo de todas as decisões. "Ajustar" reabre a decisão escolhida e volta àquele ramo. Nada é feito antes de "confirmar".
- [x] Nenhum bloco traz pergunta cuja resposta dependa de outra ainda aberta.
- [x] O `anvil-bench` faz uma pergunta por vez, pela ferramenta, com recomendada e custom.
- [x] O delta do `anvil-grilling` contra o pin fica restrito ao seam declarado no catálogo, e `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

**Prova**, em `workspace/91-grill-ask-rounds/` (fora do git), PLAN.md com 14 decisões e 3 ramos:

- Claude Code, HOME real com a skill copiada para a fixture como `grill-016` (o HOME dev não tem login do Claude): estimativa de 14 antes da 1ª pergunta, 1º bloco 4+4+2 em três chamadas, estimativa subindo até 30. A pergunta "qual decisão reabrir" do ajuste saía sem recomendada; a última frase da skill foi reforçada e a reprova passou (`out-claude-adjust2/`).
- omp pelo `dev-run.sh -- omp`: 1º bloco de 10 numa chamada do `ask`, `recommended: 0` em todas as 33 perguntas, sem marca dupla.
- Codex 0.162.1 em `codex exec`, HOME real com `grill-016`: blocos em texto compacto; `4x: …`, `12x: …` e uma frase solta viraram respostas custom.
- Bench: instrução da linha 167 do `anvil-bench` no omp, 12 chamadas do `ask` com uma pergunta cada.
