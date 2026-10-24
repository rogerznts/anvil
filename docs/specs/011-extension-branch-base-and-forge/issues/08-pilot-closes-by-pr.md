# 08: O piloto fecha por PR pelo `anvil-open-pr` e confere a árvore depois do push

**Blocked by:** 05, 07

**Status:** ready-for-agent

**What to build:** o piloto decide entre PR e merge local pelo `forge:` do
resolvedor e pelas rules, e fecha por PR pelo `/anvil-open-pr`, nos dois forges. A
conferência da árvore depois do push da linha `PR:`, o P2 do ticket 04 da 009,
ganha prova: o que ficou fora de commit para a execução antes da volta ao branch
base.

- [ ] Sem remoto ou com `forge: nenhum`, merge local; com forge e rules que não
      tiram o PR, fecha pelo `/anvil-open-pr`; uma rule que diz que o projeto fecha
      sem PR continua valendo.
- [ ] Depois do PR, a linha `PR:` é commitada e enviada ao remoto, a árvore é
      conferida, e só então o piloto volta ao branch base.
- [ ] Prova S2 pelo helper, com `--remote --forge` e `/skill:anvil-auto`, num
      diretório novo de `workspace/`, com `workspace/55-auto-clean-tree/` como prior
      art: fixture GitHub (o log mostra o `gh pr create` para o branch base, a
      linha `PR:` chega ao bare, a entrada fica parada esperando o merge do PR e o
      piloto volta ao branch base); um hook que deixa arquivo fora de commit depois
      do push da linha `PR:` (a execução para sem voltar ao branch base, e o branch
      base não recebe o arquivo). O vermelho da árvore suja é medido com o texto de
      antes do ticket 04 da 009.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
