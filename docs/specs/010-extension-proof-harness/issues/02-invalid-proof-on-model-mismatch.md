# 02: A prova sai inválida quando outro modelo responde

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** depois da sessão, o helper confere o modelo de toda mensagem do
assistente, na sessão principal e nas de subagente que ela abriu, como a do
`anvil-implementer`. Alguma de outro modelo torna a prova inválida: código `3`,
que não conta como verde nem como vermelho.

- [ ] O helper lê os jsonl da sessão principal e das sessões de subagente, achadas
      pelos frames do rpc, e copia os dos subagentes para as saídas da prova.
- [ ] Toda mensagem do modelo pedido: o código da prova é o das conferências dela,
      `0` verde ou `1` vermelho.
- [ ] Uma mensagem de outro modelo, na principal ou num subagente: código `3`, com
      cada modelo que respondeu e quantas mensagens ele deu. O `3` vale sobre o
      verde e sobre o vermelho.
- [ ] Sessão que terminou em erro do provedor fica registrada como tal nas saídas,
      com a mensagem de erro.
- [ ] O vermelho medido com o texto de antes passa pela mesma conferência.
- [ ] Prova S1, sem modelo, num diretório novo de `workspace/`: jsonl de fixture
      todo do modelo pedido dá verde; uma mensagem de outro modelo na principal dá
      `3`; uma num subagente dá `3`; os modelos e as contagens saem na saída.
- [ ] A sessão real do ticket 01, conferida pelo helper, dá o código das
      conferências e lista o modelo pedido.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
