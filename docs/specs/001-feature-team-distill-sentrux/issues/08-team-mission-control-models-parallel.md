# 08: `anvil-team`: Mission Control, modelo por papel e dois escritores em paralelo

**What to build:** Numa feature grande, o Leader mantém um bloco de notas objetivo dentro da spec, que sobrevive entre sessões e nunca serve de estado. O usuário escolhe o modelo de cada papel nas rules do projeto. Quando dois papéis precisam escrever ao mesmo tempo, o Leader os isola em worktrees e integra o resultado antes do gate seguinte.

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] O Mission Control nasce na pasta da spec, só em feature grande, criado pelo Leader.
- [ ] Seções: objetivo e resultado esperado, trabalho em execução e ownership de escrita, gates com evidência, bloqueios, decisões abertas, riscos e próximo passo. Não tem estado na frontier nem estado global, e um aviso no topo diz que ele não é fonte de estado.
- [ ] Os papéis não leem o Mission Control; recebem o contexto na delegação.
- [ ] A rule do anvil ganha a lista `team`, de papel para modelo. O Leader passa o modelo na chamada, e sem esse suporte o papel usa o modelo da sessão.
- [ ] Nenhum agente fixa modelo nem isolamento no frontmatter.
- [ ] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 08.
- [ ] O Mission Control nasce a pedido, com dois escritores em paralelo, com sessão acabando com trabalho pendente, ou quando os tickets da spec não cabem numa sessão.
- [ ] O `anvil-boot` escreve a lista `team` com os sete papéis sem modelo (cada um herda o da sessão); a rule deste repositório também.
- [ ] A integração dos worktrees é por `cherry-pick`, e depois vêm verificação e gates.
- [ ] Ponto B mede se a Skill tool enxerga as skills instaladas de dentro de um worktree (as skills são ignoradas pelo git); se não enxergar, a solução entra neste ticket.
- [ ] Ponto B: dois Devs em paralelo em worktrees, integrados no branch da spec antes do Review; um papel despachado com o modelo da rule.

## Comments

**Leader, 2026-09-13 — U4, U5 e M5:** gatilho do Mission Control ampliado com "tickets que não cabem numa
sessão" (as palavras do usuário: guia para grandes features de muitos tickets); lista `team` escrita sem
modelo, reversível; visibilidade das skills no worktree vira critério, porque sem ela um Dev isolado não
roda `anvil-implement`.

**Leader, 2026-09-13 — fase 1 do Dev** em `4b0a6cc` (o 07 está em gate nos mesmos arquivos, então a entrega foi
dividida): `anvil-team/templates/mission-control.md` literal do desenho §9 (aviso de que não é fonte de estado, sete
seções, gates em lista cronológica); `anvil-boot` escreve a lista `team` com os sete papéis sem modelo, a frase "Lidos
por" ganha a `anvil-team`, e um `anvil.md` existente sem a lista recebe proposta de acréscimo sem trocar valor;
`.claude/rules/anvil.md` deste repositório igual. `verify` limpo; nenhum agente com `model` ou `isolation`. Boot num
projeto descartável escreveu a lista vazia (US$ 0,34). **M5 medida** (US$ 0,36): o worktree de `isolation: "worktree"`
parte do HEAD do checkout principal, sem as mudanças não commitadas, em `.claude/worktrees/agent-<id>` com branch
`worktree-agent-<id>`; **a Skill tool enxerga as skills instaladas** (carregadas do checkout principal), então o
`.worktreeinclude` não é preciso; no worktree não existe `.claude/skills/`, e a linha `Protocolo:` absoluta continua
necessária; worktree com commit sobrevive ao agente e `git cherry` lista o commit.

Decisão do Leader sobre o risco levantado na M5 — `?? .claude/worktrees/` aparece no status do checkout principal, e um
`git add -A` (de `anvil-implement` ou `tea-commit` num Dev sem worktree, como o do conflito no passo 6) stagearia os
worktrees como repositório embutido: antes de abrir worktrees, o Leader acrescenta `/.claude/worktrees/` à exclusão
local do git, idempotente, sem tocar o `.gitignore` do projeto. Entra em SKILL § Paralelismo na fase 2 e no desenho §11
(Architect). A fase 2 espera o 07 resolver.

**Leader, 2026-09-13 — entrega do Dev (fase 2)** em `394430c` (SKILL § Mission Control com os quatro gatilhos e as
regras; § Modelo por papel com a lista `team`; § Paralelismo e integração; saem os provisórios "um escritor por vez",
"Mission Control fora" e "model omitido") e `c6f175e` (autorrevisão: o passo 5 integra só os dois worktrees do despacho,
pelo id do lançamento; o passo 0 cria `info/` e não cola na última linha; a Conclusão não cria Mission Control fora do
gatilho). Desenho pelo Architect em `be16c4e` (§11: passo 0 da exclusão local, M5, remoção sem `--force`, "+" que sobra
vai ao usuário) e `7d01d1e` (§5: correção depois da integração vai a `Agent` novo com o mesmo name). `PROTOCOL.md` sem
mudança. `verify` limpo; `18-team-roles` 64/64 e `15-team` 21/21 em 5.2 e 3.2; nenhum agente com `model` ou
`isolation`; linha-ponteiro com o mesmo hash nos sete.

Ponto B isolado, dois runs em dois turnos (o final sobre `c6f175e`), US$ 5,76. O Leader propôs sozinho o paralelo em
worktrees: Mission Control escrito pelo gatilho "dois escritores" e commitado; passo 0 com a linha em `info/exclude` e
o `.gitignore` intacto; `dev-01` e `dev-02` na mesma mensagem com `isolation: "worktree"` e `model: "sonnet"` da lista
`team`, cada delegação com Base (sha), Protocolo absoluto, a região do outro em Fora e Commit no worktree; os dois
leram o protocolo pelo caminho absoluto, conferiram a base com `merge-base --is-ancestor` e carregaram a skill pela
Skill tool dentro do worktree; cherry-pick um de cada vez, `node --test` 6/6, e só então os dois Reviews sobre o
intervalo integrado; `git cherry` só com "-", worktrees e branches removidos; os dois tickets a `resolved`. Os Reviews,
sem valor na lista, saíram sem `model` e rodaram no modelo da sessão; com a linha `tester` removida, o Leader avisou
uma vez. Nenhum papel leu o Mission Control nem o recebeu na delegação.

Desvios: **D1** as pré-condições do `SKILL.md` não trazem "ou isolar em worktree" para sobreposição, que o §11 do
desenho traz — o Dev argumenta que o worktree só adia a colisão para o conflito do passo 6 (a julgar no gate); **D2** o
Ponto B não despachou Tester com worktrees; **D3** não exercitados: conflito no cherry-pick, "+" que sobra, correção
depois da integração, gatilhos 1, 3 e 4 do Mission Control. Riscos: **R1** o `review-01` rodou `git checkout` de um
commit no checkout principal e voltou ao branch — papel somente leitura mexendo no HEAD que o Leader commita; **R2** o
Mission Control ficou com os Devs em execução depois da integração (nota velha; vale o ticket); **R4** efeito cruzado
entre os dois tickets coberto só pelos testes do projeto; mecânica medida só na 2.1.270. Gates despachados: Review e
Tester.

**Leader, 2026-09-13 — gate Review, rodada 1: APROVADO, sem bloqueante.** Os onze critérios atendidos sobre `c6f175e`
(e `4b0a6cc`); template igual ao §9; tabela da lista `team` igual ao §10; oito passos presentes, com "nunca `git
merge`", conferência de base, verificação antes dos gates e remoção só com `git cherry` sem `+`; provisórios
removidos de `anvil/` e do desenho; nenhum texto deste repositório no payload. Simulação num repo descartável: passo 0
de subdiretório, idempotente e criando `info/`; `git cherry` só com `-` depois dos dois cherry-picks; `branch -d`
recusa, então `-D` é preciso. `verify` limpo; 64/64 e 21/21 em 5.2 e 3.2. Achados: **F1** (relevante; o R1 da
entrega) o agente Review não diz que somente leitura inclui HEAD, índice e working tree — o `review-01` fez `git
checkout` de um commit no checkout principal enquanto o `review-02` lia a mesma árvore; com dois gates em paralelo no
passo 7 e o commit de ticket do Leader esperando só o escritor ativo, o commit cairia fora do branch da spec. **F2**
(relevante, desenho) o §11 exige regiões disjuntas e depois aceita "ou isolar em worktree" para sobreposição, e o §4
fala em "três saídas" — resto do port; o `SKILL.md` está certo (D1). **F3** a Conclusão diz "atualize-o" quando o
gatilho vale e o arquivo não existe; o §1 do desenho ficou sem o gatilho. **F4** "nenhuma skill ou hook o lê"
contradiz o Leader, que é skill — falta "como fonte de estado". **F5** o `branch -D` do passo 8 deixa inalcançável o
sha de entrega citado no Registro; registrar o sha integrado. **F6** a tabela "Trabalho em execução" fica velha
depois da integração. **F7** a lista de modelos aceitos repetida no `anvil-boot`. **F8** o passo 5 não diz o que fazer
quando um escritor volta `BLOQUEADO` ou `PERGUNTA` e o outro `PRONTO`. Não exercitados: D2, D3 (conflito no
cherry-pick, `+` que sobra, correção depois da integração, gatilhos 1, 3 e 4).

**Leader, 2026-09-13 — gate Tester, rodada 1: REPROVADO.** Isolado, payload de `ce1fa0c`, projeto Python diferente do do
Dev, 13 execuções, US$ 11,65. Passaram os seis casos: paralelo com exclusão local antes dos worktrees, Tester primeiro
e escrevendo só em `/tmp` com repro por `SendMessage` (o D2), dois Devs em `sonnet` com Base, Protocolo absoluto e
conferência de base, cherry-pick um de cada vez, testes antes dos gates, `git cherry` sem `+` e remoção sem `--force`;
região sobreposta — o Leader recusou o paralelo e serializou mesmo com o usuário pedindo worktree; commit pendente — o
Leader commitou só o ticket e usou esse sha como Base; correção depois da integração por `Agent` novo sem worktree com
gates da rodada 2; lista `team` (com valor, sem valor, valor fora do enum, lista ausente com aviso único); Mission
Control pelo gatilho, sem estado, nenhum papel lendo, e não criado em pedido comum; `anvil-boot` em projeto novo e em
`anvil.md` existente só com o acréscimo; `verify` limpo. **F1 (bloqueante)** um Dev em worktree que volta PERGUNTA ou
BLOQUEADO sem commitar tem o worktree apagado com o branch ao encerrar; retomado por `SendMessage`, como SKILL §
Perguntas manda, roda no checkout principal e commita no branch da spec (medido com `general-purpose`: commit
`91e2ddf` em `bugfix/001-x`; controle com commit fica no worktree). **F2** papel retomado por `SendMessage` de outro
papel roda no cwd e, sem `model` na chamada original, no modelo de quem manda — o Tester retomado pelo Dev rodou em
`sonnet` com cwd no worktree do Dev (2/2); com `model` explícito a retomada mantém o modelo. **F3** diretórios fixos do
Tester em `/tmp` com restos de runs anteriores. **F4** Mission Control criado 8 s depois do passo 0, que o SKILL põe
antes (sem efeito). Não exercitados: conflito no cherry-pick e `+` que sobra; gatilhos 1, 3 e 4.

Decisão do Leader, na mesma rodada de ajuste: **F1** papel despachado com worktree nunca é retomado por `SendMessage`
— PERGUNTA ou BLOQUEADO dele vão a `Agent` novo, pela regra do F8 (decisão sobre a proposta do Dev: escritor único sem
worktree no branch integrado, trazendo por cherry-pick o que o worktree tiver); SKILL § Perguntas e § Despachar ou
retomar abrem essa exceção. **F2** registrar a mecânica (retomada lateral herda cwd e, sem `model`, o modelo de quem
manda) e a Política do Tester nomear só caminho absoluto. **F3** diretório do Tester único por despacho. F4 fica como
ideia. Reteste do Tester: o probe do F1 com o texto novo e o `anvil-team-dev`, e o F2.

**Leader, 2026-09-13 — rodada de ajuste** em `f75f1cc`, `ed0c4f0`, `881a1b9` e `51e2b2a`; desenho pelo Architect em
`df905a1`, `cd327fc`, `1da5e13` e `37aa4de`. Review: **F1** o agente Review não mexe em HEAD, índice nem working tree
(sem checkout, switch, stash, reset, branch, `worktree add`) e extrai o commit a testar com `git archive` num diretório
fora de qualquer checkout — decisão do Leader sobre proposta do Dev: a Política do gate Review passa a "leitura no
checkout, escrita só em {diretório fora de qualquer checkout}" (coerente com a U2; allowlist e `PROTOCOL.md`
inalterados); **F2** §11 e §4 do desenho sem "isolar em worktree"; **F3** Conclusão cria o Mission Control quando o
gatilho vale e ele não existe; **F4** "como fonte de estado"; **F5** a decisão do Leader cita o intervalo integrado no
branch da spec; **F6** passo 8 atualiza a tabela do Mission Control; **F8** decisão do Leader sobre proposta do Dev:
com um PRONTO e outro BLOQUEADO/PERGUNTA, integra-se o PRONTO e o outro vira escritor único por `Agent` novo sem
worktree no branch integrado, trazendo por cherry-pick o que o worktree tiver. Tester: **F1** papel despachado com
worktree nunca se retoma por `SendMessage` (exceção explícita em § Despachar ou retomar e § Perguntas, apontando para
"Autor que trabalhou em worktree"); **F2** a retomada lateral herda cwd e, sem `model`, o modelo de quem manda — nota
de versão e Política do Tester só com caminho absoluto; **F3** diretório do Tester por `mktemp -d` a cada despacho.
`verify` limpo; 64/64 e 21/21 em 5.2 e 3.2; linha-ponteiro inalterada; nenhum agente com `model` ou `isolation`.

Desvios aceitos: **D1** Tester e Review não contam como escritores (senão o diretório do Review travaria o commit de
ticket); **D2** diretório do gate Review também por `mktemp`; **D3** ponteiros do F1 ao bloco da regra e ao passo 5;
**D4** redação em § Perguntas. Ficam como ideia: F7 do Review; F4 do Tester. Riscos: o escritor único do F8 fica
ativo no checkout enquanto o gate do PRONTO roda, e o commit de ticket espera; um Tester sem valor na lista, retomado
pelo Dev, roda no modelo do Dev; "com commit a retomada fica no worktree" medido só com `general-purpose`; não
exercitados: conflito no cherry-pick, `+` que sobra, gatilhos 1, 3 e 4 e o próprio caminho do F8. Rodada 2 dos gates
despachada.

**Leader, 2026-09-13 — gate Review, rodada 2: REPROVADO.** Diff `71ccf7e..37aa4de`. Resolvidos: F1 a F6 do Review
(o `git checkout` do R1 veio do próprio `review-01`, então a regra no agente alcança quem fez; a Política nova não
contradiz o protocolo nem a allowlist), F2 e F3 do Tester, D1 a D4. **RV2-F1 (bloqueante)** a regra "papel em worktree
nunca se retoma por `SendMessage`" obriga só o Leader; o Tester manda o repro sem esperar pedido, o gate conversa com o
autor, e "pergunte a ele" vale para todos — um Dev que voltou BLOQUEADO na conferência de base (worktree sem mudança,
apagado) é retomado pela lateral no cwd de quem manda, o checkout principal, onde a Base passa e ele commita no branch
da spec em paralelo com o outro Dev. Dedução de duas mecânicas medidas (probe3 e F2), não executada. **RV2-F2**
`PROTOCOL.md:78-79` (o Leader pede o retorno por `SendMessage`) e `:203` (a resposta volta por `SendMessage`) contradizem
a exceção para papel em worktree. **RV2-F3** o caminho do F8 manda "passos 5 a 7" para o PRONTO e deixa de fora o passo
8 (remoção e tabela do Mission Control); o worktree do bloqueado some sozinho e a linha dele fica velha. **RV2-F4** no
caminho do F8 o escritor único fica ativo enquanto o gate do PRONTO volta; o registro do gate anexado ao ticket e não
commitado entra no commit do Dev (`anvil-implement`/`tea-commit` stageiam o pendente). **RV2-F5** a mecânica escrita diz
"sem commit, o worktree é apagado" e o medido é "sem mudança"; o cherry-pick `{Base}..worktree-agent-{id}` de um
worktree que sobrou repete commits já integrados — trazer só os `+` do `git cherry`. **RV2-F6** a regra "nunca por
`SendMessage`" em quatro trechos, ponteiros circulares, rótulo divergente do desenho. **RV2-F7** o Review roda
verificação e sensores sem dizer onde; caches e build escrevem no checkout.

Decisão do Leader, mesma rodada de ajuste: **RV2-F1** guarda do lado do papel, valendo para qualquer remetente —
`PROTOCOL.md` § Ownership, em worktree: antes de cada escrita e de cada commit, conferir que o checkout é o worktree da
delegação; se não for, `BLOQUEADO` sem escrever. **RV2-F2** ressalva de worktree nas duas linhas do protocolo. **RV2-F3**
"passos 5 a 8", e o passo 8 cobre também o worktree que sumiu sozinho. **RV2-F4** com escritor ativo no checkout, o
Leader guarda o registro e só o escreve no ticket quando o escritor voltar. **RV2-F5** "sem mudança" e cherry-pick só
dos `+`. Ficam como ideia: RV2-F6 e RV2-F7.

**Leader, 2026-09-13 — gate Tester, rodada 2: APROVADO** (sobre `19da767`, antes do ajuste do RV2-F1). Isolado, cinco
execuções, US$ 7,81. **F1 de ponta a ponta com `anvil-team-dev`**: paralelo em worktrees com `sonnet`; o `dev-02`
conferiu a base e voltou PERGUNTA sem escrever, e o worktree dele sumiu; o Leader integrou só o PRONTO (cherry-pick,
testes, `git cherry` só com `-`, remoção sem `--force`, gates), sem nenhuma `SendMessage` ao papel de worktree; com a
resposta, `Agent` novo `dev-02` sem `isolation` sobre a Base integrada, commit no branch da spec pelo fluxo; reflog só
com o Leader, o cherry-pick e o `dev-02` novo. **F2 e F3**: Tester retomado pelo Dev com cwd no worktree gravou só no
caminho absoluto; diretório por `mktemp -d` único em seis despachos. **F1 do Review**: com o Leader commitando no
checkout, Reviews e subagentes só com git de leitura e `git archive | tar -x` no diretório da Política; nenhuma entrada
de papel no reflog. Regressão: exclusão local, Mission Control com a tabela vazia depois do passo 8 (F6), decisão
citando o intervalo integrado (F5), dois tickets `resolved`. Sugestões que ficam como ideia: **S1** `__pycache__/`
deixado por Tester e Review no checkout e no worktree (sem a linha no `.gitignore`, iria para o commit do Dev); **S2** o
`dev-02` novo sem linha Protocolo não leu o protocolo antes de agir; **S3** subagente da `anvil-code-review` extraiu
num `mktemp` próprio. Não exercitados: BLOQUEADO; worktree que sobrevive com commit; escritor único ativo durante o
gate do PRONTO; conflito no cherry-pick; `+` que sobra; gatilhos 1, 3 e 4; modelo herdado na retomada.

**Leader, 2026-09-13 — ajuste da rodada 2** em `f08e0c3` e, no desenho pelo Architect, `8026fd7`. **RV2-F1** PROTOCOL §
Ownership: em worktree, o papel anota o `git rev-parse --show-toplevel` logo depois de ler o protocolo e, antes de cada
escrita e de cada commit, confere sem `cd` que o toplevel é o anotado; falhando, volta `BLOQUEADO` sem escrever — vale
para qualquer remetente. Provado com o comando real num repo descartável: passa no worktree e num subdiretório dele;
falha no checkout principal, no worktree do outro Dev, fora de checkout e depois de o worktree ser removido.
**RV2-F2** as duas linhas do protocolo ganham a ressalva de worktree (volta por `Agent` novo). **RV2-F3** o PRONTO
segue os passos 5 a 8; o passo 8 cobre o worktree que sumiu sozinho. **RV2-F4** com escritor ativo no checkout, o
Leader não escreve no ticket nem no Mission Control até ele voltar. **RV2-F5** "sem mudança"; worktree que sobreviveu
traz só os commits `+` do `git cherry` (provado: o intervalo inteiro para no commit já integrado; só os `+` fecha
limpo). `verify` limpo; 64/64 e 21/21 em 5.2 e 3.2; agentes inalterados.

Desvios aceitos: **D1** RV2-F4 estendido ao Mission Control (o passo 8 edita a tabela); **D2** guarda por toplevel, não
por `--git-dir` (que passaria no worktree do outro Dev); **D3** anotação logo depois de ler o protocolo, para cobrir
PERGUNTA antes da primeira escrita. Riscos: sem a anotação a comparação falha para o lado do `BLOQUEADO`; papel com
worktree vivo retomado fora dele volta `BLOQUEADO` (conservador). Rodada 3: Review do diff e Tester medindo o caminho
do RV2-F1 com a guarda.

**Leader, 2026-09-13 — gate Tester, rodada 3: REPROVADO.** Isolado, payload de `094e1f4`, quatro execuções, US$ 1,21.
**Caminho do RV2-F1 — PASS:** um `anvil-team-dev` em worktree voltou `BLOQUEADO` na conferência de base sem escrever, o
worktree sumiu; retomado por `SendMessage` de outro agente com cwd no checkout principal (onde a Base já passava), rodou
`git rev-parse --show-toplevel`, comparou com o anotado e voltou "BLOQUEADO, fui retomado fora do worktree"; nenhum
commit nem arquivo no checkout. **T3-F1 (bloqueante)** a linha literal da guarda, `test "$(git rev-parse
--show-toplevel)" = "…"`, é recusada pelo harness dentro de agente com `isolation: "worktree"` ("command names git in a
form too complex to verify"); também `[ … ]`, `T=$(git …) && test` e `sh -c`. Só `git rev-parse --show-toplevel` puro
roda. No controle o `sonnet` trocou o comando por conta própria; ao pé da letra, todo Dev em worktree bloquearia. A
prova do ajuste rodou num shell, não num agente isolado. **T3-F2** "antes de cada escrita" não foi seguido no controle
(nenhum dos quatro Edits conferido logo antes). Sugestões que ficam como ideia: o Dev carregou a skill antes de ler o
protocolo; o Dev bloqueado pediu "worktree novo ou o mesmo recriado". Observação: o ticket ambíguo que gerou PERGUNTA
na rodada 2 foi implementado sem perguntar nesta (1 de 2).

Decisão do Leader: **T3-F1** a conferência é `git rev-parse --show-toplevel` sozinho numa chamada Bash, com a saída
comparada ao caminho anotado. **T3-F2** a conferência acontece no começo de cada turno — inclusive quando uma mensagem
retoma o papel — e antes de cada commit, no lugar de "antes de cada escrita"; a retomada é sempre um turno novo, e é
ela que abre o caminho do RV2-F1. Reteste: controle e caminho do RV2-F1 com o texto novo.

**Leader, 2026-09-13 — gate Review, rodada 3: REPROVADO só pelo T3-F1** (diff `19da767..8026fd7`). Sem bloqueante novo.
RV2-F1: a lógica da guarda está certa — protocolo lido por todo papel, vale para qualquer remetente, anotação antes da
conferência de base e de qualquer PERGUNTA; semântica conferida num repo descartável (passa no worktree e em
subdiretório; falha no checkout principal, no worktree do outro Dev, fora de checkout e no diretório recriado) —, mas a
forma literal não roda no agente isolado (o T3-F1, já decidido). RV2-F2 a F5 resolvidos (cherry-pick só dos `+`
conferido com commit integrado de sha diferente). Espelho pendente: o desenho ainda traz a forma literal e "antes de
cada escrita" (`team-shape.md:193`, `:588-593`), a corrigir junto com o T3-F1 e o T3-F2. Não avaliado, fica como risco:
para quem vai o `BLOQUEADO` de um papel retomado por lateral (o remetente, não o Leader, pela mecânica) — o Leader já
recebeu a volta original do papel e segue pelo caminho do F8.

**Leader, 2026-09-13 — ajuste da rodada 3** em `f92e888` e, no desenho pelo Architect, `7d5685d`. **T3-F1** a guarda é
`git rev-parse --show-toplevel` sozinho numa chamada Bash, com a saída comparada ao caminho anotado (a anotação sai do
mesmo comando); o texto diz que composto com `$(…)`, `test` ou `&&` o harness o recusa no worktree. **T3-F2** a
conferência é no começo de cada turno, inclusive na retomada, e antes de cada commit. Prova dentro de agente isolado
(`claude -p` com `haiku`, US$ 0,06): um `general-purpose` com `isolation: "worktree"` rodou o comando puro sem recusa e
recebeu o caminho do worktree; retomado por `SendMessage` depois de o worktree sem mudança ser apagado, o mesmo comando
devolveu o checkout principal e ele respondeu "diferente". Nenhum bloco `test "$(git` no protocolo nem no desenho;
`verify` limpo; 64/64 e 21/21 em 5.2 e 3.2; agentes inalterados. Reteste do Tester despachado: controle e caminho do
RV2-F1 com o texto novo.
