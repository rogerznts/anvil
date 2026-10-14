# 03: `reset-install` com destino no usuário, lock de usuário e boot que garante a instalação

**What to build:** O `/anvil-update` instala o toolkit uma vez por usuário e atualiza todos os projetos da máquina de uma vez. A instalação inclui skills, agentes, lock, espelho do Codex, camada omp e diretivas. O `/anvil-boot` garante essa instalação e escreve no projeto só o que é dele: rules, perfis em `docs/agents/` e a árvore de `docs/`. O Claude Code e o omp passam a ler o anvil do diretório do usuário, e as rules continuam por projeto. A guarda de merge e a migração de projeto antigo ficam para os tickets 04 e 05.

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] O `reset-install` instala as skills e os agentes do payload em `~/.claude/skills/` e `~/.claude/agents/`, com o lock de usuário ao lado das skills e no formato de linhas de hoje (`skill:`, `agent:`, `omp:`).
- [ ] O espelho do Codex passa a ser `~/.agents/skills/`, com um symlink por skill.
- [ ] A camada omp vai para `~/.omp/agent/{skills,rules,agents,hooks/pre}`. Ela entra quando há sinal de omp, isto é, o binário `omp` no `PATH` ou o diretório `~/.omp/`, e fica quando o lock de usuário já a registra.
- [ ] As diretivas chegam ao nível de usuário a partir da mesma fonte do payload, em dois lugares. No Claude Code, como um bloco entre os marcadores `ANVIL:DIRECTIVES` no `~/.claude/CLAUDE.md`, sem tocar o conteúdo de fora do bloco. No omp, como uma rule `alwaysApply` da camada de usuário. A diretiva continua mandando ler `.claude/rules/*.md` do projeto.
- [ ] A descoberta é conferida num omp real: o payload chega pelo espelho `~/.agents/skills` sem provider ligado à mão. Se o espelho não bastar, o payload ganha symlinks em `~/.omp/agent/skills/`, e o achado é registrado em `## Comments`.
- [ ] Os órfãos são calculados pelo lock de usuário. Skill, agente e arquivo da camada omp fora do lock ficam intocados, e a colisão de nome continua destacada no dry-run.
- [ ] O dry-run continua obrigatório antes da aprovação. Como o diretório de usuário não tem git, o relato lista por nome o que será substituído, removido e preservado.
- [ ] O update roda de qualquer diretório. Fora de um projeto, só atualiza o usuário. Num projeto, continua conferindo os perfis de `docs/agents/` contra o template novo. O update nunca commita.
- [ ] O `/anvil-boot` instala no usuário quando ainda não há instalação. Quando já há, segue e aponta o `/anvil-update` para trocar de versão. Deixa de escrever o bloco de diretivas no `CLAUDE.md` do projeto. A rule de configuração que ele escreve avisa quem clona que o toolkit não vem no clone e como instalá-lo.
- [ ] Cenário em `workspace/` com `HOME` temporário e um projeto-fixture novo, sem instalação de usuário. Depois do boot, o toolkit aparece em `HOME`, o projeto recebe só rules e perfis, e o `CLAUDE.md` do projeto fica sem bloco.
- [ ] Cenário com instalação de usuário existente. A skill que saiu do payload sai de `HOME`, a skill do usuário fora do lock fica, e a colisão aparece no dry-run.
- [ ] Cenário de sinal de omp. Com sinal, a camada aparece em `HOME/.omp/agent/`. Sem sinal e sem linha no lock, a camada não aparece. Com linha no lock e sem sinal, a camada fica.
- [ ] O `vendor-sync.sh verify` sai limpo.
