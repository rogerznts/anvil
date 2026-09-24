# 10: Cenários repetidos do `anvil-plan`

**What to build:** O mantenedor tem um conjunto de cenários que mede o `anvil-plan` com rodadas repetidas: os seis desvios saindo do grill, um saindo do to-spec e um do to-tickets, três rodadas cada. A regra de nunca carregar uma etapa sem a proposta e o sim do operador é exigida em todas as rodadas; o reconhecimento do desvio e a volta à origem são medidos e reportados. É a linha A7 do acompanhamento.

**Blocked by:** 01, 05

**Status:** ready-for-agent

- [ ] Oito cenários, cada um com um roteiro de operador cuja fala carrega o sinal do desvio: `anvil-research`, `anvil-prototype`, `anvil-to-questionnaire`, `anvil-wayfinder`, `anvil-ui` e `anvil-architect` saindo do grill, um desvio saindo do to-spec e um saindo do to-tickets.
- [ ] Três rodadas por cenário, com o modelo padrão do ponta a ponta da 003; as sessões ficam guardadas.
- [ ] Conferência por código sobre as sessões: nenhuma skill de etapa ou de desvio é lida sem a proposta no turno anterior e o sim do operador. Vale nas 24 rodadas.
- [ ] Reportados por cenário: rodadas com o desvio certo proposto, rodadas com a volta à etapa de origem proposta, e o pass^3 de cada um.
- [ ] Cada rodada registra o modelo que respondeu; rodada com modelo diferente do pedido não conta e é refeita.
- [ ] O resultado vai para o `## Comments` com número de rodadas, quantas passaram em cada medida e o modelo.
