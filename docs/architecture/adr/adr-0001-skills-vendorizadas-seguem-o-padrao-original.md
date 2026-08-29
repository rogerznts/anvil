# ADR-0001 — Skills vendorizadas seguem o padrão original; o anvil impõe só o caminho em `docs/`

- Status: aceito
- Data: 2026-08-28
- Contexto: o anvil curadoriza 33 skills de quatro repositórios upstream e precisa re-sincronizá-las quando eles andarem.

## Contexto

A primeira versão do plano fazia a adaptação fluir na direção errada: reescrevia
as skills adotadas para falarem o dialeto do `mosk`. Cada skill ganhava caminhos
do mosk, vocabulário do mosk e artefatos do mosk.

Isso tem dois custos, e o segundo é o que mata:

1. **O merge 3-way nunca fica limpo.** Cada linha reescrita é um delta permanente
   que reaparece em todo update upstream.
2. **O anvil vira o mosk com outro nome.** O ganho de adotar skills maduras de
   fora se perde se elas chegam desfiguradas.

Medindo o acoplamento real das 21 skills do Matt Pocock: **1.196 linhas somadas,
27 com acoplamento — 2,3%**. Não havia o que reescrever em massa; a reescrita era
escolha nossa, não necessidade.

## Decisão

> **Tudo funciona no padrão das skills originais. A única coisa que o anvil impõe
> é *onde* o arquivo é salvo dentro de `docs/`, conforme o modelo de pastas
> definido. Bateu dúvida, o padrão é o da skill original.**

Consequências diretas na aplicação da regra:

- **Formato de ticket** é o do Matt: um arquivo por ticket em `issues/`, com
  `Blocked by:` carregando a ordem e `Status:` carregando o progresso. Não há
  `tasks.md`, não há `- [ ] T001` — isso vinha do SpecKit, via mosk.
- **Sem arquivo de metadado.** O Matt não tem; o `spec-meta.yaml` sai inteiro.
  `tipo` e número saem do nome da pasta, `created_at`/`created_by` saem do git.
- **`code-review` devolve prosa**, dois eixos lado a lado, sem gravar arquivo.
  `gate.yaml` sobrevive só dentro do `/anvil-bench` — ver [adr-0003](./adr-0003-sem-maquina-de-fases.md).
- **`handoff` continua gravando no temp do SO.** Não é caminho em `docs/`; é
  decisão de desenho do Matt (*"not the current workspace"*), fora do que a
  exceção cobre.

A única modificação estrutural aceita: `domain-modeling`, cujas 14 linhas fixam
`CONTEXT.md` na raiz e `docs/adr/`, remapeadas para `docs/architecture/`. É
decisão explícita, e é o único caso.

## Consequências

**A favor.** O delta permanente cai para 14 linhas mais a linha de nome de cada
skill. O merge com upstream tende a ser trivial. O que foi adotado continua sendo
o que o autor escreveu, e melhora quando ele melhora.

**Contra.** O anvil abre mão de uniformizar vocabulário entre as skills. `issues/`
convive com `stories/` no histórico, o `handoff` grava fora do repositório, e
cada skill mantém suas próprias manias. Uniformizar é justamente o que
custaria o merge limpo.

**O que fica proibido.** Reescrever uma skill vendorizada para "ficar coerente
com o resto". Se a incoerência incomodar, a saída é o perfil de tracker
([adr-0002](./adr-0002-organizacao-documental-e-um-perfil-de-tracker.md)) ou uma
rule do projeto — nunca o arquivo da skill.
