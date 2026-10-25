# 01: O forge falso faz o `pr create` falhar sob pedido

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** as provas do aviso de branch publicado precisam de um forge que
recuse o PR depois do push. Com um arquivo de pedido de falha na execução da prova,
como `pr-create-fails`, o `gh pr create` e o `tea pr create` falsos saem `1` com uma
mensagem de autenticação no stderr, e a chamada continua no log do forge. Sem o
arquivo, o forge falso responde como hoje, e as provas da 011 seguem valendo.

- [x] Com o arquivo de pedido, `gh pr create` e `tea pr create` saem `1`, com a
      mensagem de autenticação no stderr e sem URL no stdout; a chamada fica no
      `forge.jsonl`.
- [x] Sem o arquivo, os dois saem `0` com a URL, como hoje; a listagem de rótulos e
      de logins não muda com ou sem o arquivo.
- [x] O cabeçalho do forge falso e a seção do helper na `anvil-sync` dizem o nome
      do arquivo e o efeito.
- [x] Prova S1, num diretório novo de `workspace/`, com `workspace/72-forge-logins-labels/`
      como prior art: com e sem o arquivo, nos dois CLIs. Vermelho: o forge falso de
      `4271efd`, em que o `pr create` com o arquivo sai `0`.
- [x] As S1 de `workspace/72-forge-logins-labels/` continuam passando.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: o arquivo de pedido é `$PROOF_RUN/pr-create-fails`, criado pela
  prova depois do `proof_prepare`. As mensagens são as do CLI real sem
  autenticação, sem TTY, capturadas com config vazio: `gh: To use GitHub CLI in
  automation, set the GH_TOKEN environment variable.` e `Error: no available login`.
  O `gh` real sai `4` nesse caso, e o falso sai `1`, como pede o ticket; o
  cabeçalho do `proof-forge.py` registra a diferença. O cabeçalho do `proof.sh`
  também ganhou a frase, porque descrevia o `pr create` só no sucesso.
- Prova S1 em `workspace/82-forge-pr-create-fails/s1.sh`: verde no bash 5.2 e no
  `/bin/bash` 3.2 (`s1.out`); vermelho com o helper de `4271efd`
  (`REPO=<árvore de 4271efd> bash s1.sh`, `s1-red.out`), com as 4 falhas do
  `pr create` com o arquivo saindo `0`. A S1 de `workspace/72-forge-logins-labels/`
  passa (`s1-72.out`), e `vendor-sync.sh verify` sai `0`.
