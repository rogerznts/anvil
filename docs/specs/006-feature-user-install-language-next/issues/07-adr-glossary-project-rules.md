# 07: ADR, glossário e `project.md` da instalação por usuário

**What to build:** Quem chega ao repositório entende, pela documentação, por que o clone não traz mais o toolkit e onde cada peça mora agora. O ADR registra a decisão. O glossário passa a usar o vocabulário novo. As rules do repositório descrevem a máquina de desenvolvimento ligada ao diretório do usuário.

**Blocked by:** 03, 04, 05, 06

**Status:** resolved

- [x] Um ADR novo revoga o ADR-0009, em que o toolkit instalado fica versionado no projeto, e emenda o ADR-0011, em que a camada omp é instalada por projeto e se mantém pelo lock do projeto. O ADR registra as consequências: o clone não traz o toolkit, não há pin de versão por projeto, e todos os projetos da máquina rodam a mesma versão.
- [x] O ADR registra a cauda de roteamento no omp como limitação conhecida, por decisão do operador antes deste ticket: a diretiva segue entregue como rule `alwaysApply` em `~/.omp/agent/rules/`, o único caminho que alcança o omp no nível de usuário, porque ele não lê o `~/.claude/CLAUDE.md`. Os números são os do `## Comments` do ticket 03, `s2.sh` com `USER_INSTALL=1`, três execuções por caso: o idioma melhorou — rules em `English.` com pedido em pt-BR saem em inglês em 2 de 3, antes em nenhuma —, e a cauda não se sustenta — `tea-open-pr` em 0 de 3, igual a antes; `anvil-diagnose` em 0 de 3, antes 3 de 3; `diagnose-en` em 1 de 3. A user story 57 — a cauda funcionando no omp como no Claude Code — fica sem cumprimento estável no omp, e um mecanismo próprio de cauda no omp fica para fora desta spec.
- [x] O ADR-0009 e o ADR-0011 apontam o ADR novo.
- [x] No glossário, o **Payload** deixa de ser "o que o anvil copia para um projeto", e a **Camada de harness** deixa de ser "instalada no projeto".
- [x] O glossário ganha **Instalação de usuário** e **Instalação de projeto antiga**.
- [x] O `project.md` atualiza a tabela "Fonte e derivado" com os symlinks em `~/.claude`, `~/.agents/skills` e `~/.omp/agent`, e reflete o que o `dev-link` liga e desliga.
- [x] A seção "Nunca rode `/anvil-update` aqui" passa a citar a recusa diante de instalação de desenvolvimento.
- [x] O índice de `docs/` lista o ADR novo, e o `validate.sh docs-paths` sai limpo.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- O ADR novo é o `docs/architecture/adr/adr-0013-toolkit-instalado-por-usuario.md`. O `validate.sh docs-paths` e o `vendor-sync.sh verify` saem limpos.
- Fora dos critérios, por herança do ticket 03 — que deixou para os tickets 06 e 07 o `overview.md`, ainda descrevendo a instalação por projeto: a seção "Harnesses" passa a citar a instalação de usuário, a camada em `~/.omp/agent/`, a linha `omp:` do lock de usuário e o espelho `~/.agents/skills`; a seção "Idioma" diz onde a diretiva é instalada. O resto do `overview.md` não mudou.
- O `project.md` ganhou uma linha para o `.claude/settings.json` na tabela, e um parágrafo sobre o que o `dev-link` não liga — diretivas e hook da guarda de usuário —, porque sem isso a tabela não diz de onde vêm a guarda e as diretivas deste repositório. É o achado de spec do ticket 06, à espera do operador, descrito como está hoje.
