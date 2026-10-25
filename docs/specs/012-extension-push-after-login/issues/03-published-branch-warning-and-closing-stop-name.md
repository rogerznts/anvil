# 03: Aviso de branch publicado e o nome "parada no fechamento"

**Blocked by:** 01, 02

**Status:** ready-for-agent

**What to build:** quando o push do fechamento por PR deu certo e nenhuma URL de PR
voltou, por CLI sem autenticação, erro do `pr create` ou outra recusa do
`anvil-open-pr`, o relatório do piloto diz que o branch está no remoto. O `Estado:`
fica `parada no branch, publicado em origin sem PR: <passo e motivo>`, e "O que
ainda espera decisão" pergunta se o operador corrige o motivo e abre o PR ou apaga
`origin/<branch>`. O piloto nunca apaga o branch remoto. No mesmo texto, a A29: os
três nomes da parada de uma spec já arquivada que não chega ao branch base viram
"parada no fechamento", o termo do glossário.

- [ ] O aviso sai só quando o `git push -u` saiu `0` e não voltou URL de PR; a
      parada antes do push não fala de branch publicado, e o PR aberto continua com
      o `Estado:` de PR aberto, com a URL.
- [ ] "O que ainda espera decisão" traz a pergunta do destino do branch remoto.
- [ ] O piloto não roda `git push --delete` nem outro comando que apague o branch
      remoto; a spec retomada no fechamento refaz o `git push -u` e segue a ordem
      do ticket 02.
- [ ] "Não fecha no fechamento", "parada no fechamento depois do archive" e
      "parada, já arquivada no branch" saem do `anvil-auto`; o caso passa a se
      chamar "parada no fechamento", e os casos listados na "Parada" ficam.
- [ ] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge`, num
      diretório novo de `workspace/`: fixture GitHub com o arquivo de pedido de
      falha do `pr create`, do ticket 01. O bare tem o branch, o `Estado:` diz
      "publicado em origin sem PR", e "O que ainda espera decisão" traz a pergunta
      do branch remoto. Vermelho: o payload de `4271efd`, sem o aviso. O código do
      helper sai nas saídas.
- [ ] As S2 do ticket 02 continuam passando.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
