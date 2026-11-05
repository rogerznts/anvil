# 03: O bench constrói pela `implement-spec`

**What to build:** A fase "Construir" do `anvil-bench` passa a ser a `implement-spec` sobre a spec da entrada, seguida do gate que reexecuta o ledger da spec e o das specs do roteiro já fechadas. O teto de duas rodadas passa a ser o da spec: rodada 1 no fim, rodada 2 sobre a correção. O `GATE.md` troca as condições por ticket pelas da spec: `CONCERNS` quando a rodada 2 da spec ainda tem P1; `FAIL` quando o `--reverify` derruba um gate. Ver a spec, "O bench".

**Blocked by:** 01

**Status:** resolved

- [x] O diagrama e o texto de "Construir" do `anvil-bench` descrevem a `implement-spec` e o gate do ledger, sem `anvil-implement` por ticket.
- [x] O `GATE.md` não cita mais rodada nem `Review:` por ticket, e os vereditos `CONCERNS` e `FAIL` dizem a condição da spec.
- [x] Num projeto do bench com uma entrada pequena, chamado direto no omp, o bench constrói pela `implement-spec` e o veredito sai do `--reverify` do ledger.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Prova no omp real: `workspace/95-bench-implement-spec/out-5`, sobre `b1bc1e2`: o implementer escreve o código, a correção sai de outro implementer e a rodada 2 mede o diff dela, `resolved` só depois das duas rodadas, `--reverify` depois e veredito dele, nenhuma `Review:`. As provas `out`, `out-3` reprovaram: a sessão principal construía e marcava `resolved` cedo. Corrigido em `b2dabac` e `b1bc1e2`.
- Achado fora do escopo · P2: o bench não escreve o `gate.yaml` que o `GATE.md` descreve, nas três execuções — quem audita o veredito do bench não tem o arquivo. Anterior a esta spec, que não mexeu nessa instrução.
