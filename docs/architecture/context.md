# anvil

Toolkit de skills para agentes de código — Claude Code, Codex e omp —, curadorizado a
partir de repositórios upstream e instalado uma vez por usuário.

## Language

### Toolkit e curadoria

**Payload**:
O conjunto de skills e agentes que o anvil publica e instala no diretório do
usuário.
_Avoid_: pacote, distribuição

**Skill vendorizada**:
Skill copiada de um upstream, com pin e adaptações registradas.
_Avoid_: skill importada, skill de terceiro

**Skill autoral**:
Skill escrita pelo próprio anvil, sem upstream e fora do sync.
_Avoid_: skill própria, skill interna

**Adaptação**:
Modificação numa skill vendorizada que pertence a uma das regras do catálogo
fechado.
_Avoid_: customização, ajuste, patch

**Trava de invocação**:
A marca que impede qualquer modelo de disparar uma skill, deixando-a só para o
usuário.
_Avoid_: lock, bloqueio

**Lock**:
O registro do que uma instalação do anvil possui, de onde saem os órfãos.
_Avoid_: manifesto, lockfile de dependência

**Instalação de usuário**:
O toolkit instalado uma vez por usuário, no diretório dele — `~/.claude/`,
`~/.agents/skills/` e `~/.omp/agent/` —, com o lock de usuário, e válido para
todos os projetos da máquina. O projeto guarda só rules e `docs/`.
_Avoid_: instalação global, instalação do sistema

**Instalação de projeto antiga**:
O toolkit copiado dentro de um projeto, como o anvil instalava antes da instalação
de usuário: skills, agentes e lock em `.claude/`, espelho em `.agents/skills`,
camada em `.omp/`, diretivas no `CLAUDE.md` e a guarda nas settings do projeto.
Sai do projeto pela migração, quando o update ou o boot roda nele.
_Avoid_: instalação local, instalação legada

### Harness

**Harness**:
O programa que executa o agente e lê o payload: Claude Code, Codex ou omp. O
Claude Code é a referência. Só o omp automatiza o fluxo; nos outros ele é manual.
_Avoid_: runtime, executor, cliente

**Camada de harness**:
A parte do payload que só um harness lê, instalada no diretório de usuário desse
harness quando ele é detectado e mantida depois, mesmo que a máquina perca o
sinal dele.
_Avoid_: adapter, plugin, integração

**Condutor**:
Skill da camada omp que encadeia as skills do fluxo por conta do operador,
parando em cada pausa humana: `anvil-plan` no planejamento, `anvil-run` na
implementação.
_Avoid_: orquestrador, pipeline, flow

**Piloto automático**:
Skill da camada omp que, depois do entendimento confirmado no grill ou na
entrevista, leva o roteiro do planejamento ao fechamento sem pausa humana, spec
por spec, e segue com o que não depende de uma spec que não fechou sozinha:
`anvil-auto`.
_Avoid_: modo autônomo, autopilot, condutor autônomo

**Roteiro**:
A sequência de specs combinada no grill, cada uma com escopo, critério de pronto
e dependências, que o piloto automático executa. O estado de cada entrada sai do
disco.
_Avoid_: plano, plano principal, backlog

### Referências

**Upstream vendorizado**:
Repositório de origem das skills, mantido como submodule com pin e versionado.
_Avoid_: referência, fonte

**Sistema de referência**:
Sistema de terceiro em `references/`, estudado para portar algo ao projeto.
Entra passageiro, fora do git, ou versionado, com pin.
_Avoid_: upstream, referência upstream

**Destilação**:
O documento que mapeia um sistema de referência para a stack corrente, com
ponteiros verificáveis, sem implementar nada.
_Avoid_: port, análise, estudo

### Tickets

**Frontier**:
Os tickets cujos bloqueadores já estão todos resolvidos.
_Avoid_: fila, backlog, próximos
