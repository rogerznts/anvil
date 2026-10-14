# 05: Migração de projeto antigo

**What to build:** Num projeto instalado do jeito antigo, o `/anvil-update` ou o `/anvil-boot` rodado nele migra o projeto na mesma execução: a cópia local do toolkit sai e o que é do usuário fica, sem limpeza à mão. Nada velho sombreia a instalação de usuário, nem no Claude Code nem no omp. A remoção passa por dry-run e aprovação próprios, e o diff fica para o usuário revisar e commitar.

**Blocked by:** 02, 03, 04

**Status:** resolved

- [x] Com lock no projeto, a migração remove:
  - as skills e os agentes listados no lock;
  - o próprio lock;
  - os symlinks do espelho `.agents/skills` com nome de skill do payload;
  - os arquivos de `.omp/` listados em linhas `omp:`;
  - a entrada do hook da guarda nas settings do projeto;
  - a cópia do script da guarda.
- [x] A migração remove do `CLAUDE.md` do projeto só o bloco entre os marcadores `ANVIL:DIRECTIVES`. O resto do arquivo fica byte a byte.
- [x] Sem lock no projeto, a migração mostra as skills e os agentes presentes e pergunta quais não vieram do anvil antes de apagar qualquer coisa.
- [x] Ficam intocados rules, perfis, `docs/`, settings fora da entrada do hook e skill, agente e arquivo de `.omp/` escritos pelo usuário.
- [x] A migração exige árvore limpa no projeto, passa por dry-run, espera aprovação e nunca commita.
- [x] O update e o boot rodados no projeto avisam quando um perfil de `docs/agents/` cita script pelo caminho da instalação por projeto, e apontam o boot.
- [x] A migração cuida de um projeto por vez, o projeto onde roda, e não varre outros diretórios.
- [x] Cenário em `workspace/` com `HOME` temporário e um projeto-fixture antigo com lock. Pelo update, tudo que o lock lista sai do projeto. Rule, perfil, `docs/`, `CLAUDE.md` fora do bloco e skill do usuário ficam, e o `git status` mostra só a remoção.
- [x] O mesmo fixture migrado pelo boot chega ao mesmo estado.
- [x] Cenário com projeto-fixture antigo sem lock: nada é apagado antes da resposta sobre o que não veio do anvil.
- [x] Cenário com perfil que cita o caminho antigo: o aviso aparece.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Cenário: `workspace/41-legacy-migration/s1.sh`, 48 checks, todos passando. `HOME` temporário por caso. O projeto-fixture antigo é montado pelo `reset-install.sh` de `dd274b2` — o último que instalava no projeto, com `--to` —, com o omp no PATH e um agente a mais no payload, para o lock ter linhas `skill:`, `agent:` e `omp:`; mais o bloco no topo do `CLAUDE.md` e a guarda com o hook, como os passos 2 e 8 do boot antigo os deixavam, e coisas do usuário em `.claude/`, `.omp/`, `.agents/skills/` e `docs/`. Os comandos saem dos blocos do `SKILL.md` do update e do boot. O update roda o reset do usuário e depois a migração; o boot roda numa máquina sem instalação, instala e migra. As duas árvores finais e os dois `git status` saem iguais, e `git diff --numstat` não tem linha acrescentada. Um mutante sem a guarda de `HOME` derruba dois checks.
- A migração é o `anvil-update/scripts/migrate-project.sh`, chamado pelo passo 5 novo do update (da cópia em `$TMP`) e pelo passo 2 do boot (da instalação de usuário). Sem lock e sem resposta, sai com código 3 e não apaga nada, nem na execução; a resposta volta em `--keep-skills` e `--keep-agents`, e o resto sai. Sem lock não há linha `omp:`, e `.omp/` fica — a camada omp por projeto só existia com lock.
- Além dos critérios, para não deixar entulho nem estragar o que é do usuário: o `CLAUDE.md` que só tinha o bloco sai inteiro (o boot antigo o criava assim); o `.claude/settings.json` que só tinha a entrada da guarda sai inteiro, e o que tem mais conteúdo é regravado pelo `python3` com indentação de 2 espaços, como no ticket 04; item cujo caminho passa por diretório que é symlink não é apagado; rodada em `HOME` ou dentro de `~/.claude`, `~/.agents` ou `~/.omp`, a migração não faz nada, porque `~/.claude/CLAUDE.md` tem o bloco da instalação de usuário.
- O `/anvil-update` de uma instalação antiga, que ainda chama o reset novo com `--to .`, recebe agora uma mensagem que aponta o `SKILL.md` do payload baixado, que instala no usuário e migra o projeto. O update antigo em si não muda: ele está no projeto, e o anvil não o alcança.
- O aviso de perfil acusa a linha que cita `.claude/skills/<skill>/scripts/` ou `.claude/hooks/guard-spec-merge.sh` relativos ao projeto; `~/.claude/` e `$HOME/.claude/` não contam. Ele sai do mesmo script, em qualquer projeto, migrado ou não, e o update e o boot o mostram no dry-run da migração.
- Não migrado neste ticket: este repositório ainda tem `.claude/hooks/guard-spec-merge.sh`, o hook dele no `.claude/settings.json`, os symlinks de `.claude/skills/anvil-*` do `dev-link` e o bloco de diretivas no `CLAUDE.md`, que aqui é instrução do repositório. Rodar a migração aqui tiraria tudo isso; quem decide é o ticket 06, que muda o `dev-link`, ou o operador.
- Não pedido e não feito: o update não tira mais o bloco `ANVIL:INSTALLED` do `.gitignore` do projeto, como o ticket 03 registrou; só o passo 9 do boot o tira. Num projeto em que o `.gitignore` ignora `.claude/skills/`, a remoção das skills não aparece no `git status`.
