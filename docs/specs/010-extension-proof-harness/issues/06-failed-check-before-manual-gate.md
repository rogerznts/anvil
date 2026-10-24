# 06: O `CHECK:` caído vale antes do gate manual aberto

**Blocked by:** 02, 04, 10

**Status:** resolved
**Review:** round=1; sha=5a46779; scope=full; verdict=pass; p1=none

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
- [x] Prova S2 pelo helper, com a infra isolada, num diretório novo de
      `workspace/`, sobre a fixture de `workspace/56-manual-gate-rule/`, com
      `/skill:anvil-auto` no primeiro turno e uma saída mista: o vermelho, com o
      texto de antes, para sem pesquisar; o verde pesquisa no caminho do `CHECK:`
      caído e, quando só o gate manual sobra, para com a pergunta dele. O código do
      helper sai nas saídas, e prova inválida se repete. O vermelho é limite
      aceito pelo operador (ver `## Comments`); só o verde é exigido.
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
- Review round=1 · P2 (Standards): o ticket fica `resolved` com a caixa da prova S2 desmarcada, e a guarda de merge lê só o `Status:` — a spec fecha sem prova vermelha, e a prova mostra que o texto novo segue o caminho do `CHECK:` caído, mas não que a mudança altera o comportamento.
- Review round=1 · P3 (Standards): a precedência do `CHECK:` caído aparece em cinco lugares do `anvil-auto` (`SKILL.md:501-503`, `515-516`, `521-525`, `724`, `826`), contra a fonte única do `anvil-writing-for-agents/SKILL.md:78` e o "aponta para o `GATE.md`" do critério 2; o excesso está no item da linha 521 — se a precedência mudar e um dos cinco ficar para trás, o piloto lê duas regras contrárias.
- Review round=1 · P3 (Standards): o `## Comments` cita "o B1 do ticket 09" e "o caso G da 56" sem glosa — quem lê abre o ticket 09 e o `workspace/56-manual-gate-rule/` para saber se a dependência importa.
- Review round=1 · P3 (Standards): o cabeçalho do `s2.sh` (linhas 18-19) descreve o vermelho como "a spec para sem pesquisar", e o vermelho não tem conferência própria — quem abre só um `s2-red-*.out` lê o "código do helper: 0" como prova vermelha aprovada, quando ele mostra que a hipótese do vermelho não se confirmou.
- Review round=1 · P3 (Standards): "as onze sessões… pesquisaram" enumera dez arquivos, e "todas com código `0`, ou `1`" só vale sem o `s2-red-low-2.out`, que saiu `3` — quem confere arquivo por arquivo acha dez nomes e um código `3` fora da frase.
- Review round=1 · P2 (Spec): o vermelho da saída mista não foi visto ("o vermelho, com o texto de antes, para sem pesquisar", critério 3 e `spec.md:304`), e o ticket está `resolved` — nada mostra que o texto antigo erra, a guarda deixa a spec fechar com o critério aberto, e aceitar o limite deveria ser escolha declarada do operador.
- Review round=1 · P2 (Spec): o `anvil-auto` repete a condição pela metade: o `GATE.md` diz "o gate com `CHECK:` que cai … ou o checker que não roda … haja ou não gate manual", e as cópias em `SKILL.md:501-503`, `521-523`, `724` e `826` dizem só "sem `CHECK:` caído" — com o checker fora do ar e o C3 aberto, as linhas 724 e 826 classificam a parada como decisão, sem pesquisa, contra o `GATE.md`.
- Review round=1 · P3 (Spec): "`s2-red-low-2.out` … foi repetida por `s2-red-low-1.out`" — as duas rodaram em paralelo, e a `low-1` terminou antes da `low-2`; a regra de repetir a prova inválida está atendida no mérito, mas quem lê pensa que houve uma repetição feita depois do código `3`.
- Review round=1 · P3 (Spec): em `s2-fechada` o checker não rodou nenhuma vez (`out-fechada/passos`: `P D I 01`), e não só "no primeiro `--reverify`" — o lado "numa fechada" da regra nova não tem observação verde, só foi visto com o texto antigo.
- Operador · o vermelho da saída mista fica como limite aceito: com o texto
  antigo, o `claude-sonnet-4-5` já resolvia a ambiguidade a favor da pesquisa, e
  medir com outro modelo provaria o modelo, não o payload. O critério da prova
  passa a exigir só o verde, que a rodada 2 refaz com o texto novo.
- Operador · reaberto para a rodada 2, pelo P2 (Spec) da rodada 1: o critério 2
  pede que o `anvil-auto` aponte para o `GATE.md` em vez de repetir a regra, e as
  cópias da precedência no `anvil-auto` perderam o "checker que não roda" — com o
  checker fora do ar e o gate manual aberto, o `anvil-auto` para por decisão, sem
  pesquisa, contra o `GATE.md`. A rodada 2 tira as cópias e deixa o `anvil-auto`
  só apontando para a regra do `GATE.md`, e refaz o verde da S2 com o texto novo.
  Espera o ticket 10, para que o checker que a S2 roda seja o desta árvore, com o
  `anvil-bench` declarado como dependência da prova.
- Implementação rodada 2 · no `anvil-auto`, as quatro cópias da precedência
  saíram: o parágrafo do `PASS` segue "Pesquisa antes de travar", "menos quando a
  regra do `GATE.md` dá à saída do `--reverify` a spec parada por decisão"; a
  lista do `--reverify` do bench passou a ter um item por desfecho do `GATE.md` —
  a saída que vale o `PASS`, o `FAIL` no teto e a spec parada por decisão —, com o
  desfecho tirado "só dela"; a pergunta formulada do gate manual vale para cada
  gate que a regra manda para "o que ainda espera decisão"; e "Pesquisa antes de
  travar" e "Parada" citam "a spec que a regra do `GATE.md` deixa parada por
  decisão no `--reverify`". Nenhuma frase do `anvil-auto` diz mais quando um
  `CHECK:` caiu, então o checker que não roda segue o `FAIL` no teto pelo
  `GATE.md`. O `GATE.md` não mudou.
- Implementação rodada 2 · prova em `workspace/68-failed-check-manual-gate-r2/s2.sh`,
  a S2 de `workspace/64-failed-check-manual-gate/` sobre a mesma fixture do caso G
  — o caso da 56 com o C2, de `CHECK:`, e o C3, manual, no ledger da 002 —, sem o
  caminho do texto antigo e com `proof_prepare --infra --dep anvil-bench --dep
  anvil-docs`, as duas skills que o `anvil-auto` e o `GATE.md` chamam por
  `~/.claude/skills/` nesta saída (o checker e o `roadmap.sh`). Conferência nova: o
  `--reverify` copiou o checker por um caminho que existe e resolve para o
  `anvil-bench` desta árvore.
- Implementação rodada 2 · verde: `s2.out`, código `0` do helper, todo de
  `anthropic/claude-sonnet-4-5`. O primeiro `--reverify` sai `1` com
  `gates:C2, gates:C3`, pelo checker de `~/.claude/skills/anvil-bench/unlazy/scripts/.`;
  o piloto commita a pesquisa com a fonte do MDN, abre a rodada 2 no ticket 01, o
  implementer corrige, e o último `--reverify` sai `1` com só `gates:C3`; a 002 para
  sem archive nem merge, e "o que ainda espera decisão" pergunta quem confere o C3.
- Implementação rodada 2 · com o C1 da 001 fechada caído (`CAIDO=fechada`), as duas
  saídas deram `1` por falha alheia à regra, e nenhuma é verde: nas duas, o primeiro
  `--reverify` sai misto (`gates:C1, gates:C3`), o checker é o desta árvore, o
  piloto pesquisa e o C3 fica aberto. Em `s2-fechada.out`, o piloto foi à pesquisa
  sem commitar o ledger que o checker reescreveu, e o `frontier.sh` parou com
  `halt` de árvore suja depois da rodada 2, sem o segundo `--reverify` nem o
  relatório. Em `s2-fechada-2.out`, a pesquisa saiu sem URL, e a spec parou pela
  verificação, com o relatório citando a pesquisa e perguntando pelo C3; o agente da
  pesquisa respondeu com `anthropic/claude-haiku-5-5`, o que o helper lista e não
  invalida.
- Observação rodada 2 · o "commite no branch o que mudou na pasta da spec" do
  `--reverify` vem depois da lista de desfechos, e o `FAIL` no teto manda para
  "Pesquisa antes de travar" antes dele: em `s2-fechada.out` o ledger ficou fora de
  commit e o `frontier.sh` parou a execução. A ordem é anterior a este ticket.
