# 03: P1 do travado em linha combinada

**What to build:** O relatório do ticket travado passa a trazer o P1 mesmo quando a linha do `## Comments` combina classes, como "Review round=2 · P2 (Standards) e P1 (Spec)". O operador decide a terceira rodada vendo o achado que travou. É a linha A3 do acompanhamento.

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=adce159; scope=full; verdict=pass; p1=none

- [x] Conta toda linha da última rodada que começa por `Review round=N ·` e tem `P1` em posição de classe, seguido de espaço e parêntese ou de dois-pontos, em qualquer ponto depois do ponto médio.
- [x] "Review round=2 · P2 (Standards): prova fraca do P1 anterior" não conta.
- [x] Travado sem linha P1 continua dizendo isso por extenso.
- [x] A mesma saída em `LC_ALL=C` e em UTF-8, e nos dois bash, por fixture em `/tmp`.
- [x] O `verify` sai limpo.

## Comments

- Leitura: o `grep` do `open_p1` roda com `LC_ALL=C`, e o padrão é `^- *Review round=N · (.*[^[:alnum:]_])?P1( \(|:)`. Em bytes, o ponto médio casa igual em qualquer locale, e a classe de caractere antes do `P1` não muda com ele. O formato da linha `open_p1 NN: <linha do ## Comments>` não muda, então a `anvil-run/SKILL.md` e a tabela da spec ficam como estão. A frase do travado sem P1 também fica como estava, "nenhuma linha 'Review round=N · P1' no ## Comments", porque o caso `f-livre-bloq-trav-dep`, que compara com o script do c2111a5, depende dela.
- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep`, caso `f-p1-travado` sobre a spec 014, com a saída escrita à mão e rodado em `LC_ALL=pt_BR.UTF-8` e `LC_ALL=C`, em `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57. O travado 01 tem a linha combinada "P2 (Standards) e P1 (Spec)" e a "P1:" sem eixo, que contam, e três que não contam: a da rodada 1, a de `round=12` e a "prova fraca do P1 anterior". O travado 02 só tem as que não contam, incluindo "AP1 (legado)" e "P1anterior:", e sai com a frase por extenso. Antes da mudança, o caso falhava nos quatro ambientes só pela linha combinada. Depois, 32 casos ok e 0 falha. Os casos da 003 seguem comparando com o c2111a5, e as quatro saídas do caso novo são idênticas byte a byte.
- `vendor-sync.sh verify`: `verify: limpo`.
- Review round=1 · P2 (Spec): o teste de posição de classe é só pontuação, e um P2 ou P3 que cita "P1 (Spec)" no meio da frase conta — a linha 49 do ticket 08 da 003 arquivada casaria, e o operador de um travado assim veria um achado a mais, o que a US 9 (o relatório não mostra achado a mais) quer evitar; falta declarar esse limite na decisão da spec.
- Review round=1 · P2 (Standards): o `anvil-implementer.md` e os exemplos do `docs/agents/issue-tracker.md` seguem com uma classe por linha, e a linha combinada só existe no comentário do `frontier.sh` — quem mantiver o script pode tirar a leniência por achá-la acidental.
- Review round=1 · P3 (Standards e Spec): a frase do travado sem P1, "nenhuma linha 'Review round=N · P1' no ## Comments", descreve a regra antiga — quem lê pode achar que a linha combinada não foi procurada e reconferir à mão; mantida pelo caso `f-livre-bloq-trav-dep`.
- Review round=1 · P3 (Spec): "P1 e P2 (Spec): …", com o P1 sem eixo próprio antes de outra classe, não casa — quem escrever a combinação nessa ordem não vê o achado no relatório.
- Review round=1 · P3 (Standards): "depois do ponto medio", no comentário do `frontier.sh` e no critério 1, se lê como "metade da linha" em vez do separador `·` — quem mexer no padrão pode implementar uma regra posicional que não existe.
