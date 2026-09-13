# Forma da `anvil-team` e dos sete papéis

Desenho dos tickets 06 (Leader, Dev e Review de ponta a ponta), 07 (os outros
cinco papéis e a conversa entre papéis) e 08 (Mission Control, modelo por papel e
dois escritores em paralelo). O Dev implementa a partir daqui.

As decisões de fundo estão no
[ADR-0007](../../../architecture/adr/adr-0007-equipe-por-papel-sobre-agent-teams.md)
e na [spec](../spec.md), seção "Implementation Decisions > `anvil-team`". Este
documento não as reabre. Onde achei contradição, ela está em
[Contradições encontradas](#contradições-encontradas), com a saída que o desenho
adota até alguém decidir outra coisa.

Vocabulário do [glossário](../../../architecture/context.md): Equipe, Leader,
Papel, Mission Control, Frontier.

## Problema

A equipe do Maestri tem um protocolo que todos leem, um arquivo por papel, e o
canvas decide quem enxerga qual nota. No Claude Code não há canvas. O papel é um
agente em `.claude/agents/`, o protocolo mora dentro da skill `anvil-team`, e a
conversa passa por `Agent` e `SendMessage`. Quatro coisas tornam a forma menos
óbvia do que parece:

1. **São três leitores.** O `team-protocol.md` de origem mistura o que só o
   Leader faz (frontier, paralelismo) com o que os dois lados do fio precisam
   saber igual (delegação, verificação). Portado inteiro, o papel lê regra de
   Leader.
2. **O caminho do protocolo tem duas raízes.** O modelo resolve caminho a partir
   do cwd, a raiz do projeto, e não sabe onde mora o próprio arquivo de agente. O
   `verify` roda no payload, onde a raiz é `anvil/`. E as skills instaladas são
   ignoradas pelo git desde o ticket 04 (o gitignore gerado do lock), então **um
   worktree não tem `.claude/skills/`**.
3. **O Review não tem `Edit` nem `Write`.** Ele não consegue escrever o próprio
   finding no ticket. Isso decide quem escreve o ticket.
4. **A guarda de merge bloqueia `git merge` no branch da spec** enquanto houver
   ticket aberto (`anvil-docs/scripts/guard-spec-merge.sh`). Isso decide como o
   Leader integra worktrees.

## Uso

### O usuário abre a equipe

```text
/anvil-team          a spec sai do prefixo numérico do branch atual
/anvil-team 001      a spec 001, de qualquer branch
```

A primeira coisa que a skill roda:

```bash
printenv CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
```

Saída diferente de `1`, o Leader para e mostra isto, sem oferecer alternativa:

```text
A equipe precisa de agent teams, e ele não está ligado nesta sessão.

Ligue de um destes jeitos e abra uma sessão nova:

  só para você, em ~/.claude/settings.json
    { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }

  só nesta execução
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude

É um recurso experimental do Claude Code. O anvil não o liga por você.
```

Variável definida no `env` do `settings.json` aparece no `printenv` do `Bash`
(medido nesta sessão), então o teste cobre as duas formas. O Leader não escreve o
`settings.json`: o ADR descartou o recurso ligado por arquivo do toolkit.

Com a variável, o Leader lê o `PROTOCOL.md`, relê os tickets, calcula a frontier
e fala com o usuário:

```text
Spec 001, Equipe, destilação e sentrux

Frontier, relida dos tickets agora:
  06  anvil-team: Leader, Dev e Review de ponta a ponta   (05 resolved)
  13  guarda de merge resolve o branch alvo               (01 resolved)

Os dois escrevem em regiões separadas. Proposta: dev-06 e dev-13 em paralelo,
cada um num worktree, integrados neste branch antes do Review. Sigo?
```

### O Leader despacha, o gate devolve

```js
Agent({
  subagent_type: "anvil-team-review",
  name: "review-06",
  description: "review · ticket 06 · rodada 1",
  model: "fable",              // da lista team; sem entrada, omitido
  run_in_background: true,
  prompt: "# Delegação · review · spec 001 · ticket 06 · gate\n…"
})
```

O resultado dessa chamada **é** o veredito. A primeira linha é `APROVADO` ou
`REPROVADO`. O Dev não despachou o Review, não recebe o retorno dele e não
escreve no ticket.

### O que o papel lê, nesta ordem

1. O próprio arquivo de agente, que é o system prompt. A primeira instrução manda
   ler o protocolo.
2. `.claude/skills/anvil-team/PROTOCOL.md`, ou o caminho absoluto que a linha
   `Protocolo:` do Contexto der, quando o papel roda num worktree.
3. A delegação, que é o `prompt` da chamada.
4. A skill do campo Skills, pela Skill tool.

O papel não lê o `SKILL.md` da `anvil-team` nem o `mission-control.md`. O
protocolo proíbe; a trava de invocação só impede a Skill tool, não o `Read`.

## 1. Mapa de arquivos

```text
anvil/.claude/
├── skills/anvil-team/
│   ├── SKILL.md                    o Leader. Lido só pela sessão principal
│   ├── PROTOCOL.md                 o contrato. Lido pelo Leader e por todo papel
│   └── templates/
│       └── mission-control.md      copiado para a pasta da spec, em feature grande
└── agents/
    ├── anvil-team-po.md
    ├── anvil-team-architect.md
    ├── anvil-team-analyst.md
    ├── anvil-team-designer.md
    ├── anvil-team-dev.md
    ├── anvil-team-tester.md
    └── anvil-team-review.md
```

**O critério da partição é quem lê.** O Leader lê `SKILL.md` e `PROTOCOL.md`. Um
papel lê o próprio arquivo e `PROTOCOL.md`. Então `PROTOCOL.md` é a interseção, o
que os dois lados do fio precisam saber igual. A delegação (o que entra no papel)
e o retorno (o que sai dele) moram juntos ali, porque o Leader escreve a primeira
e lê o segundo, e o papel faz o inverso. Uma definição, dois leitores.

Não há `scripts/`. A frontier segue a definição do perfil do tracker
(`docs/agents/issue-tracker.md`, "Trabalhar a frontier"), e um script repetiria a
regex de `Status: resolved` que já mora no `validate.sh`. O template do Mission
Control fica em `templates/`, como os da `anvil-docs`: é um arquivo que se copia
literal, e o check de links do `verify` já ignora `templates/`.

### `SKILL.md`, o Leader

```yaml
---
name: anvil-team
description: "Abre uma equipe de papéis (PO, Architect, Analyst, Designer, Dev, Tester e Review) coordenada pelo Leader, que trabalha uma spec pelos tickets com gates de Tester e Review que o autor não controla. Exige agent teams ligado."
disable-model-invocation: true
---
```

A trava de invocação nasceu neste desenho, e o Leader a confirmou (U7). Todo
papel herda a Skill tool;
sem a trava, um papel poderia carregar a `anvil-team` e virar um segundo Leader, e
o modelo poderia abrir a equipe sozinho no meio de uma conversa. A user story 51,
que pede que um pedido comum não caia na equipe, fica garantida dos dois lados: a
description dos agentes e a trava da skill.

| Seção | Conteúdo |
|---|---|
| abertura | "Você é o Leader, o único que fala com o usuário." Manda ler o `PROTOCOL.md` antes do primeiro despacho, com o link relativo `[PROTOCOL.md](PROTOCOL.md)` dentro da skill |
| Pré-condição | o `printenv` e a mensagem literal de [Uso](#uso). Nenhum modo degradado |
| Abrir a spec | resolver a spec e calcular a frontier, como em [8](#8-frontier) |
| Papéis e roteamento | modelo mental, uma linha por papel; tabela situação → papel da referência; Architect antes da implementação quando a mudança mexe em módulo, contrato, estado ou fronteira; Designer para UI, e UI que muda estado põe Designer e Architect na Equipe um do outro; o Dev é dono da implementação, e não se tira de uma skill a responsabilidade interna dela; trabalho grande ou nebuloso → **sugerir ao usuário** `/anvil-wayfinder`, que tem trava; eficiência: tarefa simples é Leader e um papel |
| Despacho | parâmetros da chamada `Agent` ([5](#5-delegação)); nomes; modelo pela lista `team` ([10](#10-lista-team)); despachar ou retomar; o que o Mission Control tem e o papel precisa vai **copiado** para o Contexto; nota de que tudo nesta seção foi medido no Claude Code 2.1.270 e se reverifica por versão |
| Gates | só o Leader despacha Tester e Review como gate; rodada = chamada nova; Contexto do gate sem o resumo do autor ([6](#6-retorno-e-gates)) |
| Tickets | único escritor de `Status:` e `## Comments`; forma do registro; quando vira `resolved`; quando commitar ([8](#8-frontier)) |
| Paralelismo e integração | [11](#11-dois-escritores-em-paralelo) |
| Perguntas ao usuário | retorno `PERGUNTA` → o Leader decide se é mesmo do usuário, pergunta, e devolve a resposta por `SendMessage` **ao mesmo name**. `anvil-grill` → `anvil-to-spec` → `anvil-to-tickets` fica num `po` só, retomado a cada pergunta. Enquanto o PO faz discovery, nenhum outro papel escreve: o `new-spec.sh` troca o branch do checkout |
| Mission Control | quando criar e as regras ([9](#9-mission-control)); aponta `templates/mission-control.md` |
| Conclusão | reunir, conferir o artefato, conferir gates, expor divergências, reler tickets; responder em CONCLUÍDO / PENDENTE / BLOQUEADO / RISCO / PRÓXIMO PASSO; delegar não transfere responsabilidade; sessão acabando com trabalho aberto → atualizar o Mission Control (feature grande) ou sugerir `/anvil-handoff` ao usuário, que tem trava |

### `PROTOCOL.md`, o contrato

Primeira linha: "Escrito para o papel. O Leader lê para saber o que despachar e o
que cobrar."

| Seção | Conteúdo |
|---|---|
| A delegação | template literal dos sete campos ([5](#5-delegação)); todo contexto chega nela; `mission-control.md` é do Leader e não se lê; name fora da linha `Equipe` não se inventa |
| O retorno | a última mensagem é o retorno e chega a quem despachou; primeira linha fixa; seções; severidade de finding ([6](#6-retorno-e-gates)) |
| Gates | Tester e Review são gate só quando a delegação diz `gate`; o veredito existe só no retorno; conversa lateral esclarece finding e não muda veredito; o autor discorda na seção Divergências do próprio retorno, e a discordância não elimina o gate; **papel nunca despacha agente `anvil-team-*`**, só os subagentes que as próprias skills abrem |
| Skills | carregar a skill real pela Skill tool e seguir o `SKILL.md`, sem simular; skills primárias não são whitelist; o protocolo de uma skill vence este; skill ausente ou travada → `BLOQUEADO`, nunca instalar |
| Fontes de verdade | a ordem da referência, com `.claude/rules/` no item de regras locais e "memória de sessões anteriores, quando houver" no último; memória é histórico, não estado; o Mission Control não é fonte |
| Comunicação | `SendMessage` aos names da linha `Equipe`; `SendMessage` é ferramenta diferida dentro do agente, e se carrega com `ToolSearch` `select:SendMessage` antes do primeiro envio (medido, M3); texto comum de um agente não chega a outro; não simular a opinião de um colega que está na Equipe; o que nasceu em conversa lateral e importa (finding, repro, divergência, acordo) vai na seção Laterais do retorno; erro de entrega não se repete, vira `BLOQUEADO` |
| Ownership de escrita | um escritor por região; a Política de escrita é a fronteira; `Status:` e `## Comments` de ticket são do Leader; sobreposição descoberta no meio → parar e devolver `BLOQUEADO`, e quem escolhe a saída é o Leader; em worktree, conferir que `HEAD` contém o sha da Base antes de escrever, e não conter é `BLOQUEADO` |
| Verificação | "done" não é evidência; formas de prova da referência; provar que funciona sempre que der |
| Divergências | evidência, não hierarquia; os quatro passos da referência; o quinto é a seção Divergências do retorno |
| Perguntas e autonomia | decisão do usuário (intenção de produto, preferência, requisito ausente, trade-off de negócio, informação indisponível, ação irreversível) vira `PERGUNTA`; o que se descobre lendo, rodando, pesquisando ou perguntando a um colega não vira; trabalho reversível avança com evidência suficiente |
| Contexto | ponteiro, não cópia; não duplicar o que tem fonte canônica |

### Os agentes

Esqueleto comum. A forma se repete; o conteúdo, não.

```markdown
---
name: anvil-team-{papel}
description: "Só despachado pela skill anvil-team, dentro de uma equipe que o usuário abriu. Não delegue a este agente por conta própria: sem a delegação da anvil-team ele não tem o que fazer. Papel: {papel}."
---

# {Papel}

Antes de agir, leia `.claude/skills/anvil-team/PROTOCOL.md`, ou o caminho
absoluto que a linha Protocolo do Contexto da delegação der. O protocolo define a
delegação que você recebeu e o retorno que você deve.

{responsabilidade em uma ou duas frases}

## Skills primárias
## {seções próprias do papel}
## Relações
## Entrega
```

| Agente | Skills primárias | Seções próprias |
|---|---|---|
| `anvil-team-po` | `anvil-grill`, `anvil-to-spec`, `anvil-to-tickets`; também `anvil-grilling`, `anvil-domain-modeling`, `anvil-research`, `anvil-prototype` | Fluxo principal · Responsabilidade · Domain Modeling · Relações · Entrega |
| `anvil-team-architect` | `anvil-architect`, `anvil-how`, `anvil-arena`, `anvil-domain-modeling`, `anvil-codebase-design`, `anvil-principles`; também `anvil-prototype`, `anvil-research` | Responsabilidade · Grounding · Design · Protótipos · Relações · Entrega |
| `anvil-team-analyst` | `anvil-how`, `anvil-research`, `anvil-diagnose`, `anvil-prototype` | Responsabilidade · Método · Relações · Entrega |
| `anvil-team-designer` | `anvil-ui`, `anvil-prototype` | Responsabilidade · Grounding · Implementação · Relações · Entrega |
| `anvil-team-dev` | `anvil-implement`, `anvil-tdd`, `anvil-diagnose` | Antes de implementar · Implementação · Relações · Entrega |
| `anvil-team-tester` | `anvil-tdd`, `anvil-diagnose` | Responsabilidade · Findings · Relações · Entrega |
| `anvil-team-review` | `anvil-code-review`, com o ponto fixo que o Contexto der | Responsabilidade · Findings · Relações · Entrega |

Quatro linhas específicas que o Dev não deve perder:

- **Dev, Implementação:** "A revisão que o `anvil-implement` roda no fim é
  verificação sua. Não é o gate."
- **Dev, Antes de implementar:** forma estrutural indefinida e relevante → falar
  com o Architect se ele estiver na linha `Equipe`, senão `BLOQUEADO`; o mesmo
  com o Designer para UI; regra de produto ambígua → `PERGUNTA`.
- **Tester, Relações:** pedido de repro do autor se responde por `SendMessage` a
  ele. "Isto não é veredito" vai escrito na resposta.
- **Review, Relações:** o autor pode pedir esclarecimento de um finding, e o
  Review responde por `SendMessage`. O veredito só muda numa rodada nova do
  Leader.

Nenhum agente declara `model`, `isolation`, `background`, `skills`,
`permissionMode`, `memory` ou `maxTurns`. O que varia por despacho vai na chamada.
`skills:` pré-carregaria skill, e a única que traria o protocolo seria a própria
`anvil-team`, o texto do Leader.

## 2. Frontmatter e descriptions

A description é a mesma nos sete, trocando o rótulo final:

```yaml
description: "Só despachado pela skill anvil-team, dentro de uma equipe que o usuário abriu. Não delegue a este agente por conta própria: sem a delegação da anvil-team ele não tem o que fazer. Papel: {papel}."
```

Ela começa pela restrição, como a spec pede, e **não nomeia tarefa nenhuma, nem em
negativa**. "Não use para revisar diff" ainda contém "revisar diff" e casa com o
pedido. Revisar, implementar, testar e pesquisar ficam fora de propósito. O
`Papel: {papel}.` no fim é rótulo para a listagem de `/agents`, depois da negação.
O `name` do agente carrega a palavra do papel de qualquer jeito, e é isso que o
Ponto B do ticket 06 mede com o "revisa esse diff".

**`anvil-team-dev.md`:**

```yaml
---
name: anvil-team-dev
description: "Só despachado pela skill anvil-team, dentro de uma equipe que o usuário abriu. Não delegue a este agente por conta própria: sem a delegação da anvil-team ele não tem o que fazer. Papel: dev."
---
```

**`anvil-team-review.md`:**

```yaml
---
name: anvil-team-review
description: "Só despachado pela skill anvil-team, dentro de uma equipe que o usuário abriu. Não delegue a este agente por conta própria: sem a delegação da anvil-team ele não tem o que fazer. Papel: review."
tools: Read, Grep, Glob, Bash, Agent, Skill, SendMessage, ToolSearch
---
```

A allowlist existe para impedir edição, e continua sem `Edit` e `Write`. `Agent`
está nela porque o `anvil-code-review` abre dois subagentes; `Bash`, porque o
Review roda `git diff`, o comando de verificação e o sentrux. `SendMessage` e
`ToolSearch` entraram pela decisão U1: mensagem não edita, a conversa lateral é do
ADR-0007, e `SendMessage` é diferida dentro do agente (M3), então sem `ToolSearch`
ela não carrega. **Confira os nomes das ferramentas de leitura na versão
instalada** (M7, Ponto B do 06): nome que não existe não dá acesso a nada, e o
Review ficaria sem ler.

## 3. Como o agente chega ao protocolo

**Forma de citar.** Num arquivo de agente, caminho do payload se cita **em crase,
relativo à raiz de instalação**: `` `.claude/skills/anvil-team/PROTOCOL.md` ``. É
a única forma aceita.

| Onde | Raiz | O caminho existe porque |
|---|---|---|
| payload | `anvil/` | `anvil/.claude/skills/anvil-team/PROTOCOL.md` |
| projeto instalado | raiz do projeto, que é o cwd do agente | o degit copia `anvil/.claude/` para `.claude/` |
| este repositório | raiz do repo | o `dev-link` liga `.claude/skills/anvil-team` e cada `.claude/agents/anvil-team-*.md` (o `dev-link` de agentes é critério do ticket 05) |
| worktree | a raiz do worktree | **não resolve**: as skills instaladas são ignoradas pelo git e não vão para o worktree. O Leader põe o caminho absoluto no Contexto, tirado do diretório base que a sessão principal recebe ao carregar a skill |

Link markdown relativo (`../skills/…`) resolveria para o `verify` e não para o
modelo, que resolve a partir do cwd. Pareceria checado e quebraria em uso.

**Consequência de forma.** Arquivo de agente não cita caminho de projeto
(`docs/…`, `.claude/rules/…`, `workspace/…`). O que é do projeto chega pela
delegação. Assim todo caminho num agente é caminho do payload, e o check é total.

### Contrato com o `verify` do ticket 05

O ticket 05 (o payload instala agentes) promete reprovar "agente que cita caminho
inexistente". Para os dois lados fecharem, o check lê a forma acima:

| # | Check | Ticket |
|---|---|---|
| a | `name:` do frontmatter de `anvil/.claude/agents/X.md` é `X` | 05 |
| b | todo span em crase que começa com `.claude/` e não tem `*`, `{` nem `<`, fora de bloco cercado, existe em `anvil/{span}` | 05 |
| c | link markdown relativo (`](…)` sem `://`) num arquivo de agente é falha | 05 |
| d | todo `anvil-team-*.md` cita `` `.claude/skills/anvil-team/PROTOCOL.md` `` | 06 |
| e | todo span em crase `anvil-[a-z0-9-]+` num agente nomeia um diretório de skill ou um arquivo de agente do payload, e a skill não tem trava | 07 |
| f | tokens do Maestri (`@team-protocol`, `@anvil-skills`, `@mission-control`, `@anvil-install`, `No connection to note`) não aparecem em skill nem agente do payload | 06 |

O check (e) é a user story 53, que pede que toda skill citada pelos papéis exista;
ele pega `anvil-debug` escrito de volta e pega skill travada antes do Ponto B. O
(f) existe porque o `DENY` de hoje é de upstream vendorizado e não pega resíduo de
port. Nenhum deles briga com o check 3 atual, que só olha links dentro de
`anvil/.claude/skills`.

O Leader cruzou este contrato com os tickets (M8): cada check virou critério do
ticket indicado na tabela.

## 4. Partição do protocolo

Destinos: **SKILL** = `anvil-team/SKILL.md`, **PROT** = `anvil-team/PROTOCOL.md`,
**TPL** = `anvil-team/templates/mission-control.md`, **{papel}** =
`agents/anvil-team-{papel}.md`. "Muda" quer dizer que a intenção fica e a
mecânica do Maestri vira a do Claude Code.

### `shared/team-protocol.md`

| Seção de origem | Veredito | Destino | Motivo |
|---|---|---|---|
| abertura | muda | PROT, abertura | diz para quem foi escrito, o papel, e que o Leader o lê como a outra ponta |
| Anvil | muda | PROT § Skills | fica "carregue e siga o `SKILL.md` real"; `@anvil-skills` sai, o catálogo vivo é a lista da Skill tool |
| Anvil ausente | muda | PROT § Skills | skill ausente vira `BLOQUEADO`; o bootstrap pelo Leader sai por decisão fechada |
| Skills não são whitelists | fica | PROT § Skills | vale para o papel e para o Leader ao preencher Skills |
| Notas e visibilidade no Maestri | sai | | canvas, decisão fechada |
| Notas compartilhadas | sai | | o protocolo chega por caminho checado |
| Notas exclusivas do Leader | sai | | o que resta, "papel não lê o Mission Control", é uma linha de PROT § A delegação |
| Erros de conexão com notas | sai | | decisão fechada; o análogo, erro de entrega de `SendMessage`, é uma linha de PROT § Comunicação |
| Fontes de verdade | muda | PROT § Fontes de verdade | `.claude/rules/` entra nas regras locais; ai-memory vira "memória de sessões anteriores, quando houver"; entra "Mission Control não é fonte" |
| ai-memory | muda | PROT § Fontes de verdade | ai-memory é ferramenta de um ambiente, não do payload (contradição 6); sobra "memória é histórico, não estado" |
| Mission Control ("estado global") | muda | PROT § A delegação (uma linha) · SKILL § Mission Control | "estado global" contradiz o ADR; o papel só precisa saber que não lê |
| Comunicação | muda | PROT § Comunicação | conexão do Maestri vira `SendMessage` por name; "decisões e bloqueios chegam ao Leader" vira seções do retorno |
| Delegação, OBJECTIVE a DONE WHEN | muda | PROT § A delegação | campos em pt-BR, com os nomes da spec, como template literal; "nota acessível" sai |
| Delegação › RETURN | muda | PROT § O retorno | vira formato com primeira linha fixa |
| Ownership de escrita | muda, divide | PROT § Ownership (um escritor, sobreposição → `BLOQUEADO`) · SKILL § Paralelismo e integração (as três saídas, separar antes de serializar) | o papel obedece à fronteira; quem escolhe a saída é o Leader |
| Paralelismo | sai do protocolo | SKILL § Paralelismo e integração | papel não despacha trabalho paralelo |
| Frontier | sai do protocolo | SKILL § Abrir a spec | só o Leader inicia ticket |
| Verificação | fica | PROT § Verificação | o papel prova, o Leader cobra |
| Perguntas ao usuário | muda, divide | PROT § Perguntas e autonomia (o que é do usuário) · SKILL § Perguntas ao usuário (voltar ao mesmo name) | o papel classifica; o roteamento é do Leader |
| Divergências | fica | PROT § Divergências | o passo 5 vira a seção Divergências do retorno; entra "discordar de gate não o elimina", vinda do `dev.md` |
| Autonomia | fica | PROT § Perguntas e autonomia | comum |
| Contexto | muda, divide | PROT § Contexto (ponteiro, não cópia) · SKILL § Conclusão (continuar em outra sessão) | só o Leader atravessa sessões; `/anvil-handoff` tem trava e é sugerido ao usuário |

### `leader/leader.md`

| Seção de origem | Veredito | Destino | Motivo |
|---|---|---|---|
| abertura, "Leia @team-protocol" | muda | SKILL, abertura | sem Maestri; o protocolo por link relativo dentro da skill |
| Modelo mental | fica | SKILL § Papéis e roteamento | só quem roteia precisa |
| Anvil (mapa, `@anvil-skills`) | muda | SKILL § Despacho | o campo Skills sai da lista da Skill tool |
| Anvil ausente | sai | | bootstrap, decisão fechada |
| Notas e visibilidade, compartilhadas, exclusivas, No connection to note | sai | | canvas; sobra "extraia do Mission Control o contexto necessário", que vai para SKILL § Despacho |
| Mission Control | muda | SKILL § Mission Control · TPL | "frontier", "tickets em execução", "agentes ocupados" e "spec ativa" saem: são estado ou derivação |
| Roteamento | fica | SKILL § Papéis e roteamento | vira tabela |
| Roteamento › `anvil-wayfinder` | muda | SKILL § Papéis e roteamento | a skill tem trava: o Leader sugere `/anvil-wayfinder` ao usuário (contradição 4) |
| Fluxo de discovery | muda | SKILL § Perguntas ao usuário | retomar o mesmo `po`; nenhum escritor em paralelo durante a discovery |
| Frontier | fica | SKILL § Abrir a spec | ganha "relida a cada decisão de despacho" |
| Arquitetura, UI, Implementação | fica | SKILL § Papéis e roteamento | linhas da tabela |
| Gates independentes | muda, divide | SKILL § Gates (quem despacha, rodada, registro) · PROT § Gates (conduta) | o mecanismo é do Leader; a conduta é de todo papel, e o autor precisa conhecê-la |
| Topologia recomendada | sai | | agent teams não tem topologia; as relações naturais ficam em cada § Relações |
| Delegação | muda | SKILL § Despacho (parâmetros da chamada) · PROT § A delegação (os campos) | a chamada é só do Leader; o conteúdo é contrato |
| Eficiência | fica | SKILL § Papéis e roteamento | só quem despacha escolhe quantos |
| Conclusão | fica | SKILL § Conclusão | só o Leader declara estado |

### `agents/*.md`, linhas repetidas nos sete

| Seção de origem | Veredito | Destino | Motivo |
|---|---|---|---|
| "Você é o {papel}… responsabilidade" | fica | {papel}, abertura | é do papel |
| "Leia e siga @team-protocol" | muda | {papel}, abertura | vira a linha com o caminho em crase, que o check (d) confere |
| "Se capacidade ausente, informe o Leader; não instale nem dependa de `@anvil-install`/`@mission-control`" | sai dos sete | PROT § Skills · PROT § A delegação | comum; a referência repetia sete vezes |
| "Siga os `SKILL.md` reais e suas dependências" | sai dos sete | PROT § Skills | comum |

### Um arquivo por papel

| Origem § | Veredito | Destino | Motivo |
|---|---|---|---|
| po › Skills primárias | muda | po § Skills primárias | `anvil-to-questionnaire` sai: tem trava, e citá-la roteia para o vazio (contradição 4) |
| po › Fluxo principal, Responsabilidade, Domain Modeling | fica | po | é do PO |
| po › Relações | muda | po § Relações | "usuário, através do Leader" vira `PERGUNTA`; fica "não responda no lugar do usuário" |
| po › Entrega | muda | po § Entrega | vira o que o PO põe nas seções do retorno; "frontier inicial" sai, o Leader a deriva |
| architect › tudo | fica | architect | nomes existem e estão livres; "Relações e entrega" se divide em duas seções |
| analyst › Skills primárias | muda | analyst | `anvil-debug` → `anvil-diagnose` |
| analyst › Responsabilidade, Método, Relações | fica | analyst | é do papel |
| designer › Implementação | muda | designer | "não escreva junto com o Dev na mesma região" sai para PROT § Ownership; fica "implemente frontend quando a Política de escrita der" |
| designer › resto | fica | designer | é do papel |
| dev › Skills primárias | muda | dev | `anvil-debug` → `anvil-diagnose`; entra `anvil-implement`, que o ADR destravou para a equipe e que só o Dev usa |
| dev › Antes de implementar | muda | dev | "devolva ao PO através do Leader" vira `PERGUNTA`; papel fora da Equipe vira `BLOQUEADO` |
| dev › Implementação | fica | dev | ganha "a revisão do `anvil-implement` não é o gate" |
| dev › Ownership | sai | PROT § Ownership | duplicata literal |
| dev › Relações | muda, divide | dev § Relações · PROT § Gates | com quem conversar fica; "discordância não elimina o gate" vale para todo autor |
| tester › Skills primárias | muda | tester | `anvil-test` → `anvil-tdd`, `anvil-debug` → `anvil-diagnose` |
| tester › Independência | sai | PROT § Gates | igual à do Review |
| tester › Findings | muda | tester § Findings | os campos do finding comportamental ficam; a severidade vai para PROT § O retorno |
| review › Skills primárias | muda | review | `anvil-review` → `anvil-code-review` |
| review › Independência | sai | PROT § Gates | igual à do Tester |
| review › Findings | muda | review § Findings | os campos ficam; a escala vai para PROT § O retorno |
| tester, review › Entrega | muda | {papel} § Entrega | veredito na primeira linha; aderência por critério de aceite no Registro |

### `control/mission-control.md`

| Seção de origem | Veredito | Destino | Motivo |
|---|---|---|---|
| abertura ("painel operacional") | muda | TPL, aviso no topo | "painel" vira "bloco de notas"; o aviso diz que não é fonte de estado |
| Missão › Objetivo atual, Resultado esperado | fica | TPL § Objetivo e resultado esperado | seção da spec |
| Missão › Spec ativa | sai | | o arquivo mora na pasta da spec |
| Frontier, a tabela inteira | sai | | derivada dos tickets; a lista de seções da spec não a inclui |
| Trabalho em execução | muda | TPL § Trabalho em execução e ownership de escrita | colunas Name, Ticket, Escreve em, Worktree; "Início" e "Próximo checkpoint" saem |
| Gates, tabela com Estado `PENDENTE` | muda | TPL § Gates com evidência | a coluna Estado sai (contradição 3); vira registro cronológico que aponta o comentário do ticket |
| Bloqueios, Decisões abertas, Riscos | fica | TPL | seções da spec; "Prazo/gate" e "Probabilidade" saem |
| Estado global | sai | | decisão fechada |
| Próximo passo | fica | TPL § Próximo passo | seção da spec |
| Última atualização | sai | | o git registra quem mudou e quando |

### `control/anvil-install.md`, `shared/anvil-skills.md`, `README.md`

Tudo **sai**. O install é o bootstrap pelo Leader, fora por decisão fechada; quem
roda a `anvil-team` já tem o anvil. O catálogo de skills era placeholder, e a lista
da Skill tool é o catálogo que não envelhece; os nomes corrigidos vão para o § Skills
primárias de cada papel e o check (e) os confere. O README descrevia notas no
canvas; a menção pública da equipe é o README e o overview do anvil, no ticket 07.

**Conferência de duplicação.** Toda regra comum tem um destino só, PROT: gates,
ownership, verificação, divergências, skills, delegação, retorno. Nenhuma regra
que só o Leader aplica está em PROT: frontier, paralelismo, parâmetros da chamada,
integração, escrita no ticket, Mission Control. O que se repete nos sete agentes é
a linha-ponteiro e a description, e as duas são checadas.

## 5. Delegação

### Template literal, em PROT § A delegação

```markdown
# Delegação · {papel} · spec {NNN} · ticket {NN}[ · gate]

## Objetivo
{o resultado que deve existir, em uma ou duas frases}

## Contexto
- Spec: `docs/specs/{NNN}-{tipo}-{nome}/spec.md`
- Ticket: `docs/specs/{NNN}-{tipo}-{nome}/issues/{NN}-{slug}.md`
- Base: `{branch}` em `{sha}`
- {ADR, arquivo:linha, commit, comentário do ticket, retorno anterior; ponteiros}
- Equipe: `{name}` ({papel}, {autor|gate}), … ou "ninguém"
- Protocolo: `{caminho absoluto}`        ← só em worktree

## Skills
`{skill}`, {por quê}   |   à escolha do papel, entre as primárias

## Escopo
Dentro: {…}
Fora: {…}

## Política de escrita
{somente leitura | documentação em {caminhos} | protótipo descartável em {caminho} | código em {caminhos}}
Não toque: `docs/specs/**/issues/*.md`, o Leader escreve o ticket.
Commit: {não | sim, no branch atual | sim, no branch do worktree}

## Critério de pronto
- [ ] {observável}

## Retorno
Primeira linha: {PRONTO | APROVADO ou REPROVADO}.
Seções exigidas: {…}
```

São os sete campos da spec, com os nomes dela. O que agent teams exige entra
dentro deles, sem campo novo:

| Necessidade | Onde entra |
|---|---|
| names para `SendMessage` | linha `Equipe` do Contexto |
| ticket e base | linhas `Ticket` e `Base` do Contexto |
| worktree | `Commit:` na Política de escrita, `Protocolo:` no Contexto |
| o que o Mission Control sabe | copiado para o Contexto |
| modelo e isolamento | na chamada, não no prompt |

A delegação de um **gate** aponta intervalo de commits, ticket e comentários do
ticket. **Não leva o resumo do autor.** O gate julga o artefato, não a descrição
dele; os desvios que o autor declarou já estão no comentário que o Leader
registrou.

### Parâmetros da chamada `Agent`, em SKILL § Despacho

| Parâmetro | Valor | Regra |
|---|---|---|
| `subagent_type` | `anvil-team-{papel}` | sempre |
| `name` | `{papel}-{NN}` no trabalho de um ticket; `{papel}` fora de ticket (discovery do PO, design antes dos tickets) | sempre. Sem `name` o agente não entra no time e ninguém fala com ele |
| `description` | `{papel} · ticket {NN}[ · rodada {n}]` | sempre |
| `model` | o valor do papel na lista `team` | papel sem entrada, ou valor fora de `opus`, `fable`, `sonnet`, `haiku` → omitir, e vale o modelo da sessão |
| `isolation` | `"worktree"` | só com outro escritor ativo ao mesmo tempo. Nunca num gate |
| `run_in_background` | `true` | sempre. O Leader segue disponível para o usuário, e dois papéis vivos ao mesmo tempo é o que torna a conversa lateral possível |
| `prompt` | a delegação | sempre |

`{papel}-{NN}` e não um nome fixo por papel: dois Devs em tickets diferentes
precisam de endereços diferentes, e reusar um name substitui o agente anterior.

### Despachar ou retomar

- **Autor** (PO, Architect, Analyst, Designer, Dev) com mais trabalho no mesmo
  ticket → `SendMessage` ao name, que retoma com o contexto intacto: correção de
  finding, resposta de `PERGUNTA`, próxima pergunta do grill.
- **Gate** → sempre `Agent` novo com o mesmo name, rodada `n+1`. A rodada anterior
  está no comentário do ticket, e o Contexto aponta para ele. O veredito é sempre o
  resultado de uma chamada `Agent` do Leader, que é o caminho medido. A rodada não
  herda a conversa lateral da anterior.

A retomada do autor depende de o resultado de um turno retomado voltar ao Leader.
Medido (M2): volta.

### Tester junto com o Dev

Para o Dev pedir um repro ao Tester sem passar pelo Leader, o Tester precisa estar
vivo. Quando o ticket tem comportamento a reproduzir ou pede harness antes da
solução, o Leader despacha `tester-{NN}` junto com `dev-{NN}`, com delegação
**sem** `gate`: preparar repro e harness numa região própria, responder o autor, e
voltar `PRONTO`. Cada um aparece na linha `Equipe` do outro. O gate do Tester é
outra chamada, depois da entrega do Dev, com o mesmo name e `· gate`, e só depois
que a delegação sem gate voltou.

Quando o Tester não foi despachado, o Dev que precisa dele devolve `BLOQUEADO`, e o
Leader decide.

## 6. Retorno e gates

### Formato do retorno, em PROT § O retorno

```markdown
{PALAVRA}, {uma linha}

### Registro no ticket
**{Papel}, {AAAA-MM-DD}, {entrega | gate {Tester|Review}, rodada {n}}: {PALAVRA}.**
{critérios de aceite e findings; cada finding com id e severidade}

### Alterações
### Evidência
### Riscos
### Divergências
### Perguntas
### Laterais
```

- **Primeira linha.** Delegação comum: `PRONTO`, `BLOQUEADO` ou `PERGUNTA`.
  Delegação `gate`: `APROVADO`, `REPROVADO`, `BLOQUEADO` ou `PERGUNTA`. Aprovar com
  finding não bloqueante é `APROVADO`.
- **Severidade.** `bloqueante` · `relevante` · `sugestão` · `pergunta`. Os ids são
  os que a skill produzir; sem ids, `F1`, `F2`…
- **Finding.** Localização (`arquivo:linha`, ou passos mínimos de repro para o
  Tester), condição, impacto, correção esperada. Os campos do finding comportamental
  (esperado, observado, ambiente, determinismo) ficam no arquivo do Tester.
- **Seções.** Só as que têm conteúdo, nesta ordem. Laterais diz com quem o papel
  falou, sobre o quê, e o que ficou acertado ou em aberto.

### Por que o julgamento chega ao Leader por construção

Quatro invariantes, cada um num lugar só. O Dev não aparece em nenhum.

1. **Só o Leader despacha `anvil-team-*`** (PROT § Gates). O Dev tem `Agent`, mas
   despachar o próprio revisor é proibido, e o retorno de um revisor despachado pelo
   Dev iria ao Dev.
2. **Cada rodada de gate é uma chamada `Agent` do Leader** (SKILL § Gates), e o
   veredito é a primeira linha do resultado. É o caminho medido: agente despachado
   com `name` devolve o resultado à sessão principal, que o recebe como
   notificação de idle com o campo `result` (M1).
3. **Conversa lateral não muda veredito** (PROT § Gates). O Dev pode discutir um
   finding com o Tester; se a avaliação mudar, só uma rodada nova do Leader a
   registra. A discordância do Dev vai na seção Divergências do retorno **dele**, que
   chega ao Leader ao lado do veredito.
4. **Só o Leader escreve o ticket** (SKILL § Tickets). O Review nem poderia. Tester e
   Review em paralelo acrescentando ao mesmo `## Comments` seriam dois escritores no
   mesmo arquivo.

### Chamadas de referência

**Leader despacha o Dev no ticket 06**, um escritor, sem worktree:

```js
Agent({
  subagent_type: "anvil-team-dev",
  name: "dev-06",
  description: "dev · ticket 06",
  model: "opus",
  run_in_background: true,
  prompt: `# Delegação · dev · spec 001 · ticket 06

## Objetivo
O ticket 06 entregue no payload: a skill anvil-team (SKILL.md, PROTOCOL.md) e os agentes anvil-team-dev e anvil-team-review, com os critérios que não exigem sessão nova atendidos e commitados.

## Contexto
- Spec: \`docs/specs/001-feature-team-distill-sentrux/spec.md\`, seção "Implementation Decisions > anvil-team"
- Ticket: \`docs/specs/001-feature-team-distill-sentrux/issues/06-team-leader-dev-review.md\`
- Base: \`feature/001-team-distill-sentrux\` em \`{sha}\`
- ADR: \`docs/architecture/adr/adr-0007-equipe-por-papel-sobre-agent-teams.md\`
- Desenho: \`docs/specs/001-feature-team-distill-sentrux/architecture/team-shape.md\`
- Sistema de referência: \`references/multiagent-config/\` (passageiro; a seção 4 do desenho diz o que entra)
- Equipe: ninguém. O Review é despachado depois da sua entrega.

## Skills
\`anvil-implement\`, executa o ticket e commita no branch atual.

## Escopo
Dentro: \`anvil/.claude/skills/anvil-team/\` (sem templates/), \`anvil/.claude/agents/anvil-team-dev.md\`, \`anvil/.claude/agents/anvil-team-review.md\`, checks (d) e (f) do verify, lock regenerado.
Fora: os outros cinco papéis (07); Mission Control, lista team e worktree (08).

## Política de escrita
Código e documentação nos caminhos de "Dentro", neste checkout.
Não toque: \`docs/specs/**/issues/*.md\`, o Leader escreve o ticket.
Commit: sim, no branch atual.

## Critério de pronto
- [ ] \`bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify\` termina em \`verify: limpo\`, com a checagem de caminhos citados por agentes rodando.
- [ ] Cada critério de aceite do ticket 06 que não exige sessão nova tem evidência.
- [ ] O roteiro do Ponto B está escrito, para rodar numa sessão nova.

## Retorno
Primeira linha: PRONTO ou BLOQUEADO.
Seções exigidas: Alterações (commits), Evidência (saída do verify), Registro no ticket (desvios do desenho, se houver).`
})
```

**Leader despacha o Review depois da entrega.** O `dev-06` voltou `PRONTO` com
`{base}..{head}`. O Leader registrou a entrega no ticket e conferiu o `verify`.

```js
Agent({
  subagent_type: "anvil-team-review",
  name: "review-06",
  description: "review · ticket 06 · rodada 1",
  model: "fable",
  run_in_background: true,
  prompt: `# Delegação · review · spec 001 · ticket 06 · gate

## Objetivo
Um veredito sobre a mudança do ticket 06 contra a spec e os padrões do repositório.

## Contexto
- Spec: \`docs/specs/001-feature-team-distill-sentrux/spec.md\`, seção "Implementation Decisions > anvil-team"
- Ticket: \`docs/specs/001-feature-team-distill-sentrux/issues/06-team-leader-dev-review.md\`, com os comentários
- Base: \`feature/001-team-distill-sentrux\`; mudança em \`{base}..{head}\`
- ADR: \`docs/architecture/adr/adr-0007-equipe-por-papel-sobre-agent-teams.md\`
- Padrões: \`CLAUDE.md\` e \`.claude/rules/\`
- Equipe: \`dev-06\` (dev, autor)

## Skills
\`anvil-code-review\`, ponto fixo \`{base}\`.

## Escopo
Dentro: o diff \`{base}..{head}\` e os critérios de aceite do ticket 06.
Fora: os papéis do 07 e o Mission Control do 08; critério que só um Ponto B em sessão nova prova fica como "não verificável".

## Política de escrita
Somente leitura.
Commit: não.

## Critério de pronto
- [ ] Os eixos Standards e Spec rodaram sobre o intervalo inteiro.
- [ ] Cada critério de aceite do ticket 06 está como atendido, não atendido ou não verificável, com evidência.

## Retorno
Primeira linha: APROVADO ou REPROVADO.
Seções exigidas: Registro no ticket, Evidência.`
})
```

**Dev pede repro ao Tester, sem o Leader** (ticket 07; `tester-07` foi despachado
junto com `dev-07`, sem gate):

```js
SendMessage({
  to: "tester-07",
  summary: "repro do critério 5, ticket 07",
  message: "Ticket 07, critério 5 (um papel é escolhido por delegação automática). Preciso do prompt exato, do diretório e da versão do Claude Code do seu repro, e se ele é determinístico. Não é pedido de veredito."
})
```

A resposta vai ao `dev-07` por `SendMessage`. O Dev registra o repro na seção
Laterais do retorno dele, o Leader anexa o ponteiro ao ticket, e o gate é a chamada
`Agent` seguinte do Leader para `tester-07`, com `· gate`.

## 7. Pré-condição

A checagem é o `printenv` de [Uso](#uso), rodado antes de qualquer outra coisa,
inclusive antes de ler a spec. Saída exatamente `1` passa; qualquer outra coisa
para, com a mensagem literal. Não há checagem de agentes instalados à parte: se um
`anvil-team-*` faltar, o despacho falha com erro de tipo de agente, e o Leader para
e sugere `/anvil-update` ao usuário.

## 8. Frontier

### Resolver a spec

1. Argumento `NNN` ou caminho da spec, se veio.
2. Senão, o prefixo numérico do branch atual, como o perfil do tracker manda.
3. Sem spec: o trabalho ainda não sabe o que construir. O Leader propõe ao usuário
   começar pelo PO (`anvil-grill` → `anvil-to-spec` → `anvil-to-tickets`).

### Calcular

Para cada `docs/specs/{NNN}-*/issues/*.md`, ler a linha `Status:` e a linha
`Blocked by:`.

- **Resolvido** é `Status: resolved`, na mesma regex do `validate.sh`.
- **Bloqueadores** são os números de dois dígitos da linha `Blocked by:`. Linha sem
  número ("Nenhum — pode começar agora.", "None") não tem bloqueador. Número sem
  arquivo correspondente conta como bloqueando, e o Leader avisa o usuário.
- **Frontier** são os tickets não resolvidos cujos bloqueadores estão todos
  resolvidos.
- **Despacho** só de ticket `ready-for-agent`. Ticket da frontier com
  `ready-for-human`, `needs-triage` ou `needs-info` vai ao usuário com o motivo;
  `wontfix` não entra.

O Leader **relê os tickets a cada decisão de despacho**. Nunca de memória, nunca do
Mission Control. Ticket bloqueado não começa por haver capacidade ociosa.

Não existe marca de "em andamento" no ticket. A Equipe só existe enquanto a skill
roda; a sessão seguinte relê `Status:` e os comentários e sabe onde parou.

### Registrar no ticket

O Leader é o **único escritor** de `Status:` e de `## Comments` enquanto a equipe
roda. A cada retorno de entrega ou de gate, nesta ordem:

1. Anexa em `## Comments` o bloco "Registro no ticket" do retorno, **literal**.
2. Logo abaixo, a própria decisão, assinada na forma do ticket 04:

```markdown
**Review, 2026-09-14, gate Review, rodada 1: REPROVADO.**
- Critério 5 (descriptions não atraem delegação): não atendido, ver S1.
- **S1 (bloqueante)** `anvil/.claude/agents/anvil-team-review.md:3`: a description diz "revisão de mudança". Num pedido "revisa esse diff", o agente é escolhido. Correção: tirar a tarefa da description.
- **P1 (sugestão)** `anvil/.claude/skills/anvil-team/PROTOCOL.md:40`: a escala de severidade aparece antes do formato do finding. Correção: inverter a ordem.

**Leader, 2026-09-14, decisão sobre a rodada 1 do Review.** S1 volta ao `dev-06` neste
ticket. P1 fica fora: não muda comportamento. Próximo: rodada 2 do Review sobre a correção.
```

O julgamento fica nas palavras do gate, e a decisão nas do Leader. Os dois lados
ficam no histórico.

**`Status: resolved`** só quando: a entrega do autor está registrada; os gates que
o ticket exige voltaram `APROVADO` na última rodada; os findings mandados corrigir
neste ticket foram conferidos numa rodada nova; e o Leader conferiu os critérios
no artefato. Review é sempre exigido. Tester é exigido quando o ticket declara
cenário de comportamento (Ponto B).

**Commit.** `docs(spec-{NNN}): record {review|tester} gate for ticket {NN}`, por
caminho explícito, e só com nenhum escritor ativo no checkout principal, porque
dois `git commit` no mesmo checkout disputam o índice. Antes de abrir worktrees, o
Leader commita o que tiver pendente nos tickets, para a Base conter o registro.

## 9. Mission Control

### Quando

Criado pelo Leader em `docs/specs/{NNN}-{tipo}-{nome}/mission-control.md`, copiado
de `templates/mission-control.md`, quando uma destas acontecer:

- dois papéis vão escrever em paralelo;
- a sessão vai acabar com ticket da spec aberto e decisão, bloqueio ou gate
  pendente;
- os tickets da spec não cabem numa sessão;
- o usuário pede.

O terceiro gatilho é da decisão U4: numa feature de muitos tickets, o Leader cria o
Mission Control ao abrir a spec, sem esperar a sessão acabar.

Sem `promote:` no front-matter: no `archive`, ele congela dentro da spec arquivada.

### Regras, em SKILL § Mission Control

- Nunca fase, nunca estado, nunca frontier.
- Ponteiro em vez de cópia: spec, ticket, comentário, commit.
- Em divergência com um ticket, vale o ticket.
- Papel não lê. O que o papel precisar daqui vai copiado para o Contexto da delegação.
- Nenhuma skill ou hook o lê.

### `templates/mission-control.md`

```markdown
# Mission Control, {NNN} {nome}

> Bloco de notas do Leader. **Não é fonte de estado.** O estado de cada ticket
> está no `Status:` dele, os gates nos comentários dos tickets, e a frontier se
> calcula dos tickets. Os papéis não leem este arquivo.

## Objetivo e resultado esperado

## Trabalho em execução e ownership de escrita

| Name | Ticket | Escreve em | Worktree |
|---|---|---|---|

## Gates com evidência

- {AAAA-MM-DD} · ticket {NN} · {gate} rodada {n}: {veredito}, ver comentário em `issues/{NN}-{slug}.md`

## Bloqueios

| Bloqueio | Impacto | Quem resolve | Próxima ação |
|---|---|---|---|

## Decisões abertas

| Decisão | Quem decide | Opções |
|---|---|---|

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|

## Próximo passo
```

Gates em lista cronológica, não em tabela: cada linha é um fato já escrito no
ticket, com data, e não uma coluna que alguém atualizaria como estado.

## 10. Lista `team`

Em `.claude/rules/anvil.md`, na seção que já tem `runners`, `how-critics` e
`cross-judge`, e no mesmo estilo de bullet:

Pela decisão U5, o `anvil-boot` escreve a lista com os sete papéis **sem modelo**, e
a rule deste repositório fica igual:

```markdown
- `team`:
  - `po`:
  - `architect`:
  - `analyst`:
  - `designer`:
  - `dev`:
  - `tester`:
  - `review`:
```

Configurado, um papel fica assim: `` - `dev`: `opus` ``.

- Chave é o sufixo do agente: `po`, `architect`, `analyst`, `designer`, `dev`,
  `tester`, `review`.
- Valor é um de `opus`, `fable`, `sonnet`, `haiku`, o enum do parâmetro `model`.
- Papel sem valor: o Leader omite `model`, e vale o modelo da sessão. É o padrão
  escrito pelo boot, então não gera aviso.
- Papel sem linha, ou a lista inteira ausente (projeto bootado antes da lista): o
  Leader omite `model` e avisa o usuário uma vez por sessão, dizendo onde configurar.
- Chave desconhecida ou valor fora do enum: avisa uma vez e omite.
- A frase "Lidos por `anvil-arena`, `anvil-how` e `anvil-architect`" ganha a
  `anvil-team`, aqui e no texto do `anvil-boot` que descreve o `anvil.md`.

## 11. Dois escritores em paralelo

Pré-condições para paralelizar escrita, em SKILL § Paralelismo e integração:
nenhuma dependência entre os tickets, regiões de escrita declaradas e disjuntas,
integração decidida antes. Sobreposição → executar em sequência, dar a região a um
escritor só, ou isolar em worktree. Leitura se paraleliza à vontade.

Com dois escritores:

1. O Leader commita o que tiver pendente nos tickets.
2. Despacha os dois, **ambos** com `isolation: "worktree"`, no mesmo turno. O
   checkout principal fica com o Leader, que escreve os tickets.
3. Cada delegação leva `Base: {branch} em {sha}`, `Protocolo: {caminho absoluto}`,
   a região do outro escritor no Escopo, e `Commit: sim, no branch do worktree`.
4. O papel confere que o `HEAD` do worktree contém o sha da Base antes de
   escrever. Não contendo, volta `BLOQUEADO` sem escrever.
5. Quando os dois voltam, o Leader integra um de cada vez no branch da spec:
   `git cherry-pick {sha-da-base}..{branch-do-worktree}`.
   **Não `git merge`**: a guarda de merge o bloqueia no branch de uma spec com
   ticket aberto.
6. Conflito → `git cherry-pick --abort`, e o Leader despacha um Dev sem worktree
   com o conflito como Objetivo.
7. Integrados os dois, o Leader roda o comando de verificação do projeto. Só então
   despacha os gates, sobre o intervalo integrado.
8. Remove cada worktree e o branch dele só depois de `git cherry {branch-da-spec}
   {branch-do-worktree}` não listar nenhum commit com `+`.

`git cherry-pick` fora da guarda de merge é critério do ticket 13. Se a Skill tool
enxerga as skills instaladas de dentro do worktree é medição do Ponto B do 08 (M5);
se não enxergar, a solução entra no 08, e o passo 3 ganha o que ela exigir.

## 12. O que cabe em cada ticket

| Ticket | Entrega deste desenho |
|---|---|
| 06 | `SKILL.md` com trava de invocação e todas as seções menos Mission Control, lista `team` e integração de worktree; `PROTOCOL.md` **completo**, inclusive a linha de worktree, para o 07 não precisar editá-lo; `anvil-team-dev.md` e `anvil-team-review.md`, este com `SendMessage` e `ToolSearch` na allowlist; checks (d) e (f); medições M4, M6 e M7 no Ponto B |
| 07 | os outros cinco agentes; check (e); o Tester despachado junto com o Dev e a conversa lateral, provados no Ponto B |
| 08 | `templates/mission-control.md` e SKILL § Mission Control com os quatro gatilhos; leitura da lista `team` em SKILL § Despacho; o `anvil-boot` escrevendo a lista com os sete papéis sem modelo, e a rule deste repositório igual; SKILL § Paralelismo e integração; medição M5 no Ponto B |
| 13 | `git cherry-pick` continua fora da guarda de merge |

Os checks (a), (b) e (c) são do 05.

## Contradições encontradas

Cada item diz como ficou depois das decisões do Leader (`3d38ec0`).

1. **A allowlist do Review não tinha `SendMessage`.** A decisão fechada dizia
   "leitura, `Bash`, `Agent`, `Skill`". A mesma lista de decisões põe os papéis em
   conversa direta, e a referência (`agents/review.md`) prevê o Dev esclarecendo
   finding com o Review. Sem `SendMessage`, o Review lê mensagens e não responde.
   **Decidido (U1):** o Review ganha `SendMessage` e `ToolSearch`, e continua sem
   `Edit` e `Write`. A spec foi atualizada.
2. **"O Review não consegue editar" vale só para as ferramentas de edição.** `Bash`
   escreve arquivo, e `Agent` deixa o Review despachar um `general-purpose` com
   `Edit`. A allowlist precisa de `Bash` (sentrux, verify) e de `Agent`
   (`anvil-code-review`). **Decidido (U2):** "não edita" quer dizer sem `Edit` e
   `Write`; `Bash` e `Agent` ficam declarados. O Ponto B do 06 mede pela ferramenta
   `Edit`, e o resto é o protocolo.
3. **O Mission Control de referência tem mais estado do que as duas peças citadas.**
   Além da coluna Estado da frontier e do Estado global, a tabela Gates tem coluna
   Estado (`PENDENTE`), o `team-protocol.md` diz que o Mission Control "representa o
   estado global da missão", e o `leader.md` põe nele "frontier" e "agentes
   ocupados". Tudo sai, pelo mesmo motivo do ADR.
4. **Skills citadas pela referência têm trava de invocação.** `anvil-to-questionnaire`
   (secundária do PO), `anvil-wayfinder` (roteamento do Leader) e `anvil-handoff` (o
   "handoff" do protocolo). A user story 53 pede que nenhum papel seja roteado para o
   vazio; a spec deixa as skills travadas fora do escopo. **Decidido (U3):** as três
   continuam travadas. O PO perde `anvil-to-questionnaire`, e o Leader sugere
   `/anvil-wayfinder` e `/anvil-handoff` ao usuário.
5. **Worktree sem `.claude/skills/`.** O ticket 06 pede que os agentes leiam o
   protocolo antes de agir, e o ticket 04 fez as skills instaladas serem ignoradas
   pelo git. Num worktree, o caminho do protocolo não existe. Saída adotada: caminho
   absoluto na linha `Protocolo:` do Contexto. Se a Skill tool também não enxergar as
   skills de dentro do worktree, um Dev isolado não roda `anvil-implement`.
   **Em aberto, com dono:** a medição é critério do Ponto B do 08 (M5), e a solução,
   se precisar, entra no 08.
6. **O port também tira `ai-memory`, que não é do Maestri.** A spec manda tirar
   visibilidade de notas, erro de conexão e bootstrap. `ai-memory` é um MCP do
   ambiente de quem configurou a equipe, e o payload vai para projetos que não o têm;
   citá-lo manda o papel chamar ferramenta inexistente. Virou "memória de sessões
   anteriores, quando houver". É desvio deliberado do port literal, e o Leader não o
   contestou.
7. **Trava de invocação na `anvil-team` era decisão nova.** Nem o ADR nem a spec a
   pediam. Motivo na [seção 1](#skillmd-o-leader). **Decidido (U7):** fica, e a spec a
   registra.
8. **A guarda de merge bloqueia a integração por `git merge`.** Não contradiz o
   ticket 08, que não diz o comando, mas amarra o ticket 13 (a guarda passa a olhar
   também o branch nomeado no merge): se a guarda um dia casar `cherry-pick`, a
   integração de worktree quebra. **Decidido:** `cherry-pick` fora da guarda é
   critério do 13.

## Tradeoffs aceitos

- Aceito que o Leader leia dois arquivos ao abrir em troca de a delegação e o
  retorno terem uma definição só, lida pelos dois lados.
- Aceito que os sete agentes repitam a linha-ponteiro e a description em troca de o
  protocolo não se repetir. As duas repetições são checadas.
- Aceito o Leader como gargalo na escrita dos tickets em troca de um escritor só no
  arquivo que todos leem, e do finding do Review chegar ao ticket sem `Write`.
- Aceito que cada rodada de gate recomece do zero, relendo o ticket, em troca de
  independência sem ancoragem na rodada anterior e do veredito sempre no caminho
  medido.
- Aceito `run_in_background: true` sempre, com o risco de permissão em background
  (M4, Ponto B do 06), em troca de o Leader continuar disponível e de dois papéis estarem
  vivos ao mesmo tempo.
- Aceito `cherry-pick` e histórico linear em troca de não abrir exceção na guarda de
  merge.
- Aceito que o campo Skills possa ser "à escolha do papel" em troca de o Leader não
  precisar conhecer o repertório de cada papel.
- Aceito que a linha `Equipe` seja um retrato tirado no despacho: name morto dá erro
  de entrega e `BLOQUEADO`, em vez de descoberta dinâmica.
- Aceito um Tester vivo durante a implementação, quando o ticket pede repro, em troca
  de a conversa lateral existir sem passar pelo Leader.

## Alternativas consideradas

- **Partição fiel à referência**, protocolo para todos com frontier e paralelismo, e
  o template da delegação no arquivo do Leader. Perdeu: o papel leria regra de
  Leader, e delegação e retorno ficariam em arquivos diferentes.
- **Link markdown relativo no agente** (`../skills/anvil-team/PROTOCOL.md`). O
  `verify` resolveria de graça; o modelo, que resolve a partir do cwd, não.
- **Protocolo colado em cada delegação.** Funciona em worktree e dispensa check.
  Perdeu: umas 150 linhas regeneradas por despacho, risco de paráfrase, e nenhuma
  costura para o `verify` conferir.
- **Protocolo copiado em cada agente.** Sete cópias que derivam; o critério do ticket
  07, "cada papel guarda só o que é dele", fica falso por construção.
- **Gate que avisa o Leader por `SendMessage`, e o Dev chama o gate quando termina**,
  como o `anvil-implement` chama o `anvil-code-review`. Perdeu: o autor decide quando
  e se o gate roda. É o furo que o ADR-0007 existe para fechar.
- **Papel escreve o próprio comentário no ticket.** Dois escritores no mesmo arquivo,
  cópias divergentes em worktree, e o Review escrevendo por `Bash` esvazia a
  allowlist.
- **Rodada de gate por `SendMessage` ao mesmo agente.** Mantém contexto; ancora o gate
  na rodada anterior e na conversa lateral com o autor. O caminho de retorno funciona
  (M2); o motivo que sobra é a independência.
- **`DISPATCH.md` separado para a mecânica medida.** Um arquivo a mais com um leitor e
  a mesma ocasião do `SKILL.md`; ficou como nota de versão dentro de SKILL § Despacho.
- **Names fixos por papel** (`dev`, `review`). Endereço estático, mas dois Devs em
  tickets diferentes colidem, e reusar name substitui o agente.

## Synthesis decision

Arena com três candidatos (`opus`, `fable`, `sonnet`), restrita ao que estava aberto:
layout de arquivos, partição do protocolo e formato da delegação. Juiz cruzado em
`fable`, contra uma rubrica de seis critérios: cobertura da partição, caminho
verificável, delegação sem campo novo, gate por construção, fidelidade às decisões
fechadas e superfície mínima. Notas do juiz: 17, 15 e 8.

**Base: o candidato de `opus`.** É o único cujo gate depende só de fato medido
(resultado de chamada `Agent`, não de turno retomado), o único que viu que o worktree
perde `.claude/skills/`, e o que tem a partição mais completa com o protocolo mais
enxuto. A minha leitura e a do juiz coincidiram na base.

**Enxertos.**

- Do candidato de `fable`: "Não toque: `issues/`" na Política de escrita; o motivo de a
  description não nomear tarefa nem em negativa; a nota de versão sobre a mecânica
  medida, dentro de SKILL § Despacho; o Tester despachado junto com o Dev para a
  conversa lateral existir; lista `team` em bullets aninhados; nenhum escritor em
  paralelo durante a discovery do PO.
- Do candidato de `sonnet`: check de `name:` igual ao nome do arquivo; o risco de o
  `DENY` não pegar resíduo do Maestri, que virou o check (f); `templates/` para o
  Mission Control, seguindo a `anvil-docs`.
- Meus, da fase de grounding: filtro de triagem na frontier, a ordem de commit do
  Leader, a conferência de base no worktree, a remoção do worktree só depois do
  `git cherry`, e gates do Mission Control em lista cronológica.

**Rejeitados.**

- Do candidato de `opus`: `SendMessage` e `ToolSearch` aplicados na allowlist do
  Review. Ficou como contradição 1, porque reabria decisão fechada; depois a decisão
  U1 os adotou. Também o aviso a
  `to: "main"` para laterais: a ferramenta o documenta só para subagente em background,
  e não está medido em agent teams. Laterais vão no retorno.
- Do candidato de `fable`: `DISPATCH.md`; gate do Tester por `SendMessage`; retorno do
  Dev colado na delegação do Review, que ancora o gate no autor.
- Do candidato de `sonnet`: campos da delegação em inglês; descriptions que descrevem
  a tarefa, contra a decisão fechada; frontier e `PENDENTE` no Mission Control;
  `ai-memory` no protocolo; frontier e paralelismo no protocolo; Tester acionado
  quando o Dev sinaliza pronto.

**Convergência dos três:** caminho em crase resolvido contra `anvil/` por check novo do
05; só o Leader despacha gates e escreve o ticket; `Agent` na allowlist do Review por
causa do `anvil-code-review`; independência de gate consolidada no protocolo;
catálogo e install fora.

## Perguntas abertas

Estado depois das decisões e medições do Leader (`3d38ec0`). As medições foram
feitas num teste de sondagem no Claude Code 2.1.270, com agent teams ligado.

### Medições

- **M1. Medido: sim.** Agente despachado com `name`, dentro de agent teams, devolve o
  resultado à sessão principal, como notificação de idle com o campo `result`. É a
  base dos gates.
- **M2. Medido: sim.** Agente retomado por `SendMessage` devolve o novo resultado à
  sessão principal. O laço de correção do autor por retomada vale como desenhado.
- **M3. Medido: sim.** `SendMessage` é diferida dentro do agente, e carrega com
  `ToolSearch` `select:SendMessage`. Por isso o Review tem as duas na allowlist, e o
  PROT § Comunicação manda carregar antes do primeiro envio.
- **M4. Aberta, Ponto B do 06.** Um papel em background que precisa de permissão não
  pré-aprovada recebe o pedido na sessão do Leader, ou a chamada é negada em
  silêncio?
- **M5. Aberta, critério do 08.** Num worktree de `isolation: "worktree"`: de que
  commit ele parte, e a Skill tool enxerga as skills instaladas? Se não enxergar, o
  caminho candidato é o `.worktreeinclude`, e a solução entra no 08.
- **M6. Aberta, Ponto B do 06.** Reusar um `name` com `Agent` substitui o agente
  anterior sem erro?
- **M7. Aberta, Ponto B do 06.** Os nomes das ferramentas de leitura do `tools:` do
  Review existem na versão instalada.
- **M8. Feito.** O contrato de citação da seção 3 virou critério: (a), (b) e (c) no
  05, (d) e (f) no 06, (e) no 07.

### Decisões do usuário

- **U1.** O Review ganha `SendMessage` e `ToolSearch`, e continua sem `Edit` e
  `Write`. A allowlist existe para impedir edição; mensagem não edita.
- **U2.** "O Review não edita" quer dizer sem `Edit` e `Write`. `Bash` e `Agent` ficam
  declarados.
- **U3.** `anvil-wayfinder`, `anvil-handoff` e `anvil-to-questionnaire` continuam
  travadas. O PO fica sem `anvil-to-questionnaire`, e o Leader sugere
  `/anvil-wayfinder` e `/anvil-handoff` ao usuário.
- **U4.** O Mission Control nasce a pedido, com dois escritores em paralelo, com
  sessão acabando com trabalho pendente, ou quando os tickets da spec não cabem numa
  sessão.
- **U5.** O `anvil-boot` escreve a lista `team` com os sete papéis sem modelo, e cada
  um herda o da sessão. A rule deste repositório fica igual.
- **U6.** A volta PO → Leader → usuário → Leader → PO a cada pergunta do grill é
  aceita: é o fluxo da configuração de origem.
- **U7.** A trava de invocação na `anvil-team` fica.
