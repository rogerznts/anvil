# 01: Contrato de saída em inglês nos condutores

**What to build:** O `frontier.sh` passa a emitir as chaves de saída da tabela da spec, em inglês e estáveis, com os motivos ao operador ainda em pt-BR. O `frontier.sh` e o `stage.sh` ganham identificadores internos em inglês. A `anvil-run` lê as chaves novas no mesmo commit. Para o operador nada muda: é o prefactor que deixa os tickets 02 a 05 e 08 mexerem no script e na skill sem conflito de nome. Linhas A8 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] O `frontier.sh` emite `refusal`, `tree`, `screen`, `story`, a linha `ticket` com `status`, `reviews`, `last`, `blocked_by` e `class`, `skipped`, `locked`, `open_p1`, `depend_on_locked`, `all_resolved`, `halt` e `next`, e as classes `resolved`, `locked`, `waiting:NN`, `skipped` e `frontier`. Nenhuma chave antiga continua.
- [ ] Os motivos depois das chaves seguem em pt-BR.
- [ ] Identificadores internos do `frontier.sh` e do `stage.sh` em inglês; as chaves de saída do `stage.sh` não mudam.
- [ ] A `anvil-run` cita só chaves que o script emite, e a troca sai num commit só.
- [ ] Fixture em `/tmp` com os estados da 003 (livre, bloqueado, travado com P1, dependente, pulado, árvore suja, tudo resolvido) dá, nos dois bash, a mesma saída de antes a menos dos nomes das chaves.
- [ ] O S1 e o S2 da `anvil-run` passam com as chaves novas, sem mudança de comportamento do supervisor.
- [ ] O `verify` sai limpo.
