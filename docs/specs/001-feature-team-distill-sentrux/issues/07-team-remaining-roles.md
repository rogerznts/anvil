# 07: `anvil-team`: os outros cinco papéis e a conversa entre papéis

**What to build:** A equipe fica completa: PO, Architect, Analyst, Designer e Tester são despachados pelo Leader como Dev e Review já são. Dois papéis conversam direto — o Dev pede um repro ao Tester sem passar pelo Leader — e o julgamento do Tester chega ao Leader mesmo quando o Dev discorda. A documentação para de dizer que o anvil não tem agentes.

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] `anvil-team-po`, `anvil-team-architect`, `anvil-team-analyst`, `anvil-team-designer` e `anvil-team-tester` existem no payload, com descriptions que não atraem delegação automática.
- [ ] Cada papel guarda só o que é dele; o comum fica no protocolo.
- [ ] As skills citadas pelos papéis existem no payload: `anvil-diagnose`, `anvil-tdd` e `anvil-code-review` no lugar dos nomes inexistentes da configuração de origem.
- [ ] O README e o overview dizem que o anvil distribui agentes e a skill de equipe, apontando o ADR-0007.
- [ ] Ponto B: uma mensagem do Dev chega ao Tester sem passar pelo Leader; o julgamento do Tester chega ao Leader; cada um dos cinco papéis é despachado ao menos uma vez.
