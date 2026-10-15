# 03: O `anvil-boot` grava o comando de verificação sob o título que o piloto lê

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** quem roda o `/anvil-boot` num projeto novo sai com o comando
de teste em `.claude/rules/anvil.md`, numa seção `## Comando de verificação` com
um bloco `bash`, no formato que este repositório já usa. É essa seção que o
piloto procura na largada, e ele recusa o projeto que não a tem. Projeto sem
suíte declara o que faz as vezes dela, como este repositório faz.

- [x] O passo de rules do `anvil-boot` manda gravar o comando de teste sob
      `## Comando de verificação`, com um bloco `bash` executável na raiz.
- [x] O `anvil-boot` sem comando de teste conhecido pergunta ao usuário, como já
      faz com o resto da configuração, e não grava seção vazia.
- [x] A seção deste repositório em `.claude/rules/anvil.md` continua batendo com
      o formato descrito.
- [x] Prova: um boot de fixture em `workspace/` produz um `anvil.md` com a seção
      e o bloco, e o comando do bloco roda e sai `0`.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Prova em `workspace/45-boot-verification/s.sh` (fora do git): boot headless do
  omp em dois fixtures. Projeto Node com suíte: a seção sai com `npm test`, o
  bloco sai `0` e sai `1` com a suíte quebrada. Projeto sem suíte: o primeiro
  turno pergunta pelo comando e não grava a seção; com a resposta, a seção sai
  com o comando dado e ele sai `0`. A seção deste repositório bate com o mesmo
  formato. Antes da mudança, a mesma prova falhava em 3 checagens: o boot gravava
  o comando em prosa sob outros títulos.
