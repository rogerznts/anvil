# Índice da documentação

Last updated: 2026-09-24T16:17:02Z

## Visão geral

- **[Discovery](./discovery/)** — pesquisa, briefings, brainstorming
  - [gate-sem-criterio-de-parada.md](./discovery/gate-sem-criterio-de-parada.md)
    — por que um par de gates independentes entra em laço num documento, e o que
    muda nas skills
  - [adaptar-omp-ao-anvil.md](./discovery/adaptar-omp-ao-anvil.md) — proposta
    de integração do anvil com o omp, antes do grill
  - [camadas-anvil-omp.md](./discovery/camadas-anvil-omp.md) — desenho em
    mermaid das camadas, da instalação, da execução e da guarda de merge
- **[Architecture](./architecture/)** — desenho do sistema, glossário e ADRs
- **[Project](./project/plan.md)** — plano vivo e atualizações datadas

## Specs ativas

- [004 — Robustez e isolamento da camada omp](./specs/004-extension-omp-layer-hardening/spec.md) — `extension/004-omp-layer-hardening`, especificado

## Specs arquivadas

- [003 — omp como harness, com camada própria](./specs/archive/003-feature-omp-harness/spec.md) — `feature/003-omp-harness`, 10 tickets
- [001 — Equipe e destilação](./specs/archive/001-feature-team-distill-sentrux/spec.md) — `feature/001-team-distill-sentrux`, 12 tickets

## Conteúdo por domínio

### Agents

- [issue-tracker.md](./agents/issue-tracker.md) — o perfil que as skills de
  fluxo leem: specs e tickets versionados em `docs/specs/{NNN}-{tipo}-{nome}/`,
  com `Blocked by` e `Status`.
- [domain.md](./agents/domain.md) — o que ler antes de explorar, e o vocabulário
  do glossário. Single-context, sob `docs/architecture/`.
- [verification.md](./agents/verification.md) — o critério de parada que as
  skills de verificação leem: classe do achado, orçamento de duas rodadas,
  escopo diff-only da segunda em diante, e a régua própria da prosa.

### Architecture

- [context.md](./architecture/context.md) — o glossário: curadoria, referências,
  tickets e harness, com os termos a evitar.
- [overview.md](./architecture/overview.md) — as quatro camadas, o que o anvil
  impõe, como o estado é lido do disco, os três harnesses e a camada omp, e a
  herança do mosk.
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
    — equipe por papel, coordenada por agent teams; **substituído pelo adr-0008**
  - [adr-0008](./architecture/adr/adr-0008-equipe-sai-do-toolkit.md)
    — a equipe por papel sai do toolkit; a máquina de agentes fica
  - [adr-0009](./architecture/adr/adr-0009-toolkit-instalado-fica-versionado.md)
    — o toolkit instalado fica versionado; o boot não escreve no `.gitignore`
  - [adr-0010](./architecture/adr/adr-0010-verificacao-tem-criterio-de-parada.md)
    — a verificação tem critério de parada, e ele é ausência de P1
  - [adr-0011](./architecture/adr/adr-0011-omp-como-harness-com-camada-propria.md)
    — o omp é harness de primeira classe, com camada própria; a orquestração volta só nela

### Project

- [acompanhamento.md](./project/acompanhamento.md) — achados P2/P3 de specs
  fechadas que viraram linha de acompanhamento, com origem e consequência.
- [plan.md](./project/plan.md) — o roster de skills, as fases, a verificação e o
  corte do core do mosk.

<!-- custom -->
<!-- /custom -->
