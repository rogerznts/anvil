# 01: A regra `ask-rounds` entra no catálogo, no manifesto, no sync e num ADR

**What to build:** O catálogo de adaptações passa a ter a regra de julgamento `ask-rounds`. A entrada diz por que ela existe, mostra o diff curto do seam ("Work the tree in rounds…" e "Format a round like so") e delimita o escopo. A versão do anvil ganha num merge que mexa nesse seam, e o resto do arquivo fica verbatim. O manifesto declara `ask-rounds` só no `anvil-grilling`. O `vendor-sync.sh` a sinaliza como as outras regras de julgamento. Um ADR novo, o próximo da sequência, registra a exceção nomeada ao `ADR-0001` — as skills vendorizadas seguem o padrão original. O argumento é o mesmo do `verification-profile`: a skill prescreve o formato da rodada literalmente, e uma diretiva que a contradiz perde. Este ticket ainda não muda o comportamento do grill. Ver a spec, "Implementation Decisions › A regra nova no catálogo".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] O catálogo lista `ask-rounds` na tabela, como julgamento aplicado à mão, e tem a seção da regra com o porquê, o diff do seam, o escopo estreito e a precedência do anvil no merge.
- [ ] O manifesto declara `ask-rounds` no `adapt:` do `anvil-grilling`, e em nenhuma outra skill.
- [ ] Num `sync` do `anvil-grilling` em cópia descartável, o `vendor-sync.sh` lista `ask-rounds` em "FALTA APLICAR À MÃO". Numa resolução de conflito, lista em "revise as regras de julgamento". O comentário de cabeçalho do script e o `SKILL.md` do `anvil-sync` citam a regra junto das outras de julgamento.
- [ ] O ADR novo existe com status aceito. Ele nomeia a exceção ao `ADR-0001` sem revogá-lo e explica por que uma rule do projeto não basta. O índice de `docs/` e o `ADR-0001` apontam para ele, se já listam ADRs.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
