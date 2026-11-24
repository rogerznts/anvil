---
name: anvil-ui
description: "Roteador da camada de interface: decide QUAL método de design usar antes de qualquer código. Use ao construir ou redesenhar página, site, tela de app ou componente — e sempre que houver dúvida entre hallmark e taste, que são métodos rivais e não podem rodar juntos."
---

# Roteador de interface

O anvil adota dois métodos de design que atacam o mesmo problema — interface que
não parece gerada por LLM — por caminhos **incompatíveis**. Rodar os dois no
mesmo pedido produz instrução contraditória.

Esta skill escolhe **um**, e só um.

## O despacho

A primeira linha que casar decide.

| # | O pedido | Método | Por quê |
|---|---|---|---|
| 1 | O usuário nomeia um dos dois: Hallmark, `/hallmark`, um tema do catálogo do hallmark, taste ou tasteskill | **o nomeado** | o pedido já escolheu. É também a única porta para o `redesign` e o `audit` do hallmark, que ele só roda quando nomeado |
| 2 | Mexe num site ou página que já existe: redesenhar, restyle, polir, revisar | **anvil-ui-taste** | o hallmark manda não rodar em design existente sem ser nomeado. O taste declara redesign, restyle, polimento e review de site como caso próprio, e o gate mede o resultado num navegador real |
| 3 | Um componente isolado e novo: botão, input, card, modal, nav, footer | **anvil-ui-hallmark** | tem escopo próprio de componente: entrega o componente e um preview que mostra os oito estados. O taste só constrói site |
| 4 | Tela de app, nova ou existente: dashboard, admin, configurações, ferramenta | **anvil-ui-hallmark** | o hallmark trata tela de app em `flow.md` § App screens. O taste 2.5 é skill de site de empresa: mostra a UI do produto dentro do site, mas não constrói a tela |
| 5 | Pede um visual fora do sistema fechado do taste — o brutalista, o terminal, o soft | **anvil-ui-hallmark** | o taste tem um sistema só, com a barra em figma.com e x.ai, e nenhum tema para esses tons. O hallmark pergunta o tom e tem esses materiais no catálogo de temas, como `brutal`, `terminal` e `console` |
| 6 | Página nova num projeto que já tem build de um dos dois: `.hallmark/` ou `.taste-skill/` na raiz | **o mesmo** | o projeto já guarda o estado do método — o log de rotação do hallmark em `.hallmark/log.json`, os históricos de deal e o gate do taste em `.taste-skill/` —, e trocar de método no meio do projeto o perde |
| 7 | Extrair o design de uma URL ou de um screenshot de referência: estudar, ler o DNA, "quero que fique como este site" | **anvil-ui-study** | nem o hallmark nem o taste leem uma referência desde que o hallmark tirou o verbo `study`, e o taste proíbe copiar código, texto ou efeito de um site de referência. O study recusa template pago, diagnostica antes de qualquer código e leva só a estrutura, nunca o pixel; ele não constrói |
| 8 | Qualquer outro pedido: página ou site novo | **anvil-ui-taste** | o escopo de site mais largo — landing, empresa, produto, loja, lugar, SaaS, jogo — e um gate de acabamento que mede em navegador real |

A linha 8 existe para a tabela ser **total**: sempre há uma resposta, e ela
nunca é "os dois".

A linha 7 não é um terceiro método. O study termina entregando ao hallmark: grava
o DNA como `design.md` na raiz do projeto e chama o **anvil-ui-hallmark**, que lê
esse arquivo como sistema travado. Um build que parte de um study é, portanto,
sempre do hallmark, nunca do taste.

**Dependência.** O taste precisa de Node 22+ e de um Chrome, Edge ou Chromium
para os scripts de checagem e para o `gate.mjs`; sem eles, o gate sai com
`GATE: ERROR` ou `GATE: OFF`, e o taste põe essa linha no relatório. No Claude
Code, o frontmatter do taste registra um hook `Stop` que roda o gate ao fim da
resposta. Falta de ferramenta não muda o despacho: avise o usuário na linha da
escolha.

## Por que não os dois

| | hallmark | taste |
|---|---|---|
| Declara-se para | site e página nova, componente e tela de app; design existente só quando nomeado (`redesign`, `audit`) | construir, redesenhar, restyle, polir ou revisar site de empresa: landing, produto, loja, lugar, SaaS, jogo |
| Decide por | `theme.mjs deal`: três temas de um catálogo de 50, e o agente escolhe o que o material aguenta; `theme.mjs draw` sorteia a forma entre 21 macroestruturas, o hero, a nav e o footer. Rota `custom` só quando pedida | o tipo de negócio decide tudo; `deal.mjs` sorteia o hero, `start.mjs deal` dá três paletas feitas para o ramo e três pares de tipo, e `moments.mjs pick` sorteia os momentos. O agente pega o primeiro, sem escolher por gosto |
| Antes de construir | uma mensagem com quatro perguntas: material, público, uso, tom | não pergunta: lê o brief, escreve o tipo, o que se vende e a ação principal, e arma o gate |
| Memória entre builds | `.hallmark/log.json` no projeto | `.taste-skill/` no projeto: os históricos de deal e o estado do gate |
| Tokens | o `theme.mjs scaffold` escreve `tokens.css` e `base.css` | o `start.mjs css` imprime o bloco `:root`, sobre o kit `assets/` copiado para o projeto |
| Marca ou design system do projeto | o pre-flight preserva fontes, paleta e espaçamento; um `design.md` trava o sistema | `start.mjs brand` com as cores do cliente, no lugar das paletas sorteadas |
| Tela de app | `flow.md` § App screens | não constrói; só mostra a UI do produto dentro do site, num `app-frame` |
| Gate | o Floor de 16 itens e o `sloplint.mjs --render`, depois uma revisão em contexto novo | `copy-lint.mjs`, `consistency.mjs`, `check.mjs`, `shoot.mjs` e `perf.mjs` de 1440 a 390, depois o `gate.mjs` até `GATE: PASS`, três rodadas no máximo |
| Dependências | Node opcional: sem ele, o tema sai à mão do `references/themes/index.json`; o render usa `puppeteer-core` | Node 22+ e Chrome, Edge ou Chromium; ffmpeg opcional |

Concordam no catálogo de vícios — ambos banem eyebrow, rótulo em caixa-alta
espaçada, métrica e depoimento inventados, e exigem `prefers-reduced-motion`.
**Divergem no método**: o hallmark parte de um tema como material e do que o
usuário tem para mostrar; o taste parte do tipo de negócio e mede a
casa num navegador real. Escolha um e siga até o fim.

## Antes de despachar

Uma pergunta, no máximo, e só se o pedido for genuinamente ambíguo entre duas
linhas. O hallmark já pergunta material, público, uso e tom; o taste decide e
declara a leitura. Perguntar aqui também é atrito duplicado.

Declare o método escolhido numa linha antes de chamar, com o número da linha do
despacho e o porquê. Quem lê depois precisa saber que houve escolha, não sorteio.
