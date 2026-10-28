# Payload — regras sempre carregadas

Vira `.claude/rules/payload.md` no projeto. Carrega **só o que se erra sem saber
que se está perto do erro**; o ofício está em `reference/`. O teste: *se a pessoa
não abrir a referência, ela erra?* Se sim, é regra.

## As quatro ciladas

### 1. Local API ignora access control por padrão

Passar `user` **não** aplica as permissões dele. Sem `overrideAccess: false`, é
um furo de segurança que parece certo.

```ts
// ERRADO — passa o usuário e ignora as permissões dele
await payload.find({ collection: 'posts', user: someUser })

// CERTO
await payload.find({ collection: 'posts', user: someUser, overrideAccess: false })
```

`overrideAccess: true`, o padrão, só em operação de servidor confiável (cron,
seed). Agindo em nome de um usuário (rota, webhook, server action): **sempre**
`false`.

### 2. Operação aninhada em hook sem `req` quebra a transação

Sem `req`, a operação roda em **outra transação**: se a de fora falhar, a de
dentro já gravou, e sobra dado órfão sem erro nenhum. **Toda** operação dentro de
hook recebe o `req` do hook.

```ts
// ERRADO — transação separada, atomicidade perdida
afterChange: [async ({ doc, req }) => {
  await req.payload.create({ collection: 'audit-log', data: { docId: doc.id } })
}]

// CERTO
afterChange: [async ({ doc, req }) => {
  await req.payload.create({ collection: 'audit-log', data: { docId: doc.id }, req })
}]
```

### 3. Hook que dispara o próprio hook entra em loop

`afterChange` que faz `update` na mesma collection dispara `afterChange` de novo.

```ts
// CERTO — flag de contexto corta a recursão
afterChange: [async ({ doc, req, context }) => {
  if (context.skipHooks) return
  await req.payload.update({
    collection: 'posts', id: doc.id,
    data: { views: doc.views + 1 },
    context: { skipHooks: true },
    req,
  })
}]
```

### 4. `--no-isolate` com o plugin multi-tenant cria dependência de ordem

Vale para quem usa `@payloadcms/plugin-multi-tenant`. O plugin troca o `access`
das coleções de tenant **no próprio objeto importado**. Sem isolamento, o arquivo
de teste que importa a config muta a coleção que o seguinte importa, no mesmo
worker. A suíte passa na primeira rodada; com `--sequence.shuffle`,
`access.read` devolve `Promise{…}` em vez de `false`. Suíte pequena pode passar
sempre, e quebra quando tiver mais arquivos que workers.

- **O arquivo que falha é a vítima**: só importa a coleção. Não o conserte.
- **Mantenha o isolamento** nos testes que importam a config ou uma coleção.
- **O controle** é `--sequence.shuffle` **com** isolamento: se sai verde, a
  fragilidade é da flag.

## Logger

A assinatura não é a do `console`:

```ts
payload.logger.error('mensagem')                        // ok
payload.logger.error({ msg: 'falhou', err: error })     // ok
payload.logger.error('falhou', error)                   // errado: 2º argumento é ignorado
payload.logger.error({ message: '…', error: err })      // errado: as chaves são msg e err
```

## Fronteira de edição

Preencha ao gerar a rule. O padrão, sem decisão contrária:

- O agente edita `src/collections/`, `src/globals/`, `src/hooks/` e labels.
- O agente **não** reescreve `docker-compose*`, infraestrutura nem a base do
  `payload.config.ts` — só acrescenta collections, e registra cada uma ali.

## Fatos deste projeto

Preenchidos por `/anvil-boot` ou `/anvil-bench`; o valor entra **sem** backtick.
O `/anvil-boot` troca a linha do comando de teste por um ponteiro para o
`anvil.md`:

- **Adapter de banco:** `{{DB_ADAPTER}}` — mongoose · postgres · sqlite
- **Onde ficam as collections:** `{{COLLECTIONS_PATH}}`
- **Comando de teste:** `{{TEST_COMMAND}}`
- **Tipos gerados em:** `{{TYPES_PATH}}`

## Onde está o resto

Na skill `anvil-stack-payload`: o `SKILL.md` roteia tarefa → arquivo, e o
`reference/` tem `FIELDS`, `COLLECTIONS`, `HOOKS`, `ACCESS-CONTROL`
(+ `-ADVANCED`), `QUERIES`, `ENDPOINTS`, `ADAPTERS`, `ADVANCED`,
`FIELD-TYPE-GUARDS` e `PLUGIN-DEVELOPMENT`.
