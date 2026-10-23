# 01: O helper conduz uma sessão rpc isolada com o `/skill:` real

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o helper de prova, junto da ferramenta de manutenção do
repositório (a `anvil-sync`), como uma biblioteca de shell que o script da prova
carrega e um condutor da sessão rpc do omp. A prova pede uma sessão com um modelo,
um diretório de fixture e uma lista de turnos; o helper a roda pelo caminho que o
operador digita, isolada do resto da máquina, e deixa as saídas em `workspace/`.

- [ ] Preparar cria um diretório da execução com nome único; duas execuções
      simultâneas não colidem.
- [ ] O overlay de config da execução traz `skills.customDirectories` com os
      diretórios de skill do payload e da camada omp do repositório, e
      `retry.modelFallback: false`. A sessão carrega as skills fora do roster do
      `dev-link.sh`, como o `anvil-bench`, sem ligar nada à mão.
- [ ] Conduzir abre o omp em `--mode rpc` com o overlay, o modelo pedido e o
      diretório da fixture; manda o primeiro turno como `/skill:<nome> …` e cada
      turno seguinte só depois do `prompt_result` do anterior; espera o
      `session_settled` antes de devolver.
- [ ] As saídas da prova, no diretório dela em `workspace/`, trazem os frames do rpc
      e a cópia do jsonl da sessão principal, achado pelo `sessionFile` do
      `get_state`.
- [ ] A limpeza roda num trap de saída, também em falha e em interrupção, e remove
      o diretório da execução.
- [ ] Sem omp, git ou docker no `PATH`, ou com opção inválida, o helper sai `2` com
      o motivo.
- [ ] Nada é escrito em `~/.claude`, `~/.agents` nem no config de usuário do omp.
- [ ] Prova S1, num diretório novo de `workspace/`, no bash do `PATH` e no
      `/bin/bash` 3.2: diretórios distintos em execuções simultâneas; o conteúdo do
      overlay; o diretório removido no fim, no erro e num sinal; o antes e depois de
      `~/.claude`, `~/.agents` e do config de usuário do omp.
- [ ] Uma sessão real curta pelo helper, com um `/skill:` do payload no primeiro
      turno e um segundo turno: o jsonl mostra a skill carregada e os dois turnos,
      e os frames ficam nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
