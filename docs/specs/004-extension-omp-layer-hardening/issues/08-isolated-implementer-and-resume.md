# 08: Implementer isolado e retomada

**What to build:** Com a isolação de tarefas do omp ligada, o `/skill:anvil-run` despacha cada implementer num workspace isolado, e o trabalho volta ao branch da spec como commits, pelo modo branch do omp. A sobra de um implementer que caiu não chega ao branch da spec, e rodar de novo retoma. Sem isolação, tudo segue como na 003, e a parada passa a dizer como sair dela. É a linha A2 do acompanhamento.

**Blocked by:** 01

**Status:** claimed

- [x] O supervisor olha se o `task` oferece o campo `isolated`. Com ele, todo despacho sai com `isolated: true`; sem ele, o laço é o da 003.
- [ ] O relatório abre dizendo se a execução rodou com ou sem isolação.
- [x] A linha `halt` diz como sair da parada, com `git stash` ou com um commit do operador.
- [x] O manual `anvil-omp` ganha a seção de isolação: o que ela muda na retomada, que o paralelo depende dela, que precisa do modo branch, e como ligá-la na configuração do omp.
- [x] Cenário no S2 com a isolação ligada: os tickets resolvidos chegam ao branch da spec como commits, e a árvore da spec fica limpa.
- [x] Cenário no S2 com a isolação ligada e um implementer que termina sem mudar o estado: a árvore da spec fica limpa, o ticket vai para `skipped`, e uma segunda execução o despacha de novo.
- [x] Cenário no S2 com a isolação em modo patch, se o omp permitir configurá-lo: a árvore suja resultante dá `halt` e o relatório aponta a configuração.
- [ ] O S2 sem isolação passa como antes.
- [x] O `verify` sai limpo.

## Comments

- Fonte dos fatos do omp (instalado: 18.3.0, a spec leu 18.2.11): `omp://tools/task.md`, `omp://settings.md` e o fonte em `~/.bun/install/global/node_modules/@oh-my-pi/pi-coding-agent/src/task/` (`isolation-runner.ts`, `worktree.ts`, `structured-subagent.ts`, `index.ts`), mais o schema em `dist/types/config/settings-schema.d.ts`. Chaves: `task.isolation.enabled` (padrão `false`), `task.isolation.merge` (`patch` ou `branch`, padrão `patch`), `task.isolation.apply` (padrão `true`). O campo `isolated` só entra no schema do `task` com `task.isolation.enabled` e fora do modo plan (conferido: pedindo ao modelo o schema do item, `isolated` aparece com o `.omp/config.yml` ligando a isolação e some sem ele).
- Execução real (protótipo `/tmp/anvil-004-08/proto.sh`, haiku): no modo branch, os commits do implementer chegam ao branch da spec e a árvore fica limpa; o hook do filho roda com o cwd em `~/.omp/wt/<id>/m`, no mesmo branch. O cherry-pick gera SHAs novos quando passa um segundo entre o commit e a integração (commit `0628f8d` no workspace virou `0ef27b1` no branch). Um implementer que devolve `yield` de erro sai `cancelled`: nada chega ao branch da spec, e a sobra fica num branch `omp/task/<id>`. O modo patch aplica o trabalho sem commit (`M` no ticket, HEAD parado). Os branches `omp/task/*` ficam no repositório mesmo depois de "Merged branch".
- Achado para o operador: o `sha` que o implementer grava na linha `Review:` é o do workspace isolado, e não chega ao branch da spec, que recebe o commit com outro SHA. A rodada 2 usaria de fixed point um commit fora da história do branch (hoje alcançável pelo `omp/task/<id>` que fica; o merge-base cai antes do ticket, e o diff da rodada 2 cobre o ticket inteiro). A spec não trata disso.
- Achado para o operador: a detecção do modo pelo schema do `task` depende de o modelo raciocinar sobre a própria definição do tool. Com `--thinking off`, o haiku e o `claude-sonnet-4-6` erram nos dois sentidos (listam `isolated` e escrevem "modo: sem isolação"; ou põem um `isolated` que não existe e escrevem "com isolação"). Com `--thinking low`, o haiku acertou 5 de 5 com a isolação ligada e 2 de 2 sem ela em sondas curtas, mas no S2 inteiro ainda errou o modo no A2 (rodada 7). Alternativa determinística para decidir: `omp config get task.isolation.enabled`, que é o que liga o campo, fora do modo plan. Mudar o mecanismo é decisão de spec.
- `frontier.sh`: a linha `halt` ganhou a saída, "A saída é do operador: guardá-los com git stash -u, ou fazer um commit dele, e rodar a skill de novo." (`-u` porque o `git status --porcelain` conta arquivo não rastreado). O primeiro texto ("O operador decide o que fazer com eles: guardá-los com git stash -u…") fez o haiku rodar o `git stash -u` sozinho no cenário E do S2; a `anvil-run` agora proíbe guardar, commitar ou descartar o que está fora de commit.
- Fixture `/tmp/anvil-004-01/fx.sh`: o `f-arvore-suja` virou caso G com a saída escrita à mão, em `LC_ALL=pt_BR.UTF-8` e `C`, em `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57. `fixture: 0 falha(s)` (49 casos).
- S2 (`workspace/33-omp-run/s2.sh`): cenários novos I (007, modo branch: 01 e 02 como commits, 03 que cai com sobra e `yield` de erro), I2 (despacha o 03 de novo) e P (008, modo patch: halt e ponteiro para `task.isolation.merge: branch`), ligados por `.omp/config.yml` commitado no branch da spec. O stub isolado roda no hook do `yield` do filho. Rodadas, todas com `claude-haiku-4-5` sem fallback: rodada 6 (isolação com `--thinking low`, resto `off`): 1 falha, o A abriu dizendo "com isolação" sem isolação; todos os checks de I, I2 e P passaram, e os da 003 também. Rodada 7 (tudo com `--thinking low`): 2 falhas, o A2 abriu dizendo "com isolação", e o P não apontou a configuração. Depois da rodada 7, o parágrafo do `halt` da `anvil-run` foi simplificado (com isolação, todo `halt` depois de um despacho é modo patch) e ainda não rodou no S2.
- Aberto: o S2 ainda não passou inteiro. O ticket fica `claimed` até uma rodada inteira passar e a review rodar.
- `vendor-sync.sh verify`: `verify: limpo` antes do commit.
