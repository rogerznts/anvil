# 07: ADR, glossário e `project.md` da instalação por usuário

**What to build:** Quem chega ao repositório entende, pela documentação, por que o clone não traz mais o toolkit e onde cada peça mora agora. O ADR registra a decisão. O glossário passa a usar o vocabulário novo. As rules do repositório descrevem a máquina de desenvolvimento ligada ao diretório do usuário.

**Blocked by:** 03, 04, 05, 06

**Status:** ready-for-agent

- [ ] Um ADR novo revoga o ADR-0009, em que o toolkit instalado fica versionado no projeto, e emenda o ADR-0011, em que a camada omp é instalada por projeto e se mantém pelo lock do projeto. O ADR registra as consequências: o clone não traz o toolkit, não há pin de versão por projeto, e todos os projetos da máquina rodam a mesma versão.
- [ ] O ADR registra a cauda de roteamento no omp como limitação conhecida, por decisão do operador antes deste ticket: a diretiva segue entregue como rule `alwaysApply` em `~/.omp/agent/rules/`, o único caminho que alcança o omp no nível de usuário, porque ele não lê o `~/.claude/CLAUDE.md`. Os números são os do `## Comments` do ticket 03, `s2.sh` com `USER_INSTALL=1`, três execuções por caso: o idioma melhorou — rules em `English.` com pedido em pt-BR saem em inglês em 2 de 3, antes em nenhuma —, e a cauda não se sustenta — `tea-open-pr` em 0 de 3, igual a antes; `anvil-diagnose` em 0 de 3, antes 3 de 3; `diagnose-en` em 1 de 3. A user story 57 — a cauda funcionando no omp como no Claude Code — fica sem cumprimento estável no omp, e um mecanismo próprio de cauda no omp fica para fora desta spec.
- [ ] O ADR-0009 e o ADR-0011 apontam o ADR novo.
- [ ] No glossário, o **Payload** deixa de ser "o que o anvil copia para um projeto", e a **Camada de harness** deixa de ser "instalada no projeto".
- [ ] O glossário ganha **Instalação de usuário** e **Instalação de projeto antiga**.
- [ ] O `project.md` atualiza a tabela "Fonte e derivado" com os symlinks em `~/.claude`, `~/.agents/skills` e `~/.omp/agent`, e reflete o que o `dev-link` liga e desliga.
- [ ] A seção "Nunca rode `/anvil-update` aqui" passa a citar a recusa diante de instalação de desenvolvimento.
- [ ] O índice de `docs/` lista o ADR novo, e o `validate.sh docs-paths` sai limpo.
- [ ] O `vendor-sync.sh verify` sai limpo.
