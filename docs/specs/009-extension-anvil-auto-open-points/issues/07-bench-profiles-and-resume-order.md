# 07: O bench nasce com os perfis e retoma a spec aberta antes de *Evoluir*

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o projeto novo do bench nasce com `docs/agents/issue-tracker.md`
e `docs/agents/verification.md`, os perfis que o bench e as skills de fluxo citam.
Reativado no meio de uma construção, o bench segue a spec aberta antes de
qualquer outro ramo da fase 2, e não cai em *Evoluir uma ferramenta* só porque a
retomada já commitou o `docs/qa/checklist.yaml`. Sem roteiro, *Uma entrada do
roteiro* constrói a spec aberta em vez de parar no `next: none`.

- [ ] No passo de projeto novo da fase 2, o bench instala os dois perfis a partir
      dos templates do `anvil-docs`, com a regra do `scaffold`: ausente, copia;
      idêntico, segue; divergente, não sobrescreve. Sob o piloto, entram no commit
      do piloto depois do sim; chamado direto, no primeiro commit.
- [ ] Antes dos ramos de hoje, a fase 2 procura uma spec aberta, fora de
      `docs/specs/archive/`, com ticket não `resolved`. Achou, a construção segue
      por ela: a fase 4, se falta o `gates.md`; senão, a fase 5 pelos tickets não
      `resolved`. *Evoluir uma ferramenta* só vale sem essa spec.
- [ ] No passo 1 de *Uma entrada do roteiro*, com `roadmap: none` e uma spec
      aberta, a entrada é essa spec. O `next: none` só segura a construção quando
      há roteiro.
- [ ] Prova B1, num diretório novo de `workspace/`: um turno headless do
      `/anvil-bench` sobre projetos de fixture, sem subir o app. Projeto novo: o
      primeiro commit traz os dois perfis, iguais aos templates. Projeto com spec
      aberta, tickets não `resolved` e `docs/qa/checklist.yaml` no branch, sem
      roteiro: o bench segue a retomada, e não *Evoluir*. Ferramenta sem spec
      aberta, com mudança pedida: o bench segue *Evoluir*. A prova registra o
      modelo que de fato respondeu.
- [ ] `vendor-sync.sh verify` sai `0`.
