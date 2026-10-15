# 04: P3 da rodada 1 do ticket 05 da 006 vão para o acompanhamento

**What to build:** Os P3 da rodada 1 do ticket 05 da spec 006 (migração de projeto antigo) que a 007 não resolve deixam de existir só no `## Comments` de uma spec arquivada. Eles ganham uma seção da spec 006 em `docs/project/acompanhamento.md`, no formato das seções que já estão lá: origem e, em cada linha, o que acontece se ninguém mexer.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A seção da spec 006 aponta a origem: a pasta arquivada da 006 e o ticket 05.
- [ ] Uma linha por P3, cada uma com a consequência:
  - qualquer menção à guarda no settings, numa string de `permissions` por exemplo, faz o projeto contar como instalação antiga;
  - o awk de marcadores da migração repete o do `reset-install.sh`;
  - a árvore de decisão do dry-run se repete no passo 2 do boot e no passo 5 do update;
  - o `json.dump` regrava a formatação do settings inteiro;
  - o aviso de perfil acusa `/Users/<u>/.claude/...` e `"${HOME}"/.claude/...` como caminho da instalação por projeto.
- [ ] As linhas seguem a numeração `A<n>` do arquivo, a partir da próxima livre.
