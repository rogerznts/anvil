# 06: O `CHECK:` caído vale antes do gate manual aberto

**Blocked by:** 02, 04

**Status:** ready-for-agent

**What to build:** uma saída do `--reverify` com gate manual desta spec aberto e
gate de `CHECK:` caído segue o caminho do `CHECK:` caído, com pesquisa, em vez de
parar a spec sem olhar a regressão. Só quando nenhum `CHECK:` cai, o gate manual
aberto desta spec deixa a spec parada por decisão. A regra mora no `GATE.md`.

- [ ] Em "Sob o piloto automático" do `GATE.md`: a saída com algum gate de
      `CHECK:` caído, nesta spec ou numa fechada, segue o caminho do `CHECK:`
      caído, haja ou não gate manual desta spec aberto; sem `CHECK:` caído, o gate
      manual aberto desta spec deixa a spec parada por decisão; a pergunta do gate
      manual vai para o relatório nos dois casos.
- [ ] O `anvil-auto` dispensa a pesquisa só quando nenhum `CHECK:` caiu, e aponta
      para o `GATE.md` em vez de repetir a regra.
- [ ] Prova S2 pelo helper, com a infra isolada, num diretório novo de
      `workspace/`, sobre a fixture de `workspace/56-manual-gate-rule/`, com
      `/skill:anvil-auto` no primeiro turno e uma saída mista: o vermelho, com o
      texto de antes, para sem pesquisar; o verde pesquisa no caminho do `CHECK:`
      caído e, quando só o gate manual sobra, para com a pergunta dele. O código do
      helper sai nas saídas, e prova inválida se repete.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
