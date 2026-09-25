# SOURCES

Skill autoral (`adr-0013` do anvil — as skills de segurança são autorais,
destiladas das referências). Desta lista entra a **ideia**, nunca o texto:
nenhuma frase de fonte CC-BY-SA-4.0 entra aqui, nem parafraseada de perto.
Nome e id de categoria (`A01`, `API1`, …) são citados como taxonomia pública,
não como o texto descritivo que cada projeto publica sob sua licença.

| De | Licença | O que entrou aqui |
|---|---|---|
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | a ideia do `repo-context`: entender stack, entrypoints e dependências do repositório antes de apontar risco — passo 1 desta skill |
| [trailofbits/skills](https://github.com/trailofbits/skills) | CC-BY-SA-4.0 — só a ideia, texto nunca copiado | `audit-context-building`: separar o que é do framework do que é do projeto antes de classificar um achado; `variant-analysis`: achar a mesma causa raiz em mais de um lugar — aqui, restrita a comparar o mecanismo de um advisory publicado contra o código do projeto (`reference/advisory-lookup.md`, resultado *b*), não a variant analysis mais ampla que o probe aplica sobre achado próprio |
| `claude-security`, de `anthropics/claude-plugins-official` | própria (não lida por completo) | o formato de saída: inventário e mapa organizados por categoria — aqui, sem o painel verificador nem o `.jsonl`/`.sarif` que o original grava ao lado do Markdown, porque este map nunca executa nada; `arquivo:linha` estável faz o papel de identificador verificável |
| [OWASP Top 10:2025](https://owasp.org/Top10/2025/) | CC-BY-SA-4.0 — só estrutura e ids | as dez categorias (`A01`–`A10`) que organizam `map.md` |
| [OWASP API Security Top 10:2023](https://owasp.org/API-Security/editions/2023/en/0x00-header/) | CC-BY-SA-4.0 — só estrutura e ids | as dez categorias de API (`API1`–`API10`), usadas na superfície REST/GraphQL do Payload |
| [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) | CC-BY-SA-4.0 — só a ideia | quais padrões de código contam como SQL Injection, SSRF, Mass Assignment, IDOR — usado para escrever `reference/generic-checks.md` com texto próprio, não citação |
| Docs oficiais do Payload — [Local API](https://payloadcms.com/docs/local-api/access-control), [REST](https://payloadcms.com/docs/rest-api/overview), [GraphQL](https://payloadcms.com/docs/graphql/overview), [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse), [Upload](https://payloadcms.com/docs/upload/overview), [Multi-tenant](https://payloadcms.com/docs/plugins/multi-tenant) | própria da Payload CMS | o contrato que `anvil-stack-payload/security/CHECKLIST.md` usa; este map só **lê** esse checklist, não repete a doc do Payload |
| [Server Actions](https://nextjs.org/docs/app/guides/server-actions), do Next.js | própria da Vercel | tratar toda Server Action e Route Handler como endpoint público |
| [GHSA-f82v-jwr5-mffw / CVE-2025-29927](https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw) | advisory público | apontar autorização feita só no middleware como falha, com o precedente do bypass por `x-middleware-subrequest` |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) | anvil | consolidação das fontes acima antes da destilação |
| [Cornjebus/security-analyzer](https://github.com/Cornjebus/security-analyzer) | MIT — só a ideia | cruzar a versão instalada de uma dependência contra banco de advisory estruturado antes de confiar na memória do checklist — aqui restrito a OSV.dev e GitHub Security Advisories, nunca CISA KEV/NVD, que o candidato também usa e este map não consulta |
| [OSV.dev API](https://google.github.io/osv.dev/api/) | Apache-2.0 (dados), API pública | o endpoint `POST /v1/query`, que devolve vulnerabilidade já filtrada por pacote+versão — `reference/advisory-lookup.md` usa a API, não replica dado do OSV.dev aqui |
| [GitHub REST API — Security Advisories](https://docs.github.com/en/rest/security-advisories/repository-advisories) | própria do GitHub | o endpoint `GET /repos/{owner}/{repo}/security-advisories`, usado para ler os advisories do repositório que o checklist da stack declarar |

Fora daqui, porque alimentam o `anvil-security-probe`, não este map: o
`validate`/`proxy` do Ghost (reproduzir contra o app rodando), o validador
adversarial do `claude-security-audit`, e o `fp-check` da Trail of Bits.

## Atualização

Manual — esta skill está fora do `anvil-skills.yaml`, sem pin nem sync
automático (adr-0013). Atualiza quando uma referência mudar de ideia ou uma
edição nova do OWASP Top 10/API Security Top 10 sair.
