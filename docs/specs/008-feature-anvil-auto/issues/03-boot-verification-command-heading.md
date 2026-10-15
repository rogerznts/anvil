# 03: O `anvil-boot` grava o comando de verificação sob o título que o piloto lê

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** quem roda o `/anvil-boot` num projeto novo sai com o comando
de teste em `.claude/rules/anvil.md`, numa seção `## Comando de verificação` com
um bloco `bash`, no formato que este repositório já usa. É essa seção que o
piloto procura na largada, e ele recusa o projeto que não a tem. Projeto sem
suíte declara o que faz as vezes dela, como este repositório faz.

- [ ] O passo de rules do `anvil-boot` manda gravar o comando de teste sob
      `## Comando de verificação`, com um bloco `bash` executável na raiz.
- [ ] O `anvil-boot` sem comando de teste conhecido pergunta ao usuário, como já
      faz com o resto da configuração, e não grava seção vazia.
- [ ] A seção deste repositório em `.claude/rules/anvil.md` continua batendo com
      o formato descrito.
- [ ] Prova: um boot de fixture em `workspace/` produz um `anvil.md` com a seção
      e o bloco, e o comando do bloco roda e sai `0`.
- [ ] `vendor-sync.sh verify` sai `0`.
