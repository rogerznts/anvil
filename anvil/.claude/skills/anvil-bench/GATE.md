# Gate — a condição de parada do loop

Este arquivo existe porque o bench é **headless**: ele dispara agentes isolados,
o disco é a fronteira de estado entre eles, e um loop que roda sozinho precisa de
uma condição de parada que não dependa de alguém julgar.

**É o único lugar do anvil com `gate.yaml`.** No fluxo normal, o
`anvil-code-review` devolve o veredito em prosa, dois eixos lado a lado — que é
melhor para um humano ler. Aqui não há humano lendo a cada volta.

## O arquivo

`docs/specs/{id}/gate.yaml`, reescrito a cada volta:

```yaml
gate: PASS                    # PASS | CONCERNS | FAIL | WAIVED
quality_score: 90             # 0-100, calculado
score_history: [61, 68, 90]   # a série, do primeiro gate ao atual
status_reason: "uma ou duas frases sobre o veredito"
updated: "2026-08-29T14:30:00Z"
evidence_ref: qa-notes.md     # caminho relativo dentro da spec

top_issues:
  - id: QA-1                  # QA-# para gate, SEC-# para segurança
    severity: high            # low | medium | high
    title: "Login aceita tentativas sem limite"
    finding: "Nenhum rate limit no endpoint de login (auth/login.ts:42-68)"
    contradicts: 'NFR-002 — "resistir a força bruta em autenticação"'
    suggested_action: "Adicionar rate limiting antes de publicar"
```

**Todo id citado carrega a glosa na primeira menção.** `contradicts: SC-004`
sozinho obriga quem lê a abrir a spec para saber se aquilo importa.

**Os ids são estáveis dentro da spec:** `QA-1` na segunda volta é o mesmo defeito
da primeira. É isso que torna a série legível.

## O veredito

| veredito | quando | o loop |
|---|---|---|
| `PASS` | smoke, testes de módulo acumulados e asserts de negócio, **todos** verdes | para, entrega |
| `CONCERNS` | teto de 3 tentativas esgotado, ou defeito que não bloqueia | para, reporta o que falta |
| `FAIL` | defeito bloqueante com tentativa ainda disponível | volta para o `anvil-implement` |
| `WAIVED` | alguém aceitou explicitamente o defeito | para, com os quatro campos de waiver preenchidos |

**Só o veredito decide.** O score não termina loop nenhum.

## O score

```
quality_score = 100 − (20 × FAILs) − (10 × CONCERNS)
```

Limitado a `0..100`. **Calculado por contagem, nunca estimado** — é isso que
torna a série comparável entre voltas.

Ele existe para tornar a **trajetória** visível:

- dois `FAIL` com score parado → estagnação. Hora de parar e devolver, não de
  tentar de novo.
- dois `FAIL` com score subindo → convergência lenta. Vale a próxima volta.

`score_history` é acumulado: o arquivo é reescrito a cada volta, então score que
não for anexado ali se perde.

## O teto de três

Por ticket, não por spec. Esgotado, o veredito é `CONCERNS` e o loop **para** —
não insiste, não tenta uma quarta com outra abordagem.

O motivo é o mesmo que justifica o loop existir: quem está esperando a ferramenta
não tem como julgar se a quarta tentativa vale a pena. Parar e dizer o que falta
é mais honesto que continuar tentando.

## Nova evidência

Evidência que aparece no meio do loop **amplia** o contexto e pode reclassificar
o trabalho para mais rigor. Nunca para menos: um teste que passou não apaga um
defeito encontrado antes.
