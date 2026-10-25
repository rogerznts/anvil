# 07: O piloto e o `new-spec.sh` usam o branch base

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=df3d63e; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Spec): a S2 começa no `feature/001-conta-linhas` e mede a retomada, não a largada no branch base — a comparação `branch` = `base` que leva à entrada, a recusa com `base: none`/`base_refusal` e o `git checkout <base>` + `checkout -B <branch> <base>` depois do `new-spec.sh` ficam sem prova de sessão, e o vermelho só falha nas linhas do `stage.sh`; uma regressão nesses passos da prosa passa verde.
- Review round=1 · P2 (Spec): o `new-spec.sh` recusa em qualquer recusa do resolvedor, inclusive as de forge ("forge não declarado", "nenhum login do tea casa"), e não só fora do branch base — num Gitea próprio sem a seção `## Git` (o ticket 09 ainda não a escreve) ou numa máquina sem `tea`, o `/anvil-to-spec` deixa de criar spec mesmo com fechamento por merge local.
- Review round=1 · P2 (Spec): o manual `anvil-omp` diz que a largada recusa "o projeto cujo branch base o resolvedor não decide", mas o piloto recusa com qualquer `base_refusal`, inclusive de forge e login — quem lê espera largar num projeto com `master` inequívoco e recebe uma recusa sobre o login do `tea`.
- Review round=1 · P2 (Spec): o `new-spec.sh` monta o `RESOLVER` relativo ao `BASH_SOURCE` e roda `cd "$ROOT"` antes de chamá-lo; chamado por caminho relativo de uma subpasta (`bash ../anvil/.claude/skills/anvil-to-spec/scripts/new-spec.sh` a partir de `docs/`), sai `2` com `No such file or directory` — essa chamada funcionava antes; os chamadores documentados usam `~/.claude/...`, absoluto, e não são afetados.
- Review round=1 · P3 (Spec): o `stage.sh` só imprime `base` depois da recusa do tracker e de achar a raiz; com `next: refused` ou fora do git não sai linha `base`, e o passo 4 não diz o que fazer sem ela — sem efeito hoje, porque os passos 1 e 2 recusam antes.
- Review round=1 · P3 (Standards): `ATUAL` em português ao lado de `RESOLVER`, `RESOLVED` e `BASE` em inglês no mesmo hunk do `new-spec.sh` — o resto do arquivo já mistura (`usados`, `RESERVADO`); pesa só na leitura.
- Review round=1 · P3 (Standards): possível Mysterious Name — `RESOLVED` guarda a saída crua do resolvedor, inclusive as linhas `refusal:`, e o nome sugere valor já resolvido a quem mantiver o código.
- Review round=1 · P3 (Standards): o `-h` do `new-spec.sh` imprime o cabeçalho, que não diz que a spec tem de sair do branch base — quem lê o `--help` só descobre pela recusa, que já diz como sair dela.
- Review round=1 · P3 (Standards): possível Duplicated Code — o `new-spec.sh` e o `stage.sh` repetem a leitura do resolvedor (`sed 's/^base: //p'`, o `case "refusal: "*` e a mensagem "não deu o branch base") — se o contrato de saída do `resolve-git.sh` mudar, os dois lugares podem divergir em silêncio.
- Review round=1 · P3 (Standards): possível Divergent Change — o `stage.sh` é da `anvil-plan` e agora chama o resolvedor só para a `anvil-auto`; toda chamada da `anvil-plan` paga o custo, e numa recusa a saída dela leva `base_refusal:`, que o contrato da `anvil-plan/SKILL.md` ("devolve as linhas `spec`, `next`, `reason` e `do`") não explica; a spec pediu esse lugar para a linha.
- Review round=1 · P3 (Standards): o manual `anvil-omp` diz que o branch base é "a `main`, a `master` ou o que a seção `## Git` declara" e omite a detecção por `origin/HEAD`, que dá, por exemplo, uma `develop` não declarada — quem ler espera `main` ou `master` e o piloto parte da `develop`.
