# 05: A cilada do `--no-isolate` entra na rule do Payload, ou não entra

**What to build:** Um agente num projeto Payload lê na rule da stack que `--no-isolate` introduz dependência de ordem — **só se o ticket 04 reproduziu**, e com o alcance que ele mostrou: Payload em geral, ou só quem usa o plugin multi-tenant. A cilada segue o formato das três primeiras: o sintoma (verde na primeira rodada, falha com shuffle), a causa que a reprodução confirmou, que o arquivo que quebra é a vítima, e o jeito certo, com o shuffle com isolamento como controle. Se o 04 não reproduziu, o ticket fecha sem mudança no `RULE.md`, com a justificativa.

**Blocked by:** 04

**Status:** resolved

- [x] Reproduziu: a cilada entra no `RULE.md` do `anvil-stack-payload` no formato das outras, com o alcance do veredito do 04, e o título vira "As quatro ciladas".
- [x] Nenhum número de projeto é citado na cilada.
- [~] Não reproduziu: o `RULE.md` fica intocado e o ticket registra o porquê em `## Comments`. — não se aplica: o 04 reproduziu.
- [x] O `reference/` do `anvil-stack-payload` fica intocado.
- [x] O `verify` sai limpo.

## Comments

- O 04 reproduziu só com o plugin, então a cilada entra com esse alcance: o
  título dela nomeia o plugin e o primeiro parágrafo diz para quem vale. Os
  lugares que citavam "três ciladas" foram atualizados: o `README.md`, o exemplo
  de proposta do passo 7 do `anvil-boot` e o `VENDOR.md`, que agora diz que a
  quarta não vem do upstream. O ADR-0006 e o `STACK-CONTRACT.md` ficam como
  estão: o primeiro é histórico, e o segundo usa "três ciladas" como exemplo de
  princípio, não como contagem da rule.
