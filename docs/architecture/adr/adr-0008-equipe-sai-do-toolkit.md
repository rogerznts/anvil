# ADR-0008 — A equipe por papel sai do toolkit

- Status: aceito
- Data: 2026-09-21
- Substitui o [ADR-0007](./adr-0007-equipe-por-papel-sobre-agent-teams.md)

## Contexto

O [ADR-0007](./adr-0007-equipe-por-papel-sobre-agent-teams.md) pôs no payload uma
skill Leader — `anvil-team` — e sete agentes `anvil-team-{papel}`, coordenados por
*agent teams*, recurso experimental do Claude Code ligado por
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

Ele já registrava o custo como consequência contra: a equipe depende de um recurso
experimental e de um aninhamento de subagentes que foi **medido, não documentado**,
e as duas premissas precisam ser reverificadas a cada versão do Claude Code. Some-se
o peso próprio da equipe no toolkit: um protocolo, sete arquivos de agente, um
runtime alternativo para o Codex, uma lista `team` de modelos por papel em toda
`.claude/rules/anvil.md`, um documento de arquitetura de 1.000 linhas e dois checks
do `vendor-sync` que só existem para ela.

A tese do anvil é **não escrever as skills de trabalho**. A equipe era a maior
exceção autoral a essa tese, e a que mais custava para manter.

## Decisão

**A `anvil-team` e os agentes `anvil-team-*` saem do payload.** Saem junto: o
`PROTOCOL.md`, o `RUNTIMES.md`, o template de Mission Control, a configuração de
runtime do Codex, o check do `vendor-sync` que exigia a linha-ponteiro do protocolo
em cada agente de papel, a lista `team` de modelos por papel e o
`docs/architecture/team-shape.md`.

**A máquina de agentes do payload fica.** O `anvil.lock` mantém a linha `agent:`, o
`reset-install.sh` mantém o laço por arquivo de agente, o `dev-link.sh` continua
ligando os agentes do payload e o `vendor-sync verify` continua conferindo nome,
caminho citado e skill citada em cada agente. Ela é genérica — não era da equipe — e
já trata payload sem agente nenhum como caso válido. Hoje o payload não traz agente.

**O trabalho por tickets continua**, pelo caminho que nunca dependeu de recurso
experimental: `anvil-to-tickets`, `anvil-implement`, `anvil-tdd` e
`anvil-code-review`, com o estado lido do disco.

## Alternativas descartadas

- **Manter a equipe atrás de uma flag e parar de exercitá-la.** Caminho que ninguém
  roda apodrece em silêncio, e continuaria custando revisão a cada update do
  Claude Code.
- **Reescrever a equipe sobre subagente comum, sem *agent teams*.** Perderia os
  gates independentes, que eram a razão inteira de existir da equipe — sem eles ela
  vira despacho por capacidade, que `anvil-arena` e `anvil-code-review` já fazem.
- **Tirar a máquina de agentes junto.** Ela é genérica e o custo de mantê-la é um
  laço que não itera. Removê-la só reapareceria como reescrita no primeiro agente
  que o payload voltar a trazer.

## Consequências

**A favor.** O payload volta a ser só skills. Some a dependência de um recurso
experimental e do aninhamento não documentado de subagentes, e com ela a
reverificação a cada versão do Claude Code.

**Contra.** Some também o gate que o autor não controla: Tester e Review passam a ser
etapas do mesmo agente que implementou, dentro do `anvil-implement` e do
`anvil-code-review`. Quem quiser independência de verdade abre uma sessão separada.

**Continua valendo do ADR-0003 e do ADR-0007:** não há máquina de fases, não há
`current_phase`, e o estado é lido do disco.
