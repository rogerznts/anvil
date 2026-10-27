# Relatório do piloto automático

Roteiro: `docs/specs/roadmap.md`, confirmado no commit `f120d11`.

Antes da corrente, com o sim do operador, a `main` local foi integrada ao `origin/main` (merge `41dc8ff`): ela estava 129 commits atrás, desde 17/10, com as specs 009 a 012. Conflitos resolvidos no `dev-link.sh` (valeu a estrutura do `origin`, com `anvil-security-audit` no roster), no `docs/index.md` e em `docs/project/acompanhamento.md`. O ADR da auditoria colidia com o ADR-0015 do `origin` (branch base) e virou o ADR-0019 — a auditoria de segurança é a skill da Cloudflare, vendorizada —, com as citações corrigidas no payload, no README, no manifesto, no índice e nas specs 013 e 014.

## security-audit-record-metadata — spec 015

- Estado: fechada, com merge local na `main` (`426672a`)
- Branch: `extension/015-security-audit-record-metadata`

### Pausas respondidas pelo piloto

- `anvil-to-spec` — Os seams batem com o esperado? Resposta: um seam só, o mesmo da 014, o verbo `security` sobre um diretório de execução de exemplo (recomendada pela skill: o seam mais alto e único).
- `anvil-to-tickets` — A granularidade está certa? Resposta: um ticket, por ser uma mudança num script e no documento do verbo (a mais conservadora: sem ampliar o escopo).

### Tickets

- `docs/specs/archive/015-extension-security-audit-record-metadata/issues/01-tolerant-metadata.md` — Status: resolved
  - Review: round=1; sha=54d339d; scope=full; verdict=pass; p1=none

### P2 e P3 que ficaram

- `01-tolerant-metadata.md` — Review round=1 · P3 (Standards): possível Duplicated Code — no `render()`, a forma "`=== null` ? marca : valor formatado" aparece no `shown()` e de novo, à mão, no commit e na árvore com `NOT_DECLARED` — o próximo campo marcado vira mais uma cópia do mesmo condicional em vez de reusar um helper.
- `01-tolerant-metadata.md` — Review round=1 · P3 (Spec): com `commit` string sem SHA e `sha` com SHA, o script não cai para o `sha`, porque toma o primeiro campo que é string, como a spec manda ("o primeiro de `commit`, `sha` e `revision` que é string") — quem lê o código esperando "o primeiro que traz SHA" se surpreende, sem defeito de contrato.

### Travados em round=2

nenhum

### Comando de verificação

```text
$ bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
…
verify: limpo
exit: 0
```

O `Pronto quando:` da entrada, conferido também pelo piloto sobre a execução de exemplo de `/tmp/smoke014`, com marcadores no `source_ref` e no `run_id` (`2026-10-27T10:00.LEAKMARKID`):

```text
== obj:   Execução: não exibido · Commit auditado: `abcdef1234567` · Árvore auditada: suja · leaks=0
== str:   Execução: não exibido · Commit auditado: `0123456789abcdef0123456789abcdef01234567` · Árvore auditada: suja · leaks=0
== nosha: Execução: não exibido · Commit auditado: não declarado em forma reconhecível · Árvore auditada: não declarado em forma reconhecível · leaks=0
== none:  Execução: não exibido · Commit auditado: não declarado em forma reconhecível · Árvore auditada: não declarado em forma reconhecível · leaks=0
```

### Pesquisas

nenhum

### Decidido sem humano

- Na integração, o comentário do `dev-link.sh` sobre a auditoria saiu com a estrutura nova do `origin`; a linha de acompanhamento do P2 da 013 foi escrita como A39 (o `origin` já usava até a A38) e diz agora dois lugares, README e ADR-0019.
- O `Entra:` da entrada `security-audit-vendor` ainda cita "o ADR-0015": o piloto não edita `Entra:`. O ADR certo é o ADR-0019.
- O implementer decidiu que uma string de `source_ref` com `dirty` e `clean` ao mesmo tempo vale `dirty`; está no `SECURITY.md`.
- `profile` e `run_status` continuam recusados fora dos valores do upstream, que o `SKILL.md` dele enumera; a spec registrou isso.

## Onde a corrente parou

Nenhuma entrada parada. As três entradas do roteiro estão fechadas, e o `roadmap.sh` dá `next: none`: a corrente terminou.

## O que ainda espera decisão

- A instalação de usuário desta máquina (`~/.claude/skills/anvil-docs`, `~/.omp/agent`) é a publicada de 19/10, sem o verbo `security`; e o `dev-link.sh` antigo, rodado na spec 013, deixou `~/.claude/skills/anvil-security-audit` e `~/.agents/skills/anvil-security-audit` como symlinks globais para este checkout, o modelo que o ADR-0018 substituiu pelo HOME dev do `dev-run.sh`. Tira esses dois symlinks com o `dev-link.sh --unlink` e passa a usar o `dev-run.sh`, ou os mantém até publicar?
- A `main` local está à frente do `origin` com esta execução: quando ela é publicada?
- O PR #6 (`feature/adjust-code-review`) mistura a spec 002, de custo de verificação, com a parte de segurança que o ADR-0019 tirou do plano: quando a 002 é separada e revisada contra o anvil atual?
