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

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Idioma

A fronteira é uma só:

- **pt-BR** — a conversa com o usuário e **toda documentação gerada**: specs,
  tickets, ADRs, glossário, relatórios de revisão, `docs/index.md`.
- **Inglês** — código: identificadores, comandos, caminhos, nomes de arquivo,
  chaves de YAML e mensagens de commit.

Isso vale **independentemente do idioma das skills**, que são escritas em inglês
porque vêm de repositórios upstream e não são traduzidas. Uma skill em inglês
produz documentação em pt-BR; é a regra que decide o idioma da saída, não o
idioma do arquivo que a produz.

Quando as regras do projeto definirem outro idioma de comunicação, ele
substitui o pt-BR nas duas primeiras linhas. O inglês no código não muda.

## Regras do projeto

Antes de agir, leia **todos** os arquivos em `.claude/rules/*.md`. Eles são o
contexto e as regras deste projeto. Se o diretório estiver vazio ou ausente,
avise e sugira rodar `/anvil-boot`.

Skills são para **ações**. Contexto de projeto mora em rules, nunca em skill.

## Citar id sempre com a glosa

Todo identificador citado — `FR-009`, `NFR-002`, `SC-004`, `QA-1` — carrega o
que ele quer dizer na **primeira menção**:

> o `FR-009` — nenhuma regra sai antes de existir o equivalente declarativo —
> exige isso

Sem a glosa, quem lê é obrigado a abrir a spec para saber se aquilo importa.