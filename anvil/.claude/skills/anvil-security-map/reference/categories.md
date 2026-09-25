# Categorias e ids do mapa

A estrutura e os ids abaixo são do
[OWASP Top 10:2025](https://owasp.org/Top10/2025/) e do
[OWASP API Security Top 10:2023](https://owasp.org/API-Security/editions/2023/en/0x00-header/) —
nomes e ids de uma taxonomia pública, não o texto descritivo de cada projeto.
Nenhuma frase das páginas OWASP entra aqui.

## OWASP Top 10:2025

| id | categoria |
|---|---|
| A01 | Broken Access Control (inclui SSRF, incorporado nesta edição) |
| A02 | Security Misconfiguration |
| A03 | Software Supply Chain Failures |
| A04 | Cryptographic Failures |
| A05 | Injection |
| A06 | Insecure Design |
| A07 | Authentication Failures |
| A08 | Software or Data Integrity Failures |
| A09 | Security Logging & Alerting Failures |
| A10 | Mishandling of Exceptional Conditions |

## OWASP API Security Top 10:2023

Só entra quando o projeto expõe API (no Payload, sempre — REST e GraphQL são
gerados por collection).

| id | categoria |
|---|---|
| API1 | Broken Object Level Authorization |
| API2 | Broken Authentication |
| API3 | Broken Object Property Level Authorization |
| API4 | Unrestricted Resource Consumption |
| API5 | Broken Function Level Authorization |
| API6 | Unrestricted Access to Sensitive Business Flows |
| API7 | Server Side Request Forgery |
| API8 | Security Misconfiguration |
| API9 | Improper Inventory Management |
| API10 | Unsafe Consumption of APIs |

## Esquema de id

`<categoria>-<NN>`, dois dígitos, sequencial dentro da categoria — `A01-01`,
`A01-02`, `API1-01`. A ordem é determinística: dentro de cada categoria,
ordene os achados por arquivo e depois por linha, e numere nessa ordem. Rodar
o map de novo sem mudar o código produz os mesmos ids; mudar o código pode
renumerar os achados daquela categoria — é o custo de um id derivado da
posição, aceito porque o rastreamento permanente é o `SEC-#` do probe em
`findings.md`, não este id.

## Achado → categoria

A tabela abaixo é o julgamento desta skill, para que duas execuções
classifiquem o mesmo achado do mesmo jeito. Não é uma correspondência
publicada pela OWASP.

| Achado (genérico ou do checklist da stack) | Categoria primária |
|---|---|
| SQL cru, execução de comando, template (SSTI), upload sem `mimeTypes`/tipo restrito | A05 — Injection |
| Autorização por rota sem checagem de sessão/usuário (qualquer framework), caminho de arquivo (path traversal), fetch de URL do usuário (SSRF), Local API sem `overrideAccess: false`, autorização só no middleware, Server Actions/Route Handlers sem reautorização, multi-tenant sem `useTenantAccess`, `pasteURL` sem allowlist | A01 — Broken Access Control |
| CORS aberto, headers de segurança ausentes, GraphQL sem limite de profundidade/complexidade, introspection ou playground expostos, `csrf` mal configurado | A02 — Security Misconfiguration |
| Versão instalada de qualquer dependência direta do projeto vs. advisory do OSV.dev ou dos GitHub Security Advisories do repositório da stack | A03 — Software Supply Chain Failures |
| Segredo hardcoded, chave privada versionada | A04 — Cryptographic Failures |
| `maxLoginAttempts`/`lockTime` ausentes, fluxo de reset de senha sem validação | A07 — Authentication Failures |
| Collection Payload: rotas REST/GraphQL geradas e `access` que define ou deixa de definir | API1 — Broken Object Level Authorization |
| Campo de collection sem `access` próprio, herdando o da collection | API3 — Broken Object Property Level Authorization |

Um achado só cai em mais de uma linha desta tabela se afetar arquivo:linha
diferentes — a mesma ocorrência nunca ganha dois ids.
