# 12: `anvil-sentrux`: regras a partir dos ADRs e gate de sessão

**What to build:** Num projeto com ADRs de camada e fronteira, a `anvil-sentrux` propõe as regras correspondentes do sentrux, cada uma com o motivo apontando o ADR, e só escreve com aprovação. Antes de uma sessão de implementação, oferece salvar a linha de base; depois, compara. O Review da equipe consulta o sentrux pela linha de comando quando ele está instalado.

**Blocked by:** 11, 06

**Status:** ready-for-agent

- [ ] Proposta de regras extraída dos ADRs, com o motivo de cada fronteira apontando o ADR; escrita só com aprovação.
- [ ] Gate: salvar a linha de base antes e comparar depois de uma sessão de implementação; nada no fluxo o chama.
- [ ] O Review usa o sentrux pela linha de comando, e a allowlist dele não muda.
- [ ] Ponto B: um ADR com fronteira gera a proposta; uma violação da fronteira faz a verificação falhar; o gate acusa degradação numa sessão que cria um ciclo.

## Comments

**Leader, 2026-09-13 — fatos do Analyst** em `discovery/sentrux-facts.md` (`371d1e0`), a usar na implementação:

- `[[layers]]` usa `order` **invertido** em relação à documentação na v0.5.7 (order 0 é a camada de cima); o PR #67,
  aberto, inverte o código. A skill descreve a semântica da versão fixada, e a troca de versão exige reconferir.
- `[[boundaries]]` aceita `reason` livre, anexado à mensagem depois de " — "; `[[layers]]` não tem `reason`. Chave
  desconhecida é ignorada em silêncio; glob só aceita curinga no fim.
- `sentrux check [path]` sai 0/1 e lê o `rules.toml`. `gate --save` grava `.sentrux/baseline.json`; `gate` sai 1 se
  degradou e **não lê o `rules.toml`** — fronteira violada falha no `check`, não no `gate`. Sem saída JSON.
- O scan só vê arquivos rastreados pelo git: no ponto B, os arquivos do ciclo precisam estar no índice.
- `check_rules` pelo MCP trunca em 3 regras no tier gratuito; a CLI não — o Review usa a CLI (já decidido).
- Pendente de decisão do usuário: download de gramáticas sem conferência e telemetria diária em qualquer invocação.
