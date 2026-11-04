# 03: O bench constrói pela `implement-spec`

**What to build:** A fase "Construir" do `anvil-bench` passa a ser a `implement-spec` sobre a spec da entrada, seguida do gate que reexecuta o ledger da spec e o das specs do roteiro já fechadas. O teto de duas rodadas passa a ser o da spec: rodada 1 no fim, rodada 2 sobre a correção. O `GATE.md` troca as condições por ticket pelas da spec: `CONCERNS` quando a rodada 2 da spec ainda tem P1; `FAIL` quando o `--reverify` derruba um gate. Ver a spec, "O bench".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O diagrama e o texto de "Construir" do `anvil-bench` descrevem a `implement-spec` e o gate do ledger, sem `anvil-implement` por ticket.
- [ ] O `GATE.md` não cita mais rodada nem `Review:` por ticket, e os vereditos `CONCERNS` e `FAIL` dizem a condição da spec.
- [ ] Num projeto do bench com uma entrada pequena, chamado direto no omp, o bench constrói pela `implement-spec` e o veredito sai do `--reverify` do ledger.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
