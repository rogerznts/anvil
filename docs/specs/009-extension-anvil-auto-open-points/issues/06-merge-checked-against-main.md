# 06: O merge confere a verificação quando a `main` andou

**Blocked by:** 02, 04, 05

**Status:** ready-for-agent

**What to build:** quando a `main` tem commits que o branch da spec não tem, como
uma spec irmã que fechou depois do corte, o piloto prepara o merge local sem
commitá-lo e roda a verificação sobre o estado combinado. Saindo `0`, commita o
merge; saindo diferente, aborta, e a spec fica parada, já arquivada no branch, com
a pergunta de qual spec cede para o operador. Assim uma spec nova não quebra o que
já foi entregue sem nada que segure o fechamento.

- [ ] No merge local, o piloto confere se a `main` tem commits que o branch não
      tem. Sem, o merge é o de hoje.
- [ ] Com, o merge sai com `--no-ff --no-commit`. Conflito só no `docs/index.md`
      se resolve como hoje, antes da conferência; outro conflito aborta, como hoje.
- [ ] Com o merge preparado, fora do bench, o piloto roda o comando de verificação
      pelo script do ticket 02; no bench, o `--reverify` do `GATE.md`, com o ledger
      desta spec, agora em `docs/specs/archive/`, e os das specs `closed`.
- [ ] Saindo `0`, o piloto commita o merge com a mensagem padrão.
- [ ] Saindo diferente de `0`, o piloto devolve os ledgers que o checker
      reescreveu, roda `git merge --abort`, e a spec fica parada, já arquivada no
      branch. É parada por decisão: sem pesquisa e sem rodada extra. O relatório
      leva a saída, e "o que ainda espera decisão" leva a pergunta de qual spec
      cede.
- [ ] O merge passa pela guarda como o de hoje, sem contorno.
- [ ] O caminho do PR não muda.
- [ ] O piloto não retoma nem refaz sozinho o merge de uma spec já arquivada no
      branch e parada: chamado no branch dela, ele recusa com esse motivo. Confira o
      que a retomada faz hoje e ajuste se for preciso.
- [ ] O manual `anvil-omp`, se descreve o merge local do piloto, cita a
      conferência.
- [ ] Prova S2 (prior art `workspace/48-auto-stops/`), num diretório novo de
      `workspace/`, fora do bench: duas entradas independentes, a segunda fechando
      na `main` depois do corte da primeira. Verde: o merge sai commitado. Vermelho,
      com a primeira quebrando o que a segunda entregou: o merge é abortado, a
      `main` fica como estava, a spec fica arquivada no branch e parada, sem
      pesquisa. O S2 registra o modelo que de fato respondeu.
- [ ] No bench, a prova é um caso de `workspace/51-auto-bench/` com o `--reverify`
      da irmã, se o custo da stack couber; senão, o limite fica declarado aqui.
- [ ] `vendor-sync.sh verify` sai `0`.
