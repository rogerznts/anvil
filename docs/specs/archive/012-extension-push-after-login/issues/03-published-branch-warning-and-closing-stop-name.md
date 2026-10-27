# 03: Aviso de branch publicado e o nome "parada no fechamento"

**Blocked by:** 01, 02

**Status:** resolved
**Review:** round=1; sha=91c167577abbf046e770278d75e77a9c8bb18bb2; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=bdf65a02911f0f7e4d306c6379303766dfa437c2; scope=diff:91c167577abbf046e770278d75e77a9c8bb18bb2..bdf65a02911f0f7e4d306c6379303766dfa437c2; verdict=pass; p1=none

**What to build:** quando o push do fechamento por PR deu certo e nenhuma URL de PR
voltou, por CLI sem autenticação, erro do `pr create` ou outra recusa do
`anvil-open-pr`, o relatório do piloto diz que o branch está no remoto. O `Estado:`
fica `parada no branch, publicado em origin sem PR: <passo e motivo>`, e "O que
ainda espera decisão" pergunta se o operador corrige o motivo e abre o PR ou apaga
`origin/<branch>`. O piloto nunca apaga o branch remoto. No mesmo texto, a A29: os
três nomes da parada de uma spec já arquivada que não chega ao branch base viram
"parada no fechamento", o termo do glossário.

- [x] O aviso sai só quando o `git push -u` saiu `0` e não voltou URL de PR; a
      parada antes do push não fala de branch publicado, e o PR aberto continua com
      o `Estado:` de PR aberto, com a URL.
- [x] "O que ainda espera decisão" traz a pergunta do destino do branch remoto.
- [x] O piloto não roda `git push --delete` nem outro comando que apague o branch
      remoto; a spec retomada no fechamento refaz o `git push -u` e segue a ordem
      do ticket 02.
- [x] "Não fecha no fechamento", "parada no fechamento depois do archive" e
      "parada, já arquivada no branch" saem do `anvil-auto`; o caso passa a se
      chamar "parada no fechamento", e os casos listados na "Parada" ficam.
- [x] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge`, num
      diretório novo de `workspace/`: fixture GitHub com o arquivo de pedido de
      falha do `pr create`, do ticket 01. O bare tem o branch, o `Estado:` diz
      "publicado em origin sem PR", e "O que ainda espera decisão" traz a pergunta
      do branch remoto. Vermelho: o payload de `4271efd`, sem o aviso. O código do
      helper sai nas saídas.
- [x] As S2 do ticket 02 continuam passando.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: no "PR" do `anvil-auto`, depois do `git push -u`, a URL do PR é
  só a que o `pr create` imprime saindo `0`, e nenhuma URL se monta à mão. Quando o
  `anvil-open-pr` para sem URL, a spec fica em parada no fechamento com
  `- Estado: parada no branch, publicado em origin sem PR: <passo e motivo>`, e "o
  que ainda espera decisão" pergunta se o operador corrige o motivo e abre o PR ou
  apaga `origin/<branch>`. O mesmo trecho diz que a retomada da spec parada depois
  do push refaz o `--pr`, o `git push -u` e o `anvil-open-pr`, e que um
  `git push -u` que não sai `0` para a spec sem o aviso. O modelo do relatório
  ganhou a forma no `Estado:` e a pergunta em "O que ainda espera decisão"; o
  "Nunca" ganhou o apagar do branch remoto. Os três nomes viraram "parada no
  fechamento", com os casos da "Parada" iguais. O manual `anvil-omp` cita o aviso
  no fechamento por PR.
- Prova S2 em `workspace/84-pilot-published-branch-warning/s2.sh`: retomada no
  branch da 001 pronta para fechar, origin `https://github.com/acme/loja.git` sem
  `## Git`, só o master no bare e o `$PROOF_RUN/pr-create-fails`. Vermelho com o
  payload igual ao de `4271efd` (`git diff 4271efd -- anvil` vazio, `s2-red.out`):
  o `gh pr create` saiu `1`, o piloto montou à mão a URL
  `https://github.com/acme/loja/pull/1`, commitou a linha `PR:` com ela e deu o
  `Estado:` de PR aberto; 4 falhas, código do helper 1. Verde (`s2.out`): o `--pr`
  antes do `git push -u`, o bare com o branch, nenhuma linha `PR:`, nenhum comando
  que apague o branch remoto, o `Estado:` com "publicado em origin sem PR" e a
  pergunta de `origin/feature/001-conta-linhas`; código do helper 0. As S2 do
  ticket 02 passam: `workspace/83-pilot-login-before-push/s2-t03.out`, código 0,
  sem "publicad" no relatório, e `workspace/76-pilot-closes-by-pr/s2-t03-github.out`,
  código 0, com o `Estado:` de PR aberto e a URL. `vendor-sync.sh verify` sai `0`
  (`verify.out`).
- Review round=1 · P1 (Spec): a retomada da spec em parada no fechamento, que o ticket pede ("a spec retomada no fechamento refaz o `git push -u` e segue a ordem do ticket 02") e a US 13 da spec repete, está escrita no "PR" do `anvil-auto`, mas é inalcançável: no branch, o `stage.sh` dá `next: none` e a "Largada" recusa a spec arquivada ("o piloto não retoma a spec"); no branch base, a entrada fica `stopped` e fora do `next` — o operador que corrige a autenticação e chama o piloto de novo recebe uma recusa e abre o PR à mão.
- Review round=1 · P3 (Spec): o `git push -u` que não sai `0` deixa a spec parada, mas o caso não entra na lista da "Parada" — quem casa a regra pela lista não o acha.
- Review round=1 · P3 (Spec): o manual `anvil-omp` ainda diz "a spec fica parada, já arquivada no branch", e a spec afirma que o `anvil-auto` é o único lugar da camada omp com os três nomes — a US 16 (um nome só na skill, no relatório e no glossário) fica pela metade, embora o ticket peça a troca só no `anvil-auto`.
- Review round=1 · P3 (Spec): o "sem publicado" da parada antes do push só foi lido em `workspace/83-pilot-login-before-push/out-t03/report`, e não é conferência do `s2.sh` de lá — se o aviso passar a sair antes do push, aquela S2 continua verde.
- Review round=1 · P3 (Standards): possível Duplicated Code, aceito pelo padrão do "Nunca" e do modelo do relatório — a proibição de apagar o branch remoto e a pergunta do destino dele aparecem no "PR", no modelo do relatório, no "Nunca" e no manual `anvil-omp`; uma mudança na pergunta precisa ser feita em três lugares.
- Review round=1 · P3 (Standards): desvio do glossário — o `git push -u` que não sai `0` é mais uma parada depois do archive, fora da lista da "Parada" e da definição de **Parada no fechamento** do `context.md`, e as linhas do "PR" alternam "parada, como diz Parada" e "parada no fechamento" — quem procura os casos do fechamento pela lista ou pelo glossário não acha a falha do push.
- Review round=1 · P3 (Standards): no item novo do "Nunca", "o branch remoto, …, nem o da spec parada com o branch publicado em `origin`" repete "branch" e o "nem" não acrescenta nada — só deixa a leitura mais lenta.
- Review round=1 · P3 (Standards): no manual `anvil-omp`, "corrige o motivo e abre o PR ou apaga o branch remoto, o que o piloto nunca faz sozinho" tem antecedente ambíguo — o operador pode ler que o piloto nunca abre o PR sozinho, contra a frase anterior do próprio manual.
- Correção do P1 da rodada 1: na "Largada" do `anvil-auto`, o `next: none` com o
  branch fora do branch base (`git merge-base --is-ancestor HEAD <base>` diferente
  de `0`) deixou de recusar e vai à "Retomada" como spec em parada no fechamento;
  com `0`, a recusa fica. A "Retomada" ganhou o caso `none`: sem refazer o archive,
  o piloto roda o resolvedor e decide como em "Fechamento"; com merge local, ou com
  a linha `PR:` num ticket (PR aberto), recusa; com PR e sem a linha, segue o "PR",
  com o `--pr`, o `git push -u` e o `anvil-open-pr`. O manual `anvil-omp` descreve
  a retomada no fechamento. Prova: o caso `CASO=retomada` do mesmo
  `workspace/84-pilot-published-branch-warning/s2.sh`, com a 001 arquivada no
  branch, o branch já no bare e sem o pedido de falha. Vermelho com o payload de
  `91c1675`, a rodada 1 (`s2-red-retomada.out`): a largada recusou, 8 falhas,
  código do helper 1. Verde (`s2-retomada.out`): nenhum archive novo, o `--pr`
  antes do `git push -u`, um `gh pr create`, a linha `PR:` no bare e o `Estado:`
  de PR aberto, com a URL; código do helper 0. Com o texto final, o aviso passa de
  novo (`s2-r2.out`, código 0), e as S2 do ticket 02 também:
  `workspace/83-pilot-login-before-push/s2-t03-r2.out`, código 0, sem "publicad"
  no relatório, e `workspace/76-pilot-closes-by-pr/s2-t03-r2-github.out`, código
  0, com o `Estado:` de PR aberto. `vendor-sync.sh verify` sai `0`.
- Review round=2: o P1 da rodada 1 fechou (eixo Spec). Os P3 da rodada 1 continuam abertos nos dois eixos, com o mesmo texto: o `git push -u` que não sai `0` fora da lista da "Parada" e da definição do glossário, o "já arquivada no branch" do manual `anvil-omp`, a S2 de `workspace/83-pilot-login-before-push/` sem conferir a ausência do aviso, a redação do item do "Nunca" e o antecedente ambíguo do manual; o Duplicated Code segue aceito pelo padrão do "Nunca".
- Review round=2 · P2 (Spec): a recusa da spec parada pela conferência do merge saiu da "Largada" para o caso `none` da "Retomada", depois do `roadmap.sh` e do resolvedor, e o texto não manda mais a recusa dizer que a spec está arquivada no branch sem merge nem apontar o branch base, o motivo que o ticket 06 da spec 009 exige; a S2 que confere isso, `workspace/57-merge-check/s2.sh` no `CASO=F` (F2), não foi rodada de novo — a recusa pode perder o motivo sem que prova alguma acuse.
- Review round=2 · P3 (Standards): possível Duplicated Code — a ordem do PR (`--pr`, `git push -u`, `anvil-open-pr`) aparece no caso `none` da "Retomada", no "PR" e no manual `anvil-omp`; quem mudar a ordem num lugar e esquecer outro deixa duas versões em conflito.
- Review round=2 · P3 (Standards): possível Mysterious Name — a "Largada" e a "Retomada" separam "spec aberta" de "spec em parada no fechamento", mas a "Parada" diz que a spec parada "fica aberta no branch dela", e a descrição do frontmatter e a introdução só falam em "spec aberta" — quem lê a descrição não sabe se a retomada no fechamento está coberta.
- Review round=2 · P3 (Standards): na retomada no fechamento, a linha `Roteiro:` do modelo do relatório ("na etapa <next do stage.sh>") vira "na etapa none" (`workspace/84-pilot-published-branch-warning/out-retomada/report`) — o operador não lê nela em que ponto a spec foi retomada.
- Review round=2 · P3 (Standards): o manual `anvil-omp` passou a dizer "spec parada no fechamento" poucas linhas antes do "a spec fica parada, já arquivada no branch" que o _Avoid_ do glossário lista — os dois nomes ficam lado a lado no mesmo arquivo.
- Review round=2 · P3 (Spec e Standards): "No bench, a pasta da spec sem `gates.md` pede o Ledger da spec antes de qualquer um desses pontos" passa a valer para o caso `none`, em que a pasta já está em `docs/specs/archive/` — o piloto pode procurar o `gates.md` no caminho antigo e refazer o ledger de uma spec arquivada, contra o "O que o disco já tem não se refaz".
