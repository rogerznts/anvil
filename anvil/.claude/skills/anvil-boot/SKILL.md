---
name: anvil-boot
description: "Bootstrap: prepara um projeto para o anvil — injeta as diretivas no CLAUDE.md, gera .claude/rules/, monta a árvore docs/, escreve o perfil do issue tracker e propõe a rule da stack detectada. Rode uma vez por projeto, e de novo quando a estrutura mudar bastante."
---

<!-- STATUS: stub. Implementação prevista para a Fase 6 do plano. -->

Esta skill ainda não está implementada. Ela existe no payload para reservar o
nome e o contrato; rodá-la hoje não faz nada.

Quando for implementada, o fluxo será:

1. **Diretivas** — injetar `claude_boot.md` no `CLAUDE.md` do projeto, entre
   `<!-- ANVIL:DIRECTIVES:START -->` e `<!-- ANVIL:DIRECTIVES:END -->`. Nada
   fora dos marcadores é tocado; se eles não existirem, o bloco é acrescentado
   no topo sem sobrescrever nada.
2. **Varredura** — ler a estrutura do projeto, o README, os manifestos de
   pacote, os arquivos de configuração e uma amostra representativa do código.
3. **Rules** — gerar `.claude/rules/project.md` (contexto do projeto) e
   `.claude/rules/anvil.md` (caminhos, idioma, comando de teste). Esse
   diretório é do projeto: o `/anvil-update` nunca o toca.
4. **Documentação** — chamar `anvil-docs scaffold` para montar a árvore de
   domínios, ou `anvil-docs adopt` quando já existir conteúdo fora do padrão.
5. **Issue tracker** — chamar `anvil-setup` para escrever
   `docs/agents/issue-tracker.md` no perfil anvil. É esse arquivo que faz as
   skills de fluxo (`anvil-to-spec`, `anvil-to-tickets`, `anvil-code-review`,
   `anvil-wayfinder`) publicarem em `docs/specs/` sem conhecerem esse caminho.
6. **Stack** — se a varredura encontrar uma stack conhecida (hoje, um
   `payload.config.ts`), **propor** a rule correspondente com uma linha de
   justificativa e esperar aprovação. Nunca escrever sem confirmar.
7. **Guarda de merge** — registrar o hook em `.claude/settings.json` e
   verificar que ele dispara.
8. **Índice** — chamar `anvil-docs index` para gerar `docs/index.md`.

Até lá, informe ao usuário que o bootstrap ainda não está pronto.
