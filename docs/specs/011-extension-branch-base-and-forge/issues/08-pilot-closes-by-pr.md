# 08: O piloto fecha por PR pelo `anvil-open-pr` e confere a árvore depois do push

**Blocked by:** 05, 07

**Status:** resolved

**What to build:** o piloto decide entre PR e merge local pelo `forge:` do
resolvedor e pelas rules, e fecha por PR pelo `/anvil-open-pr`, nos dois forges. A
conferência da árvore depois do push da linha `PR:`, o P2 do ticket 04 da 009,
ganha prova: o que ficou fora de commit para a execução antes da volta ao branch
base.

- [x] Sem remoto ou com `forge: nenhum`, merge local; com forge e rules que não
      tiram o PR, fecha pelo `/anvil-open-pr`; uma rule que diz que o projeto fecha
      sem PR continua valendo.
- [x] Depois do PR, a linha `PR:` é commitada e enviada ao remoto, a árvore é
      conferida, e só então o piloto volta ao branch base.
- [x] Prova S2 pelo helper, com `--remote --forge` e `/skill:anvil-auto`, num
      diretório novo de `workspace/`, com `workspace/55-auto-clean-tree/` como prior
      art: fixture GitHub (o log mostra o `gh pr create` para o branch base, a
      linha `PR:` chega ao bare, a entrada fica parada esperando o merge do PR e o
      piloto volta ao branch base); um hook que deixa arquivo fora de commit depois
      do push da linha `PR:` (a execução para sem voltar ao branch base, e o branch
      base não recebe o arquivo). O vermelho da árvore suja é medido com o texto de
      antes do ticket 04 da 009.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · no "Fechamento" do `anvil-auto`, a decisão roda o
  `resolve-git.sh` da instalação de usuário no lugar do `git remote`: com
  `refusal:`, a spec fica parada com as linhas no motivo (a "Parada" ganhou o caso);
  com `forge: nenhum`, merge local, mesmo com remoto e com o perfil falando de PR;
  com `github` ou `gitea`, o perfil e as rules decidem como antes. A frase da guarda
  cita o `gh pr create` ao lado do `tea pr create` (a guarda já confere os dois). No
  "PR", o push vai ao `origin`, o que o resolvedor lê, e o texto diz que o
  `anvil-open-pr` abre no forge do resolvedor, com `gh` ou `tea`. Saiu a frase "sem
  responsável indicado nas rules, o PR sai sem responsável": desde o ticket 05 o
  `anvil-open-pr` não pergunta o responsável (é `@me` no `gh`, o `user` do login no
  `tea`), e a frase contradizia o que a skill faz. O manual `anvil-omp` acompanha.
- Implementação · prova em `workspace/76-pilot-closes-by-pr/s2.sh`, pelo helper com
  `--remote --forge --dep anvil-docs`, `claude-sonnet-4-5`, retomada no branch da
  spec 001 pronta para fechar, base `master`, origin com a URL do forge e o push no
  bare. Três casos, todos verdes com código `0` do helper:
  - `github` (`s2-github.out`): sem `## Git`, origin `https://github.com/acme/loja.git`;
    o resolvedor roda depois do archive e antes do `git push -u origin`, o piloto lê o
    `skill://anvil-open-pr`, um `gh pr create --repo acme/loja --base master --head
    feature/001-conta-linhas`, a linha `PR:` com a URL é commitada e chega ao bare,
    `git status --porcelain` vazio depois do push e só então `git checkout master`; a
    sessão termina no master, a `conta-linhas` fica `stopped` (arquivada no branch),
    a `ultima-linha`, que depende dela, `pending`, e o relatório no master traz a URL.
  - `suja` (`s2-suja.out`): a fixture do github com um `post-receive` no bare que, no
    push que traz a linha `PR:`, deixa o `sobra.txt` na raiz da fixture; o
    `git status --porcelain` depois do push o mostra, nenhum checkout do master, a
    sessão termina no branch da 001 com o `sobra.txt` fora de commit, o master como a
    fixture o deixou e nenhum commit com o arquivo.
  - `nenhum` (`s2-nenhum.out`): origin `https://git.loja.example/acme/loja.git` e
    `forge: nenhum` declarado, nenhuma rule tirando o PR; o resolvedor roda e o piloto
    fecha por merge local no master, sem `git push`, sem ler o `anvil-open-pr` e sem
    `pr create`.
- Implementação · vermelhos. `suja` com o texto deste ticket sem os trechos do
  67f6c9b (o ticket 04 da 009), em `red-suja.patch`, aplicado na árvore de trabalho e
  revertido depois: o piloto fez o `git commit … && git push` da linha `PR:`, voltou
  ao master com `git checkout master` levando o `sobra.txt` para a árvore do master,
  e só lá parou, pela conferência da "Parada"; 2 falhas, código `1`
  (`s2-red-suja.out`). O master não ganhou commit com o arquivo, mas ficou com ele na
  árvore. `nenhum` com o texto de dcbb8e3: o piloto rodou o `git remote`, empurrou o
  branch e leu o `anvil-open-pr`, que parou em `forge: nenhum`, e então fez o merge
  local; 2 falhas, código `1` (`s2-red-nenhum.out`). `github` com o texto de dcbb8e3:
  o caminho do PR já funcionava, e a única falha é a decisão sem o resolvedor antes
  do push; código `1` (`s2-red-github.out`).
- Implementação · o `roadmap.sh` dá o motivo "arquivada no branch … e ainda sem merge
  na main" num projeto com `master`: o estado está certo, só o texto fixa a `main`.
  Fora deste ticket.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0 (`workspace/76-pilot-closes-by-pr/verify.out`).
