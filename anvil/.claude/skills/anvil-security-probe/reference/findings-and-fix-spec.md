# Achado, causa raiz e spec `fix`

Usado depois de cada teste de
[test-execution.md](test-execution.md). As seções 1–5 entram depois de um
resultado **positivo** (um bypass aparente); a seção 6 entra depois de
**qualquer** resultado — positivo ou negativo — de um item citado nos
**Itens do mapa** de um `SEC-#` que `findings.md` já tem, porque fechar ou
manter um achado depende tanto da ausência de bypass quanto de um bypass
novo. Nada aqui roda antes de um teste real ter acontecido — esta seção
decide o que fazer com o resultado, não gera um resultado por conta
própria.

## 1. Tentativa de refutação, antes de registrar

Uma resposta que parece um bypass ainda não é achado. Antes de gravar
qualquer coisa, tente derrubar o próprio resultado:

- **Repita a requisição** — um resultado que só aparece uma vez pode ser
  race condition do ambiente de teste (dado ainda não commitado, cache),
  não o bypass em si.
- **Rode o comparativo** — a mesma operação pelo caminho que aplica o
  access control (rota gerada equivalente, `overrideAccess: false`, a
  identidade dona do documento). Se o comparativo se comporta **igual** ao
  caminho suspeito, o teste é refutado: a collection já é aberta por
  design, ou o campo já é editável por qualquer um de propósito — não é
  achado, e nada é gravado.
- **Confira o código** — o arquivo:linha que `map.md` aponta precisa
  explicar o comportamento observado. Resposta que bate mas código que não
  sustenta a explicação (ex.: a linha já tem `overrideAccess: false`, e o
  bypass veio de outra causa) volta para investigação, não vira achado
  ainda.

Só o que sobrevive às três tentativas acima — requisição, resposta e
trecho de código, coerentes entre si — vira achado.

## 2. Agrupar por causa raiz

Causa raiz é o mecanismo, não a rota: "Local API chamada com `user` sem
`overrideAccess: false`" é uma causa raiz só, esteja ela em uma rota ou em
vinte. Duas ocorrências têm a mesma causa raiz quando:

- o padrão de código é o mesmo (mesma chamada, mesmo parâmetro faltando ou
  mal usado), **e**
- o mecanismo de exploração é o mesmo (o que o atacante faz para acionar o
  bypass é idêntico, mudando só o alvo — outra collection, outro campo,
  outra rota).

Ocorrências que só coincidem na categoria OWASP (duas linhas A01 — Broken
Access Control — por motivos diferentes: uma por Local API, outra por
multi-tenant sem `useTenantAccess`) **não** compartilham causa raiz — são
achados diferentes, `SEC-#` diferentes. Um achado cita todos os ids de
`map.md` que a mesma causa raiz cobre (`Itens do mapa`, lista, não um id
só).

## 3. Deduplicar contra `findings.md`

Antes de abrir qualquer coisa nova, leia `docs/security/findings.md`
inteiro. Para cada `SEC-#`, `Status: aberto` ou `Status: corrigido`,
compare a causa raiz nova com a descrita ali (pelo critério da seção 2,
não pelo texto literal — reformular a mesma causa com outras palavras
ainda é a mesma causa):

- **Já existe, aberta** → não crie `SEC-#` novo, não abra spec nova. Anexe
  a evidência nova (seção 4) ao `SEC-#` existente, acrescente qualquer id
  de `map.md` que a rodada atual tenha achado e que a lista ainda não
  tinha, e pare aqui.
- **Já existe, corrigida** → o mesmo mecanismo de bypass reproduziu de
  novo depois de marcado `corrigido`: é regressão, não achado novo. Reabra
  no mesmo `SEC-#` — mude `Status:` de volta para `aberto`, anexe a
  evidência nova (seção 4) com uma nota explícita de reabertura ("reaberto
  — reproduziu de novo depois de `corrigido`"), e acrescente qualquer id
  de `map.md` que a rodada atual tenha achado e a lista ainda não tinha.
  Não abra `SEC-#` novo nem segunda spec — o campo **Spec** continua
  apontando para a mesma spec já aberta (mesma regra de deduplicação
  acima). Não edite a spec nem o ticket de correção: aplicar ou desfazer
  a correção é o fluxo normal de tickets, fora do escopo desta skill
  (seção 5) — a evidência da regressão em `findings.md` é o sinal para
  quem cuida daquele ticket reabri-lo pela convenção que o perfil do
  tracker já usa para regressão (no anvil,
  `docs/agents/issue-tracker.md`: um P1 de revisão muda `Status:` de
  `resolved` para `claimed`; a mesma mecânica se aplica aqui, à mão, fora
  desta skill).
- **Não existe nenhum `SEC-#` para essa causa** → é achado novo: primeiro
  `SEC-#` livre (maior número usado no arquivo, mais um; `findings.md`
  ausente ou vazio começa em `SEC-1`), seção 4 e depois seção 5.

## 4. Escrever em `findings.md`

Um achado é uma seção `## SEC-<n>`, nesta forma:

```markdown
## SEC-1 — Local API chamada com `user` sem `overrideAccess: false`

- **Severidade:** high
- **Status:** aberto
- **Itens do mapa:** A01-01, A01-02
- **Spec:** docs/specs/003-fix-local-api-overrides-access/

### Evidência

- 2026-09-25 — `GET /api/posts-search` (sem sessão) → `200`, corpo inclui o
  documento `id:1` (`authorId: "owner-1"`), que o caminho equivalente com
  `overrideAccess: false` (`GET /api/posts`, rota gerada) recusa com `403`
  no mesmo estado do banco. Código: `src/app/api/posts-search/route.ts:13-17`.
- 2026-09-25 — mesma causa, segunda ocorrência: `GET /api/posts-recent`
  (sem sessão) → `200`, mesmo documento. Código:
  `src/app/api/posts-recent/route.ts:13-17`.
```

- **Severidade** — `low`/`medium`/`high`, a mesma escala do `GATE.md` do
  `anvil-bench` (o critério de impacto abaixo é desta skill, o `GATE.md`
  não o define): julgue pelo impacto de quem explora sem nenhum acesso
  prévio — exposição/alteração de dado de outro usuário ou tenant tende a
  `high`; vazamento de campo interno sem dado sensível, `medium`; algo que
  exige uma condição rara para importar, `low`. Registre em uma frase por
  que, junto da severidade.
- **Status** — `aberto` para achado novo ou reaberto (seção 3, causa que
  voltou a reproduzir depois de `corrigido`). `corrigido` só é escrito
  pela seção 6 (retestar achados existentes), quando a causa para de
  reproduzir — nunca por um resultado positivo desta seção.
- **Itens do mapa** — todos os ids de `map.md` que a causa raiz cobre.
- **Spec** — o caminho da spec aberta na seção 5; se a seção 5 não
  conseguiu abrir spec (sem perfil de tracker), este campo diz isso em vez
  de um caminho.
- **Evidência** — uma linha (ou bloco) por ocorrência/rodada, sempre com
  data, requisição, resposta (o suficiente para reproduzir o comparativo,
  não o corpo inteiro se for grande) e `arquivo:linha`. Rodar o probe de
  novo com a causa ainda presente **acrescenta** um item aqui, no mesmo
  `SEC-#` — nunca reescreve os itens anteriores.

### Sem cobertura

Testes que um item de `map.md` descreve mas que não rodaram por falta de
ferramenta (ver `test-execution.md`) entram numa seção à parte, sempre
presente quando houver pelo menos uma lacuna:

```markdown
## Sem cobertura

| item do mapa | teste do probe | ferramenta ausente |
|---|---|---|
| A05-01 | confirmação com ferramenta de SQL injection sobre o parâmetro `q` | sqlmap |
```

Isto não é achado — é a diferença entre "testado e passou" e "não
testado", que a `user story` 33 da spec pede para não confundir.

Item sem cobertura que também aparece nos **Itens do mapa** de um `SEC-#`
existente não decide nada sobre o `Status:` dele — ver seção 6.

## 5. Abrir a spec `fix`, pelo perfil do tracker do projeto

Só depois de a seção 3 confirmar achado novo (a causa não tinha `SEC-#`
nenhum). Uma spec por causa raiz — nunca uma por rota/ocorrência.

1. **Ache o perfil do tracker do projeto** — normalmente
   `docs/agents/issue-tracker.md`, o arquivo que `anvil-setup` grava e que
   toda skill de fluxo do anvil lê antes de publicar. Ausente → não invente
   um tracker: diga ao usuário que a reprodução está em `findings.md` (a
   seção 4 já rodou) mas a spec de correção precisa ser aberta à mão,
   porque não há perfil de tracker para seguir; deixe o campo `Spec` do
   achado dizendo isso.
2. **Siga a convenção que o perfil descreve para "publish to the issue
   tracker".** No perfil do anvil isso é rodar `bash
   .claude/skills/anvil-to-spec/scripts/new-spec.sh --json` — o probe
   acrescenta `--type fix --short-name <slug-da-causa-raiz>
   "<descrição curta>"` por conta própria (são flags do script, não parte
   da instrução do perfil), a partir da raiz do projeto (o script resolve
   sozinho via `git rev-parse --show-toplevel`). A saída JSON dá
   `spec_dir`, `spec_file` e `issues_dir` — use os caminhos que ela
   devolve, nunca um caminho calculado à mão, porque o número pode ter
   mudado por corrida com outra reserva. Perfil diferente (GitHub, GitLab,
   markdown local — os que `anvil-setup` também instala) descreve outra
   convenção; siga a dele, não a do anvil.
3. **Registre a evidência da causa raiz**, no formato que a convenção do
   perfil usa para o corpo de uma spec/ticket novo — sem inventar seção
   fora do que o perfil já define:
   - *Problema*: a causa raiz em prosa, mais a requisição e a resposta
     verbatim da primeira ocorrência (o par comparativo da seção 1, não só
     o lado que falha).
   - *Código*: o trecho de cada ocorrência (`arquivo:linha`), citando que
     veio da reprodução do probe.
   - *Critério de correção*: a correção precisa fazer a requisição
     registrada em `findings.md` voltar a recusar (mesmo status do
     caminho comparativo) — não um teste novo desconectado da reprodução.
   - *Fora do escopo*: qualquer causa raiz vizinha que não seja esta
     (outro `SEC-#`).

   No perfil do anvil, isso é o `spec_file` (`spec.md`) pelo template
   padrão do `anvil-to-spec` — *Problem Statement* e *Implementation
   Decisions* levam a evidência acima (o próprio template abre exceção
   para snippet que "encodes a decision more precisely than prose" quando
   a origem é citada), *Testing Decisions* leva o critério de correção,
   *Out of Scope* a causa vizinha, *Further Notes* o `SEC-#`. Num perfil
   GitHub/GitLab, é o corpo da issue/MR que a convenção do perfil cria
   (`gh issue create --body "..."` ou equivalente); num perfil de
   markdown local, é o `spec.md` do mesmo jeito, porque a convenção local
   já espelha o formato do anvil.
4. **Escreva um primeiro ticket** com a correção em si (ex.: adicionar
   `overrideAccess: false` em cada ocorrência citada) e a checagem de
   regressão pela requisição registrada — no perfil do anvil,
   `issues_dir/01-<slug>.md` (`Blocked by:`, `Status: ready-for-agent`,
   lista de critérios `- [ ]`); noutro perfil, o que a convenção dele
   chamar de ticket/issue de trabalho.
5. **Grave a referência da spec/ticket** no campo `Spec` do achado, em
   `findings.md` (seção 4) — o caminho (`spec_dir`, no perfil do anvil) ou
   a URL que a convenção do perfil devolver.

Nenhum destes passos aplica a correção — o probe abre a spec, corrigir é o
fluxo normal de tickets (fora de escopo desta skill).

## 6. Retestar achados existentes a cada rodada

Fora de qualquer resultado positivo novo: toda vez que o probe roda, os
itens de `map.md` citados nos **Itens do mapa** de um `SEC-#` já
registrado (`aberto` ou `corrigido`) rodam de novo pela execução normal da
seção 6 do `SKILL.md`/`test-execution.md` — não é um teste diferente, é o
mesmo teste de sempre, cujo resultado desta vez decide o `Status:`.

Antes de rodar qualquer teste da rodada, leia `findings.md` inteiro e
separe, por `SEC-#`, a lista de ids de **Itens do mapa** que ele cobre.
Depois que a rodada de testes terminar, cruze o resultado de cada id
contra essa lista:

- **Pelo menos um id do `SEC-#` reproduziu nesta rodada** → segue pela
  seção 3 (`aberto` ganha evidência nova; `corrigido` reabre no mesmo id).
  Um único id ainda positivo mantém `aberto` a causa inteira, mesmo que os
  outros ids do mesmo achado já tenham testado limpo.
- **Nenhum id reproduziu, e todos os ids do `SEC-#` rodaram nesta
  rodada** (o caminho suspeito agora se comporta como o comparativo com
  access control — mesma recusa, mesmo dado) → **fecha**: `SEC-#`
  `aberto` vira `Status: corrigido`. Acrescente uma entrada de evidência
  (seção 4) com data, a requisição que antes reproduzia e a resposta
  recusando agora, e o `arquivo:linha` que passou a sustentar a recusa
  (ex.: a linha ganhou `overrideAccess: false`) — o mesmo par comparativo
  da tentativa de refutação (seção 1), do lado que agora recusa. `SEC-#`
  que já estava `corrigido` permanece `corrigido`, sem entrada nova: nada
  mudou para registrar.
- **Nenhum id reproduziu, mas nem todos os ids do `SEC-#` rodaram nesta
  rodada** (lacuna de cobertura — ferramenta ausente, rota que o servidor
  não expôs nesta rodada) → não decida nada para esse `SEC-#`: sem teste,
  não há resultado, positivo ou negativo, para basear a transição. O
  `Status:` fica exatamente como estava (`aberto` continua `aberto`,
  `corrigido` continua `corrigido`), mesmo que os ids testados nesta
  rodada tenham dado limpo. A lacuna em si entra na seção "Sem cobertura"
  do jeito de sempre — isso não é, sozinho, sinal de correção nem de
  regressão.
