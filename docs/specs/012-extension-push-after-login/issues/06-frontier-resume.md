# 06: O `frontier.sh` aceita `--resume NN`

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** parte da issue #8. Hoje, qualquer caminho fora de commit dá
`halt`, e a corrente para mesmo quando a sujeira é do despacho interrompido do
ticket que acabou de cair. Com `--resume NN`, que o supervisor passa na leitura que
segue um despacho interrompido do NN, a árvore suja não dá `halt`, e o `next` é o
NN, com a linha `resume: NN`, quando o NN ainda pode ser despachado. Sem o flag, ou
com o NN fora desse caso, a árvore suja dá `halt` como hoje.

- [ ] Árvore suja, `--resume NN` e o NN sem `resolved`, sem travamento, fora do
      `--skip` e com bloqueio legível e resolvido: sem `halt`, `next` é o NN e sai a
      linha `resume: NN`.
- [ ] `--resume NN` com o NN resolvido, travado, pulado ou com bloqueio ilegível:
      `halt`, como hoje, sem linha `resume`.
- [ ] Árvore limpa com `--resume NN`: a saída de sempre.
- [ ] Sem o flag, a saída é a de hoje em todos os casos.
- [ ] O cabeçalho do script diz o flag, o caso em que ele vale e a linha `resume`.
- [ ] Prova S1, num diretório novo de `workspace/`, com as chamadas do
      `frontier.sh` em `workspace/33-omp-run/` e `workspace/54-auto-skip/` como prior
      art, no bash do `PATH` e no `/bin/bash` 3.2, com os quatro casos acima.
      Vermelho: o `frontier.sh` de `4271efd`, que dá `halt` com a árvore suja.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
