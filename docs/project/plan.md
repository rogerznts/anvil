# Plano de construção do anvil

Documento vivo. Reescrito conforme avança; o histórico fica no git.

**Onde estamos:** Fase 0 concluída (`205e883`). Próxima: Fase 1 — `anvil-docs`.

As decisões de arquitetura não se repetem aqui — estão em
[`docs/architecture/adr/`](../architecture/adr/) e resumidas no
[overview](../architecture/overview.md). Este documento é só a sequência de
trabalho e o que cada etapa entrega.

---

## Roster — 43 skills

**Fluxo (5)** `anvil-grill` ← grill-with-docs · `anvil-to-spec` ·
`anvil-to-tickets` · `anvil-implement` · `anvil-code-review`

**Deps trazidas (3)** `anvil-grilling` · `anvil-domain-modeling` ·
`anvil-codebase-design` — sem elas, `grill-with-docs` e `grill-me` são uma linha
delegando para `grilling`, e viram no-op.

**Extras (12)** `anvil-wayfinder` · `anvil-prototype` · `anvil-research` ·
`anvil-diagnose` · `anvil-wizard` · `anvil-tdd` · `anvil-grill-me` ·
`anvil-handoff` · `anvil-teach` · `anvil-wait-what` ·
`anvil-writing-for-agents` · `anvil-to-questionnaire`

**Setup (1)** `anvil-setup` ← setup-matt-pocock-skills, com o seed
`issue-tracker-anvil.md`

**pstack (5)** `anvil-unslop` · `anvil-how` · `anvil-architect` · `anvil-arena` ·
`anvil-poteto`

**UI (7)** `anvil-ui-hallmark` · `-taste` · `-redesign` · `-brutalist` ·
`-minimalist` · `-soft` · `-stitch`

**Autorais (10)** `anvil-docs` · `anvil-stack-payload` · `anvil-ui` (roteador) ·
`anvil-boot` · `anvil-update` · `anvil-bench` · `tea-commit` · `tea-open-pr` ·
`tea-open-fast-pr` · `tea-prune-branches`

### Fora do roster, e por quê

- **`why`** (pstack, 13 arq) — amarrado a MCPs corporativos: Datadog, Linear,
  Notion, Sentry, Slack.
- **`interrogate`** (pstack) — sobrepõe `code-review` e o cross-judge do `arena`.
- **`poteto-mode` completo** — 47 arq com `~/.cursor/`, `AskQuestion`, `/loop`,
  dependência cross-plugin do `cursor-team-kit`, Bun e Graphite. Entra o roteador
  mais 7 playbooks: bug-fix, feature, refactoring, investigation, shipping,
  session-pickup, pause-safely.

---

## Fases

### Fase 0 — Base ✅ `205e883`

- Submodules `references/hallmark` (`13ac0ec`) e `references/taste` (`ccbc156`).
- **Incógnita resolvida:** os presets do taste são pequenos — brutalist 92 l,
  minimalist 85, soft 98, redesign 178, stitch 184 (2 arq). As destilações do
  mosk (84/77/89/127/135) eram ports quase literais. **Vendorizar inteiro.**
- `anvil-boot` e `anvil-update` viraram stubs declarando o contrato. O boot
  delegava para `../../mosk/tasks/boot.md`, inexistente; um rename por `sed`
  produziria arquivo plausível apontando para scripts que não existem.
- `tea-open-pr` e `tea-open-fast-pr` sem menção a MOSK.
- **Adiantado da Fase 6:** a seção de idioma do `claude_boot.md`, mais a ordem de
  ler `.claude/rules/` antes de agir e a regra de glosar todo id na primeira
  menção. Já estava decidido e é o arquivo sempre carregado.
- **Imprevisto:** havia um `README.md` na raiz com a versão anterior dos fluxos,
  ainda com `tasks.md`, `T001`, `stories/` e `spec-meta.yaml`. Reescrito antes do
  commit; teria gravado no repositório os quatro contrabandos que a auditoria
  removeu.

### Fase 1 — `anvil-docs`

Quatro verbos, cobrindo só o que o modelo do Matt não tem:

| verbo | o que faz | quem chama |
|---|---|---|
| `scaffold` | monta a árvore de domínios com README por pasta | `anvil-boot` |
| `adopt` | brownfield: lê o `docs/` existente e realoca | `anvil-boot`, ao achar não-conforme |
| `index` | regenera `docs/index.md` | as skills, em silêncio |
| `archive` | spec fechada: promove artefatos, move para `archive/` | o usuário |

Mais `STACK-CONTRACT.md` (as 6 capacidades), o `validate.sh` reduzido a
`ship-ready` + `docs-paths` com o subset de `common.sh` inlinado, e o
`guard-spec-merge.sh` lendo `Status:`.

O `adopt` recupera `migrate-install.md` (113 l) + `post-migration-organize.md`
(200 l) — as únicas 313 linhas que cobrem brownfield, que eu havia dado como
mortas. Guardrails literais do mosk: nunca sobrescreve · nunca deleta o original
sem dizer · o padrão é mover · mostra o plano inteiro antes de tocar em nada.

### Fase 2 — `anvil-stack-payload`

Reorganizar a skill já presente nas três camadas do
[adr-0006](../architecture/adr/adr-0006-stack-como-camada-propria.md): as 3
ciladas e a fronteira de edição para `RULE.md`; enxugar o `SKILL.md` de 409 para
~120 l mantendo a tabela roteadora; trazer starter, scripts e INV-1..6 do mosk
para `bench/`.

**Pendência que precisa ser resolvida aqui:** identificar a origem upstream da
skill e registrá-la no manifesto. Sem origem rastreável ela é autoral e fica fora
do sync — e isso tem que ficar explícito.

### Fase 3 — A máquina

`anvil-skills.yaml` na raiz; `anvil-sync/` com `SKILL.md` (julgamento),
`ADAPT-RULES.md` (catálogo) e `scripts/vendor-sync.sh` — `status` · `pull` ·
`vendor` · `update` · `verify`.

`verify` reprova em: `name:` ≠ diretório · link relativo quebrado · skill
referenciada inexistente · token da denylist (`~/.cursor`, `cursor-team-kit`,
`mosk`, slugs de modelo) · caminho relativo cruzando fronteira de skill. Pega
exatamente os bugs que a Fase 0 corrigiu à mão.

Script justificado como geração em lote de arquivos derivados; o julgamento fica
na skill.

### Fase 4 — Vendorizar, em lotes que exercitam a máquina

1. `anvil-unslop` — zero deps, valida o caminho feliz
2. `anvil-setup` + fluxo + deps (9) — exercita `add` e `docs-remap`
3. Extras (12)
4. pstack (5) — exercita `decursor`
5. UI (7) + o roteador

### Fase 5 — `anvil-bench`

Sem persona, com INV-1..6 (em `anvil-stack-payload/bench/`) e `loop-until-green`
com teto de 3 tentativas. O build loop chama as skills novas: `anvil-grill` (só
negócio) → `anvil-to-spec` → `anvil-to-tickets` → `anvil-implement` + `anvil-tdd`
→ `anvil-code-review` → gate.

Único lugar com `gate.yaml`, `quality_score` e `score_history`. O que continua
específico do bench é a ausência de jargão: nunca dizer "porta", "container",
"migration" ou "commit" para o usuário leigo.

### Fase 6 — `anvil-boot` e `anvil-update`

**boot** — injeta `claude_boot.md` entre `<!-- ANVIL:DIRECTIVES:START/END -->`,
gera as rules, chama `scaffold`/`adopt` e `anvil-setup`, detecta stack e
**propõe** a rule aguardando aprovação, registra o hook e confirma que dispara,
gera o índice.

**update** — reset + `degit rogerznts/anvil/anvil`, `reset-install.sh` rodado a
partir do `$TMP` porque o script apaga o diretório onde vive, dry-run
obrigatório, órfãos calculados pelo `anvil.lock`, protegidos `.claude/rules`,
`settings.json`, `docs`, `CLAUDE.md`.

---

## Verificação

1. `vendor-sync.sh verify` limpo em todo o payload.
2. **Prova do merge 3-way** — apontar o pin de `anvil-to-spec` para um commit
   antigo, rodar `update`, conferir que traz o diff upstream sem conflito. A
   skill não foi modificada, então o merge tem que ser trivial. Sem isso a
   máquina está descrita, não provada.
3. `npx degit rogerznts/anvil/anvil /tmp/anvil-smoke` — as 43 skills carregam e
   nenhuma aponta para arquivo inexistente.
4. `/anvil-boot` num projeto Payload descartável — bloco delimitado no
   `CLAUDE.md`, rules preenchidas, `docs/agents/issue-tracker.md` no dialeto
   anvil, rule de stack **proposta e não escrita** sem aprovação.
5. **Ponta a ponta** — (a) artefatos em `docs/specs/{NNN}-{tipo}-{nome}/` **sem
   que nenhuma skill saiba desse caminho por dentro**, a prova da tese; (b) o
   `issues/` no formato do Matt, com `Blocked by` e `Status`, sem nenhum
   `tasks.md`; (c) conteúdo em pt-BR com as skills em inglês; (d) dois
   `new-spec.sh` simultâneos nunca pegam o mesmo número; (e) o hook barra o merge
   com ticket sem `Status: resolved`.
6. **`adopt` num `docs/` bagunçado de mentira** — com monolito, ticket órfão e
   arquivo ambíguo, exercitando os três caminhos. É a peça mais perigosa do
   toolkit e a que menos se testa sozinha.
7. **Roteador de UI** — três pedidos despacham para redesign, taste e hallmark, e
   nunca dois ao mesmo tempo.
8. **Camada de stack** — `overrideAccess: false` aparece sem ninguém ter aberto o
   `reference/QUERIES.md`.

---

## O corte do core do mosk

252 arquivos / 2,2 MB → ~11 arquivos reais e 2 blobs.

### Morre — com evidência

| O quê | Por quê |
|---|---|
| `schemas/*.json` (3) | `grep -rn "schemas/"` em todo o `.claude/` retorna só as linhas `$id` dentro dos próprios schemas. `validate.sh` tem zero ocorrências de `schema.json`. Código morto |
| `scripts/common.sh` (559 l) | 15 funções, 6 chamadas. `create-new-feature` usa **1**, `validate` usa **5**, e os três `payload-*.sh` fazem `source` e usam **zero** |
| `scripts/sync.sh` (595 l) | Gerava wrapper de skill a partir de agente. Não há mais agentes |
| `pipeline.yaml` (378 l) · `phase-transition-contract.md` (91 l) · `qa-gate-tmpl.yaml` · `spec-meta-tmpl.yaml` · `tasks-template.md` (251 l) | Máquina de fase e artefatos SpecKit — [adr-0003](../architecture/adr/adr-0003-sem-maquina-de-fases.md) |
| `tasks/` — 40 de 49 | Substituídas pelas skills vendorizadas |
| `templates/` — 28 | Os `*-tmpl.yaml` de PRD, architecture, story e brief existiam para as personas. `to-spec` e `to-tickets` carregam seus templates inline |
| `checklists/` (6) | Insumo do `execute-checklist` das personas. `code-review` traz o próprio baseline: 12 code smells do Fowler |
| `data/` — 14 | Fixtures e referências de task morta |

### Sobrevive — e para onde vai

| Arquivo | Linhas | Dono |
|---|---|---|
| `project-rule-tmpl.md`, só a seção de organização documental | 380 → ~120 | `anvil-docs` |
| `docs-index-tmpl.md` | 27 | `anvil-docs` |
| `migrate-install.md` + `post-migration-organize.md` | 313 | `anvil-docs` (verbo `adopt`) |
| `validate.sh` — `ship-ready` lendo `Status:` + `docs-paths` | 600 → ~150 | `anvil-docs` |
| `guard-spec-merge.sh` | — | `anvil-docs` |
| `claude_boot.md` + R1 do `output-contract.md` | 69 + 193 | `anvil-boot` ✅ |
| `create-new-feature.sh` — reserva o número atomicamente no `origin` num ref imutável `refs/spec-numbers/<NNN>`; corrida contra outro processo no remoto, coisa que prompt nenhum faz | 575 | `anvil-to-spec` |
| `reset-install.sh` — calcula órfãos; `degit --force` sobrescreve mas nunca apaga | 240 | `anvil-update` |
| `payload-rule-tmpl.md` + `payload-starter/` + 3 `.sh` | 77 l + 23 arq + 737 l | `anvil-stack-payload/bench/` |
| `qa-evidence-contract.md` — `quality_score = 100 − 20×FAIL − 10×CONCERNS`, só faz sentido havendo loop | 58 | `anvil-bench` |

---

## Em aberto

**`anvil-arena` e a premissa multi-modelo.** O `pstack/arena` pressupõe
candidatos de famílias diferentes — `gpt-5.6`, `grok-4.6`, `claude-*` — via o
parâmetro `model` do Task. O Claude Code só endereça modelos Claude, então a
premissa degrada para N candidatos do mesmo modelo. Vendorizar com variantes
Claude e uma nota de que o valor migra de "diversidade de modelo" para
"cross-judge". Se não se sustentar na prática, `anvil-arena` sai do roster sem
afetar mais nada — só `anvil-architect` a referencia.

**Origem da skill `payload`.** Ver Fase 2.
