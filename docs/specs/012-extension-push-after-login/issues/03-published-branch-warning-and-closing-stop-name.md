# 03: Aviso de branch publicado e o nome "parada no fechamento"

**Blocked by:** 01, 02

**Status:** resolved

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
