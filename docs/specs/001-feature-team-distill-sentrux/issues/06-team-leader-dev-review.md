# 06: `anvil-team`: Leader, Dev e Review de ponta a ponta

**What to build:** O usuário chama a `anvil-team` numa spec com tickets e conversa com o Leader. O Leader calcula a frontier pelos tickets, despacha o Dev com a delegação completa, e o Review julga o resultado. O julgamento do Review chega ao Leader diretamente e fica registrado nos comentários do ticket. Sem *agent teams* ligado, a skill para e diz o que falta. É o esqueleto que os outros papéis vão ocupar — ver ADR-0007.

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] Sem a variável de *agent teams*, a skill para e mostra a configuração que falta. Não há modo degradado.
- [ ] O Leader é a skill, na sessão principal, e é o único que conversa com o usuário.
- [ ] O protocolo, portado do usado no Maestri sem visibilidade de notas, erro de conexão com nota e bootstrap pelo Leader, fica num lugar só dentro da skill, e os agentes o leem antes de agir.
- [ ] A delegação tem os sete campos: objetivo, contexto, skills, escopo, política de escrita, critério de pronto e retorno.
- [ ] `anvil-team-dev` e `anvil-team-review` existem no payload, com descriptions que dizem que só são despachados pela `anvil-team` e que não atraem delegação automática.
- [ ] O Review declara allowlist com leitura, `Bash`, `Agent` e `Skill`, sem `Edit` e `Write`.
- [ ] A implementação segue o desenho em `architecture/team-shape.md` (`384fc45`), seção 12, parte do 06.
- [ ] O Review declara também `SendMessage` e `ToolSearch` na allowlist, e continua sem `Edit` e `Write`.
- [ ] A `anvil-team` tem trava de invocação: só o usuário a abre.
- [ ] O `verify` reprova agente de equipe que não cita o protocolo, e token do Maestri (`@team-protocol`, `@anvil-skills`, `@mission-control`, `@anvil-install`, `No connection to note`) em skill ou agente do payload.
- [ ] A frontier sai dos tickets, e os findings do Review ficam nos comentários do ticket.
- [ ] Ponto B: sem a variável, a skill para; com ela, um ticket vai do Dev ao Review e o julgamento chega ao Leader; um "revisa esse diff" fora da skill não cai em papel nenhum; o Review não consegue editar.
- [ ] A skill `anvil-team` entra no roster do `dev-link`, e os agentes da equipe ficam ligados neste repositório.
- [ ] O `verify` sai limpo, incluindo a checagem de caminhos citados por agentes.

## Comments

**Leader, 2026-09-13 — decisões sobre as perguntas do desenho** (o desenho em `architecture/team-shape.md` (`384fc45`)):

- **U1** o Review ganha `SendMessage` e `ToolSearch`: a allowlist existe para impedir edição, e
  mensagem não edita; a conversa lateral é decisão do ADR-0007.
- **U2** "o Review não edita" = sem `Edit` e `Write`; `Bash` e `Agent` ficam declarados (Q19).
- **U6** a volta PO → Leader → usuário → Leader → PO no grill é aceita: é o fluxo da configuração de origem.
- **U7** a trava de invocação na `anvil-team` fica: o usuário disse que a equipe só existe quando ele a chama.

Medições já feitas no teste de sondagem (Claude Code 2.1.270): **M1** o resultado de um agente com nome
chega à sessão principal; **M2** o de um agente retomado por `SendMessage` também; **M3** `SendMessage`
é diferida dentro do agente e precisa de `ToolSearch`. Ficam para o ponto B deste ticket: **M4**
permissão pedida por papel em background, **M6** reuso de `name`, **M7** nomes das ferramentas de
leitura na allowlist.

**Leader, 2026-09-13 — mudanças de desenho durante a implementação** (Architect, `team-shape.md` em `9ad85de`, a
partir de medições do ponto B do Dev):

1. **Sessão do Leader retomada** (`--resume` ou `-p`) não alcança papel pelo `name`. Regra só para autor: listar
   os agentes; exatamente um subagente desta sessão com o `name` → retomar por `SendMessage` pelo id; nenhum ou
   mais de um → `Agent` novo com o mesmo `name`, apontando ticket e comentários. Gate não muda.
2. **Subagente de skill em background** perdia o resultado. A linha do protocolo vira exceção explícita à regra
   "o protocolo de uma skill vence este": dentro da equipe, foreground mesmo quando a skill manda background; as
   chamadas da mesma mensagem continuam em paralelo.
