<!-- ANVIL:DIRECTIVES:START -->
## Diretrizes do anvil

Reduzem os erros que um LLM comete por padrão ao escrever código. Convivem com
as instruções específicas do projeto, que ficam fora deste bloco.

**Tradeoff:** these guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**Verification has a stopping criterion too, and it isn't "no findings left".** A
review is instructed to find, so on a long artefact it always finds something.
Stop when nothing that changes behaviour — or that makes a published contract
lie — is left open; everything else is a tracker line. Two rounds; the third is a
declared choice, not momentum. The project profile is `docs/agents/verification.md`.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Idioma

A fronteira é uma só:

- **Idioma de comunicação** — tudo que chega ao chat e **toda documentação
  gerada**. No chat, é toda saída, venha de onde vier: conclusão de skill,
  relatório de subagente repassado, veredito, resumo de saída de ferramenta. Na
  documentação: specs, tickets, ADRs, glossário, relatórios de revisão,
  `docs/index.md`.
- **Inglês** — código: identificadores, comandos, caminhos, nomes de arquivo,
  chaves de YAML e mensagens de commit.

O idioma de comunicação é o que as regras do projeto declaram, mesmo quando o
usuário escreve em outro idioma; sem declaração, é pt-BR. O inglês no código não
muda.

Isso vale **independentemente do idioma das skills**, que são escritas em inglês
porque vêm de repositórios upstream e não são traduzidas. Uma skill em inglês
produz chat e documentação no idioma de comunicação; é a regra que decide o
idioma da saída, não o idioma do arquivo que a produz.

- **Brief de subagente.** Todo brief leva uma linha com o idioma de saída — por
  exemplo, "Responda em pt-BR." —, inclusive quando a skill dá o brief literal em
  inglês: acrescente a linha ao despachar. Relatório que voltar em outro idioma é
  reescrito antes de chegar ao chat.
- **"Verbatim" é sobre conteúdo, não sobre idioma.** Skill que manda repassar um
  relatório "verbatim" ou "lightly cleaned" pede o achado e o formato intactos; a
  prosa sai no idioma de comunicação.
- **O que não se traduz:** a linha `Review:` e suas chaves (`round`, `sha`,
  `scope`, `verdict`, `p1`), as classes como `P1`, os cabeçalhos que outra peça
  lê, os identificadores, os comandos, os caminhos e os nomes de skill. O resto se
  traduz.
- **Idioma de artefato não vaza para o chat.** Skill que fixa o idioma de um
  artefato — o corpo de um PR, por exemplo — fixa só o artefato; o que ela diz ao
  usuário segue o idioma de comunicação.

## Regras do projeto

Antes de agir, leia **todos** os arquivos em `.claude/rules/*.md`. Eles são o
contexto e as regras deste projeto. Se o diretório estiver vazio ou ausente,
avise e sugira rodar `/anvil-boot`.

Skills são para **ações**. Contexto de projeto mora em rules, nunca em skill.

## Cauda de roteamento

Quando uma destas skills chega ao fim, com sucesso ou bloqueada, a sessão
principal invoca a skill `anvil-next` pela Skill tool, sem argumento, na mesma
resposta, depois da conclusão da skill. Invocar é carregar a skill e seguir o
formato dela; um prompt de próxima sessão escrito de memória não a substitui. O
`anvil-next` vem no payload do anvil: invoque-o mesmo quando ele não aparecer na
lista de skills do contexto, que o harness pode cortar.

- `anvil-to-spec`
- `anvil-to-tickets`
- `anvil-implement` — rodado direto na sessão; a cauda vem depois de gravada a
  linha `Review:`, seja `verdict=pass` ou `verdict=fail`
- `anvil-implement-spec`
- `anvil-browser-qa`
- `anvil-diagnose`
- `anvil-prototype`
- `anvil-docs`, só no verbo `archive`
- `anvil-open-pr`
- `anvil-open-fast-pr`

A cauda não dispara:

- dentro de subagente, inclusive dos implementers da `anvil-implement-spec`: só a
  sessão principal gera o prompt da próxima sessão;
- quando a skill para numa pergunta ao usuário: ela ainda não terminou;
- dentro de uma execução do `anvil-auto`: quem decide o próximo passo ali é o
  piloto, que termina oferecendo um grill novo.

Fora da lista — `anvil-commit`, `anvil-tdd`, `anvil-code-review` e `anvil-handoff`,
por exemplo —, o `anvil-next` roda só a pedido do usuário, e a skill termina sem
prompt nem sugestão de próxima sessão. Esta lista é o único lugar a editar para
mudar quais skills têm cauda.

## Integração na `anvil-implement-spec`

A guarda de merge bloqueia `git merge` enquanto a spec está aberta e deixa passar
o `git cherry-pick`, que é como se integra trabalho com a spec aberta. Onde o
harness não integra sozinho o trabalho dos implementers — Claude Code, Codex, ou
omp sem a isolação no modo branch —, os dois merges da skill viram:

- **passo 4**, trazer a ponta do branch de integração: o implementer faz
  `git rebase <branch da spec>` no branch dele, em vez do merge;
- **passo 5**, o merger: `git cherry-pick <base>..<branch do implementer>` no
  branch da spec, com o branch dele já rebaseado.

Dê ao branch de cada implementer um nome sem barra seguida de número, como
`impl-017-t01`. A guarda lê como branch de spec todo nome com `<tipo>/<NNN>-`,
como `feature/017-t01`, e bloquearia o merge dele. No omp com a isolação no modo
branch, o omp integra, e os dois merges acima não se aplicam.

**Worktrees pelo workz.** Num projeto com a seção `## Worktrees` no
`.claude/rules/anvil.md`, quem conduz cria o worktree de cada implementer pelo
script do anvil, que o põe na convenção do workz e roda o `provisionar:` da seção,
em vez de `git worktree add`:

```bash
printf '{"name":"impl-018-t01"}' | bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh" create
```

O stdout é só o caminho do worktree, no branch `worktree-<nome>`, a partir do
`HEAD` do checkout principal; é esse caminho que vai no brief. No **passo 9 da
`anvil-implement-spec`**, a limpeza dos worktrees, remova cada um com
`bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh" remove <caminho>`,
que também apaga o branch e libera a porta alocada. O gancho `WorktreeCreate` do
projeto faz o mesmo para o worktree que o Claude Code cria sozinho, com
`isolation: "worktree"` ou `claude --worktree`; o de subagente também sai pelo
`remove` no passo 9, porque o Claude Code não chama o `WorktreeRemove` para ele.
No omp com a isolação no modo branch, a cópia é do omp, e o brief manda rodar o
`provisionar:` na raiz dela.

## Citar id sempre com a glosa

Todo identificador citado — `FR-009`, `NFR-002`, `SC-004`, `QA-1` — carrega o
que ele quer dizer na **primeira menção**:

> o `FR-009` — nenhuma regra sai antes de existir o equivalente declarativo —
> exige isso

Sem a glosa, quem lê é obrigado a abrir a spec para saber se aquilo importa.
<!-- ANVIL:DIRECTIVES:END -->

## Agent skills

### Issue tracker

Specs e tickets versionados em `docs/specs/{NNN}-{tipo}-{nome}/`. Veja
`docs/agents/issue-tracker.md`.

### Domain docs

Single-context, sob `docs/architecture/`. Veja `docs/agents/domain.md`.
