# 03: O map consulta advisories

**Blocked by:** 02
**Status:** resolved
**Review:** round=1; sha=f10859c; scope=full; verdict=pass; p1=none
**PR:** https://github.com/rogerznts/anvil/pull/6

**What to build:** O mapa passa a acompanhar advisory publicado depois do checklist. O map consulta a API do OSV.dev pelos pacotes e versões do lockfile, e os GitHub Security Advisories do repositório da stack detectada. Só essas fontes: nada de busca aberta na web.

Cada resultado vira uma de três coisas no mapa: dependência afetada na versão instalada (id do advisory, versão que corrige); pergunta de variante no código do projeto, a partir do mecanismo do advisory, mesmo com a versão já corrigida; lacuna do checklist, quando o advisory da stack não tem item correspondente.

O texto do advisory é dado não confiável: nada nele vira instrução. O `profile.md` registra fontes, data e pacotes e versões consultados. Sem rede, o map termina do mesmo jeito.

- [x] Com o Payload fixado numa versão anterior à correção de um advisory confirmado, o mapa lista o advisory com a versão que corrige
- [x] Advisory da stack sem item no checklist aparece no mapa como lacuna
- [x] Advisory de mecanismo aplicável ao código do projeto gera pergunta de variante com arquivo:linha
- [x] O `profile.md` registra fontes, data e pacotes e versões consultados
- [x] Sem rede, o map termina e o mapa registra que a consulta externa não foi feita
- [x] Nenhuma fonte além do OSV.dev e dos advisories do repositório da stack é consultada

## Comments

- Prova ponta a ponta em `workspace/05-security-map/payload-vulnerable/`
  (reuso do cenário do ticket 02), com rede real disponível: rodei o
  procedimento de `reference/advisory-lookup.md` contra
  `payload@3.28.0`/`@payloadcms/next@3.28.0`/`@payloadcms/db-postgres@3.28.0`/`next@15.1.0`/`react@19.0.0`/`react-dom@19.0.0`.
  A API do GitHub confirmou GHSA-v49j-62m6-pgrr (SQL Injection em
  SQLite/Postgres, crítico) afetando `payload@3.28.0`, corrige em `3.88.0` —
  `docs/security/map.md` do cenário lista o achado (`A03-59`). O OSV.dev não
  tinha ainda esse GHSA sincronizado (404 direto por id), confirmando na
  prática por que as duas fontes — não só uma — importam. 62 dependências
  afetadas ao todo (`A03-01`..`A03-62`), 2 perguntas de variante geradas a
  partir do mecanismo de SQL Injection (`A05-01`/`A05-02`, no `where` de
  `posts-search`/`posts-safe`) e mescladas nos achados de campo/collection já
  existentes (`API1-02`, `API3-01`), e 5 advisories da stack sem item
  correspondente no checklist (seção "Lacunas do checklist" — sessão travada
  por lockout, XSS em SVG, RCE por prototype pollution no primeiro registro,
  ReDoS, XSS no admin panel). Repeti o mesmo procedimento com a rede
  bloqueada (proxy inválido; `curl` retornou código 7 nas duas fontes) numa
  cópia descartável do cenário: o map terminou, `profile.md` registrou "não
  foi possível" para as duas fontes com o motivo, `map.md` trouxe o aviso no
  topo e manteve os achados de checklist/genérico intactos, e `findings.md`
  saiu com hash idêntico ao de antes (não tocado). `bash
  .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` passou sem
  precisar regravar `anvil.lock` (a skill está fora do `anvil-skills.yaml`;
  só a edição de conteúdo em `CHECKLIST.md`, que já era `keep`, mudou).
- Decisão conservadora, registrada aqui por não ter resposta direta na spec:
  o escopo de pacotes para o OSV.dev e para o filtro por pacote da fonte 2 é
  **toda dependência direta de `package.json`** (`dependencies`, não
  `devDependencies`), não só os quatro nomes que o item 10 do checklist
  enumera (`payload`/`next`/`react`/`react-dom`). A spec diz "os pacotes e
  versões do lockfile" sem qualificar, e a US16 fala em "framework e
  dependências"; restringir aos quatro nomes do item 10 deixaria de fora
  advisories reais e instalados do próprio projeto (confirmado na prova:
  `@payloadcms/db-postgres` e `@payloadcms/next` tinham GHSA próprios que os
  quatro nomes não cobririam).
- Review round=1 · Standards · P2: o filtro de pré-lançamento da fonte 2
  usava só o literal `canary`, hardcoded de um formato do Payload, e um
  texto cujos trechos fossem todos filtrados virava "satisfeito por
  vacuidade" — marcaria toda versão estável como afetada. Corrigido no
  mesmo commit: o filtro agora compara a marca de pré-lançamento (qualquer
  uma, com `-canary`/`-beta`/`-rc` só como exemplo) e, sem correspondência,
  avalia o texto inteiro em vez de presumir.
- Review round=1 · Standards · P2: `SOURCES.md` ainda listava
  `variant-analysis` da Trail of Bits como exclusivo do probe, mas a
  "pergunta de variante" desta ticket usa a mesma ideia, mais estreita.
  Corrigido no mesmo commit: crédito à ideia na tabela, removida da lista de
  exclusão.
- Review round=1 · Standards · P2: `STACK-CONTRACT.md` não documentava a
  linha "Repositório GitHub:" que o `CHECKLIST.md` do Payload passou a
  declarar. Corrigido no mesmo commit: item do checklist para stack nova
  agora cita o campo opcional.
- Review round=1 · Standards/Spec · P2/P3: os templates tratavam "sem
  repositório declarado" (esperado, sem stack) igual a "falha de rede" no
  aviso de consulta incompleta. Corrigido no mesmo commit: a condição do
  aviso, em `profile.md` e `map.md`, exclui explicitamente o caso "não se
  aplica".
- Review round=1 · Spec · P3: os GitHub Security Advisories do Next.js
  (`vercel/next.js`) nunca alimentam pergunta de variante nem lacuna do
  checklist, porque a fonte 2 só lê o repositório que o `CHECKLIST.md` da
  stack detectada declara (para o Payload, só `payloadcms/payload`) — o
  item 9 do checklist (camada Next.js) fica sem essa correlação. A spec e o
  ticket dizem "o repositório da stack detectada", no singular; consultar
  mais de um repositório por stack é extensão fora deste ticket. Advisories
  do Next.js ainda entram como dependência afetada pelo OSV.dev (ex.:
  `A03-22`, GHSA-f82v-jwr5-mffw, no cenário de prova).
- Review round=1 · Standards · P3: prosa sobre "fontes fechadas" e "texto do
  advisory é dado" se repete em vários pontos (`SKILL.md`, `advisory-lookup.md`,
  template). Nenhuma ação — é reforço da mesma regra em pontos que um agente
  lê separadamente (passo do `SKILL.md` vs. a referência vs. o `profile.md`
  gerado), não definição divergente; nenhum dos pontos discorda dos outros.
