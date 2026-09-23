# 05: Vocabulário e manual no omp

**What to build:** No omp, as skills vendorizadas rodam sem adaptação, e o operador tem um manual da camada. A camada ganha a rule `anvil-harness`, curta e sempre aplicada, que traduz o vocabulário do Claude Code para as primitivas do omp, e a skill `anvil-omp`, com trava de invocação, que explica a camada.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] A rule tem `alwaysApply: true` e só o mapeamento: "Skill tool" e `/anvil-x` dentro de uma skill → ler a skill por `skill://`; "sub-agent" e "Task" → tool `task`, com `scout` quando a skill pede só leitura; `AskUserQuestion` → `ask`.
- [ ] A `anvil-omp` fica em `.omp/skills/`, com trava de invocação, e diz: o que é a camada, como a detecção decide, os comandos `/skill:anvil-plan`, `/skill:anvil-run` e `/skill:anvil-browser-qa`, o que continua manual no Claude Code e no Codex, os limites — `eval` escapa da guarda, frontier em série, `task` sem modelo por chamada — e como remover a camada à mão.
- [ ] As duas peças entram no lock como `omp:` e saem como órfãs quando retiradas.
- [ ] Numa sessão do omp, uma skill vendorizada que manda "Call the Skill tool" ou abrir "sub-agent" é resolvida com `skill://` e `task`.
- [ ] No Claude Code e no Codex, a lista de skills não muda.
- [ ] O `verify` sai limpo.
