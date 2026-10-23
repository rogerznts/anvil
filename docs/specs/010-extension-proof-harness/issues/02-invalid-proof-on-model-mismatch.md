# 02: A prova sai inválida quando outro modelo responde

**Blocked by:** 01

**Status:** resolved

**What to build:** depois da sessão, o helper confere o modelo de toda mensagem do
assistente, na sessão principal e nas de subagente que ela abriu, como a do
`anvil-implementer`. Alguma de outro modelo torna a prova inválida: código `3`,
que não conta como verde nem como vermelho.

- [x] O helper lê os jsonl da sessão principal e das sessões de subagente, achadas
      pelos frames do rpc, e copia os dos subagentes para as saídas da prova.
- [x] Toda mensagem do modelo pedido: o código da prova é o das conferências dela,
      `0` verde ou `1` vermelho.
- [x] Uma mensagem de outro modelo, na principal ou num subagente: código `3`, com
      cada modelo que respondeu e quantas mensagens ele deu. O `3` vale sobre o
      verde e sobre o vermelho.
- [x] Sessão que terminou em erro do provedor fica registrada como tal nas saídas,
      com a mensagem de erro.
- [x] O vermelho medido com o texto de antes passa pela mesma conferência.
- [x] Prova S1, sem modelo, num diretório novo de `workspace/`: jsonl de fixture
      todo do modelo pedido dá verde; uma mensagem de outro modelo na principal dá
      `3`; uma num subagente dá `3`; os modelos e as contagens saem na saída.
- [x] A sessão real do ticket 01, conferida pelo helper, dá o código das
      conferências e lista o modelo pedido.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o veredito é uma operação nova do helper, `proof_verdict --model
  <modelo> --out <saídas> <código das conferências>` (`proof-verdict.py`), que a
  prova chama por último e que sai com o código da prova; ele grava o relatório em
  `<saídas>/verdict.txt`. O condutor assina os frames de subagente
  (`set_subagent_subscription` em `progress`) e copia o `sessionFile` de cada
  `subagent_lifecycle`/`subagent_progress` para `<saídas>/subagents/`. O vermelho
  passa pela mesma conferência porque o código das conferências, `0` ou `1`, é
  argumento do veredito e o `3` vale sobre os dois.
- Implementação · o `--model` casa com o `<provider>/<model>` da mensagem ou só com
  o `<model>`, literalmente: um apelido como `sonnet` dá `3`, com os modelos na
  saída. "Terminou em erro do provedor" é a última mensagem do assistente da
  sessão com `stopReason: error`; o erro que a sessão superou depois não é o fim
  dela.
- Implementação · provas em `workspace/60-invalid-proof/`: `s1.sh` (omp falso que
  escreve os jsonl e manda os frames de subagente; bash 5.2 e `/bin/bash` 3.2)
  passou inteiro; `s2.sh` refaz as conferências do `s2.sh` do ticket 01 e confere
  uma cópia das saídas dele: código do helper `0`, igual ao das conferências,
  `anthropic/claude-sonnet-4-5 (2 mensagens)`; `s3.sh`, sessão real com um
  subagente aberto no turno 2, confirma no omp 18.12.6 o `subagent_lifecycle` com
  o `sessionFile` e a cópia em `subagents/`: código do helper `0`,
  `anthropic/claude-sonnet-4-5 (5 mensagens)`, 1 delas do subagente.
- Implementação · o `s1.sh` do ticket 01 (`workspace/59-proof-helper/`) compara a
  ordem exata dos comandos que o omp falso recebe; a conferência ganhou o
  `set_subagent_subscription` antes do turno 1, e o resto dela não mudou. Passou
  inteiro de novo.
