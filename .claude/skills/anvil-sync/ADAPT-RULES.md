# Catálogo de adaptações

Toda modificação numa skill vendorizada é uma destas regras, declarada no campo
`adapt:` do manifesto. **Se uma mudança não cabe em nenhuma, ela não deveria
estar sendo feita** — reveja antes de inventar uma regra nova.

O catálogo é fechado de propósito. Regra nova exige entrada aqui e um motivo.

| id | natureza | quem aplica |
|---|---|---|
| `rename` | mecânica | o script |
| `docs-remap` | julgamento | você, lendo o arquivo |
| `decursor` | julgamento | você, lendo o arquivo |
| `keep` / `strip` | declarativa | o script, pelo manifesto |

---

## `rename` — mecânica

O `name:` do frontmatter passa a casar com o nome do diretório. Só isso.

```diff
-name: to-spec
+name: anvil-to-spec
```

**A `description` fica verbatim.** É ela que faz a skill disparar no momento
certo, e quem escreveu a skill sabia o que estava fazendo. Reescrever a
description é a forma mais fácil de quebrar uma skill sem perceber.

Cross-referências entre skills adotadas também mudam, porque o nome mudou:

```diff
-Call the Skill tool with "grilling".
+Call the Skill tool with "anvil-grilling".
```

O script aplica o `name:`. As cross-referências você confere — elas variam de
forma demais para automatizar com segurança.

---

## `docs-remap` — julgamento

Só para caminho de saída **dentro de `docs/`**, e só quando o modelo de pastas do
anvil difere do que a skill assume.

| Upstream | Anvil |
|---|---|
| `CONTEXT.md` na raiz | `docs/architecture/context.md` |
| `CONTEXT-MAP.md` na raiz | `docs/architecture/context-map.md` |
| `docs/adr/` | `docs/architecture/adr/` |

**Não é para caminho que o perfil de tracker já resolve.** Antes de aplicar,
confira se a skill não delega ao `docs/agents/issue-tracker.md`. Se delega, a
adaptação já está feita — no perfil, não na skill.

Exemplos do que **não** se remapeia:

- `.scratch/<feature>/issues/` citado no `to-tickets` — está dentro de *"How
  depends on the tracker configured"*. É exemplo do perfil local padrão.
- `docs/agents/issue-tracker.md` no `code-review` — é o arquivo que a gente
  escreve, e mantemos o nome.
- O temp do SO no `handoff` — não é caminho em `docs/`, é decisão de desenho do
  autor (*"not the current workspace"*). Fora do escopo da exceção.

Hoje só `anvil-domain-modeling` precisa de verdade: 14 linhas.

---

## `decursor` — julgamento

Só para skills do `pstack`, que são escritas para o Cursor.

| Upstream | Anvil |
|---|---|
| `~/.cursor/rules/*.mdc` | `.claude/rules/*.md`, ou a config do próprio anvil |
| `~/.cursor/projects/*/agent-transcripts` | `~/.claude/projects/<slug>/` |
| `.cursor/worktrees/` | worktree do git, sem caminho fixo |
| `AskQuestion` | `AskUserQuestion` |
| frontmatter `mode` · `icon` · `color` · `reminder` | **descartar** — não existem no Claude Code |
| slugs `gpt-5.6-sol-max`, `grok-4.6-fast-xhigh`, `claude-fable-5-thinking-max` | variantes Claude |
| skill de outro plugin (`cursor-team-kit`) | remover a referência, ou apontar para a equivalente do anvil |

`disable-model-invocation: true` **é suportado** pelo Claude Code. Não mexa.

**A armadilha do `arena`.** Ele pressupõe candidatos de famílias de modelo
diferentes. O Claude Code só endereça modelos Claude, então a premissa degrada
para N candidatos do mesmo modelo. Ao adaptar, deixe explícito no arquivo que o
valor migrou de *diversidade de modelo* para *cross-judge* — senão quem ler
depois vai achar que está funcionando como o autor pensou.

---

## `keep` e `strip` — declarativas

Vivem no manifesto, e o script obedece.

**`keep`** — arquivos do anvil **dentro** de uma skill vendorizada. O sync não os
mescla, não os apaga por não existirem upstream, e não reclama deles.

```yaml
keep: [RULE.md, VENDOR.md, bench]
```

**`strip`** — arquivos do upstream deliberadamente fora. Registrados para o
update **não os re-adicionar** a cada sincronização.

```yaml
strip: [agents]                      # metadados do Codex, que não usamos
strip: [scripts, "playbooks/eval.md"]   # o que não sobreviveu do poteto-mode
```

Sem o `strip` registrado, todo update traz de volta o que você tirou, e você
tira de novo, para sempre.

---

## O que nunca é adaptação

Isto não são regras — são coisas que a gente **não faz**, e vale escrever para
não haver dúvida no calor do momento:

- **Traduzir.** As skills ficam no idioma do autor. Quem garante o pt-BR na saída
  é a regra do `claude_boot.md`, não o idioma do arquivo.
- **Enxugar.** Duplicação entre `SKILL.md` e `reference/` costuma ser desenho
  deliberado — o `SKILL.md` é a porta de entrada que evita carregar tudo.
- **Uniformizar vocabulário** entre skills adotadas. `issues/` convivendo com
  outra palavra é o preço do merge limpo.
- **Corrigir erro do upstream.** Reporte lá. A correção volta no próximo sync e
  beneficia todo mundo; corrigir aqui cria divergência num arquivo que o autor vai
  consertar de qualquer jeito. Registre no `VENDOR.md` para quem esbarrar.
