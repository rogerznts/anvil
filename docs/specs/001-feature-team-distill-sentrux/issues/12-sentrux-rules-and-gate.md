# 12: `anvil-sentrux`: regras a partir dos ADRs e gate de sessão

**What to build:** Num projeto com ADRs de camada e fronteira, a `anvil-sentrux` propõe as regras correspondentes do sentrux, cada uma com o motivo apontando o ADR, e só escreve com aprovação. Antes de uma sessão de implementação, oferece salvar a linha de base; depois, compara. O Review da equipe consulta o sentrux pela linha de comando quando ele está instalado.

**Blocked by:** 11, 06

**Status:** ready-for-agent

- [ ] Proposta de regras extraída dos ADRs, com o motivo de cada fronteira apontando o ADR; escrita só com aprovação.
- [ ] Gate: salvar a linha de base antes e comparar depois de uma sessão de implementação; nada no fluxo o chama.
- [ ] O Review usa o sentrux pela linha de comando, e a allowlist dele não muda.
- [ ] Ponto B: um ADR com fronteira gera a proposta; uma violação da fronteira faz a verificação falhar; o gate acusa degradação numa sessão que cria um ciclo.
