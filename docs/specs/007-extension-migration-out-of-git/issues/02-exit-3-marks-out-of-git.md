# 02: A saída 3 marca o que tem conteúdo fora do git

**What to build:** Num projeto antigo sem lock, a migração para com a saída 3 e pergunta quais skills e agentes não vieram do anvil. Nessa lista, a skill ou o agente que tem conteúdo fora do git vem marcado, e o usuário decide o `--keep-skills` e o `--keep-agents` sabendo o que não vai recuperar pelo git. Uma rodada de resposta basta: depois dela, nenhuma segunda parada por causa do ignore, e o que está fora do git do que sai aparece no grupo "sai junto, fora do git, sem volta pelo git".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Sem lock e sem resposta, a lista de skills e agentes da saída 3 marca os que têm conteúdo fora do git e não marca os outros. Nada é alterado, como hoje.
- [ ] A resposta continua em `--keep-skills` e `--keep-agents`, juntos.
- [ ] Com a resposta, a migração chega ao dry-run e à execução sem outra parada, e o conteúdo fora do git do que sai aparece no grupo fora do git.
- [ ] Cenário `workspace/41-legacy-migration/s1.sh`, falhando antes da correção: sem lock, a saída 3 marca a skill que tem conteúdo fora do git, e depois uma rodada de resposta basta para migrar.
- [ ] O `vendor-sync.sh verify` sai limpo.
