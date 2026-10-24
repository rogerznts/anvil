# 06: O `CHECK:` caído vale antes do gate manual aberto

**Blocked by:** 02, 04

**Status:** resolved

**What to build:** uma saída do `--reverify` com gate manual desta spec aberto e
gate de `CHECK:` caído segue o caminho do `CHECK:` caído, com pesquisa, em vez de
parar a spec sem olhar a regressão. Só quando nenhum `CHECK:` cai, o gate manual
aberto desta spec deixa a spec parada por decisão. A regra mora no `GATE.md`.

- [x] Em "Sob o piloto automático" do `GATE.md`: a saída com algum gate de
      `CHECK:` caído, nesta spec ou numa fechada, segue o caminho do `CHECK:`
      caído, haja ou não gate manual desta spec aberto; sem `CHECK:` caído, o gate
      manual aberto desta spec deixa a spec parada por decisão; a pergunta do gate
      manual vai para o relatório nos dois casos.
- [x] O `anvil-auto` dispensa a pesquisa só quando nenhum `CHECK:` caiu, e aponta
      para o `GATE.md` em vez de repetir a regra.
- [ ] Prova S2 pelo helper, com a infra isolada, num diretório novo de
      `workspace/`, sobre a fixture de `workspace/56-manual-gate-rule/`, com
      `/skill:anvil-auto` no primeiro turno e uma saída mista: o vermelho, com o
      texto de antes, para sem pesquisar; o verde pesquisa no caminho do `CHECK:`
      caído e, quando só o gate manual sobra, para com a pergunta dele. O código do
      helper sai nas saídas, e prova inválida se repete.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · no `GATE.md`, o item do `CHECK:` caído vem primeiro e vale "haja
  ou não gate manual desta spec aberto"; o do gate manual desta spec passa a valer
  só "sem gate com `CHECK:` caído", como parada por decisão; e um parágrafo depois
  da lista manda cada gate manual aberto, desta spec ou de spec fechada, para "o
  que ainda espera decisão" também quando a spec seguiu o `FAIL` no teto. No
  `anvil-auto`, o `PASS` dispensa a pesquisa só no bench, sem `CHECK:` caído e com
  o gate manual desta spec segurando, "pela regra do `GATE.md`"; o desfecho do
  gate manual desta spec, a lista das paradas por decisão e a "Parada" ganharam a
  mesma ressalva; a pergunta vai para o relatório nos dois casos. Isso fecha
  também o P3 do ticket 10 da 008 sobre a pergunta que sumia na saída mista.
- Implementação · prova em `workspace/64-failed-check-manual-gate/s2.sh`: a
  fixture do caso G da 56, com o C2 caindo por um fato público — o
  `relatorio.mjs` conta as linhas do `inventario.txt` com `split("\n")`, e o
  separador no fim deixa um `""` no array, o que a documentação do
  `String.prototype.split` diz. `proof_prepare --infra`: o `infra.sh` do payload
  sob prova provisiona a infra do prefixo, a rede vai para o `.env` (fora do git),
  o app entra nela, e a limpeza do helper derruba tudo; o antes e depois da infra
  compartilhada fica igual em todas as saídas. `TEXTO=<rev>` e `PENSAMENTO=<nível>`
  como na 63; `CAIDO=fechada` derruba o C1 da 001 fechada, e não o C2.
- Implementação · verde, com o pensamento padrão do omp: `s2.out` e `s2-2.out`,
  código `0`. O primeiro `--reverify` sai `1` com `gates:C2, gates:C3`; o piloto
  carrega o `anvil-research`, commita a pesquisa com a URL do MDN, abre a rodada 2
  no ticket 01, o implementer corrige, e o último `--reverify` sai `1` com só
  `gates:C3`; a spec para sem archive nem merge, o C3 fica aberto e a pergunta
  dele está em "o que ainda espera decisão". `s2-fechada.out` e `s2-off.out`
  (código `1`) chegam ao mesmo desfecho, mas o checker não rodou no primeiro
  `--reverify` (o caminho dele, abaixo), e a saída mista não foi vista.
- Implementação · o vermelho não reproduz: com o texto de `f0becd1`, as onze
  sessões que chegaram ao `--reverify` misto pesquisaram — `s2-red-1.out` a
  `s2-red-4.out` (pensamento padrão), `s2-red-low-1.out`, `s2-red-minimal-1.out`,
  `s2-red-minimal-2.out` e, com o C1 da spec fechada caído, `s2-red-fechada-1.out`
  a `s2-red-fechada-3.out`; todas com código `0`, ou `1` por falha alheia à
  pesquisa (a pesquisa sem URL em `s2-red-4` e `s2-red-fechada-2`).
  `s2-red-low-2.out` deu `3`, inválida, e foi repetida por `s2-red-low-1.out`. Com
  o pensamento `off`, nenhuma das seis (`s2-red-off-1.out` a `s2-red-off-6.out`)
  chegou ao `--reverify`: cinco recusaram na largada, pela falta do comando de
  verificação ou pela linha `handoff` do `stage.sh`, e uma parou por não achar o
  checker. O `claude-sonnet-4-5` resolve a ambiguidade do texto antigo a favor da
  pesquisa; a prova mostra que o texto novo segue o caminho do `CHECK:` caído, e
  não que a mudança é necessária. A caixa da prova fica desmarcada por essa parte.
- Observação · o comando de "A evidência" copia o checker de
  `~/.claude/skills/anvil-bench/unlazy/scripts/.`, que o helper não liga: em
  `out-off/` e `out-fechada/` o modelo rodou os testes direto no lugar do checker,
  e em `out-red-off-2/` parou. É a mesma observação do ticket 05, e o B1 do ticket
  09 depende dela.
- Observação · em `out-red-low-2/` o agente da pesquisa, um item do `task`,
  respondeu com `anthropic/claude-haiku-5-5`, e o helper deu `3`: o modelo de um
  subagente pode não ser o pedido mesmo com o fallback desligado.
