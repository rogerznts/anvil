# 05: A regra do gate manual sob o piloto mora só no `GATE.md`

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=b847c41; scope=full; verdict=pass; p1=none

**What to build:** o piloto, no bench, recebe uma regra só para o gate manual
aberto: o gate manual desta spec deixa a spec parada e vai para o relatório como
pergunta; o de uma spec já fechada vai para "o que ainda espera decisão" e não
segura esta. Hoje o `GATE.md` diz que todo gate manual aberto para a spec, e o
`anvil-auto` exclui o de spec fechada.

- [x] A seção "Sob o piloto automático" do `GATE.md` traz a regra inteira: gate
      manual aberto desta spec para a spec; o de spec fechada vai para "o que ainda
      espera decisão" e não segura esta; sem gate manual desta spec aberto e sem
      gate com `CHECK:` caído, a saída vale o `PASS`.
- [x] O `anvil-auto` e a seção "Sob o piloto automático" do `SKILL.md` do bench
      apontam para essa regra em vez de repeti-la. O `anvil-auto` guarda só o que o
      piloto faz com cada desfecho: parar, registrar no relatório, seguir.
- [x] O que o `unlazy/` traz não muda.
- [x] Prova: os casos de gate manual do S2 de `workspace/51-auto-bench/` (spec
      parada sem pesquisa com gate manual desta spec; `PASS` com gate manual só de
      spec fechada) rodam de novo e passam, ou o limite fica declarado no ticket se
      o custo da stack não couber. O S2 registra o modelo que de fato respondeu.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Prova em `workspace/56-manual-gate-rule/s2.sh`, com a fixture do S2 de
  `workspace/51-auto-bench/`: o caso G, gate manual aberto desta spec, e o caso F,
  novo, com o ledger arquivado da 001 trazendo o gate manual C4 aberto e o da 002
  só com o C2, que passa. Pedido `claude-sonnet-4-5`; respondeu
  `anthropic/claude-sonnet-4-5` nos dois casos, lido do jsonl.
- Vermelho (`out-red/`, só o F, antes da mudança): as conferências do gate manual
  já passavam, porque o `anvil-auto` trazia a exceção da spec fechada; a mudança
  tira a regra rival do `GATE.md`, que o piloto lê no mesmo `PASS`.
- Verde (`s2.out`): todas as conferências do gate manual passam. G: a spec 002
  fica parada, sem pesquisa, nem archive nem merge, o C3 aberto no branch, a
  pergunta dele em "o que ainda espera decisão" e a entrada `stopped`. F: o
  `--reverify` sai `1` com só `gates:C4` abaixo de `UNMET:`, a 002 é arquivada e
  mesclada na `main`, o C4 continua aberto no ledger arquivado da 001, a pergunta
  dele vai para "o que ainda espera decisão" e a entrada fica `closed`.
- Limite declarado: o S2 não sai todo verde. Três conferências caem fora da regra
  deste ticket. Em G e F, a mensagem do fim traz jargão (G) ou não termina numa
  pergunta (F), variação do modelo na fase 6. Em F, vermelho e verde, o relatório
  diz "nenhum" no `decisions-log.md`: o piloto o lê com
  `git show <branch>:docs/specs/002-…/decisions-log.md` depois do archive, que já
  moveu a pasta para `docs/specs/archive/`, e o `git show` falha. É o "No bench, a
  seção de cada spec traz o `decisions-log.md` dela, lido do branch com
  `git show <branch>:<caminho>`" do `anvil-auto`, que não diz o caminho depois do
  archive — defeito anterior a este ticket, fora do que a spec 009 lista.
- O `anvil-bench` e o `anvil-stack-payload` foram ligados por symlink em
  `~/.claude/skills` e `~/.agents/skills` só durante as vezes, e desligados depois.
- Review round=1 · P2 (Standards): regra sem precedência na saída mista — com um gate manual desta spec aberto e um gate com `CHECK:` caído juntos, a saída cabe no item do gate manual do `GATE.md` (parada sem pesquisa) e no do `FAIL` no teto (pesquisa), e o `anvil-auto` dispensa a pesquisa "no gate manual aberto desta spec" — o piloto pode parar a spec sem pesquisar a regressão do `CHECK:`; a spec não fecha em nenhum dos dois caminhos.
- Review round=1 · P3 (Spec): a regra não cobre toda saída — sumiu o "qualquer outra saída" do `anvil-auto`, e a saída mista acima e o `HANDOFF REQUIRED` de um gate abandonado ficam sem desfecho no `GATE.md` — o piloto escolhe sozinho nesses casos, raros porque o bench não escreve `ABANDON`.
- Review round=1 · P3 (Spec): a prova não separa antes e depois — o vermelho do caso F já passava nas conferências do gate manual, então o S2 não mostra efeito observável da mudança, que só tira a regra rival.
- Review round=1 · P3 (Standards): possível Duplicated Code — "nem você nem o implementer o marcam" (`anvil-auto`, no `--reverify` do bench e no "Nunca") repete o "Nem o piloto nem o implementer o marcam" do `GATE.md`, que ainda repete "ninguém o marca" no item da spec fechada — mudar essa proibição continua pedindo três edições.
- Review round=1 · P3 (Standards): "S2" sem glosa nos `## Comments` deste ticket — quem lê sem abrir `workspace/51-auto-bench/` não sabe que é a sessão headless do omp com `/skill:anvil-auto` da spec.
