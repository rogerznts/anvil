# 07: O piloto e o `new-spec.sh` usam o branch base

**Blocked by:** 01

**Status:** resolved

**What to build:** o piloto automático começa, retoma, fecha por merge local,
confere o merge e abre a entrada nova a partir do branch base que o resolvedor dá, e
não da palavra `main`. O `new-spec.sh` só cria o branch da spec saindo do branch
base.

- [x] O `stage.sh` imprime o branch base numa linha própria, e a largada e a
      retomada do piloto comparam o branch atual com ela.
- [x] Todo `git checkout main`, `rev-list <branch>..main`, `merge-base … main` e
      `checkout -B <branch> main` do piloto passa a usar o branch base; com o
      resolvedor recusando, a largada recusa com o motivo dele.
- [x] O `new-spec.sh` recusa, com o motivo e antes de reservar o número, quando o
      checkout atual não é o branch base.
- [x] Prova S1 do `new-spec.sh`, num diretório novo de `workspace/`: fora do branch
      base, recusa sem reservar número nem criar branch; no branch base `master`,
      cria.
- [x] Prova S2 pelo helper, com `/skill:anvil-auto`, sobre a fixture de
      `workspace/57-merge-check/` com o branch base `master`: o piloto começa,
      fecha por merge local no `master` e volta a ele; a conferência do merge
      compara com o `master`. O código do helper sai nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o `stage.sh` imprime, logo depois da linha `branch`, a linha
  `base: <branch>`, do `resolve-git.sh` da instalação de usuário
  (`~/.claude/skills/anvil-docs/scripts/resolve-git.sh`); com o resolvedor
  recusando, `base: none` e uma linha `base_refusal:` por motivo dele. A etapa da
  `anvil-plan` não depende dela. No piloto, o passo 4 da largada recusa com as
  linhas `base_refusal` e, senão, compara a `branch` com a `base`; os comandos
  usam `<base>`, e a prosa diz "branch base" no lugar da `main`. O manual
  `anvil-omp` acompanha.
- Implementação · o `new-spec.sh` roda o resolvedor pelo caminho relativo a ele
  (`../../anvil-docs/scripts/resolve-git.sh`), que vale no payload e na instalação
  de usuário, logo depois de achar a raiz e antes do slug e da reserva; recusa com
  `erro:` no stderr e saída `2`.
- Implementação · provas em `workspace/75-pilot-on-base/`. `s1.sh`, no bash 5.2 e
  no `/bin/bash` 3.2: fora do branch base (`wip` com `master`), com o resolvedor
  recusando (`main` e `master`) e fora da `develop` declarada, recusa sem reserva,
  branch nem pasta; no `master` e na `develop`, cria. Verde em `s1.out`; o
  vermelho, com o `new-spec.sh` de 66fb49c, tem 18 falhas (`s1-red.out`). `s2.sh`,
  pelo helper com `--remote --forge --dep anvil-docs`, sobre a fixture do caso V da
  57 com o `master`, sem a seção `## Git` e o origin no bare: código `0`
  (`s2.out`) — o `stage.sh` dá `base: master`, a conferência roda
  `git rev-list --count feature/001-conta-linhas..master`, o merge preparado passa
  na verificação e é commitado no `master`, e a sessão termina no `master`, sem
  `main` criada. O vermelho, com o texto de 66fb49c, saiu `1` (`s2-red.out`), mas
  só nas duas conferências da linha `base`: o modelo viu o `master` e o usou no
  lugar do `git checkout main` do texto, como no `prune` do ticket 06.
- Implementação · o resolvedor não separa as recusas: num Gitea sem login do `tea`
  casando, ele recusa inteiro, e então a largada do piloto e o `new-spec.sh`
  recusam também, mesmo com o branch base inequívoco. É o contrato do ticket 01
  ("com recusa não sai nenhuma outra linha"), e mudar isso é decisão do operador.
