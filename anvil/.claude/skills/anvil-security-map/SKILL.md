---
name: anvil-security-map
description: "Mapeia a superfície de ataque de um projeto: detecta a stack, carrega o checklist de segurança que a skill da stack oferecer, soma a parte genérica de segurança (SQL cru, execução de comando, caminho de arquivo, SSRF, template, autorização por rota, segredos, CORS, headers) e grava docs/security/profile.md e docs/security/map.md. Não executa nada contra o app — roda sem servidor de dev no ar, e nunca toca docs/security/findings.md. Use para gerar ou atualizar o mapa de segurança antes do /anvil-security-probe, a qualquer momento, com ou sem ter passado pelo boot."
---

# Mapa de superfície de ataque

Esta skill é autoral (adr-0012 — as skills de segurança são autorais,
destiladas das referências, listadas em [SOURCES.md](SOURCES.md)). Ela **só
lê** o repositório: nenhuma requisição ao app do projeto, nenhum servidor
subido, nenhuma conexão a banco. Quem executa é o `/anvil-security-probe`,
noutra skill.

**Nunca toca `docs/security/findings.md`.** Esse arquivo é do probe. Rodar o
map de novo **regrava** `profile.md` e `map.md` inteiros — não é merge, é
sobrescrita — e não lê nem escreve mais nada em `docs/security/`.

## 1. Detectar a stack

Procure no projeto o que uma stack conhecida do anvil deixa no disco. Hoje, só
o Payload: `payload.config.ts` (ou `.js`) na raiz ou em `src/`.

Achou → confira se a skill da stack está instalada no projeto, em
`.claude/skills/anvil-stack-<nome>/`. Leia `package.json` para a versão
instalada de `payload`, `next`, `react` e `react-dom` (do lockfile, quando
existir — `package-lock.json`, `pnpm-lock.yaml` ou `yarn.lock` fixam a versão
resolvida; o `package.json` sozinho só dá o range).

Não achou nenhuma stack conhecida → siga para o passo 2 mesmo assim. O mapa
sai só com a parte genérica (passo 4), e `profile.md`/`map.md` **dizem
explicitamente** que não há checklist específico — nunca deixe isso
implícito, porque ausência de seção não distingue "sem risco" de "sem
cobertura". Registre em `profile.md`, na seção Stack, a tecnologia real que
`package.json` declarar (nome e versão de framework/runtime) como contexto —
deixando claro que não é uma stack catalogada do anvil, só o que existe no
projeto.

## 2. Carregar o checklist da stack

Só existe se a stack tiver sétima capacidade
(`STACK-CONTRACT.md` do `anvil-docs`): `.claude/skills/anvil-stack-<nome>/security/CHECKLIST.md`.

- **Presente** → leia cada item. Cada um traz "o que olhar", "como
  reconhecer", "teste do probe" (ou "só leitura") e "precedente". Aplique
  "como reconhecer" contra o código do projeto — é busca textual guiada pelo
  item, não execução.
- **Ausente** (stack detectada sem checklist, ou nenhuma stack detectada) →
  registre a lacuna em `profile.md` e no topo de `map.md`, e siga só com a
  parte genérica.

## 3. Ferramentas de segurança e ambiente local

Para `profile.md`. Nada disto executa a ferramenta — só confere presença:

```bash
for t in semgrep osv-scanner gitleaks trufflehog zap nuclei sqlmap schemathesis graphql-cop clairvoyance; do
  command -v "$t" >/dev/null 2>&1 && echo "presente: $t" || echo "ausente: $t"
done
npm audit --version >/dev/null 2>&1 && echo "presente: npm audit"
```

Ambiente local, só por leitura:

- **Alvo**: o script `dev` de `package.json` e a porta que ele assume (Next.js
  usa `3000` por padrão); `.env`/`.env.example` para `PORT`/`NEXT_PUBLIC_*`.
- **Banco**: `.env`/`.env.example` para `DATABASE_URI`/`MONGODB_URI` e
  variantes, `docker-compose*.yml` para o serviço de banco e a imagem.

Escreva o que achou; se um dos dois não aparecer no repositório, diga que não
foi encontrado — não adivinhe um valor.

## 4. Parte genérica

Sempre roda, com ou sem stack detectada. Os padrões e a categoria OWASP de
cada um estão em [reference/generic-checks.md](reference/generic-checks.md):
SQL cru, execução de comando, caminho de arquivo, fetch de URL do usuário,
template, autorização por rota, Server Actions e Route Handlers como
endpoints públicos, autorização feita só no middleware, segredos, CORS e
headers.

## 5. Parte específica (checklist da stack), quando houver

Para cada item do checklist, procure "como reconhecer" no código. Cada
ocorrência vira uma linha do mapa, citando arquivo:linha e o "teste do probe"
do próprio item, **verbatim** — não parafraseie o teste, porque é o contrato
que o probe lê depois.

No Payload, o item 1 do checklist (collections e rotas geradas) cobre cada
`src/collections/*.ts` (ou o caminho equivalente do projeto): toda collection
gera `GET/POST/PATCH/DELETE` REST e as operações GraphQL correspondentes,
inclusive edição e remoção em massa por `where`, mesmo sem nenhuma rota
escrita à mão. Liste cada collection com o `access` que ela define ou deixa
de definir — é o que a User Story do Payload pede.

## 6. IDs e categorias

`map.md` é organizado pelas categorias do
[OWASP Top 10:2025](https://owasp.org/Top10/2025/) e, na superfície de API
(Payload REST/GraphQL), do
[OWASP API Security Top 10:2023](https://owasp.org/API-Security/editions/2023/en/0x00-header/).
O esquema de id, a lista de categorias e a tabela "achado → categoria" que
todo item deste mapa segue estão em
[reference/categories.md](reference/categories.md) — leia antes de classificar
o primeiro item, para que duas execuções sem mudança no código produzam os
mesmos ids.

## 7. Escrever profile.md e map.md

Use [templates/profile.md](templates/profile.md) e
[templates/map.md](templates/map.md) como esqueleto. Escreva em
`docs/security/`, criando a pasta se não existir. Sobrescreva os dois
arquivos inteiros a cada execução — nunca faça merge com o que já estava lá,
e nunca leia ou grave `findings.md`.

Categoria sem nenhum achado **não aparece** no `map.md` — uma tabela vazia
não informa nada que a ausência da seção já não diga.

## 8. Antes de terminar

- Nenhum comando desta skill fez requisição de rede ao app do projeto, subiu
  processo do projeto, nem abriu conexão de banco. Consultar API de advisory
  (OSV.dev, GHSA) é uma extensão futura **deste map**, não do probe — enquanto
  ela não existir aqui, o item de versões do checklist sai como "só leitura,
  consulta externa não implementada nesta versão do map".
- `docs/security/findings.md` está exatamente como estava antes de rodar —
  inclusive **ausente**, se já estava ausente.
- `profile.md` diz, sem ambiguidade, se há checklist específico; sem ele, diz
  que a parte específica ficou de fora.
