# 05: Prova: limpeza e bench seguem com `refusal: forge:`

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** a A37 do acompanhamento. A US 36 da 011 diz que a limpeza de
branches e o bench não param por uma recusa de forge, porque só precisam do branch
base. Nenhuma prova tem vermelho para isso. Esta prova mostra a limpeza atualizando
o branch base e o bench escrevendo a seção `## Git` sem a linha `forge:`, com o
resolvedor dando `refusal: forge:`. Se a prova mostrar que o texto não faz isso,
corrija a skill neste ticket.

- [ ] Prova S2 pelo helper, com `/skill:anvil-prune-branches` e `--remote`, num
      diretório novo de `workspace/`, com `workspace/74-fast-pr-prune/` como prior
      art: fixture com remoto num host desconhecido e sem a seção, com a
      `refusal: forge:`. A limpeza segue e atualiza o branch base.
- [ ] Prova S2 pelo helper do bench escrevendo a seção `## Git`, com
      `workspace/78-bench-git-section/` como prior art, com a `refusal: forge:`: a
      seção sai com a linha `branch base:` e sem a linha `forge:`.
- [ ] Vermelho das duas: o payload de `179bc78`, de antes do ticket 11 da 011, em
      que a recusa para a skill. O código do helper sai nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
