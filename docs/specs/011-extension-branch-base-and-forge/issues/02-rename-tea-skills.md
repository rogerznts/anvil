# 02: As `tea-*` viram `anvil-*` em todo lugar

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** a renomeação mecânica das quatro skills de git, sem mudar o que
elas fazem: `tea-commit` → `anvil-commit`, `tea-open-pr` → `anvil-open-pr`,
`tea-open-fast-pr` → `anvil-open-fast-pr`, `tea-prune-branches` →
`anvil-prune-branches`. Todo lugar que cita os nomes antigos como instrução passa
aos novos, de uma vez, para que o `verify` fique verde e os tickets seguintes já
editem as skills pelo nome novo.

- [x] As quatro pastas e o `name:` do frontmatter têm os nomes novos; o
      `anvil-commit` mantém o `model: haiku`.
- [x] Os nomes novos estão no roster do `dev-link.sh`, no lock regenerado e no
      comentário de skills autorais do manifesto.
- [x] A cauda de roteamento no `claude_boot.md`, de onde saem o bloco do
      `CLAUDE.md` e a rule de diretivas do omp, e no `CLAUDE.md` deste repositório
      cita os nomes novos.
- [x] O perfil do tracker, nas duas cópias e idênticas entre si, o verbo
      `archive`, o `anvil-auto`, o manual `anvil-omp`, o `README`, as rules deste
      repositório e o ADR-0013, onde cita a skill como instrução, usam os nomes
      novos.
- [x] A menção às `tea-*` no `anvil-poteto`, skill vendorizada, muda pelo catálogo
      de adaptação do manifesto, como a `anvil-sync` manda.
- [x] O `anvil-boot` continua reconhecendo as `tea-*` antigas de um projeto do
      mosk.
- [x] O relatório do update, na lista de órfãos, diz o nome novo de cada `tea-*`.
- [x] Prova S1, num diretório novo de `workspace/`, com `workspace/03-reset-install/`
      como prior art, num `HOME` de fixture com um lock que tem as `tea-*`: o reset
      as tira de `~/.claude/skills`, de `~/.agents/skills` e do lock, e liga as
      `anvil-*`.
- [x] Nenhuma citação das `tea-*` como instrução sobra no payload nem nos
      contratos deste repositório; as que sobram são histórico (ADRs antigos, specs
      arquivadas, plano) ou o reconhecimento do mosk.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · prova S1 em `workspace/70-rename-tea-skills/s1.sh`: a instalação
  antiga é a do payload de `7699123`, instalada pelo próprio reset dela num `HOME`
  de fixture; o reset novo roda da cópia "baixada" da árvore, no bash do `PATH`
  (5.2) e no `/bin/bash` 3.2. Vermelho antes da renomeação, em `s1-red.out` (10
  falhas); verde depois, em `s1.out`. O relatório lista `tea-open-pr — agora
  anvil-open-pr` e as outras três entre os órfãos.
- Implementação · o manual `anvil-omp` não cita nenhuma `tea-*` como skill; a
  única menção é o comando `tea pr create` da guarda, que é do ticket 10. Nada a
  mudar ali neste ticket.
- Implementação · o `anvil-poteto` muda pela regra `decursor`, já declarada no
  manifesto (`adapt: [rename, decursor]`): a linha do Shipping e a nota de
  adaptação apontam para a equivalente do anvil, agora `anvil-open-pr` e
  `anvil-open-fast-pr`.
- Implementação · o filtro `(anvil|tea)-` do aviso de referência fora do roster, em
  `dev-link.sh`, ficou como está: o ticket 03 reescreve esse aviso para contar só
  diretório de skill do payload.
- Implementação · na máquina de desenvolvimento, os links `~/.claude/skills/tea-*`
  ficam pendurados até o `dev-link.sh` do ticket 03 rodar; as provas S2 dos tickets
  05 e 06 precisam do `dev-link.sh --all` para ligar as `anvil-*` antes do
  `--dep`.
- Implementação · o roster do `dev-link.sh` tinha só a `tea-commit`, porque este
  repositório fecha sem PR; a renomeação mantém a mesma curadoria, com a
  `anvil-commit` no lugar dela, e não acrescenta as outras três.
