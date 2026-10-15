# 04: `anvil-auto` recusa a largada indevida e leva o grill até o roteiro commitado

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** o operador chama `/skill:anvil-auto` no omp com um pedido. O
piloto é uma skill nova da camada omp, ao lado de `anvil-plan` e `anvil-run`, com
`disable-model-invocation: true`, e é instalado com o resto da camada, sem passo
extra. Antes de escrever qualquer coisa, ele aplica a largada da spec. Na `main`,
conduz o `anvil-grill` sobre o plano inteiro: specs, ordem, escopo, o que fica de
fora e critério de pronto. No fim, escreve `docs/specs/roadmap.md`, valida o
arquivo pelo `roadmap.sh`, mostra o roteiro e pede a confirmação do entendimento
sobre o texto escrito. Com o sim, commita o roteiro na `main`. A corrente vem no
ticket 05, e até lá o piloto termina dizendo que o roteiro está pronto.

A entrada pelo bench fica com o ticket 10. Aqui a entrada é só o `anvil-grill`.

- [ ] A skill está na camada omp com trava de invocação, e o `SKILL.md` do
      `anvil-update` a lista entre as skills da camada.
- [ ] Largada, na ordem da spec. Perfil de tracker que não é o `docs/specs` gera
      a recusa com o mesmo texto do `stage.sh` e do `frontier.sh`. Árvore suja
      gera recusa sem escrever nada. Sem `## Comando de verificação` em
      `.claude/rules/anvil.md`, a recusa diz onde e como declarar o comando.
      Branch de spec arquivada, ou branch sem número que não é a `main`, gera
      recusa que aponta a `main`.
- [ ] Anexo da pessoa é copiado, ou tem o texto extraído, para
      `docs/discovery/` antes de ser usado.
- [ ] Com roteiro existente e entrada não `closed`, o grill parte dele e o edita.
      Um roteiro que substitui o anterior é recusado até cada entrada não
      `closed` ser abandonada de forma explícita no grill, e abandonar é tirar a
      entrada do arquivo.
- [ ] Uma recusa do `roadmap.sh` sobre o roteiro escrito volta ao grill, e o
      roteiro inválido nunca é mostrado para confirmação.
- [ ] Nada é commitado nem nenhum branch é criado antes do sim. Com o sim, o
      roteiro é commitado na `main`.
- [ ] S2, casos de largada e de entrada da spec: `omp -p --mode json` em vários
      turnos sobre fixtures de `workspace/`.
- [ ] S3: o `vendor-sync.sh verify` passa com o `anvil-auto` e falha num fixture
      com a trava ausente.
