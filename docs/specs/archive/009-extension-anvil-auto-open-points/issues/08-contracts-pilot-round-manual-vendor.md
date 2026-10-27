# 08: Os contratos dizem o que o piloto, o implementer e o bench fazem

**Blocked by:** 01, 07

**Status:** resolved
**Review:** round=1; sha=82d9f609ea883e370cb9420e53669afe854c1ebf; scope=full; verdict=pass; p1=none

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
- Review round=1 · P3 (Standards): o formato da linha do piloto mora em três
  textos, o perfil do tracker nas duas cópias, o `anvil-auto/SKILL.md` e o
  `anvil-implementer.md`, e o do implementer usa marcadores mais curtos
  (`` `<arquivo>` ``, "o que ela explica") — uma mudança futura no formato exige
  três edições, e a diferença de marcador já existe.
- Review round=1 · P3 (Standards): o template do perfil do tracker, que vai para
  todo projeto, cita "a skill `anvil-auto`", que só existe na camada omp — quem lê
  o perfil num projeto Claude Code procura uma skill que não tem, sem mudança de
  comportamento, porque a linha nunca é gravada ali.
- Review round=1 · P3 (Standards): sobraram linhas curtas sem realinhar no
  `anvil-implementer.md` (l.31) e no `anvil-omp/SKILL.md` (a que termina em "O
  Codex lê as skills") — só a leitura do Markdown cru piora.
- Review round=1 · P3 (Spec): "a única rodada que não segue o orçamento" no perfil
  do tracker só é exata com N 3 ou mais; com N 1 ou 2 a rodada do piloto cabe no
  orçamento de `verification.md` — repete a moldura do piloto, e o implementer
  mede N do mesmo jeito, então nada quebra.
- Review round=1 · P3 (Spec): os marcadores da linha do piloto no implementer
  diferem dos do piloto e do perfil, contra o "um formato só" da spec — a
  estrutura é a mesma e a leitura não falha; um leitor que compare os três textos
  acha que divergem.
- Review round=1 · P3 (Spec): a troca no `README.md` da raiz, fora do payload, não
  foi pedida pelo ticket — segue a razão do `VENDOR.md` e não quebra nada.
- Review round=1 · P3 (Spec): o manual não cita o caso sem roteiro com spec
  aberta, em que o bench constrói essa spec — quem lê "sem ela, a do `next:`" pode
  esperar nada construído com `next: none`; o ticket não pede esse caso.
