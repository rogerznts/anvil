# 07: O piloto e o `new-spec.sh` usam o branch base

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** o piloto automático começa, retoma, fecha por merge local,
confere o merge e abre a entrada nova a partir do branch base que o resolvedor dá, e
não da palavra `main`. O `new-spec.sh` só cria o branch da spec saindo do branch
base.

- [ ] O `stage.sh` imprime o branch base numa linha própria, e a largada e a
      retomada do piloto comparam o branch atual com ela.
- [ ] Todo `git checkout main`, `rev-list <branch>..main`, `merge-base … main` e
      `checkout -B <branch> main` do piloto passa a usar o branch base; com o
      resolvedor recusando, a largada recusa com o motivo dele.
- [ ] O `new-spec.sh` recusa, com o motivo e antes de reservar o número, quando o
      checkout atual não é o branch base.
- [ ] Prova S1 do `new-spec.sh`, num diretório novo de `workspace/`: fora do branch
      base, recusa sem reservar número nem criar branch; no branch base `master`,
      cria.
- [ ] Prova S2 pelo helper, com `/skill:anvil-auto`, sobre a fixture de
      `workspace/57-merge-check/` com o branch base `master`: o piloto começa,
      fecha por merge local no `master` e volta a ele; a conferência do merge
      compara com o `master`. O código do helper sai nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
