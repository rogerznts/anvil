# 07: O piloto pesquisa antes de travar numa parada técnica

**Blocked by:** 06

**Status:** ready-for-agent

**What to build:** numa parada técnica (ticket travado em `round=2`,
verificação que falha no `PASS` ou implementer bloqueado por fato desconhecido),
o piloto roda o `anvil-research` contra fontes primárias da web antes de deixar
a spec parada e grava o achado em `docs/specs/{id}/discovery/`. Se o achado traz
evidência nova, isto é, uma fonte citada que explica a falha e ainda não está no
ticket, o piloto abre uma rodada a mais, uma só por parada, no ticket que a
evidência aponta. Ele registra no `## Comments` do ticket que abriu a rodada e
por qual arquivo, e despacha um `anvil-implementer` para esse ticket com o
arquivo no contexto. Os sinais de laço de `docs/agents/verification.md`
bloqueiam a rodada mesmo com evidência. A parada por decisão (gate manual, PR,
contradição com o roteiro) não pesquisa.

O `FAIL` no teto do bench usa esta mesma pesquisa, e quem o liga é o ticket 10.

- [ ] Cada uma das três paradas técnicas dispara o `anvil-research` e grava um
      arquivo em `docs/specs/{id}/discovery/`.
- [ ] Com evidência nova que aponta um ticket, a linha em `## Comments` cita o
      arquivo, o ticket é despachado de novo, e a rodada gravada é a seguinte à
      última `Review:`.
- [ ] No máximo uma rodada extra por parada. Sem evidência nova, ou com
      evidência que não aponta ticket, não há rodada.
- [ ] Com dois sinais de laço presentes no histórico do ticket, a rodada não é
      aberta, e o motivo vai para o relatório.
- [ ] Gate manual, PR e contradição com o roteiro não geram arquivo de pesquisa.
- [ ] O relatório lista cada pesquisa com o arquivo e diz se abriu rodada.
- [ ] S2: no caso de ticket travado da spec, existe o arquivo de pesquisa, e o
      ticket mostra uma das duas saídas aceitas: a linha em `## Comments` citando
      o arquivo, ou o ticket em "o que ainda espera decisão".
