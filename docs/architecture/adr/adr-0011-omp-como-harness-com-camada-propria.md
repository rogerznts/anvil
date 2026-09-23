# ADR-0011 — O omp é harness de primeira classe, com camada própria

- Status: aceito
- Data: 2026-09-23
- Revê em parte o [ADR-0008](./adr-0008-equipe-sai-do-toolkit.md), só na camada omp

## Contexto

O omp já roda o anvil sem configuração: lê `.claude/skills` do projeto e o
`CLAUDE.md` da raiz, e o modelo resolve "Call the Skill tool" como
`read skill://<nome>`. Três coisas não atravessam:

- **A guarda de merge.** O omp não executa os hooks `PreToolUse` do
  `.claude/settings.json`. Quem trabalha pelo omp perde a trava de `ship-ready` sem
  aviso.
- **Agentes.** O omp ignora `.claude/agents` de propósito; o contrato dele mora em
  `.omp/agents`.
- **Rules.** `.claude/rules/*.md` não é caminho de discovery do omp. Chega ao
  modelo só porque o `CLAUDE.md` manda ler.

O Codex também está em uso e lê as skills de repositório de `.agents/skills`. O
payload traz esse espelho pronto, mas nenhum script o mantém: o `reset-install.sh`
só mexe em `.claude/`, e na raiz deste repositório sobra um `anvil-team` pendurado
desde o ADR-0008.

O ADR-0008 tirou a equipe do payload porque ela dependia do *agent teams*,
experimental, e de um aninhamento de subagentes medido, não documentado. O custo
registrado foi perder o gate que o autor não controla. O `task` do omp é
documentado, abre filho sem a conversa do pai e comporta supervisor → implementer
→ reviewers dentro do limite padrão de recursão (`task.maxRecursionDepth: 2`).

## Decisão

**O omp entra como harness de primeira classe; o Claude Code continua a
referência.** O núcleo — skills, `docs/`, perfis de tracker e de verificação — é o
mesmo para todos os harnesses. O que só o omp lê é uma **camada de harness**:

- viaja no payload como material dentro da `anvil-update`, não como skill;
- é instalada em `.omp/` pelo `/anvil-boot` e pelo `reset-install.sh` quando o omp
  é detectado — `command -v omp`, `~/.omp/` ou linha `omp:` no lock;
- é **pegajosa**: ausência do binário na máquina que roda o update nunca a remove.
  O lock ganha uma linha `omp: <caminho relativo a .omp/>` por arquivo, e os órfãos
  saem dela como saem das skills.

A camada traz a guarda (`.omp/hooks/pre/*.ts` chamando o mesmo
`guard-spec-merge.sh`), uma rule `alwaysApply` só com o mapeamento de vocabulário,
o agente `anvil-implementer` e três skills em `.omp/skills/`, todas com trava de
invocação: `anvil-plan`, `anvil-run` e `anvil-omp`, o manual de uso. No omp elas se
chamam por `/skill:<nome>`.

**A automação só existe no omp.** No Claude Code e no Codex o fluxo continua
manual, como hoje, e a lista de skills que eles veem não muda.

- **Planejamento.** A `anvil-plan` conduz `grill → to-spec → to-tickets` na mesma
  janela. Entre uma etapa e outra, sugere a próxima ou um desvio — research,
  prototype, to-questionnaire, wayfinder, ui, architect — e só carrega com o sim do
  usuário. A etapa sai da conversa e do disco, sem campo de estado.
- **Implementação.** A `anvil-run` faz da sessão principal o supervisor: deriva o
  frontier do disco, despacha um `anvil-implementer` por ticket, **em série**, e
  relê o disco. O implementer segue o `anvil-implement` vendorizado sem mudança, e
  é o `anvil-code-review` que abre os dois eixos em subagentes. Ticket com
  `Review: round=2 … verdict=fail` fica travado, o supervisor segue com o que não
  depende dele, e a terceira rodada é do humano, como manda o
  [ADR-0010](./adr-0010-verificacao-tem-criterio-de-parada.md). A execução para em
  "todos resolvidos": browser QA, archive e PR continuam com o usuário.

**O espelho `.agents/skills` fica, e passa a ser gerado.** O payload deixa de
trazê-lo pronto; o `reset-install.sh` cria um symlink
`.agents/skills/<nome>` → `../../.claude/skills/<nome>` por linha `skill:` do lock e
remove os órfãos junto. O omp também lê `.agents/skills`, mas deduplica por caminho
real.

## Alternativas descartadas

- **Payload traz `.omp/` na raiz, sempre.** Mais simples e reprodutível, mas põe
  arquivo inerte em todo projeto que não usa omp. A regra pegajosa dá a
  reprodutibilidade sem isso.
- **Detecção pela presença do binário, sem memória.** Dois devs no mesmo
  repositório fariam a camada aparecer e sumir a cada update.
- **Remover o espelho `.agents/skills`.** O omp não precisa dele, mas o Codex lê as
  skills de lá: o anvil sumiria do Codex.
- **Automação no núcleo, para todos os harnesses.** Mudaria o fluxo de quem usa
  Claude Code ou Codex. A condução depende do `task` e dos agentes do omp na
  implementação, e no planejamento fica junto dela por decisão: um harness
  automatiza, os outros seguem manuais.
- **Frontier em paralelo com worktree isolado.** Tickets *tracer bullet* se cruzam
  nos arquivos, `Status:` e `Review:` voltariam de workspaces diferentes, e o
  merge por patch falha quando o texto não aplica. Fica para ser medido depois do
  modo em série.
- **Supervisor dono do review.** Tiraria o gate do autor, mas contradiz um passo
  de skill vendorizada. Os dois eixos já rodam em sessões que não viram a
  implementação e são agregados verbatim.
- **Skill-adaptador de vocabulário (`anvil-flow-plan`, `anvil-flow-run`).** O
  vocabulário do Claude Code já se resolve no omp; uma rule curta basta. Os
  condutores existem, mas como `anvil-plan` e `anvil-run`, sem traduzir skill
  nenhuma.
- **Extensão TypeScript com `registerCommand` para `/anvil-plan` e `/anvil-run`.**
  O omp já transforma toda skill em `/skill:<nome>`. O único TypeScript da camada é
  a guarda, que precisa bloquear uma chamada de ferramenta.

## Consequências

**A favor.** A guarda volta a valer no omp. O gate independente que o ADR-0008
perdeu reaparece onde o harness o sustenta, sem tocar skill vendorizada. Claude
Code e Codex não veem nada novo, e o Codex passa a receber um espelho mantido.

**Contra.** O anvil passa a manter dois caminhos de hook, e o do omp depende de uma
API de extensão que muda com o omp. `git merge` disparado pelo `eval` escapa da
guarda, como hoje escapa do hook do Claude o que não passa pelo Bash; o Codex segue
sem guarda. Nenhum harness garante que a instrução de conduzir da `anvil-plan`
continue viva numa conversa longa — chamá-la de novo recupera o ponto. As listas
`runners`, `how-critics` e `cross-judge` do `.claude/rules/anvil.md` não têm efeito
no omp: o `task` não aceita modelo por chamada.
