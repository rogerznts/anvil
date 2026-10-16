# 07: O piloto pesquisa antes de travar numa parada técnica

**Blocked by:** 06

**Status:** resolved

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

- [x] Cada uma das três paradas técnicas dispara o `anvil-research` e grava um
      arquivo em `docs/specs/{id}/discovery/`.
- [x] Com evidência nova que aponta um ticket, a linha em `## Comments` cita o
      arquivo, o ticket é despachado de novo, e a rodada gravada é a seguinte à
      última `Review:`.
- [x] No máximo uma rodada extra por parada. Sem evidência nova, ou com
      evidência que não aponta ticket, não há rodada.
- [x] Com dois sinais de laço presentes no histórico do ticket, a rodada não é
      aberta, e o motivo vai para o relatório.
- [x] Gate manual, PR e contradição com o roteiro não geram arquivo de pesquisa.
- [x] O relatório lista cada pesquisa com o arquivo e diz se abriu rodada.
- [x] S2: no caso de ticket travado da spec, existe o arquivo de pesquisa, e o
      ticket mostra uma das duas saídas aceitas: a linha em `## Comments` citando
      o arquivo, ou o ticket em "o que ainda espera decisão".

## Comments

- Implementação: o `anvil-auto` ganhou a seção "Pesquisa antes de travar", com
  as três paradas técnicas, a lista das paradas por decisão, o arquivo
  `docs/specs/<pasta>/discovery/research-<ticket-NN|verification>.md` commitado
  no branch da spec, o brief do `anvil-research` terminando numa `## Conclusão`
  de três linhas (fonte, ticket apontado, correção), as quatro condições da
  rodada extra, na ordem (evidência nova pelo `grep -F` da URL no ticket, ticket
  apontado, sem dois sinais de laço, uma por parada), e a linha
  `- Piloto · rodada <N+1> aberta por <arquivo>: …` no `## Comments`. O
  "Despacho", o `PASS`, a "Parada", o relatório (seção "Pesquisas" e a pergunta
  da parada técnica) e o "Nunca" passaram a encaminhar para ela.
- Decisão tomada pelo repositório, sem operador: o `anvil-implementer` também
  mudou. Ele parava em todo ticket com `round` 2 ou mais e `verdict=fail`, e não
  fazia nada num ticket `resolved` com `verdict=pass`, o que tornava inútil o
  despacho da rodada extra. Agora a linha `- Piloto · rodada <N> aberta por …`
  sem `Review:` de `round=<N>` abre a rodada N: o implementer lê o arquivo,
  corrige e mede, e P1 numa rodada aberta pelo piloto com N 2 ou mais para o
  ticket como na rodada 2.
- Decisão tomada pelo repositório, sem operador: o ticket que já recebeu a rodada
  extra nesta execução não recebe outra, e a parada que volta depois dela não
  pesquisa de novo; a verificação pesquisa uma vez por spec na execução.
- S2 em `workspace/49-auto-research/s2.sh`, sobre fixtures em `/tmp`, com
  `MODELO=sonnet`, em retomada no branch da spec 001. O `conta.sh` da fixture usa
  `grep -c ""`, e o teste falha. A prova vermelha, com a skill do ticket 06, está
  em `s2-red-*.out`: T, L e V falham por não pesquisar, e P passa.
  - T: ticket 01 travado em `round=2`, com o mesmo P1 nas duas rodadas. O piloto
    gravou `discovery/research-ticket-01.md` (fonte: POSIX `grep`, na Open
    Group), escreveu a linha da rodada 3 no `## Comments`, despachou o 01, que
    gravou `round=3` com `verdict=pass`, e a spec fechou. `muda-legado`, a
    contradição com o roteiro, parou sem pesquisa.
  - L: o mesmo travado, com dois sinais de laço no histórico. O arquivo existe, a
    rodada não abriu, e o relatório nomeia os dois sinais.
  - V: ticket 01 `resolved` com `verdict=pass` e verificação saindo `1`. O piloto
    gravou `discovery/research-verification.md`, abriu a rodada 2 no 01, e a
    spec fechou com a verificação passando.
  - P: projeto que fecha por PR. Archive e PR, sem `anvil-research` e sem
    arquivo em `discovery/`.
- Limite do S2: nenhum caso exercita o implementer bloqueado por fato
  desconhecido, nem o gate manual, nem a parada que volta depois da rodada extra.
  Essas regras estão na skill e não foram vistas rodando.
- Limite do S2: os `sha` das linhas `Review:` da fixture não são commits. Nos
  casos T e V, o implementer da rodada extra registrou que o fixed point não
  resolve e mediu a partir do `HEAD` do começo da vez dele.
- O `FAIL` no teto do bench não foi ligado: é do ticket 10.
