# 10: O piloto entra pelo bench e fecha cada spec pelo `--reverify` acumulado

**Blocked by:** 07, 09

**Status:** resolved

**What to build:** o piloto entra pela entrevista do bench quando o projeto tem a
rule da stack do bench ou quando é chamado com `--bench`, e pelo `anvil-grill`
nos outros casos. No bench, a confirmação é sobre o roteiro em português simples.
O comando de verificação das rules não é exigido na largada. Na corrente, cada
spec roda a fase 4 do bench antes do `anvil-to-spec`. O `PASS` da spec k é o
`gate-check.mjs --reverify`, rodado pelo piloto, sobre o `gates.md` dela e sobre
o de cada spec do roteiro já `closed`. Um gate manual aberto, em item coberto
pela entrada, segura o fechamento e vai para o relatório com a pergunta
formulada. O `FAIL` no teto do bench leva à pesquisa do ticket 07. O relatório
traz o `decisions-log.md`, e o chat recebe a versão em português simples.

- [x] A entrada pelo bench é escolhida pela rule da stack ou por `--bench`, e por
      nenhum outro sinal.
- [x] No bench, a largada não recusa por falta de `## Comando de verificação`.
      As outras recusas valem.
- [x] A fase 4 roda por spec, depois do `Spec:` na `main` e antes do
      `anvil-to-spec`.
- [x] O `PASS` reexecuta o `gates.md` da spec e o de cada spec `closed` do
      roteiro. Uma regressão numa spec fechada impede o fechamento.
- [x] Um gate manual aberto deixa a spec parada, sem pesquisa, com a pergunta em
      "o que ainda espera decisão".
- [x] O `FAIL` no teto dispara a pesquisa antes de travar.
- [x] O `report.md` traz o `decisions-log.md`, e o chat termina com a versão em
      português simples, sem log, comando nem nome de tecnologia.
- [x] Verificação no ponta a ponta manual da spec: a corrente de duas entradas
      no omp, com a stack plugada.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: o `anvil-auto` ganhou a seção "Modo bench". O sinal é a rule com
  a seção "Invariantes do bench", que só a fase 2 do bench acrescenta à rule da
  stack (`grep -l 'Invariantes do bench' .claude/rules/*.md`), ou o `--bench` no
  argumento; uma rule de stack sem essa seção, como a do `anvil-boot`, não liga o
  modo. No bench, a largada pula o passo 3, a entrada são as fases 1 a 3 do
  bench com a conferência das inacabadas do piloto, a confirmação é sobre a versão
  em português simples, e o commit do sim leva também o starter e a rule. Na
  corrente, o passo 3 abre a spec e roda o ledger; o `PASS` do bench é o comando
  de "A evidência" do `GATE.md`, lido com três saídas (`ALL MET`; só gate manual
  aberto, que para sem pesquisa; o resto, `FAIL` no teto, que pesquisa). O
  relatório traz o `decisions-log.md` de cada spec, escrito pelo piloto, e o fim
  no bench é a versão em português simples.
- Implementação: o comando de "A evidência" do `GATE.md` passou a ser o
  `--reverify` acumulado, também no bench chamado direto: os ledgers das specs
  `closed` saem do `roadmap.sh`, o `--cwd .` roda os `CHECK:` da raiz (o ledger
  arquivado fica um nível mais fundo), e o `git checkout --` devolve os ledgers
  arquivados como estavam, porque o checker reescreve a evidência de todo ledger
  que reexecuta. O `SKILL.md` do bench ganhou a seção "Sob o piloto automático":
  sob o piloto, nem a fase 2 nem a fase 4 commitam, e *Uma entrada do roteiro*
  não roda.
- Decisão tomada pelo repositório, sem operador: no bench, o `PASS` mantém as duas
  condições de ticket de fora do bench (todos `resolved`, última `Review:` em
  `verdict=pass; p1=none`) e troca só o comando de verificação pelo
  `--reverify`. A spec diz "No bench, `PASS` é o `--reverify`", e fechar com
  ticket aberto seria barrado pela guarda de qualquer forma.
- Decisão tomada pelo repositório, sem operador: um gate manual aberto no ledger
  de uma spec fechada é dela (história 59) e não segura a spec desta volta; vai
  para "o que ainda espera decisão".
- Fora do que a spec lista, e necessário para a corrente rodar: o
  `.gitignore` do starter (`anvil-stack-payload/bench/starter`, no `keep`) passou a
  ignorar `next-env.d.ts`, `*.tsbuildinfo` e `.pnpm-store/`, que o app escreve ao
  subir no container. Sem isso, a árvore sujava, o `frontier.sh` dava `halt` antes
  do primeiro ticket e a execução inteira parava
  (`workspace/51-auto-bench/out-e2e-halt-next-env/`).
- S2 em `workspace/51-auto-bench/s2.sh` (fora do git), `omp -p --mode json`,
  sonnet. Entrada, um turno cada: E1 (rule do bench, sem comando) e E2
  (`--bench`, sem a rule nem comando) entram pelo bench sem recusa e sem commit;
  E3 (sem nenhum dos dois, sem comando) recusa pelo comando; E4 (rule de stack sem
  a seção do bench, pedido com cara de bench) entra pelo grill; E5 (rule do bench,
  árvore suja) recusa pela árvore. PASS, em retomada no branch da 002 com a 001
  arquivada na main, num container `node:22-alpine`: G (gate manual C3 aberto)
  para sem pesquisa, com a pergunta de C3 no relatório, e o ledger da 001 foi
  reexecutado e devolvido; R (o ticket da 002 quebrou o C1 da 001) pesquisou,
  abriu a rodada extra e fechou só com o C1 passando na `main`. A prova vermelha,
  com a skill do ticket 09, está em `s2-red.out` e `out-red/`: E1, E2, G e R
  recusam pela falta do comando, e E4 carrega o `anvil-bench` depois do grill. A
  primeira rodada verde de G e R (`out/G-oci`, `out/R-oci`) bateu num container
  de fixture velho; com a fixture corrigida, `s2-GR.out` passa inteiro.
- Ponta a ponta em `workspace/51-auto-bench/e2e.sh` (fora do git), no omp, com a
  stack Payload plugada: projeto novo em `/tmp`, sem rule de stack e sem
  comando, piloto com `--bench`. Roteiro de duas entradas mostrado em português
  simples no turno 3, sim no turno 4; as duas specs fecharam com archive e merge
  local, cada uma com o `gates.md` só do `Cobre:` dela, escrito antes da
  `spec.md`; o `--reverify` da 002 reexecutou o ledger arquivado da 001 (`ALL
  MET`, 6 gates) e o devolveu sem mudança; o `report.md` traz o
  `decisions-log.md` e as saídas do `--reverify`; o chat termina em português
  simples. Passaram as 20 conferências (`e2e.out`). Nenhum gate manual apareceu
  nesse roteiro: o gate manual ficou provado só no caso G do S2.
- As rodadas do S2 (E1, E2) e do ponta a ponta provisionaram as fixtures na infra
  compartilhada, em `~/projects/.anvil-infra/registry.yaml`, como no ticket 09.
