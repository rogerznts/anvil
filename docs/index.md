# Índice da documentação

Last updated: 2026-08-28T00:00:00Z

## Visão geral

- **[Discovery](./discovery/)** — pesquisa, briefings, brainstorming
- **[PRD](./prd/)** — requisitos de produto
- **[Architecture](./architecture/overview.md)** — desenho do sistema + ADRs
- **[UI](./ui/)** — design system, fluxos, wireframes
- **[QA](./qa/)** — estratégia de teste e gates
- **[Project](./project/plan.md)** — plano vivo e atualizações datadas

## Specs ativas

Nenhuma.

## Specs arquivadas

Nenhuma.

## Conteúdo por domínio

### Architecture

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

### Project

- [plan.md](./project/plan.md) — o roster de 43 skills, as sete fases, a
  verificação e o corte do core do mosk.

<!-- custom -->
<!-- /custom -->
