# 04: Prova: a rule decide antes do forge recusado

**Blocked by:** 03

**Status:** resolved

**What to build:** a A36 do acompanhamento. A US 39 da 011 (a rule que manda fechar
sem PR não para num forge não resolvido) tem verde e nenhum vermelho. Esta prova roda
sobre o fechamento já com o texto dos tickets 02 e 03: num Gitea sem a seção
`## Git`, o resolvedor dá `refusal: forge:`, e a rule do projeto manda fechar por
merge local. A spec fecha por merge local no branch base. Se a prova mostrar que o
texto não faz isso, corrija o fechamento do piloto neste ticket.

- [x] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge`, num
      diretório novo de `workspace/`, com `workspace/81-pilot-base-and-rule/` como
      prior art: fixture Gitea sem a seção `## Git`, com a `refusal: forge:`, e uma
      rule que manda fechar por merge local. A spec fecha por merge local no branch
      base, sem push, sem `pr create` no `forge.jsonl` e sem o `resolve-git.sh --pr`.
- [x] Vermelho: o payload de `179bc78`, de antes do ticket 11 da 011, em que a
      spec fica parada pela recusa de forge. O código do helper sai nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: o texto do fechamento já faz o que a prova pede, e nada no
  payload mudou. No "Fechamento" do `anvil-auto`, o passo 2 lê as rules inteiras e,
  quando uma diz que o projeto fecha sem PR, fecha por merge local "sem consultar o
  forge: as linhas `forge:` e `refusal: forge:` não contam"; o passo 3, o do
  forge, só vem depois.
- Prova S2 em `workspace/85-pilot-rule-before-refused-forge/s2.sh`: retomada no
  branch da 001 pronta para fechar, origin `https://git.loja.test/acme/loja.git`
  sem a seção `## Git` (o resolvedor dá `base: master`, a `refusal: forge:` e sai
  `2`), a rule do projeto com "`git merge` local no `master`, sem PR", e só o
  master no bare. Verde com o payload de `6d41dcc`, o `HEAD` deste branch com os
  tickets 02 e 03 (`s2.out`): archive no branch, resolvedor sem `--pr` depois dele,
  `git checkout master` e `git merge --no-ff --no-edit`, nenhum
  `resolve-git.sh --pr`, nenhuma leitura do `skill://anvil-open-pr`, nenhum
  `pr create` no `forge.jsonl`, nenhum `git push` e o bare igual ao de antes; o
  `roadmap.sh` dá a conta-linhas `closed`, e o `Estado:` é "fechada, com merge
  local no `master`"; código do helper 0. Vermelho com o payload de `179bc78`
  (`git diff 179bc78 -- anvil` vazio naquele ponto, `s2-red.out`): o resolvedor
  antigo só dá a recusa, o `stage.sh` dá `base: none` com a `base_refusal:`, e o
  piloto recusa a execução já na retomada, pedindo `forge:` na seção `## Git`; a
  spec fica parada sem archive nem merge; 9 falhas, código do helper 1. O vermelho
  para na largada, e não no fechamento, porque antes do ticket 11 da 011 qualquer
  recusa do resolvedor parava as duas. `vendor-sync.sh verify` sai `0`
  (`verify.out`).
