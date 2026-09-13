# 13: A guarda de merge acha a spec pelo branch que está sendo mesclado

**What to build:** Com a spec aberta — ticket sem `Status: resolved` ou spec fora de `archive/` —, um `git merge {tipo}/{NNN}-{nome}` é bloqueado de onde quer que seja disparado: do branch da spec ou da `main`. Hoje, rodado na `main`, a guarda libera, porque só olha o branch atual; no fluxo de merge local, que é o jeito natural de mesclar, ela não confere nada. A rule deste repositório deixa de ensinar o contorno.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A guarda identifica a spec pelo branch nomeado no `git merge`, além do branch atual, e opções do comando (`--no-ff`, `-m`, etc.) não atrapalham a identificação.
- [ ] Merge de branch sem número continua liberado, como hoje.
- [ ] Quando o branch atual e o branch mesclado são specs diferentes, as duas são conferidas.
- [ ] As fixtures de decisão (menção dentro de string ignora; invocação verifica) continuam passando.
- [ ] A cópia do hook instalada neste repositório fica igual à do payload.
- [ ] A rule do projeto deixa de descrever o contorno "disparar do branch da spec".
- [ ] Ponto A: num projeto descartável com spec de ticket aberto, `git merge` do branch da spec rodado na `main` sai 2, e do próprio branch da spec também; com tickets resolvidos e spec arquivada, os dois saem 0.
- [ ] A rule do projeto diz que o passo de PR do perfil do tracker (`/tea-open-pr`) não se aplica neste repositório, onde a spec fecha com merge local.
- [ ] O critério de bloqueio da guarda não é repetido na rule: ela aponta o perfil do tracker.
- [ ] Na rule, `mosk` ganha glosa na primeira menção, o `unlazy` deixa de ser descrito como origem de skill, e o parágrafo de abertura para de tratar todo `references/` como upstream.
- [ ] `git cherry-pick` continua fora da guarda: é como a equipe integra worktrees com a spec aberta.
- [ ] O `verify` sai limpo.

## Comments

**Leader, 2026-09-13 — escopo acrescentado.** Os achados P1, P2 e P3 do gate Review do ticket 01
entram aqui, porque este ticket reescreve o mesmo parágrafo da rule.

**Leader, 2026-09-13 — entrega do Dev** em `c1fcb74` (guarda e `validate.sh`), `f82b902` (cópia instalada
do hook) e `720b74e` (rule). A spec de cada branch nomeado no merge é lida do commit do branch, porque
na `main` a pasta não existe. Gates despachados: Review e Tester. Riscos declarados pelo Dev, a julgar
nos gates: `git -c k=v merge` e `git merge <sha>` não são reconhecidos; archive não commitado; nome de
branch fora do conjunto sem python3; perfil do tracker não diz que `git merge` bloqueia sem archive;
`gh pr merge <branch>` da `main`.

**Leader, 2026-09-13 — gate Review: REPROVADO por B1.**

- **B1** — merge disparado do próprio branch da spec confere o disco, não o commit: archive e resolved
  feitos e não commitados passam (`git switch main && git merge {spec}` rc=0), e a `main` recebe a
  spec com ticket aberto e fora de `archive/`. É o estado que o `/anvil-docs archive` deixa. Reproduzido
  de ponta a ponta. Correção: o branch atual também é lido do commit (HEAD), o que fecha ainda o risco 2
  no fluxo de PR.

Critérios 1–12 atendidos; fail-closed e decisão isolada mantidos; desvios do Dev (refs qualificados,
`-`/`@{-1}`, lista larga sem python3, textos) se sustentam.

Entram na correção deste ticket, por serem contornos da mesma guarda e baratos:
- `git -C <dir> merge` e `git -c k=v merge` passam sem verificação — o `-C` é a forma usual dos agentes;
- o perfil do tracker (template e este repo) diz que o merge bloqueia sem archive, não só o `tea pr create`;
- o rodapé e a mensagem do `validate.sh` não falam em PR quando o merge é local;
- a rule deixa de chamar o `anvil-bench` de "sem upstream" sem ressalvar o material do `unlazy`.

Ficam como ideia, fora da spec: merge por SHA ou alvo que ainda não resolve (fail-closed incompleto —
registrar a limitação no cabeçalho, isto sim entra), `gh pr merge <branch>` a partir da `main` (fluxo
de PR), `git ls-tree` sem `-z` com nome não-ASCII, e os smells de regex repetida.
Aguardando o gate do Tester antes de devolver ao Dev.
