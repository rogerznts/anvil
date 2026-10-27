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

## security-audit-record — spec 014

- Estado: fechada, com merge local na `main` (`e79bbd5`)
- Branch: `feature/014-security-audit-record`

### Pausas respondidas pelo piloto

- `anvil-to-spec` — Os seams batem com o esperado? Resposta: um seam só, o verbo `security` rodado sobre um diretório de execução de exemplo, observado no arquivo gravado e no `docs/index.md` (recomendada pela skill: o seam mais alto e único).
- `anvil-to-tickets` — A granularidade está certa? Resposta: dois tickets, o verbo que grava o registro, depois o domínio `security/` no `anvil-docs` e no índice (a mais conservadora: mantém a quebra proposta, sem ampliar o escopo).

### Tickets

- `docs/specs/archive/014-feature-security-audit-record/issues/01-security-verb-writes-record.md` — Status: resolved
  - Review: round=1; sha=9c127e4; scope=full; verdict=fail; p1=open
  - Review: round=2; sha=38998e5; scope=diff:9c127e4..38998e5; verdict=pass; p1=none
- `docs/specs/archive/014-feature-security-audit-record/issues/02-security-domain-indexed.md` — Status: resolved
  - Review: round=1; sha=4f93665; scope=full; verdict=fail; p1=open
  - Review: round=2; sha=e8ab4e5; scope=diff:4f93665..e8ab4e5; verdict=pass; p1=none

### P2 e P3 que ficaram

- `01-security-verb-writes-record.md` — Review round=1 · P3 (Standards): possível Mysterious Name — o `n` que atravessa `runDirectory`, `render` e `recordPath` é o número da execução, e só o comentário do topo diz isso — quem lê precisa rastrear o significado.
- `01-security-verb-writes-record.md` — Review round=2 · P3 (Standards): possível Duplicated Code — o `hidden` do `render` refaz o teste `SAFE_ID` que o `id()` já aplica por linha — quem mudar a regra de exibição em um dos dois e esquecer o outro deixa a nota do rodapé dizendo o contrário da tabela.
- `01-security-verb-writes-record.md` — Review round=2 · P3 (Standards): no `SECURITY.md`, "com a posição do achado no `findings.json` da execução, onde ele se acha" tem antecedente ambíguo entre o achado e a execução — quem lê rápido não sabe onde procurar o fingerprint oculto.
- `02-security-domain-indexed.md` — Review round=1 · P2 (Standards): o quarto critério tem prova mais fraca que os outros — o `docs/index.md` gerado à mão não está no disco depois de rodar o cenário, e quem revisa depois tem de confiar na descrição em vez de inspecionar o resultado.
- `02-security-domain-indexed.md` — Review round=1 · P3 (Standards): possível Shotgun Surgery — um domínio canônico novo exige editar seis arquivos do `anvil-docs` (`ADOPT.md`, `INDEX.md`, `SECURITY.md`, `SKILL.md`, `validate.sh`, `templates/docs-index.md`); é o padrão que já existia, e o próximo domínio vai pagar o mesmo custo.
- `02-security-domain-indexed.md` — Review round=1 · P3 (Spec): a chamada ao `index` no `SECURITY.md` é uma frase solta, enquanto o `ARCHIVE.md` dá ao índice uma seção numerada própria — forma divergente entre verbos irmãos, sem efeito no comportamento.

### Travados em round=2

nenhum

### Comando de verificação

```text
$ bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
…
verify: limpo
exit: 0
```

O `Pronto quando:` da entrada, conferido por um smoke independente, fora do repositório, em `/tmp/smoke014/`: execução `run-5` com um achado de cada veredito, marcadores únicos em título, descrição, trace, reprodução e correção, e um fingerprint `src/leak.c:9`; os dois validadores da cópia vendorizada saem `PASS`.

```text
$ node anvil-docs/scripts/audit-record.cjs /tmp/smoke014/run-5
record: docs/security/audit-2026-10-27-run-5.md   (exit=0)
$ grep -c LEAKMARK docs/security/audit-2026-10-27-run-5.md  → 0
$ grep -c "src/"    docs/security/audit-2026-10-27-run-5.md  → 0
rodar de novo: o mesmo arquivo, mesmo hash
validador corrompido: refusal: validate-findings.cjs saiu com 1 sobre findings.json (exit=2), nada gravado
$ bash anvil-docs/scripts/validate.sh docs-paths   → sem saída, exit=0
```

### Pesquisas

nenhum

### Decidido sem humano

- O implementer do ticket 01 decidiu ocultar, na linha do achado, o fingerprint que tem caractere fora de letras, dígitos, `-` e `_`: o schema do upstream aceita `/`, `.` e `:` no fingerprint, e um fingerprint derivado do caminho vazaria. A linha leva a posição do achado no `findings.json` da execução. Ocultar, e não recusar a execução, veio da user story 7.
- O script exige `source_ref.commit` e `source_ref.dirty` no `run-metadata.json`: o upstream não fixa a forma do `source_ref`. Uma execução real com outra forma é recusada.
- O escopo da execução (`scope_paths`) não entra no registro: é lista de caminhos, fora da lista branca. A user story 3 fica atendida pelo perfil.
- O ticket 01 deixou para o ticket 02 a chamada ao `index` ao fim do verbo.

## Onde a corrente parou

Nenhuma entrada parada. As duas entradas do roteiro fecharam, e o `roadmap.sh` dá `next: none`: a corrente terminou.

## O que ainda espera decisão

- Os P2 que ficaram — o comportamento do modo guidance e o caminho de saída escritos em três lugares (ticket 02 da 013), e a prova do índice que não ficou no disco (ticket 02 da 014) — viram linhas em `docs/project/acompanhamento.md` ou ficam congelados nos tickets?
- A forma do `source_ref` que o `audit-record.cjs` exige (`commit` e `dirty`) é a que a `anvil-security-audit` grava numa execução real? Se não for, a primeira auditoria de verdade é recusada pelo verbo `security`, e a forma se ajusta numa spec `extension`.
- O PR #6 (`feature/adjust-code-review`) mistura a spec 002, de custo de verificação, com a parte de segurança que o ADR-0015 tirou do plano: quando a 002 é separada e revisada contra o anvil atual?
