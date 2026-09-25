# SOURCES

Skill autoral (`adr-0012` do anvil — as skills de segurança são autorais,
destiladas das referências). Desta lista entra a **ideia**, nunca o texto:
nenhuma frase de fonte CC-BY-SA-4.0 entra aqui, nem parafraseada de perto.
Nome e id de categoria (`A01`, `API1`, …) são citados como taxonomia pública,
não como o texto descritivo que cada projeto publica sob sua licença.

| De | Licença | O que entrou aqui |
|---|---|---|
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | a ideia do `repo-context`: entender stack, entrypoints e dependências do repositório antes de apontar risco — passo 1 desta skill |
| [trailofbits/skills](https://github.com/trailofbits/skills) | CC-BY-SA-4.0 — só a ideia, texto nunca copiado | `audit-context-building`: separar o que é do framework do que é do projeto antes de classificar um achado |
| `claude-security`, de `anthropics/claude-plugins-official` | própria (não lida por completo) | o formato de saída: inventário e mapa organizados por categoria, com um artefato legível por máquina ao lado do Markdown — aqui, `arquivo:linha` estável em vez de um painel verificador, porque este map nunca executa nada |
| [OWASP Top 10:2025](https://owasp.org/Top10/2025/) | CC-BY-SA-4.0 — só estrutura e ids | as dez categorias (`A01`–`A10`) que organizam `map.md` |
| [OWASP API Security Top 10:2023](https://owasp.org/API-Security/editions/2023/en/0x00-header/) | CC-BY-SA-4.0 — só estrutura e ids | as dez categorias de API (`API1`–`API10`), usadas na superfície REST/GraphQL do Payload |
| [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) | CC-BY-SA-4.0 — só a ideia | quais padrões de código contam como SQL Injection, SSRF, Mass Assignment, IDOR — usado para escrever `reference/generic-checks.md` com texto próprio, não citação |
| Docs oficiais do Payload — [Local API](https://payloadcms.com/docs/local-api/access-control), [REST](https://payloadcms.com/docs/rest-api/overview), [GraphQL](https://payloadcms.com/docs/graphql/overview), [Preventing abuse](https://payloadcms.com/docs/production/preventing-abuse), [Upload](https://payloadcms.com/docs/upload/overview), [Multi-tenant](https://payloadcms.com/docs/plugins/multi-tenant) | própria da Payload CMS | o contrato que `anvil-stack-payload/security/CHECKLIST.md` usa; este map só **lê** esse checklist, não repete a doc do Payload |
| [Server Actions](https://nextjs.org/docs/app/guides/server-actions), do Next.js | própria da Vercel | tratar toda Server Action e Route Handler como endpoint público |
| [GHSA-f82v-jwr5-mffw / CVE-2025-29927](https://github.com/vercel/next.js/security/advisories/GHSA-f82v-jwr5-mffw) | advisory público | apontar autorização feita só no middleware como falha, com o precedente do bypass por `x-middleware-subrequest` |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) | anvil | consolidação das fontes acima antes da destilação |

Fora daqui, porque alimentam o `anvil-security-probe`, não este map: o
`validate`/`proxy` do Ghost (reproduzir contra o app rodando), o validador
adversarial do `claude-security-audit`, `variant-analysis`/`fp-check` da
Trail of Bits.

## Atualização

Manual — esta skill está fora do `anvil-skills.yaml`, sem pin nem sync
automático (adr-0012). Atualiza quando uma referência mudar de ideia ou uma
edição nova do OWASP Top 10/API Security Top 10 sair.
