# Payload — regras sempre carregadas

Este arquivo vira `.claude/rules/payload.md` no projeto. Ele é curto de propósito:
carrega **só o que se erra sem saber que se está perto do erro**. O ofício —
como escrever collection, hook, access control, query — está em `reference/`, e
se carrega quando você sabe que precisa.

O teste que decide o que entra aqui: *se a pessoa não abrir a referência, ela
erra?* Se sim, é regra. Se não, é referência.

## As três ciladas

### 1. Local API ignora access control por padrão

Passar `user` **não** aplica as permissões dele. Sem `overrideAccess: false` você
escreve um furo de segurança achando que acertou.

```ts
// ERRADO — passa o usuário e ignora as permissões dele
await payload.find({ collection: 'posts', user: someUser })

// CERTO
await payload.find({ collection: 'posts', user: someUser, overrideAccess: false })
```

- `overrideAccess: true` (o padrão) — operação de servidor em que você confia:
  cron, tarefa de sistema, seed.
- `overrideAccess: false` — **sempre** que estiver agindo em nome de um usuário:
  rota de API, webhook, server action.

### 2. Operação aninhada em hook sem `req` quebra a transação

Sem passar `req`, a operação roda em **outra transação**. Se a de fora falhar, a
de dentro já foi gravada — e você fica com dado órfão sem nenhum erro aparecendo.

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

Regra curta: **toda** operação dentro de hook recebe o `req` do hook.

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

## Logger

A assinatura não é a do `console`:

```ts
payload.logger.error('mensagem')                        // ok
payload.logger.error({ msg: 'falhou', err: error })     // ok
payload.logger.error('falhou', error)                   // errado: 2º argumento é ignorado
payload.logger.error({ message: '…', error: err })      // errado: as chaves são msg e err
```

## Fronteira de edição

Preencha ao gerar a rule do projeto. O padrão, quando não houver decisão
contrária:

- O agente edita `src/collections/`, `src/globals/`, `src/hooks/` e labels.
- O agente **não** reescreve `docker-compose*`, arquivos de infraestrutura, nem a
  base do `payload.config.ts` — só acrescenta collections à lista.
- Toda collection nova é registrada em `payload.config.ts`.

## Fatos deste projeto

Preenchidos por `/anvil-boot` na varredura, ou por `/anvil-bench` na criação. O
valor entra **sem** backtick — o template já os coloca:

- **Adapter de banco:** `{{DB_ADAPTER}}` — mongoose · postgres · sqlite
- **Onde ficam as collections:** `{{COLLECTIONS_PATH}}`
- **Comando de teste:** `{{TEST_COMMAND}}`
- **Tipos gerados em:** `{{TYPES_PATH}}`

## Onde está o resto

Chame a skill `anvil-stack-payload`. O `SKILL.md` dela tem uma tabela de tarefa →
solução → arquivo, e o `reference/` tem onze documentos: `FIELDS`, `COLLECTIONS`,
`HOOKS`, `ACCESS-CONTROL` (+ `-ADVANCED`), `QUERIES`, `ENDPOINTS`, `ADAPTERS`,
`ADVANCED`, `FIELD-TYPE-GUARDS`, `PLUGIN-DEVELOPMENT`.
