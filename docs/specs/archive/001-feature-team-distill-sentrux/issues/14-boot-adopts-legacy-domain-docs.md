# 14: O boot adota glossário e ADRs antigos que moram fora de `docs/`

**What to build:** Num projeto que tem `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz, ou ADRs em `docs/adr/`, o boot percebe que existe documentação de domínio no layout antigo e segue pelo `adopt`, que mostra o plano de movimentação e espera aprovação, em vez de seguir pelo `scaffold`. Hoje o boot escolhe o verbo olhando só dentro de `docs/`; e, desde que o `anvil-setup` passou a procurar o glossário no layout do anvil, esse glossário antigo passa despercebido e o perfil de domínio manda "seguir em silêncio". É uma regressão desta spec.

**Blocked by:** 04

**Status:** resolved

- [x] O passo 5 do boot trata como gatilho do `adopt` a presença de `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz, ou de ADRs em `docs/adr/`, mesmo com `docs/` ausente ou só com README de domínio.
- [x] O `adopt` mostra o plano inteiro antes de mover qualquer coisa, como já faz para esses caminhos, e nada é movido sem aprovação.
- [x] Projeto sem nenhum desses arquivos continua indo para o `scaffold`.
- [x] Depois do boot, o glossário e os ADRs estão no layout do anvil e o perfil de domínio aponta para eles; nenhuma rule do projeto continua citando o caminho antigo sem aviso.
- [x] Ponto B, com `claude -p` isolado do `CLAUDE.md` e das rules do repo pai: um projeto com `CONTEXT.md` na raiz recebe o plano do `adopt` e só move com aprovação; um projeto limpo segue pelo `scaffold`.
- [x] O `verify` sai limpo.

## Comments

**Leader, 2026-09-13 — entrega do Dev** em `7feda2d` e `0c71304` (passo 5 do boot). Ponto B isolado: projeto
com `CONTEXT.md` na raiz e projeto com `docs/adr/` seguem pelo `adopt`, mostram o plano, param e só movem
com aprovação; projeto limpo segue pelo `scaffold`. Cinco execuções, US$ 2,73.

**Ampliação antes dos gates:** a regra "sem verbo explícito" do `anvil-docs` é a fonte da escolha entre
`scaffold` e `adopt`, e o boot só a repete. Sem a exceção lá, `/anvil-docs` rodado direto num projeto antigo
ainda cai no `scaffold` e ignora o glossário. A exceção vai para o `anvil-docs` (regra e parada do
`scaffold`), e o passo 5 do boot aponta para ela.

Ficam como ideia: `ARCHITECTURE.md`/`ROADMAP.md` soltos na raiz e `src/*/docs/adr/` como gatilho (o ticket
nomeia três caminhos). Aceito: a cláusula de `docs/adr/` é redundante com "conteúdo fora dos domínios", mas o
ticket a nomeia. `CONTEXT-MAP.md` sem execução própria vai para o gate do Tester.

**Leader, 2026-09-13 — ampliação entregue** em `3a66f54` (`anvil-docs`: regra "sem verbo explícito" e parada
do `scaffold`) e `30549ae` (boot delega a escolha). Prova isolada: `/anvil-docs` digitado direto num projeto
com `CONTEXT.md` na raiz segue pelo `adopt` com plano e parada; pelo boot, projeto antigo vai para o `adopt`
e projeto limpo para o `scaffold`. Desvio aceito: duas células da tabela de verbos do `anvil-docs` deixam de
contradizer a regra. O diagrama do README que mostra o boot chamando o `scaffold` direto vai para o ticket 03.
Gates: Review agora; Tester depois do reteste do 05.

**Leader, 2026-09-13 — gate Review: APROVADO, sem bloqueante.** Seis critérios atendidos; a ampliação para o
`anvil-docs` e o desvio da tabela se sustentam. Ajuste antes do Tester, só texto:

- **F1** — a parada do `scaffold` vem depois dos passos 1–4; com `/anvil-docs scaffold` explícito num projeto
  antigo, a árvore é criada antes de a parada ser lida. Vira pré-condição, antes do passo 1.
- **F2** — a condição sobre `docs/` está redigida de três jeitos (tabela, regra, parada). Uma redação só.
- **F4** — o boot ainda diz que "vai para o verbo `adopt` no passo 5" e repete "quatro domínios" e "Nunca
  presuma", que agora são do `anvil-docs`; "escritas antes da mudança" nomeia a movimentação do `adopt`.

Ficam como ideia: **F3** usuário que recusa a movimentação fica com o perfil apontando para o layout do anvil
(avisar na recusa); **F5** description do `anvil-docs` e título do `ADOPT.md` falam de `docs/` existente, e o
`ADOPT.md` não trata os links relativos de um `CONTEXT-MAP.md` movido; **F6** `src/*/docs/adr/` chamado de
layout antigo no `ADOPT.md` e válido no `anvil-setup`. O Tester julga depois do ajuste, cobrindo
`CONTEXT-MAP.md` e o turno de aprovação na versão final.

**Leader, 2026-09-13 — ajuste entregue** em `0b61a59` (`anvil-docs`: F1 pré-condição do `scaffold` antes do
passo 1; F2 "gatilho do `adopt`" definido uma vez em Verbos e citado na tabela, na regra e na pré-condição) e
`14ff955` (boot: F4). Decisão confirmada no F2: a condição sobre `docs/` é "conteúdo fora dos domínios canônicos",
a mesma do `validate.sh docs-paths` — o boot rodado de novo num projeto que já segue o anvil vai para o
`scaffold`, que não sobrescreve nada. Pendente: checagem curta do Review sobre o ajuste e gate do Tester
(com `CONTEXT-MAP.md` e o turno de aprovação na versão final).

**Leader, 2026-09-13 — checagem do Review sobre o ajuste: APROVADO.** F1 (pré-condição antes do passo 1, valendo
com o verbo explícito), F2 (gatilho definido uma vez e citado nos três lugares, sem texto antigo sobrando) e F4
resolvidos. Falta o gate do Tester na versão final.

**Leader, 2026-09-13 — resolvido.** Gate do Tester, isolado, na versão final: APROVADO nos cinco casos —
`CONTEXT-MAP.md` na raiz (adopt, plano, parada, movimentação aprovada), `CONTEXT.md` pelo boot até a aprovação
(rule do usuário trocada com aprovação), `/anvil-docs scaffold` explícito com legado (para antes de criar
qualquer coisa), projeto que já segue o anvil (scaffold sem sobrescrever nada) e projeto limpo. Com o gate e a
checagem do Review, os gates passaram sobre `14ff955`.

Evidência acrescentada à ideia **F5**: na execução com `CONTEXT-MAP.md`, os links relativos foram corrigidos por
iniciativa do modelo — o `ADOPT.md` não manda, então uma execução pior deixa o mapa com links quebrados.
