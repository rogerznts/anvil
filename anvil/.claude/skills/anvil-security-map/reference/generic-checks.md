# Parte genérica: onde entrada vira risco

Roda em qualquer stack, com ou sem checklist. Cada item diz o padrão a
procurar, como reconhecer que é risco de verdade (não todo hit é achado — leia
o contexto antes de listar) e o teste que o probe aplica.

**Achado de ausência** (falta um arquivo, falta um bloco de configuração —
headers de segurança, `graphQL`, `csrf`/`cors`) não tem uma linha onde algo
erra; cite o arquivo onde a configuração **deveria** entrar (a instância do
app/servidor, o arquivo de config do framework) ou, se o arquivo nem existe,
o caminho esperado entre parênteses — `next.config.* (ausente no projeto)`.
Ordene esse achado pela mesma string que você escreveu em arquivo:linha, como
qualquer outro achado, para manter a numeração determinística de
`categories.md`.

**Sobreposição com o checklist da stack.** Quando um achado bate tanto num
item da parte genérica quanto num item do checklist da stack (ex.: Local API
sem `overrideAccess: false` é ao mesmo tempo "autorização por rota" genérica e
um item do checklist do Payload), a mesma ocorrência vira **uma linha só**, e
o texto — descrição, teste do probe, precedente — vem do item do checklist:
ele é mais específico da tecnologia. A parte genérica preenche a lacuna só
quando o checklist não cobre aquele arquivo:linha.

## Autorização por rota

- **Procure:** toda definição de endpoint HTTP, em qualquer framework —
  `app.get(`/`.post(`/`.put(`/`.delete(` e equivalentes de router (Express,
  Fastify, Koa, Hapi); no Next.js, cada Route Handler (`app/**/route.ts`) e
  cada rota do Pages Router (`pages/api/**/*.ts`).
- **É risco quando:** o handler lê ou grava dado sem checar sessão/usuário
  antes — nenhuma chamada a um middleware de auth (`passport`,
  `express-session` com checagem própria, `requireAuth`) nem a uma função de
  sessão do framework (`getServerSession`, `auth()`) antes de tocar o dado.
- **Teste do probe:** requisição direta ao handler sem sessão e com sessão de
  um usuário sem permissão sobre o recurso.

## Next.js: Server Actions e Route Handlers como endpoints públicos

Só quando o projeto usa Next.js (`next` em `package.json`, ou diretório
`app/`/`pages/`). Não é uma checagem à parte de "autorização por rota" — é o
motivo pelo qual, no Next.js, o item acima **também** se aplica a toda função
`'use server'` exportada: a documentação de Server Actions do próprio Next.js
trata as duas coisas como endpoint público, que aceita POST direto sem passar
pela página que as chama. Isso não gera uma linha extra por Route
Handler/Server Action que já checa sessão corretamente — só reforça que a
ausência de checagem, quando existir, é achado tão sério quanto numa rota
Express.

- **Teste do probe:** chamar a action ou o handler direto, sem passar pela
  página.

## Next.js: autorização feita só no middleware

Só quando o projeto usa Next.js.

- **Procure:** `middleware.ts` (ou `proxy.ts` a partir do Next 16) que
  redireciona ou bloqueia por sessão/role.
- **É risco quando:** o handler ou a action que o middleware diz proteger não
  repete a checagem por conta própria.
- **Teste do probe:** repetir a chamada direta ao handler com o header
  `x-middleware-subrequest` forjado, conferindo se a autorização do
  middleware é contornável (GHSA-f82v-jwr5-mffw / CVE-2025-29927).

## SQL cru

- **Procure:** `.query(`, `.raw(`, `sequelize.query(`, `db.execute(`,
  `client.query(` e templates literais contendo `SELECT `/`INSERT INTO
  `/`UPDATE `/`DELETE FROM`.
- **É risco quando:** a string do comando é montada por concatenação (`+`) ou
  interpolação (`` `...${valor}...` ``) com um valor que vem de request, query
  string, body ou parâmetro de rota — não quando o valor é parametrizado
  (`?`, `$1`, placeholder nomeado do driver).
- **Teste do probe:** confirmação com ferramenta de SQL injection sobre o
  parâmetro suspeito (não varredura ampla).

## Execução de comando

- **Procure:** `child_process`, `exec(`, `execSync(`, `spawn(` com
  `shell: true`, `eval(`.
- **É risco quando:** o comando ou um dos argumentos vem de entrada do
  usuário sem allowlist fixa de valores possíveis.
- **Teste do probe:** injeção de metacaractere de shell (`;`, `` ` ``, `$()`)
  no parâmetro suspeito, observando efeito colateral controlado.

## Caminho de arquivo

- **Procure:** `fs.readFile`, `fs.readFileSync`, `fs.createReadStream`,
  `path.join(`/`path.resolve(` recebendo uma variável vinda de request, e
  `require(`/`import(` dinâmico com segmento de caminho vindo de entrada.
- **É risco quando:** não há normalização (`path.normalize`) nem checagem de
  que o caminho resultante continua dentro de um diretório base.
- **Teste do probe:** requisição com `../` no parâmetro de caminho, tentando
  ler um arquivo fora do diretório esperado.

## Fetch de URL do usuário (SSRF)

- **Procure:** `fetch(`, `axios.get(`/`axios.post(`, `http.get(`,
  `https.request(` cujo argumento de URL vem de body, query ou campo
  gravado pelo usuário (inclusive `pasteURL` de upload).
- **É risco quando:** não há allowlist de domínio nem bloqueio de IP privado
  e de metadata da nuvem (`169.254.169.254`, `localhost`, faixas `10.`/`172.16-31.`/`192.168.`).
- **Teste do probe:** apontar o campo para um endereço interno e conferir se a
  requisição é bloqueada.

## Template (SSTI)

- **Procure:** `dangerouslySetInnerHTML`, `{{{` (Handlebars sem escape),
  `ejs.render(`/`ejs.compile(` chamado com uma *string vinda de entrada* como
  template (não como dado), `new Function(`, `vm.runInNewContext(`.
- **É risco quando:** o template em si — não só os dados interpolados — é
  controlado pelo usuário.
- **Teste do probe:** payload de sintaxe do motor de template (`${7*7}` ou
  equivalente) no campo suspeito, conferindo se ele é avaliado.

## Segredos

- **Procure:** padrões de chave (`sk_live_`, `AKIA[0-9A-Z]{16}`,
  `-----BEGIN PRIVATE KEY-----`) e atribuição direta
  (`password = "..."`, `apiKey: "..."`) com valor literal de 6+ caracteres.
  Confira também se `.env` (sem sufixo `.example`/`.sample`) está rastreado
  pelo git.
- **Teste do probe:** nenhum — achado de leitura. Ferramenta de segredo
  (gitleaks/TruffleHog), quando presente, confirma sem executar contra o app.

## CORS

- **Procure:** `Access-Control-Allow-Origin`, `cors(`, `cors: '*'`,
  `origin: '*'`.
- **É risco quando:** a origem é `*` (ou reflete qualquer origem recebida) e a
  rota autentica por cookie.
- **Teste do probe:** requisição cross-origin forjada de uma origem fora da
  allowlist, contra uma rota autenticada por cookie.

## Headers de segurança

- **Procure:** ausência de `helmet` (Express) ou de uma função `headers()` em
  `next.config.*` que defina `Content-Security-Policy`,
  `X-Frame-Options`/`frame-ancestors`, `Strict-Transport-Security`.
- **Teste do probe:** só leitura — o map já resolve por inspeção da
  configuração; não executa nada contra o app.
