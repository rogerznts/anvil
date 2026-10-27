# 02: A skill aparece ligada na máquina e listada no README

**What to build:** Com a skill no payload, ela entra no roster do `dev-link.sh`, de modo que nesta máquina apareça ligada em `~/.claude/skills/` e no espelho `~/.agents/skills/` que o omp lê, e o README a lista na tabela de skills com a origem `cloudflare`, com a Cloudflare entre os upstreams. Nenhuma mudança na camada omp nem no `anvil-update`. Ver a spec, "Implementation Decisions".

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=0a8bd42a4db1c8e623103de3b1f5c16d8749511f; scope=full; verdict=pass; p1=none

- [x] `anvil-security-audit` está na lista `ROSTER` do `dev-link.sh`.
- [x] Depois de `bash .claude/skills/anvil-sync/scripts/dev-link.sh`, `~/.claude/skills/anvil-security-audit` e `~/.agents/skills/anvil-security-audit` são symlinks para `anvil/.claude/skills/anvil-security-audit`.
- [x] O README lista `anvil-security-audit` na tabela de skills, com o que ela faz e a origem `cloudflare`, e cita a Cloudflare onde lista os upstreams.
- [x] Nada no README, nas skills ou nos docs promete que a auditoria grava dentro do repositório auditado.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Implementação · o `dev-link.sh` foi exercitado com `HOME` temporário, a partir da worktree isolada desta execução: os dois symlinks, em `.claude/skills` e `.agents/skills`, saem apontando para `anvil/.claude/skills/anvil-security-audit`. O `HOME` real não foi tocado, porque ligar a partir da worktree apontaria a máquina para uma cópia descartável; nesta máquina, `~/.claude/skills/anvil-research` hoje é diretório real, da instalação publicada, e o `dev-link` pula diretório real. A ligação de verdade é rodar o `dev-link.sh` do repositório principal.
- Implementação · `docs/architecture/overview.md` dizia "35 skills de cinco repositórios", como o README; os dois passam a 36 de seis. A tabela de medição do topo do README (`stats`, datada de 2026-09-25) ficou como está: é medição datada, e refazê-la é rodar o `stats` de novo.
- Review round=1 · P2 (Standards): o fato "o modo guidance não escreve arquivo nem roda as seis fases sem pedido explícito" e o caminho de saída da auditoria ficam escritos em três lugares — comentário do `dev-link.sh`, README e ADR-0015 — sem nada que force a sincronia — se o upstream mudar o padrão da skill, os três precisam ser editados à mão e um deles pode ficar mentindo.
- Review round=1 · P3 (Standards): na árvore de `references/` do README, `security-audit-skill/` repete o respiro de dois espaços de `payload-skills/` e não alinha com as entradas curtas — inconsistência de forma pré-existente, sem efeito de comportamento.
