# 05: O `anvil-open-pr` abre o PR no GitHub e no Gitea

**Blocked by:** 01, 02, 04

**Status:** resolved
**Review:** round=1; sha=25e1a15; scope=full; verdict=pass; p1=none

**What to build:** o `anvil-open-pr` lê o resolvedor no começo e abre o PR no forge
dele, para o branch base, com o texto, o rótulo e a linha `PR:` escritos uma vez e
só o bloco de comando mudando entre `gh` e `tea`. O par branch estável e de
integração some; o hotfix abre um PR só.

- [x] Com o resolvedor recusando, a skill para com o motivo dele e não chama o
      CLI.
- [x] GitHub: `gh pr create` com `--base` no branch base, `--head`, título, corpo,
      rótulo, `--assignee @me` e `--repo` do resolvedor; a URL vem do stdout.
- [x] Gitea: `tea pr create --login <login> --repo <repo> --output json`, com a
      base no branch base; a URL vem do campo `url`.
- [x] O rótulo é escolhido entre os que o forge lista, pelo `gh label list` ou pelo
      `tea labels list --login --repo`.
- [x] Cada ticket da spec ganha a linha `PR:` com a URL, uma linha a mais quando já
      tem uma.
- [x] O hotfix abre um PR só, para o branch base.
- [x] Prova S2 pelo helper, com `--remote --forge` e as dependências declaradas,
      num diretório novo de `workspace/`, com `/skill:anvil-open-pr`: fixture GitHub
      com `master` (o log mostra `gh pr create --base master`, e os tickets ganham a
      linha `PR:`); fixture Gitea com `develop` declarada e remoto por alias de ssh
      via `GIT_SSH_COMMAND` (o log mostra `--login`, `--repo` e a base `develop`);
      um hotfix (um `pr create` só); Gitea com dois logins casando (recusa, sem
      `pr create` no log). O código do helper sai nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · prova em `workspace/73-open-pr-forges/`: `s2.sh` por `CASO`
  (`github`, `gitea`, `hotfix`, `dois-logins`), pelo helper com `--remote --forge
  --dep anvil-docs`, código `0` nos quatro (`s2-<caso>.out`); o vermelho, com o texto
  de antes (2458cc6), saiu `1` nos quatro (`s2-red-<caso>.out`): o GitHub chamou
  `tea labels list`, o Gitea não passou `--login`, o hotfix anunciou dois PRs, e os
  dois logins não pararam. `s1.sh` prova a mudança do helper abaixo, no bash do
  PATH e no `/bin/bash` 3.2.
- Implementação · o helper mudou: com `--remote`, a fixture que já tem o bare como
  URL de push do `origin` fica como está. Sem isso a prova não se fazia: o
  `proof_session` ligava o bare como `origin`, e o resolvedor recusa o `origin` em
  caminho local com forge declarado, ou dá `forge: nenhum` sem declaração. A prova dá
  ao `origin` a URL do forge e o `pushurl` no bare.
- Implementação · o responsável é quem abre o PR nos dois forges, escrito uma vez:
  `@me` no `gh`, e no `tea` o `user` do login do resolvedor, do `tea login list
  --output json`; o texto de antes perguntava, e a sessão parava ali.
- Implementação · a linha do README das skills de PR diz GitHub ou Gitea para as
  duas; o `anvil-open-fast-pr` só passa a servir o GitHub no ticket 06.
- Implementação · o `anvil-auto` ainda diz, no fechamento por PR, que a base é a
  `main` e que, sem responsável nas rules, o PR sai sem responsável; o
  `anvil-open-pr` agora põe quem abre como responsável. É do ticket 08 (o piloto
  fecha por PR pelo `anvil-open-pr`).
- Implementação · o `s1.sh` de `workspace/59-proof-helper/` continua com as 2
  falhas de antes, do roster do `dev-link` depois da renomeação, já vistas antes do
  ticket 04 em `workspace/72-forge-logins-labels/s1-anteriores.out`; os de 61, 67 e
  72 passam (`s1-anteriores.out`).
- Review round=1 · P2 (Spec): a linha do README já diz "PR no GitHub ou no Gitea, para o branch base" também para o `anvil-open-fast-pr`, que até o ticket 06 (PR rápido e limpeza pelo branch base) é só `tea` com o par estável e integração — quem ler o README neste branch roda o PR rápido no GitHub e ele falha; vira mentira publicada só se o 06 sair do recorte.
- Review round=1 · P2 (Spec): a regra nova do helper — a fixture com o bare como URL de push do `origin` fica como está — está só no cabeçalho do `proof.sh` e no `anvil-sync/SKILL.md` — quem escreve outra prova com forge precisa conhecê-la para não esbarrar na recusa do `origin`.
- Review round=1 · P2 (Standards, observação ao eixo Spec): o `s2.sh` não confere o responsável no Gitea (o `user` do login, `assignee=prova` no resumo) — uma regressão do Step 5 no Gitea passa sem a prova ver.
- Review round=1 · P3 (Spec): no Gitea, o responsável passou a ser quem abre o PR, e a skill deixou de perguntar — quem atribuía o PR a outra pessoa perde a escolha; a spec cobre com "o responsável […] fica escrito uma vez".
- Review round=1 · P3 (Spec): no caso `gitea`, a resposta final saiu em inglês, com a fixture em pt-BR — desvio do modelo, não do texto; o operador às vezes recebe o chat no idioma errado.
- Review round=1 · P3 (Spec): no caso `github`, a conferência exige `--repo` só no `pr create`, e não em toda chamada do `gh`, como o caso Gitea faz com `--login` e `--repo` — uma regressão que tire o `--repo` do `gh label list` passa sem a prova ver.
- Review round=1 · P3 (Standards): possível Repeated Switches — o ramo GitHub/Gitea se repete nos Steps 4, 5 e 6 (rótulos, responsável, comando, URL), e a frase "only the command block changes between the forges" diz menos do que o texto faz — quem lê a frase espera um bloco só.
- Review round=1 · P3 (Standards): no `anvil-sync/SKILL.md`, o reflow deixou uma linha só com "bare. O" — forma; o Markdown renderiza igual.
- Review round=1 · P3 (Standards): possível Divergent Change no commit 824a992, um `feat(anvil-open-pr)` que traz também a mudança do helper de prova — um `git log` do helper não acha o commit pelo assunto.
- Review round=1 · P3 (Standards): o comentário sobre o `workspace/59-proof-helper` cita o ticket 04 sem a glosa (o do forge falso com logins e rótulos) — quem lê precisa abrir o ticket para saber se importa.
