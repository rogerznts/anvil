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

**HOME de desenvolvimento**:
O ambiente privado de um checkout do anvil, usado somente nas sessões abertas
explicitamente para trabalhar na fonte. A instalação publicada dos outros
projetos permanece independente.
_Avoid_: instalação dev global, sandbox dev

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

**Parada**:
A spec que o piloto automático não fecha sozinho: fica aberta no branch dela,
com o motivo e a pergunta que a destrava no relatório, e a corrente segue pelo
que não depende dela.
_Avoid_: spec travada, spec bloqueada, spec falha

**Parada no fechamento**:
A parada de uma spec já arquivada no branch que não chega ao branch base: forge
recusado, recusa do PR, guarda, conflito, conferência do merge ou PR à espera do
operador.
_Avoid_: não fecha no fechamento, parada depois do archive, parada já arquivada

### Git e forge

**Forge**:
O serviço que hospeda o remoto do projeto e recebe o PR: hoje, Gitea ou GitHub.
_Avoid_: provedor, host, plataforma

**Branch base**:
O branch de onde todo trabalho sai e para onde volta, pelo merge local ou pelo
PR: a `main` ou a `master`, ou outro que o projeto declarar.
_Avoid_: main, branch principal, trunk, branch de integração, branch estável

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

### Segurança

**Execução da auditoria**:
Uma passada completa da auditoria de segurança sobre um repositório, com os
artefatos gravados fora do que o git versiona.
_Avoid_: scan, pentest, run

**Registro da auditoria**:
O documento versionado que diz o que uma execução da auditoria cobriu e quantos
achados teve, por veredito e severidade, sem o caminho nem a reprodução de nenhum
achado.
_Avoid_: relatório, report, laudo

### Tickets

**Frontier**:
Os tickets cujos bloqueadores já estão todos resolvidos.
_Avoid_: fila, backlog, próximos

**Despacho interrompido**:
O despacho de um ticket ao implementer que volta sem o relatório dele: cancelado,
com erro ou sem os três campos.
_Avoid_: despacho falho, implementer morto, ticket caído

**Retomada do despacho**:
O despacho de novo, na mesma execução, de um ticket cujo despacho foi
interrompido, continuando do que ele deixou no disco.
_Avoid_: redespacho, retry, retomada (que é rodar a skill de novo)

### Verificação

**Prova**:
A execução que mostra um comportamento do toolkit acontecendo, com o vermelho
medido antes da mudança e o verde depois.
_Avoid_: teste, smoke, cenário

**Prova inválida**:
A prova cuja sessão não foi respondida pelo modelo pedido. Não conta como verde
nem como vermelho, e se repete.
_Avoid_: prova falha, prova inconclusiva

**Gate**:
A rodada da suíte inteira de um projeto, com o typecheck quando ele tem um, que
libera o commit que fecha um ticket. No bench, cada item do `gates.md` também se
chama gate: é outra coisa, o critério de pronto de um item do ledger.
_Avoid_: suíte completa, CI, e "gate" para a revisão de código

**Laço curto**:
O que um projeto roda a cada conferida durante um ticket. Enquanto a suíte
inteira cabe em ~2 min, é ela; depois disso, um comando seletivo à parte. Adia a
descoberta, nunca substitui o gate.
_Avoid_: laço (que é a revisão que não converge), teste rápido, smoke
