# ADR-0007 — Equipe por papel, coordenada por agent teams

- Status: aceito
- Data: 2026-09-12
- Contexto: o anvil volta a distribuir agentes, e o [ADR-0003](./adr-0003-sem-maquina-de-fases.md) registrou o fim dos agentes-persona. Este ADR o complementa; não o revoga.

## Contexto

Uma equipe de sete papéis mais um Leader, operada no Maestri, funciona: os papéis
conversam entre si, e os gates de Tester e Review chegam ao Leader
independentemente do Dev. Sem o Maestri, não havia como montá-la.

O ADR-0003 abandonou as personas do mosk porque **elas não se falavam**. O disco
era a fronteira de estado entre elas, e o `current_phase` existia para costurá-las.
O problema não era ter papéis; era coordená-los pelo disco.

O que o Claude Code oferece, medido na versão 2.1.270:

- subagente despachado pela sessão principal, com retorno a ela;
- subagente despachando subagente — funciona, mas **não está documentado**;
- conversa direta entre agentes só em *agent teams*, recurso **experimental**
  ligado por `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Testado: uma mensagem saiu
  de um agente e chegou a outro sem passar pela sessão principal.

As skills do fluxo carregavam a trava de invocação e não podiam ser despachadas
por agente nenhum. A regra `invocable` removeu a trava das sete que a equipe usa.

## Decisão

**O Leader é a skill `anvil-team`**, carregada na sessão principal — a única que
conversa com o usuário. **Os sete papéis são agentes** `anvil-team-{papel}`,
despachados só por ela.

**A coordenação é viva, por agent teams, e não pelo disco.** A `anvil-team` exige
o recurso: sem ele, para e mostra a configuração que falta. Não há modo degradado,
e o boot não liga o recurso.

**O estado continua sendo lido do disco**, como o ADR-0003 decidiu. A frontier sai
dos tickets. O Mission Control é bloco de notas do Leader dentro da spec: não tem
fase, não tem coluna de status, e nenhuma skill ou hook o lê como fonte de estado.

## Alternativas descartadas

- **Despachar por capacidade, sem papel**, como `anvil-arena` e
  `anvil-code-review` já fazem. Não preserva os gates independentes que fazem a
  equipe do Maestri funcionar.
- **Estrela sem agent teams**, ou estrela como fallback. Seriam dois protocolos, e
  o de reserva nunca seria exercitado.
- **O boot ligar o recurso no `settings.json` do projeto.** Deixaria um recurso
  experimental ativo em toda sessão daquele projeto.
- **Codex.** Só entraria via `Bash`, sem estado, sem retorno estruturado e sem
  Skill tool.

## Consequências

**A favor.** A equipe roda sem Maestri; os papéis se falam; Tester e Review
continuam sendo gates que o autor não controla.

**Contra.** A `anvil-team` depende de um recurso experimental que pode mudar entre
versões, e de um aninhamento de subagentes que foi medido, não documentado. As duas
premissas precisam ser reverificadas a cada versão do Claude Code.

**O payload passa a instalar agentes.** O lock ganha linhas `agent:`, o
`reset-install.sh` ganha um laço por arquivo, e o bloco de gitignore gerado do lock
cobre `.claude/skills/` e `.claude/agents/`. O boot deixa de apagar
`.claude/agents/` inteiro na migração do mosk e remove só as personas dele.

**Continua valendo do ADR-0003:** não há máquina de fases, não há `current_phase`,
e o `pipeline.yaml` continua morto.
