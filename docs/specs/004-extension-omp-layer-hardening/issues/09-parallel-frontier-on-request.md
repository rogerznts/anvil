# 09: Frontier em paralelo sob pedido

**What to build:** O operador com isolação pode pedir ao `/skill:anvil-run` que rode até N tickets do frontier ao mesmo tempo. Sem o pedido, a execução segue em série; sem isolação, o pedido é recusado e a execução segue em série. O relatório mede quantos tickets estavam prontos a cada rodada. É a linha A10 do acompanhamento, e revê em parte a alternativa descartada do ADR-0011.

**Blocked by:** 08

**Status:** resolved

- [x] A `anvil-run` aceita um argumento de paralelo com N de 2 em diante.
- [x] Com isolação, cada leva é uma chamada do `task` com até N itens, um por ticket do frontier, na ordem do script; o script roda de novo depois da leva, e cada ticket passa pela comparação de antes e depois da 003.
- [x] Sem isolação, a primeira linha de andamento recusa o paralelo com o motivo, e a execução segue em série.
- [x] O `frontier.sh` emite `ready:` com quantos tickets estão no frontier, e o relatório final traz a linha `ready` de cada rodada.
- [x] A regra "nunca despachar dois tickets ao mesmo tempo" vale só sem isolação.
- [x] Conferido na prática, num fixture, o que o omp faz quando o cherry-pick de uma leva conflita, registrado no `## Comments`: o ticket que não mudou de estado vai para `skipped`, e árvore suja dá `halt`.
- [x] Cenário no S2: uma spec com dois tickets livres e independentes roda numa leva de dois, com isolação, e os dois chegam resolvidos ao branch da spec.
- [x] Cenário no S2: pedido de paralelo sem isolação é recusado e a execução segue em série.
- [x] O ADR-0012 registra a decisão do paralelo com a isolação do omp e o comportamento conferido no conflito, e revê em parte o ADR-0011.
- [x] O manual `anvil-omp` troca o limite "o frontier é em série" pelo paralelo sob pedido, com isolação.
- [x] O `verify` sai limpo.

## Comments

- Decisões do operador no começo do ticket, registradas na decisão **Paralelo** da spec. (1) Os caminhos da leva vêm de uma chave nova do `frontier.sh`, `frontier_files`, com os caminhos do frontier na ordem da linha `frontier`: a linha `ticket` não traz o arquivo, e só o `next` trazia caminho. A alternativa descartada era um `--parallel N` no script, com várias linhas `next`. (2) Com `isolation: misconfigured`, o pedido de paralelo também é recusado: no modo patch, a leva deixaria o trabalho de vários tickets misturado fora de commit antes do `halt`. As chaves `ready` e `frontier_files` entraram no mesmo commit no script, na `anvil-run` e na tabela da spec; a linha `ready` já estava na tabela.
- A `anvil-run` aceita `--parallel N`. Com N menor que 2 ou que não é número, recusa na primeira linha de andamento e segue em série. O item do `Nunca` que o P3 da rodada 1 do 08 apontou ("Chamar o `task` para outra coisa que não despachar o `next`") passou a incluir a leva.
- Conflito conferido na prática (`/tmp/anvil-004-09/conflict.sh`, saída em `/tmp/anvil-004-09/conflict.out`), com o omp 18.3.0 e o `claude-haiku-4-5`: uma chamada do `task` com dois itens isolados, no modo branch, e o stub de cada filho mudando a mesma linha do `lib.sh`, resolvendo o próprio ticket e commitando. O omp integrou cada filho quando ele terminou, pela ordem de término: o 02 terminou primeiro e entrou ("Merged branch: omp/task/ElaborateFowl"). O cherry-pick do 01 conflitou, e o omp o desfez: o resultado do `task` trouxe "Branch merge failed: omp/task/NewFlamingo … The unmerged branch remains for manual resolution", a árvore ficou limpa, sem `CHERRY_PICK_HEAD` nem stash, e os dois branches `omp/task/*` ficaram no repositório. O `frontier.sh` relido deu o 01 com `status=ready-for-agent`, igual ao de antes, e a comparação da 003 o põe em `skipped`. A árvore suja depois de uma leva só vem de um conflito na devolução do stash que o omp faz antes do cherry-pick (`src/task/worktree.ts`, lido no fonte). Como a `anvil-run` só despacha com a árvore limpa, esse caso não foi reproduzido; se acontecer, a árvore suja dá `halt`, como no 08.
- Fixture `/tmp/anvil-004-01/fx.sh`: as linhas `ready` e `frontier_files` escritas à mão em todo caso G com frontier, inclusive o `f-bloqueios` (seis tickets, na ordem) e o `f-bloqueios-pulados` (frontier vazio porque todos foram pulados, `ready: 0`). Nos casos da 003, a tradução da saída antiga as tira da linha `frontier` antiga. Red antes do script: `fixture: 25 falha(s)`, todas pela falta das duas linhas. Depois: `fixture: 0 falha(s)` (56 casos, `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57, `LC_ALL=pt_BR.UTF-8` e `C` nos casos com os dois locales).
- S2 (`workspace/33-omp-run/s2.sh`): o S2 conduz a `anvil-run` numa sessão headless do omp, com um implementer de mentira, e confere o disco e o relatório. Cenários novos, com `--parallel 2`: L (spec 009, isolação no modo branch, 01 e 02 livres: uma chamada do `task` com os dois itens e `isolated: true`, o `frontier.sh` antes e depois da leva, os dois resolvidos como commits, árvore limpa, `ready: 2` e o `ready` da rodada no relatório) e R (spec 010, sem isolação: o paralelo recusado antes do primeiro despacho, com o motivo, 01 e 02 em série, e `ready por rodada` 2 e 1 no relatório). O stub isolado passou a ler o ticket da primeira mensagem da sessão do filho, em vez de um arquivo único, para servir a dois filhos ao mesmo tempo. Rodada 21 (`claude-haiku-4-5`, `--thinking low`, sem fallback, cenários A, A2, E, B, C, C2, C3, D, T, I, I2, P, P2, L e R; 70 checks): `S2: tudo passou`.
- `vendor-sync.sh verify`: `verify: limpo` em `/opt/local/bin/bash` e `/bin/bash`, com saídas idênticas.
