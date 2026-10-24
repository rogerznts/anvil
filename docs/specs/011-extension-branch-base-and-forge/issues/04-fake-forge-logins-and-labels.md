# 04: O forge falso responde logins e rótulos

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o forge falso do helper de prova passa a responder o que as
skills neutras perguntam antes de abrir o PR: a lista de logins do `tea`, que a
prova configura, e a lista de rótulos dos dois CLIs.

- [ ] A prova configura os logins do `tea` falso (nome, `url`, `ssh_host`, padrão),
      e o `tea login list --output json` os devolve no formato do `tea` real, com
      `name`, `url`, `ssh_host`, `user` e `default`.
- [ ] O `gh label list` e o `tea labels list` falsos devolvem uma lista de rótulos
      que a prova configura, com um padrão quando ela não configura.
- [ ] Cada chamada continua no log do forge, com argumentos e diretório.
- [ ] O cabeçalho do helper e a seção "Helper de prova" da `anvil-sync` dizem as
      opções novas.
- [ ] Prova S1, num diretório novo de `workspace/`, com
      `workspace/61-bare-remote-forge/` como prior art: os logins configurados no
      formato do `tea`; os rótulos dos dois CLIs; as S1 dos tickets 01 a 04 e 10 da
      010 continuam passando.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
