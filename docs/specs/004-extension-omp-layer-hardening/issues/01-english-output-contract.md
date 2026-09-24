# 01: Contrato de saída em inglês nos condutores

**What to build:** O `frontier.sh` passa a emitir as chaves de saída da tabela da spec, em inglês e estáveis, com os motivos ao operador ainda em pt-BR. O `frontier.sh` e o `stage.sh` ganham identificadores internos em inglês. A `anvil-run` lê as chaves novas no mesmo commit. Para o operador nada muda: é o prefactor que deixa os tickets 02 a 05 e 08 mexerem no script e na skill sem conflito de nome. Linhas A8 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] O `frontier.sh` emite `refusal`, `tree`, `screen`, `story`, a linha `ticket` com `status`, `reviews`, `last`, `blocked_by` e `class`, `skipped`, `locked`, `open_p1`, `depend_on_locked`, `all_resolved`, `halt` e `next`, e as classes `resolved`, `locked`, `waiting:NN`, `skipped` e `frontier`. Nenhuma chave antiga continua.
- [x] Os motivos depois das chaves seguem em pt-BR.
- [x] Identificadores internos do `frontier.sh` e do `stage.sh` em inglês; as chaves de saída do `stage.sh` não mudam.
- [x] A `anvil-run` cita só chaves que o script emite, e a troca sai num commit só.
- [x] Fixture em `/tmp` com os estados da 003 (livre, bloqueado, travado com P1, dependente, pulado, árvore suja, tudo resolvido) dá, nos dois bash, a mesma saída de antes a menos dos nomes das chaves.
- [x] O S1 e o S2 da `anvil-run` passam com as chaves novas, sem mudança de comportamento do supervisor.
- [x] O `verify` sai limpo.

## Comments

- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep`. Roda o `frontier.sh` e o `stage.sh` do `HEAD` anterior e os novos em `/opt/local/bin/bash` e `/bin/bash`, traduz a saída antiga pela tabela da spec e compara. Cobre livre, bloqueado, travado com P1, travado sem P1, dependente, dependente do dependente, bloqueador inexistente, pulado, árvore suja, tudo resolvido com e sem `ui/`, história de tela, recusas, e os estados do `stage.sh`. Resultado: `fixture: 0 falha(s)`, sem chave antiga na saída nova.
- S1 (`workspace/29-codex-mirror/s1.sh`): 104/104 nos dois bash, depois do `dev-link.sh`. Antes dele dava 103/104, porque faltava `.agents/skills` neste repositório (check "espelho = skills ligadas em .claude/skills"). Falha de ambiente, não do ticket.
- S2 (`workspace/33-omp-run/s2.sh`), evidência em `/tmp/anvil-004-01`: chaves novas passaram em 2 de 4 rodadas, o controle com as chaves antigas em 2 de 3. A falha é a mesma nos dois lados, o 06 despachado duas vezes, ruído que já existia na 003. Sem mudança de comportamento do supervisor atribuível à troca de chaves.
