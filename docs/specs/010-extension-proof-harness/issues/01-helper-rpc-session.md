# 01: O helper conduz uma sessão rpc isolada com o `/skill:` real

**Blocked by:** None (can start immediately)

**Status:** resolved

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
