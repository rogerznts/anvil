# 03: O `anvil-boot` grava o comando de verificação sob o título que o piloto lê

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=1a6e236; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Spec): o primeiro turno do caso B não gravou arquivo nenhum, então a checagem "nenhuma seção gravada" passa sem exercitar o caminho que o `SKILL.md` promete (resto do `anvil.md` gravado, seção de fora, pendência no relatório do passo 10) — se esse caminho quebrar, a prova continua verde.
- Review round=1 · P3 (Spec): o parágrafo sobre `anvil.md` existente leva o comando gravado por um boot antigo sob outro título para a seção nova, o que o ticket ("projeto novo") não pede e nenhum fixture exercita — um re-boot pode deixar o comando duplicado sob dois títulos sem que a prova pegue.
- Review round=1 · P3 (Spec/Standards): o `SKILL.md` descreve o `anvil-auto` procurando o título e recusando o projeto, mas a skill só nasce no ticket 04 — se a spec parar antes dele, o boot descreve um piloto que não existe (o merge da spec espera todos os tickets `resolved`).
- Review round=1 · P3 (Spec): o comentário de prova não registra a saída do `vendor-sync.sh verify`, embora o critério esteja marcado — quem auditar precisa rodá-lo de novo (saiu `verify: limpo` antes do commit `1a6e236`).
- Review round=1 · P3 (Standards): a frase "O comando de teste que um boot antigo gravou sob outro título é o que a seção de verificação leva" chama a mesma coisa por dois nomes, com a ordem invertida (possível Mysterious Name) — custa uma releitura, sem mudar a ação.
- Review round=1 · P3 (Standards): o título literal `## Comando de verificação` vira contrato repetido no boot, no `anvil.md` deste repositório e na spec, e o ticket 04 cria o quarto lugar (possível Shotgun Surgery) — se o título mudar, quatro arquivos mudam juntos, e só a prova manual pega a divergência.
