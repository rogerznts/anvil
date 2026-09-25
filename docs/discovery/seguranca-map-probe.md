# Skills de segurança: `anvil-security-map` e `anvil-security-probe`

Pesquisa de 2026-09-24, antes do grill. Fontes primárias: o repositório de cada
candidato (README, `SKILL.md`, `LICENSE`, commits), OWASP, docs oficiais do
Payload e do Next.js. O que não foi confirmado por leitura direta está marcado.

## Decisões já tomadas

- Nomes: `anvil-security-map` (gera o mapa) e `anvil-security-probe` (executa
  contra o ambiente de desenvolvimento e abre spec de correção por achado).
- Lugar: `docs/security/`, com o mapa e um índice de achados e solucionados.
- Agnóstica de stack, com foco inicial no Payload. A análise da stack acontece
  num boot, dentro do `anvil-boot` ou num `security-boot` próprio — em aberto.

## Candidatos a upstream

### Cobrem map e probe

| Candidato | Licença | `SKILL.md` | Atividade | O que traz |
|---|---|---|---|---|
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | 8 | 2026-09-23 | Pipeline `repo-context` → `scan-deps` → `scan-secrets` → `scan-code` → `report`, e `validate` + `proxy`, que confirmam o achado contra o app rodando |
| [TobiasVeiga00/claude-security-audit](https://github.com/TobiasVeiga00/claude-security-audit) | MIT | por domínio | 2026-09-23 | Trava de escopo explícita (nada vai para a rede sem regra de engajamento escrita), validador adversarial que tenta refutar cada achado, saída SARIF |
| [AgentSecOps/SecOpsAgentKit](https://github.com/AgentSecOps/SecOpsAgentKit) | CC-BY-SA-4.0 / MPL-2.0 | 25+ | não confirmado | Uma skill fina por ferramenta real: `dast-zap`, `dast-nuclei`, `webapp-sqlmap`, `secrets-gitleaks`, e threat modeling STRIDE com `pytm` |

O `ghostsecurity/skills` depende de três binários da própria Ghost:
[wraith](https://github.com/ghostsecurity/wraith) (dependências),
[poltergeist](https://github.com/ghostsecurity/poltergeist) (segredos) e
[reaper](https://github.com/ghostsecurity/reaper) (proxy MITM).

O `claude-security-audit` é de um autor só, e recente.

### Cobrem só o map

| Candidato | Licença | `SKILL.md` | Atividade | O que traz |
|---|---|---|---|---|
| [anthropics/claude-plugins-official → `claude-security`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-security) | LICENSE + NOTICE próprios, não lidos | sim | CI ativo; data não confirmada | Oficial da Anthropic. Inventário, threat model, caça, e um painel verificador independente por achado. Saída `.md` + `.jsonl` + `.sarif`. `disable-model-invocation: true`; os *dynamic workflows* exigem plano pago |
| [trailofbits/skills](https://github.com/trailofbits/skills) | CC-BY-SA-4.0 | maioria dos 42 plugins | 2026-09-21 | `audit-context-building` (entender antes de caçar), `static-analysis` (CodeQL, Semgrep, SARIF), `variant-analysis`, `supply-chain-risk-auditor`, `fp-check` (triagem de falso positivo) |
| [UnboundCompute/security-agent-skills](https://github.com/UnboundCompute/security-agent-skills) | MIT | 194 | 2026-09-08 | Metodologia granular por classe (BOLA, mass assignment, GraphQL, SSRF) e um `FINDING-SCHEMA.md` compartilhado. Repositório novo, 5 estrelas |
| [Cornjebus/security-analyzer](https://github.com/Cornjebus/security-analyzer) | MIT | 1 | não confirmado | Cruza dependências com CISA KEV, NVD, GitHub Advisories e OSV.dev |

### Referência, sem executar

| Candidato | Licença | O que traz |
|---|---|---|
| [agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp) | MIT | OWASP Top 10:2025 e ASVS 5.0 com ids verificados, padrões por linguagem. Instala por `degit`, como o anvil |
| [vbs0101/appsec-sentinel](https://github.com/vbs0101/appsec-sentinel) | MIT | Roteiro de pentest que começa por autorização e escopo. Zero estrelas |
| [anthropics/claude-code-security-review](https://github.com/anthropics/claude-code-security-review) | MIT | GitHub Action e a fonte do `/security-review` nativo. Sem `SKILL.md`. [Doc oficial](https://support.claude.com/en/articles/11932705-automated-security-reviews-in-claude-code) |
| [`security-guidance`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance) | não lido | Hooks puros durante a edição. Sem `SKILL.md` |
| [semgrep/mcp-marketplace](https://github.com/semgrep/mcp-marketplace) | não confirmado | Semgrep Guardian: hook pós-edição + MCP. A única skill é de instalação |

Descartados: [anthropics/skills](https://github.com/anthropics/skills) não tem
nenhuma skill de segurança; [semgrep/mcp](https://github.com/semgrep/mcp) foi
arquivado em 2025-10-28.

## Licença: o que pesa na vendorização

O anvil não tem `LICENSE` na raiz. CC-BY-SA-4.0 (Trail of Bits, SecOpsAgentKit)
é *share-alike*: a cópia adaptada tem que sair sob a mesma licença. MIT e
Apache-2.0 só pedem atribuição e aviso, o que o `VENDOR.md` já faz.

## Metodologia que o mapa segue

| Fonte | Versão | Papel no mapa |
|---|---|---|
| [OWASP Top 10](https://owasp.org/Top10/2025/) | 2025 | Estrutura de alto nível. SSRF entrou em A01 Broken Access Control |
| [OWASP API Security Top 10](https://owasp.org/API-Security/editions/2023/en/0x00-header/) | 2023 | Prioridade no Payload: API1 BOLA e API3 mass assignment, porque o REST e o GraphQL saem gerados por collection |
| [OWASP ASVS](https://github.com/OWASP/ASVS) | 5.0.0 | Checklist de postura, com veredito e arquivo:linha |
| [OWASP WSTG](https://github.com/OWASP/wstg) | 4.2 estável | Id de cada teste (`WSTG-ATHZ-04` para IDOR) |
| [Cheat sheets](https://cheatsheetseries.owasp.org/) | — | SQL Injection, IDOR, Authorization, SSRF, Mass Assignment, GraphQL, Multi Tenant, Next.js, Node.js |

## Ferramentas para o probe

| Ferramenta | Detecta | App rodando? | Licença |
|---|---|---|---|
| [Semgrep CE](https://github.com/semgrep/semgrep) | SAST. Não há ruleset de Next.js, só JS/TS genérico | não | LGPL-2.1; regras sob Semgrep Rules License |
| [OSV-Scanner](https://github.com/google/osv-scanner) | Dependências com CVE, por lockfile | não | Apache-2.0 |
| `npm audit` / `pnpm audit` | Dependências com CVE | não | embutido |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Segredos no código e no histórico | não | MIT |
| [TruffleHog](https://github.com/trufflesecurity/trufflehog) | Segredos, com verificação ao vivo da credencial | parcial | AGPL-3.0 |
| [OWASP ZAP](https://github.com/zaproxy/zaproxy) | Headers, cookies, CSP; API scan de OpenAPI e GraphQL | sim | Apache-2.0 |
| [nuclei](https://github.com/projectdiscovery/nuclei) | CVE conhecida, misconfig, exposição | sim | MIT |
| [sqlmap](https://github.com/sqlmapproject/sqlmap) | Confirma SQL injection num parâmetro suspeito | sim | GPLv2 |
| [Schemathesis](https://github.com/schemathesis/schemathesis) | Fuzz de OpenAPI e GraphQL | sim | MIT |
| [graphql-cop](https://github.com/dolevf/graphql-cop) | Introspection, GraphiQL exposto, batching, alias overloading; gera `curl` reproduzível | sim | MIT |
| [clairvoyance](https://github.com/nikitastupin/clairvoyance) | Reconstrói o schema com introspection desligada | sim | Apache-2.0 |

## Payload: o que o mapa tem que olhar

Das docs oficiais:

- [Local API](https://payloadcms.com/docs/local-api/access-control): `overrideAccess`
  é `true` por padrão. Chamada com `user` e sem `overrideAccess: false` num
  route handler ou numa Server Action ignora o access control.
- [REST](https://payloadcms.com/docs/rest-api/overview) e
  [GraphQL](https://payloadcms.com/docs/graphql/overview): toda collection ganha
  `GET/POST/PATCH/DELETE`, inclusive em massa por `where`. Cada collection vira
  uma linha do mapa, cruzada com as `access` que ela define ou não define.
- [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse):
  `maxLoginAttempts`, `lockTime`, `maxDepth`, `graphQL.maxComplexity`,
  `disableIntrospectionInProduction`, CSRF, CORS. É quase um checklist pronto.
- [Upload](https://payloadcms.com/docs/upload/overview): `mimeTypes`,
  `allowRestrictedFileTypes`, `pasteURL` (ligado por padrão, vetor de SSRF),
  `skipSafeFetch`.
- `csrf` é uma allowlist de domínio para o cookie e não tem relação com `cors`.
  `cors: '*'` com autenticação por cookie é configuração perigosa.
- [Multi-tenant](https://payloadcms.com/docs/plugins/multi-tenant):
  `useTenantAccess: false` desliga o filtro automático de tenant.

[Advisories do repositório](https://github.com/payloadcms/payload/security/advisories),
lidos em 2026-09-24. As mesmas classes já aconteceram no núcleo:

- SQL injection em SQLite e Postgres (GHSA-v49j-62m6-pgrr, crítico, 2026-09-22)
- prototype pollution no plugin Import Export (GHSA-qf28-8hc6-vwrp, crítico, 2026-09-22)
- vazamento de campo oculto por sort e por join polimórfico (GHSA-9g87-32v6-3c2r, GHSA-fpww-c55p-cjv6)
- XML enviado por upload executando JavaScript same-origin (GHSA-9qpg-3cf8-w33x)
- password recovery sem validação (GHSA-hp5w-3hxx-vmwf, CVE-2026-34751, CVSS 9.1)
- IDOR entre collections em `payload-preferences` (GHSA-jq29-r496-r955, CVE-2026-25574)

Cinco outros (CSRF bypass, SSRF por upload, escrita em campo no MongoDB) vieram
de busca e **não foram confirmados** por leitura direta.

Consequência para o probe: o primeiro teste é a versão instalada do Payload
contra essa lista. É o mais barato e o de maior acerto.

## Next.js: o que o mapa tem que olhar

- [CVE-2025-29927](https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw):
  com o header `x-middleware-subrequest` forjado, o middleware é pulado. Regra
  do mapa: toda rota protegida reautoriza no handler, não só no middleware
  (`proxy.ts` a partir do Next 16).
- [CVE-2025-66478](https://github.com/vercel/next.js/security/advisories/GHSA-9qr9-h5gf-34mp)
  / CVE-2025-55182: RCE no protocolo RSC Flight. Corrigido em React ≥ 19.2.3 e
  Next ≥ 15.4.10. [Aviso do Payload](https://payloadcms.com/posts/blog/critical-security-notice-affecting-react-19-and-nextjs).
- [Server Actions](https://nextjs.org/docs/app/guides/server-actions): *"Treat
  Server Actions with the same security considerations as public-facing API
  endpoints"*. Toda action exportada aceita POST direto.
- [Data security](https://nextjs.org/docs/app/guides/data-security) e o
  [cheat sheet de Next.js](https://cheatsheetseries.owasp.org/cheatsheets/Nextjs_Security_Cheat_Sheet.html):
  camada de acesso a dados server-only, DTO mínimo,
  `images.dangerouslyAllowLocalIP`, `productionBrowserSourceMaps`.

## Leitura

Nenhum candidato cobre o que é do anvil: salvar em `docs/security/`, abrir spec
pelo perfil do tracker, puxar checklist da skill de stack. O que se aproveita é
o **desenho**:

- **map**: `repo-context` do Ghost ou `audit-context-building` da Trail of Bits
  para o passo "entender antes de caçar"; o formato de saída do `claude-security`.
- **probe**: a trava de escopo do `claude-security-audit`; o `validate` do Ghost
  (reproduzir antes de reportar); o `fp-check` da Trail of Bits.

Decidido: autoral, destilando as ideias destas referências. Ver o
[adr-0013](../architecture/adr/adr-0013-skills-de-seguranca-sao-autorais.md).
