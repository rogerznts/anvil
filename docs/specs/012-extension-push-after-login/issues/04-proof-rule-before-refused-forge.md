# 04: Prova: a rule decide antes do forge recusado

**Blocked by:** 03

**Status:** ready-for-agent

**What to build:** a A36 do acompanhamento. A US 39 da 011 (a rule que manda fechar
sem PR não para num forge não resolvido) tem verde e nenhum vermelho. Esta prova roda
sobre o fechamento já com o texto dos tickets 02 e 03: num Gitea sem a seção
`## Git`, o resolvedor dá `refusal: forge:`, e a rule do projeto manda fechar por
merge local. A spec fecha por merge local no branch base. Se a prova mostrar que o
texto não faz isso, corrija o fechamento do piloto neste ticket.

- [ ] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge`, num
      diretório novo de `workspace/`, com `workspace/81-pilot-base-and-rule/` como
      prior art: fixture Gitea sem a seção `## Git`, com a `refusal: forge:`, e uma
      rule que manda fechar por merge local. A spec fecha por merge local no branch
      base, sem push, sem `pr create` no `forge.jsonl` e sem o `resolve-git.sh --pr`.
- [ ] Vermelho: o payload de `179bc78`, de antes do ticket 11 da 011, em que a
      spec fica parada pela recusa de forge. O código do helper sai nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
