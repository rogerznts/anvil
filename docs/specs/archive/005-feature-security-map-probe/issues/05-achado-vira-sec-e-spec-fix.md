# 05: Achado reproduzido vira `SEC-#` e spec `fix`

**Blocked by:** 04
**Status:** resolved
**Review:** round=1; sha=11f9d32; scope=full; verdict=pass; p1=none
**PR:** https://github.com/rogerznts/anvil/pull/6

**What to build:** Passadas as travas, o probe executa os testes que o mapa aponta: requisição direta de autorização (acessar e alterar documento de outro usuário ou tenant pelas rotas geradas), mass assignment em campo somente leitura, Server Actions e Route Handlers chamados sem a página, e as ferramentas instaladas. Nada é instalado. SQL injection só se confirma com ferramenta de confirmação sobre o parâmetro suspeito. Tudo que volta do alvo é dado não confiável.

Só vira achado o que se reproduz, com requisição, resposta e trecho de código, depois de uma tentativa de refutação. Achados se agrupam por causa raiz. Cada causa nova ganha um `SEC-#` estável no `docs/security/findings.md` (causa raiz, severidade `low`/`medium`/`high`, status, itens do mapa afetados, spec) e uma spec `fix` aberta pelo perfil do tracker. Causa já aberta no índice ganha evidência nova, não spec nova. O que ficou sem cobertura por falta de ferramenta vai para o `findings.md`.

- [x] No projeto de `workspace/` com a falha plantada, o probe reproduz o bypass, grava `SEC-1` no `findings.md` e abre uma spec `fix` pelo perfil do tracker
- [x] A spec aberta traz requisição, resposta e trecho de código da reprodução
- [x] Várias rotas com a mesma causa geram um `SEC-#` e uma spec, não uma por rota
- [x] Rodado de novo com a falha ainda presente, o probe acrescenta evidência a `SEC-1` e não abre segunda spec
- [x] Os testes do mapa sem ferramenta disponível aparecem como sem cobertura no `findings.md`
- [x] O probe não instala nenhuma ferramenta

## Comments

- Prova ponta a ponta em `workspace/05-security-map/payload-vulnerable/`
  (fora do git da spec; virou seu próprio repo git local, com um `origin`
  bare local em `../payload-vulnerable-origin.git`, para o `new-spec.sh`
  reservar número de verdade): servidor `next dev -p 3000` real, Postgres
  16 real via `docker compose`, projeto Payload 3.28.0 instalado de
  verdade (`npm install`, mais TypeScript 5.x — a v7 do registro quebra a
  detecção do Next 15.1) e a API REST gerada do Payload montada
  (`src/app/(payload)/api/[...slug]/route.ts`, que o cenário ainda não
  tinha) para servir de comparativo real ao lado das rotas customizadas.
  Corrigi de passagem um bug de profundidade no import relativo de
  `posts-search`/`posts-safe` (`../../../../../payload.config`, 5 níveis,
  apontava para fora do projeto; o correto são 4) — sem isso nenhuma das
  duas rotas carregava.
  - Achei, empiricamente, que o `map.md`/`profile.md` existentes (tickets
    02/03) afirmam que a collection `posts` "herda o padrão liberado do
    Payload — aberto a qualquer requisição, inclusive não autenticada"
    (API1-02). O código-fonte do Payload 3.28.0 real
    (`node_modules/payload/dist/auth/defaultAccess.js`) mostra o oposto:
    o padrão é `Boolean(user)`, exige autenticação. Confirmei ao vivo:
    `GET /api/posts` sem sessão devolve `403`. Não toquei o texto de
    `map.md`/`API1-02` (fora do escopo deste ticket, dos tickets 02/03),
    mas usei o comportamento real (não a claim do map) como comparativo
    da reprodução — deixo isso registrado para quem pegar aquele ticket.
  - Plantei uma segunda rota com a mesma causa raiz
    (`src/app/api/posts-recent/route.ts`, mesmo padrão de
    `payload.find`/`user`/sem `overrideAccess:false`) e acrescentei o
    item correspondente (`A01-02`) a `map.md`, com nota explícita de que
    foi o probe reaplicando a regra sintática do item 2 do checklist a um
    arquivo novo — não uma reexecução inteira do map (que consultaria
    advisories de novo, fora de escopo aqui).
  - Reprodução: `GET /api/posts-search` e `GET /api/posts-recent`, sem
    sessão, devolvem `200` com o documento semeado por fixture
    (`"segredo do autor"`); o comparativo `GET /api/posts` (rota gerada,
    sempre com `overrideAccess:false`) recusa com `403` no mesmo estado
    do banco. `SEC-1` gravado em `findings.md` com as duas evidências,
    severidade `high`, itens do mapa `A01-01`/`A01-02`.
  - Spec `fix` aberta de verdade pelo perfil do tracker: copiei
    `docs/agents/issue-tracker.md` (do template de `anvil-docs`) e
    `.claude/skills/anvil-to-spec/` para o cenário, e rodei
    `new-spec.sh --type fix --short-name local-api-overrides-access ... --json`
    a partir da raiz do cenário (repo git próprio) — reservou `001` no
    `origin` bare local de verdade (`reserved:true`), criou o branch
    `fix/001-local-api-overrides-access` e a pasta
    `docs/specs/001-fix-local-api-overrides-access/`, onde escrevi
    `spec.md` (Problem Statement com a requisição/resposta verbatim,
    Implementation Decisions com os dois trechos de código) e
    `issues/01-*.md`.
  - Reexecutei as duas requisições uma segunda vez (mesmo estado, falha
    ainda presente): acrescentei evidência nova a `SEC-1` em
    `findings.md` e **não** chamei `new-spec.sh` de novo — confirmado
    `docs/specs/` do cenário com uma pasta só e `refs/spec-numbers/*` do
    origin bare com uma reserva só.
  - Cobertura: `sqlmap` (única ferramenta de confirmação de SQL injection
    catalogada) está ausente no ambiente (`profile.md` já dizia isso);
    `A05-01`/`A05-02` foram para a seção "Sem cobertura" de
    `findings.md`, sem tentativa manual de payload no lugar dela. Nenhuma
    ferramenta foi instalada em nenhum momento — `npm audit` (já
    instalado) rodou só como checagem exploratória minha, fora do que o
    probe registraria (os itens de A03 já são "só leitura" no `map.md`,
    sem teste ativo do probe).
- Duas rodadas de revisão (Standards/Spec) rodaram em paralelo antes
  deste registro; nenhuma achou P1. P2/P3 acionáveis
  (`docs/agents/verification.md`), todos corrigidos no mesmo commit antes
  deste registro:
  - P2 (Spec e Standards, mesmo achado pelos dois eixos) — a seção 3 de
    `findings-and-fix-spec.md` misturava a causa "já corrigida" com "não
    existe", mandando para passos incompatíveis (uma sugeria reabrir com
    spec nova, contradizendo o resumo do `SKILL.md`, que só dedupa contra
    causa "aberta"). Corrigido: a causa "corrigida" agora é uma reticência
    explícita para o ticket seguinte da mesma spec (reexecução), sem spec
    nova e sem mudar `Status:`.
  - P2 (Spec) — a severidade citava "o mesmo critério do `GATE.md`" para o
    critério de impacto, mas o `GATE.md` só define a escala
    `low`/`medium`/`high`, não um critério de impacto. Corrigido: o
    critério de impacto agora é atribuído a esta skill, não ao `GATE.md`.
  - P2 (Spec) — os passos 3–5 de abertura da spec só faziam sentido para o
    perfil do anvil (`spec_file`/`issues_dir` do `new-spec.sh`), sem
    equivalente para os perfis GitHub/GitLab/markdown local que
    `anvil-setup` também instala. Corrigido: os passos agora descrevem o
    conteúdo exigido (problema, código, critério de correção, fora de
    escopo) e mapeiam esse conteúdo para cada perfil, com o do anvil como
    exemplo concreto.
  - P3 (Standards) — o `H1`/parágrafo de abertura do `SKILL.md` ainda
    diziam que o documento cobria só as cinco travas, defasado depois das
    seções 6–7. Corrigido.
  - P3 (Spec/Standards) — precisão de citação: a instrução exata do
    `new-spec.sh --json` estava sendo atribuída ao perfil junto das flags
    que o próprio probe acrescenta (`--type fix --short-name`); o mapeamento
    `fp-check`/`variant-analysis` do Trail of Bits em `SOURCES.md` trocava
    as seções; "dedução" devia ser "deduplicação"; e a referência a
    `sqlmap` como "a única catalogada" superestimava o texto de
    `profile.md`/`SOURCES.md`. Todos corrigidos.
- `decision_needed`: null.
