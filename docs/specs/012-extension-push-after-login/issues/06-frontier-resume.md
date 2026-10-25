# 06: O `frontier.sh` aceita `--resume NN`

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** parte da issue #8. Hoje, qualquer caminho fora de commit dá
`halt`, e a corrente para mesmo quando a sujeira é do despacho interrompido do
ticket que acabou de cair. Com `--resume NN`, que o supervisor passa na leitura que
segue um despacho interrompido do NN, a árvore suja não dá `halt`, e o `next` é o
NN, com a linha `resume: NN`, quando o NN ainda pode ser despachado. Sem o flag, ou
com o NN fora desse caso, a árvore suja dá `halt` como hoje.

- [x] Árvore suja, `--resume NN` e o NN sem `resolved`, sem travamento, fora do
      `--skip` e com bloqueio legível e resolvido: sem `halt`, `next` é o NN e sai a
      linha `resume: NN`.
- [x] `--resume NN` com o NN resolvido, travado, pulado ou com bloqueio ilegível:
      `halt`, como hoje, sem linha `resume`.
- [x] Árvore limpa com `--resume NN`: a saída de sempre.
- [x] Sem o flag, a saída é a de hoje em todos os casos.
- [x] O cabeçalho do script diz o flag, o caso em que ele vale e a linha `resume`.
- [x] Prova S1, num diretório novo de `workspace/`, com as chamadas do
      `frontier.sh` em `workspace/33-omp-run/` e `workspace/54-auto-skip/` como prior
      art, no bash do `PATH` e no `/bin/bash` 3.2, com os quatro casos acima.
      Vermelho: o `frontier.sh` de `4271efd`, que dá `halt` com a árvore suja.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Execução: fixed point da rodada 1 `7da86cc83df3bd752699c38b8f4a6f9bfa556c36`. Seam S1 já acordada no ticket e na spec: CLI pública do `frontier.sh`, com repositório real e conferência de `halt`, `next`, `resume` e saída anterior. Plano: medir o vermelho em `4271efd`; implementar o flag reaproveitando a classificação do frontier; medir as quatro famílias de casos no bash do PATH e no `/bin/bash` 3.2; rodar a verificação e revisar em dois eixos.
- Implementação: `--resume` é normalizado como os números do tracker e usa a classificação `frontier` já calculada, sem duplicar regras de bloqueio, travamento ou `--skip`. Só a árvore suja com NN despachável recebe `resume: NN` e o NN como `next`; a ordem de `frontier_files` fica intacta.
- Prova S1 em `workspace/87-frontier-resume/s1.sh`, fora do git como as anteriores: bash do PATH `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57. `bash workspace/87-frontier-resume/s1.sh red` mede `4271efd`, sai 1, com 44 conferências e seis falhas esperadas (as três formas de retomada por shell); a saída confirma `halt` e `next: none` na árvore suja. `bash workspace/87-frontier-resume/s1.sh green` sai 0, com 42 conferências e nenhuma falha. As saídas brutas estão em `out-red/` e `out-green/` no mesmo diretório.
- A matriz cobre retomada de NN posterior ao primeiro do frontier, bloqueador resolvido, ticket sem bloqueador, NN sem zero à esquerda, combinação com `--skip`, resolvido, travado, bloqueio ilegível, bloqueio pendente ou inexistente, NN ausente/zero e ticket pulado. Árvores limpas com flag e chamadas sem flag são comparadas byte a byte com a saída anterior; os casos inválidos na árvore suja preservam essa saída, inclusive `halt`.
- Verificação antes do commit de implementação: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` saiu 0 (`verify: limpo`). Não há pacote compilado, typecheck nem suíte automatizada neste repositório.
