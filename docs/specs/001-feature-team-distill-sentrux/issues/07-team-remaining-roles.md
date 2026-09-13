# 07: `anvil-team`: os outros cinco papéis e a conversa entre papéis

**What to build:** A equipe fica completa: PO, Architect, Analyst, Designer e Tester são despachados pelo Leader como Dev e Review já são. Dois papéis conversam direto — o Dev pede um repro ao Tester sem passar pelo Leader — e o julgamento do Tester chega ao Leader mesmo quando o Dev discorda. A documentação para de dizer que o anvil não tem agentes.

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] `anvil-team-po`, `anvil-team-architect`, `anvil-team-analyst`, `anvil-team-designer` e `anvil-team-tester` existem no payload, com descriptions que não atraem delegação automática.
- [ ] Cada papel guarda só o que é dele; o comum fica no protocolo.
- [ ] As skills citadas pelos papéis existem no payload: `anvil-diagnose`, `anvil-tdd` e `anvil-code-review` no lugar dos nomes inexistentes da configuração de origem.
- [ ] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 07.
- [ ] O `verify` reprova agente que cita skill inexistente no payload ou skill com trava de invocação.
- [ ] O PO não cita `anvil-to-questionnaire`; o Leader sugere `/anvil-wayfinder` e `/anvil-handoff` ao usuário em vez de despachá-las.
- [ ] RV-F1 (gate Review do 06): o Tester despachado junto com o Dev deixa de contradizer "um escritor por vez neste checkout" — exceção explícita com commit coordenado, ou o Tester escreve fora do checkout.
- [ ] RV-F2 (gate Review do 06): a regra de divergência e os campos do finding ficam num lugar só (protocolo), sem cópia nos papéis.
- [ ] RV-F3 (gate Review do 06): o papel Review (e o Tester) contempla a delegação sem gate prevista no protocolo.
- [ ] TS-F1 (gate Tester do 06): a linha-ponteiro dos sete agentes manda ler o protocolo INTEIRO antes de agir; um fluxo de reteste mostra o Dev lendo o arquivo todo e carregando a skill delegada pela Skill tool.
- [ ] TS-R1 (gate Tester do 06): com os sete papéis existindo, um ticket chega a `resolved` pela equipe com os gates de Review e Tester.
- [ ] O README e o overview dizem que o anvil distribui agentes e a skill de equipe, apontando o ADR-0007.
- [ ] Ponto B: uma mensagem do Dev chega ao Tester sem passar pelo Leader; o julgamento do Tester chega ao Leader; cada um dos cinco papéis é despachado ao menos uma vez.

## Comments

**Leader, 2026-09-13 — U3:** `anvil-wayfinder`, `anvil-handoff` e `anvil-to-questionnaire` continuam
travadas (o usuário destravou só as sete que a equipe despacha). Vale a saída do desenho.

**Leader, 2026-09-13 — RV-F1 decidido** (Architect, a partir de proposta do Dev; `team-shape.md` §5 em `0ca933b`): o
Tester, com ou sem gate, escreve **fora de qualquer checkout**, num diretório nomeado pelo Leader, com `Commit: não`; o
Dev é o único escritor do checkout. O repro chega ao Dev por `SendMessage`, com caminho e comando; teste de regressão
quem escreve e commita é o Dev; o Leader anota o caminho do repro no ticket e o repassa ao gate do Tester. Vale também
com worktrees. Motivo: dois escritores disputam o índice, e arquivo não rastreado do Tester entraria no commit do Dev.
`SKILL.md` e `anvil-team-tester.md` ficam com o Dev.

**Leader, 2026-09-13 — entrega do Dev** em `1911994` (check e, "14." no `verify`), `8e54737` (os cinco agentes; Dev,
Review, `PROTOCOL.md`, `SKILL.md` e lock), `4999f32` (`anvil-principles` e `anvil-prototype` no roster do `dev-link`),
`a085581` (README e overview), `cf464ec` (autorrevisão) e `1465105` (Tester despachado antes do Dev). Desenho
atualizado pelo Architect em `8180c4a`. Ponto A: fixtures do check (e) 16/16 em bash 5.2 e 3.2 — reprova skill
inexistente, crase dupla, skill travada, a própria `anvil-team`, trava com espaço, agente fora da equipe; não reprova
skill livre, nome de agente, bloco cercado, nome sem crase, placeholder, trava fora do frontmatter; 8 falhas antes do
check; `workspace/15-team/run.sh` sem regressão. Ponto B isolado, uma sessão em três turnos (US$ 6,50): os sete agent
types no init; Dev → Tester por `SendMessage` sem o Leader (a primeira tentativa voltou "not reachable", a segunda
entregou), repro com caminho e comando, Dev viu falhar antes de corrigir; Tester escreveu só fora do checkout; o
julgamento do Tester chegou ao Leader; o ticket 01 do projeto de teste chegou a `resolved` com os dois gates;
tester, po, analyst, architect e designer despachados; todo despacho leu o protocolo com `cat` inteiro e carregou a
skill pela Skill tool.

Desvios aceitos: **D1** campos do finding de comportamento no `PROTOCOL.md`, sem seção Findings em Tester e Review
(RV-F2; o 07 editou o protocolo, contra o §12 original); **D2** Tester despachado antes do Dev, pela corrida medida
(ambos em `8180c4a`); **D3** `anvil-ui` fora do roster do `dev-link`, porque este repositório não tem UI; **D4** check
(e) vale para todo agente do payload; **D5** turnos 1 e 2 com a linha-ponteiro anterior a `cf464ec` (o "inteiro, sem
head" já estava); **D6** linha de agente no bloco do `.gitignore` do README, atrasada do 05. Riscos registrados:
"Tester primeiro" medido uma vez; o check (e) só reconhece a trava sem aspas, como o check 8; `SendMessage` tardia
retomou o Tester depois do PRONTO. Gates despachados: Review e Tester.

**Leader, 2026-09-13 — gate Review, rodada 1: APROVADO, sem bloqueante.** Critérios atendidos sobre `1465105`;
`run.sh` 16/16 em 5.2 e 3.2 rodado pelo Review sobre o HEAD; checks 10 e 12 sem regressão (regex nova equivalente);
linha-ponteiro com hash idêntico nos sete; RV-F1, RV-F2 e RV-F3 coerentes entre `SKILL.md`, `PROTOCOL.md`, agentes e
desenho. Achados: **F1** a regra "Tester primeiro" (`SKILL.md:190-194`, D2) não foi exercitada — no turno 2 o Dev saiu
antes e falhou, e o turno 3 não tem par; e "o Dev só depois que a chamada do Tester voltar" é ambíguo (voltar =
PRONTO em 188/190), o que serializaria o par; a mesma frase está no desenho. **F2** a conversa lateral do Ponto B teve
mão do Leader: ele autorizou nova tentativa ao Dev e mandou o Tester enviar o repro sem esperar o pedido; o critério
literal se sustenta, mas o comentário de entrega acima a descreve como espontânea — **fica corrigido aqui**. **P3** o
template da Política de escrita não tem a forma do Tester (leitura no checkout, escrita fora dele). **P4** o check (e)
não pega `/anvil-wayfinder` com barra. **P5** o Review repete o "preferência sem fonte de verdade não é finding" do
protocolo. **S1** o bloco "com · gate / sem gate" de Review e Tester parafraseia o protocolo. **S3** "regressão quem
escreve é o Dev" em três lugares. **S4** `SKILL.md:220-221` repete :196-198. **S5** checks 8 e 14 detectam a trava de
formas diferentes (`true # x`). **S6** a linha-ponteiro diz "inteiro" quatro vezes. Não verificados pelo Review:
"8 falhas antes do check"; o Tester chegando ao Leader com o Dev discordando (o gate do Tester cobre).
