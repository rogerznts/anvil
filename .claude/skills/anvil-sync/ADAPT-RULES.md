# Catálogo de adaptações

Toda modificação numa skill vendorizada é uma destas regras, declarada no campo
`adapt:` do manifesto. **Se uma mudança não cabe em nenhuma, ela não deveria
estar sendo feita** — reveja antes de inventar uma regra nova.

O catálogo é fechado de propósito. Regra nova exige entrada aqui e um motivo.

| id | natureza | quem aplica |
|---|---|---|
| `rename` | mecânica | o script |
| `invocable` | mecânica | o script |
| `docs-remap` | julgamento | você, lendo o arquivo |
| `decursor` | julgamento | você, lendo o arquivo |
| `tracker-profile` | julgamento | você, lendo o arquivo |
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

## `invocable` — mecânica

Tira `disable-model-invocation: true` do frontmatter. Só isso.

```diff
 name: anvil-to-spec
 description: "..."
-disable-model-invocation: true
```

**Por que existe.** Com a trava, só o usuário dispara a skill digitando o
comando — a Skill tool recusa qualquer modelo, inclusive um subagente. É uma
decisão deliberada do upstream, e ela serve a quem trabalha sozinho. Ela impede
a orquestração: um agente coordenador não consegue despachar `grill`,
`to-spec`, `to-tickets` ou `implement`, e o fluxo inteiro volta para as mãos do
usuário. Contornar por skill-wrapper não funciona — a recusa manda
explicitamente não replicar a skill por outro caminho.

**Aplique só no que um agente precisa despachar.** A trava é também uma proteção
contra auto-invocação: sem ela, o modelo pode disparar a skill sozinho no meio de
uma conversa. As skills que ninguém orquestra continuam travadas.

**Mecânica, e reaplicada a cada merge**, como o `rename`: um conflito no
frontmatter resolvido a favor do upstream traria a trava de volta em silêncio. O
`verify` reprova skill marcada `invocable` que ainda trave.

---

## `docs-remap` — julgamento

Só para os caminhos da tabela — glossário, mapa de contextos e ADRs —, que no
anvil moram **dentro de `docs/`**, e só quando o modelo de pastas do anvil difere
do que a skill assume. Vale para o caminho que a skill escreve e para o que ela
lê, manda ler ou descreve ao usuário: skill que procura `CONTEXT.md` na raiz não
acha o glossário do anvil, mesmo sem escrever nada.

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

Quem declara a regra está no manifesto. Hoje são cinco: o `anvil-domain-modeling`,
que escreve esses arquivos, e o `anvil-setup`, o `anvil-diagnose`, o `anvil-tdd` e o
`anvil-wait-what`, que os leem ou apontam para eles.

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

`disable-model-invocation: true` **é suportado** pelo Claude Code, e o
`decursor` não o descarta. Quem o tira é a regra `invocable`, e só nas skills
que o anvil precisa despachar por agente.

**A armadilha do `arena`.** Ele pressupõe candidatos de famílias de modelo
diferentes. O Claude Code só endereça modelos Claude, então a premissa degrada
para N candidatos do mesmo modelo. Ao adaptar, deixe explícito no arquivo que o
valor migrou de *diversidade de modelo* para *cross-judge* — senão quem ler
depois vai achar que está funcionando como o autor pensou.

---

## `tracker-profile` — julgamento

Só na skill de setup, e só para **oferecer o perfil de tracker do `anvil-docs`**.
São três linhas: a postura padrão do upstream — propor GitHub ou GitLab conforme o
`git remote` — é **substituída** por propor o perfil do anvil primeiro; a opção
entra na lista como recomendada; e o passo de escrita manda buscar o perfil no
`anvil-docs`.

```diff
-Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:
+Default posture in anvil: propose **anvil docs/specs** first. It is the layout the rest of the toolkit assumes, and the only one where specs are versioned with the code. Propose another only if the user tracks work elsewhere and wants to keep doing so.
+- **anvil docs/specs** (recommended): specs and tickets live under `docs/specs/{NNN}-{type}-{name}/`, versioned in the repo. Call the Skill tool with "anvil-docs" and use the profile it provides at `templates/issue-tracker-anvil.md`
+- **anvil docs/specs**: the profile is owned by the `anvil-docs` skill, not duplicated here. Call the Skill tool with "anvil-docs" to get it
```

**Por que existe.** O `adr-0002` — a organização documental do anvil é um perfil
de issue tracker — decide que `docs/specs/` chega aos projetos como um quarto
perfil, e não reescrevendo as skills de fluxo. O setup do upstream é quem
apresenta os perfis, então é nele que o perfil do anvil precisa aparecer.

**A perda é deliberada.** Sem a postura do upstream, o setup deixa de sugerir
GitHub ou GitLab pelo remote. As duas opções continuam na lista. Num merge em que
o upstream mexa nessa postura, a versão do anvil ganha.

**Por que não é `docs-remap`.** O `docs-remap` exclui de propósito o que o perfil
de tracker resolve. Esta regra é justamente a entrada desse perfil.

**Estreita.** O perfil mora no `anvil-docs` e não é copiado para o setup, e as
opções GitHub, GitLab, local e outro ficam verbatim. Hoje só o `anvil-setup` usa.

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
