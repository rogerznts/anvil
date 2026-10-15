# Handoff — specs 007 (migração) e 008 (piloto automático)

Repositório: `/Users/admin/Projects/anvil`. Idioma de comunicação: pt-BR.

## Onde está

- Grill feito nesta sessão sobre dois trabalhos; o usuário confirmou o entendimento
  comum. Saem **duas specs**, nesta ordem.
- `main` @ `e6875f4`: ADR-0014 (`docs/architecture/adr/adr-0014-piloto-automatico-fecha-sem-humano.md`),
  cabeçalhos dos ADR-0010 e ADR-0011 apontando para ele, verbetes **Piloto
  automático** e **Roteiro** em `docs/architecture/context.md`.
- Branch `extension/007-migration-out-of-git` @ `b636d56`: spec 007 publicada em
  `docs/specs/007-extension-migration-out-of-git/spec.md`, sem tickets. Tudo o que
  a 007 precisa está na spec; nada da 007 depende desta conversa.
- A spec 008 **não existe ainda**. Ela nasce de um branch novo saído da `main`
  depois que a 007 fechar (archive + merge local, regra do projeto). As decisões
  dela que não estão no ADR-0014 estão abaixo — são a única cópia.

## Próximos passos

1. 007: `anvil-to-tickets` no branch atual → implementação (`anvil-implement` ou
   `/skill:anvil-run 007` no omp) → `anvil-docs archive` → `git merge` local na
   `main`. Verificação: cenário `workspace/41-legacy-migration/s1.sh` e
   `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`.
2. 008: da `main`, `anvil-to-spec` sintetizando o ADR-0014, o
   `docs/discovery/bench-autonomo.md` e a seção abaixo. Não refaça o grill; os
   seams o to-spec confere com o usuário.

## Decisões da 008 que só estavam na conversa

Numeração das perguntas do grill (Q5–Q29). O discovery tem 8 perguntas; as
respostas estão mapeadas entre parênteses.

**Forma e alcance**
- Q5 (disc. 1): "dá pass" = autoaprovar as pausas **e** fechar só com `PASS`.
- Q6 (disc. 2): vale para **qualquer projeto do anvil**, não só o bench.
- Q7 (disc. 4a): forma B — skill nova na camada omp; `anvil-plan` e `anvil-run`
  não mudam.
- Q11: termo Piloto automático, skill `anvil-auto`, com trava de invocação
  (`disable-model-invocation: true`), uma execução por vez. O verbete Condutor não
  muda.
- Q16 (disc. 4b): no Claude Code sem omp, o bench para no fim da construção como
  hoje; o relatório diz que o fechamento ficou com o operador e lista archive e
  merge. Sem recusa.

**Entrada**
- Q12: projeto comum → `anvil-grill` humano até o entendimento confirmado; bench →
  a entrevista dele. Daí em diante, sem pausa.
- Q9 (disc. 7): anexo da pessoa (PDF, planilha) é copiado, ou tem o texto
  extraído, para `docs/discovery/` antes de ser usado.
- Q19: o grill cobre o **plano inteiro** (specs, ordem, escopo, critério de
  pronto); sem grill entre specs.
- Q23: no fim do grill o piloto escreve o roteiro e o mostra; a confirmação do
  entendimento é sobre o roteiro escrito — único sim. Commit do roteiro na `main`,
  antes do branch da primeira spec.
- Q27: no bench, a pessoa vê o roteiro em português simples (o que, em que ordem,
  como saberá que cada parte está pronta) e confirma sobre ele; o `roadmap.md`
  técnico fica gravado ao lado, fora da conversa (INV-6). Fora do bench, o operador
  vê o `roadmap.md`.

**Roteiro**
- Q20/Q21: arquivo `docs/specs/roadmap.md` (em `specs/`, não em `project/`, que é
  escrito à mão). Nada existente servia: `docs/index.md` é gerado, `map.md` do
  wayfinder é de uma spec só, `plan.md` é prosa.
- Q21: o verbo `index` do `anvil-docs` ganha uma seção do roteiro em `docs/index.md`,
  acima das specs ativas, com o estado derivado de cada entrada.
- Q22: entrada = tipo, nome, escopo (entra / fica de fora), critério de pronto,
  `Depende de:`, e `Spec: NNN` depois que a spec nasce. Estado **não gravado**,
  derivado do disco por script (como o `stage.sh`): pendente (sem `Spec:`), em
  andamento (pasta aberta), fechada (pasta em `archive/`), parada (spec aberta sem
  ticket por fazer e a última execução não fechou).
- Q24: um roteiro ativo por projeto; o grill novo edita o mesmo roteiro; roteiro
  novo com outro inacabado é recusado até a pessoa abandonar as entradas no grill.
  Histórico no git.
- Q25: o piloto nunca edita escopo nem critério de pronto de uma entrada. Se o
  critério ainda é cumprível, adapta dentro da spec e registra "decidido sem
  humano"; se não, para antes dessa spec e põe a contradição em "o que ainda
  espera decisão".
- Q28: frontier de specs — segue com as entradas que não dependem (nem
  transitivamente) da spec parada, cada uma em branch novo da `main`; termina
  quando não sobra entrada desbloqueada.

**Execução e fechamento**
- Q17: árvore suja na largada → recusa antes de escrever. Spec aberta no branch
  atual → retomada pelo `stage.sh`/`frontier.sh`. Na `main` sem spec → branch pelo
  `new-spec.sh` depois do entendimento confirmado.
- Q13: `PASS` fora do bench = todos os tickets `resolved` com última `Review:`
  `verdict=pass; p1=none` + o "Comando de verificação" de `.claude/rules/anvil.md`
  rodado pelo supervisor saindo `0`. Sem comando declarado → recusa na largada.
- Q14 (disc. 3): fechamento segue a regra do projeto (perfil do tracker + rules);
  quando passa por PR, abre o PR e para, sem merge. Sem PR → merge local depois do
  archive. A guarda vale sempre.
- Q15 (disc. 5): gate manual do bench segura o fechamento da spec; vai para o
  relatório com a pergunta formulada.
- Q29: pesquisa antes de travar — está no ADR-0014 (uma rodada a mais por
  evidência nova; sinais de laço bloqueiam; parada por decisão não pesquisa;
  achado em `docs/specs/{id}/discovery/`).

**Bench**
- Q8 (disc. 6): teto do `anvil-bench/GATE.md` passa de três tentativas para as duas
  rodadas do ADR-0010, também no bench manual; ticket travado → `CONCERNS` e
  pendência no relatório.
- Q10 (disc. 8): construção começada fora do bench (sem `checklist.yaml`/`gates.md`)
  → refaz só a fase 4 a partir da spec e dos tickets existentes; sem spec, fase 3
  como entrevista do delta. Registrar no relatório.
- Q26: a entrevista gera o roteiro com N entradas. `briefing.md` →
  `docs/discovery/briefing.md`; `checklist.yaml` → `docs/qa/checklist.yaml` (da
  ferramenta, não da spec). Cada entrada do roteiro diz quais itens do checklist
  cobre; cada spec tem seu `gates.md` (formato do `unlazy`, vendorizado, não muda)
  só com esses itens. `PASS` da spec k = `gate-check.mjs --reverify` do `gates.md`
  dela **e** de cada spec já fechada do roteiro. Gate manual pertence à entrada que
  cobre o item.
- O `anvil-bench` hoje grava `briefing.md`, `checklist.yaml` e `gates.md` dentro
  da spec (`SKILL.md` fase 4) e não fala de branch, merge nem archive.

**Relatório**
- Q18: `docs/specs/{id}/report.md`, escrito à medida que avança: cada pausa
  autoaprovada com a resposta; tickets com `Status` e linhas `Review`; P2/P3 que
  ficaram; travados em `round=2`; saída do comando de verificação; pesquisas
  feitas. Termina em "o que ainda espera decisão", com cada item como pergunta —
  pauta da oferta de grill novo. Relatório único cobre a corrente inteira e diz
  onde ela parou. No bench, também puxa o `decisions-log.md` e ganha a versão em
  português simples no chat (INV-6).

## Atenções

- Este repositório é a fonte do payload; skills em `~/.claude/skills` são symlinks
  para `anvil/.claude/skills`. Nunca rode `/anvil-update` aqui.
- A camada omp mora em `anvil/.claude/skills/anvil-update/.omp-layer/`; o
  `anvil-auto` entra lá, ao lado de `anvil-plan` e `anvil-run`.
- `anvil-bench/unlazy/` é vendorizado: segue a regra de skill vendorizada.

## Suggested skills

- `anvil-to-tickets` — fatiar a spec 007 agora.
- `anvil-implement` (ou `/skill:anvil-run 007` no omp), com `anvil-tdd` e
  `anvil-code-review` — implementar a 007.
- `anvil-docs` (verbo `archive`) — fechar a 007 antes do merge local.
- `anvil-to-spec` — abrir a 008 a partir deste documento e do ADR-0014.
- `anvil-codebase-design` / `anvil-architect` — se a forma do `anvil-auto` e do
  script do roteiro ficar em aberto no to-spec da 008.
