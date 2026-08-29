---
name: anvil-docs
description: "Organização documental do anvil: onde cada documento mora, como a spec se chama, e o que acontece com ela quando fecha. Use para montar a árvore docs/ num projeto novo, adotar um docs/ existente e bagunçado, regenerar o índice, ou arquivar uma spec promovendo o que virou canônico."
---

# Organização documental

Esta skill responde três perguntas: **onde o documento mora**, **como ele se
chama** e **o que acontece com ele quando a spec fecha**.

Ela cobre só o que as skills de fluxo não cobrem. O **conteúdo** de `spec.md` e
dos tickets é integralmente das skills originais — o anvil define a pasta, não o
que vai dentro dela.

## Verbos

| verbo | quando | onde está |
|---|---|---|
| `scaffold` | projeto novo, `docs/` vazio ou ausente | aqui embaixo |
| `adopt` | `docs/` existente com conteúdo fora do padrão | [ADOPT.md](ADOPT.md) |
| `index` | depois de criar, mudar ou arquivar spec | [INDEX.md](INDEX.md) |
| `archive` | spec fechada | [ARCHIVE.md](ARCHIVE.md) |

Sem verbo explícito: se `docs/` não existe ou só tem os README de domínio, é
`scaffold`. Se tem conteúdo, é `adopt` — nunca presuma que dá para só criar por
cima.

## A árvore canônica

```
docs/
├── index.md                    gerado pelo verbo `index`
├── agents/issue-tracker.md     o perfil que as skills de fluxo leem
├── discovery/                  pesquisa, briefing, brainstorming
├── prd/                        escopo de produto
├── architecture/               desenho do sistema
│   ├── context.md                glossário ubíquo do domínio
│   ├── context-map.md            só em repositório multi-contexto
│   └── adr/                      decisões, uma por arquivo
├── ui/                         design system, fluxos, wireframes
├── qa/gates/                   só em projeto criado pelo /anvil-bench
├── project/                    plan.md + update-YYYYMMDD.md
└── specs/
    ├── {NNN}-{tipo}-{nome}/
    │   ├── spec.md               /anvil-to-spec
    │   ├── issues/NN-slug.md     /anvil-to-tickets, um arquivo por ticket
    │   ├── map.md                /anvil-wayfinder, quando usado
    │   ├── prd-delta.md          opcional, quando a spec muda o PRD
    │   ├── discovery/            opcional, pesquisa da própria spec
    │   ├── architecture/         opcional, ADRs e modelos da spec
    │   ├── ui/                   opcional, fluxos e componentes da spec
    │   └── project/              opcional, acompanhamento da spec
    └── archive/                  specs concluídas
```

Duas camadas espelhadas: **base**, que é a verdade do projeto hoje, e
**por spec**, que é o escopo de uma mudança pendente.

**A regra de decisão:**

- Descreve o projeto **como ele é hoje** → `docs/<domínio>/`
- É **específico de uma mudança pendente** → `docs/specs/{id}/<domínio>/`
- Nasceu numa spec mas virou canônico → **fica na spec** e é **promovido** no
  arquivamento

Não há `spec-meta.yaml`, `tasks.md` nem `gate.yaml` no fluxo normal. O estado é
lido do disco: `spec.md` existe → especificado; `issues/` com `Status:` diferente
de `resolved` → em andamento; todos `resolved` → implementado; pasta sob
`archive/` → arquivado.

## Nome da spec: branch e pasta são strings diferentes

```
branch:  {tipo}/{NNN}-{nome}        →  feature/012-checkout-coupon
pasta:   docs/specs/{NNN}-{tipo}-{nome}  →  docs/specs/012-feature-checkout-coupon
```

O tipo aparece nos dois, **em posições diferentes**: no branch é um segmento de
caminho, que agrupa no `git branch`; na pasta é parte do nome, o que mantém
`docs/specs/` plano, sem um nível de diretório por tipo.

**Resolva sempre pelo prefixo numérico, nunca por igualdade de string.** Código
que assume `branch == nome da pasta` quebra. A transformação é determinística — o
segmento antes da `/` é o tipo, o resto é `{NNN}-{nome}` — mas as duas strings
nunca são iguais.

Tipos: `feature` · `fix` · `hotfix` · `gmud` · `refactor` · `experimental` ·
`extension`.

Trabalho sem spec usa `{tipo}/{nome}` **sem número** — `chore/`, `docs/`, `ci/`,
`build/`. O número é o que marca "isto tem spec"; usá-lo fora disso torna a marca
inútil.

## Promoção

Artefato dentro de `specs/{id}/` que deve virar canônico declara destino e modo
no front-matter:

```yaml
---
promote: docs/architecture/adr/adr-0007-coupon-service.md
promote_mode: copy
---
```

| modo | comportamento no arquivamento |
|---|---|
| `copy` | copia para o destino; se já existir, pergunta antes |
| `append` | anexa o corpo, sem o front-matter, ao fim do destino |
| `manual` | não aplica; imprime o arquivo e o destino sugerido para o usuário aplicar |

Sem `promote:`, o artefato congela dentro da spec arquivada e não toca a base.

O front-matter precisa começar na coluna zero. Um mapa raiz inteiramente
indentado falha antes da leitura.

**Escreva o artefato para onde ele vai morar, não para onde está.** O modo `copy`
exige que o destino fique idêntico à origem, então link relativo tem que resolver
no **destino**.

## `scaffold`

1. Criar as pastas que faltam. **Nunca sobrescrever** uma que já existe.
2. Cada pasta de domínio recebe um `README.md` curto dizendo quem escreve ali.
3. Chamar o `anvil-setup` para escrever `docs/agents/issue-tracker.md` a partir
   do perfil em [templates/issue-tracker-anvil.md](templates/issue-tracker-anvil.md).
   É esse arquivo que faz as skills de fluxo publicarem em `docs/specs/` sem
   conhecerem esse caminho.
4. Rodar o verbo `index`.

Se `docs/` já tiver conteúdo fora dos domínios canônicos, **pare e use `adopt`**.

## Contrato de stack

Adicionar uma stack ao anvil é preencher seis lacunas conhecidas, sem tocar no
fluxo do bench. O contrato está em [STACK-CONTRACT.md](STACK-CONTRACT.md).

## Verificação

- `bash scripts/validate.sh docs-paths` — as saídas declaradas ficam sob os
  domínios canônicos. Consultivo, não bloqueia.
- `bash scripts/validate.sh ship-ready` — a spec do branch atual está fechada.
  É o que o hook de merge chama.
