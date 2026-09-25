# 01: O contrato de stack ganha a sétima capacidade, e o Payload traz o checklist

**Blocked by:** None (can start immediately)
**Status:** resolved
**Review:** round=1; sha=203f333; scope=full; verdict=pass; p1=none

**What to build:** A stack passa a poder declarar o que olhar em segurança, e o `anvil-stack-payload` é a primeira a declarar. O `/anvil-security-map` vai ler esse checklist; aqui ele só precisa existir, estar no contrato e sobreviver ao sync do upstream.

Cada item do checklist diz o que olhar, como reconhecer no código ou na config, qual teste o probe aplica (ou "só leitura"), e o precedente: advisory confirmado ou doc oficial. Cobertura mínima, conforme a spec: collections e rotas REST/GraphQL geradas, Local API e `overrideAccess`, access control por campo, auth (`maxLoginAttempts`, `lockTime`, reset de senha), GraphQL (complexidade, introspection, playground), `csrf` e `cors`, upload (`mimeTypes`, `allowRestrictedFileTypes`, `pasteURL`, `skipSafeFetch`), multi-tenant (`useTenantAccess`), a camada Next.js (Server Actions, Route Handlers, middleware/proxy) e versões mínimas contra advisories.

Referências: `docs/discovery/seguranca-map-probe.md` e o adr-0013.

- [x] O checklist de segurança existe dentro do `anvil-stack-payload` e cobre todos os temas listados acima
- [x] Todo item cita um precedente; só advisories confirmados por leitura direta entram (os cinco não confirmados da pesquisa ficam de fora)
- [x] Nenhum texto de fonte CC-BY-SA entra, nem parafraseado de perto
- [x] O checklist está como `keep` do `anvil-stack-payload` no `anvil-skills.yaml`
- [x] O contrato de stack descreve sete capacidades, com a sétima carregada só pelo map, e o checklist para stack nova pede o arquivo de segurança
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` passa

## Comments

- Review round=1 · Standards · P3: o bloco ASCII de `STACK-CONTRACT.md` alinha
  o comentário de cada entrada na coluna 25, e `security/CHECKLIST.md` já
  ocupa essa coluna sozinho — realinhar exigiria reflow do bloco inteiro,
  fora do escopo cirúrgico deste ticket. Puramente cosmético, nenhum leitor é
  enganado.
- Review round=1 · Spec · P3: o item 5 do checklist (GraphQL) atribuía a
  postura de playground só à página *Preventing abuse*; corrigido no mesmo
  commit para também citar *GraphQL overview*, de onde vem essa afirmação
  específica.
- Review round=1 · Standards · P3: a vírgula depois da crase em
  `` `security/CHECKLIST.md`, opcional `` destoava dos demais itens do
  checklist para stack nova; corrigido no mesmo commit.
- Review round=1 · Spec: nota, não achado — `VENDOR.md` ganhou uma linha
  documentando `security/CHECKLIST.md` como adição do anvil. Não pedido pelo
  ticket, mas seguindo a convenção que o próprio arquivo já usa para `RULE.md`
  e `bench/`; deixar de fora seria a inconsistência.
- Achado, fora do diff revisado pelos dois eixos: `docs/architecture/overview.md`
  também citava "contrato de 6 capacidades" no diagrama da camada stack.
  Corrigido para 7 e para listar `security/` ao lado de `RULE.md`/`reference/`/
  `bench/`, no mesmo commit — mesma correção já validada pelos dois eixos em
  `STACK-CONTRACT.md`, sem justificar nova rodada.
