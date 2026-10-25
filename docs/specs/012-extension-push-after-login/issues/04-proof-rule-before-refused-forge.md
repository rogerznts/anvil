# 04: Prova: a rule decide antes do forge recusado

**Blocked by:** 03

**Status:** resolved
**Review:** round=1; sha=5571b01d468eeab71cd1dac5bb76bad6ec517bfe; scope=full; verdict=pass; p1=none

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
- Review round=1 · P3 (Spec): o vermelho para na largada (`stage.sh` com `base: none`), e não no fechamento, e por isso não isola a ordem "rule antes do forge" — é o vermelho que a spec prescreve e o comentário já declara; nada quebra, mas o leitor não vê nele uma rule perdendo para o forge no fechamento.
- Review round=1 · P3 (Spec): das 9 falhas do vermelho, duas são pré-condições da fixture (o formato antigo do `stage.sh` e do resolvedor), e não comportamento do piloto — o leitor superestima o que o vermelho discrimina no fechamento.
- Review round=1 · P3 (Spec): o `forge.jsonl` sai vazio no verde e no vermelho, e a conferência "sem `pr create`" não tem controle positivo nesta prova — sozinha, ela não distingue "sem chamada" de "falso não armado"; as conferências sem `--pr` e sem `anvil-open-pr` cobrem o caso.
- Review round=1 · P3 (Standards): "ticket 11 da 011" aparece no comentário de prova sem a glosa da diretiva "Citar id sempre com a glosa" — quem lê abre a 011 para saber por que `179bc78` é o vermelho.
- Review round=1 · P3 (Standards): "`vendor-sync.sh verify` sai `0` (`verify.out`)" — o `verify.out` termina em "verify: limpo" e não grava o código de saída; a afirmação depende de quem rodou.
- Review round=1 · P3 (Standards): possível Duplicated Code / Shotgun Surgery no `s2.sh` — `volta_master` repete a forma de `linha_b`, o prefixo `git (-C [^ ]+ )?` aparece cinco vezes, e o parser do `session.jsonl` e os auxiliares de conferência são cópia dos de 81 e 84; uma correção no casamento ou no parser precisa ser feita em cada `s2.sh`.
- Review round=1 · P3 (Standards): o `s2.sh` depende de `../73-open-pr-forges/resumo.py`, e o `--so-fixture` passa pelo `rm -rf "$O"` antes de sair (herdados de 81 e 84) — apagar o 73 deixa o resumo do forge vazio sem falhar, e rodar só a fixture apaga a evidência verde em `out/`.
