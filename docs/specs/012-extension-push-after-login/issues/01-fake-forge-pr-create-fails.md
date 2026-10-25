# 01: O forge falso faz o `pr create` falhar sob pedido

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** as provas do aviso de branch publicado precisam de um forge que
recuse o PR depois do push. Com um arquivo de pedido de falha na execução da prova,
como `pr-create-fails`, o `gh pr create` e o `tea pr create` falsos saem `1` com uma
mensagem de autenticação no stderr, e a chamada continua no log do forge. Sem o
arquivo, o forge falso responde como hoje, e as provas da 011 seguem valendo.

- [ ] Com o arquivo de pedido, `gh pr create` e `tea pr create` saem `1`, com a
      mensagem de autenticação no stderr e sem URL no stdout; a chamada fica no
      `forge.jsonl`.
- [ ] Sem o arquivo, os dois saem `0` com a URL, como hoje; a listagem de rótulos e
      de logins não muda com ou sem o arquivo.
- [ ] O cabeçalho do forge falso e a seção do helper na `anvil-sync` dizem o nome
      do arquivo e o efeito.
- [ ] Prova S1, num diretório novo de `workspace/`, com `workspace/72-forge-logins-labels/`
      como prior art: com e sem o arquivo, nos dois CLIs. Vermelho: o forge falso de
      `4271efd`, em que o `pr create` com o arquivo sai `0`.
- [ ] As S1 de `workspace/72-forge-logins-labels/` continuam passando.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
