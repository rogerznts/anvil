# 02: O piloto automático implementa cada spec pela `implement-spec`

**What to build:** O `anvil-auto` implementa a spec de cada entrada do roteiro chamando a `implement-spec` no branch da spec, no lugar do laço do `frontier.sh` com o `anvil-implementer`. Somem a retomada do despacho por ticket, os pulados e os travados por `Review:`. O `PASS` passa a ser todo ticket `resolved` e, fora do bench, o comando de verificação saindo `0` pelo `verification.sh`; a condição da linha `Review:` sai. A spec para quando a execução termina com P1 aberto na rodada 2 ou com ticket que não fechou, com o motivo no relatório. A "Pesquisa antes de travar" vale para a spec: com evidência nova, o piloto abre uma rodada a mais da spec, uma vez por spec, registrada no relatório. A linha do piloto no `## Comments` do ticket sai do perfil de tracker. Ver a spec, "O piloto automático".

**Blocked by:** 01

**Status:** resolved

- [x] Sobre um roteiro de uma entrada com a spec de três tickets, o piloto fecha com `PASS`, faz o archive e o merge, e a guarda de merge libera, sem ler linha `Review:`.
- [x] Com o P1 plantado que a correção não resolve, o piloto para a spec com o motivo e não faz archive nem merge.
- [x] Com evidência nova de pesquisa, o piloto abre uma rodada a mais da spec uma vez só, e o relatório a registra.
- [x] O `anvil-auto` não chama mais o `frontier.sh` nem o `anvil-implementer`.
- [x] O perfil de tracker do `anvil-docs` e o `docs/agents/issue-tracker.md` não descrevem mais a linha do piloto no ticket.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Prova no omp real: `workspace/94-pilot-implement-spec/out-A` e `out-B` (fecha com `PASS`, archive e merge sem ler `Review:`; para com P1 sem archive nem merge) e `out-A3` (regressão verde depois da terceira rodada); `workspace/96-pilot-research-round/out-3` (rodada a mais por pesquisa aberta uma vez, registrada no relatório, spec fechada).
- Review da spec · rodada 3, declarada pelo operador: a prova `96-…/out-1` mostrou o piloto revertendo arquivos com implementer em segundo plano ainda vivo e aceitando "impossível" sem pesquisar. Corrigido em `e49c986` e `7fed9de` (o review da rodada 3 achou a contradição entre seções que `7fed9de` fecha).
- Review da spec · rodada 3 · P3: o brief da rodada 2 do review depois de uma rodada a mais não aponta o arquivo da pesquisa, embora a skill peça o ponteiro em todo brief — o revisor da rodada pode não ler a evidência que a abriu.
