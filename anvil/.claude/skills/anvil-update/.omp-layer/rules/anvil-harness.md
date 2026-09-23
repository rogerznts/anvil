---
description: "Vocabulário do Claude Code nas skills do anvil, traduzido para as primitivas do omp."
alwaysApply: true
---

# Vocabulário das skills no omp

As skills do anvil foram escritas para o Claude Code. No omp, leia assim o que elas
mandam fazer:

- "Skill tool", "Call the Skill tool with X" e `/anvil-x` citado dentro de uma
  skill: leia a skill com o tool `read` em `skill://X` e siga-a.
- "sub-agent", "subagent", "Task" e "Agent": o tool `task`. Quando a skill pede só
  leitura, como achar um fato, explorar ou `readonly`, use o agente `scout`.
- `AskUserQuestion`: o tool `ask`.
