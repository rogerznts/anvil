# 11: Ponta a ponta e acompanhamento

**What to build:** O caminho inteiro da 003 roda de novo com a camada desta spec, sem isolação, e passa: a troca de chaves e as regras novas não mudaram a condução. O acompanhamento passa a dizer só o que continua aberto.

**Blocked by:** 02, 03, 04, 05, 06, 07, 09, 10

**Status:** resolved
**Review:** round=1; sha=6705312; scope=full; verdict=pass; p1=none

- [ ] O ponta a ponta da 003 (`workspace/35-omp-e2e/`) roda do degit ao relatório da `anvil-run` com o payload deste branch, e o `check.sh` passa, ajustado só para as chaves novas.
- [x] As linhas A1 a A11 saem de `docs/project/acompanhamento.md`, e fica uma linha para o adaptador de tracker, com origem nesta spec.
- [x] O README e o `overview.md` citam o paralelo sob pedido com isolação onde descrevem a camada omp.
- [x] O `verify` sai limpo.

## Comments

- Ponta a ponta com o payload de `93839fa` (`git archive`, como o degit), saída em `workspace/35-omp-e2e/out-004/`, modelo `openai-codex/gpt-5.6-sol`, `--thinking off`, sem isolação. O caminho foi o da 003: boot (2 vezes), `anvil-plan` do pedido aos tickets (15 vezes, com os desvios de research sobre a RFC 5424 e de questionário para a Marta), a guarda contra o merge prematuro, a `anvil-run` numa sessão nova até o relatório, a guarda com tudo resolvido e sem archive, e a lista de skills do Claude Code antes da spec (payload de `a2fdbe2`, o merge-base com a `main`) e depois. `check.sh`: 40 ok, 1 falha. O critério 1 fica sem a marca por causa dela.
- A falha que fica: o relatório da `anvil-run` recomendou `/skill:anvil-browser-qa` em vez do archive. A spec escrita pelo modelo tem na US 8 "manter a regra separada da interface executável", e `interface` está na lista de palavras de tela desde a 003. É falso positivo, não regressão desta spec, que fixou que a lista não muda. Decisão do operador: registrar e não mudar a lista. Foi para o acompanhamento como A13.
- Ajustes no ponta a ponta além das chaves: o `e2e.sh` perdeu o `hub` do `--tools`, que o omp 18.3.0 recusa. O `plan_check.py` passou a aceitar a volta à origem que continua a etapa sem ler a skill de novo. Nas vezes 3 e 8, o condutor propôs voltar ao `anvil-grill` depois do research e do questionário, o operador disse sim, e o grill seguiu com as perguntas Q4 a Q7 com a skill já no contexto. O check da 003 só aceitava a volta se a leitura seguinte fosse a da origem. Esse ajuste foi decisão do operador. Com ele, a rodada da 003 (`out/`) continua passando nas duas conferências da volta.
- Achado do caminho: a `anvil-to-tickets` escreveu no ticket 02 `Blocked by: 01: Contar severidades de 0 a 3 em arquivo válido`. O `frontier.sh` o deu como `class=unreadable_blockers`, com o texto original, e o deixou fora do frontier: é o "na dúvida, bloqueia" da spec funcionando (`out-004/frontier-antes-da-correcao.out`). O operador corrigiu a linha para `01` num commit do projeto de teste, antes da `anvil-run`. Foi para o acompanhamento como A14.
- A `anvil-run` despachou o 01 e o 02 em série, um item por `task`. Cada implementer rodou o `anvil-implement`, o `anvil-tdd` e o `anvil-code-review`, e os dois tickets fecharam com `round=1/pass`. O relatório abriu com `modo: sem isolação` e trouxe `ready por rodada: 1, 1`. As guardas barraram os dois merges: o primeiro com "0 de 2 tickets resolvidos", o segundo pela falta de archive.
- Acompanhamento: saíram as linhas A1 a A11. A A12 é o adaptador de tracker, a parte do A9 que ficou fora desta spec, e entraram a A13 e a A14 deste ponta a ponta. O README (tabela de comandos do omp) e o `overview.md` (seção Harnesses) citam o paralelo sob pedido com a isolação no modo branch e o ADR-0012.
- `vendor-sync.sh verify`: `verify: limpo` em `/opt/local/bin/bash` e `/bin/bash`, com saídas idênticas.
- Review round=1 · P3 (Spec): o ticket fecha com o critério 1 sem marca, e os Comments atribuem isso só à falha do browser QA. Os ajustes no `plan_check.py` e no `e2e.sh` também saem de "ajustado só para as chaves novas", e nenhuma frase diz que fechar com o critério aberto foi aceito. Quem lê o ticket fechado, ou o archive, não distingue pendência aceita de esquecida. A aceitação é do operador, no fechamento da spec.
- Review round=1 · P2 (Standards): no ramo novo do `plan_check.py`, uma vez de sim que não carregue etapa nem desvio passa como volta à origem, sem conferir que a origem seguiu. Nesta rodada as vezes 4 e 9 trazem as perguntas Q4 e Q7 do grill, mas o check não exige isso. Uma rodada futura em que o modelo pare depois do sim passaria. Correção: exigir no fim da vez m+1 um sinal da origem, como uma pergunta do grill.
- Review round=1 · P3 (Standards): o cabeçalho da seção do acompanhamento cita "as linhas A1 a A11 da spec 003" e "o antigo A9" sem glosa, logo depois de apagá-las.
- Review round=1 · P3 (Standards): as linhas A13 e A14 saem sem classe e rodada, ao contrário das antigas. Quem priorizar o acompanhamento precisa reler o ticket.
