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

**Leader, 2026-09-13 — gate Tester: REPROVADO pelo caso 2** (opção global antes do subcomando). Da
`main`, `git -C . merge {spec}` e `git -c k=v merge {spec}` passam e mesclam de verdade. Confirmou também
o B1 do Review. O ticket fechou 28 contornos que já existiam e criou 5 falsos positivos.

**Lista única de correções deste ticket** (Review + Tester):

1. **B1** — o branch atual também é lido do commit (HEAD), não do disco.
2. **Opção global do git** antes do subcomando (`-C <dir>`, `-c k=v`, `--no-pager` e afins) não impede
   reconhecer o `merge`.
3. **Falsos positivos novos**: `git` só conta em posição de comando (início de comando simples, depois de
   `&&`, `;`, `|`, newline, prefixo de env ou `command`) — `echo git merge x` é menção; newline encerra
   a coleta de alvos; delimitadores de heredoc entre aspas (`<<'EOF'`, `<<"EOF"`) e com pipe depois
   (`<<EOF | tee f`) são reconhecidos.
4. O perfil do tracker (template do `anvil-docs` e o deste repo) diz que o merge também bloqueia com a
   spec fora de `archive/`, não só o `tea pr create`.
5. O rodapé do hook e a mensagem do `validate.sh` não falam em PR quando o merge é local.
6. A rule ressalva que o `anvil-bench` carrega material do `unlazy`, que vem de upstream.
7. O cabeçalho do hook registra o que a guarda **não** pega: `bash -c`/`sh -c`/`eval`/backticks/`xargs`,
   merge por SHA ou alvo que não resolve, `git pull . {spec}`, `git rebase {spec}` na `main`, `reset --hard`.

Ficam como ideia, fora da spec: fechar os contornos do item 7; `gh pr merge {branch}` a partir da
`main`; hook que libera quando o `validate.sh` não existe num clone novo sem `dev-link`; `ls-tree -z`.

Reteste: `workspace/11-merge-target-tester/adv.sh` e `repro-git-C.sh` do Tester, o `run.sh` do Dev, e
os cenários do Review (archive não commitado disparado do branch da spec → rc=2).

**Leader, 2026-09-13 — correções entregues** em `f454be1..f1a12f4` (os 7 itens). Suíte adversarial do Tester:
14 contornos e 8 falsos positivos → 10 e 2; os 10 são exatamente os do item 7, e os 2 já existiam
(`git merge main` e `git merge --abort` disparados do branch da spec). `run.sh` com 100 checagens limpo em
bash 5 e 3.2; cópia instalada igual ao payload; verify limpo.

Desvios aceitos: **D1** a posição de comando foi implementada ao contrário — `git` fora da cabeça só é
menção quando a cabeça nunca executa os argumentos (`echo`, `printf`, `grep`, `rg` e afins), o que mantém
`sudo`, `timeout`, `if`, `{ }` e `nohup` verificados; **D2** a pré-passada trata também comentário,
continuação de linha e `$(`, fechando dois contornos antigos; **D3** `ARCHIVE.md` e `SKILL.md` do
`anvil-docs` dizem que a spec é lida do commit; **D4** texto neutro "merge ou PR". Efeito aceito do B1: no
branch de uma spec cuja pasta ainda não foi commitada, `git merge main` bloqueia até o commit.
Reteste despachado: Review e Tester.

**Leader, 2026-09-13 — reteste do Review: REPROVADO por N1.** Os itens 1, 3, 4, 5, 6 e 7 estão resolvidos;
o B1 fechou de ponta a ponta; D1–D4 se sustentam; nenhuma regressão nos critérios originais.

- **N1** (bloqueante, item 2 incompleto) — `$(...)` sem aspas antes do verbo ou dos alvos quebra o parse
  e a guarda libera um merge de verdade: `git -C $(pwd) merge {spec}`, `git --work-tree $(pwd) merge`,
  `git -c user.name=$(whoami) merge`, e `git merge -m $(printf x) {spec}` com alvo truncado. O shlex separa
  comando no `(`. Correção: `$(...)` sem aspas é parte da palavra, e o conteúdo é conferido como comando
  à parte (`echo $(git merge x)` continua verificando).

Entram junto: **N2** verbo ofuscado (`git mer\ge`, `git mer''ge`) documentado no cabeçalho, na lista do que
a guarda não pega; **N4** comentários do `validate.sh` e do cabeçalho do hook que ainda supõem PR.
Ficam como ideia: **N3** `git commit … && git switch main && git merge` bloqueia porque o hook roda antes
do commit (conservador, a mensagem orienta); **N5** a cópia instalada do hook não tem paridade conferida
pelo `verify`; smells de nomes e ramos duplicados.

Esta é a terceira rodada do ticket: o próximo reteste cobre só os casos do N1, do N2 e do N4.
Aguardando o reteste do Tester.

**Leader, 2026-09-13 — reteste do Tester: APROVADO**, com achados não bloqueantes. Suíte adversarial: 10
contornos (os do item 7) e 2 falsos positivos antigos; 32 combinações de opção global, 16 cenários do B1,
heredocs e commits no formato dos agentes passando; corpus de 31.337 chamadas Bash reais sem falso
positivo novo.

**Arbitragem N1 (Review, bloqueante) × F1 (Tester, não bloqueante)** — mesmo achado: `$(...)` sem aspas
antes do verbo ou do alvo esconde o merge. Uso real medido: zero. Decisão: entra, porque contraria o
fail-closed declarado no cabeçalho e o texto do item 2, e a correção sugerida pelo Tester é barata.

**Última rodada deste ticket:**
1. N1/F1 — `$(...)` sem aspas não separa o comando de fora; o conteúdo é conferido como comando à parte.
2. F2 e alvo em variável — se algum alvo tem `$` ou crase, ou se a coleta parou num redirecionamento
   (`git merge 2>&1 {spec}`), não emitir a linha de alvos: cai na lista larga.
3. N2 — o cabeçalho registra verbo ofuscado (`git mer''ge`, `m\erge`) entre o que a guarda não pega.
4. N4 — comentários do `validate.sh` e do cabeçalho do hook que ainda supõem PR.
5. Se barato: F3 (commit com `EOF)"` na mesma linha cai em "heredoc sem fim") e `echo $((1<<2))` lido
   como heredoc.

Reteste limitado: `repro-reteste.sh` e `adv.sh` do Tester e os casos do N1 do Review.

**Leader, 2026-09-13 — última rodada entregue** em `1d16b07` (guarda), `489e23c` (comentários do
`validate.sh`) e `33644a2` (cópia instalada). Números: `repro-reteste.sh` 13/13 em bash 5 e 3.2; `adv.sh`
estável em 10 contornos (item 7) e 2 falsos positivos antigos; `adv2.sh` de 24 contornos e 21 falsos positivos
para 16 e 13, sem piora; `run.sh` com 120 checagens limpo.

Desvios aceitos: `$(which git) merge {spec}` passa a contar como git; o redirecionamento deixa de separar
comandos e sai da lista de alvos em vez de derrubar para a lista larga (a forma literal gerava 6 falsos
positivos no formato de merge dos agentes). Exceção aceita no corpus: um falso positivo novo em comando com alvo
em variável e outro nome de spec no mesmo comando — custo direto de mandar alvo em variável para a lista larga;
no uso real só acrescenta o branch atual. Ficam como ideia: `echo a\ #` e `echo \;#` antes de um merge.
Reteste limitado: Review (casos do N1) e Tester (`repro-reteste.sh`, `adv.sh`).
