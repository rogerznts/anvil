# 05: Migração de projeto antigo

**What to build:** Num projeto instalado do jeito antigo, o `/anvil-update` ou o `/anvil-boot` rodado nele migra o projeto na mesma execução: a cópia local do toolkit sai e o que é do usuário fica, sem limpeza à mão. Nada velho sombreia a instalação de usuário, nem no Claude Code nem no omp. A remoção passa por dry-run e aprovação próprios, e o diff fica para o usuário revisar e commitar.

**Blocked by:** 02, 03, 04

**Status:** ready-for-agent

- [ ] Com lock no projeto, a migração remove:
  - as skills e os agentes listados no lock;
  - o próprio lock;
  - os symlinks do espelho `.agents/skills` com nome de skill do payload;
  - os arquivos de `.omp/` listados em linhas `omp:`;
  - a entrada do hook da guarda nas settings do projeto;
  - a cópia do script da guarda.
- [ ] A migração remove do `CLAUDE.md` do projeto só o bloco entre os marcadores `ANVIL:DIRECTIVES`. O resto do arquivo fica byte a byte.
- [ ] Sem lock no projeto, a migração mostra as skills e os agentes presentes e pergunta quais não vieram do anvil antes de apagar qualquer coisa.
- [ ] Ficam intocados rules, perfis, `docs/`, settings fora da entrada do hook e skill, agente e arquivo de `.omp/` escritos pelo usuário.
- [ ] A migração exige árvore limpa no projeto, passa por dry-run, espera aprovação e nunca commita.
- [ ] O update e o boot rodados no projeto avisam quando um perfil de `docs/agents/` cita script pelo caminho da instalação por projeto, e apontam o boot.
- [ ] A migração cuida de um projeto por vez, o projeto onde roda, e não varre outros diretórios.
- [ ] Cenário em `workspace/` com `HOME` temporário e um projeto-fixture antigo com lock. Pelo update, tudo que o lock lista sai do projeto. Rule, perfil, `docs/`, `CLAUDE.md` fora do bloco e skill do usuário ficam, e o `git status` mostra só a remoção.
- [ ] O mesmo fixture migrado pelo boot chega ao mesmo estado.
- [ ] Cenário com projeto-fixture antigo sem lock: nada é apagado antes da resposta sobre o que não veio do anvil.
- [ ] Cenário com perfil que cita o caminho antigo: o aviso aparece.
- [ ] O `vendor-sync.sh verify` sai limpo.
