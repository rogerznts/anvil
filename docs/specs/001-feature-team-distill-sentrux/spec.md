# 001 — Equipe, destilação e sentrux

**Status:** ready-for-agent

## Problem Statement

Quem usa o anvil sem o Maestri conduz o fluxo sozinho. A equipe de papéis que
funciona no Maestri — PO, Architect, Analyst, Designer, Dev, Tester e Review,
coordenados por um Leader, com gates que o autor não controla — não tem como
existir numa sessão comum do Claude Code. O usuário vira o roteador de cada
especialista, papel por papel.

Portar uma funcionalidade de outro sistema não tem método. O agente lê o sistema
de referência, parafraseia o que entendeu e reinventa o resto. Quem implementa
depois não tem como conferir de onde veio cada afirmação, e o acoplamento da stack
de origem entra junto com a funcionalidade.

A instalação atrapalha o projeto. O boot ignora `.claude/skills/` inteiro, e as
skills que o usuário escreve nesse diretório somem do git. O perfil de domínio
escrito pelo `anvil-setup` manda ler um glossário e ADRs em caminhos que o anvil
não usa. O manifesto não registra uma adaptação que existe de fato, então o
próximo update não vai avisar quando o upstream mexer nessas linhas.

As decisões de arquitetura ficam em prosa. Um ADR que decide uma fronteira entre
camadas não quebra nada quando alguém a atravessa, e nada acusa quando uma sessão
de implementação degrada a estrutura do código.

E o mantenedor não consegue refazer a métrica que o README exibe, nem trabalhar
neste repositório pelo fluxo que o anvil publica.

## Solution

**Uma equipe sob demanda.** O usuário chama a skill `anvil-team` e passa a
conversar com o Leader. O Leader despacha os sete papéis como agentes, calcula a
frontier a partir dos tickets, e os papéis conversam entre si pelo recurso de
*agent teams* do Claude Code. Os julgamentos de Tester e Review chegam ao Leader
diretamente. Em features grandes, o Leader mantém um bloco de notas objetivo
dentro da spec. Sem *agent teams* ligado, a skill para e diz o que falta.

**Destilação com ponteiros.** O usuário chama o `anvil-distill` com um sistema de
referência — uma pasta já presente ou a URL de um repositório. Em background, o
distill produz um documento que mapeia a funcionalidade, cita o código de origem
literalmente com `caminho:linha`, traduz cada conceito para a stack do projeto e
lista o que não deve ser portado. Ele não escreve código.

**Instalação que não atrapalha.** O gitignore passa a cobrir exatamente o que o
anvil instalou — skills e agentes —, gerado a partir do lock. Skill e agente do
usuário ficam versionados. O update instala e remove agentes como já faz com
skills. O perfil de domínio aponta para onde o anvil guarda glossário e ADRs, e o
manifesto registra o que foi adaptado.

**Arquitetura que se verifica.** A skill opcional `anvil-sentrux` instala o sensor
sentrux com aprovação, propõe regras de camada e fronteira a partir dos ADRs e
oferece uma comparação estrutural antes e depois de uma sessão de implementação.

**Um repositório que segue o próprio fluxo.** A métrica do README passa a ter
comando e definição, e as rules deste repositório descrevem o fluxo por branch de
spec com merge local.

## User Stories

### Instalação e curadoria

1. Como usuário do anvil, quero que as skills que eu escrevo em `.claude/skills/` continuem versionadas depois do boot, para não perdê-las do repositório.
2. Como usuário do anvil, quero que o gitignore cubra exatamente o que o anvil instalou — skills e agentes, inclusive as `tea-*` —, para que o toolkit não engorde o histórico.
3. Como usuário com um projeto já bootado, quero que o boot troque a linha antiga que ignorava `.claude/skills/` inteiro, mostrando o antes e o depois, para corrigir sem editar à mão.
4. Como usuário que escreveu uma linha parecida por conta própria, quero que o boot não mexa nela, para que a minha configuração não seja reescrita.
5. Como usuário, quero que o update regenere o bloco do gitignore a cada reinstalação, para que uma skill órfã removida também saia do ignore.
6. Como usuário que roda o boot, quero que o passo do issue tracker rode sem eu precisar digitar comando nenhum, para que o boot termine de uma vez.
7. Como agente que explora o código, quero que o perfil de domínio aponte para o glossário e os ADRs onde o anvil os guarda, para ler o que existe em vez de procurar arquivos que não existem.
8. Como mantenedor, quero que toda adaptação feita no `anvil-setup` esteja registrada no manifesto, para que o update sinalize conflito quando o upstream mexer nessas linhas.
9. Como mantenedor, quero medir com um comando quantas linhas nossas diferem do upstream, para que a métrica do README possa ser refeita por qualquer pessoa.
10. Como mantenedor, quero que a definição de "linha nossa" esteja escrita junto do comando, para que duas medições comparem a mesma coisa.
11. Como leitor do README, quero ver o comando e a data da medição ao lado do número, para saber quão atual ele é.
12. Como usuário, quero que o update instale, substitua e remova os agentes do payload como já faz com as skills, para que um agente descontinuado não fique no disco.
13. Como usuário que escreveu um agente próprio, quero que o update não o apague, para que meu trabalho sobreviva à reinstalação.
14. Como usuário vindo do mosk, quero que a migração remova só as personas do mosk, para que os agentes do anvil e os meus fiquem.
15. Como mantenedor, quero que o verify reprove um lock que não cubra os agentes do payload, para que o update não os trate como alheios em silêncio.
16. Como mantenedor, quero que o verify reprove um agente que cite um caminho inexistente, para que um protocolo renomeado não quebre a equipe sem aviso.
17. Como mantenedor deste repositório, quero que os agentes do payload também fiquem ligados aqui, para construir o anvil com a equipe que ele distribui.

### Destilação

18. Como usuário, quero pedir a destilação de um sistema de referência que já está em `references/`, para portar uma funcionalidade dele para a minha stack.
19. Como usuário, quero passar a URL de um repositório e as direções do que me interessa, para que o anvil baixe o sistema e destile sem eu clonar à mão.
20. Como usuário que passa uma URL, quero escolher se o sistema entra passageiro, fora do git, ou versionado, como submodule, com o passageiro sugerido, para decidir quanto desse sistema fica no meu projeto.
21. Como usuário, quero que um sistema passageiro fique fora do git sem que o gitignore do projeto mude, para que ele não apareça no status nem vá para o repositório.
22. Como usuário com a pasta do sistema já presente, quero que o distill use o que está lá sem atualizar, para que a destilação reflita a versão que eu estudei.
23. Como usuário de um repositório privado, quero que o distill use a credencial que o meu git já tem, para nunca digitar senha para ele.
24. Como usuário, quero que a destilação registre o commit ou o pin do sistema de referência, para saber a que versão os ponteiros se referem.
25. Como agente que vai implementar, quero ponteiros `caminho:linha` com o trecho citado literalmente, para reabrir e conferir em vez de confiar numa paráfrase.
26. Como agente que vai implementar, quero o mapa da funcionalidade — por onde o dado entra e por onde sai —, para entender o recorte antes de abrir o código.
27. Como agente que vai implementar, quero cada conceito classificado como equivalente direto, equivalente com adaptação, sem equivalente ou não portar, para saber o que reusar e o que construir.
28. Como agente que vai implementar, quero o ponteiro do equivalente que já existe no meu projeto, para conferir a tradução dos dois lados.
29. Como usuário, quero uma seção do que não portar, para que o acoplamento da stack de origem não entre junto.
30. Como usuário, quero as perguntas abertas no fim da destilação, para levá-las ao grill.
31. Como usuário, quero que o distill descubra a stack lendo o código e aponte quando a rule do projeto disser outra coisa, para que a tradução se baseie no que o projeto realmente é.
32. Como usuário no meio de um grill, quero que o distill rode em background e devolva só o caminho e um resumo curto, para que a janela do fluxo não se encha com o código lido.
33. Como usuário, quero que a destilação caia na spec quando eu estiver num branch de spec e na base quando não estiver, para que ela vá para o lugar certo sem eu dizer.
34. Como usuário, quero um arquivo por destilação, nomeado pelo sistema e pela funcionalidade, para achar e referenciar cada uma.
35. Como usuário, quero a garantia de que o distill não altera o meu código nem o sistema de referência, para usá-lo em qualquer momento sem medo.

### Equipe

36. Como usuário sem o Maestri, quero chamar uma skill e ter uma equipe de papéis trabalhando na minha feature, para não conduzir cada especialista à mão.
37. Como usuário, quero conversar só com o Leader, para ter um ponto único de decisão.
38. Como usuário sem *agent teams* ligado, quero que a skill pare e mostre a configuração que falta, para entender por que ela não roda.
39. Como Leader, quero despachar PO, Architect, Analyst, Designer, Dev, Tester e Review, cada um com a sua especialização, para distribuir o trabalho.
40. Como papel, quero conversar diretamente com outro papel, para esclarecer uma dúvida sem passar tudo pelo Leader.
41. Como Leader, quero receber os julgamentos de Tester e Review diretamente, mesmo quando o Dev discorda, para que o autor não controle o gate que o avalia.
42. Como Leader, quero calcular a frontier a partir dos tickets, para despachar só o que está desbloqueado.
43. Como Leader numa feature grande, quero um bloco de notas dentro da spec, para registrar objetivo, quem escreve o quê, gates, bloqueios, decisões abertas, riscos e próximo passo entre uma sessão e outra.
44. Como mantenedor, quero que esse bloco de notas nunca carregue fase nem status, para que o estado continue sendo lido dos tickets.
45. Como papel, quero findings, repros e divergências anotados nos comentários do ticket, para que o próximo papel leia o histórico ali.
46. Como papel, quero receber na delegação o objetivo, o contexto, a skill, o escopo, a política de escrita, o critério de pronto e o que devolver, para trabalhar sem adivinhar.
47. Como papel, quero um protocolo único e compartilhado, para que todos sigam as mesmas regras de ownership, paralelismo, verificação e divergência.
48. Como usuário, quero que o Review não consiga editar arquivos, para que o gate de revisão não vire autor.
49. Como usuário, quero configurar o modelo de cada papel nas rules do projeto, para equilibrar custo e qualidade sem editar arquivo do toolkit.
50. Como Leader, quero isolar dois escritores em paralelo em worktrees e integrar o resultado, para que um não sobrescreva o outro.
51. Como usuário, quero que um pedido comum numa conversa — "revisa esse diff" — não caia num papel da equipe, para que a equipe só exista quando eu a chamo.
52. Como papel, quero despachar as skills do fluxo e as que abrem subagentes, para usar a capacidade certa dentro da minha tarefa.
53. Como mantenedor, quero que toda skill citada pelos papéis exista no payload, para que nenhum papel seja roteado para o vazio.

### Sentrux

54. Como usuário, quero que o anvil confira se o sentrux está instalado e em qual versão, para saber se posso usá-lo.
55. Como usuário, quero ver o comando de instalação com a versão fixada e aprovar antes, para controlar o que entra na minha máquina.
56. Como usuário, quero instalar o sentrux sem `sudo`, para não dar privilégio de administrador a um instalador de terceiro.
57. Como usuário, quero ser avisado de que o upstream não publica checksum, para decidir com a informação completa.
58. Como usuário, quero escolher registrar o servidor MCP no projeto ou só para mim, com o projeto sugerido, sabendo que quem clonar sem o binário verá o servidor falhar.
59. Como usuário, quero que as camadas e fronteiras decididas nos ADRs virem regras que o sentrux verifica, com o motivo apontando o ADR, para que uma decisão de arquitetura quebre algo quando violada.
60. Como usuário, quero aprovar a proposta de regras antes de ela ser escrita, para que nada entre no projeto sem eu ver.
61. Como usuário, quero salvar uma linha de base antes de uma sessão de implementação e comparar depois, para ver se aquela sessão piorou a estrutura.
62. Como Review, quero consultar o sentrux pela linha de comando, para ter evidência estrutural sem ferramenta extra liberada.
63. Como usuário, quero que nada no fluxo dependa do sentrux, para usá-lo só quando eu quiser.

### Este repositório

64. Como mantenedor, quero que a rule do projeto descreva o fluxo por branch de spec com merge local, para que agentes não mandem trabalho de spec direto na `main`.
65. Como mantenedor, quero que a rule distinga upstream vendorizado de sistema de referência, para que ninguém trate uma pasta passageira como base de merge.
66. Como mantenedor, quero que o README e o overview parem de dizer que o anvil não tem agentes, para que a documentação conte o que o payload distribui.
67. Como mantenedor que fecha uma spec com merge local, quero que a guarda bloqueie o `git merge` do branch da spec disparado de qualquer lugar, inclusive da `main`, para que a garantia não dependa de eu lembrar de onde rodar o comando.
68. Como usuário com um projeto antigo que guarda o glossário na raiz ou ADRs em `docs/adr/`, quero que o boot perceba e me proponha mover para o layout do anvil, para que meu glossário não seja ignorado em silêncio.

## Implementation Decisions

### Instalação e curadoria

- **`anvil-setup`.** O seed do perfil de domínio recebe `docs-remap` nos caminhos
  do glossário, do mapa de contextos e dos ADRs, e `rename` nas referências a
  skills adotadas. A referência a `improve-codebase-architecture`, que não foi
  adotada, fica verbatim, como o catálogo manda. No manifesto, o `adapt` do
  `anvil-setup` passa a ser `rename`, `docs-remap`, `tracker-profile` e `invocable`.
- **Regra `tracker-profile`.** Regra de julgamento nova no catálogo, estreita: a skill
  de setup oferece o perfil de tracker do `anvil-docs`, como decide o ADR-0002.
  Registra as linhas que o anvil acrescentou ao setup e que o `docs-remap` não cobre.
- **Passo do issue tracker no boot e no scaffold.** O texto não muda. A regra
  `invocable` (`c8e99de`) já tornou a instrução executável.
- **Bloco de gitignore.** Delimitado por `ANVIL:INSTALLED:START` e `END`, com uma
  linha por skill e por agente do lock — nunca por prefixo, porque as `tea-*`
  quebram o prefixo. Uma função única no `reset-install` gera o bloco: o update a
  chama depois de gravar o lock, e o modo `--gitignore-only` lê o lock existente e
  reescreve só o bloco, que é o que o boot usa.
- **Linha antiga.** O boot procura a linha que ignorava `.claude/skills/` pelo
  comentário exato que ele mesmo escreveu. Achando, mostra o antes e o depois e
  troca com aprovação. Linha sem esse comentário não é tocada.
- **Lock.** Ganha linhas `agent:` ao lado de `skill:`. Um leitor antigo ignora as
  linhas novas e deixa de reconhecer os agentes como do anvil — o lado seguro,
  porque então não apaga nenhum.
- **`reset-install`.** Ganha um segundo laço, por arquivo, sobre os agentes do
  payload, com a mesma classificação das skills: substituídos, órfãos, alheios e
  preservados.
- **`vendor-sync`.** A geração do lock emite `agent:`. O `verify` ganha duas
  checagens: o lock cobre os agentes do payload, e todo caminho citado por um
  agente existe.
- **`vendor-sync stats`.** *Linha nossa* é a linha presente no payload e ausente da
  versão do pin, contada só em arquivos que existem dos dois lados. Arquivos `keep`
  e `extra` são contados à parte, e `strip` não conta. A definição fica escrita no
  próprio script. O README passa a citar o comando e a data da medição.
- **`dev-link`.** Liga também os agentes do payload neste repositório.
- **Migração do mosk no boot.** Remove só as personas do mosk dentro de
  `.claude/agents/`, não o diretório.
- **Documentação de domínio antiga fora de `docs/`.** O passo 5 do boot trata
  `CONTEXT.md` e `CONTEXT-MAP.md` na raiz, e `docs/adr/`, como gatilho do `adopt`.
  Achado no gate do ticket 02: depois do remapeamento do `anvil-setup`, esses arquivos
  deixavam de ser notados.
- **Guarda de merge.** Identifica a spec também pelo branch nomeado no `git merge`,
  não só pelo branch atual. Achado durante a implementação: rodado na `main`, o merge
  local passava com ticket aberto.

### `anvil-distill`

- **Skill autoral**, sem trava de invocação. Registrada no manifesto e no README
  como fora do sync.
- **Entrada.** Um caminho local — por padrão, uma pasta em `references/` — e,
  opcionalmente, a funcionalidade. Ou a URL de um repositório com direções.
- **URL.** O distill pergunta como o sistema entra, sugerindo passageiro:
  *passageiro* é clone raso, com uma linha de exclusão local do git por pasta,
  sem tocar o gitignore do projeto; *versionado* é submodule, e a mudança nos
  submodules fica para o usuário commitar. Pasta já presente: sem pergunta e sem
  atualizar. Repositório privado usa a credencial que o git da máquina já tiver.
- **Execução.** Subagente em background, que devolve só o caminho do documento e
  um resumo de três linhas.
- **Destino.** Branch com prefixo numérico: a pasta de discovery da spec. Qualquer
  outro branch: a discovery da base. É a mesma resolução por prefixo numérico que
  a guarda de merge usa. Uma spec criada depois aponta para a destilação; ela não
  é movida.
- **Nome.** `distill-{sistema}` ou `distill-{sistema}-{funcionalidade}`, um
  arquivo por destilação. Sistema grande vira várias destilações.
- **Formato — seis seções.**
  1. *Origem*: o sistema, onde está e a versão — commit do clone ou pin do
     submodule. Sem versão verificável, declara que não há.
  2. *Mapa da funcionalidade*: os seams, por onde o dado entra e sai.
  3. *Ponteiros verificáveis*: `caminho:linha` com o trecho citado literalmente.
  4. *Tradução para a stack*: cada conceito em uma de quatro classes —
     equivalente direto, equivalente com adaptação (dizendo o que difere), sem
     equivalente (vira pergunta aberta) e não portar. Equivalente que já existe no
     projeto leva o próprio ponteiro.
  5. *O que não portar*: acoplamento, dependência e decisão que eram da stack de
     origem.
  6. *Perguntas abertas*.
- **Stack.** Lida do código — manifestos, configuração, imports. A rule do projeto
  serve de atalho quando existe; divergência entre as duas é apontada.
- **Política de escrita, como invariante no texto da skill.** Escreve em `docs/` e
  cria a pasta em `references/`. Nunca altera o sistema de referência depois de
  baixado, nem o código do projeto.

### `anvil-team` — ver ADR-0007

- **Leader** é a skill `anvil-team`, na sessão principal. Os papéis são os agentes
  `anvil-team-po`, `anvil-team-architect`, `anvil-team-analyst`,
  `anvil-team-designer`, `anvil-team-dev`, `anvil-team-tester` e
  `anvil-team-review`.
- **Pré-condição.** A skill confere a variável de *agent teams* ao abrir. Sem ela,
  para e mostra a configuração que falta. Não há modo degradado, e o boot não liga
  o recurso.
- **Descriptions dos agentes** declaram, logo no começo, que só são despachados
  pela `anvil-team`, e não descrevem tarefas que atraiam delegação automática. O
  que o papel faz fica no corpo.
- **Protocolo único** dentro da skill, portado do protocolo de equipe usado no
  Maestri, sem as partes específicas dele: visibilidade de notas, erro de conexão
  com nota e bootstrap do toolkit pelo Leader. O arquivo de cada papel guarda só o
  que é daquele papel.
- **Comunicação.** Os papéis trocam mensagens diretamente pelo *agent teams*. Os
  julgamentos de Tester e Review chegam ao Leader diretamente. Findings, repros e
  divergências ficam registrados nos comentários do ticket.
- **Frontier** derivada dos tickets, sempre.
- **Mission Control.** Um arquivo `mission-control` dentro da pasta da spec, criado
  pelo Leader só em feature grande. Seções: objetivo e resultado esperado, trabalho
  em execução e ownership de escrita, gates com evidência, bloqueios, decisões
  abertas, riscos e próximo passo. Não tem coluna de estado na frontier nem estado
  global. Um aviso no topo diz que ele não é fonte de estado. Os papéis não o leem:
  recebem o contexto na delegação.
- **Delegação** com os sete campos: objetivo, contexto, skills, escopo, política de
  escrita, critério de pronto e retorno.
- **Ferramentas.** Só o Review declara allowlist: leitura, `Bash`, `Agent`, `Skill`,
  `SendMessage` e `ToolSearch`, sem `Edit` e `Write`. Os demais papéis herdam tudo.
- **Trava de invocação na `anvil-team`**: só o usuário abre a equipe.
- **Forma detalhada** em `architecture/team-shape.md`, dentro da pasta desta spec.
- **Modelo.** Nenhum agente fixa modelo. A rule do anvil ganha a lista `team`, de
  papel para modelo, que o Leader passa na chamada. Sem esse suporte, o papel usa o
  modelo da sessão.
- **Isolamento.** Nenhum agente fixa isolamento. O Leader passa worktree ao
  despachar dois escritores em paralelo e integra o resultado no branch da spec
  antes do gate seguinte.
- **Skills citadas pelos papéis** corrigidas no port: `anvil-debug` →
  `anvil-diagnose`, `anvil-test` → `anvil-tdd`, `anvil-review` →
  `anvil-code-review`.

### `anvil-sentrux`

- **Skill autoral**, opcional e fora do fluxo. A skill `scan` do upstream não é
  adotada: ela é a lista de ferramentas que o MCP já expõe, e contradiz o README do
  projeto. O motivo fica registrado no manifesto.
- **Detecção** do binário e da versão instalada.
- **Instalação** com aprovação e versão fixada, sem `sudo`: pelo tap do Homebrew no
  macOS; no Linux, o binário da release no diretório de binários do usuário, sem o
  instalador oficial. A skill avisa que o upstream não publica checksum e registra
  a versão instalada.
- **MCP.** Oferece registrar no projeto, sugerido, ou só para o usuário. Ao sugerir
  o projeto, avisa que quem clonar sem o binário verá o servidor falhar.
- **Regras.** Propõe o arquivo de regras do sentrux com camadas e fronteiras
  extraídas dos ADRs, cada uma com o motivo apontando o ADR. Escreve só com
  aprovação.
- **Gate.** Oferece salvar a linha de base antes de uma sessão de implementação e
  comparar depois. Nada no fluxo o chama.
- **Review** usa o sentrux pela linha de comando; a allowlist dele não muda.

### Este repositório

- **Rule do projeto.** Fluxo git: spec em branch `{tipo}/{NNN}-{nome}`, fechada
  com archive e merge local na `main`, sem PR; trabalho sem spec vai direto na
  `main`. `references/` passa a distinguir upstream vendorizado — submodule com
  pin, base do merge 3-way — de sistema de referência.
- **README e overview.** Passam a dizer que o anvil distribui agentes e a skill de
  equipe, e a métrica ganha comando e data.
- **Glossário e ADR-0007**, escritos no grill desta spec, entram no mesmo branch.

## Testing Decisions

- **Um bom teste verifica comportamento observável**: a saída de um script, o que
  ficou no disco, o que a skill perguntou antes de escrever. Nunca o texto interno
  de uma skill.
- **Não há ponto de teste novo.** Os cenários continuam manuais, como os que já
  existem em `workspace/`, e cada ticket declara o cenário que o prova.

### Ponto A — scripts

`vendor-sync verify`, `vendor-sync stats` e `reset-install --dry-run`, contra o
payload e contra um projeto descartável.

- O `verify` reprova um lock sem os agentes do payload e um agente que cita caminho
  inexistente; as checagens que já existem, incluindo a da trava de invocação,
  continuam passando.
- O `stats` dá o mesmo resultado em duas execuções, e uma skill cujo único delta é
  o `rename` mede exatamente uma linha nossa.
- O `reset-install --dry-run` classifica agente do payload como substituído ou
  órfão e agente do usuário como alheio. O bloco gerado lista skills e agentes,
  inclusive as `tea-*`. O modo `--gitignore-only` reescreve só o bloco, e rodar
  duas vezes não muda nada.
- A linha do `anvil-setup` no manifesto tem `docs-remap` e `tracker-profile`, o
  `vendor-sync` sinaliza `tracker-profile` para revisão, e o `verify` sai limpo.
- A guarda bloqueia o `git merge` de uma spec aberta disparado do branch da spec e da
  `main`, e libera os dois depois do archive.

### Ponto B — skills num projeto descartável

- **Isolamento:** todo `claude -p` rodado num projeto dentro de `workspace/` exclui o
  `CLAUDE.md` e as rules do repositório pai, que de outro modo contaminam o teste.
- **Boot:** o passo do issue tracker roda sem intervenção. Projeto com a linha
  antiga e o comentário recebe a proposta de troca; linha sem o comentário fica
  intocada. A migração do mosk remove só as personas dele.
- **`anvil-setup`:** o perfil de domínio escrito aponta para o glossário e os ADRs
  do anvil.
- **`anvil-distill`:** destila um sistema local, uma URL passageira (fora do
  status do git, com o commit na Origem) e uma URL versionada (submodule, com o
  pin). O documento tem as seis seções; cada ponteiro abre e contém o trecho
  citado; nada fora de `docs/` e da pasta criada em `references/` é alterado. Em
  branch com número, cai na spec; sem número, na base.
- **`anvil-team`:** sem a variável, para e mostra a configuração. Com ela, despacha
  um papel, uma mensagem entre papéis chega, o julgamento do Review chega ao Leader
  e fica o comentário no ticket. Um "revisa esse diff" fora da skill não cai em
  papel nenhum. O Review não consegue editar.
- **`anvil-sentrux`:** sem o binário, mostra o comando com a versão fixada e
  espera. Com o binário, detecta a versão. Um ADR com fronteira gera a proposta de
  regra com o motivo apontando para ele. O gate salva e compara.

### Ponta a ponta

O merge local desta spec na `main` passa pela guarda de merge de verdade: bloqueia
com ticket aberto ou spec fora de `archive/`, e libera depois do archive.

### Prior art

`workspace/03-reset-install` e `workspace/08-lock` para os scripts;
`workspace/05-boot` e `workspace/07-scaffold` para as skills;
`workspace/04-hook-merge` e o modo de decisão isolada da guarda para o merge.

## Out of Scope

- **`anvil-obscura`** e o navegador obscura: considerados e descartados.
- **Codex** como executor de papel.
- **Modo degradado** da equipe sem *agent teams*, e o boot ligar o recurso.
- **Verificador de ponteiros** que reabre cada `caminho:linha` de uma destilação.
- **Sentrux como insumo do distill**, com `scan` ou `dsm` alimentando o mapa.
- **Runner automatizado** para os cenários de `workspace/`.
- **Mover uma destilação** da base para a spec depois que a spec nasce.
- **A regra `invocable`** e a remoção da trava das sete skills que a equipe
  despacha: entregues em `c8e99de`. As outras sete skills travadas no upstream
  continuam travadas.

## Further Notes

- **Premissas medidas no Claude Code 2.1.270**, a reverificar a cada versão: um
  subagente consegue despachar outro, o que não está documentado; agentes trocam
  mensagem direta com *agent teams* ligado, um recurso experimental; modelo e
  isolamento podem ser passados por chamada.
- **Riscos.** *Agent teams* é experimental e pode mudar. O sentrux não recebe merge
  desde março de 2026 e tem aberto um bug que inventa ciclos que não existem.
  Nenhum dos binários instalados pelo anvil publica checksum.
- **Acoplamentos.** A equipe depende de o lock e o `reset-install` saberem instalar
  agentes, e do bloco de gitignore cobri-los. O distill pode ser despachado pelo
  Analyst, mas não depende da equipe.
- **O material de origem da equipe** é um sistema de referência passageiro, fora do
  git. O port grava nos agentes e no protocolo tudo o que precisa, porque a pasta
  pode ser descartada.
- **A métrica atual do README não reproduz.** Medido nesta spec: 34 skills, 21.954
  linhas, 241 linhas nossas e 16 skills com uma linha de delta, contra 35, 25.064,
  171 e 21 no README.
- **Vocabulário** em `docs/architecture/context.md`; decisão de arquitetura da
  equipe no ADR-0007.
