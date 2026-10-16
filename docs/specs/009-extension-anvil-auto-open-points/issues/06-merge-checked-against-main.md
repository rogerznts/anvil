# 06: O merge confere a verificação quando a `main` andou

**Blocked by:** 02, 04, 05

**Status:** claimed
**Review:** round=1; sha=e1b60ea9e9475ff1598e20fbecce35743949716f; scope=full; verdict=fail; p1=open

**What to build:** quando a `main` tem commits que o branch da spec não tem, como
uma spec irmã que fechou depois do corte, o piloto prepara o merge local sem
commitá-lo e roda a verificação sobre o estado combinado. Saindo `0`, commita o
merge; saindo diferente, aborta, e a spec fica parada, já arquivada no branch, com
a pergunta de qual spec cede para o operador. Assim uma spec nova não quebra o que
já foi entregue sem nada que segure o fechamento.

- [x] No merge local, o piloto confere se a `main` tem commits que o branch não
      tem. Sem, o merge é o de hoje.
- [x] Com, o merge sai com `--no-ff --no-commit`. Conflito só no `docs/index.md`
      se resolve como hoje, antes da conferência; outro conflito aborta, como hoje.
- [x] Com o merge preparado, fora do bench, o piloto roda o comando de verificação
      pelo script do ticket 02; no bench, o `--reverify` do `GATE.md`, com o ledger
      desta spec, agora em `docs/specs/archive/`, e os das specs `closed`.
- [x] Saindo `0`, o piloto commita o merge com a mensagem padrão.
- [x] Saindo diferente de `0`, o piloto devolve os ledgers que o checker
      reescreveu, roda `git merge --abort`, e a spec fica parada, já arquivada no
      branch. É parada por decisão: sem pesquisa e sem rodada extra. O relatório
      leva a saída, e "o que ainda espera decisão" leva a pergunta de qual spec
      cede.
- [x] O merge passa pela guarda como o de hoje, sem contorno.
- [x] O caminho do PR não muda.
- [x] O piloto não retoma nem refaz sozinho o merge de uma spec já arquivada no
      branch e parada: chamado no branch dela, ele recusa com esse motivo. Confira o
      que a retomada faz hoje e ajuste se for preciso.
- [x] O manual `anvil-omp`, se descreve o merge local do piloto, cita a
      conferência.
- [x] Prova S2 (prior art `workspace/48-auto-stops/`), num diretório novo de
      `workspace/`, fora do bench: duas entradas independentes, a segunda fechando
      na `main` depois do corte da primeira. Verde: o merge sai commitado. Vermelho,
      com a primeira quebrando o que a segunda entregou: o merge é abortado, a
      `main` fica como estava, a spec fica arquivada no branch e parada, sem
      pesquisa. O S2 registra o modelo que de fato respondeu.
- [x] No bench, a prova é um caso de `workspace/51-auto-bench/` com o `--reverify`
      da irmã, se o custo da stack couber; senão, o limite fica declarado aqui.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- O "Merge local" do `anvil-auto` confere, na `main`, `git rev-list --count <branch>..main`. Com `0`, o merge é o de hoje, `--no-ff --no-edit`. Com mais, prepara o merge com `--no-ff --no-commit` e segue a nova "Conferir o merge": fora do bench, o `verification.sh` em `check` e `run`; no bench, o comando de "A evidência" do `GATE.md` sem o `docs/specs/<pasta>/gates.md`, porque com o merge preparado o `roadmap.sh` já dá esta spec como `closed` e o `$fechados` traz o ledger arquivado dela junto dos das outras; antes de concluir ou abortar, `git diff --name-only` mostra o que o checker reescreveu, e o piloto devolve com `git checkout -- <arquivos>`. Saindo `0`, `git commit --no-edit`; senão, `git merge --abort`, e a spec para por decisão, sem pesquisa nem rodada extra, com a saída no relatório e a pergunta de qual spec cede. O conflito só no `docs/index.md` se resolve como hoje e, no merge preparado, segue para a conferência sem commit. A "Pesquisa antes de travar", a "Parada" e o "Nunca" ganharam o merge abortado pela conferência.
- Leitura da spec no bench: "saindo `0`" é a saída que vale o `PASS` pela regra de "Sob o piloto automático" do `GATE.md`, e não o `exit:` literal. Com o `exit:` literal, um gate manual aberto de uma spec fechada, que dá `exit: 1` e vale o `PASS` (ticket 05), abortaria todo merge com a `main` adiantada. O `GATE.md` passou a dizer que o piloto roda o comando também sobre o merge preparado.
- A guarda, medida à mão sobre a fixture: `git merge --no-ff --no-commit` de um branch sem archive sai `2`; arquivado, sai `0`; `git merge --abort` com o merge em andamento sai `0`. O `git commit --no-edit` não passa pelo filtro dela.
- Retomada: chamado no branch de uma spec arquivada, o `stage.sh` já dá `next: none`, e a largada já recusava (vermelho, `out-red/F/2.fatos`), mas sem dizer por quê. A recusa agora confere `git merge-base --is-ancestor HEAD main` e, sem o merge, diz que a spec está arquivada no branch e sem merge na `main`, que o piloto não a retoma nem refaz o merge dela, e que qual spec cede é decisão do operador. Da `main`, o `roadmap.sh` a dá `stopped` e ela nunca sai no `next`.
- O manual `anvil-omp` cita a conferência no item do fechamento.
- Prova S2, a sessão headless do omp com `/skill:anvil-auto`: `workspace/57-merge-check/s2.sh`, fora do bench, retomada no branch da spec 001 de um projeto sem remoto, com `omp -p --mode json --model claude-sonnet-4-5 --thinking off`. Duas entradas independentes; a 002 nasceu, foi arquivada e mesclada na `main` depois do corte do branch da 001. O `verifica.sh` da fixture grava cada execução em `.git/verifica.log`, com o branch e se havia merge em andamento. O modelo que respondeu é lido do jsonl da sessão principal.
  - Caso V, verde: vermelho, com o texto de antes (`out-red/V`, `s2-red-V.out`), o piloto mesclou com `--no-ff --no-edit` sem rodar a verificação na `main`; 3 falhas. Verde (`out/V`, `s2-V.out`): `rev-list --count`, merge `--no-commit`, `verification.sh run` com o merge em andamento saindo `0`, `git commit --no-edit`, o produto da `main` cumpre os dois `Pronto quando:`, as duas entradas `closed`; `S2: tudo passou`. Respondeu `anthropic/claude-sonnet-4-5`. Uma primeira tentativa verde caiu no meio por `overloaded_error` do provedor e foi refeita.
  - Caso F, vermelho: a 001 tira de `lib.sh` a `ultima_linha`, que o `ultima.sh` da 002 usa, sem conflito de texto. Vermelho (`out-red/F`, `s2-red-F.out`): o merge foi commitado e a `main` ficou com o `ultima.sh` quebrado; 10 falhas. Verde (`out/F`, `s2-F.out`): a verificação sobre o merge sai `1`, o piloto roda `git merge --abort`, a `main` só ganha o relatório, a 001 fica `stopped` com "arquivada no branch … e ainda sem merge na main", sem pesquisa e sem `task`, o relatório leva a saída e a pergunta de qual spec cede, com as duas. Na segunda vez, chamado de novo no branch da 001, o piloto recusa sem merge nem escrita, com o motivo; `S2: tudo passou`. Respondeu `anthropic/claude-sonnet-4-5`. A conferência da segunda vez casava `git merge-base` como merge e foi corrigida no script, refeita com `--so-checar` sobre a mesma saída.
- Prova no bench: `workspace/57-merge-check/s2-bench.sh`, com a fixture e o container `node:22-alpine` do `workspace/56-manual-gate-rule/`, que deriva do `workspace/51-auto-bench/`; o custo da stack coube. A 001 troca o Projetor da lista por um Teclado, e o C2 dela passa no branch; a 002, fechada na `main` depois do corte, tem o C1, que pede o Projetor. Vermelho (`out-bench-red`, `s2-bench-red.out`): o `--reverify` só rodou no branch, e o merge foi commitado; 8 falhas. Verde (`out-bench`, `s2-bench.out`): o `--reverify` sobre o merge preparado sai `1` com só `gates:C1` abaixo de `UNMET:`, os ledgers são devolvidos, o merge é abortado, a `main` só ganha o relatório, a 001 fica `stopped`, sem pesquisa, e a pergunta cita as duas; `S2: tudo passou`. Respondeu `anthropic/claude-sonnet-4-5`. A primeira tentativa verde também caiu por `overloaded_error` e foi refeita. O `anvil-bench` e o `anvil-stack-payload` foram ligados por symlink só durante as vezes do bench.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0.
- Review round=1 · P1 (Standards): o `GATE.md`, em "Sob o piloto automático", passou a dizer que o piloto roda o comando também sobre o merge preparado e "lê a saída por esta regra", e essa regra manda o gate com `CHECK:` caído para o `FAIL` no teto, com pesquisa em fontes primárias e rodada extra — o contrário da parada por decisão, sem pesquisa, que o `anvil-auto` dá à conferência do merge; um piloto que siga o `GATE.md` pesquisa e abre rodada sobre uma spec já arquivada.
- Review round=1 · P3 (Standards): possível Speculative Generality — o "no outro, conclua o merge com `git commit --no-edit`" do conflito no `docs/index.md` cobre o merge com `rev-list --count` em `0`, em que a `main` é ancestral do branch e o `--no-ff` não conflita; o leitor gasta atenção num ramo que não roda, sem decisão que mude.
- Review round=1 · P3 (Standards): possível Duplicated Code — o "devolva esses ledgers com `git checkout -- <arquivos>`" do `anvil-auto` repete a última linha do comando de "A evidência", que já devolve o `$fechados`; se a forma de devolver mudar no `GATE.md`, a cópia fica para trás.
- Review round=1 · P3 (Spec): a recusa da retomada com `git merge-base --is-ancestor HEAD main` vale para toda spec arquivada no branch e sem merge, não só a parada pela conferência — no branch de uma spec com PR aberto ou merge bloqueado pela guarda, o motivo fala de "qual spec cede" sem spec irmã; a recusa segue certa.
- Review round=1 · P3 (Spec): o `GATE.md` diz que o comando de "A evidência" roda de novo sobre o merge preparado, sem dizer que nessa vez ele sai sem o `docs/specs/<pasta>/gates.md`, que já foi para o archive — quem seguir só o `GATE.md` passa um caminho que não existe; o piloto lê a forma certa no `anvil-auto`.
- Review round=1 · P3 (Spec): o vermelho de F (`s2-red-F.out`) foi medido antes da correção da conferência da segunda vez no `s2.sh` — o par vermelho/verde do F usou checkers diferentes nessa conferência; a conclusão não muda.
- Review round=1 · P3 (Spec): a prova do bench usa a fixture do `workspace/56-manual-gate-rule/`, derivada do `workspace/51-auto-bench/` — o "caso de `workspace/51-auto-bench/`" do ticket é lido por derivação.
