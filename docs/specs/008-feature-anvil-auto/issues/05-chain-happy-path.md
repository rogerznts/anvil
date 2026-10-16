# 05: O piloto leva cada entrada do roteiro da spec ao merge local, com relatório

**Blocked by:** 04

**Status:** resolved

**What to build:** depois do roteiro confirmado, o piloto executa a corrente sem
pausa, num projeto que fecha sem PR. O laço segue a seção "Corrente" da spec,
sem os desvios de parada. Para cada `next` do `roadmap.sh`, o piloto roda o
`new-spec.sh` com o `Tipo:` e o nome da entrada, commita `Spec: NNN` na `main`,
avança o branch da spec até esse commit, roda `anvil-to-spec` e
`anvil-to-tickets` com as pausas respondidas por ele e o laço de despacho da
`anvil-run`, em série. Depois confere o `PASS` e fecha com `anvil-docs archive` e
merge local na `main`. A cada fronteira de spec, atualiza e commita
`docs/specs/report.md` na `main`. Quando o `next` vira `none`, termina oferecendo
um grill novo com a pauta de "o que ainda espera decisão".

- [x] O `Spec: NNN` aparece na `main` antes de qualquer commit no branch da spec,
      e o branch da spec contém esse commit.
- [x] Cada pausa de `anvil-to-spec` e `anvil-to-tickets` é respondida com a
      opção recomendada pela skill ou, sem recomendação, com a mais conservadora,
      e pergunta e resposta vão para o relatório.
- [x] O laço de despacho é o da `anvil-run`: `frontier.sh`, um
      `anvil-implementer` por ticket, pulados no `--skip`, parada no `halt`. A
      `anvil-run` e os scripts dela não mudam.
- [x] O `PASS` fora do bench exige todos os tickets `resolved`, a última
      `Review:` em `verdict=pass; p1=none` e o bloco de
      `## Comando de verificação` rodado pelo piloto saindo `0`, com a saída
      gravada no relatório.
- [x] Com `PASS`, vem o archive no branch da spec, com commit, e depois o merge
      local na `main`, sob a guarda de merge, sem contorno.
- [x] Um conflito de merge só no `docs/index.md` é resolvido gerando o índice de
      novo, e o merge é concluído.
- [x] O `report.md` tem o conteúdo da seção "Relatório" da spec e é commitado na
      `main` a cada fronteira.
- [x] A cauda de roteamento não dispara dentro de uma execução do `anvil-auto`:
      a linha entra na lista "A cauda não dispara" do bloco de diretivas do
      payload e na rule da camada omp que o espelha. O `anvil-auto` não entra na
      lista de skills com cauda.
- [x] S2: a corrente de duas entradas, a segunda dependente da primeira, com um
      comando de verificação trivial, fecha as duas. A segunda nasce de um branch
      saído da `main` já com a primeira.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: o `anvil-auto` ganhou as seções "Corrente" (abrir a spec, spec e
  tickets, despacho, `PASS`, fechamento, relatório), "O fim" e "Fora do caminho
  feliz". O "Com o sim" segue para a corrente na mesma vez, e não termina mais em
  "O roteiro está pronto". A linha da cauda entrou no `claude_boot.md` e na cópia
  do bloco no `CLAUDE.md` da raiz. A rule `anvil-directives` da camada omp é gerada
  do `claude_boot.md` pelo `reset-install.sh` e não tem arquivo próprio no payload,
  então a mesma edição a cobre.
- Até o ticket 06, qualquer passo fora do caminho feliz (recusa do `roadmap.sh`,
  `new-spec.sh` que falha, `halt` ou ticket sem resolver, `PASS` que não vem,
  projeto que fecha por PR, merge bloqueado pela guarda, conflito fora do
  `docs/index.md`) para a execução ali e diz ao operador onde ela ficou, sem
  archive nem merge. A spec parada, o PR e a continuação pelo independente ficam
  com o 06.
- S2 em `workspace/47-auto-chain/s2.sh`, sobre fixtures em `/tmp`, com
  `MODELO=sonnet`. Pelo jsonl, o omp atendeu por fallback com o
  `openai-codex/gpt-6.1-sol`, como já tinha acontecido no `35-omp-e2e`.
  - Caso C: corrente de duas entradas, `conta-erros` dependendo de `conta-linhas`,
    com o comando de verificação `bash -n lib.sh`. Antes da mudança, o
    `out-red/` mostra o piloto parado no roteiro pronto (15 falhas). Depois dela,
    `out/C-r1/` passou nas 21 conferências. Na rodada sobre a skill final,
    `out/C/`, passaram 20. A única falha foi "o repositório do anvil não mudou",
    causada pela minha edição da regra do bloco custom no meio da rodada; o diff
    do anvil é só esse `SKILL.md`, e a regra não atua sem conflito.
  - Caso K: um hook `post-commit` da fixture faz um commit na `main` logo depois
    do archive do branch, mudando o `Last updated:` e o bloco custom do índice.
    Com isso, o merge para em conflito só no `docs/index.md`, e uma conferência
    refaz o merge numa worktree à parte para provar o conflito. O `out/K/` final
    passou em tudo.
- Duas correções saíram do caso K. Em `out/K-r1/`, a spec escrita pela
  `anvil-to-spec`, que evita caminho de arquivo, perdeu o `conta.sh` do
  `Pronto quando:`. O implementer entregou `count-lines.sh`, e o piloto parou sem
  fechar. Agora a skill manda citar o `Pronto quando:` como está, na spec e num
  critério de ticket. Em `out/K-r2/`, o merge passou, mas a regra "bloco custom da
  `main`" descartou o texto que o implementer tinha escrito no bloco custom do
  branch, e o piloto o recuperou num commit extra na `main`. Agora a skill mantém
  os dois lados do bloco.
- Limite do S2: no `out/K/` final, o branch não escreveu no bloco custom, então a
  regra de juntar os dois lados não rodou. Ela é a correção do que o `K-r2`
  mostrou, mas ainda não foi vista rodando.
- Limite do S2: nenhum caso tem a guarda de merge bloqueando. Ela estava ativa
  (hook em `~/.omp/agent/hooks/pre/`, e a fixture tem `.claude/rules/anvil.md`) e
  liberou os merges, que vieram depois do archive commitado. O caso da guarda
  bloqueando um merge indevido, da seção S2 da spec, fica para o ticket que trata
  as paradas.
