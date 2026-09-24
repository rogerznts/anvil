Olhando a estrutura atual do seu Anvil, você já fez uma parte importante do trabalho: o payload instala as skills tanto em `.claude/skills` quanto através de `.agents/skills`, e o Pi nativo procura skills de projeto em `.agents/skills`. Ou seja, **o Anvil já está muito próximo de ser independente do Claude Code**. O Pi também permite carregar diretórios de skills externos e invocá-las com `/skill:<nome>`. ([GitHub](https://github.com/open-gsd/gsd-pi/blob/main/packages/pi-coding-agent/docs/skills.md?utm_source=chatgpt.com "gsd-pi/packages/pi-coding-agent/docs/skills.md at main · open-gsd/gsd-pi · GitHub"))

Para o que você quer, eu faria uma separação clara:

```text
ANVIL
= protocolo / metodologia / estado
  specs
  tickets
  blocked by
  status
  review
  QA

OMP
= runtime / scheduler / multi-agent
  sessões
  modelos
  subagents
  paralelismo
  worktrees
  isolamento
```

E usaria **Oh My Pi/OMP como executor principal do Anvil**.

O motivo é importante: o Pi original deliberadamente não traz subagents como recurso central; ele espera que você acrescente isso via extension/package. O OMP já tem `task`, agentes customizados, execução paralela, child sessions com contexto limpo, isolamento em worktree e `autoloadSkills`. ([GitHub](https://github.com/forkgitss/badlogic-pi-mono/blob/main/packages/coding-agent/README.md?utm_source=chatgpt.com "badlogic-pi-mono/packages/coding-agent/README.md at main · forkgitss/badlogic-pi-mono · GitHub"))

## Como eu desenharia

Você teria dois workflows de primeira classe:

```text
/anvil-plan

Grill
   ↓
Spec
   ↓
Tickets
```

e:

```text
/anvil-run

Ticket frontier
   ↓
Implement
   ↓
TDD
   ↓
Review
 ┌──────┴──────┐
Standards     Spec
 └──────┬──────┘
        ↓
       Fix?
        ↓
   próximo ticket
        ↓
   Browser QA
        ↓
 archive / PR
```

### 1. `grill → spec → tickets`

Aqui eu **não usaria subagents**.

Isso é importante porque seu próprio fluxo atual exige que:

```text
grill → to-spec → to-tickets
```

fique na **mesma janela de contexto**.

Então o OMP principal atua como coordenador e carrega as três skills sucessivamente.

A automação não deveria eliminar os pontos em que suas skills explicitamente pedem decisão humana.

Por exemplo, `to-spec` pergunta sobre os seams de teste e `to-tickets` pede validação da granularidade e dos blockers.

Então ficaria algo assim:

```text
/anvil-plan quero criar cupons de desconto

        ↓

anvil-grill
        ↓
[conversa comigo]
        ↓
anvil-to-spec
        ↓
[validação de seams]
        ↓
anvil-to-tickets
        ↓
[validação dos tickets]
        ↓

docs/specs/xxx/
   spec.md
   issues/
      01-...
      02-...
      03-...
```

Ou seja:

**automático entre os gates humanos, não automático ignorando os gates.**

Isso mantém exatamente a filosofia das suas skills.

---

# 2. `implement → review → QA`

Aqui é onde o OMP encaixa muito melhor.

O OMP possui uma primitiva `task` que cria child sessions independentes. As child sessions **não herdam a conversa do pai**, mas enxergam workspace, skills e contexto explicitamente fornecido. Isso casa exatamente com sua regra atual de que cada `implement` começa em contexto novo e o ticket é o estado. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md?utm_source=chatgpt.com "oh-my-pi/docs/tools/task.md at main · can1357/oh-my-pi · GitHub"))

Então o supervisor poderia fazer:

```text
Anvil Supervisor
       │
       ├── lê todos os tickets
       │
       ├── calcula frontier
       │
       │   Blocked by = resolved
       │
       ▼
Implementer
 fresh context
       │
       ├── anvil-implement
       ├── anvil-tdd
       │
       ▼
     commit
       │
       ▼
 Review ──────────────────────┐
       │                      │
       ├── Standards agent    │ paralelo
       │                      │
       └── Spec agent         │
                              │
       ◄──────────────────────┘
       │
       ▼
P1?
 ├── sim → Implementer novamente
 │
 └── não
       ↓
 Status: resolved
       ↓
 próximo frontier
```

O OMP suporta exatamente esse fan-out em `task`, inclusive vários itens em um mesmo batch. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md?utm_source=chatgpt.com "oh-my-pi/docs/tools/task.md at main · can1357/oh-my-pi · GitHub"))

---

# Uma coisa que eu mudaria no Anvil

Não nas skills upstream.

Hoje existem instruções como:

```text
Use /anvil-tdd
```

e:

```text
Call the Skill tool twice
```

Isso é linguagem específica do Claude Code.

No Pi/OMP a invocação de skill é outra; o padrão interativo é `/skill:<nome>`. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/skills.md?utm_source=chatgpt.com "oh-my-pi/docs/skills.md at main · can1357/oh-my-pi · GitHub"))

Mas eu **não sairia alterando as 35 skills vendorizadas**.

Isso destruiria uma das melhores características do seu Anvil: os deltas mínimos contra upstream.

Eu criaria duas skills autorais:

```text
anvil-flow-plan
anvil-flow-run
```

Essas seriam o adapter.

Então:

```text
anvil-flow-plan
    ├── anvil-grill
    ├── anvil-grilling
    ├── anvil-domain-modeling
    ├── anvil-to-spec
    └── anvil-to-tickets
```

e:

```text
anvil-flow-run
    ├── anvil-implement
    ├── anvil-tdd
    ├── anvil-code-review
    └── anvil-browser-qa
```

As skills originais continuam intactas.

---

# E usaria uma feature muito interessante do OMP

Os agents do OMP aceitam:

```yaml
autoloadSkills
```

Ou seja, você pode dizer:

> toda vez que nascer um implementer, injete automaticamente essas skills nele.

Isso é recurso nativo do sistema de task agents do OMP. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/task-agent-discovery.md?utm_source=chatgpt.com "oh-my-pi/docs/task-agent-discovery.md at main · can1357/oh-my-pi · GitHub"))

Por exemplo:

```text
.omp/
└── agents/
    ├── anvil-implementer.md
    └── anvil-qa.md
```

O [`anvil-implementer.md`](http://anvil-implementer.md) poderia ser:

```yaml
---
name: anvil-implementer
description: Implements exactly one Anvil ticket using TDD and two-axis review.
model: "@build"
blocking: true

tools:
  - read
  - grep
  - glob
  - bash
  - edit
  - write
  - task
  - hub

spawns:
  - reviewer

autoloadSkills:
  - anvil-implement
  - anvil-tdd
  - anvil-code-review
---

You implement exactly one Anvil ticket.

The ticket is the source of execution state.

Read:
- the ticket
- its originating spec
- applicable ADRs
- project rules

Execute the procedures contained in the autoloaded
Anvil skills directly.

Do not emit Claude Code slash commands such as
/anvil-tdd or /anvil-code-review.

After implementation:

1. run the required tests;
2. run the Anvil two-axis review;
3. spawn two independent reviewer tasks:
   - Standards
   - Spec
4. aggregate their results according to anvil-code-review;
5. update the ticket according to the Anvil verification rules.

Never work on more than one ticket.
```

E isso é bem interessante porque o OMP permite que o agent tenha um modelo próprio:

```yaml
model: "@build"
```

e depois:

```yaml
modelRoles:
  build: openai/gpt-5.6
  review: anthropic/claude-opus-4-6
  qa: openai/gpt-5.6
```

Assim seu workflow Anvil deixa de ser preso a um modelo.

Você poderia ter, por exemplo:

```text
Supervisor
GPT-5.6

Implementer
GPT-5.6

Review Standards
Claude

Review Spec
GPT-5.6

QA
modelo mais barato
```

Os custom agents do OMP suportam aliases de modelo justamente para isso. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/task-agent-discovery.md?utm_source=chatgpt.com "oh-my-pi/docs/task-agent-discovery.md at main · can1357/oh-my-pi · GitHub"))

---

# O supervisor

Eu criaria então a skill:

```text
anvil-flow-run
```

com uma lógica parecida com:

```text
1. Leia docs/agents/issue-tracker.md
2. Leia docs/agents/verification.md

3. Descubra a spec ativa.

4. Leia todos os tickets.

5. Calcule o frontier:

   ticket.status != resolved

   AND

   todos os Blocked by == resolved

6. Para cada ticket no frontier:

   spawn anvil-implementer

7. Espere os resultados.

8. Releia os tickets do disco.

9. Recalcule frontier.

10. Continue até:

    todos Status == resolved

11. Se a spec tiver comportamento de UI:

    spawn anvil-qa

12. Se QA encontrar defeito:

    crie/identifique o ticket responsável
    execute novamente implement → review

13. Quando tudo passar:

    anvil-docs archive
    tea-open-pr
```

Veja como isso casa extraordinariamente bem com sua arquitetura atual:

```text
não é o supervisor que guarda estado.

O DISCO guarda estado.
```

O supervisor pode até morrer.

Outro OMP abre e encontra:

```text
01
Status: resolved

02
Status: resolved

03
Status: ready-for-agent
Blocked by: 01, 02
```

e imediatamente conclui:

```text
frontier = ticket 03
```

Isso é uma arquitetura muito mais robusta do que depender de memória de agente.

---

# Paralelização

Aqui existe outra oportunidade interessante.

Imagine:

```text
01 banco
02 API
03 checkout
04 relatório
```

E:

```text
01
Blocked by: none

02
Blocked by: none

03
Blocked by: 01,02

04
Blocked by: none
```

O supervisor calcula:

```text
frontier:

01
02
04
```

Então o OMP pode executar:

```text
             supervisor

       ┌─────────┼─────────┐

 implement 01 implement 02 implement 04

       └─────────┼─────────┘

              merge

                ↓

          implement 03
```

Se você usar isolamento, OMP consegue executar subagents em workspaces separados e retornar patch/branch para integração. Esse mecanismo está integrado ao `task`. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md?utm_source=chatgpt.com "oh-my-pi/docs/tools/task.md at main · can1357/oh-my-pi · GitHub"))

Isso significa que o seu:

> `Blocked by`

deixa de ser apenas documentação.

Ele vira literalmente um **DAG de execução**.

Essa para mim é uma das evoluções mais interessantes que você pode fazer no Anvil.

---

# Browser QA

Eu mudaria apenas onde ele entra.

Não faria:

```text
ticket
implement
review
browser QA

ticket
implement
review
browser QA
```

Faria normalmente:

```text
ticket 01
implement
review

ticket 02
implement
review

ticket 03
implement
review

todos resolvidos

        ↓

Browser QA da SPEC
```

Porque seu `browser-qa` trabalha muito mais naturalmente sobre o comportamento final.

Então:

```text
Automated tests
→ por ticket

Code review
→ por ticket

Browser QA
→ por spec
```

Se o Browser QA encontrar:

```text
BQA-07 FAIL
```

o supervisor volta para:

```text
fix
 ↓
review
 ↓
browser QA do caso afetado
```

---

# Como expor isso no OMP

Eu criaria uma extensão muito pequena.

```text
.omp/extensions/anvil.ts
```

Algo conceitualmente assim:

```ts
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

export default function anvil(pi: ExtensionAPI) {

  pi.registerCommand("anvil-plan", {
    description: "Run Anvil grill → spec → tickets",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      pi.sendUserMessage(
        `
Execute the Anvil planning workflow.

Read and follow:
.agents/skills/anvil-flow-plan/SKILL.md

Initial request:

${args}
        `.trim(),
        {
          attribution: "agent"
        }
      );
    }
  });

  pi.registerCommand("anvil-run", {
    description: "Run Anvil implementation workflow",
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      pi.sendUserMessage(
        `
Execute the Anvil implementation supervisor.

Read and follow:
.agents/skills/anvil-flow-run/SKILL.md

Target:

${args || "detect the active spec"}
        `.trim(),
        {
          attribution: "agent"
        }
      );
    }
  });

}
```

Esse tipo de extension é suportado diretamente pelo OMP: extensions podem registrar slash commands e injetar mensagens no agent loop com `sendUserMessage`. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/extensions.md?utm_source=chatgpt.com "oh-my-pi/docs/extensions.md at main · can1357/oh-my-pi · GitHub"))

Então sua experiência seria literalmente:

```bash
omp
```

e:

```text
/anvil-plan sistema de cupons
```

Você conversa durante o Grill.

No final:

```text
✓ Spec 041 criada
✓ 7 tickets criados
✓ dependency graph validado
```

Depois:

```text
/anvil-run 041
```

E aí ele pode trabalhar sozinho:

```text
Anvil 041

✓ 01 model coupon
✓ review
✓ 02 discount engine
✓ review

⟳ 03 checkout integration

parallel:
⟳ 04 admin UI
⟳ 05 analytics

pending:
06 blocked by 03,04
07 blocked by 06
```

---

# Eu faria em três camadas

A arquitetura final que eu usaria no seu repositório seria:

```text
                    ANVIL

             methodology layer
                    │
        ┌───────────┴────────────┐
        │                        │
   upstream skills        orchestration skills
        │                        │
        │                anvil-flow-plan
        │                anvil-flow-run
        │
        ▼
 docs/specs / tickets / ADR / QA
        │
        │ durable state
        ▼
────────────────────────────────────────

               HARNESS ADAPTER

 Claude Code       OMP            Pi
     │              │              │
 /skills       .omp/agents      extension
     │          task/subagents      │
     └──────────────┼───────────────┘
                    │

                 ANVIL
```

Isso evita que você crie:

```text
Anvil for Claude
Anvil for Pi
Anvil for OMP
Anvil for Codex
```

O **core permanece o mesmo**.

Só muda o executor.

## Minha recomendação

Para o que você descreveu, eu evoluiria o Anvil nessa ordem:

1. Criar `anvil-flow-plan`.
2. Criar `anvil-flow-run`.
3. Criar `anvil-implementer` como agent nativo do OMP.
4. Usar o `reviewer` do OMP em duas instâncias paralelas para os dois eixos do seu `anvil-code-review`.
5. Criar a pequena extensão com `/anvil-plan` e `/anvil-run`.
6. Depois transformar `Blocked by` num DAG que permita execução paralela automática.

O resultado seria bem poderoso: **você entra com uma ideia no** `/anvil-plan`**, participa apenas das decisões de produto/arquitetura e depois entrega a spec para** `/anvil-run`**, que passa a dirigir implementação, TDD, reviewers independentes, correções e QA.**

E o mais interessante é que isso não exige reescrever o Anvil. A arquitetura atual dele — principalmente o fato de o **ticket ser o estado e cada implementação começar limpa** — já é quase exatamente o modelo que um harness como OMP precisa. ([GitHub](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md?utm_source=chatgpt.com "oh-my-pi/docs/tools/task.md at main · can1357/oh-my-pi · GitHub"))

Se eu fosse implementar isso no repositório agora, eu começaria especificamente pelos **dois orchestration skills + os agents OMP**, porque já entrega uns 80% do comportamento sem você precisar criar um orquestrador TypeScript complexo.