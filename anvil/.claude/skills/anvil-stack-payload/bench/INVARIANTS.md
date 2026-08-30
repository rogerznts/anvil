# Invariantes do bench — Payload

**Isto não vale para projeto Payload comum.** São decisões de produto do
`/anvil-bench`, que constrói ferramenta interna para quem não é técnico. Um
desenvolvedor trabalhando em Payload não quer nenhuma delas.

Por isso este arquivo mora em `bench/` e **não entra** na
`.claude/rules/payload.md` de um projeto normal. Só o `/anvil-bench` acrescenta
esta seção à rule que gera.

## As seis

- **INV-1 — Admin sempre em pt-BR, com menu completo.** Nada escondido nem
  agrupado de forma que oculte entrada. Nunca `admin.hidden`, nunca `admin.group`
  que esconda módulo. Quem usa a ferramenta precisa ver tudo o que existe.
- **INV-2 — Todo módulo é uma collection.** Sem exceção. "Módulo", na conversa
  com o usuário, é uma collection do Payload no código.
- **INV-3 — Postgres como banco, Redis para fila.** Infra compartilhada por
  máquina, na rede `anvil-net`.
- **INV-4 — Zero build local; só Docker.** Imagens pinadas. O usuário nunca
  instala runtime, nunca roda `pnpm install` na máquina dele.
- **INV-5 — O usuário decide só regra de negócio.** Todo o resto é convenção,
  resolvida pelos scripts do adapter ou pelo starter versionado.
- **INV-6 — Toda saída ao usuário é pt-BR simples, sem jargão.** Nunca dizer o
  nome da tecnologia, "porta", "container", "banco", "migration", "YAML" ou
  "commit". Fale de "cadastros", "informações", "quem pode usar", "regras", "o
  endereço da ferramenta".

**A regra de ouro (INV-5).** Nunca faça um leigo tomar decisão técnica.
Bifurcação técnica durante a conversa: **escolha o default seguro e avise em
linguagem simples** — nunca pergunte.

## Fronteira de edição no bench

Mais estreita que a de um projeto comum:

- O agente edita **só** `src/collections/` e labels.
- **Nunca** reescreve o `docker-compose`, a infraestrutura, ou a base do
  `payload.config.ts`.
- Collection nova entra em `src/collections/` e é registrada no
  `payload.config.ts` **sem** `hidden` nem agrupamento que esconda (INV-1).

## Mapeamento do adapter

| Capacidade | Implementação |
|---|---|
| Starter | `bench/starter/` — copiado as-is, nunca regenerado |
| Ambiente | `bench/env.sh` |
| Infra e alocação | `bench/infra.sh` |
| Rule gerada | `.claude/rules/payload.md`, a partir de `../RULE.md` mais esta seção |
| Testes | `docker compose exec app pnpm test` (Vitest, via Local API) |
| Publicação opt-in | `bench/deploy.sh` — Railway |

## Alocação por projeto

O `infra.sh` provisiona uma infra compartilhada por máquina — Postgres, Redis e a
rede `anvil-net` — e aloca por projeto:

- nome do banco
- índice do Redis (0–15, com prefixo como fallback)
- porta livre do admin (3000–3999, testada por bind)

O registro fica em `~/projects/.anvil-infra/registry.yaml`, que é a **fonte única
da alocação**. Não edite à mão, e não reprovisione um projeto que já tem
`ALLOC_*` — reuse.

## `loop-until-green`

O bench é a exceção escopada à regra de que o toolkit pausa a cada decisão. O
fundamento é a **audiência**: um leigo não tem como responder "os testes de
integração falharam, quer que eu ajuste o mock?".

- Teto de **3 tentativas** de correção por tarefa.
- `PASS` exige smoke, testes acumulados de módulo e asserts de negócio, todos
  verdes.
- Teto esgotado produz `CONCERNS`, e o loop para — não insiste.

É o único lugar do anvil que grava `gate.yaml`, e é por isso: um loop headless,
que dispara agentes isolados com o disco como fronteira de estado, precisa de
condição de parada mecânica. No fluxo normal, o `/anvil-code-review` devolve o
veredito em prosa.

## Migração de projeto criado pelo mosk

<!-- anvil-verify: allow-mosk-ops — esta seção precisa nomear os identificadores
     antigos; quem migra vai encontrá-los no docker-compose.yml do projeto. -->

Projeto que já roda na infra do mosk usa `mosk-net` e
`~/projects/.mosk-infra/registry.yaml`. O anvil usa `anvil-net` e
`~/projects/.anvil-infra/`, com usuário de banco `anvil`.

As duas infras **convivem** — são redes e diretórios distintos. Projeto antigo
continua funcionando onde está; projeto novo nasce na infra do anvil. Migrar um
projeto antigo é mudar a rede no `docker-compose.yml` dele e realocar no registry
novo, e não vale a pena a menos que você queira consolidar.
