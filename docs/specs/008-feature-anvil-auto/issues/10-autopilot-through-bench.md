# 10: O piloto entra pelo bench e fecha cada spec pelo `--reverify` acumulado

**Blocked by:** 07, 09

**Status:** ready-for-agent

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

- [ ] A entrada pelo bench é escolhida pela rule da stack ou por `--bench`, e por
      nenhum outro sinal.
- [ ] No bench, a largada não recusa por falta de `## Comando de verificação`.
      As outras recusas valem.
- [ ] A fase 4 roda por spec, depois do `Spec:` na `main` e antes do
      `anvil-to-spec`.
- [ ] O `PASS` reexecuta o `gates.md` da spec e o de cada spec `closed` do
      roteiro. Uma regressão numa spec fechada impede o fechamento.
- [ ] Um gate manual aberto deixa a spec parada, sem pesquisa, com a pergunta em
      "o que ainda espera decisão".
- [ ] O `FAIL` no teto dispara a pesquisa antes de travar.
- [ ] O `report.md` traz o `decisions-log.md`, e o chat termina com a versão em
      português simples, sem log, comando nem nome de tecnologia.
- [ ] Verificação no ponta a ponta manual da spec: a corrente de duas entradas
      no omp, com a stack plugada.
- [ ] `vendor-sync.sh verify` sai `0`.
