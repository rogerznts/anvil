# 06: Rodar de novo fecha e reabre achados

**Blocked by:** 05
**Status:** resolved
**Review:** round=1; sha=e0e42c2; scope=full; verdict=pass; p1=none
**PR:** https://github.com/rogerznts/anvil/pull/6

**What to build:** O `findings.md` acompanha as correções. Ao rodar de novo, o probe retesta cada `SEC-#`: o que não se reproduz mais vira `corrigido`; o que estava `corrigido` e volta a se reproduzir é reaberto no mesmo `SEC-#`, com a evidência nova, sem id novo.

- [x] Com a falha plantada corrigida, o probe marca `SEC-1` como `corrigido`
- [x] Reintroduzida a falha, o probe reabre `SEC-1` com evidência nova, sem criar `SEC-2`
- [x] Achado cujo teste ficou sem cobertura nesta rodada não muda de status

## Comments

- Ramo adiado pelo ticket 05 resolvido: `reference/findings-and-fix-spec.md`
  seção 3 ("já existe, corrigida") não é mais uma reticência — descreve a
  reabertura por completo (mesmo `SEC-#`, `Status:` de volta para `aberto`,
  evidência nova com nota explícita de reabertura, campo `Spec` intocado).
  Seção 6, nova, define o fechamento: um `SEC-#` só vira `corrigido` quando
  **todos** os ids de `Itens do mapa` rodaram na mesma rodada e nenhum
  reproduziu; um id ainda positivo mantém `aberto` a causa inteira; e um
  `SEC-#` com algum id sem cobertura nesta rodada (ferramenta ausente, alvo
  que não respondeu) não decide nada — `Status:` fica exatamente como
  estava, dos dois lados (`aberto` continua `aberto`, `corrigido` continua
  `corrigido`).
- Decisão registrada (conservadora) sobre a spec/ticket `fix` ligada na
  reabertura: o probe não edita nem a spec nem o ticket de correção —
  aplicar ou desfazer a correção já era fluxo normal de tickets, fora do
  escopo desta skill (seção 5). O campo `Spec` do achado não muda (continua
  apontando para o valor já gravado, mesmo que a spec/ticket referenciados
  já tenham sido mesclados/arquivados desde a correção original). O perfil
  do tracker do anvil (`docs/agents/issue-tracker.md`) não define uma
  convenção própria de reabertura por regressão — só define
  `resolved`→`claimed` para P1 de revisão — então o texto não afirma que é
  "a mesma convenção", só sugere emprestá-la, à mão, fora desta skill; quem
  administra aquele ticket decide como reabri-lo a partir da evidência que
  fica em `findings.md`.
- Prova ponta a ponta em `workspace/05-security-map/payload-vulnerable/`
  (servidor `next dev -p 3000` real, Postgres 16 real via `docker
  compose`), reaproveitando o cenário e o `SEC-1` do ticket 05:
  1. Corrigi de verdade as duas rotas (`overrideAccess: false` +
     `try/catch` traduzindo o `Forbidden` que o Local API lança em `403`
     com o mesmo corpo do comparativo, em vez de deixar virar `500` sem
     tratamento — sem isso as duas rotas quebravam com `overrideAccess:
     false` e sem sessão). `GET /api/posts-search` e `GET
     /api/posts-recent`, sem sessão, passaram a responder `403` igual ao
     comparativo (`GET /api/posts`). Os dois ids do achado (`A01-01`,
     `A01-02`) testaram limpo na mesma rodada → `SEC-1` fechou como
     `corrigido`, com evidência da recusa. Marquei `docs/specs/001-.../
     issues/01-adicionar-overrideaccess-false.md` como `resolved` (os
     quatro critérios do próprio ticket viraram verdade).
  2. Reintroduzi a mesma causa raiz nas duas rotas (removi
     `overrideAccess: false` de novo). As duas voltaram a `200` com o
     documento privado. `SEC-1` reabriu — mesmo id, sem `SEC-2` — com
     evidência nova, e o ticket 01 (já `resolved`) ficou intocado de
     propósito, demonstrando a decisão conservadora acima.
  3. Corrigi as duas rotas de novo e, para simular lacuna de cobertura
     (sugestão do próprio ticket: "servidor sem a rota"), renomeei
     temporariamente `src/app/api/posts-recent/` para tirá-la do ar nesta
     rodada. `GET /api/posts-search` testou limpo (`403`); `GET
     /api/posts-recent` voltou `404` (rota indisponível), sem teste real
     possível. Como nem todos os ids de `SEC-1` rodaram, nenhuma transição
     foi decidida — `Status:` continuou `aberto` (o valor de antes desta
     rodada), mesmo com o outro id limpo; `A01-02` entrou em "Sem
     cobertura". Restaurei a rota, rodei mais uma vez com cobertura
     completa e limpa nos dois ids → `SEC-1` fechou de novo como
     `corrigido` (estado final do cenário).
  - `docs/security/findings.md` do cenário acumula as seis execuções
    (ticket 05 abriu com duas; este ticket acrescentou quatro: fecha,
    reabre, lacuna sem decisão, fecha de novo), cada uma com data,
    requisição/resposta e `arquivo:linha`, sem reescrever entradas
    anteriores.
  - Commits do cenário (repo git próprio,
    `workspace/05-security-map/payload-vulnerable/`, fora do git do
    anvil): `4079f6d` (fecha), `0d5656e` (reabre), `0c47e63` (lacuna +
    fechamento final).
- Revisão em duas rodadas paralelas (Spec/Standards) sobre
  `git diff 2fe40d3..e0e42c2` (só os 3 arquivos da skill); nenhuma achou
  P1. P2/P3 acionáveis, todos corrigidos no commit `317a68b` antes deste
  registro (a linha `Review:` acima referencia `e0e42c2`, o sha que a
  revisão de fato mediu — o padrão já usado no ticket 05):
  - P2 (Standards) — o texto afirmava que "a convenção que o perfil do
    tracker já usa para regressão" era `resolved`→`claimed`, mas
    `docs/agents/issue-tracker.md` só define essa mecânica para P1 de
    revisão, sem convenção própria de regressão; e o campo `Spec` podia
    apontar para uma spec já arquivada/mesclada sem o texto admitir isso.
    Corrigido: a seção agora diz que o perfil não define essa convenção,
    só sugere emprestá-la, e reconhece que a spec/ticket referenciados
    podem ter mudado de lugar.
  - P2 (Standards e Spec, mesmo achado pelos dois eixos) — o resumo do
    `SKILL.md` dizia "todo id do achado sem reprodução nesta rodada fecha
    o `SEC-#`", contradizendo a própria referência (que exige **todos**
    os ids limpos na mesma rodada). Corrigido nos dois lugares do
    `SKILL.md` (resumo da seção 7 e checklist "Antes de terminar").
  - P2 (Standards) — texto anterior ao ticket 06 (herdado do ticket 05)
    ainda falava em checar só causa "aberta" antes de abrir spec nova,
    sem contar `corrigido` (que também bloqueia spec nova, na reabertura).
    Corrigido no `SKILL.md`.
  - P2 (Spec) — a lacuna "rota que o servidor não expôs" não cabia na
    definição de "Sem cobertura" da seção 4 de `findings-and-fix-spec.md`,
    que só falava em falta de ferramenta. Corrigido: a seção agora cobre
    os dois motivos, com a coluna da tabela generalizada.
  - P3 (Spec) — a evidência de fechamento (seção 6) só fazia sentido para
    a classe de autorização direta (comparativo). Generalizado para
    também cobrir mass assignment e classes por ferramenta.
  - P3 (Standards) — `SOURCES.md` não citava a capacidade nova. Corrigido:
    nova linha na tabela e no parágrafo de abertura, seguindo o padrão já
    usado para os tickets 04/05.
  - P3 (Standards) — "segue pela seção 3" podia ser lido como pular a
    refutação da seção 1 num id que reproduziu de novo. Corrigido: a
    seção 6 agora deixa explícito que passa pela seção 1 primeiro.
  - Não corrigidos (julgamento, registrados aqui): P3 (Standards) sobre
    as duas seções "6" (uma em cada arquivo) citadas lado a lado — reduzir
    exigiria renumerar seções que tickets anteriores já fixaram por
    referência cruzada; o link markdown explícito antes de cada menção já
    desambigua qual arquivo. P3 (Spec) sobre o formato de evidência ainda
    não ter um exemplo concreto para mass assignment/SQLi — a seção 6 já
    generaliza o texto; um exemplo por classe fica para quando essas
    classes fecharem um achado de verdade.
- `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` passou
  depois de cada rodada de edição (implementação e correção de P2/P3).
- `decision_needed`: null.
