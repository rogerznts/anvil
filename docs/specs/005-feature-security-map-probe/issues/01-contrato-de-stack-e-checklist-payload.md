# 01: O contrato de stack ganha a sétima capacidade, e o Payload traz o checklist

**Blocked by:** None (can start immediately)
**Status:** claimed

**What to build:** A stack passa a poder declarar o que olhar em segurança, e o `anvil-stack-payload` é a primeira a declarar. O `/anvil-security-map` vai ler esse checklist; aqui ele só precisa existir, estar no contrato e sobreviver ao sync do upstream.

Cada item do checklist diz o que olhar, como reconhecer no código ou na config, qual teste o probe aplica (ou "só leitura"), e o precedente: advisory confirmado ou doc oficial. Cobertura mínima, conforme a spec: collections e rotas REST/GraphQL geradas, Local API e `overrideAccess`, access control por campo, auth (`maxLoginAttempts`, `lockTime`, reset de senha), GraphQL (complexidade, introspection, playground), `csrf` e `cors`, upload (`mimeTypes`, `allowRestrictedFileTypes`, `pasteURL`, `skipSafeFetch`), multi-tenant (`useTenantAccess`), a camada Next.js (Server Actions, Route Handlers, middleware/proxy) e versões mínimas contra advisories.

Referências: `docs/discovery/seguranca-map-probe.md` e o adr-0012.

- [ ] O checklist de segurança existe dentro do `anvil-stack-payload` e cobre todos os temas listados acima
- [ ] Todo item cita um precedente; só advisories confirmados por leitura direta entram (os cinco não confirmados da pesquisa ficam de fora)
- [ ] Nenhum texto de fonte CC-BY-SA entra, nem parafraseado de perto
- [ ] O checklist está como `keep` do `anvil-stack-payload` no `anvil-skills.yaml`
- [ ] O contrato de stack descreve sete capacidades, com a sétima carregada só pelo map, e o checklist para stack nova pede o arquivo de segurança
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` passa
