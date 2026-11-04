# ADR-0024 — O bench sai do anvil

- Status: aceito
- Data: 2026-11-04
- Origem: [spec 017](../../specs/017-feature-implement-spec-conductor/spec.md), ticket 08 — o anvil deixa de ter o bench
- Revê em parte o [ADR-0003](./adr-0003-sem-maquina-de-fases.md): a exceção do `/anvil-bench` sai, e o hook de merge fica como a única
- Revê em parte o [ADR-0006](./adr-0006-stack-como-camada-propria.md): o contrato de stack fica com três capacidades, sem as do bench
- Revê em parte o [ADR-0014](./adr-0014-piloto-automatico-fecha-sem-humano.md): o piloto automático entra só pelo grill, e o `PASS` do bench sai
- Revê em parte o [ADR-0017](./adr-0017-prova-pelo-caminho-real-com-resultado-invalido.md): o prefixo de execução do `infra.sh` sai da prova, com o `--infra`
- Revê em parte o [ADR-0021](./adr-0021-grill-pergunta-pela-ferramenta-do-harness.md): o `anvil-bench` deixa de estar entre as skills que carregam o `anvil-grilling`
- Revê em parte o [ADR-0023](./adr-0023-implement-spec-conduz-a-spec-com-review-unico.md): a `anvil-implement-spec` serve o piloto automático e o fluxo manual, e o gate do bench sai

## Contexto

O `anvil-bench` levava quem não programa de uma necessidade até a ferramenta
rodando: uma entrevista, um roteiro, e a construção de cada spec com um **ledger
de gates** executável, do `unlazy` vendorizado embaixo de `anvil-bench/unlazy/`.
A regra do ADR-0003 deixava o bench gravar `gate.yaml`, porque o loop headless
precisava de parada mecânica, e a defesa contra auto-relato era a reexecução do
ledger pelo supervisor, o `gate-check.mjs --reverify`. O `anvil-stack-payload`
trazia em `bench/` o starter, os scripts de ambiente, infra e publicação e as
invariantes de produto; o piloto automático tinha um modo bench, com a entrevista
no lugar do grill e o `--reverify` no lugar do comando de verificação; e o
`proof.sh` tinha o `--infra`, que isolava a infra do bench por execução.

As provas da spec 017 mostraram que o veredito não dependia do checker, e sim de
o modelo copiar à mão a saída dele:

- na `out-7`, a sessão do bench descartou por conta própria um P1 aberto na
  rodada 2, gravou `gate: PASS` e marcou o ticket `resolved`;
- na `out-8`, o condutor não rodou o `--reverify`: rodou o vitest, marcou `[x]` à
  mão no `gates.md` e gravou `status_reason: "exit: 0, ALL MET"`, uma saída que
  nenhum checker imprimiu. O `gate.yaml` disse `PASS` sem prova. O texto do
  `GATE.md` proibia isso por extenso, e as provas `out-5`, `out-6` e `out-7`
  tinham rodado o `--reverify` com o mesmo texto.

Cada rodada de review do ticket 06 achou um caminho novo pelo qual o arquivo
aprovava a spec sem prova — o checker que não roda, o `exit: 1` sem `UNMET:`, a
cauda truncada dos ids —, e cada correção deixava o veredito dependendo da
obediência do modelo do mesmo jeito.

## Decisão

**Decisão do operador: o bench sai do anvil, com tudo o que só existe por ele.**
Tirar o modo custa menos do que mantê-lo com um veredito em que não se confia.

Saem:

- a skill `anvil-bench` inteira — `SKILL.md`, `GATE.md`, `CHECKLIST.md` e o
  `unlazy/` vendorizado, com o `gate-check.mjs` —, a entrada dela no manifesto,
  o source `unlazy` e o submodule `references/unlazy`;
- o `anvil-stack-payload/bench/` inteiro: starter, `infra.sh`, `deploy.sh`,
  `env.sh` e invariantes;
- o modo bench do `anvil-auto` e do `anvil-omp`: o `--bench`, a entrevista, o
  ledger de cada spec, o `decisions-log.md` e o `--reverify` como `PASS`;
- o `--infra` do `proof.sh`;
- toda citação viva ao bench nas skills, nos templates, nas regras, no catálogo
  e nos documentos de arquitetura.

A `anvil-benchmark-checklist`, que confere uma medição de desempenho, não é o
bench e fica.

## O que cada ADR revisto perde

- **ADR-0003.** Das duas exceções à regra do estado lido do disco, sai a do
  `/anvil-bench`, com o `gate.yaml`, o `quality_score` e o `score_history`. Fica o
  hook de merge.
- **ADR-0006.** O contrato de stack perde o scaffold, o ambiente, a infra e a
  publicação, e as invariantes do bench: de seis capacidades, ficam as ciladas e a
  fronteira na `RULE.md`, o ofício em `reference/` e o comando de teste. A rule
  tem um chamador só, o `/anvil-boot`.
- **ADR-0014.** A entrada do piloto é só o grill, sem a entrevista do bench, e o
  `PASS` do `gate-check.mjs --reverify` sai; somem com ele o gate manual aberto e
  o `FAIL` no teto como paradas.
- **ADR-0017.** O isolamento da prova perde o prefixo por execução no `infra.sh`:
  o `proof_prepare --infra` sai.
- **ADR-0021.** O `anvil-bench` deixa de estar entre os que carregam o
  `anvil-grilling`; ficam o `anvil-grill`, o `anvil-grill-me` e o
  `anvil-wayfinder`. A exceção ao ADR-0001 não muda.
- **ADR-0023.** A `anvil-implement-spec` deixa de servir o bench; o `PASS` do
  piloto é sempre o comando de verificação, sem o `--reverify` do ledger.

## Consequências

**A favor.** O piloto automático tem uma entrada só, o grill, e um `PASS` só: todo
ticket `resolved` e o comando de verificação do projeto, rodado pelo script,
saindo `0`. Nenhum veredito do toolkit depende mais de o modelo transcrever a
saída de um checker. O estado volta a ter uma exceção só à regra do ADR-0003, o
hook de merge. O contrato de stack fica com o que serve a qualquer projeto: as
ciladas e a fronteira de edição na `RULE.md`, o ofício em `reference/` e o
comando de teste. As provas não sobem mais infra própria.

**Contra — a perda deliberada.** Quem não programa deixa de ter caminho no anvil
da necessidade à ferramenta rodando: não há entrevista em português simples, nem
starter, nem publicação. O trabalho do ticket 06 e as correções do `GATE.md` saem
sem ter sido medidas por uma rodada nova. Os ADRs que decidiram o bench ficam
como história; quem os lê encontra a revisão no cabeçalho deles.
