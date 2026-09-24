# Acompanhamento

Achados P2 e P3 que sobraram de specs fechadas e não seguraram o fechamento,
pelo critério de `docs/agents/verification.md`. Cada linha diz de onde veio e o
que acontece se ninguém mexer. Quem pegar uma linha abre uma spec `extension`
ligada à spec de origem e tira a linha daqui no mesmo branch.

## Spec 003: omp como harness, com camada própria

Origem: `docs/specs/archive/003-feature-omp-harness/`. Os demais P2 e P3
abertos dos tickets 08, 09 e 10 foram aceitos no fechamento, e a decisão está
registrada nos `## Comments` de cada ticket.

- **A1 · `Blocked by` fora do formato falha aberto.** Ticket 08, rodada 2, P2.
  O `frontier.sh` corta a linha na primeira letra que não é dígito, vírgula ou
  espaço. "01 e 02", "01 (a), 02 (b)", "`05`" e "01; 05" perdem bloqueadores, e
  a `anvil-run` despacha um ticket em cima de um bloqueador travado. O perfil
  fixa `NN, NN`, mas o template da `anvil-to-tickets` aceita números ou títulos.
  O review sugere tirar só os tokens `ADR-NNNN`.
- **A2 · árvore suja para em vez de retomar.** Ticket 08, rodada 1, P2. A US 45
  (rodar de novo retoma de onde parou) promete retomada. O `frontier.sh` para o
  despacho com qualquer arquivo fora de commit, inclusive a sobra de um
  implementer que caiu no meio. Quem lê a spec só descobre isso na primeira
  execução. Falta decidir se a parada entra no manual `anvil-omp` ou se a
  retomada limpa a sobra.
- **A3 · `p1_aberto` perde linha combinada.** Ticket 08, rodada 2, P3. Uma
  linha como "Review round=2 · P2 (Standards) e P1 (Spec)" não é lida como P1.
  O ticket travado continua listado, mas o relatório diz que não há linha P1.
- **A4 · caixa alta acentuada sob `LC_ALL=C`.** Ticket 08, rodada 2, P3. O
  `grep -i` do BSD não iguala "PÁGINA" nem "BOTÃO" com locale `C`, a linha
  `tela` sai `nao`, e a `anvil-run` recomenda o archive para uma spec com tela.
  Em `pt_BR.UTF-8` funciona.
- **A5 · check 15 não confere o comando.** Ticket 09, rodada 2, P3. O check 15
  do `vendor-sync.sh verify` lê o caminho citado na prosa da skill, não o
  comando dentro do bloco `bash`. Um erro de digitação só no comando passa no
  `verify` e quebra a `anvil-plan` ou a `anvil-run` no primeiro passo.
- **A6 · exemplos errados no `tela: nao`.** Ticket 10, rodada 1, P3. A
  `anvil-run` dá "página, formulário, painel" como exemplos de história que sobe
  um `nao` para o browser QA. O `PALAVRAS_TELA` do `frontier.sh` já reconhece
  essas palavras, então elas nunca aparecem num `nao`, e o supervisor fica sem
  exemplo do caso que deveria subir.
- **A7 · desvios da `anvil-plan` sem prova.** Tickets 09 e 10, P2. Rodaram o
  `anvil-research` e o `anvil-to-questionnaire`, os dois saídos do grill.
  `anvil-prototype`, `anvil-wayfinder`, `anvil-ui` e `anvil-architect` nunca
  rodaram, e nenhum desvio saiu do to-spec ou do to-tickets. As US 51 e 52
  (desvio proposto pelo sinal, e volta à etapa de origem) estão provadas em
  parte. Um desvio que não volta à origem só aparece no uso.
- **A8 · identificadores em português nos scripts da camada.** Tickets 08 e 09,
  P3. O `frontier.sh` (`recusa`, `pular`, `proximo`, `tudo_resolvido`, `sim`,
  `nao`) e o `stage.sh` (`saida`, `pasta_de`, `arq`, `abertas`) contrariam a
  regra de idioma do `CLAUDE.md` para código. As chaves de saída do
  `frontier.sh` são lidas pela `anvil-run`, então renomear mexe nos dois.
- **A9 · os condutores só funcionam com o perfil `docs/specs`.** Fechamento,
  conferência contra o briefing. O briefing (`docs/discovery/adaptar-omp-ao-anvil.md`,
  l. 362–363) abria o supervisor lendo `docs/agents/issue-tracker.md`. O
  `frontier.sh` e o `stage.sh` fixam `docs/specs/{NNN}-*/` e o branch
  `{tipo}/{NNN}-{nome}`. A camada instala mesmo com outro perfil do `anvil-setup`,
  e aí o `anvil-run` recusa sempre e o `anvil-plan` volta ao grill. A restrição
  entrou nos Limites do manual `anvil-omp` no fechamento. Falta decidir se os
  condutores leem o perfil ou se a detecção deixa de instalá-los fora do
  `docs/specs`.
- **A10 · frontier em paralelo com worktree isolado.** Out of Scope da spec e
  alternativa descartada do ADR-0011, com a promessa de uma linha no tracker
  para medir depois do modo em série. Os tickets tracer bullet se cruzam nos
  arquivos, e `Status:` e `Review:` voltariam de workspaces diferentes. Medir o
  modo em série antes de abrir.
- **A11 · `verify` morre em `/bin/bash` 3.2.** Ticket 06, P2, anterior à spec. O
  `vendor-sync.sh verify` sai com SIGTRAP (rc 133) no check 3 sob o bash 3.2 do
  macOS. Quem não tem bash novo no `PATH` fica sem `verify`, e os checks da
  camada nem chegam a rodar.
