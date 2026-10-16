# 08: Os contratos dizem o que o piloto, o implementer e o bench fazem

**Blocked by:** 01, 07

**Status:** resolved

**What to build:** quem lê o perfil do tracker, o manual `anvil-omp` ou o
material do bench encontra o comportamento de hoje, e não o da 008 ou o do
upstream. A rodada extra do piloto vira contrato do perfil do tracker, com um
formato só para a linha que a abre; o manual diz o que o `/anvil-bench` chamado
direto constrói; e o `unlazy/VENDOR.md` deixa de apontar um teto rival. Decisões
do operador sobre os tickets 07 e 08 da spec 008: a mudança no implementer fica e
é registrada, e o teto de três sai do `VENDOR.md`.

- [x] As duas cópias do perfil do tracker, idênticas, descrevem na seção de
      `Review:` a linha `- Piloto · rodada <N> aberta por …`: só o piloto automático
      a escreve, uma vez por ticket, no fim do `## Comments`, e o
      `anvil-implementer` mede a rodada N quando nenhuma `Review:` tem
      `round=<N>`.
- [x] O `anvil-implementer` cita o formato que o piloto grava: caminho do arquivo
      entre crases, dois-pontos, a fonte e o que ela explica. A regra de decisão
      dele não muda.
- [x] O parágrafo do `/anvil-bench` chamado direto, em "O que continua manual" do
      `anvil-omp`, diz que ele constrói a entrada em andamento, ou a do `next:`, e
      que o archive e o merge saem listados na entrega.
- [x] O `anvil-bench/unlazy/VENDOR.md` diz o teto das duas rodadas do `GATE.md` no
      lugar do "teto de três tentativas por ticket". Os scripts e o resto do
      `unlazy/` não mudam, e o `keep` do manifesto continua igual.
- [x] Nenhum "três tentativas" sobra no payload fora do `docs/project/plan.md` e do
      ADR-0003.
- [x] Prova: `vendor-sync.sh verify` sai `0`, e o `diff` das duas cópias do perfil
      do tracker sai vazio.

## Comments

- Implementação · o `README.md` da raiz, fora do payload, também dizia que o Stop
  hook "competiria com o teto de três tentativas do próprio bench"; passou a dizer
  o teto de duas rodadas, pela mesma razão do `VENDOR.md`. Ficaram com "três
  tentativas", além do `docs/project/plan.md` e do ADR-0003, só o histórico: as
  discoveries `bench-autonomo.md` e `piloto-automatico-decisoes-do-grill.md`, a
  spec 008 arquivada e esta spec.
- Implementação · prova: `vendor-sync.sh verify` sai `0` (`verify: limpo`), o
  `diff` entre `docs/agents/issue-tracker.md` e
  `anvil/.claude/skills/anvil-docs/templates/issue-tracker-anvil.md` sai vazio, e
  `grep -rnE 'tr[eê]s tentativas|teto de tr[eê]s' anvil README.md` não acha nada.
