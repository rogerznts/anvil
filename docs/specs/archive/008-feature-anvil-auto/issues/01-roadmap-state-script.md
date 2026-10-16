# 01: `roadmap.sh` deriva o estado do roteiro e o frontier do disco

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=5dc530a; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=857800b; scope=diff:5dc530a..857800b; verdict=pass; p1=none

**What to build:** o operador, e mais tarde o piloto e o verbo `index`, roda o
script de estado do roteiro na raiz de um projeto. O script lê
`docs/specs/roadmap.md` e devolve, em linhas `chave: valor` como o `stage.sh` e o
`frontier.sh`, o estado derivado de cada entrada, o frontier do roteiro e o
`next`. Ele recusa roteiro que não pode terminar e não escreve nada. O formato do
roteiro e a derivação estão na spec, em "Formato do roteiro" e "`roadmap.sh`:
estado derivado e frontier". O script mora no núcleo, dentro de `anvil-docs`, e é
chamado pela instalação de usuário.

O formato do roteiro fica documentado onde o perfil `docs/specs` é descrito: no
template do perfil do tracker que o `anvil-setup` escreve, na cópia deste
repositório e no `README` de `docs/specs/`. Esses três lugares registram que
`roadmap.md` e `report.md` moram em `docs/specs/`, fora das pastas de spec.

- [x] Sem `roadmap.md`, a saída é `roadmap: none` e `next: none`.
- [x] Cada entrada sai numa linha `entry:`, na ordem do arquivo, com `state`
      (`pending`, `open`, `closed` ou `stopped`), `spec`, `depends` e `reason`.
- [x] `closed` exige a pasta `docs/specs/archive/{NNN}-*` no checkout atual.
- [x] Spec aberta só no branch local dela é lida pelo commit desse branch, sem
      trocar de checkout e sem mexer na árvore.
- [x] `stopped` cobre todos os casos da tabela da spec: todos `resolved` sem
      archive; não resolvidos travados (`round` 2 ou mais com `verdict=fail`) ou
      dependentes de travado; spec arquivada no branch e sem merge; e `Spec:` sem
      pasta nem branch. Cada caso sai com o seu `reason`.
- [x] `frontier:` traz as entradas `pending` com todas as dependências `closed`,
      na ordem do arquivo. A dependente transitiva de uma `stopped` nunca entra.
- [x] `--skip "a b"` tira essas entradas do frontier, e o `next` passa para a
      seguinte.
- [x] Nome repetido, `Depende de:` que aponta para nome inexistente, ciclo e
      `Tipo:` fora dos tipos do `new-spec.sh` saem com `refusal:` e o motivo, sem
      frontier.
- [x] As chaves são aceitas com ou sem negrito, como o `Status:` dos tickets.
- [x] O cenário S1, descrito em Testing Decisions da spec, roda num diretório
      novo de `workspace/` sobre repositórios de fixture e passa em todos os casos
      listados lá.
- [x] O template do perfil do tracker, a cópia deste repositório e o `README` de
      `docs/specs/` descrevem o `roadmap.md` (formato e quem escreve) e o
      `report.md`.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai `0`.

## Comments

- S1 em `workspace/43-roadmap-state/s1.sh`: todos os casos da spec passam, com o
  script rodado no bash 5 e no `/bin/bash` 3.2 do macOS, com saídas iguais.
- A spec diz que o nome da entrada é kebab-case, mas não põe o nome fora de
  kebab-case entre as recusas. O script segue a lista da spec e não recusa; um
  nome com espaço quebraria a linha `frontier:` e o `--skip`, que separam nomes
  por espaço. Fica para decisão do operador se vira recusa.
- Review round=1 · P1 (Standards): os laços usam `seq 1 "$count"`, e o `seq` do macOS devolve `1 0` para `seq 1 0`; com um `roadmap.md` sem nenhuma entrada, o script morre com `name[i]: unbound variable` e sai 1 — o piloto e o índice recebem erro do bash no lugar de `roadmap:`/`next:`.
- Review round=1 · P2 (Standards): `read_blockers`, a leitura da última `Review:` e o fecho dos dependentes de travado copiam o `frontier.sh`, e `TYPES` copia o `VALID` do `new-spec.sh`, com a marca só do lado do `roadmap.sh` — quem mudar a regra no `frontier.sh` ou um tipo no `new-spec.sh` não sabe do gêmeo, e o roteiro passa a divergir da `anvil-run`.
- Review round=1 · P3 (Standards): o array `tipo[]` e os nomes `tipo`/`dep` do awk estão em português, contra a regra de identificadores em inglês do `CLAUDE.md` — só forma.
- Review round=1 · P3 (Standards): os globais de retorno `st`/`rs` e a constante `US` não dizem o que guardam — quem lê precisa abrir o corpo das funções.
- Review round=1 · P3 (Standards): o cabeçalho lista a recusa por argumento inválido com saída 2 e omite a de fora de um repositório git — documentação incompleta, sem efeito no comportamento.
- Review round=1 · P3 (Spec): o `--skip` aceita vírgula além de espaço, sintaxe que a spec não documenta — segunda forma de chamada sem contrato.
- Review round=1 · P3 (Spec): a saída 2 da recusa só está no cabeçalho do script — o índice (ticket 02) precisa saber que a recusa sai com 2 para não tratá-la como falha.
- Review round=1 · P3 (Spec): spec cujos únicos tickets têm `Type:` (decisões do wayfinder), todos `resolved`, sai `open … sem ticket de implementação`, e a tabela da spec diria `stopped` — o índice mostraria "em andamento" numa spec parada.
- Review round=1 · P3 (Spec): o `docs/specs/README.md` diz que o roteiro é escrito "depois do sim do operador", e a spec manda escrevê-lo e mostrá-lo antes do sim, com só o commit depois — quem ler só o README acha que o arquivo não existe enquanto o roteiro espera confirmação.
- Review round=2 · P2 (Standards): segue aberta a cópia do `frontier.sh` e do `VALID` do `new-spec.sh` marcada só no `roadmap.sh` (o `frontier.sh` está fora do escopo da spec 008) — quem mudar o gêmeo não sabe do `roadmap.sh`, e o roteiro diverge da `anvil-run`.
- Review round=2 · P3 (Spec): segue aberto que a saída 2 da recusa só está no cabeçalho do script — o índice (ticket 02) pode tratar a recusa como falha.
- Review round=2 · P3 (Spec): segue aberto que spec só com tickets `Type:`, todos `resolved`, sai `open` — o índice mostraria "em andamento" numa spec parada.
- Review round=2 · P3 (Spec): sem a vírgula no `--skip`, `--skip a,b` é lido como um nome inexistente e ignorado sem aviso — quem errar a sintaxe vê a entrada que devia pular voltar como `next`.
