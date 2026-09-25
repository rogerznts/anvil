# Checklist de segurança — Payload

Sétima capacidade do contrato de stack (`STACK-CONTRACT.md` do `anvil-docs`),
carregada só pelo `/anvil-security-map`. Não substitui o `RULE.md`: a rule é o
que se erra sem saber que está perto do erro; este arquivo é o que o map varre
item por item para montar `docs/security/map.md`. Nada aqui executa contra o
app — quem executa é o `/anvil-security-probe`, pelo teste que cada item indica.

Cada item traz:

- **O que olhar** — onde no projeto o item se manifesta.
- **Como reconhecer** — o padrão de código ou config que indica exposição.
- **Teste do probe** — o que o `/anvil-security-probe` executa para confirmar,
  ou "só leitura" quando o map já resolve por inspeção, sem teste ativo.
- **Precedente** — advisory confirmado por leitura direta na pesquisa
  (`docs/discovery/seguranca-map-probe.md`) ou doc oficial da Payload/Next.js.

A pesquisa achou cinco outros advisories (CSRF bypass, SSRF por upload, escrita
em campo no MongoDB, entre outros) que vieram de busca e não foram confirmados
por leitura direta na página do advisory. Nenhum item abaixo cita esses cinco.

## 1. Collections e rotas REST/GraphQL geradas

- **O que olhar:** cada arquivo de collection em `{{COLLECTIONS_PATH}}` e sua
  entrada em `payload.config.ts`.
- **Como reconhecer:** toda collection ganha `GET/POST/PATCH/DELETE` por REST e
  as operações equivalentes em GraphQL automaticamente, inclusive edição e
  remoção em massa por `where` — sem nenhuma rota escrita à mão. Uma collection
  sem `access` definido herda o padrão liberado do Payload.
- **Teste do probe:** requisição direta a cada rota gerada (list, get, create,
  update, delete, e a operação em massa por `where`) como usuário sem
  permissão, e como usuário de outro papel ou tenant.
- **Precedente:** [REST API overview](https://payloadcms.com/docs/rest-api/overview),
  [GraphQL overview](https://payloadcms.com/docs/graphql/overview).

## 2. Local API e `overrideAccess`

- **O que olhar:** chamadas a `payload.find/create/update/delete` (Local API)
  dentro de route handler, Server Action ou hook que recebe `user`.
- **Como reconhecer:** `overrideAccess` é `true` por padrão. `user` passado sem
  `overrideAccess: false` ignora o access control da collection inteira — a
  mesma cilada 1 do `RULE.md`.
- **Teste do probe:** chamar a rota ou action que envolve essa Local API como
  usuário sem permissão sobre o documento, e conferir se o retorno respeita o
  access control da collection.
- **Precedente:** [Local API access control](https://payloadcms.com/docs/local-api/access-control).

## 3. Access control por campo

- **O que olhar:** `access.read` e `access.update` de campos sensíveis dentro
  de uma collection (roles, flags internas, referência a outro tenant).
- **Como reconhecer:** campo sem `access` próprio herda o access da collection;
  um usuário com permissão de leitura na collection lê e, sem `access.update`,
  também grava um campo que deveria ser só do sistema.
- **Teste do probe:** ler e tentar gravar o campo específico como usuário sem
  permissão elevada, via REST, GraphQL e Local API.
- **Precedente:** [GHSA-9g87-32v6-3c2r](https://github.com/payloadcms/payload/security/advisories/GHSA-9g87-32v6-3c2r)
  e [GHSA-fpww-c55p-cjv6](https://github.com/payloadcms/payload/security/advisories/GHSA-fpww-c55p-cjv6) —
  vazamento de campo oculto por `sort` e por join polimórfico, no núcleo do
  Payload.

## 4. Auth: `maxLoginAttempts`, `lockTime`, reset de senha

- **O que olhar:** o bloco `auth` da collection de usuários.
- **Como reconhecer:** `maxLoginAttempts`/`lockTime` ausentes deixam login sem
  limite de tentativas; o fluxo de `forgot-password`/`reset-password` sem
  validação equivalente aceita reset indevido.
- **Teste do probe:** tentativas de login sucessivas até o limite esperado, e o
  fluxo de recovery pelo endpoint gerado, conferindo a validação.
- **Precedente:** [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse)
  (`maxLoginAttempts`, `lockTime`) e
  [GHSA-hp5w-3hxx-vmwf / CVE-2026-34751](https://github.com/payloadcms/payload/security/advisories/GHSA-hp5w-3hxx-vmwf) —
  password recovery sem validação, CVSS 9.1.

## 5. GraphQL: complexidade, introspection, playground

- **O que olhar:** o bloco `graphQL` em `payload.config.ts`.
- **Como reconhecer:** `maxDepth`/`graphQL.maxComplexity` ausentes permitem
  query profunda ou cara sem limite; `disableIntrospectionInProduction` ausente
  ou `false` deixa o schema inteiro legível; playground acessível fora de dev.
- **Teste do probe:** enviar query de introspecção e query aninhada além do
  limite esperado, e requisitar o endpoint do playground em produção.
- **Precedente:** [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse)
  (`maxDepth`, `graphQL.maxComplexity`, `disableIntrospectionInProduction`) e
  [GraphQL overview](https://payloadcms.com/docs/graphql/overview) (playground
  em produção).

## 6. `csrf` e `cors`

- **O que olhar:** os blocos `csrf` e `cors` em `payload.config.ts`.
- **Como reconhecer:** `csrf` é a allowlist de domínio para o cookie de sessão
  e não tem relação com `cors`; `cors: '*'` combinado com autenticação por
  cookie é a configuração perigosa — qualquer origem lê a resposta autenticada.
- **Teste do probe:** requisição cross-origin forjada, de uma origem fora da
  allowlist, contra uma rota autenticada por cookie.
- **Precedente:** [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse)
  (`csrf`, `cors`).

## 7. Upload: `mimeTypes`, `allowRestrictedFileTypes`, `pasteURL`, `skipSafeFetch`

- **O que olhar:** o bloco `upload` de cada collection com arquivo.
- **Como reconhecer:** `mimeTypes` ausente aceita qualquer tipo;
  `allowRestrictedFileTypes: true` libera extensão perigosa; `pasteURL` vem
  ligado por padrão e busca a URL que o usuário informar — vetor de SSRF sem
  allowlist de domínio; `skipSafeFetch: true` pula a checagem que bloqueia IP
  privado nesse fetch.
- **Teste do probe:** upload de arquivo com mimetype restrito, e `pasteURL`
  apontando para um endereço interno (loopback, metadata da nuvem), conferindo
  se a requisição é bloqueada.
- **Precedente:** [Upload overview](https://payloadcms.com/docs/upload/overview)
  (`mimeTypes`, `allowRestrictedFileTypes`, `pasteURL`, `skipSafeFetch`) e
  [GHSA-9qpg-3cf8-w33x](https://github.com/payloadcms/payload/security/advisories/GHSA-9qpg-3cf8-w33x) —
  XML enviado por upload executando JavaScript same-origin.

## 8. Multi-tenant: `useTenantAccess`

- **O que olhar:** a config do `@payloadcms/plugin-multi-tenant` em cada
  collection habilitada para tenant.
- **Como reconhecer:** `useTenantAccess: false` desliga o filtro automático de
  tenant que o plugin injeta em `access`, deixando a collection sem isolamento
  entre tenants por padrão.
- **Teste do probe:** autenticado como usuário do tenant A, ler e gravar
  documento do tenant B pelas rotas REST/GraphQL geradas.
- **Precedente:** [Multi-tenant plugin](https://payloadcms.com/docs/plugins/multi-tenant)
  e [GHSA-jq29-r496-r955 / CVE-2026-25574](https://github.com/payloadcms/payload/security/advisories/GHSA-jq29-r496-r955) —
  IDOR entre collections em `payload-preferences`, mesma classe de falha de
  isolamento.

## 9. Camada Next.js: Server Actions, Route Handlers, middleware/proxy

- **O que olhar:** toda função exportada com `'use server'`, todo
  `app/**/route.ts`, e `middleware.ts` (ou `proxy.ts` a partir do Next 16).
- **Como reconhecer:** autorização escrita só dentro do middleware/proxy e
  ausente no handler ou na action — toda Server Action exportada aceita POST
  direto, sem passar pela página que a chama.
- **Teste do probe:** chamar a Server Action e o Route Handler direto, sem
  passar pela página, e repetir com o header `x-middleware-subrequest` forjado
  para conferir se a autorização do middleware é contornável.
- **Precedente:** [GHSA-f82v-jwr5-mffw / CVE-2025-29927](https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw) —
  bypass de middleware via `x-middleware-subrequest` — e
  [Server Actions](https://nextjs.org/docs/app/guides/server-actions), que
  trata toda action exportada como endpoint público.

## 10. Versões mínimas contra advisories

- **O que olhar:** a versão instalada de `payload`, `next`, `react` e
  `react-dom` no lockfile.
- **Como reconhecer:** versão abaixo da que corrige um dos advisories
  confirmados abaixo. A versão exata que corrige cada um o
  `/anvil-security-map` resolve na consulta ao OSV.dev/GHSA em tempo de
  execução — não fica fixada aqui, para acompanhar advisory publicado depois
  deste checklist.
- **Teste do probe:** só leitura — compara a versão do lockfile com os
  advisories abaixo; não executa nada contra o app.
- **Precedente**, todos confirmados por leitura direta em 2026-09-24:
  - [GHSA-v49j-62m6-pgrr](https://github.com/payloadcms/payload/security/advisories/GHSA-v49j-62m6-pgrr) —
    SQL injection em SQLite e Postgres, crítico
  - [GHSA-qf28-8hc6-vwrp](https://github.com/payloadcms/payload/security/advisories/GHSA-qf28-8hc6-vwrp) —
    prototype pollution no plugin Import Export, crítico
  - [GHSA-9g87-32v6-3c2r](https://github.com/payloadcms/payload/security/advisories/GHSA-9g87-32v6-3c2r) /
    [GHSA-fpww-c55p-cjv6](https://github.com/payloadcms/payload/security/advisories/GHSA-fpww-c55p-cjv6) —
    vazamento de campo oculto por `sort` e por join polimórfico
  - [GHSA-9qpg-3cf8-w33x](https://github.com/payloadcms/payload/security/advisories/GHSA-9qpg-3cf8-w33x) —
    XML por upload executando JavaScript same-origin
  - [GHSA-hp5w-3hxx-vmwf / CVE-2026-34751](https://github.com/payloadcms/payload/security/advisories/GHSA-hp5w-3hxx-vmwf) —
    password recovery sem validação, CVSS 9.1
  - [GHSA-jq29-r496-r955 / CVE-2026-25574](https://github.com/payloadcms/payload/security/advisories/GHSA-jq29-r496-r955) —
    IDOR entre collections em `payload-preferences`
  - [GHSA-f82v-jwr5-mffw / CVE-2025-29927](https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw) —
    bypass de middleware do Next.js via `x-middleware-subrequest`
  - [GHSA-9qr9-h5gf-34mp / CVE-2025-66478 / CVE-2025-55182](https://github.com/vercel/next.js/security/advisories/GHSA-9qr9-h5gf-34mp) —
    RCE no protocolo RSC Flight, corrigido em React ≥ 19.2.3 e Next ≥ 15.4.10
