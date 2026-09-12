# Domain docs

Como as skills devem consumir a documentação de domínio deste repositório
enquanto exploram o código.

## Antes de explorar, leia

- **`docs/architecture/context.md`** — o glossário ubíquo do projeto
- **`docs/architecture/context-map.md`**, se existir: aponta para um
  `context.md` por contexto. Este repositório é single-context, e o arquivo não
  existe
- **`docs/architecture/adr/`** — os ADRs que tocam a área em que você vai mexer

Se algum deles não existir, **siga em silêncio**. Não sinalize a ausência e não
sugira criar de antemão. O `/anvil-domain-modeling` — alcançado pelo
`/anvil-grill` e pelo `/anvil-codebase-design` — cria esses arquivos quando um
termo ou uma decisão realmente se resolve.

## Estrutura

Single-context, que é o caso deste repositório:

```
docs/
├── architecture/
│   ├── context.md
│   └── adr/
│       ├── adr-0001-skills-vendorizadas-seguem-o-padrao-original.md
│       └── adr-0002-organizacao-documental-e-um-perfil-de-tracker.md
└── specs/
```

Multi-context — um `context-map.md` na raiz de `architecture/` apontando para um
`context.md` por contexto — só aparece em repositório genuinamente
multi-pacote. Não é o caso aqui.

## Use o vocabulário do glossário

Quando a sua saída nomear um conceito do domínio — título de ticket, proposta de
refatoração, hipótese, nome de teste — use o termo como o `context.md` o define.
Não derive para sinônimos que o glossário evita de propósito.

Se o conceito ainda não está no glossário, isso é sinal: ou você está inventando
linguagem que o projeto não usa, e vale reconsiderar, ou existe uma lacuna real,
e ela é anotada para o `/anvil-domain-modeling`.

## Sinalize conflito com ADR

Se a sua saída contradiz um ADR existente, diga isso explicitamente em vez de
passar por cima em silêncio:

> *Contradiz o `adr-0003` — sem máquina de fases: o artefato é o estado — mas
> vale reabrir porque…*
