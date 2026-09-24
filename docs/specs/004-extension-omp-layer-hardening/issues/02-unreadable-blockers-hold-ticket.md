# 02: Bloqueio ilegível segura o ticket

**What to build:** Um `Blocked by` que o `frontier.sh` não consegue ler segura o ticket fora do frontier, em vez de soltá-lo. O operador vê no relatório o ticket com a classe `unreadable_blockers` e o texto original da linha, e corrige. É a linha A1 do acompanhamento.

**Blocked by:** 01

**Status:** resolved

- [x] Referências `ADR-NNNN` saem antes da leitura: "03, ver ADR-0011" bloqueia só pelo 03.
- [x] `01, 02` e `01,02` bloqueiam pelos dois, como hoje.
- [x] Linha ausente, vazia, "Nenhum — pode começar agora." e "None (can start immediately)" deixam o ticket livre.
- [x] "01 e 02", "01 (a), 02 (b)", "`05`" e "01; 05" dão `class=unreadable_blockers`, com o texto original do `Blocked by` na linha do ticket, e o ticket nunca sai em `next`.
- [x] Um ticket que depende de um de bloqueio ilegível fica em `waiting`.
- [x] Bloqueador inexistente continua aparecendo como "não existe".
- [x] Prova por fixture em `/tmp`, com saída idêntica em `/opt/local/bin/bash` e `/bin/bash`.
- [x] O `verify` sai limpo.

## Comments

- Contrato: no ticket de bloqueio ilegível, o campo `blocked_by` traz o valor da linha entre aspas, `blocked_by="01 e 02"`, em vez de uma chave nova. A tabela da spec, a `anvil-run/SKILL.md` e o comentário do `frontier.sh` dizem o mesmo, no mesmo commit.
- Leitura do ADR: a spec diz que o `ADR-NNNN` sai e o resto tem de ser lista de números, mas em "03, ver ADR-0011" o resto é "03, ver ", que não é lista. O script lê o `Blocked by` item a item, entre vírgulas, e tira o item que cita um ADR quando, sem o ADR, não sobra dígito nele. "03 (ver ADR-0011)" sobra "03 (ver )" e dá bloqueio ilegível: na dúvida, bloqueia. Uma linha só com "ver ADR-0011" fica sem bloqueador.
- Precedência: `resolved` e `locked` vêm antes de `unreadable_blockers`. Um ticket resolvido com `Blocked by` ilegível segue `resolved`, e o `blocked_by` dele sai entre aspas do mesmo jeito.
- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep`. Os casos da 003 comparam com o `frontier.sh` e o `stage.sh` do c2111a5 (o 01) e saem iguais. Os casos novos comparam com a saída escrita à mão, nos dois bash: spec 012, com 17 tickets nos formatos das US 1–7 (ilegíveis, dependente de ilegível, ADR, `01, 02`, `01,02`, linha vazia, sem linha, "Nenhum", "None", caixa alta e baixa, inexistente); a mesma spec com todo o frontier no `--skip` (`next: none` com ilegíveis abertos); e a spec 013, em que o único aberto é ilegível sobre bloqueadores resolvidos. Antes da mudança, 3 falhas: o script soltava os ilegíveis pelo prefixo numérico, e o "`01`" saía sem bloqueador. Depois, `fixture: 0 falha(s)`. A spec 012 dá a mesma saída com `LC_ALL=C` nos dois bash.
- `vendor-sync.sh verify`: `verify: limpo`.
