# 06: PR rápido e limpeza de branches pelo branch base

**Blocked by:** 05

**Status:** resolved

**What to build:** o `anvil-open-fast-pr` consulta o resolvedor antes de qualquer
`git stash`, cria o branch novo a partir do branch base e abre o PR como o
`anvil-open-pr`, nos dois forges. O `anvil-prune-branches` atualiza o branch base,
e não uma `main` fixa.

- [x] O PR rápido roda o resolvedor antes do stash; com recusa, para com o motivo, e
      nada é guardado.
- [x] O branch novo sai do branch base, qualquer que seja o tipo, hotfix
      incluído, e o PR vai para ele, num PR só.
- [x] A criação do PR segue a do `anvil-open-pr`, nos dois forges, sem cópia
      divergente das regras de login, repositório, rótulo e linha `PR:`.
- [x] A limpeza atualiza o branch base dado pelo resolvedor.
- [x] Prova S2 pelo helper, com `--remote --forge`, num diretório novo de
      `workspace/`: `/skill:anvil-open-fast-pr` sem branch base resolvível recusa, e
      `git stash list` fica vazio; com `master` e mudança pendente, o branch sai do
      `master` e o log mostra o `pr create` com essa base;
      `/skill:anvil-prune-branches` em fixture com `master` atualiza o `master` e
      tira o branch cujo remoto sumiu.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · prova em `workspace/74-fast-pr-prune/`: `s2.sh` por `CASO`
  (`recusa`, `master`, `hotfix`, `prune`), pelo helper com `--remote --forge --dep
  anvil-docs`, código `0` nos quatro (`s2-<caso>.out`). O `hotfix` é a fixture Gitea
  com `develop` declarada, o checkout no `main` e o origin num alias de ssh: o branch
  sai do `develop` do remoto, e o log tem um `tea pr create` só, com `--login`,
  `--repo`, `--output json`, a base `develop` e o `Kind/Hot`. O vermelho, com o texto
  de antes (0ec16d4), saiu `1` em `recusa` (stash, branch novo a partir do `main`,
  commit, push e um `tea labels list` sem `--login` num projeto GitHub), `master` e
  `hotfix` (as duas pararam perguntando os branches estável e de integração), e `0`
  em `prune`: o modelo viu que estava no `master` e o atualizou, sem seguir o
  `git checkout main` do texto (`s2-red-<caso>.out`).
- Implementação · o PR rápido não tem mais cópia própria do PR: depois do push, ele
  carrega o `anvil-open-pr` e o segue desde o Step 0. Nas duas sessões verdes, a
  sessão leu o `skill://anvil-open-pr` e o log mostra as regras dele (`--repo`,
  `--login`, rótulo da lista, responsável). Isso fecha o P2 do ticket 05 sobre a
  linha do README, que já dizia GitHub ou Gitea para o PR rápido.
- Implementação · o fetch e o pull da sessão passam por um ssh de fixture no
  `GIT_SSH_COMMAND`: o `-G` vai ao ssh real com `-F` no config de fixture, e o
  `git-upload-pack` é servido do bare; o push vai ao bare pela URL de push. O
  resolvedor da conferência roda antes da sessão: o git 2.48 ou mais novo cria o
  `origin/HEAD` no fetch, e depois dele a fixture de `recusa` já não é ambígua.
- Implementação · defeito anterior, fora do recorte: a limpeza volta ao branch de
  origem antes do `git branch -d`, e com o upstream sumido o `-d` compara com o
  `HEAD`; partindo de um branch que não é o branch base, o branch já mesclado no
  remoto sai como "not fully merged". A prova parte do `master`.
- Implementação · defeito anterior, fora do recorte: o PR rápido só confere a árvore
  limpa no Step 3, depois do `git stash pop`; com a árvore limpa, o `git stash` não
  guarda nada e o `pop` tira um stash antigo do operador.
- Implementação · no caso `recusa`, a resposta final saiu em inglês, com a fixture
  em pt-BR — desvio do modelo, como no ticket 05.
