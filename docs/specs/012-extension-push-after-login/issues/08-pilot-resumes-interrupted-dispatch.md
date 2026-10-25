# 08: O piloto retoma o despacho interrompido

**Blocked by:** 07

**Status:** ready-for-agent

**What to build:** parte da issue #8. O piloto automático reescreve o laço da
`anvil-run` no "Despacho" em vez de carregá-la, então ganha o mesmo passo do ticket
07, com o mesmo texto: reconhecer o despacho interrompido, tentar o agente vivo,
despachar o implementer novo sem isolação, no máximo duas retomadas do despacho por
ticket e o `--resume NN` na leitura seguinte. O ticket que passa do limite segue o
caminho do pulado: o passo 1 do "Despacho" e a "Parada". Cada retomada do despacho
vai para "Decidido sem humano" no relatório.

- [ ] O "Despacho" do `anvil-auto` tem o passo do ticket 07, com as exceções ao
      "não é despachado de novo nesta execução" e ao "não termine o trabalho dele"
      escritas.
- [ ] Cada retomada do despacho sai em "Decidido sem humano", com o ticket e a
      tentativa.
- [ ] O manual `anvil-omp` descreve a retomada do despacho, se descreve o laço do
      piloto.
- [ ] Prova S2 pelo helper, com `/skill:anvil-auto` numa retomada no branch da
      spec, num diretório novo de `workspace/`, com `workspace/54-auto-skip/` como
      prior art, com o implementer falso do ticket 07: o ticket termina resolvido,
      sem `halt`, e a retomada do despacho está em "Decidido sem humano". Vermelho:
      o payload de `4271efd`, que para no `halt`.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
