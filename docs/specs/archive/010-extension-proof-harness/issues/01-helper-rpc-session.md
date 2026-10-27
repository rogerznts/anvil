# 01: O helper conduz uma sessão rpc isolada com o `/skill:` real

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=a2a6905; scope=full; verdict=pass; p1=none

**What to build:** o helper de prova, junto da ferramenta de manutenção do
repositório (a `anvil-sync`), como uma biblioteca de shell que o script da prova
carrega e um condutor da sessão rpc do omp. A prova pede uma sessão com um modelo,
um diretório de fixture e uma lista de turnos; o helper a roda pelo caminho que o
operador digita, isolada do resto da máquina, e deixa as saídas em `workspace/`.

- [x] Preparar cria um diretório da execução com nome único; duas execuções
      simultâneas não colidem.
- [x] O overlay de config da execução traz `skills.customDirectories` com os
      diretórios de skill do payload e da camada omp do repositório, e
      `retry.modelFallback: false`. A sessão carrega as skills fora do roster do
      `dev-link.sh`, como o `anvil-bench`, sem ligar nada à mão.
- [x] Conduzir abre o omp em `--mode rpc` com o overlay, o modelo pedido e o
      diretório da fixture; manda o primeiro turno como `/skill:<nome> …` e cada
      turno seguinte só depois do `prompt_result` do anterior; espera o
      `session_settled` antes de devolver.
- [x] As saídas da prova, no diretório dela em `workspace/`, trazem os frames do rpc
      e a cópia do jsonl da sessão principal, achado pelo `sessionFile` do
      `get_state`.
- [x] A limpeza roda num trap de saída, também em falha e em interrupção, e remove
      o diretório da execução.
- [x] Sem omp, git ou docker no `PATH`, ou com opção inválida, o helper sai `2` com
      o motivo.
- [x] Nada é escrito em `~/.claude`, `~/.agents` nem no config de usuário do omp.
- [x] Prova S1, num diretório novo de `workspace/`, no bash do `PATH` e no
      `/bin/bash` 3.2: diretórios distintos em execuções simultâneas; o conteúdo do
      overlay; o diretório removido no fim, no erro e num sinal; o antes e depois de
      `~/.claude`, `~/.agents` e do config de usuário do omp.
- [x] Uma sessão real curta pelo helper, com um `/skill:` do payload no primeiro
      turno e um segundo turno: o jsonl mostra a skill carregada e os dois turnos,
      e os frames ficam nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · provas em `workspace/59-proof-helper/`: `s1.sh` (sem modelo, com
  um omp falso que fala o rpc; bash 5.2 e `/bin/bash` 3.2) passou inteiro, e
  `s2.sh` (sessão real, `/skill:anvil-wait-what` — skill fora do roster e não
  ligada em `~/.claude`/`~/.agents` — e um segundo turno) passou, respondida por
  `anthropic/claude-sonnet-4-5` em 2 mensagens; o jsonl traz o `skill-prompt` com
  `[Skill directory: <repo>/anvil/.claude/skills/anvil-wait-what]`.
- Implementação · o turno seguinte vai depois do `prompt_result` **e** do
  `session_settled` do anterior, e não só do `prompt_result`: um prompt mandado
  enquanto um trabalho em segundo plano acorda o agente falha sem
  `streamingBehavior` (omp `rpc.md`, "While streaming").
- Implementação · o preparo recusa com `2` também sem `python3`, que o condutor
  (`proof-rpc.py`) usa, além de omp, git e docker. O docker é exigido sempre,
  como o ticket pede, mesmo antes da opção de infra do ticket 04.
- Review round=1 · P3 (Standards): em `proof.sh`, o `case` de fora casa `--model|--cwd|--out` e um `case` de dentro decide de novo entre os três (Repeated Switches) — uma opção nova tem de ser escrita nos dois lugares.
- Review round=1 · P3 (Standards): o status `local`, que o `proof-rpc.py` imprime quando o omp completa o turno sem agente, sai misturado aos status do protocolo (`completed`, `aborted`, `error`) na linha `proof: turno N: …` — quem lê o stderr o toma por status que o `rpc.md` não define.
- Review round=1 · P3 (Standards): no `proof-rpc.py`, o parâmetro `waiting` de `next_frame`/`until` é só o rótulo da mensagem de erro, e `p`, `a` e `s` em `main` não dizem o que guardam — quem lê `until(waiting, matches)` acha que `waiting` controla a espera.
- Review round=1 · P3 (Standards): a mensagem `o omp saiu (rc=…) …; veja omp.err` se repete em `send`, `next_frame` e `close`, e a gravação do frame em `next_frame` e `close` — mudar o formato exige três edições.
- Review round=1 · P3 (Standards): o caminho `anvil-update/.omp-layer/skills` está escrito à mão no `proof.sh` e no `dev-link.sh` (`CAMADA`) — mover a camada omp quebra o helper sem aviso.
- Review round=1 · P3 (Standards): o prefixo de erro do helper é `proof:`, e o `dev-link.sh` e o `vendor-sync.sh` usam `erro:` — só a uniformidade se perde; o prefixo diz de onde vem a linha dentro do script da prova.
- Review round=1 · P3 (Standards): `. proof.sh` sem barra faz `_PROOF_SCRIPTS` cair no `pwd`, e o cabeçalho diz "biblioteca de shell" mas o arquivo depende de bash (`BASH_SOURCE`, `local`) — quem o carregar de outro diretório, ou de `sh`/`zsh`, recebe o caminho das skills errado.
- Review round=1 · P3 (Spec): o `frames.jsonl` grava só o que o omp escreveu, sem os comandos que o helper mandou (`prompt`, `get_state`) — quem investiga uma falha reconstrói o lado de entrada pelos turnos.
- Review round=1 · P3 (Spec): a S1 manda o sinal só ao pid do bash, num grupo próprio (`set -m`), e não exercita o Ctrl-C real, que chega ao grupo inteiro — uma regressão que só aparece com o sinal no grupo passaria sem a prova acusar.
