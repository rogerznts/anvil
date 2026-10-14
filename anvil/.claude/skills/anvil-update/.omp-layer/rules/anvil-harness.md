---
description: "Vocabulário do Claude Code nas skills do anvil, traduzido para as primitivas do omp."
alwaysApply: true
---

# Vocabulário das skills no omp

As skills e as diretivas do anvil foram escritas para o Claude Code. No omp, leia
assim o que elas mandam fazer:

- "Skill tool", "Call the Skill tool with X" e `/anvil-x` citado dentro de uma
  skill ou das diretivas: leia a skill com o tool `read` em `skill://X` e siga-a.
  Vale para a cauda de roteamento das diretivas: invocar o `anvil-next` é ler
  `skill://anvil-next` e seguir o formato dele.
- "sub-agent", "subagent", "Task" e "Agent": o tool `task`. Quando a skill pede só
  leitura, como achar um fato, explorar ou `readonly`, use o agente `scout`.
- `AskUserQuestion`: o tool `ask`.
- `.claude/rules/*.md`, que o Claude Code carrega sozinho e o omp não: antes da
  primeira resposta da sessão, inclusive quando ela começa por `/skill:`, leia
  cada arquivo com `read`. É deles que vem o idioma de comunicação.
