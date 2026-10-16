# 07: O piloto pesquisa antes de travar numa parada técnica

**Blocked by:** 06

**Status:** claimed
**Review:** round=1; sha=9fdf41d; scope=full; verdict=fail; p1=open

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
- Decisão tomada pelo repositório, sem operador: a rodada extra é uma só por
  ticket, em qualquer execução, e o registro dela é a linha `- Piloto · rodada`
  no `## Comments`; o ticket que já a tem não recebe outra e não pesquisa de novo.
  A verificação que falha pesquisa uma vez por spec em cada execução.
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
- Limite do S2, na primeira medição: os `sha` das linhas `Review:` da fixture não
  eram commits, e nos casos T e V o implementer da rodada extra parou ou mediu a
  partir do `HEAD` do começo da vez dele. Na rodada 2, a fixture passou a gravar
  commits reais, e o T fechou com `round=3` em `verdict=pass`.
- O `FAIL` no teto do bench não foi ligado: é do ticket 10.
- Review round=1 · P1 (Spec): a condição "uma por parada" vive na memória da conversa ("nesta execução"), e numa retomada o mesmo ticket travado de novo pode ganhar uma segunda rodada extra com outra URL — o teto do ADR-0010 vira uma rodada a mais por execução, contra o "uma só" da spec.
- Review round=1 · P2 (Spec): os critérios das três paradas técnicas e do gate manual estão marcados sem prova executada do implementer bloqueado nem do gate manual — quem lê só as caixas acredita que as três paradas foram exercitadas.
- Review round=1 · P3 (Standards): "a exceção declarada ao ADR-0010" cita o id sem glosa e sem "do anvil" — num projeto de usuário o agente pode abrir o ADR-0010 do projeto, que trata de outra coisa.
- Review round=1 · P3 (Standards): a condição 1 roda o `grep -F` no ticket que só a condição 2 identifica — com "Ticket que ela aponta: nenhum", o relatório pode dar "sem evidência nova" em vez de "a evidência não aponta ticket".
- Review round=1 · P3 (Standards): possível Mysterious Name — o título "Uma por parada" e o "Nunca" falam de parada, e a regra conta por ticket — editar só um dos dois diverge a unidade da contagem.
- Review round=1 · P3 (Standards): possível Shotgun Surgery — o relatório mantém "### Travados em round=2" com a rodada 3 agora possível — um ticket travado em `round=3` sai sob um título que mente sobre a rodada.
- Review round=1 · P3 (Standards): possível Duplicated Code — os quatro sinais de laço foram copiados de `docs/agents/verification.md` — se o perfil mudar, a skill fica com a cópia velha.
- Review round=1 · P3 (Standards): a seção "Pesquisa antes de travar", com cerca de 110 linhas só do caminho de parada, ficou inline e a skill passou de 740 linhas — o caminho feliz fica mais diluído.
- Review round=1 · P3 (Standards): no `anvil-implementer`, "a rodada seguinte é escolha do operador" não diz que a linha do piloto, testada antes, é a outra via — quem lê só o item não a acha.
- Correção da rodada 1: a condição "uma por parada" virou "uma só", lida do disco
  pela linha `- Piloto · rodada` no `## Comments` do ticket apontado, e o ticket
  que já a tem não pesquisa de novo. Na mesma seção, as condições passaram a
  conferir o ticket apontado antes da evidência nova, e o ADR-0010 ganhou a glosa.
  O S2 ganhou o caso X: o ticket 01 em `round=3 verdict=fail`, com a linha do
  piloto e o arquivo de pesquisa já commitados. A prova vermelha, com a skill da
  rodada 1, está em `s2-red-X.out`: o piloto pesquisou de novo, e gravou
  `research-ticket-01-2.md`. Com a correção, X passa sem pesquisa e sem rodada 4,
  e T, L, V e P passam de novo.
