# 09: `anvil-plan` conduz o planejamento

**What to build:** No omp, o operador chama `/skill:anvil-plan <pedido>` uma vez e é conduzido por grill, to-spec e to-tickets na mesma janela, sem precisar saber a ordem nem os desvios. Quando a pausa humana de uma etapa fecha, a skill propõe a próxima ou um desvio, e só carrega com o sim. Termina indicando a passagem para a implementação.

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] A skill fica em `.omp/skills/`, com trava de invocação; o argumento vai para o grill como pedido inicial.
- [ ] Carrega `anvil-grill`, `anvil-to-spec` e `anvil-to-tickets` na mesma janela, sem compactar, e as pausas de cada uma continuam existindo.
- [ ] Depois de cada pausa fechada, propõe a próxima etapa ou um desvio; nada é carregado sem sim, e um "não" para sem carregar nada.
- [ ] Os desvios são `anvil-research`, `anvil-prototype`, `anvil-to-questionnaire`, `anvil-wayfinder`, `anvil-ui` e `anvil-architect`, cada um ligado ao sinal que o justifica; depois do desvio, propõe voltar à etapa de origem.
- [ ] Chamada de novo, retoma pela conversa e pelo disco: `spec.md` existe leva à sugestão de `to-tickets`; `issues/` com tickets leva ao fim da janela. Nenhum campo de estado é escrito.
- [ ] No fim, indica `/clear` e depois `/skill:anvil-run NNN`.
- [ ] Não publica spec nem ticket por conta própria.
- [ ] Cenário S2 em vários turnos: depois do grill confirmado propõe `to-spec` e não carrega sem sim; com sim, carrega na mesma janela; chamada de novo com `spec.md` no disco retoma na sugestão de `to-tickets`.
- [ ] A skill entra no lock como `omp:`; o `verify` sai limpo.
