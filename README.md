# anvil

Toolkit de skills para Claude Code. Sucede o [mosk](https://github.com/rogerznts/mosk),
trocando agentes-como-persona por um conjunto curado de skills.

O anvil não escreve as próprias skills de trabalho — ele **curadoriza** skills de
quatro repositórios upstream (mantidos como submodules em `references/`) e as
vendoriza com adaptação registrada num manifesto.

## A regra que governa tudo

> Tudo funciona no padrão das skills originais. A única coisa que o anvil impõe
> é **onde** o arquivo é salvo dentro de `docs/`. Bateu dúvida, o padrão é o da
> skill original.

Isso é possível porque as skills do Matt Pocock não têm caminho fixo: elas leem
`docs/agents/issue-tracker.md`, um documento do projeto. **A organização
documental do anvil é um perfil de tracker**, ao lado de github, gitlab e local
— não um alvo de reescrita.

## Greenfield

```
$ npx degit rogerznts/anvil/anvil .
$ claude
> /anvil-boot
```

O boot varre o projeto, injeta o `claude_boot.md` no `CLAUDE.md` entre
marcadores, gera `.claude/rules/project.md` e `anvil.md`, chama
`anvil-docs scaffold` para montar a árvore e `anvil-setup` para escrever o
arquivo que destrava o resto:

```
docs/agents/issue-tracker.md
  ┌────────────────────────────────────────────────┐
  │ # Issue tracker: anvil docs/specs              │
  │ - Uma spec por diretório:                      │
  │   docs/specs/{NNN}-{tipo}-{nome}/              │
  │ - Tickets: issues/, um arquivo por ticket      │
  │ - Publish → rode new-spec.sh                   │
  └────────────────────────────────────────────────┘
```

Depois detecta a stack (achou `payload.config.ts`?) e **propõe**
`.claude/rules/payload.md`; sugere rules adicionais com evidência; registra o
hook de merge e confirma que ele dispara. Nada disso escreve sem aprovação.

O trabalho então:

```
> /anvil-grill    "cupom de desconto no checkout"
```
Entrevista. Sai com `docs/architecture/context.md` atualizado e um ADR novo em
`docs/architecture/adr/`.

```
> /anvil-to-spec
```
Ela lê `docs/agents/issue-tracker.md`, que manda rodar `new-spec.sh`. O script
reserva o `012` atomicamente no `origin`, cria o branch
`feature/012-checkout-coupon` e a pasta `docs/specs/012-feature-checkout-coupon/`.
Aí ela escreve o `spec.md` com o template que já carrega por dentro.

**Repare: a skill não sabe o que é `docs/specs/`.** Ela seguiu um perfil. É isso
que a mantém idêntica ao upstream.

```
> /anvil-to-tickets
```
Um arquivo por ticket em `issues/`, numerado a partir de `01` em ordem de
dependência. Cada arquivo declara suas arestas:

```markdown
# 03: Aplicar cupom no total do carrinho

**Blocked by:** 01, 02
**Status:** ready-for-agent

- [ ] Critério de aceite 1
```

A ordem não vem de um índice — vem do `Blocked by`. A *frontier* é qualquer
ticket cujos bloqueadores estão todos `resolved`.

```
> /clear                      ← contexto limpo entre tickets
> /anvil-implement            ← um por vez; chama tdd por dentro, depois code-review
```

Grill, spec e tickets ficam numa janela só — é o que o fluxo do Matt exige, e o
que faz o encadeamento funcionar sem estado em disco. Cada `implement` começa do
zero, e **o ticket é o estado**.

```
> git merge  →  hook varre issues/ atrás de Status: != resolved  →  bloqueia
> /anvil-docs archive
```
Promove o ADR da spec para `docs/architecture/adr/`, move a pasta para
`specs/archive/`, re-indexa.

## Brownfield

O boot é o mesmo até a varredura. A diferença é que ele encontra isto:

```
docs/
├── notes.md                  ← solto na raiz
├── prd.md                    ← monolito
├── architecture.md           ← monolito
├── stories/                  ← global, sem spec dona
├── brainstorming-2024.md
└── front-end-spec.md
```

Então chama `anvil-docs adopt`:

1. **Survey.** Tabela de três colunas — *caminho · o que parece ser · onde iria*.
   Nada se move ainda.
2. **Scaffold.** Cria só o que falta.
3. **Classifica lendo o arquivo, não o nome.** `notes.md` pode ser discovery, PRD
   ou arquitetura; só o conteúdo decide. Monolito só é fatiado se for
   genuinamente vários documentos grampeados — não se fatia por fatiar.
4. **`docs/stories/` global** vai para o `issues/` da spec que o possui. Ticket
   sem spec dona é **reportado, não adivinhado**.
5. **Resíduo ambíguo** vira pergunta ao usuário, com destino proposto.

Guardrails: nunca sobrescreve, nunca deleta o original sem dizer, o padrão é
mover, mostra o plano inteiro antes de tocar em qualquer coisa. *This is the one
migration where a wrong guess is expensive to undo.*

Condição de saída: ou `docs/` só tem entradas conformes, ou toda não-conforme tem
destino explicitamente aprovado. A partir daí o brownfield é greenfield — mesmo
fluxo, mesmas skills.

## Estrutura do repositório

```
anvil-skills.yaml        manifesto de curadoria (não vai no degit)
.claude/skills/anvil-sync/   ferramenta de manutenção (não vai no degit)
references/              submodules — os pins são a base do merge 3-way
  skills/    mattpocock/skills
  plugins/   cursor/plugins (pstack)
  hallmark/  Nutlope/hallmark
  taste/     Leonxlnx/taste-skill
  mosk/      rogerznts/mosk (herança)
anvil/                   o payload que o degit copia
```

## Estado

Em construção. `anvil-boot` e `anvil-update` são stubs; a vendorização das
skills ainda não começou.
