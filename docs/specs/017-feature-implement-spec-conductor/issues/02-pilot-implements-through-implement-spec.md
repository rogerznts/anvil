# 02: O piloto automático implementa cada spec pela `implement-spec`

**What to build:** O `anvil-auto` implementa a spec de cada entrada do roteiro chamando a `implement-spec` no branch da spec, no lugar do laço do `frontier.sh` com o `anvil-implementer`. Somem a retomada do despacho por ticket, os pulados e os travados por `Review:`. O `PASS` passa a ser todo ticket `resolved` e, fora do bench, o comando de verificação saindo `0` pelo `verification.sh`; a condição da linha `Review:` sai. A spec para quando a execução termina com P1 aberto na rodada 2 ou com ticket que não fechou, com o motivo no relatório. A "Pesquisa antes de travar" vale para a spec: com evidência nova, o piloto abre uma rodada a mais da spec, uma vez por spec, registrada no relatório. A linha do piloto no `## Comments` do ticket sai do perfil de tracker. Ver a spec, "O piloto automático".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Sobre um roteiro de uma entrada com a spec de três tickets, o piloto fecha com `PASS`, faz o archive e o merge, e a guarda de merge libera, sem ler linha `Review:`.
- [ ] Com o P1 plantado que a correção não resolve, o piloto para a spec com o motivo e não faz archive nem merge.
- [ ] Com evidência nova de pesquisa, o piloto abre uma rodada a mais da spec uma vez só, e o relatório a registra.
- [x] O `anvil-auto` não chama mais o `frontier.sh` nem o `anvil-implementer`.
- [x] O perfil de tracker do `anvil-docs` e o `docs/agents/issue-tracker.md` não descrevem mais a linha do piloto no ticket.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
