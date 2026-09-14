# 07: `anvil-team`: os outros cinco papéis e a conversa entre papéis

**What to build:** A equipe fica completa: PO, Architect, Analyst, Designer e Tester são despachados pelo Leader como Dev e Review já são. Dois papéis conversam direto — o Dev pede um repro ao Tester sem passar pelo Leader — e o julgamento do Tester chega ao Leader mesmo quando o Dev discorda. A documentação para de dizer que o anvil não tem agentes.

**Blocked by:** 06

**Status:** resolved

- [x] `anvil-team-po`, `anvil-team-architect`, `anvil-team-analyst`, `anvil-team-designer` e `anvil-team-tester` existem no payload, com descriptions que não atraem delegação automática.
- [x] Cada papel guarda só o que é dele; o comum fica no protocolo.
- [x] As skills citadas pelos papéis existem no payload: `anvil-diagnose`, `anvil-tdd` e `anvil-code-review` no lugar dos nomes inexistentes da configuração de origem.
- [x] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 07.
- [x] O `verify` reprova agente que cita skill inexistente no payload ou skill com trava de invocação.
- [x] O PO não cita `anvil-to-questionnaire`; o Leader sugere `/anvil-wayfinder` e `/anvil-handoff` ao usuário em vez de despachá-las.
- [x] RV-F1 (gate Review do 06): o Tester despachado junto com o Dev deixa de contradizer "um escritor por vez neste checkout" — exceção explícita com commit coordenado, ou o Tester escreve fora do checkout.
- [x] RV-F2 (gate Review do 06): a regra de divergência e os campos do finding ficam num lugar só (protocolo), sem cópia nos papéis.
- [x] RV-F3 (gate Review do 06): o papel Review (e o Tester) contempla a delegação sem gate prevista no protocolo.
- [x] TS-F1 (gate Tester do 06): a linha-ponteiro dos sete agentes manda ler o protocolo INTEIRO antes de agir; um fluxo de reteste mostra o Dev lendo o arquivo todo e carregando a skill delegada pela Skill tool.
- [x] TS-R1 (gate Tester do 06): com os sete papéis existindo, um ticket chega a `resolved` pela equipe com os gates de Review e Tester.
- [x] O README e o overview dizem que o anvil distribui agentes e a skill de equipe, apontando o ADR-0007.
- [x] Ponto B: uma mensagem do Dev chega ao Tester sem passar pelo Leader; o julgamento do Tester chega ao Leader; cada um dos cinco papéis é despachado ao menos uma vez.

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

**Leader, 2026-09-13 — gate Tester, rodada 1: REPROVADO.** Isolado, payload de `14b8563`, projeto Python diferente
do do Dev, sete execuções, US$ 8,67. Passaram: divergência provocada — o gate do Tester reprovou, o Dev discordou, e o
julgamento chegou ao Leader e ficou literal no ticket, que voltou a `ready-for-agent`; um ticket chegou a `resolved`
com os dois gates; onze despachos (os cinco papéis novos inclusive), todos com `cat` do protocolo inteiro e a skill
da delegação pela Skill tool, subagentes de skill em foreground; o Review sem `Edit`/`Write` nem por `ToolSearch`;
"revisa esse diff" com os sete instalados não despachou papel. **F1 (bloqueante)** — a medição do F1 do Review: "o
Dev só depois que a chamada do Tester voltar" foi lido como esperar o PRONTO em 2 de 2 tickets; o par nunca ficou vivo
junto, zero `SendMessage` entre papéis no fluxo natural, e o repro chegou ao Dev colado pelo Leader na delegação. A
lateral só aconteceu quando o prompt pediu, retomando um Tester já encerrado. **F2** o Dev encerrou "esperando a
resposta do tester-02" com `sleep 60` em background, sem palavra do protocolo, e depois emitiu três retornos. **F3**
medido na 2.1.270: travam `true`, `True`, `yes`, `1`, `"true"`, tab, `true # x` e BOM; não travam `false`, `no`,
`"false"` — os checks 8 e 14 só reconhecem `true`. **F4** o check (e) não vê `skills:` no frontmatter do agente, agente
em subdiretório, span com argumento, cerca com crase no info string, span em duas linhas, e reprova bloco indentado.
**F5** o Tester em gate fez `git worktree add` no checkout e removeu em seguida. Fora do 07: SIGTRAP do `/bin/bash`
3.2 no `verify` desta máquina (anterior); CRLF reprova o check 1.

Decisão do Leader para a rodada de ajuste (a mesma, já em curso com o Dev): **F1** "voltar" = a chamada `Agent` do
Tester devolver o lançamento; o Dev é despachado logo em seguida, com o Tester vivo; o Leader não cola o repro na
delegação do Dev — ele chega por `SendMessage` do Tester; alinhar `SKILL.md`, agente do Tester e desenho §5 (Architect).
**F2** no protocolo: papel não encerra à espera de lateral; retorno sem palavra do protocolo não é entrega; retorno
repetido não se registra. **F3** entra no S5 do Review: os checks 8 e 14 reconhecem a trava como o Claude Code
(`true`/`yes`/`1`, maiúsculas, aspas, comentário, tab, BOM). **F5** o agente do Tester nomeia que nada escreve no `.git`
do checkout (sem `git worktree add`). Ficam como ideia: **F4** (exceto o que o F3 cobre), CRLF no check 1. Reteste do
Tester: caso 1 com F2, e o ataque ao check (e)/trava.

**Leader, 2026-09-13 — rodada de ajuste** em `7f43a23`, `24af185`, `e09539d`, `0619011`, `1ed719e`, `7d87cff` e
`2840c70`; desenho pelo Architect em `08429ec`, `2133935`, `6f961a7` e `162754f`. **F1** o Dev sai logo que a chamada
`Agent` do Tester devolve o lançamento, sem esperar o PRONTO; o repro não é colado na delegação do Dev e chega por
`SendMessage`. **F2** no protocolo: mensagem final sem palavra do protocolo não é entrega (o Leader pede o retorno);
retorno repetido sem trabalho novo não se registra; papel não encerra à espera de lateral. **F5** o Tester não escreve
no `.git` do checkout. **P3** template da Política de escrita com a forma do Tester. **P4** check 14 pega `/anvil-…`.
**S5 + F3** checks 8 e 14 usam uma função só, `tem_trava`, portada da leitura do Claude Code 2.1.270 (booleano; texto
`1`/`true`/`yes`/`on` sem caixa; BOM; segunda tentativa de parse). **P5, S3, S4** fonte única. Fixtures do check (e) e
da trava 52/52 em 5.2 e 3.2 (contra o script anterior, 12 falhas); `15-team` 21/21; `verify` limpo; linha-ponteiro
com o mesmo hash nos sete. Ponto B do par, um run isolado (US$ 2,02), sem o prompt pedir lateral: Tester às 22:33:50,
Dev às 22:34:02, antes de qualquer notificação; o Dev pediu o repro por `SendMessage`, seguiu em TDD e recebeu a
resposta no meio do trabalho; zero `sleep`; todo fim de turno com palavra do protocolo.

Desvios aceitos: **D-a** o Dev aponta para a própria Política de escrita, não para o arquivo do Tester (quebraria em
worktree); **D-b** `on` e a segunda tentativa de parse vêm da leitura do binário, sem `claude -p`; **D-c** o Leader pede o
retorno quando a mensagem final vem sem palavra; **D-d** CRLF sem fixture (ideia). Riscos registrados: a linha Equipe
nomeia o diretório do Tester, e o Dev achou o harness no disco antes da mensagem (mantido: o Dev pediu por
`SendMessage`, e o caminho é útil); PyYAML (YAML 1.1) pode divergir do Bun.YAML em `0b1`, `1e0`, `0o1`; o
`apply_invocable` só apaga `true`, e uma trava `yes` de upstream faz o check 8 reprovar alto; três leitores de
frontmatter no `vendor-sync`. Reteste do Tester e revisão do diff da rodada pelo Review despachados.

**Leader, 2026-09-13 — gate Review, rodada 2: APROVADO, sem bloqueante.** Diff `14b8563..2840c70` e desenho até
`162754f`. F1, F2 (para autor), F3 + S5, F5, P3, P4, P5 e S4 atendidos; o `tem_trava` conferido contra as strings do
binário 2.1.270 e julgado proporcional (a segunda tentativa de parse é necessária: um `SKILL.md` real de
`references/` quebra o primeiro); checks 8 e 14 coerentes com o `apply_invocable` (reprova alto, nunca em silêncio);
52/52 e 21/21 em 5.2 e 3.2; `verify` limpo em `22c1f25`; 17 casos de borda do `tem_trava`. Correção do registro da
rodada: contra o script de `14b8563` são 18 falhas de fixture, não 12. Achados: **RV2-F1** "mensagem final sem palavra
não é entrega, o Leader pede o retorno por `SendMessage`" (`PROTOCOL.md:78-79`) colide com "rodada nunca vai por
`SendMessage`" e "o veredito é sempre o resultado de uma chamada `Agent`" quando quem encerra sem palavra é um gate.
**RV2-S1** corrida inversa: o Tester sem gate manda o repro antes de o Dev existir e, pelo protocolo, volta
`BLOQUEADO`. **RV2-S2** o S3 ficou parcial (regra em `SKILL.md` e no Tester, públicos diferentes). **RV2-S3** com o
Tester retomado depois do PRONTO, qual PRONTO libera o gate — o último. **RV2-S4** desenho §6 sem as regras do F2.
**RV2-S5** redação (negrito em proibição, linha longa, `.git` sem crase). **RV2-S6** identificadores em pt-BR, no estilo
do script. Risco: harness do Tester em `/tmp` com pasta fixa rodado ao mesmo tempo pelo par deu falso vermelho.

**Leader, 2026-09-13 — gate Tester, rodada 2: APROVADO.** Isolado, payload de `22c1f25`, projeto horas, quatro runs de
equipe e três sondas, US$ 6,94. **F1** em duas amostras sem o prompt pedir lateral: Dev despachado 12 s depois do
Tester e antes do PRONTO dele; delegação do Dev sem o repro; `SendMessage` nos dois sentidos (Dev pede, Tester manda
caminho e comando antes do PRONTO); repro fora do checkout. **F2** nenhum `sleep`, todo fim de turno com palavra do
protocolo; Tester retomado voltou PRONTO duas vezes com trabalho novo (retorno sem palavra não apareceu). **F5** gate do
Tester só com git de leitura; vigia do `.git` a cada segundo sem escrita em index, refs ou worktrees. **F3 e P4**
20/20 formas certas nos checks 8 e 14 em 5.2 e 3.2; `/anvil-…` com barra reprova; `on` medido: trava. Regressão: um
ticket chegou a `resolved` com os dois gates. Achados: **F6** (relevante, regressão do `tem_trava`) — tab no meio de
um valor ou caractere de controle que o PyYAML recusa e o Claude Code aceita faz as duas tentativas falharem, e uma
trava `true` canônica passa pelos checks (o 2.1.270 recusa a skill; o script de `14b8563` reprovava); latente, nenhum
`SKILL.md` do payload tem esses caracteres. **F7** (sugestão) YAML 1.1 × 1.2 medido: `1e0` e `0o1` travam no Claude Code
e o check não vê; `0b1`, `0_1` e `0:01` não travam e o check reprova. Riscos: `SendMessage` enfileirada para um papel que
encerra sem nova rodada de ferramenta não chega (2 de 2) — só Laterais garante a entrega; o Tester sem gate lê um
checkout em edição (passou a usar `git archive`).

Com o gate do Review, os gates da rodada 2 passaram. Passada curta antes de resolver, conferida pelo Leader: RV2-F1,
RV2-S1, RV2-S3 e **F6** (sanear antes do parse o que o PyYAML recusa, com as fixtures do Tester). F7 fica como ideia.

**Leader, 2026-09-13 — resolvido.** Passada curta em `098858d` e `d447e49`, conferida pelo Leader: **RV2-F1** em PROTOCOL
§ Gates, gate que encerra sem veredito não é cobrado por `SendMessage` — o Leader o redespacha com `Agent` novo e o
mesmo name, na mesma rodada; § O retorno aponta para lá (a regra fica no protocolo porque o papel não lê o `SKILL.md`).
**RV2-S1** o Tester sem gate que recebe "No agent named … is reachable" do autor segue preparando, tenta de novo antes do
PRONTO e, se falhar, põe o repro em Laterais. **RV2-S3** o gate do Tester sai depois do último PRONTO da delegação sem
gate. **F6** o `tem_trava` troca por espaço, antes do parse, o que o YAML não aceita como imprimível e todo tab fora da
indentação: seis fixtures novas (ESC, U+0092, form feed, tab no meio do valor, DEL, U+FFFE) com 12 falhas antes da
correção; `18-team-roles` 64/64 e `15-team` 21/21 em 5.2 e 3.2 (rodado também pelo Leader); `e-attack2` do Tester sem
divergência nos casos do F6 (sobram as do F7 e do F4, ideias); 36 de 41 formas medidas no 2.1.270 certas, antes 30.
`verify` limpo; linha-ponteiro com o mesmo hash nos sete. Com os gates da rodada 2 de Review e Tester, fecha sobre
`d447e49`.

Ficam como ideia: S1 e S6 do Review da rodada 1; RV2-S2, RV2-S4 (desenho §6 sem as regras do F2), RV2-S5 e RV2-S6; F4 do
Tester (pontos cegos do check e); F7 (YAML 1.1 × 1.2); CRLF no check 1. Riscos: `SendMessage` enfileirada para papel que
encerra sem nova rodada de ferramenta não chega — Laterais é o que garante; o Tester sem gate lê checkout em edição;
harness com pasta fixa rodado pelo par ao mesmo tempo; "Tester primeiro" medido em três amostras de uma sessão cada.
