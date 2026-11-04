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
| 2 | Mexe num design que já existe: redesenhar, restyle, polir, revisar | **anvil-ui-taste** | o hallmark manda não rodar em design existente sem ser nomeado. O taste trata redesign, restyle e review de página ou de tela de app como caso próprio, com medição antes e depois |
| 3 | Um componente isolado e novo: botão, input, card, modal, nav, footer | **anvil-ui-hallmark** | tem escopo próprio de componente: entrega o componente e um preview que mostra os oito estados. O taste trata componente como caso à parte, sem esse preview |
| 4 | Pede um visual que a casa do taste proíbe: monospace fora de código, fio fino, gradiente, sombra em repouso — o brutalista, o terminal, o soft | **anvil-ui-hallmark** | o taste proíbe esses recursos sem exceção. O hallmark pergunta o tom e tem esses materiais no catálogo de temas, como `brutal`, `terminal` e `console` |
| 5 | Página ou tela de app nova num projeto que já tem build de um dos dois: `.hallmark/` ou `.taste-skill/` na raiz | **o mesmo** | o projeto já guarda o estado do método — o log de rotação do hallmark em `.hallmark/log.json`, a folha de direção do taste em `.taste-skill/direction.json` —, e trocar de método no meio do projeto o perde |
| 6 | Extrair o design de uma URL ou de um screenshot de referência: estudar, ler o DNA, "quero que fique como este site" | **anvil-ui-study** | nem o hallmark nem o taste leem uma referência desde que o hallmark tirou o verbo `study`. O study recusa template pago, diagnostica antes de qualquer código e leva só a estrutura, nunca o pixel; ele não constrói |
| 7 | Qualquer outro pedido: página, site ou tela de app nova | **anvil-ui-taste** | o escopo declarado mais largo — página e tela de app, nova ou existente — e um gate que mede em navegador real em três larguras |

A linha 7 existe para a tabela ser **total**: sempre há uma resposta, e ela
nunca é "os dois".

A linha 6 não é um terceiro método. O study termina entregando ao hallmark: grava
o DNA como `design.md` na raiz do projeto e chama o **anvil-ui-hallmark**, que lê
esse arquivo como sistema travado. Um build que parte de um study é, portanto,
sempre do hallmark, nunca do taste.

**Dependência.** O taste precisa de Node 22+ e de um Chrome, Edge ou Chromium
para o `inspect.mjs`; sem eles, ele mesmo degrada para o `lint.mjs` e para
screenshots por outra via, e diz isso no relatório. Falta de ferramenta não muda
o despacho: avise o usuário na linha da escolha.

## Por que não os dois

| | hallmark | taste |
|---|---|---|
| Declara-se para | site e página nova; design existente só quando nomeado (`redesign`, `audit`) | construir, redesenhar, restyle, polir ou revisar página pública, e tela de app |
| Decide por | `theme.mjs deal`: três temas de um catálogo de 50, e o agente escolhe o que o material aguenta; `theme.mjs draw` sorteia a forma entre 21 macroestruturas, o hero, a nav e o footer. Rota `custom` só quando pedida | `draw.mjs`: três de 20 direções, e o agente escolhe contra um inventário do assunto; a direção escolhida dá a folha com tipo, paleta, hero, seções e movimento |
| Antes de construir | uma mensagem com quatro perguntas: material, público, uso, tom | não pergunta: lê o brief, decide e declara a leitura numa linha |
| Memória entre builds | `.hallmark/log.json` no projeto | `~/.taste-skill/history.json`, do usuário; a folha do build em `.taste-skill/` no projeto |
| Tokens | o `theme.mjs scaffold` escreve `tokens.css` e `base.css` | tokens da folha como custom properties; `assets/base.css` é base opcional |
| Marca ou design system do projeto | o pre-flight preserva fontes, paleta e espaçamento; um `design.md` trava o sistema | `--keep palette,type`: o deal dá só a composição |
| Tela de app | `flow.md` § App screens | `references/app-screens.md`, com run e deal próprios (`draw.mjs --app`) |
| Gate | o Floor de 16 itens e o `sloplint.mjs --render`, depois uma revisão em contexto novo | `lint.mjs` e `inspect.mjs` a 1440, 768 e 390, depois crítica dos screenshots por rubrica, até três rodadas |
| Dependências | Node opcional: sem ele, o tema sai à mão do `references/themes/index.json`; o render usa `puppeteer-core` | Node 22+ e Chrome, Edge ou Chromium |

Concordam no catálogo de vícios — ambos banem eyebrow, rótulo em caixa-alta
espaçada, métrica e depoimento inventados, e exigem `prefers-reduced-motion`.
**Divergem no método**: o hallmark parte de um tema como material e do que o
usuário tem para mostrar; o taste parte de uma ideia tirada do assunto e mede a
casa num navegador real. Escolha um e siga até o fim.

## Antes de despachar

Uma pergunta, no máximo, e só se o pedido for genuinamente ambíguo entre duas
linhas. O hallmark já pergunta material, público, uso e tom; o taste decide e
declara a leitura. Perguntar aqui também é atrito duplicado.

Declare o método escolhido numa linha antes de chamar, com o número da linha do
despacho e o porquê. Quem lê depois precisa saber que houve escolha, não sorteio.
