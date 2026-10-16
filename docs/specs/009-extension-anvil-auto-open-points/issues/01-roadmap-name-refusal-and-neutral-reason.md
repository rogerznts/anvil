# 01: O `roadmap.sh` recusa nome fora de kebab-case e não fala de PR sem saber

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=cb53c81; scope=full; verdict=pass; p1=none

**What to build:** quem escreve um roteiro com uma entrada chamada, por exemplo,
`Cadastro de clientes` recebe do `roadmap.sh` uma recusa com o nome e o formato
esperado, antes de o piloto ou o bench criarem uma spec com ele. E a spec
arquivada no branch e ainda sem merge passa a sair `stopped` com um motivo que
não fala de PR, para que o índice e o relatório de um projeto sem PR não mintam.
Decisão do operador sobre o ticket 01 da spec 008: o nome fora de kebab-case é
recusado.

- [x] Nome de entrada que não é kebab-case (minúsculas ASCII e dígitos em grupos
      separados por um hífen, sem hífen no começo nem no fim) gera uma linha
      `refusal:` com o nome entre aspas simples e o formato esperado, na mesma
      lista das recusas de hoje: uma linha por nome, saída `2`, sem frontier.
- [x] `a`, `cadastro-de-clientes` e `fase-2-relatorios` seguem válidos.
- [x] A spec arquivada num branch e sem merge na `main` sai `stopped` com o
      motivo "arquivada no branch <branch> e ainda sem merge na main". O estado
      não muda.
- [x] O cabeçalho do script lista a recusa nova.
- [x] As duas cópias do perfil do tracker (o template do `anvil-docs` e
      `docs/agents/issue-tracker.md`), idênticas, dizem o formato do nome e que o
      `roadmap.sh` o recusa; o `docs/specs/README.md` também, se cita as recusas.
- [x] O relatório do `anvil-auto` continua dando a causa da parada (PR aberto,
      merge abortado) em vez de só copiar o motivo do script, se a skill hoje
      depender do texto antigo.
- [x] Prova S1 (prior art `workspace/43-roadmap-state/s1.sh`), num diretório novo
      de `workspace/`: nomes válidos sem recusa; nome com espaço, com maiúscula,
      com `_`, com hífen no começo e com hífen duplo, cada um com a sua `refusal:`
      e saída `2`; spec arquivada em branch local sem merge com o motivo neutro,
      sem "PR". No bash do `PATH` e no `/bin/bash` 3.2, com saídas iguais.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · a prova S1 é `workspace/52-roadmap-name/s1.sh`, que passa no
  bash 5.2 do `PATH` e no `/bin/bash` 3.2, com saídas iguais. Além dos casos
  pedidos, cobre hífen no fim, nome com acento, vários nomes inválidos num roteiro
  só e nome inválido repetido, que dá uma recusa de formato e a de nome repetido.
- Implementação · o caso 7 de `workspace/43-roadmap-state/s1.sh` procura "PR" no
  motivo e passa a falhar, por decisão desta spec; o caso equivalente é o 4 do
  S1 novo. O `workspace/` está fora do git, e o S1 antigo não foi editado.
- Implementação · o `docs/specs/README.md` não cita as recusas do roteiro e não
  mudou. No `anvil-auto`, a seção de cada entrada do relatório já dá a causa no
  `Estado:`; a "Onde a corrente parou" copiava o motivo do script, que levava o
  "espera o merge do PR", e passa a pedir também a causa do `Estado:` da entrada
  parada nesta execução.
- Review round=1 · P2 (Spec): a "Onde a corrente parou" do `anvil-auto` só pede a causa da entrada que parou nesta execução; uma entrada com PR aberto de uma execução anterior sai só com o motivo neutro, e o operador de projeto que fecha por PR não lê ali que o merge é dele (US6), embora a linha `PR:` dos tickets do branch dê a causa.
- Review round=1 · P3 (Standards): a definição de kebab-case está escrita na constante `KEBAB` do `roadmap.sh` e nas duas cópias do perfil do tracker; se a regra mudar num lugar só, a mensagem de recusa passa a descrever um formato diferente do documentado.
- Review round=1 · P3 (Standards): a constante `KEBAB` é usada uma vez só, na mensagem de recusa; é um nome a mais sem abstração, sem efeito no comportamento.
