# 01: O perfil de verificação diz quando rodar o gate

**What to build:** Um agente que lê o perfil de verificação sabe que o gate — a suíte inteira mais o typecheck — roda **uma vez por ticket**, nunca uma vez por spec, e sabe por quê: por spec, uma falha vira bissecção entre tickets já entrelaçados. Sabe que o gate roda em background e não bloqueia o próximo passo, e que há uma rodada da suíte inteira antes do merge, sobre o branch completo, para pegar a interação entre tickets. Sabe também que o laço curto é o passo seguinte, a adotar quando o laço passar de ~2 min, e não na instalação, e que a seleção do laço curto adia a descoberta, nunca dispensa o gate. Nenhum número de projeto aparece no perfil: o custo de cada projeto está no `anvil.md` dele.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] O template do perfil no `anvil-docs` tem a seção do custo, ao lado de classe, orçamento e persistência.
- [ ] A seção diz: gate por ticket, com o argumento da bissecção; gate em background; rodada antes do merge; sinal de adoção do laço curto (~2 min); forma genérica do laço curto (o barato e transversal roda inteiro, só o caro se seleciona, numa invocação só); a seleção adia e não dispensa o gate.
- [ ] Nenhum número medido de projeto aparece na seção.
- [ ] `docs/agents/verification.md` do anvil é idêntico ao template.
- [ ] O `verify` sai limpo.
