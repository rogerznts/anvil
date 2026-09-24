# 03: P1 do travado em linha combinada

**What to build:** O relatório do ticket travado passa a trazer o P1 mesmo quando a linha do `## Comments` combina classes, como "Review round=2 · P2 (Standards) e P1 (Spec)". O operador decide a terceira rodada vendo o achado que travou. É a linha A3 do acompanhamento.

**Blocked by:** 01

**Status:** resolved

- [x] Conta toda linha da última rodada que começa por `Review round=N ·` e tem `P1` em posição de classe, seguido de espaço e parêntese ou de dois-pontos, em qualquer ponto depois do ponto médio.
- [x] "Review round=2 · P2 (Standards): prova fraca do P1 anterior" não conta.
- [x] Travado sem linha P1 continua dizendo isso por extenso.
- [x] A mesma saída em `LC_ALL=C` e em UTF-8, e nos dois bash, por fixture em `/tmp`.
- [x] O `verify` sai limpo.

## Comments

- Leitura: o `grep` do `open_p1` roda com `LC_ALL=C`, e o padrão é `^- *Review round=N · (.*[^[:alnum:]_])?P1( \(|:)`. Em bytes, o ponto médio casa igual em qualquer locale, e a classe de caractere antes do `P1` não muda com ele. O formato da linha `open_p1 NN: <linha do ## Comments>` não muda, então a `anvil-run/SKILL.md` e a tabela da spec ficam como estão. A frase do travado sem P1 também fica como estava, "nenhuma linha 'Review round=N · P1' no ## Comments", porque o caso `f-livre-bloq-trav-dep`, que compara com o script do c2111a5, depende dela.
- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep`, caso `f-p1-travado` sobre a spec 014, com a saída escrita à mão e rodado em `LC_ALL=pt_BR.UTF-8` e `LC_ALL=C`, em `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57. O travado 01 tem a linha combinada "P2 (Standards) e P1 (Spec)" e a "P1:" sem eixo, que contam, e três que não contam: a da rodada 1, a de `round=12` e a "prova fraca do P1 anterior". O travado 02 só tem as que não contam, incluindo "AP1 (legado)" e "P1anterior:", e sai com a frase por extenso. Antes da mudança, o caso falhava nos quatro ambientes só pela linha combinada. Depois, 32 casos ok e 0 falha. Os casos da 003 seguem comparando com o c2111a5, e as quatro saídas do caso novo são idênticas byte a byte.
- `vendor-sync.sh verify`: `verify: limpo`.
