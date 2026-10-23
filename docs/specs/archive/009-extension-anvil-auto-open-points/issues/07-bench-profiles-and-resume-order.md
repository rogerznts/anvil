# 07: O bench nasce com os perfis e retoma a spec aberta antes de *Evoluir*

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=a64fe68be8d2fdff791ac9ca46f9e76e00bfb160; scope=full; verdict=pass; p1=none

**What to build:** o projeto novo do bench nasce com `docs/agents/issue-tracker.md`
e `docs/agents/verification.md`, os perfis que o bench e as skills de fluxo citam.
Reativado no meio de uma construção, o bench segue a spec aberta antes de
qualquer outro ramo da fase 2, e não cai em *Evoluir uma ferramenta* só porque a
retomada já commitou o `docs/qa/checklist.yaml`. Sem roteiro, *Uma entrada do
roteiro* constrói a spec aberta em vez de parar no `next: none`.

- [x] No passo de projeto novo da fase 2, o bench instala os dois perfis a partir
      dos templates do `anvil-docs`, com a regra do `scaffold`: ausente, copia;
      idêntico, segue; divergente, não sobrescreve. Sob o piloto, entram no commit
      do piloto depois do sim; chamado direto, no primeiro commit.
- [x] Antes dos ramos de hoje, a fase 2 procura uma spec aberta, fora de
      `docs/specs/archive/`, com ticket não `resolved`. Achou, a construção segue
      por ela: a fase 4, se falta o `gates.md`; senão, a fase 5 pelos tickets não
      `resolved`. *Evoluir uma ferramenta* só vale sem essa spec.
- [x] No passo 1 de *Uma entrada do roteiro*, com `roadmap: none` e uma spec
      aberta, a entrada é essa spec. O `next: none` só segura a construção quando
      há roteiro.
- [x] Prova B1, num diretório novo de `workspace/`: um turno headless do
      `/anvil-bench` sobre projetos de fixture, sem subir o app. Projeto novo: o
      primeiro commit traz os dois perfis, iguais aos templates. Projeto com spec
      aberta, tickets não `resolved` e `docs/qa/checklist.yaml` no branch, sem
      roteiro: o bench segue a retomada, e não *Evoluir*. Ferramenta sem spec
      aberta, com mudança pedida: o bench segue *Evoluir*. A prova registra o
      modelo que de fato respondeu.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Fase 2 do `anvil-bench`: o "Projeto novo" instala `docs/agents/issue-tracker.md` e `docs/agents/verification.md` de `~/.claude/skills/anvil-docs/templates/`, com a regra do `scaffold` — ausente, copia; idêntico, segue; divergente, não sobrescreve e não pergunta, porque no bench não há pergunta técnica. Entram no primeiro commit; sob o piloto, a seção "Sob o piloto automático" do bench e o "Com o sim" do `anvil-auto` os listam no commit do piloto. Sob o piloto o perfil do tracker já existe, porque a largada (`stage.sh`) o exige, e a regra dá "idêntico, segue".
- O "Reconhecer" ganhou, antes dos ramos, a busca da spec aberta com ticket não `resolved`: sem `gates.md`, a fase 4 (o ledger e, sem checklist, o briefing e o checklist da retomada de fora do bench); com ele, a fase 5. Os três ramos de hoje ficam como estão, sob "Sem essa spec". O ramo da construção começada fora do bench com spec aberta continua lá para a spec sem ticket por resolver, como uma spec ainda sem tickets. O ponto de entrada da retomada que vai para o `decisions-log.md` passou a incluir a fase 5.
- O passo 1 de *Uma entrada do roteiro*: com `roadmap: none`, o `next: none` não segura; a entrada é a spec aberta da fase 2, do ponto que o disco indica, como na linha `state=open`. Só com roteiro o `next: none` diz que não há entrada.
- Prova B1: `workspace/58-bench-profiles/b1.sh`, um turno de `omp -p --mode json --model claude-sonnet-4-5 --thinking off` por caso, com o `/skill:anvil-bench` chamado direto, sobre projetos em `/tmp/anvil-58-bench-profiles/<out>/`. Um `docker` à frente no `PATH` recusa o `docker run` e o `docker compose` que sobe, roda ou entra num serviço, menos o da infra compartilhada (`-f …/.anvil-infra/docker-compose.yml`); a conferência confere também que nenhum container do projeto existe ao fim. A vez é cortada quando a sessão carrega uma skill de construção ou escreve em `src/collections/`. O modelo que respondeu é lido do jsonl. A rodada vermelha liga o `anvil-bench` do `HEAD` de antes do ticket, exportado com `git archive`.
  - N, projeto novo: vermelho (`out-red/N`, `b1-red.out`), o primeiro commit sem os dois perfis; verde (`out/N`, `b1.out`), o primeiro commit único, com o starter, a rule da stack e os dois perfis byte a byte iguais aos templates. Respondeu `anthropic/claude-sonnet-4-5`.
  - R, spec aberta com o ticket 02 não `resolved`, o `gates.md` e o `docs/qa/checklist.yaml` no branch, sem roteiro, sem pedido: verde (`out/R`), o bench vai à fase 5 pelo ticket 02 e carrega o `anvil-implement`, sem entrevista, sem roteiro escrito e sem `new-spec.sh`, no branch da spec. Respondeu `anthropic/claude-sonnet-4-5`. O vermelho só reproduziu em parte: em três vezes com o texto de antes e o `claude-sonnet-4-5`, o modelo nunca caiu em *Evoluir* nessa fixture; na última (`out-red/R`), escreveu um `docs/specs/roadmap.md` próprio para sair do `next: none` antes de construir, o que o terceiro critério deste ticket tira. Uma tentativa com o `claude-haiku-4-5` sobre o texto de antes também retomou, e foi descartada porque passou pelo `docker` falso com `-f docker-compose.yml`, o que levou ao endurecimento acima.
  - E, ferramenta construída pelo bench, a 001 arquivada na `main`, sem spec aberta, com a manutenção pedida: verde (`out/E`), a vez termina na primeira pergunta da entrevista do delta, sobre a manutenção, sem construir e sem branch novo. Respondeu `anthropic/claude-sonnet-4-5`. Nessa vez o modelo não carregou o `anvil-grilling` (em uma das três vezes verdes, carregou); a pergunta saiu sem ele, o que é aderência da fase 3, fora deste ticket.
  - `B1: tudo passou (claude-sonnet-4-5, N R E)`. A alocação de infra das fixtures é real e idempotente: o `registry.yaml` da máquina ganhou `anvil58_r` e `anvil58_e`, e a tentativa descartada do haiku registrou `r`.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0.
- Review round=1 · P2 (Spec): o vermelho de R não caiu em *Evoluir* com esta fixture e este modelo, e a busca da spec aberta antes dos ramos só tem prova verde — se alguém tirar essa busca, o B1 não garante reprovar.
- Review round=1 · P2 (Spec): o verde de R não rodou o `roadmap.sh`; foi da fase 2 direto ao `anvil-implement`, e o passo 1 novo de *Uma entrada do roteiro* com `roadmap: none` não foi percorrido — não há prova positiva do texto alterado, só o sintoma antigo no vermelho (o roteiro escrito pelo modelo).
- Review round=1 · P3 (Standards, Spec): o bench diz "É a regra do `scaffold` do `anvil-docs`: … divergente, não sobrescreva e não pergunte", e o passo 4 do `scaffold` manda mostrar o diff e esperar aprovação, e o passo 3 escreve o perfil do tracker pelo `anvil-setup` — quem conferir a citação acha o contrário; o comportamento prescrito no bench está explícito e certo para quem não programa.
- Review round=1 · P3 (Standards): possível Duplicated Code — a escolha "sem `gates.md`, fase 4; senão, tickets não `resolved`" está na fase 2 e no passo 1 de *Uma entrada do roteiro*, e as duas já diferem no caso "falta a spec" — uma mudança no ponto de retomada precisa ser feita duas vezes.
- Review round=1 · P3 (Standards): possível Shotgun Surgery — a lista do que entra no commit do piloto está na seção "Sob o piloto automático" do bench, no "Projeto novo" e no "Com o sim" do `anvil-auto`; com o `git add -A` nada muda de comportamento, mas as listas podem divergir em silêncio.
- Review round=1 · P3 (Standards): "spec aberta" ganhou na fase 2 o sentido de spec com ticket não `resolved`, e o ramo "Construção começada fora do bench … com uma spec aberta", sob "Sem essa spec", segue com o termo e com "os tickets ainda não `resolved`" — o sentido que vale ali, spec sem ticket por resolver, só está neste `## Comments`.
- Review round=1 · P3 (Spec): sob o piloto, o perfil do tracker já está commitado na largada, porque o `stage.sh` o exige e a árvore está limpa; "os perfis entram no commit do piloto" só vale para o `verification.md`, e a skill não diz isso.
- Review round=1 · P3 (Spec): o B1 manda um prompt em texto ("The operator invoked /skill:anvil-bench … Read skill://anvil-bench"), como o prior art do S2, e não o comando de barra; e não cobre a retomada sem `gates.md` com o checklist presente, o caminho da fase 4.
