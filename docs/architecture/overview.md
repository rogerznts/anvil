# Arquitetura do anvil

O anvil é um toolkit de skills para Claude Code, distribuído por `npx degit`.
Sucede o [mosk](https://github.com/rogerznts/mosk), trocando agentes-como-persona
por um conjunto curado de skills de terceiros.

A tese: **não escrever as skills de trabalho.** Curadoriza 35 skills de cinco
repositórios upstream, mantidos como submodules em `references/`, e as vendoriza
com adaptação registrada — ver
[adr-0001](./adr/adr-0001-skills-vendorizadas-seguem-o-padrao-original.md).

## As quatro camadas

```
┌─ fluxo ──────────────────────────────────────────────────┐
│  grill → to-spec → to-tickets → implement → code-review  │
│  mattpocock/skills · 21 skills                            │
├─ ofício ─────────────────────────────────────────────────┤
│  architect · arena · unslop · how · poteto · principles   │
│  cursor/plugins (pstack) · 6 skills                       │
├─ interface ──────────────────────────────────────────────┤
│  anvil-ui (roteador) → hallmark | taste | redesign        │
│                      + presets brutalist/minimalist/…     │
│  Nutlope/hallmark + Leonxlnx/taste-skill · 7 skills       │
│  payloadcms/skills · 1 skill (a stack)                    │
├─ stack ──────────────────────────────────────────────────┤
│  anvil-stack-payload: RULE · reference/ · bench/          │
│  contrato de 6 capacidades                                │
└───────────────────────────────────────────────────────────┘
      apoiadas por 9 skills autorais: docs · boot · update ·
      bench · ui · tea-* (4)
```

## O que o anvil impõe, e só isso

Uma coisa: **onde o arquivo é salvo dentro de `docs/`**. O conteúdo é
integralmente das skills originais.

```
docs/
├── index.md                    auto-gerado
├── agents/issue-tracker.md     o perfil que as skills de fluxo leem
├── architecture/               context.md · context-map.md · adr/
├── discovery/                  ●  anvil-research
├── specs/                      ●
│   ├── {NNN}-{tipo}-{nome}/       ← só a PASTA é do anvil
│   │   ├── spec.md                  to-spec, com as User Stories
│   │   ├── issues/NN-slug.md        to-tickets, com Blocked by e Status
│   │   ├── ui/                      fluxo desta mudança (anvil-grill)
│   │   └── map.md                   wayfinder, quando usado
│   └── archive/
└── prd/  ui/  qa/  project/    ○  sem escritor; nascem sob demanda
```

**●** o `scaffold` cria · **○** reconhecidos pelo `validate.sh`, mas nascem só
quando houver conteúdo. Cinco dos oito domínios do mosk existiam para agentes que
morreram com as personas; manter pasta vazia com README prometendo um autor
inexistente ensina quem lê a ignorar a árvore.

Branch é `{tipo}/{NNN}-{nome}` — string diferente da pasta, de propósito. A
resolução é por prefixo numérico, nunca por igualdade.

Como isso funciona sem reescrever as skills:
[adr-0002](./adr/adr-0002-organizacao-documental-e-um-perfil-de-tracker.md).

## Estado

Lido do disco, nunca escrito num campo — ver
[adr-0003](./adr/adr-0003-sem-maquina-de-fases.md):

```
spec.md existe                    → especificado
issues/ com Status != resolved    → em andamento
todos resolved                    → implementado
pasta sob specs/archive/          → arquivado
```

Duas exceções com fundamento: o `/anvil-bench`, headless, grava `gate.yaml`
porque um loop precisa de parada mecânica; e o hook de merge, que varre
`issues/` atrás de ticket aberto.

## Idioma

Fronteira única, na rule sempre carregada (`claude_boot.md`, injetada no
`CLAUDE.md` do projeto entre marcadores):

- **pt-BR** — conversa e toda documentação gerada
- **Inglês** — código: identificadores, comandos, caminhos, commits

As skills não são traduzidas. Skill em inglês produz documentação em pt-BR — quem
decide o idioma da saída é a regra, não o idioma do arquivo que a produz.

## Sincronização

Os submodules são pinados por commit no manifesto, e o pin **é** a base do merge
3-way. Não há snapshot a manter — ver
[adr-0004](./adr/adr-0004-sync-por-merge-3-way-sem-cache.md).

O delta medido contra o upstream: **171 linhas em 25.064 — 0,68%**. Vinte e uma
skills ficam com uma linha só, o `name:` do frontmatter.

## Herança do mosk

O core do mosk tinha 252 arquivos e 2,2 MB. Sobrevivem ~11 arquivos e dois blobs
(o hallmark e o starter do Payload), e nenhum sobrevivente é compartilhado por
mais de uma skill — cada um mora dentro da skill que o usa. O payload do `degit`
não tem diretório compartilhado: é só `.claude/skills/`.

O que sobreviveu e por quê está registrado no
[plano](../project/plan.md#o-corte-do-core-do-mosk).
