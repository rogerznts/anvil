# Índice da documentação

Last updated: 2026-10-27T00:53:54Z

## Visão geral

- **[Discovery](./discovery/)** — pesquisa, briefings, brainstorming
  - [gate-sem-criterio-de-parada.md](./discovery/gate-sem-criterio-de-parada.md)
    — por que um par de gates independentes entra em laço num documento, e o que
    muda nas skills
  - [adaptar-omp-ao-anvil.md](./discovery/adaptar-omp-ao-anvil.md) — proposta
    de integração do anvil com o omp, antes do grill
  - [camadas-anvil-omp.md](./discovery/camadas-anvil-omp.md) — desenho em
    mermaid das camadas, da instalação, da execução e da guarda de merge
  - [bench-autonomo.md](./discovery/bench-autonomo.md) — proposta para pôr o
    bench sobre o plan e o run e torná-lo autônomo da entrevista ao relatório,
    antes do grill
  - [piloto-automatico-decisoes-do-grill.md](./discovery/piloto-automatico-decisoes-do-grill.md)
    — handoff do grill das specs 007 e 008, com as decisões Q5–Q29 da 008 que
    não estão no ADR-0014
- **[Architecture](./architecture/)** — desenho do sistema, glossário e ADRs
- **[Project](./project/plan.md)** — plano vivo e atualizações datadas

## Roteiro

- **security-audit-vendor** — fechada — [013](./specs/archive/013-feature-security-audit-vendor/)
- **security-audit-record** — fechada — [014](./specs/archive/014-feature-security-audit-record/)

Relatório da execução: [report.md](./specs/report.md)

## Specs ativas

Nenhuma.

## Specs arquivadas

- [014 — O registro da auditoria entra versionado em `docs/security/`](./specs/archive/014-feature-security-audit-record/spec.md) — `feature/014-security-audit-record`, 2 tickets
- [013 — A auditoria de segurança da Cloudflare entra vendorizada](./specs/archive/013-feature-security-audit-vendor/spec.md) — `feature/013-security-audit-vendor`, 2 tickets
- [008 — Piloto automático: do grill ao fechamento sem pausa humana](./specs/archive/008-feature-anvil-auto/spec.md) — `feature/008-anvil-auto`, 11 tickets
- [007 — Migração lista o que está fora do git e edita o alvo de symlink no repositório](./specs/archive/007-extension-migration-out-of-git/spec.md) — `extension/007-migration-out-of-git`, 4 tickets
- [006 — Instalação por usuário, idioma no chat e cauda do `anvil-next`](./specs/archive/006-feature-user-install-language-next/spec.md) — `feature/006-user-install-language-next`, 7 tickets
- [004 — Robustez e isolamento da camada omp](./specs/archive/004-extension-omp-layer-hardening/spec.md) — `extension/004-omp-layer-hardening`, 11 tickets
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
  segurança, tickets e harness, com os termos a evitar.
- [overview.md](./architecture/overview.md) — as quatro camadas, o que o anvil
  impõe, como o estado é lido do disco, os três harnesses e a camada omp, com o
  piloto automático, e a herança do mosk.
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
    — o toolkit instalado fica versionado; o boot não escreve no `.gitignore`; **revogado pelo adr-0013**
  - [adr-0010](./architecture/adr/adr-0010-verificacao-tem-criterio-de-parada.md)
    — a verificação tem critério de parada, e ele é ausência de P1
  - [adr-0011](./architecture/adr/adr-0011-omp-como-harness-com-camada-propria.md)
    — o omp é harness de primeira classe, com camada própria; a orquestração volta só nela; **emendado pelo adr-0013**
  - [adr-0012](./architecture/adr/adr-0012-frontier-em-paralelo-com-isolacao-do-omp.md)
    — o frontier roda em paralelo sob pedido, só com a isolação do omp no modo branch
  - [adr-0013](./architecture/adr/adr-0013-toolkit-instalado-por-usuario.md)
    — o toolkit é instalado uma vez por usuário; o projeto fica só com rules e `docs/`
  - [adr-0014](./architecture/adr/adr-0014-piloto-automatico-fecha-sem-humano.md)
    — o piloto automático leva o roteiro ao fechamento sem humano; revê em parte o adr-0010 e o adr-0011
  - [adr-0015](./architecture/adr/adr-0015-auditoria-de-seguranca-vendorizada-da-cloudflare.md)
    — a auditoria de segurança é a skill da Cloudflare, vendorizada; o versionado é só o registro da auditoria

### Project

- [acompanhamento.md](./project/acompanhamento.md) — achados P2/P3 de specs
  fechadas que viraram linha de acompanhamento, com origem e consequência.
- [plan.md](./project/plan.md) — o roster de skills, as fases, a verificação e o
  corte do core do mosk.

<!-- custom -->
<!-- /custom -->
