# 08: Bench com teto de duas rodadas e retomada de construção começada fora dele

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o bench passa a seguir o orçamento do ADR-0010 (a
verificação tem critério de parada, e a terceira rodada é escolha declarada de um
humano). O teto deixa de ser de três tentativas por ticket e passa a ser de duas
rodadas, também no bench manual. Um ticket travado vira `CONCERNS` e entra como
pendência na entrega. Na fase 2, uma construção começada fora do bench, sem
checklist nem `gates.md`, é retomada refazendo só a fase 4 a partir da spec e
dos tickets existentes. Sem spec, a fase 3 vira entrevista do delta. A entrega
diz em que ponto a retomada entrou.

- [ ] O `GATE.md` troca "o teto de três" pelas duas rodadas do ADR-0010, e o
      veredito `CONCERNS` cobre o ticket travado em `round=2`.
- [ ] O diagrama e a prosa da fase 5 do `SKILL.md` do bench dizem duas rodadas,
      e nenhum "3 tentativas" sobra no bench.
- [ ] A fase 2 ganha o ramo de retomada: com spec e tickets, mas sem checklist
      nem `gates.md`, refaz só a fase 4; sem spec, faz a fase 3 como delta.
- [ ] A entrega registra o ponto em que a retomada entrou.
- [ ] O material de `unlazy/` não muda, e o `SKILL.md` e o `GATE.md` continuam
      protegidos por `keep` no manifesto.
- [ ] `vendor-sync.sh verify` sai `0`.
