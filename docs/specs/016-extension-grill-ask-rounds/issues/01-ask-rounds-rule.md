# 01: A regra `ask-rounds` entra no catálogo, no manifesto, no sync e num ADR

**What to build:** O catálogo de adaptações passa a ter a regra de julgamento `ask-rounds`. A entrada diz por que ela existe, mostra o diff curto do seam ("Work the tree in rounds…" e "Format a round like so") e delimita o escopo. A versão do anvil ganha num merge que mexa nesse seam, e o resto do arquivo fica verbatim. O manifesto declara `ask-rounds` só no `anvil-grilling`. O `vendor-sync.sh` a sinaliza como as outras regras de julgamento. Um ADR novo, o próximo da sequência, registra a exceção nomeada ao `ADR-0001` — as skills vendorizadas seguem o padrão original. O argumento é o mesmo do `verification-profile`: a skill prescreve o formato da rodada literalmente, e uma diretiva que a contradiz perde. Este ticket ainda não muda o comportamento do grill. Ver a spec, "Implementation Decisions › A regra nova no catálogo".

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] O catálogo lista `ask-rounds` na tabela, como julgamento aplicado à mão, e tem a seção da regra com o porquê, o diff do seam, o escopo estreito e a precedência do anvil no merge.
- [x] O manifesto declara `ask-rounds` no `adapt:` do `anvil-grilling`, e em nenhuma outra skill.
- [x] Num `sync` do `anvil-grilling` em cópia descartável, o `vendor-sync.sh` lista `ask-rounds` em "FALTA APLICAR À MÃO". Numa resolução de conflito, lista em "revise as regras de julgamento". O comentário de cabeçalho do script e o `SKILL.md` do `anvil-sync` citam a regra junto das outras de julgamento.
- [x] O ADR novo existe com status aceito. Ele nomeia a exceção ao `ADR-0001` sem revogá-lo e explica por que uma rule do projeto não basta. O índice de `docs/` e o `ADR-0001` apontam para ele, se já listam ADRs.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

**Review:** round=1; sha=5d3d92e; scope=full; verdict=pass; p1=none

## Comments

- Review round=1 · P2 (Spec): "numa resolução de conflito" foi lido como o caminho `update` com merge, onde as outras quatro regras já saem em "revise as regras de julgamento". Um `update` com conflito só lista os marcadores, e o `cmd_resolved` não sinaliza regra nenhuma. Quem fecha um conflito no `anvil-grilling` pelo `resolved` não é lembrado do `ask-rounds`, como já acontece hoje com o `docs-remap` e as demais.
- Review round=1 · P2 (Spec): o diff curto do seam no catálogo omite detalhes da spec: pergunta com pré-requisito aberto vai para o bloco seguinte, título de até 12 caracteres, "Other" nativo sem duplicar, fallback quando a chamada falha. Quem reaplicar a regra num merge só pelo catálogo pode reaplicar uma versão mais fraca. O ticket 02 e a spec são a fonte completa.
- Review round=1 · P2 (Standards): a seção "Specs ativas" do `docs/index.md` diz "Nenhuma" com a spec 016 aberta. Quem entra pelo índice não acha o trabalho em curso. Isso é anterior a este ticket e se resolve com o verbo `index` do `anvil-docs`.
- Review round=1 · P3 (Standards): a lista das regras de julgamento se repete em oito lugares: tabela do catálogo, cabeçalho e dois `case` do script, `SKILL.md`, README, `project.md` e cabeçalho do manifesto. O `verify` não confere nome de regra contra o catálogo, então a próxima regra esquecida num deles passa sem sinal.
