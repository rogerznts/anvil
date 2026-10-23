---
name: anvil-bench
description: "Leva alguém que não é técnico de 'preciso de uma ferramenta interna' até a ferramenta rodando e testada, sem nenhuma decisão técnica pelo caminho. Use quando o pedido for uma ferramenta de uso interno — cadastro, controle, acompanhamento — e quem pede não programa. Também para evoluir uma ferramenta que o bench já criou."
---

# Bench

Uma pessoa que não programa descreve o que precisa, em português comum, e recebe
uma ferramenta funcionando. Nada de técnico aparece na conversa.

O bench é o **modo**; a tecnologia por baixo é uma **stack plugada**. Hoje a
stack ativa é o Payload. Raciocine em termos de "a ferramenta", "os módulos", "as
regras" — nunca amarre o que você diz a uma tecnologia.

## As duas regras que valem sempre

**Nunca faça alguém leiga tomar decisão técnica.** Toda escolha técnica é
resolvida por convenção — os scripts do adapter, o starter versionado — ou
sozinha, na fase de construção. Bifurcação técnica no meio da conversa:
**escolha o default seguro e avise em linguagem simples.** Nunca pergunte.

**Toda saída ao usuário é português simples, sem jargão.** Nunca diga o nome da
tecnologia, "porta", "container", "banco", "migration", "YAML" ou "commit". Fale
de "cadastros", "informações", "quem pode usar", "regras", "o endereço da
ferramenta".

As invariantes completas do produto gerado (INV-1..6) estão na skill
`anvil-stack-payload`, arquivo `bench/INVARIANTS.md`. Carregue antes de começar.

## Sob o piloto automático

No omp, o piloto automático, a skill `anvil-auto`, entra pelo bench quando o
projeto tem a rule da stack com a seção das invariantes do bench, ou quando é
chamado com `--bench`. Ele carrega esta skill para a entrada e conduz o resto:

- As fases 1 a 3 rodam como estão, até a pessoa confirmar o roteiro em português
  simples. O projeto já é um repositório git, que a largada do piloto exige: a
  fase 2 não roda o `git init`, e nem ela nem a fase 4 commitam. O commit do
  starter, da rule da stack, dos perfis e do combinado é do piloto, um só, depois
  do sim, com a rule já atualizada com os módulos e os papéis reais.
- O ledger de cada spec, da fase 4, é o piloto que roda, no começo de cada spec,
  e ele também escreve o `decisions-log.md` de cada uma.
- A fase 5 é a corrente do piloto: ele despacha os tickets, roda o comando do
  [GATE.md](GATE.md) como supervisor, lê a saída pela seção "Sob o piloto
  automático" de lá, onde mora a regra do gate manual aberto, e fecha a spec.
  *Uma entrada do roteiro* não roda, e a fase 6 é o fim do piloto, em português
  simples.

## Fluxo

### 1. Preparar

Rode o validador e o provisionador da stack, da instalação de usuário, no
diretório do projeto:

```
bash ~/.claude/skills/anvil-stack-payload/bench/env.sh
bash ~/.claude/skills/anvil-stack-payload/bench/infra.sh --provision "<nome>"
```

Traduza só o progresso. Em falha, diga qual requisito falta **sem** mostrar
comando, porta, banco ou container. Confirmação humana só para instalar
requisito externo.

Projeto que já tem alocação: **reuse**, não reprovisione.

### 2. Reconhecer

Starter presente mais a rule da stack indicam projeto existente. Nele, o disco
decide o ramo.

Antes de qualquer ramo, procure uma **spec aberta**: uma pasta de
`docs/specs/`, fora de `docs/specs/archive/`, com algum ticket em `issues/` cujo
`Status:` não é `resolved`. Achou, a construção segue por ela, sem entrevista,
com ou sem `docs/qa/checklist.yaml`, e nenhum dos ramos abaixo vale:

- sem o `gates.md` na pasta da spec, retome pela fase 4: o ledger dessa spec e,
  se ainda não há o `docs/qa/checklist.yaml`, antes dele o briefing e o checklist,
  como no ramo da construção começada fora do bench;
- com o `gates.md`, siga direto para a fase 5, pelos tickets ainda não
  `resolved`.

O checklist que uma retomada já commitou no branch da spec não faz dela uma
ferramenta a evoluir.

Sem essa spec:

- **Ferramenta que o bench construiu**, com o `docs/qa/checklist.yaml` da fase 4:
  vá direto ao delta — ver *Evoluir uma ferramenta*, abaixo.
- **Construção começada fora do bench**, sem o `docs/qa/checklist.yaml` e sem
  `gates.md` na spec, com uma spec aberta, fora de `docs/specs/archive/`:
  **retome refazendo só a fase 4**, a partir da spec e dos tickets que existem. A
  fase 3 não roda: o `briefing.md` e o `checklist.yaml` saem do que a spec e os
  tickets já dizem, com o critério de pronto deles escrito como resultado, como
  pede o [CHECKLIST.md](CHECKLIST.md), e vão para os mesmos caminhos da fase 4,
  commitados no branch da spec junto do ledger. Sem roteiro, o `gates.md` dessa
  spec leva todos os itens do checklist. Na fase 5, o que existe não se refaz: a
  spec e os tickets ficam, e a construção segue pelos tickets ainda não
  `resolved`.
- **Construção começada fora do bench, sem spec aberta**: a fase 3 vira
  **entrevista do delta**. Leia o código e os documentos que o projeto já tem, e
  pergunte só o que eles não respondem. Depois, as fases 4 e 5 seguem como num
  projeto novo.

Numa retomada, o ponto em que ela entrou — a fase 4 ou a fase 5 sobre a spec
existente, ou a fase 3 como entrevista do delta — vai para o `decisions-log.md`,
com a spec de onde partiu quando há uma, e para a entrega da fase 6.

Projeto novo: copie o starter **as-is**, sem regenerar, inicialize o git com o
branch `main` (`git init -b main`), materialize o `.env` com a alocação, gere
`.claude/rules/payload.md` a partir do `RULE.md` da stack mais a seção de
invariantes, e instale os dois perfis que o bench e as skills de fluxo leem, a
partir dos templates do `anvil-docs`, da instalação de usuário:

| Perfil | Template |
|---|---|
| `docs/agents/issue-tracker.md` | `~/.claude/skills/anvil-docs/templates/issue-tracker-anvil.md` |
| `docs/agents/verification.md` | `~/.claude/skills/anvil-docs/templates/verification-anvil.md` |

É a regra do `scaffold` do `anvil-docs`: ausente, copie; idêntico, siga; divergente,
não sobrescreva e não pergunte, que o perfil do projeto fica. Commite tudo isso na
`main` como o primeiro commit. O `.env` fica fora dele, pelo `.gitignore` do
starter. Sob o piloto automático, sem o `git init` e sem o commit, como diz a seção
dele: os perfis entram no commit do piloto, depois do sim.

### 3. Entender

Antes da primeira pergunta, leia o que o projeto já tem: `docs/discovery/`,
`docs/prd/`, o `docs/qa/checklist.yaml` e o roteiro em `docs/specs/roadmap.md`,
quando existem, e o código. O que já está escrito não vira pergunta.

Um anexo da pessoa — PDF, planilha, documento — entra em `docs/discovery/` antes
de ser usado. Arquivo de texto, como `.md`, `.txt` ou `.csv`, é copiado como
está. O que não é texto tem o texto extraído para `docs/discovery/<nome>.md`, que
abre com uma linha dizendo de onde veio. Daí em diante, leia e cite a cópia, nunca
o caminho de fora.

Chame a Skill tool com **anvil-grilling**, uma pergunta por vez, esperando
resposta antes de seguir. Sempre com a **sua recomendação** e uma linha de
porquê.

Perguntas permitidas, e só estas:

- que **módulos** a ferramenta tem, e que **informações** cada um guarda
- **quem pode usar** cada parte
- que **regras de negócio** valem
- **integrações** com o que já existe
- os **nomes** que aparecem na tela
- o **critério de pronto**: como a pessoa vai saber que está funcionando

Se a resposta puder ser lida do código ou do que já existe, leia — não pergunte.

A entrevista cobre a ferramenta inteira, e não só a primeira parte a construir: a
pessoa não volta à conversa entre uma parte e outra.

`chega` congela o que foi decidido e registra o resto como lacuna.

#### O roteiro

No fim da entrevista, escreva três arquivos, nenhum dentro de uma spec:

- `docs/discovery/briefing.md`, o combinado em prosa;
- `docs/qa/checklist.yaml`, o critério de pronto, no formato do
  [CHECKLIST.md](CHECKLIST.md);
- `docs/specs/roadmap.md`, o **roteiro**: a ferramenta dividida em N entradas,
  cada uma uma spec.

Dividir e ordenar é decisão sua, e não vira pergunta: uma entrada por módulo, ou
por grupo pequeno de módulos que só funcionam juntos, e antes o que os outros
usam. Cada entrada é uma seção de segundo nível, com o nome em kebab-case, único
no arquivo, e as chaves no começo da linha:

```markdown
# Roteiro

## contratos

Tipo: feature
Depende de:
Cobre: C1, C2

Entra: cadastro e busca de contratos, e quem enxerga o valor.
Fica de fora: o aviso de vencimento.
Pronto quando: cadastrar um contrato com número, cliente, valor e vencimento; quem não é do financeiro não enxerga o valor.

## avisos

Tipo: feature
Depende de: contratos
Cobre: C3

Entra: …
Fica de fora: …
Pronto quando: …
```

- `Depende de:` são os nomes das entradas que precisam fechar antes, separados
  por vírgula. Vazio, a entrada não depende de nenhuma.
- `Cobre:` são os ids do checklist que a entrada entrega. Cada item do
  checklist está no `Cobre:` de **exatamente uma** entrada.
- `Pronto quando:` são os `outcome` dos itens do `Cobre:`, na fala da pessoa.
- Não escreva `Spec:`: ele nasce com a spec da entrada, na fase 5.

É o formato do roteiro do perfil do tracker, na seção "Roteiro e relatório" de
`docs/agents/issue-tracker.md`. Antes de mostrar qualquer coisa, confira os dois
lados. O roteiro passa no script de estado, sem linha `refusal:`:

```
bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh
```

E a cobertura fecha: o `diff` abaixo sai vazio quando cada item do checklist está
em exatamente um `Cobre:`, e todo id de um `Cobre:` existe no checklist:

```
diff <(sed -n 's/^[[:space:]]*- id:[[:space:]]*\([^[:space:]#]*\).*/\1/p' docs/qa/checklist.yaml | sort) \
     <(sed -n 's/^\**Cobre:\** *//p' docs/specs/roadmap.md | tr ',' '\n' | sed 's/[[:space:]]//g;/^$/d' | sort)
```

Uma recusa ou uma diferença é erro seu, não da pessoa: corrija os arquivos e
confira de novo.

Então mostre à pessoa o roteiro em **português simples**: as partes na ordem em
que vão ser feitas, o que entra em cada uma, o que fica de fora, e como ela vai
saber que cada parte está pronta. Sem nome de arquivo, sem id de item e sem as
chaves do roteiro. Peça a confirmação sobre esse texto. Um pedido de mudança
edita os arquivos, passa pelas duas conferências e volta a ser mostrado.

O `roadmap.md` técnico fica gravado ao lado, fora da conversa: nem ele nem o
conteúdo dele aparecem para quem pediu (INV-6).

### 4. Congelar e testar

#### O combinado, uma vez

Com o sim, atualize a rule da stack com os módulos e papéis reais, e commite na
`main`, num commit só, o que a entrevista escreveu: o `briefing.md`, o
`checklist.yaml`, o `roadmap.md` e as cópias de anexo em `docs/discovery/`. Sob o
piloto automático, o commit é dele.

```
git add docs/discovery docs/qa docs/specs/roadmap.md .claude/rules
git commit -m "docs: freeze the briefing, the checklist and the roadmap"
```

Daqui em diante, o briefing e o checklist estão congelados: nenhuma spec os
reescreve, e só *Evoluir uma ferramenta* acrescenta a eles.

#### O ledger de cada spec

No começo de cada spec, com o branch dela aberto e antes do `anvil-to-spec`,
escreva os testes e o ledger **só dos itens do `Cobre:`** da entrada dela.

Derive os testes desses itens, simétricos ao que foi acordado: existência de
módulo, campos, CRUD, papéis, e os asserts de negócio. **Não reescreva os testes
base do starter.** Cada teste derivado termina imprimindo o marcador do seu item
(`CHECKLIST_C1_OK`), depois do último assert — é ele que o ledger vai exigir, e
imprimi-lo de dentro é o que impede uma suíte pulada de passar por verde.

Escreva também o **ledger** `gates.md`, na raiz da spec,
`docs/specs/<pasta>/gates.md`: um item do `Cobre:`, um gate, com o `CHECK:`
apontando o teste que você acabou de derivar. O critério de pronto que a pessoa
deu em português vira aqui a coisa que decide o loop sozinho, e nasce **antes**
da construção, não depois dela.

A conversão e as três regras que fazem um gate valer alguma coisa — marcador que
só sai quando tudo passou, nada de número copiado do briefing, item sem teste
vira gate manual — estão em [CHECKLIST.md](CHECKLIST.md). O formato do arquivo é
o do upstream, em [unlazy/references/gates.md](unlazy/references/gates.md).

Antes de seguir, rode o linter, que acha o gate incapaz de falhar. Ele vem da
instalação de usuário, fora do que o container monta, e por isso entra no
container antes de rodar:

```
docker compose cp ~/.claude/skills/anvil-bench/unlazy/scripts/. app:/tmp/anvil-gates
docker compose exec -T app node /tmp/anvil-gates/gate-lint.mjs docs/specs/<pasta>/gates.md
```

Commite os testes e o ledger no branch da spec.

Nada disto aparece para quem pediu a ferramenta (INV-6).

### 5. Construir

```
anvil-to-spec  →  anvil-to-tickets  →  [ anvil-implement + anvil-tdd ]  →  anvil-code-review  →  gate
                                          ↑                                        │
                                          └──────── até 2 rodadas ─────────────────┘
```

Este é o único lugar do anvil que roda sem parar a cada decisão. O fundamento é
a **audiência**: quem está do outro lado não tem como responder "os testes de
integração falharam, quer que eu ajuste o mock?".

A condição de parada é mecânica e está em [GATE.md](GATE.md). Teto de **duas
rodadas** por ticket, o orçamento do ADR-0010 — a verificação tem critério de
parada, e a terceira rodada é escolha declarada de um humano —, que vale no
resto do anvil: a rodada 1 mede o ticket inteiro, a rodada 2 mede o diff da
correção, e cada uma deixa a sua linha `Review:` no ticket. A rodada 2 que não
aprova trava o ticket: o veredito é `CONCERNS`, o loop para e reporta, e o ticket
entra na entrega como pendência. A terceira rodada não é do bench. O `gate` do
diagrama reexecuta o ledger da spec e o de cada spec do roteiro já fechada — ele
não lê o que o agente disse ter feito.

Uma linha visível de progresso por fase. Detalhe vai para `build-log.md`, e toda
decisão que você tomou sozinha vai para `decisions-log.md` — é o que permite
alguém auditar depois o que foi convenção e o que foi pedido.

#### Uma entrada do roteiro

Chamado direto — no Claude Code, ou no omp fora do piloto automático —, o bench
constrói **uma** entrada do roteiro e para no fim da construção. Não recusa por
estar fora do piloto, e não fecha a spec: o archive e o merge ficam com quem
opera o anvil, e a entrega diz isso.

1. Na `main`, rode o script de estado do roteiro:

   ```
   bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh
   ```

   Uma linha `entry:` com `state=open` é uma construção que parou no meio: a
   entrada é ela, no branch da spec dela, e a construção segue do ponto que o
   disco indica — o ledger, se falta o `gates.md`; o `anvil-to-spec`, se falta a
   spec; os tickets ainda não `resolved`. Sem ela, a entrada é a da linha `next:`,
   a primeira do frontier.

   Com `roadmap: none`, não há roteiro, e o `next: none` que vem junto não segura
   nada: com a spec aberta da fase 2, a entrada é essa spec, no branch dela, e a
   construção segue do ponto que o disco indica, como na linha `state=open`. Só
   com roteiro o `next: none` quer dizer que não há entrada a construir: diga na
   entrega o que segura o resto, sem construir nada.
2. Para a entrada do `next:`, abra a spec dela, da `main`, com o `Tipo:` e o
   nome da entrada:

   ```
   bash ~/.claude/skills/anvil-to-spec/scripts/new-spec.sh --type <Tipo> --short-name <nome> --json
   ```

   O script deixa o checkout no branch novo, ainda sem commit. Volte à `main`,
   acrescente `Spec: <number>` à seção da entrada no `roadmap.md`, logo abaixo de
   `Depende de:` ou, sem ela, de `Tipo:`, e commite só o roteiro. Depois, leve o
   branch até esse commit com `git checkout -B <branch> main`. Assim o roteiro diz
   qual spec é da entrada, e nenhuma ativação seguinte abre outra para ela.
3. Rode o ledger da spec, da fase 4.
4. Rode o `anvil-to-spec`, com a entrada do roteiro como contexto — o `Entra:` e
   o `Fica de fora:` são o escopo, e o `Pronto quando:` é o critério de pronto —,
   e depois o `anvil-to-tickets` e o loop do diagrama.
5. Pare no fim da construção, com o veredito do [GATE.md](GATE.md). Não faça
   archive, PR nem merge, e não comece a entrada seguinte.

### 6. Entregar

Com `PASS`: o endereço, as credenciais e um resumo do que a ferramenta faz, em
linguagem de negócio.

Com `CONCERNS` ou `FAIL`: diga o que falta, em uma frase, **sem despejar log**.
Ticket travado na rodada 2 entra aqui como pendência declarada, dita como o que a
pessoa ainda não consegue fazer na ferramenta.

Numa retomada, a entrega diz também, com qualquer veredito e em uma frase
simples, de onde a construção partiu: do que já estava combinado por escrito, ou
de uma conversa só sobre o que faltava.

Chamado direto, a entrega diz também, em linguagem simples, que a parte
construída ainda precisa ser guardada como versão oficial por quem cuida da
ferramenta, e que as partes seguintes do roteiro vêm nas próximas vezes em que o
bench for chamado. Depois, num bloco à parte, endereçado a quem opera o anvil e
não a quem pediu, liste o fechamento que ficou com o operador:

- o `/anvil-docs archive` no branch da spec, `<branch>`;
- o merge na `main`, ou o PR, conforme a regra do projeto no perfil do tracker,
  com a guarda de merge valendo.

Publicar é opt-in e não faz parte deste fluxo —
`~/.claude/skills/anvil-stack-payload/bench/deploy.sh`, no diretório do projeto.

## Evoluir uma ferramenta

Reative o bench no projeto existente e descreva a mudança.

- A entrevista cobre **só o delta**, e parte do roteiro e do checklist que já
  existem: acrescenta entradas ao roteiro e itens ao checklist, com os ids
  seguintes, e passa pelas conferências e pela confirmação do roteiro da fase 3.
  Não re-entreviste o que já foi decidido. Sem mudança pedida, não há
  entrevista: a fase 5 segue com a próxima entrada do roteiro.
- Preserve módulos e testes anteriores. Remoção ou substituição exige pedido
  explícito, confirmado na conversa.
- A mudança nasce como spec **aditiva**, rastreável no git.
- Rode a regressão inteira: testes antigos e novos juntos.
- O endereço e a alocação **não mudam**.
- A entrega resume só o que mudou.

## Nunca

- **Inventar regra de negócio.** Lacuna material volta para a conversa ou aparece
  na entrega como pendência declarada.
- **Gerar ambiente, infraestrutura ou scaffold.** Isso vem do adapter, versionado.
- **Editar fora de `src/collections/` e labels.** O compose, a infra e a base do
  `payload.config.ts` não são seus.
- **Mostrar log, comando ou nome de tecnologia** para quem pediu a ferramenta.
- **Mostrar o roteiro técnico** a quem pediu, ou gravar o `briefing.md` e o
  `checklist.yaml` dentro de uma spec.
