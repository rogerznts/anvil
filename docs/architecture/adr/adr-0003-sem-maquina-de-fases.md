# ADR-0003 — Sem máquina de fases: o artefato é o estado

- Status: aceito
- Data: 2026-08-28
- Contexto: o mosk mantinha `current_phase` em `spec-meta.yaml` e um `pipeline.yaml` de 378 linhas. O anvil abandona os agentes-como-persona.

## Contexto

O mosk tinha doze agentes-persona que não se falavam. O disco era a fronteira de
estado entre eles, e `current_phase` era como o `mosk-dev` sabia que uma spec
estava pronta para implementar.

Rastreando os sete consumidores de `current_phase` e `gate.yaml`:

| Consumidor | Sobrevive? |
|---|---|
| handoff entre agentes-persona | não — não há mais agentes |
| `mosk-suggestion` ("e agora?") | não — fora do roster |
| `mosk-orq`, runner autônomo | não — fora do roster |
| `validate.sh prerequisites` | não — os chamadores morrem |
| tabela de specs ativas no `docs/index.md` | sim |
| `loop-until-green` do bench | sim |
| hook de merge | sim |

**Quatro dos sete eram a arquitetura de personas.** A máquina de fases era a
espinha que ligava agentes isolados; sem eles, perde o motivo pelo qual foi
construída.

O fluxo adotado resolve o mesmo problema de outro jeito: `grill → to-spec →
to-tickets` roda numa única janela de contexto — o `ask-matt` manda
explicitamente não compactar até o fim — então não há handoff a persistir.
Depois cada `implement` começa do zero a partir do ticket, e são as arestas de
bloqueio declaradas no ticket que carregam a ordem.

E `current_phase` era **cache de coisa derivável guardado como estado primário**.
O mosk o escrevia em cinco tasks diferentes e mantinha um `validate.sh
self-check` só para pegar a divergência entre elas.

## Decisão

**Não há máquina de fases.** O estado é lido do disco:

```
spec.md existe                    → foi especificado
issues/ com Status != resolved    → em andamento; os abertos medem o que falta
todos resolved                    → implementado
pasta sob specs/archive/          → arquivado
```

Saem: `pipeline.yaml` (378 l), `phase-transition-contract.md` (91 l),
`spec-meta.yaml` inteiro, `qa-gate-tmpl.yaml`, `tasks-template.md` (251 l) e os
três schemas JSON — estes últimos, código morto verificado: `grep -rn "schemas/"`
em todo o `.claude/` do mosk retorna só as linhas `$id` dentro dos próprios
schemas, e o `validate.sh` tem zero ocorrências de `schema.json`.

**Duas exceções, ambas com fundamento:**

1. **`/anvil-bench`** é headless e dispara agentes isolados, com o disco como
   fronteira de estado. Um loop com teto de três tentativas precisa de condição
   de parada mecânica. É o único lugar com `gate.yaml`, `quality_score` e
   `score_history` — que só fazem sentido havendo volta de loop para comparar.
2. **O hook de merge** varre `issues/*.md` atrás de arquivo sem
   `Status: resolved`. O mosk registrou o custo de não ter guarda: *"a spec 014
   deste toolkit chegou ao branch default ainda em `qa-gate`, com o verificador
   instalado, correto e nunca invocado."*

## Consequências

**A favor.** ~530 linhas de máquina a menos. Nenhum cache para desincronizar.
O estado nunca mente, porque não é escrito — é lido.

**Contra.** A tabela de specs ativas do `docs/index.md` passa a ser derivada, não
lida de um campo. Fica mais cara de gerar e menos precisa: "em andamento" não
distingue especificado de implementado pela metade.

**A ponte branch↔pasta.** `feature/012-checkout-coupon` e
`docs/specs/012-feature-checkout-coupon` são strings diferentes de propósito. O
mosk guardava a ponte num campo. Sem ele, a resolução é **por prefixo numérico** —
que é o que o `specify.md` do próprio mosk já fazia. O ADR-0017 dele proibia
**igualdade de string**, não uma transformação determinística.
