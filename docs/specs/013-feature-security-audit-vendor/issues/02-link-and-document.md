# 02: A skill aparece ligada na máquina e listada no README

**What to build:** Com a skill no payload, ela entra no roster do `dev-link.sh`, de modo que nesta máquina apareça ligada em `~/.claude/skills/` e no espelho `~/.agents/skills/` que o omp lê, e o README a lista na tabela de skills com a origem `cloudflare`, com a Cloudflare entre os upstreams. Nenhuma mudança na camada omp nem no `anvil-update`. Ver a spec, "Implementation Decisions".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] `anvil-security-audit` está na lista `ROSTER` do `dev-link.sh`.
- [ ] Depois de `bash .claude/skills/anvil-sync/scripts/dev-link.sh`, `~/.claude/skills/anvil-security-audit` e `~/.agents/skills/anvil-security-audit` são symlinks para `anvil/.claude/skills/anvil-security-audit`.
- [ ] O README lista `anvil-security-audit` na tabela de skills, com o que ela faz e a origem `cloudflare`, e cita a Cloudflare onde lista os upstreams.
- [ ] Nada no README, nas skills ou nos docs promete que a auditoria grava dentro do repositório auditado.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
