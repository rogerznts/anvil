# 08: `anvil-team`: Mission Control, modelo por papel e dois escritores em paralelo

**What to build:** Numa feature grande, o Leader mantém um bloco de notas objetivo dentro da spec, que sobrevive entre sessões e nunca serve de estado. O usuário escolhe o modelo de cada papel nas rules do projeto. Quando dois papéis precisam escrever ao mesmo tempo, o Leader os isola em worktrees e integra o resultado antes do gate seguinte.

**Blocked by:** 06

**Status:** ready-for-agent

- [ ] O Mission Control nasce na pasta da spec, só em feature grande, criado pelo Leader.
- [ ] Seções: objetivo e resultado esperado, trabalho em execução e ownership de escrita, gates com evidência, bloqueios, decisões abertas, riscos e próximo passo. Não tem estado na frontier nem estado global, e um aviso no topo diz que ele não é fonte de estado.
- [ ] Os papéis não leem o Mission Control; recebem o contexto na delegação.
- [ ] A rule do anvil ganha a lista `team`, de papel para modelo. O Leader passa o modelo na chamada, e sem esse suporte o papel usa o modelo da sessão.
- [ ] Nenhum agente fixa modelo nem isolamento no frontmatter.
- [ ] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 08.
- [ ] O Mission Control nasce a pedido, com dois escritores em paralelo, com sessão acabando com trabalho pendente, ou quando os tickets da spec não cabem numa sessão.
- [ ] O `anvil-boot` escreve a lista `team` com os sete papéis sem modelo (cada um herda o da sessão); a rule deste repositório também.
- [ ] A integração dos worktrees é por `cherry-pick`, e depois vêm verificação e gates.
- [ ] Ponto B mede se a Skill tool enxerga as skills instaladas de dentro de um worktree (as skills são ignoradas pelo git); se não enxergar, a solução entra neste ticket.
- [ ] Ponto B: dois Devs em paralelo em worktrees, integrados no branch da spec antes do Review; um papel despachado com o modelo da rule.

## Comments

**Leader, 2026-09-13 — U4, U5 e M5:** gatilho do Mission Control ampliado com "tickets que não cabem numa
sessão" (as palavras do usuário: guia para grandes features de muitos tickets); lista `team` escrita sem
modelo, reversível; visibilidade das skills no worktree vira critério, porque sem ela um Dev isolado não
roda `anvil-implement`.

**Leader, 2026-09-13 — fase 1 do Dev** em `4b0a6cc` (o 07 está em gate nos mesmos arquivos, então a entrega foi
dividida): `anvil-team/templates/mission-control.md` literal do desenho §9 (aviso de que não é fonte de estado, sete
seções, gates em lista cronológica); `anvil-boot` escreve a lista `team` com os sete papéis sem modelo, a frase "Lidos
por" ganha a `anvil-team`, e um `anvil.md` existente sem a lista recebe proposta de acréscimo sem trocar valor;
`.claude/rules/anvil.md` deste repositório igual. `verify` limpo; nenhum agente com `model` ou `isolation`. Boot num
projeto descartável escreveu a lista vazia (US$ 0,34). **M5 medida** (US$ 0,36): o worktree de `isolation: "worktree"`
parte do HEAD do checkout principal, sem as mudanças não commitadas, em `.claude/worktrees/agent-<id>` com branch
`worktree-agent-<id>`; **a Skill tool enxerga as skills instaladas** (carregadas do checkout principal), então o
`.worktreeinclude` não é preciso; no worktree não existe `.claude/skills/`, e a linha `Protocolo:` absoluta continua
necessária; worktree com commit sobrevive ao agente e `git cherry` lista o commit.

Decisão do Leader sobre o risco levantado na M5 — `?? .claude/worktrees/` aparece no status do checkout principal, e um
`git add -A` (de `anvil-implement` ou `tea-commit` num Dev sem worktree, como o do conflito no passo 6) stagearia os
worktrees como repositório embutido: antes de abrir worktrees, o Leader acrescenta `/.claude/worktrees/` à exclusão
local do git, idempotente, sem tocar o `.gitignore` do projeto. Entra em SKILL § Paralelismo na fase 2 e no desenho §11
(Architect). A fase 2 espera o 07 resolver.
