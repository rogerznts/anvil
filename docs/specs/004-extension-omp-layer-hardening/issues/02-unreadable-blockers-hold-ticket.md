# 02: Bloqueio ilegível segura o ticket

**What to build:** Um `Blocked by` que o `frontier.sh` não consegue ler segura o ticket fora do frontier, em vez de soltá-lo. O operador vê no relatório o ticket com a classe `unreadable_blockers` e o texto original da linha, e corrige. É a linha A1 do acompanhamento.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] Referências `ADR-NNNN` saem antes da leitura: "03, ver ADR-0011" bloqueia só pelo 03.
- [ ] `01, 02` e `01,02` bloqueiam pelos dois, como hoje.
- [ ] Linha ausente, vazia, "Nenhum — pode começar agora." e "None (can start immediately)" deixam o ticket livre.
- [ ] "01 e 02", "01 (a), 02 (b)", "`05`" e "01; 05" dão `class=unreadable_blockers`, com o texto original do `Blocked by` na linha do ticket, e o ticket nunca sai em `next`.
- [ ] Um ticket que depende de um de bloqueio ilegível fica em `waiting`.
- [ ] Bloqueador inexistente continua aparecendo como "não existe".
- [ ] Prova por fixture em `/tmp`, com saída idêntica em `/opt/local/bin/bash` e `/bin/bash`.
- [ ] O `verify` sai limpo.
