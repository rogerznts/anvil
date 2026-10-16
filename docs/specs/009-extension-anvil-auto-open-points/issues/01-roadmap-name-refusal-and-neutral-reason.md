# 01: O `roadmap.sh` recusa nome fora de kebab-case e não fala de PR sem saber

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** quem escreve um roteiro com uma entrada chamada, por exemplo,
`Cadastro de clientes` recebe do `roadmap.sh` uma recusa com o nome e o formato
esperado, antes de o piloto ou o bench criarem uma spec com ele. E a spec
arquivada no branch e ainda sem merge passa a sair `stopped` com um motivo que
não fala de PR, para que o índice e o relatório de um projeto sem PR não mintam.
Decisão do operador sobre o ticket 01 da spec 008: o nome fora de kebab-case é
recusado.

- [ ] Nome de entrada que não é kebab-case (minúsculas ASCII e dígitos em grupos
      separados por um hífen, sem hífen no começo nem no fim) gera uma linha
      `refusal:` com o nome entre aspas simples e o formato esperado, na mesma
      lista das recusas de hoje: uma linha por nome, saída `2`, sem frontier.
- [ ] `a`, `cadastro-de-clientes` e `fase-2-relatorios` seguem válidos.
- [ ] A spec arquivada num branch e sem merge na `main` sai `stopped` com o
      motivo "arquivada no branch <branch> e ainda sem merge na main". O estado
      não muda.
- [ ] O cabeçalho do script lista a recusa nova.
- [ ] As duas cópias do perfil do tracker (o template do `anvil-docs` e
      `docs/agents/issue-tracker.md`), idênticas, dizem o formato do nome e que o
      `roadmap.sh` o recusa; o `docs/specs/README.md` também, se cita as recusas.
- [ ] O relatório do `anvil-auto` continua dando a causa da parada (PR aberto,
      merge abortado) em vez de só copiar o motivo do script, se a skill hoje
      depender do texto antigo.
- [ ] Prova S1 (prior art `workspace/43-roadmap-state/s1.sh`), num diretório novo
      de `workspace/`: nomes válidos sem recusa; nome com espaço, com maiúscula,
      com `_`, com hífen no começo e com hífen duplo, cada um com a sua `refusal:`
      e saída `2`; spec arquivada em branch local sem merge com o motivo neutro,
      sem "PR". No bash do `PATH` e no `/bin/bash` 3.2, com saídas iguais.
- [ ] `vendor-sync.sh verify` sai `0`.
