# 06: Rodar de novo fecha e reabre achados

**Blocked by:** 05
**Status:** ready-for-agent

**What to build:** O `findings.md` acompanha as correções. Ao rodar de novo, o probe retesta cada `SEC-#`: o que não se reproduz mais vira `corrigido`; o que estava `corrigido` e volta a se reproduzir é reaberto no mesmo `SEC-#`, com a evidência nova, sem id novo.

- [ ] Com a falha plantada corrigida, o probe marca `SEC-1` como `corrigido`
- [ ] Reintroduzida a falha, o probe reabre `SEC-1` com evidência nova, sem criar `SEC-2`
- [ ] Achado cujo teste ficou sem cobertura nesta rodada não muda de status
