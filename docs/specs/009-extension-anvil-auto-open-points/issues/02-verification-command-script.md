# 02: O piloto lê e roda o comando de verificação por um script

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** a largada e o `PASS` do piloto leem o mesmo bloco de
`## Comando de verificação` de `.claude/rules/anvil.md` por um script da camada
omp, e o `PASS` roda o comando que o projeto declarou, e não um que o modelo
digitou depois de errar o escape do `awk` inline. O relatório grava a saída do
comando declarado e a linha `exit:` que o script imprime.

- [ ] Script novo na pasta do `anvil-auto` na camada omp, com duas operações:
      conferir (imprime o comando e sai `0`; sem a seção, sem bloco `bash` nela ou
      com bloco vazio, sai diferente de `0` com o motivo numa linha) e rodar (roda
      o bloco da raiz do projeto, com a saída do comando e uma última linha
      `exit: <código>`).
- [ ] O título lido é o exato `## Comando de verificação`, o que o `anvil-boot`
      grava; o título não muda.
- [ ] A largada do `anvil-auto` usa conferir, e o `PASS` usa rodar. O `awk` inline
      sai das duas seções.
- [ ] O script é instalado com o resto da camada omp, pelo `reset-install.sh` e
      pelo `dev-link.sh`, sem passo extra.
- [ ] Prova do script num diretório novo de `workspace/`: rule com a seção e um
      bloco com aspas e `$` dentro roda o comando declarado, com o `exit:` do
      comando; rule sem a seção, seção sem bloco e bloco vazio são recusados com o
      motivo.
- [ ] Prova S2 (prior art `workspace/47-auto-chain/`): uma corrente com esse bloco
      fecha, e a saída gravada no relatório é a do comando declarado. O S2
      registra o modelo que de fato respondeu, lido do jsonl.
- [ ] `vendor-sync.sh verify` sai `0`, e o check 15 passa com o script citado pelo
      `anvil-auto`.
