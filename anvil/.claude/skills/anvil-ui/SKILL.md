---
name: anvil-ui
description: "Roteador da camada de interface: decide QUAL método de design usar antes de qualquer código. Use ao construir landing page, portfólio, componente, ou ao redesenhar uma tela existente — e sempre que houver dúvida entre hallmark e taste, que são métodos rivais e não podem rodar juntos."
---

# Roteador de interface

O anvil adota dois métodos de design que atacam o mesmo problema — interface que
não parece gerada por LLM — por caminhos **incompatíveis**. Rodar os dois no
mesmo pedido produz instrução contraditória.

Esta skill escolhe **um**, e só um.

## O despacho

| O pedido | Método | Por quê |
|---|---|---|
| Já existe código, e a tarefa é modernizar | **anvil-ui-redesign** | audit-first: lê o que existe, extrai os tokens de marca, documenta o que funciona, e só então mexe |
| Landing ou portfólio, e o projeto já usa um design system (shadcn, Material, Fluent, Carbon, Radix) | **anvil-ui-taste** | roteia para o sistema oficial em vez de inventar CSS. *"Never invent CSS for things that have a package"* |
| Produto novo · componente isolado · partir de uma referência visual | **anvil-ui-hallmark** | é o único que cobre componente (exige os 8 estados) e o único com o verbo `study`, que extrai o DNA de uma URL ou screenshot |

Empate entre taste e hallmark? Duas perguntas resolvem:

1. **É dashboard, tabela de dados, formulário multi-etapa ou editor?** O taste
   declara esses fora de escopo. → hallmark.
2. **O projeto já tem design system instalado?** Se tem, inventar tokens novos
   briga com ele. → taste.

Continua empatado: **hallmark**, que tem o escopo mais largo.

## Por que não os dois

| | hallmark | taste |
|---|---|---|
| Decide por | catálogo: 1 de 21 macroestruturas + 1 de 20 temas OKLCH + arquétipos de nav e footer | 3 dials numéricos — `DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY` |
| Design system | **inventa** os tokens, emite `tokens.css` | **roteia para o oficial**, não escreve CSS que já vem em pacote |
| Memória entre builds | `.hallmark/log.json`, rotaciona contra os 3 últimos | rotação declarada, sem estado |
| Carga | progressiva: 107 arquivos, ~5–7 por build | monolítico: 1.206 linhas de uma vez |
| Escopo | qualquer UI, inclusive componente | só landing, portfólio, redesign |
| Gate final | 58 portas do slop-test | 80 checkboxes de pre-flight |

Eles concordam no catálogo de vícios — ambos banem em-dash, ambos proíbem a
paleta bege/latão que todo LLM produz, ambos exigem rotação. **Divergem no
método**: um manda emitir OKLCH próprio, o outro proíbe escrever CSS quando
existe pacote. Escolha um e siga até o fim.

## Presets de estilo

Aplicados **por cima** do método, nunca no lugar dele. São especificação de
fonte, paleta e layout — tema, não processo — então não conflitam com o método
escolhido.

- **anvil-ui-brutalist** — industrial, CRT, tipografia suíça. Painel denso de
  dados, portfólio, editorial que quer parecer planta baixa desclassificada
- **anvil-ui-minimalist** — contenção, espaço negativo, hierarquia por escala
- **anvil-ui-soft** — orgânico, curvas amplas, paleta quente
- **anvil-ui-stitch** — texturado, costurado, materialidade

Chame o preset **depois** do método, quando o usuário pedir uma estética nomeada
ou quando a referência dele claramente cair numa delas.

## Antes de despachar

Uma pergunta, no máximo, e só se o pedido for genuinamente ambíguo. O `taste`
tem um portão de inferência de brief e o `hallmark` tem um portão de contexto de
design — os dois já perguntam o que precisam. Perguntar aqui também é atrito
duplicado.

Declare o método escolhido numa linha antes de chamar, dizendo por quê. Quem lê
depois precisa saber que houve escolha, não sorteio.
