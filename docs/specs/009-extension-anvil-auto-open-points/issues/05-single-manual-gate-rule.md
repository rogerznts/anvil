# 05: A regra do gate manual sob o piloto mora só no `GATE.md`

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o piloto, no bench, recebe uma regra só para o gate manual
aberto: o gate manual desta spec deixa a spec parada e vai para o relatório como
pergunta; o de uma spec já fechada vai para "o que ainda espera decisão" e não
segura esta. Hoje o `GATE.md` diz que todo gate manual aberto para a spec, e o
`anvil-auto` exclui o de spec fechada.

- [ ] A seção "Sob o piloto automático" do `GATE.md` traz a regra inteira: gate
      manual aberto desta spec para a spec; o de spec fechada vai para "o que ainda
      espera decisão" e não segura esta; sem gate manual desta spec aberto e sem
      gate com `CHECK:` caído, a saída vale o `PASS`.
- [ ] O `anvil-auto` e a seção "Sob o piloto automático" do `SKILL.md` do bench
      apontam para essa regra em vez de repeti-la. O `anvil-auto` guarda só o que o
      piloto faz com cada desfecho: parar, registrar no relatório, seguir.
- [ ] O que o `unlazy/` traz não muda.
- [ ] Prova: os casos de gate manual do S2 de `workspace/51-auto-bench/` (spec
      parada sem pesquisa com gate manual desta spec; `PASS` com gate manual só de
      spec fechada) rodam de novo e passam, ou o limite fica declarado no ticket se
      o custo da stack não couber. O S2 registra o modelo que de fato respondeu.
- [ ] `vendor-sync.sh verify` sai `0`.
