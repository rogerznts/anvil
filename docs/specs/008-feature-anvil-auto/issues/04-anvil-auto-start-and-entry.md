# 04: `anvil-auto` recusa a largada indevida e leva o grill até o roteiro commitado

**Blocked by:** 01

**Status:** resolved

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

- [x] A skill está na camada omp com trava de invocação, e o `SKILL.md` do
      `anvil-update` a lista entre as skills da camada.
- [x] Largada, na ordem da spec. Perfil de tracker que não é o `docs/specs` gera
      a recusa com o mesmo texto do `stage.sh` e do `frontier.sh`. Árvore suja
      gera recusa sem escrever nada. Sem `## Comando de verificação` em
      `.claude/rules/anvil.md`, a recusa diz onde e como declarar o comando.
      Branch de spec arquivada, ou branch sem número que não é a `main`, gera
      recusa que aponta a `main`.
- [x] Anexo da pessoa é copiado, ou tem o texto extraído, para
      `docs/discovery/` antes de ser usado.
- [x] Com roteiro existente e entrada não `closed`, o grill parte dele e o edita.
      Um roteiro que substitui o anterior é recusado até cada entrada não
      `closed` ser abandonada de forma explícita no grill, e abandonar é tirar a
      entrada do arquivo.
- [x] Uma recusa do `roadmap.sh` sobre o roteiro escrito volta ao grill, e o
      roteiro inválido nunca é mostrado para confirmação.
- [x] Nada é commitado nem nenhum branch é criado antes do sim. Com o sim, o
      roteiro é commitado na `main`.
- [x] S2, casos de largada e de entrada da spec: `omp -p --mode json` em vários
      turnos sobre fixtures de `workspace/`.
- [x] S3: o `vendor-sync.sh verify` passa com o `anvil-auto` e falha num fixture
      com a trava ausente.

## Comments

- Implementação: a skill está em
  `anvil/.claude/skills/anvil-update/.omp-layer/skills/anvil-auto/SKILL.md`, e o
  `vendor-sync.sh verify` ganhou o check 17, que exige a trava de invocação em toda
  skill da camada omp. Provas em `workspace/46-auto-start/`: `s3.sh` (o payload
  real passa; o `anvil-auto` sem a trava, com a trava em `false` e o `anvil-plan`
  sem a trava falham só no check 17), nos dois bash, e `s2.sh` com o `sonnet`:
  seis casos de largada (T, D, V, O, A, N) e quatro de entrada (E, R, S, I), tudo
  verde.
- Até o ticket 06, o branch de uma spec aberta também é recusado, apontando a
  `main`. A retomada da largada, passo 4 da spec, fica com o 06, que troca essa
  recusa por ela.
- Ao confirmar, o commit na `main` leva, além do roteiro, as cópias de anexo em
  `docs/discovery/` e o glossário e os ADRs que o grill escreveu: a árvore estava
  limpa na largada, e o ticket 05 precisa dela limpa para o `new-spec.sh` e o
  `frontier.sh`.
- Limite do S2: no caso I, de roteiro commitado com ciclo, o modelo levou o ciclo ao
  grill antes de escrever, e nenhum turno deixou no disco um roteiro escrito e
  recusado. O caso prova que o roteiro mostrado para confirmação nunca é recusado,
  mas não exercita o caminho escrever, receber a recusa do `roadmap.sh` e voltar ao
  grill.
- O check 15 do verify não vê caminho com `~/`, como
  `~/.omp/agent/skills/anvil-plan/stage.sh` e
  `~/.claude/skills/anvil-docs/scripts/roadmap.sh`, que o `anvil-auto` cita. A
  lacuna vem da instalação por usuário, da spec 006, vale igual para a `anvil-plan`
  e a `anvil-run`, e ficou como está.
- O manual `anvil-omp` ainda diz que a camada traz as skills `anvil-plan`,
  `anvil-run` e o próprio manual. A correção fica com o ticket 11, junto da seção do
  piloto.
