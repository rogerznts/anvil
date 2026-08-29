# Verbo `adopt` — adotar um `docs/` existente

Traz um projeto brownfield para a organização documental do anvil.

**Isto é julgamento sobre conteúdo, não sobre nome de arquivo.** Decidir se um
`docs/notes.md` solto é discovery, PRD ou arquitetura exige **ler o arquivo**. Um
script só consegue casar nome, e é por isso que a versão em script disso carregava
uma lista fixa que nunca cobria o projeto na frente dela.

## Guardrails

Esta é a operação em que um palpite errado sai caro de desfazer.

- **Nunca sobrescreva.** Destino que já existe e difere: reporte o conflito e
  pergunte.
- **Nunca delete o original** sem dizer. O padrão é **mover**; se o usuário
  quiser os dois, copie e diga onde cada um ficou.
- **Mostre o plano inteiro antes de tocar em qualquer coisa** e espere um
  "pode ir". Não avance com um "talvez".
- **Não mova o que você não classificou com confiança.** Pergunte o destino.
- **Não aplique `promote:` automaticamente** em artefato que foi para uma spec.
  Sugira o front-matter; quem decide é o usuário.

## 1. Survey

Leia antes de propor. Enumere e reporte como tabela — *caminho · o que parece
ser · para onde iria* — sem mover nada:

- `docs/` — todo arquivo e pasta, inclusive os soltos na raiz
- a raiz do repositório — `CONTEXT.md`, `CONTEXT-MAP.md`, `ARCHITECTURE.md`,
  `ROADMAP.md` e afins
- `docs/adr/`, `src/*/docs/adr/` — ADRs em layout antigo
- `.scratch/` — sinal de que o perfil de tracker local já esteve em uso
- `.claude/rules/` e `.claude/skills/` — o que já existe

Classifique cada entrada como **conforme** ou **não-conforme**:

- Conforme: mora sob um domínio canônico (`discovery/`, `prd/`, `architecture/`,
  `ui/`, `qa/`, `project/`, `specs/`, `agents/`), ou é `index.md`, ou é um
  `README.md` de domínio.
- Não-conforme: tudo o mais — arquivo solto na raiz de `docs/`, monolito
  (`docs/prd.md`, `docs/architecture.md`), `docs/stories/`, `docs/epics/`, pasta
  fora dos domínios.

## 2. Scaffold

Crie **só o que falta**. Pasta que já existe não é tocada.

## 3. Colocar o conteúdo

Para cada artefato, decida **lendo**:

| O que é | Para onde vai |
|---|---|
| pesquisa, entrevista, brainstorming, análise de mercado | `docs/discovery/` |
| escopo de produto, requisitos, épicos | `docs/prd/` |
| desenho do sistema, stack, integrações, decisões | `docs/architecture/` — decisões sob `adr/` |
| glossário, vocabulário ubíquo do domínio | `docs/architecture/context.md` |
| fluxos, wireframes, spec de front-end, design system | `docs/ui/` |
| estratégia de teste, gates, avaliação de NFR | `docs/qa/` |
| plano não-técnico, acompanhamento datado | `docs/project/` |
| qualquer coisa no escopo de uma mudança pendente | `docs/specs/{id}/<domínio>/` |

**Monolito só é fatiado se for genuinamente vários documentos grampeados.** Um
`prd.md` coeso continua sendo um arquivo. Não se fatia por fatiar.

**`docs/stories/` global** vai para o `issues/` da spec que o possui. Ticket sem
spec dona é **reportado, não adivinhado** — o usuário decide se cria uma spec
para ele ou se ele morreu.

**`CONTEXT.md` na raiz** vai para `docs/architecture/context.md`; `CONTEXT-MAP.md`
para `docs/architecture/context-map.md`; `docs/adr/` para
`docs/architecture/adr/`. Depois de mover, avise que quem referenciava os
caminhos antigos precisa ser atualizado — e liste quem eram.

## 4. Retrofit das specs

Para cada pasta de spec encontrada em layout antigo:

- Renomeie para `{NNN}-{tipo}-{nome}` se estiver noutro formato. Se não der para
  inferir o tipo, pergunte.
- Converta a lista de tarefas para um arquivo por ticket em `issues/`, com
  `Blocked by:` e `Status:`. Tarefa já concluída vira `Status: resolved`.
- Remova `spec-meta.yaml`, `tasks.md` e `gate.yaml` **depois** de extrair deles o
  que for necessário, e diga o que foi extraído.
- Spec concluída vai para `specs/archive/`.

## 5. Resíduo

O que sobrou sem classificação confiável vira pergunta, com um destino proposto e
uma linha dizendo por que aquele destino.

## Saída

Ou `docs/` só tem entradas conformes, ou **toda** não-conforme tem destino
explicitamente aprovado. Reporte o que ficou sem resolver.

Ao final, rode o verbo `index`.
