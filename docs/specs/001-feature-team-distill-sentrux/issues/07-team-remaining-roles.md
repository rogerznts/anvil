# 07: `anvil-team`: os outros cinco papéis e a conversa entre papéis

**What to build:** A equipe fica completa: PO, Architect, Analyst, Designer e Tester são despachados pelo Leader como Dev e Review já são. Dois papéis conversam direto — o Dev pede um repro ao Tester sem passar pelo Leader — e o julgamento do Tester chega ao Leader mesmo quando o Dev discorda. A documentação para de dizer que o anvil não tem agentes.

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] `anvil-team-po`, `anvil-team-architect`, `anvil-team-analyst`, `anvil-team-designer` e `anvil-team-tester` existem no payload, com descriptions que não atraem delegação automática.
- [ ] Cada papel guarda só o que é dele; o comum fica no protocolo.
- [ ] As skills citadas pelos papéis existem no payload: `anvil-diagnose`, `anvil-tdd` e `anvil-code-review` no lugar dos nomes inexistentes da configuração de origem.
- [ ] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 07.
- [ ] O `verify` reprova agente que cita skill inexistente no payload ou skill com trava de invocação.
- [ ] O PO não cita `anvil-to-questionnaire`; o Leader sugere `/anvil-wayfinder` e `/anvil-handoff` ao usuário em vez de despachá-las.
- [ ] O README e o overview dizem que o anvil distribui agentes e a skill de equipe, apontando o ADR-0007.
- [ ] Ponto B: uma mensagem do Dev chega ao Tester sem passar pelo Leader; o julgamento do Tester chega ao Leader; cada um dos cinco papéis é despachado ao menos uma vez.

## Comments

**Leader, 2026-09-13 — U3:** `anvil-wayfinder`, `anvil-handoff` e `anvil-to-questionnaire` continuam
travadas (o usuário destravou só as sete que a equipe despacha). Vale a saída do desenho.
