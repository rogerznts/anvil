---
name: anvil-bench
description: "Leva alguém que não é técnico de 'preciso de uma ferramenta interna' até a ferramenta rodando e testada, sem nenhuma decisão técnica pelo caminho. Use quando o pedido for uma ferramenta de uso interno — cadastro, controle, acompanhamento — e quem pede não programa. Também para evoluir uma ferramenta que o bench já criou."
---

# Bench

Uma pessoa que não programa descreve o que precisa, em português comum, e recebe
uma ferramenta funcionando. Nada de técnico aparece na conversa.

O bench é o **modo**; a tecnologia por baixo é uma **stack plugada**. Hoje a
stack ativa é o Payload. Raciocine em termos de "a ferramenta", "os módulos", "as
regras" — nunca amarre o que você diz a uma tecnologia.

## As duas regras que valem sempre

**Nunca faça alguém leiga tomar decisão técnica.** Toda escolha técnica é
resolvida por convenção — os scripts do adapter, o starter versionado — ou
sozinha, na fase de construção. Bifurcação técnica no meio da conversa:
**escolha o default seguro e avise em linguagem simples.** Nunca pergunte.

**Toda saída ao usuário é português simples, sem jargão.** Nunca diga o nome da
tecnologia, "porta", "container", "banco", "migration", "YAML" ou "commit". Fale
de "cadastros", "informações", "quem pode usar", "regras", "o endereço da
ferramenta".

As invariantes completas do produto gerado (INV-1..6) estão na skill
`anvil-stack-payload`, arquivo `bench/INVARIANTS.md`. Carregue antes de começar.

## Fluxo

### 1. Preparar

Rode o validador e o provisionador da stack — na `anvil-stack-payload`,
`bench/env.sh` e depois `bench/infra.sh`, com `--provision "<nome>"`.

Traduza só o progresso. Em falha, diga qual requisito falta **sem** mostrar
comando, porta, banco ou container. Confirmação humana só para instalar
requisito externo.

Projeto que já tem alocação: **reuse**, não reprovisione.

### 2. Reconhecer

Starter presente mais a rule da stack indicam projeto existente. Nesse caso vá
direto ao delta — ver *Evoluir uma ferramenta*, abaixo.

Projeto novo: copie o starter **as-is**, sem regenerar, inicialize o git,
materialize o `.env` com a alocação, e gere `.claude/rules/payload.md` a partir
do `RULE.md` da stack mais a seção de invariantes.

### 3. Entender

Chame a Skill tool com **anvil-grilling**, uma pergunta por vez, esperando
resposta antes de seguir. Sempre com a **sua recomendação** e uma linha de
porquê.

Perguntas permitidas, e só estas:

- que **módulos** a ferramenta tem, e que **informações** cada um guarda
- **quem pode usar** cada parte
- que **regras de negócio** valem
- **integrações** com o que já existe
- os **nomes** que aparecem na tela
- o **critério de pronto**: como a pessoa vai saber que está funcionando

Se a resposta puder ser lida do código ou do que já existe, leia — não pergunte.

`chega` congela o que foi decidido e registra o resto como lacuna.

### 4. Congelar e testar

Grave o combinado em `briefing.md` e `checklist.yaml` dentro da spec, e atualize
a rule da stack com os módulos e papéis reais.

Derive os testes **do checklist**, simétricos ao que foi acordado: existência de
módulo, campos, CRUD, papéis, e os asserts de negócio. **Não reescreva os testes
base do starter.**

### 5. Construir

```
anvil-to-spec  →  anvil-to-tickets  →  [ anvil-implement + anvil-tdd ]  →  anvil-code-review  →  gate
                                          ↑                                        │
                                          └──────── até 3 tentativas ──────────────┘
```

Este é o único lugar do anvil que roda sem parar a cada decisão. O fundamento é
a **audiência**: quem está do outro lado não tem como responder "os testes de
integração falharam, quer que eu ajuste o mock?".

A condição de parada é mecânica e está em [GATE.md](GATE.md). Teto de **três**
tentativas por ticket; esgotado, para e reporta.

Uma linha visível de progresso por fase. Detalhe vai para `build-log.md`, e toda
decisão que você tomou sozinha vai para `decisions-log.md` — é o que permite
alguém auditar depois o que foi convenção e o que foi pedido.

### 6. Entregar

Com `PASS`: o endereço, as credenciais e um resumo do que a ferramenta faz, em
linguagem de negócio.

Com `CONCERNS` ou `FAIL`: diga o que falta, em uma frase, **sem despejar log**.

Publicar é opt-in e não faz parte deste fluxo — `bench/deploy.sh`, na stack.

## Evoluir uma ferramenta

Reative o bench no projeto existente e descreva a mudança.

- O grill cobre **só o delta**. Não re-entreviste o que já foi decidido.
- Preserve módulos e testes anteriores. Remoção ou substituição exige pedido
  explícito, confirmado na conversa.
- A mudança nasce como spec **aditiva**, rastreável no git.
- Rode a regressão inteira: testes antigos e novos juntos.
- O endereço e a alocação **não mudam**.
- A entrega resume só o que mudou.

## Nunca

- **Inventar regra de negócio.** Lacuna material volta para a conversa ou aparece
  na entrega como pendência declarada.
- **Gerar ambiente, infraestrutura ou scaffold.** Isso vem do adapter, versionado.
- **Editar fora de `src/collections/` e labels.** O compose, a infra e a base do
  `payload.config.ts` não são seus.
- **Mostrar log, comando ou nome de tecnologia** para quem pediu a ferramenta.
