# Relatório do piloto automático

Roteiro: `docs/specs/roadmap.md`, confirmado no commit `a460434`.

## security-audit-vendor — spec 013

- Estado: fechada, com merge local na `main` (`55d4b9c`)
- Branch: `feature/013-security-audit-vendor`

### Pausas respondidas pelo piloto

- `anvil-to-spec` — Os seams batem com o esperado? Resposta: um seam só, a cópia no payload, observada pelo `vendor-sync.sh verify` e pelo `node --test` dos testes do upstream (recomendada pela skill: o seam mais alto e único).
- `anvil-to-tickets` — A granularidade está certa? Resposta: dois tickets, a cópia vendorizada e verificada, depois o roster e o README (a mais conservadora: mantém a quebra proposta, sem ampliar o escopo).

### Tickets

- `docs/specs/archive/013-feature-security-audit-vendor/issues/01-vendor-the-skill.md` — Status: resolved
  - Review: round=1; sha=0f446ec50973021ff84f5a19c4e0076c8e0fde6b; scope=full; verdict=pass; p1=none
- `docs/specs/archive/013-feature-security-audit-vendor/issues/02-link-and-document.md` — Status: resolved
  - Review: round=1; sha=0a8bd42a4db1c8e623103de3b1f5c16d8749511f; scope=full; verdict=pass; p1=none

### P2 e P3 que ficaram

- `02-link-and-document.md` — Review round=1 · P2 (Standards): o fato "o modo guidance não escreve arquivo nem roda as seis fases sem pedido explícito" e o caminho de saída da auditoria ficam escritos em três lugares — comentário do `dev-link.sh`, README e ADR-0015 — sem nada que force a sincronia — se o upstream mudar o padrão da skill, os três precisam ser editados à mão e um deles pode ficar mentindo.
- `02-link-and-document.md` — Review round=1 · P3 (Standards): na árvore de `references/` do README, `security-audit-skill/` repete o respiro de dois espaços de `payload-skills/` e não alinha com as entradas curtas — inconsistência de forma pré-existente, sem efeito de comportamento.

### Travados em round=2

nenhum

### Comando de verificação

```text
$ bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
…
14. name: da camada omp bate com o arquivo ou a pasta
15. caminho citado pela camada omp existe no payload
16. skill em autoloadSkills de agente da camada existe e não tem trava
17. skill da camada omp tem trava de invocação

verify: limpo
exit: 0
```

O `Pronto quando:` da entrada, conferido à parte:

```text
$ node --test *.test.cjs   # em anvil/.claude/skills/anvil-security-audit/
ℹ tests 65
ℹ pass 65
ℹ fail 0

$ readlink ~/.claude/skills/anvil-security-audit ~/.agents/skills/anvil-security-audit
/home/claudiotenreiro/projects/labstorm/anvil/anvil/.claude/skills/anvil-security-audit
/home/claudiotenreiro/projects/labstorm/anvil/anvil/.claude/skills/anvil-security-audit
```

### Pesquisas

nenhum

### Decidido sem humano

- O `frontier.sh` deu `halt` depois do ticket 01: o merge do worktree isolado trouxe o gitlink do submodule novo, mas não o clone, e a árvore mostrava `references/security-audit-skill` como apagado. O piloto rodou `git submodule update --init references/security-audit-skill`, que só faz o checkout do pin commitado, sem descartar nada; a árvore voltou limpa e o despacho seguiu.
- O implementer do ticket 02 não ligou a skill no `HOME` real, por rodar numa worktree isolada. O piloto rodou o `dev-link.sh` do repositório principal depois do merge do ticket: os dois symlinks apontam para o payload.
- A primeira tentativa de commitar o archive e fazer o merge numa só chamada foi bloqueada pela guarda, que avaliou o merge antes do commit do archive existir. O piloto commitou o archive, voltou à `main` e fez o merge em chamadas separadas; a guarda liberou.
- No `index`, a seção "Roteiro" entrou no `docs/index.md`, que ainda não a tinha.

## Onde a corrente parou

Nenhuma entrada parada. A próxima é `security-audit-record`, liberada com o fechamento da 013.

## O que ainda espera decisão

- O P2 do ticket 02 da 013 — o comportamento do modo guidance e o caminho de saída escritos em três lugares — vira linha em `docs/project/acompanhamento.md` ou fica congelado no ticket?
- O PR #6 (`feature/adjust-code-review`) mistura a spec 002, de custo de verificação, com a parte de segurança que o ADR-0015 tirou do plano: quando a 002 é separada e revisada contra o anvil atual?
