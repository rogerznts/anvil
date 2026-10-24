# 06: PR rápido e limpeza de branches pelo branch base

**Blocked by:** 05

**Status:** ready-for-agent

**What to build:** o `anvil-open-fast-pr` consulta o resolvedor antes de qualquer
`git stash`, cria o branch novo a partir do branch base e abre o PR como o
`anvil-open-pr`, nos dois forges. O `anvil-prune-branches` atualiza o branch base,
e não uma `main` fixa.

- [ ] O PR rápido roda o resolvedor antes do stash; com recusa, para com o motivo, e
      nada é guardado.
- [ ] O branch novo sai do branch base, qualquer que seja o tipo, hotfix
      incluído, e o PR vai para ele, num PR só.
- [ ] A criação do PR segue a do `anvil-open-pr`, nos dois forges, sem cópia
      divergente das regras de login, repositório, rótulo e linha `PR:`.
- [ ] A limpeza atualiza o branch base dado pelo resolvedor.
- [ ] Prova S2 pelo helper, com `--remote --forge`, num diretório novo de
      `workspace/`: `/skill:anvil-open-fast-pr` sem branch base resolvível recusa, e
      `git stash list` fica vazio; com `master` e mudança pendente, o branch sai do
      `master` e o log mostra o `pr create` com essa base;
      `/skill:anvil-prune-branches` em fixture com `master` atualiza o `master` e
      tira o branch cujo remoto sumiu.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
