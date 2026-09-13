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
- [ ] A frontier sai dos tickets, e os findings do Review ficam nos comentários do ticket.
- [ ] Ponto B: sem a variável, a skill para; com ela, um ticket vai do Dev ao Review e o julgamento chega ao Leader; um "revisa esse diff" fora da skill não cai em papel nenhum; o Review não consegue editar.
- [ ] O `verify` sai limpo, incluindo a checagem de caminhos citados por agentes.
