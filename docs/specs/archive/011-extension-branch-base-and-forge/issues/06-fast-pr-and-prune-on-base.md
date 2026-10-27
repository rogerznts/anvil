# 06: PR rápido e limpeza de branches pelo branch base

**Blocked by:** 05

**Status:** resolved
**Review:** round=1; sha=c6548ff; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=9d273c6; scope=diff:c6548ff..9d273c6; verdict=pass; p1=none

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
- Review round=1 · P1 (Spec): o resolvedor roda duas vezes no PR rápido, no Step 0 dele e no Step 0 do `anvil-open-pr`, com o `git fetch origin` do Step 2 no meio, e o git 2.48 ou mais novo cria o `origin/HEAD` nesse fetch (reproduzido no git 2.50.1: `base: main` antes, `base: develop` depois) — num repositório sem `origin/HEAD`, o branch sai de um branch base e o PR vai para outro, ou o resolvedor recusa depois do commit e do push e o branch fica publicado sem PR; "One PR, to `<base>`" fica falso.
- Review round=1 · P2 (Spec): o caso `prune` passou verde também com o texto de antes (`s2-red-prune.out`, código `0`) — a prova não distingue a mudança da limpeza e não pega uma regressão para a `main` fixa.
- Review round=1 · P3 (Spec): o `anvil-prune-branches` deixou de descobrir o remoto por `git remote -v` e passou a usar sempre o `origin`, parando com `remote: none` — um repositório cujo único remoto não se chama `origin` perde a limpeza; coerente com o resolvedor, que só lê o `origin`, mas não declarado no ticket.
- Review round=1 · P3 (Standards): possível Duplicated Code — o Step 0 do PR rápido repete o tratamento do resolvedor do Step 0 do `anvil-open-pr` (recusa, `forge: nenhum`), e o Step 6 manda seguir este desde o Step 0, rodando o resolvedor duas vezes — uma mudança no tratamento de recusa do `anvil-open-pr` deixa a cópia para trás sem aviso.
- Review round=1 · P3 (Standards): no `anvil-prune-branches`, o Step 2 ainda diz "Before anything", depois do Step 1 que roda o resolvedor — o leitor acha "antes de tudo" no segundo passo; a ordem dos passos resolve.
- Review round=1 · P3 (Standards): possível Divergent Change no commit 0a979ec, `feat(anvil-open-fast-pr)` que muda também o `anvil-prune-branches` e o README — um `git log` pelo escopo do prune não acha o commit.
- Review round=1 · P3 (Standards): o último comentário de implementação cita o ticket 05 sem a glosa (o `anvil-open-pr` no GitHub e no Gitea) — quem lê precisa abrir o ticket para saber que a semelhança é a resposta final em inglês.
- Correção do P1 da rodada 1 (5e4958a) · o resolvedor roda uma vez só, no Step 0 do PR rápido, e o Step 6 segue o `anvil-open-pr` com o Step 0 dele tomando o `<base>`, o `<repo>` e o `<login>` de lá, sem rodar o resolvedor de novo. Prova no caso novo `origin-head` de `workspace/74-fast-pr-prune/` — `main` e `develop`, sem `origin/HEAD` local, o HEAD do remoto no `develop`: o resolvedor dá `main` antes do fetch e `develop` depois (`s2.sh --so-fixture`). O vermelho, com o texto de c6548ff, saiu `0` (`s2-red-origin-head.out`): o modelo pulou o Step 0 do `anvil-open-pr` e não rodou o resolvedor de novo, então o defeito era do texto seguido à letra, e não apareceu na sessão. O verde saiu `0` nos casos `origin-head`, `master`, `hotfix` e `recusa`, com uma chamada do resolvedor por sessão; o `prune` não mudou desde a rodada 1.
- Review round=2 · P2 (Spec): o vermelho do `origin-head` saiu `0`, e o `s2.sh` não conta as chamadas do resolvedor — um texto que volte a mandar rodar o resolvedor duas vezes passa na prova enquanto o modelo ignorar a instrução; "uma chamada do resolvedor por sessão" foi contada à mão.
- Review round=2 · P3 (Spec): o Step 6 do PR rápido lista `<base>`, `<repo>` e `<login>` como o que o Step 0 do `anvil-open-pr` toma, mas não o `forge:`, pelo qual o Step 6 do `anvil-open-pr` escolhe o bloco de comando ("Run the block of the resolver's forge") — quem seguir à letra deduz o forge do contexto; hoje nada quebra.
- Review round=2 · P3 (Standards): possível Data Clumps no repasse do Step 6 — a resposta do resolvedor é um grupo (`base`, `forge`, `repo`, `login`) e a correção repassa só parte dele, e a nota deixou de citar o forge — o mesmo achado do eixo Spec acima; a correção é pôr `<forge>` nos dois lugares.
- Review round=2 · P3 (Standards): o Duplicated Code da rodada 1 mudou — a execução dupla sumiu, e a cópia do tratamento do resolvedor no Step 0 do PR rápido ficou como o único tratamento executado no fluxo, justificada por vir antes do stash — se o tratamento de recusa mudar no `anvil-open-pr`, a cópia pode ficar para trás. Os outros achados da rodada 1 sobre o `anvil-prune-branches` e o comentário do ticket 05 continuam como estão.
