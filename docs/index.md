# Índice da documentação

Last updated: 2026-09-13T01:20:05Z

## Visão geral

- **[Discovery](./discovery/)** — pesquisa, briefings, brainstorming
- **[Architecture](./architecture/)** — desenho do sistema, glossário e ADRs
- **[Project](./project/plan.md)** — plano vivo e atualizações datadas

## Specs ativas

| Spec | Branch | Estado | Tickets |
|---|---|---|---|
| [001 — Equipe, destilação e sentrux](./specs/001-feature-team-distill-sentrux/spec.md) | `feature/001-team-distill-sentrux` | em andamento | 3/14 |

## Specs arquivadas

Nenhuma.

## Conteúdo por domínio

### Agents

- [issue-tracker.md](./agents/issue-tracker.md) — o perfil que as skills de
  fluxo leem: specs e tickets versionados em `docs/specs/{NNN}-{tipo}-{nome}/`,
  com `Blocked by` e `Status`.
- [domain.md](./agents/domain.md) — o que ler antes de explorar, e o vocabulário
  do glossário. Single-context, sob `docs/architecture/`.

### Architecture

- [context.md](./architecture/context.md) — o glossário: curadoria, referências e
  equipe, com os termos a evitar.
- [overview.md](./architecture/overview.md) — as quatro camadas, o que o anvil
  impõe, como o estado é lido do disco, e a herança do mosk.
- **ADRs**
  - [adr-0001](./architecture/adr/adr-0001-skills-vendorizadas-seguem-o-padrao-original.md)
    — skills vendorizadas seguem o padrão original; o anvil impõe só o caminho em `docs/`
  - [adr-0002](./architecture/adr/adr-0002-organizacao-documental-e-um-perfil-de-tracker.md)
    — a organização documental é um perfil de issue tracker
  - [adr-0003](./architecture/adr/adr-0003-sem-maquina-de-fases.md)
    — sem máquina de fases: o artefato é o estado
  - [adr-0004](./architecture/adr/adr-0004-sync-por-merge-3-way-sem-cache.md)
    — sync por merge 3-way, com o pin do submodule como base
  - [adr-0005](./architecture/adr/adr-0005-ui-com-roteador.md)
    — a camada de UI tem roteador: hallmark e taste são métodos rivais
  - [adr-0006](./architecture/adr/adr-0006-stack-como-camada-propria.md)
    — stack é camada própria, com contrato de seis capacidades
  - [adr-0007](./architecture/adr/adr-0007-equipe-por-papel-sobre-agent-teams.md)
    — equipe por papel, coordenada por agent teams; complementa o adr-0003

### Project

- [plan.md](./project/plan.md) — o roster de skills, as fases, a verificação e o
  corte do core do mosk.

<!-- custom -->
<!-- /custom -->
