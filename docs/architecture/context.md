# anvil

Toolkit de skills para Claude Code, curadorizado a partir de repositórios
upstream e distribuído a projetos por cópia.

## Language

### Toolkit e curadoria

**Payload**:
O conjunto de skills e agentes que o anvil copia para um projeto.
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

### Equipe

**Equipe**:
O Leader e os papéis que ele despacha. Existe só enquanto a skill de equipe roda.
_Avoid_: time, squad, agent team

**Leader**:
O papel que coordena a equipe e o único que conversa com o usuário.
_Avoid_: orquestrador, coordenador, agente principal

**Papel**:
Especialização de equipe — PO, Architect, Analyst, Designer, Dev, Tester ou
Review — que o Leader despacha.
_Avoid_: persona, agente

**Mission Control**:
Bloco de notas do Leader com anotações objetivas de uma feature grande. Nunca é
fonte de estado.
_Avoid_: painel, estado global, status

**Frontier**:
Os tickets cujos bloqueadores já estão todos resolvidos.
_Avoid_: fila, backlog, próximos
