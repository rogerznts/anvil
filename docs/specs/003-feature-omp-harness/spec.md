# 003 — omp como harness, com camada própria

**Status:** ready-for-agent

## Problem Statement

Quem usa o anvil pelo omp roda as skills, mas perde a guarda de merge sem saber.
O omp não executa os hooks `PreToolUse` do `.claude/settings.json`, então uma spec
pode chegar à `main` com ticket aberto ou sem arquivar, que é exatamente o que a
guarda existe para impedir.

O fluxo no omp também é tão manual quanto no Claude Code, embora o omp tenha o que
falta para conduzi-lo: `task`, agentes próprios e sessões filhas que nascem sem a
conversa do pai. O operador encadeia `grill → to-spec → to-tickets` de cabeça,
precisa saber quando desviar para research, prototype ou wayfinder, e depois abre
uma sessão por ticket para rodar o `anvil-implement`, um de cada vez.

A instalação não sabe que o omp existe. O degit copia `.claude/`, e o update só
mantém `.claude/`. Nada instala o que o omp lê em `.omp/` — agentes, hooks, rules,
skills nativas — e o omp ignora `.claude/agents` e `.claude/rules` de propósito.

O espelho `.agents/skills`, que é por onde o Codex lê as skills, vem pronto no
payload e ninguém o mantém. Skill removida do anvil continua no Codex para sempre,
e na raiz deste repositório já sobra um link pendurado para o `anvil-team`, que saiu
pelo ADR-0008 — a equipe por papel sai do toolkit.

## Solution

Ao instalar ou atualizar, o anvil detecta o omp e instala a **camada omp** em
`.omp/`, sem perguntar. A camada fica depois, mesmo que um colega sem omp rode o
próximo update.

No omp:

- a guarda de merge volta a valer, com a mesma regra do Claude Code;
- `/skill:anvil-plan <pedido>` conduz o planejamento na mesma janela e, entre uma
  etapa e outra, sugere a próxima ou um desvio, carregando só com o sim do operador;
- `/skill:anvil-run NNN` implementa a spec ticket a ticket, em série, cada ticket
  num implementer de contexto novo, com o review em dois eixos que já existe. Para
  quando tudo está resolvido ou quando o que sobra está travado, e diz o próximo
  passo: browser QA se a spec tem tela, depois archive e PR;
- o manual `anvil-omp` explica a camada.

No Claude Code e no Codex nada muda: o fluxo continua manual e a lista de skills é a
mesma. O Codex passa a receber um espelho mantido pelo update.

A decisão está no ADR-0011 — o omp é harness de primeira classe, com camada
própria. O desenho do fluxo está em `docs/discovery/camadas-anvil-omp.md`.

## User Stories

### Detecção e instalação

1. Como operador que usa omp, quero que o `/anvil-boot` perceba que tenho omp e instale a camada omp sozinho, para que eu não precise saber que ela existe.
2. Como operador que usa omp, quero que o `/anvil-update` instale a camada quando detectar o omp, para que um projeto bootado antes desta spec ganhe a camada no próximo update.
3. Como operador, quero que a detecção olhe o binário `omp` no `PATH`, o diretório `~/.omp/` e a linha `omp:` no lock, para que qualquer um dos três sinais baste.
4. Como dev num time misto, quero que um update rodado numa máquina sem omp mantenha a camada que já está no lock, para que ela não apareça e suma a cada update conforme quem rodou.
5. Como operador que só usa Claude Code, quero que um projeto sem nenhum sinal de omp não ganhe `.omp/`, para que o repositório não carregue arquivo que ninguém lê.
6. Como operador, quero que o relatório do update diga se a camada foi instalada, mantida ou não instalada, e por qual sinal, para que eu entenda por que ela está ali.
7. Como operador, quero que um arquivo da camada removido do payload saia do meu `.omp/` no update seguinte, para que o omp não continue carregando agente ou hook morto.
8. Como operador, quero que os meus próprios arquivos em `.omp/` — `config.yml`, agentes, rules e skills que escrevi — nunca sejam tocados pelo update, para que a camada conviva com a minha configuração.
9. Como operador, quero que um arquivo meu em `.omp/` com o mesmo nome de um arquivo da camada seja apontado no relatório antes de ser substituído, para que eu não perca trabalho sem aviso.
10. Como operador, quero que o dry-run do update mostre também o que vai mudar em `.omp/`, para que eu confirme antes de executar.
11. Como operador, quero que a camada venha versionada no repositório como o resto do toolkit, para que quem clona tenha o omp configurado sem instalar nada.
12. Como operador sem lock, quero que o modo degradado do update não apague nada em `.omp/`, para que a ausência do lock continue sendo o lado seguro.

### Espelho do Codex

13. Como operador que usa Codex, quero que `.agents/skills` continue expondo as skills do anvil, para que o Codex funcione como hoje.
14. Como operador que usa Codex, quero que uma skill removida do anvil saia de `.agents/skills` no update, para que o Codex não siga uma skill que não existe mais.
15. Como operador que usa Codex, quero que o espelho aponte para `.claude/skills` em vez de copiar, para que as duas visões nunca divirjam.
16. Como operador que usa Codex, quero que as minhas skills próprias em `.agents/skills` fiquem intactas, para que o espelho não apague o que não é do anvil.
17. Como operador que usa omp, quero que as skills vistas por `.claude/skills` e por `.agents/skills` não apareçam duplicadas, para que a lista do omp fique limpa.

### Guarda de merge no omp

18. Como operador no omp, quero que um `git merge` de spec com ticket aberto seja bloqueado, para que a spec não chegue à `main` sem terminar.
19. Como operador no omp, quero que um `git merge` de spec não arquivada seja bloqueado, para que o archive continue vindo antes do merge.
20. Como operador no omp, quero que um `tea pr create` de spec não arquivada seja bloqueado, como no Claude Code, para que o PR não abra antes do archive.
21. Como operador no omp, quero ver o mesmo motivo e o mesmo rodapé de correção que o Claude Code mostra, para que eu saiba o que fazer.
22. Como operador no omp, quero que merge fora de branch de spec passe sem atrito, para que a guarda só aja onde tem regra.
23. Como mantenedor, quero que a regra da guarda fique numa fonte só, para que Claude Code e omp nunca decidam diferente.
24. Como operador num time misto, quero que o hook do Claude continue registrado no `settings.json` mesmo com a camada omp instalada, para que quem usa Claude Code siga protegido.

### Vocabulário e manual

25. Como operador no omp, quero que o modelo entenda "Call the Skill tool", `/anvil-x` e "sub-agent" dentro das skills vendorizadas como as primitivas do omp, para que as skills rodem sem adaptação.
26. Como operador no omp, quero que essa tradução ocupe pouco contexto, para que ela não pese em todo turno.
27. Como operador no omp, quero um manual `anvil-omp` que diga o que a camada é, como chegou, quais comandos existem e o que continua manual, para que eu aprenda sem ler o ADR.
28. Como operador, quero que o manual diga como remover a camada à mão, para que a regra pegajosa não vire armadilha.
29. Como operador, quero que o manual deixe claros os limites — o `eval` escapa da guarda, o frontier é em série, o `task` não escolhe modelo por chamada —, para que eu não descubra em produção.

### Implementação conduzida — `anvil-run`

30. Como operador no omp, quero chamar `/skill:anvil-run 003` e ver a spec implementada ticket a ticket, para que eu não precise abrir uma sessão por ticket.
31. Como operador no omp, quero que a `anvil-run` sem argumento resolva a spec pelo branch atual, para que eu não precise lembrar o número.
32. Como operador no omp, quero que a `anvil-run` recuse rodar fora do branch da spec, para que os commits não caiam no branch errado.
33. Como operador no omp, quero que o próximo ticket seja sempre o de menor número entre os desbloqueados, para que a ordem seja previsível.
34. Como operador no omp, quero que cada ticket rode num implementer de contexto novo, para que o ticket seja o estado e não a conversa.
35. Como operador no omp, quero que o implementer siga `anvil-implement`, `anvil-tdd` e `anvil-code-review` como estão, para que a disciplina seja a mesma do fluxo manual.
36. Como operador no omp, quero que os dois eixos do review rodem em sessões que não viram a implementação, para que o gate não seja o autor se revisando.
37. Como operador no omp, quero que o supervisor releia os tickets do disco depois de cada implementer, para que o que vale seja o que foi gravado.
38. Como operador no omp, quero que um ticket com a segunda rodada reprovada fique travado e o supervisor siga com o que não depende dele, para que um ticket difícil não pare a spec inteira.
39. Como operador no omp, quero que o supervisor nunca abra a terceira rodada, para que essa escolha seja minha, como manda o ADR-0010 — a verificação para quando não sobra P1.
40. Como operador no omp, quero que um implementer que falhou sem gravar estado não seja repetido na mesma execução, para que o supervisor não gire em falso.
41. Como operador no omp, quero que, ao terminar, o relatório liste o que foi resolvido, o que travou com o P1 aberto e o que depende dos travados, para que eu saiba onde agir.
42. Como operador no omp, quero que, com tudo resolvido e a spec tendo tela, o relatório recomende `/skill:anvil-browser-qa`, para que o QA venha na hora certa.
43. Como operador no omp, quero que, sem tela, o próximo passo recomendado seja o `/anvil-docs archive`, para que não haja QA de browser sem browser.
44. Como operador no omp, quero que a `anvil-run` nunca dispare browser QA, archive ou PR, para que o fechamento continue meu.
45. Como operador no omp, quero que, se a sessão cair, rodar `/skill:anvil-run 003` de novo retome de onde parou, para que nada dependa da memória do supervisor.
46. Como operador no omp, quero ver o andamento a cada ticket, para que eu acompanhe sem abrir arquivo.
47. Como operador no omp, quero que a `anvil-run` tenha trava de invocação, para que o modelo nunca comece uma execução autônoma por conta própria.

### Planejamento conduzido — `anvil-plan`

48. Como operador no omp, quero chamar `/skill:anvil-plan <pedido>` uma vez e ser conduzido por grill, to-spec e to-tickets na mesma janela, para que eu não precise saber a ordem.
49. Como operador no omp, quero que, ao fechar a pausa de uma etapa, a `anvil-plan` proponha a próxima, para que eu não precise perguntar "e agora?".
50. Como operador no omp, quero que nada seja carregado sem o meu sim, para que cada transição continue sendo decisão minha.
51. Como operador no omp, quero que a `anvil-plan` proponha um desvio quando o grill esbarrar em fato desconhecido, pergunta que só se responde vendo rodar, dependência de outra pessoa, trabalho grande demais, tela sem fluxo ou forma de módulos em aberto, para que eu use research, prototype, to-questionnaire, wayfinder, ui ou architect sem conhecer cada um.
52. Como operador no omp, quero voltar à etapa de onde saí depois de um desvio, para que o desvio não perca o fio.
53. Como operador no omp, quero que as pausas de cada skill — entendimento confirmado, seams, granularidade — continuem existindo, para que a condução não pule decisão.
54. Como operador no omp, quero que dizer "não" pare a condução sem carregar nada, para que eu possa seguir por outro caminho.
55. Como operador no omp, quero que chamar a `anvil-plan` de novo retome pelo que já está no disco e na conversa, para que uma instrução perdida numa conversa longa seja recuperável.
56. Como operador no omp, quero que, com os tickets validados, a `anvil-plan` indique `/clear` e depois `/skill:anvil-run NNN`, para que a passagem para a implementação seja óbvia.
57. Como operador no omp, quero que a `anvil-plan` tenha trava de invocação, para que ela não dispare sozinha no meio de uma conversa.

### Claude Code e Codex sem mudança

58. Como operador no Claude Code, quero que a lista de skills continue a mesma, para que nada novo apareça num harness onde a automação não vale.
59. Como operador no Codex, quero que a lista de skills continue a mesma, pelo mesmo motivo.
60. Como operador no Claude Code, quero que o fluxo manual — `/anvil-grill`, `/anvil-to-spec`, `/anvil-to-tickets`, `/anvil-implement` por sessão — siga como está, para que eu não reaprenda nada.
61. Como mantenedor, quero que nenhuma skill vendorizada ganhe delta por causa do omp, para que o merge 3-way continue limpo, como mandam o ADR-0001 e o ADR-0004.

### Este repositório

62. Como mantenedor, quero que o `dev-link.sh` ligue a camada omp no `.omp/` deste repositório, para que eu desenvolva o anvil usando a própria camada.
63. Como mantenedor, quero que o `dev-link.sh` também gere o `.agents/skills` deste repositório a partir das skills ligadas, para que o link pendurado do `anvil-team` suma e o Codex funcione aqui.
64. Como mantenedor, quero que o `vendor-sync verify` confira a camada — nomes, caminhos citados, skills carregadas pelo agente —, para que a camada não apodreça em silêncio.
65. Como mantenedor, quero que o README tenha uma seção curta sobre o omp e que o `overview.md` cite a camada de harness, para que quem chega entenda que existem três harnesses e só um automatiza.
66. Como mantenedor, quero que o manifesto registre `anvil-plan`, `anvil-run` e `anvil-omp` como autorais da camada, para que a curadoria saiba o que não tem upstream.

## Implementation Decisions

### Camada omp no payload

- **Onde mora.** Material dentro da `anvil-update`, numa árvore que espelha o
  `.omp/` do projeto — por exemplo `omp-layer/`. Não é skill: nenhum harness a lista,
  porque a descoberta de skills não é recursiva.
- **Conteúdo.** Hook de guarda em `hooks/pre/`, a rule `anvil-harness` em `rules/`,
  o agente `anvil-implementer` em `agents/` e três skills em `skills/`:
  `anvil-plan`, `anvil-run` e `anvil-omp`.
- **Autorais.** As três skills e o agente não têm upstream. O manifesto as registra
  no comentário de autorais, como camada omp.

### Detecção

- **Sinais.** `command -v omp`, `~/.omp/` existente, ou ao menos uma linha `omp:` no
  lock atual. Qualquer um basta. O omp não exporta variável de ambiente que o
  identifique, e o degit não executa nada — a detecção roda no `reset-install.sh`.
- **Pegajosa.** A terceira condição é o que torna a camada permanente: ausência do
  binário nunca remove nada.
- **Uma implementação.** Uma função no `reset-install.sh` instala a camada e o
  espelho do Codex. O update a chama depois de instalar as skills; o boot a chama
  por um modo do script que roda só essa parte, como o `--unignore` já faz para o
  `.gitignore`.
- **Relatório.** O update diz o sinal que decidiu e o que mudou em `.omp/` e em
  `.agents/skills`. O dry-run mostra os dois antes de executar.

### Lock

- **Linha nova.** `omp: <caminho relativo a .omp/>`, uma por arquivo da camada, ao
  lado de `skill:` e `agent:`, lida pelo mesmo `sed`. Um leitor antigo ignora a
  linha e deixa de reconhecer a camada como do anvil — o lado seguro, porque então
  não apaga nada.
- **Classificação.** A mesma das skills: substituídos, órfãos, alheios e colisões.
  Órfão é linha `omp:` do lock que não existe mais no payload. Alheio é qualquer
  arquivo em `.omp/` fora do lock, e nunca é tocado. Colisão é arquivo em `.omp/`
  com caminho da camada e fora do lock: aparece no aviso antes de ser substituído.
- **Só no projeto.** O lock do payload não ganha `omp:`. Quem escreve `omp:` é o
  `reset-install.sh`, e só quando instala a camada.

### Espelho `.agents/skills`

- **Sai do payload.** O `anvil/.agents/` deixa de existir.
- **Gerado.** Para cada linha `skill:` do lock novo, um symlink relativo
  `.agents/skills/<nome>` → `../../.claude/skills/<nome>`.
- **Órfãos.** Symlink cujo nome estava no `skill:` do lock anterior e não está no
  novo sai. Entrada em `.agents/skills` que não é symlink para `.claude/skills` é
  alheia e fica; se tiver nome de skill do payload, é colisão e aparece no aviso sem
  ser substituída.
- **Sem duplicata no omp.** O omp deduplica skills por caminho real; o symlink
  resolve para o mesmo arquivo de `.claude/skills`.

### Guarda no omp

- **Hook.** Um `.omp/hooks/pre/*.ts` que escuta `tool_call` do `bash`, monta o JSON
  no formato do hook do Claude com o comando e chama o `guard-spec-merge.sh`
  instalado. Exit 2 bloqueia, com a saída de erro do script como motivo; qualquer
  outro código deixa passar, como o Claude Code trata hook que falha sem ser 2.
- **Fonte única.** A regra continua no `validate.sh ship-ready`, sem mudança.
- **Furo declarado.** Só o tool `bash` é interceptado. Comando disparado pelo `eval`
  escapa, como hoje escapa do hook do Claude o que não passa pelo Bash.
- **Claude Code.** O boot continua registrando o hook do Claude no
  `.claude/settings.json`, com ou sem camada omp.

### Rule `anvil-harness`

- `alwaysApply: true`, curta, só com o mapeamento: "Skill tool" e `/anvil-x` dentro
  de uma skill significam ler a skill por `skill://`; "sub-agent" e "Task" significam
  o tool `task`, com `scout` quando a skill pede leitura apenas; `AskUserQuestion`
  significa `ask`. As rules do projeto continuam lidas porque o `CLAUDE.md` manda.

### `anvil-implementer`

- **Frontmatter.** `name`, `description`, `autoloadSkills` com `anvil-implement`,
  `anvil-tdd` e `anvil-code-review`, e `task` entre as ferramentas, para abrir os
  dois eixos do review. Sem `model:`: herda o da sessão, e quem quiser outro usa
  `task.agentModelOverrides`.
- **Contrato.** Um ticket por execução. Lê o ticket, a spec, os ADRs citados e as
  rules; segue as skills carregadas como estão; commita no branch atual. Devolve o
  ticket, o `Status:` final e a última linha `Review:`.
- **Profundidade.** Supervisor na sessão principal (0), implementer (1), eixos do
  review (2). Cabe no `task.maxRecursionDepth` padrão, que é 2; na profundidade 2 o
  omp tira o `task` do filho.

### `anvil-run`

- **Invocação.** Trava de invocação. Argumento opcional: o número da spec; sem ele,
  resolve pelo prefixo numérico do branch atual. Fora do branch da spec, para e diz
  qual é o branch.
- **Frontier.** Ticket com `Status:` diferente de `resolved`, com todos os
  `Blocked by` resolvidos e não travado. **Travado** é o ticket cuja última linha
  `Review:` tem `round` 2 ou mais e `verdict=fail` — lido do disco, sem status novo.
- **Laço.** Pega o menor número do frontier, despacha um `anvil-implementer`,
  espera, relê o disco, recalcula. Em série.
- **Falha do implementer.** Ticket cujo implementer terminou sem mudar o estado é
  anotado só na memória desta execução e não é repetido nela. Rodar de novo tenta de
  novo.
- **Fim.** Frontier vazio. Com tudo resolvido: relatório e próximo passo. O próximo
  passo é `/skill:anvil-browser-qa` quando a spec tem tela — existe `ui/` na pasta
  da spec ou uma user story descreve tela —, e `/anvil-docs archive` quando não tem.
  Com tickets pendentes: a lista dos travados com o P1 aberto e dos que dependem
  deles.
- **Nunca faz.** Terceira rodada, browser QA, archive, PR.

### `anvil-plan`

- **Invocação.** Trava de invocação. Argumento: o pedido inicial, que vai para o
  grill.
- **Condução.** Carrega `anvil-grill`, `anvil-to-spec` e `anvil-to-tickets` na mesma
  janela, sem compactar. Quando a pausa humana de uma etapa fecha, propõe a próxima
  ou um desvio e só carrega com o sim.
- **Desvios.** `anvil-research`, `anvil-prototype`, `anvil-to-questionnaire`,
  `anvil-wayfinder`, `anvil-ui` e `anvil-architect`, cada um ligado ao sinal que o
  justifica. Depois do desvio, propõe voltar à etapa de origem.
- **Retomada.** A etapa sai da conversa e do disco: `spec.md` existe leva à
  sugestão de `to-tickets`; `issues/` com tickets leva ao fim da janela. Nenhum
  campo de estado, como manda o ADR-0003 — sem máquina de fases.
- **Fim.** Indica `/clear` e depois `/skill:anvil-run NNN`.
- **Não faz.** Publicar spec ou ticket por conta própria — isso é das skills que ela
  carrega.

### `anvil-omp`

- Manual com trava de invocação: o que é a camada, como a detecção decide, os
  comandos `/skill:anvil-plan`, `/skill:anvil-run` e `/skill:anvil-browser-qa`, o que
  continua manual, os limites, e como remover a camada à mão — apagar os arquivos e
  as linhas `omp:` do lock no mesmo commit.

### Boot e update

- **Boot.** Um passo novo, depois do registro do hook do Claude: chama o modo de
  camadas do `reset-install.sh` e relata o que instalou. No omp, o boot é chamado
  por `/skill:anvil-boot`.
- **Update.** Nenhum passo novo na skill: o `reset-install.sh` já faz a detecção e o
  relatório.

### Este repositório

- **`dev-link.sh`.** Liga a camada do payload em `.omp/` deste repositório e gera
  `.agents/skills` a partir das skills ligadas. `--unlink` desfaz os dois.
- **`vendor-sync verify`.** Confere, na camada: nome do frontmatter igual ao do
  arquivo ou da pasta, todo caminho citado existe, e toda skill em `autoloadSkills`
  existe no payload e não tem trava de invocação — a mesma checagem que os agentes
  já têm.
- **Documentação.** README ganha uma seção curta sobre o omp e o Codex; o
  `overview.md` cita a camada de harness. Glossário e ADR-0011 já estão escritos.

## Testing Decisions

Um bom teste aqui observa o que o operador veria: arquivos em `.omp/` e em
`.agents/skills`, linhas do lock, um comando bloqueado ou liberado, a ordem em que
os tickets foram despachados. Não confere redação de skill nem quantidade de
linhas.

O repositório não tem suíte. Os três seams já existem.

### S1 — `reset-install.sh` sobre projeto de fixture

Com `HOME` e `PATH` controlados, `--dry-run` e execução sobre um projeto de
fixture. Casos:

- sem nenhum sinal: nenhum `.omp/`, nenhuma linha `omp:`;
- com `omp` no `PATH`, e separadamente com `~/.omp/`: camada instalada, linhas
  `omp:` no lock;
- lock com `omp:` e máquina sem omp: camada mantida e atualizada;
- arquivo retirado da camada no payload novo: sai do `.omp/` e do lock;
- arquivo alheio em `.omp/`: intacto; arquivo do usuário com caminho da camada:
  aparece como colisão;
- `.agents/skills`: um symlink por `skill:`, órfão removido, skill própria do
  usuário intacta, diretório real com nome do payload como colisão;
- sem lock: nada apagado em `.omp/` nem em `.agents/skills`;
- modo de camadas chamado pelo boot produz o mesmo resultado que o update.

Prior art: `workspace/03-reset-install`, `workspace/12-payload-agents/run.sh`.

### S2 — sessão real do omp, headless

`omp -p --mode json` num repositório de fixture, com o turno guardado em `.jsonl`
como o `turn.sh` já faz com o `claude -p`. Casos:

- guarda: `git merge` de spec com ticket aberto bloqueado com o motivo do script;
  spec arquivada liberada; branch sem número liberado; `tea pr create` sem archive
  bloqueado;
- `anvil-run`: spec de fixture com três tickets e uma aresta de bloqueio despachada
  em série na ordem certa; ticket com `Review: round=2 … verdict=fail` pulado e seu
  dependente listado como pendente; fora do branch da spec, recusa; tudo resolvido
  sem `ui/` recomenda archive, com `ui/` recomenda browser QA;
- `anvil-plan`, em vários turnos: depois do grill confirmado propõe `to-spec` e não
  carrega sem sim; com sim, carrega na mesma janela; chamada de novo com `spec.md` no
  disco retoma na sugestão de `to-tickets`.

**Limite.** Não dá para forçar um P1 de forma determinística. O caso de ticket
travado parte de fixture com a linha `Review:` já gravada: prova que o supervisor lê
o estado e pula, não que o review gera a segunda reprovação.

Prior art: `workspace/16-distill/turn.sh`, `workspace/23-team-parallel`.

### S3 — `vendor-sync.sh verify`

A checagem da camada falha num fixture com nome divergente, caminho citado
inexistente ou `autoloadSkills` apontando para skill com trava, e passa no payload
real.

Prior art: a checagem de agentes do `vendor-sync.sh verify`.

### Ponta a ponta

Um projeto descartável em `workspace/`: degit do payload local, `/skill:anvil-boot`
no omp, `/skill:anvil-plan` até os tickets e `/skill:anvil-run` até o relatório.

## Out of Scope

- **Frontier em paralelo** com worktree isolado. Fica como linha no tracker, para
  medir depois do modo em série.
- **Modelo por papel no omp.** O implementer herda o modelo da sessão. As listas
  `runners`, `how-critics` e `cross-judge` do `.claude/rules/anvil.md` não têm efeito
  no omp, porque o `task` não aceita modelo por chamada.
- **Automação no Claude Code ou no Codex.** Os dois seguem manuais.
- **Guarda no Codex** e guarda para comando disparado pelo `eval` do omp.
- **Pi puro** e qualquer outro harness.
- **Browser QA, archive e PR disparados pelo supervisor**, e o laço de correção
  depois do QA.
- **Agente `anvil-qa`** e extensão TypeScript com `registerCommand`.
- **Mudança em skill vendorizada.**
- **Espelho `.agents/skills` em sistema sem symlink.**

## Further Notes

- Comportamento do omp conferido na documentação embutida do omp 18.2.11 em
  2026-09-23: descoberta de skills, rules e agentes, evento `tool_call`, limite de
  recursão do `task`, modo `-p`. A API de extensão muda com o omp; o hook de guarda é
  a peça mais exposta.
- Ordem dos tickets: primeiro a compatibilidade — espelho, lock, detecção, guarda,
  rule, manual —, depois `anvil-implementer` e `anvil-run`, por último `anvil-plan`.
- Origem: `docs/discovery/adaptar-omp-ao-anvil.md`. O que entrou e o que não entrou
  dele, e o desenho do fluxo, estão em `docs/discovery/camadas-anvil-omp.md` e no
  ADR-0011.
- Glossário: *Harness*, *Camada de harness* e *Condutor* em
  `docs/architecture/context.md`.
