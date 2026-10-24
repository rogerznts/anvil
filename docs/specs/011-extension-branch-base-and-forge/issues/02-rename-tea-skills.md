# 02: As `tea-*` viram `anvil-*` em todo lugar

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** a renomeação mecânica das quatro skills de git, sem mudar o que
elas fazem: `tea-commit` → `anvil-commit`, `tea-open-pr` → `anvil-open-pr`,
`tea-open-fast-pr` → `anvil-open-fast-pr`, `tea-prune-branches` →
`anvil-prune-branches`. Todo lugar que cita os nomes antigos como instrução passa
aos novos, de uma vez, para que o `verify` fique verde e os tickets seguintes já
editem as skills pelo nome novo.

- [ ] As quatro pastas e o `name:` do frontmatter têm os nomes novos; o
      `anvil-commit` mantém o `model: haiku`.
- [ ] Os nomes novos estão no roster do `dev-link.sh`, no lock regenerado e no
      comentário de skills autorais do manifesto.
- [ ] A cauda de roteamento no `claude_boot.md`, de onde saem o bloco do
      `CLAUDE.md` e a rule de diretivas do omp, e no `CLAUDE.md` deste repositório
      cita os nomes novos.
- [ ] O perfil do tracker, nas duas cópias e idênticas entre si, o verbo
      `archive`, o `anvil-auto`, o manual `anvil-omp`, o `README`, as rules deste
      repositório e o ADR-0013, onde cita a skill como instrução, usam os nomes
      novos.
- [ ] A menção às `tea-*` no `anvil-poteto`, skill vendorizada, muda pelo catálogo
      de adaptação do manifesto, como a `anvil-sync` manda.
- [ ] O `anvil-boot` continua reconhecendo as `tea-*` antigas de um projeto do
      mosk.
- [ ] O relatório do update, na lista de órfãos, diz o nome novo de cada `tea-*`.
- [ ] Prova S1, num diretório novo de `workspace/`, com `workspace/03-reset-install/`
      como prior art, num `HOME` de fixture com um lock que tem as `tea-*`: o reset
      as tira de `~/.claude/skills`, de `~/.agents/skills` e do lock, e liga as
      `anvil-*`.
- [ ] Nenhuma citação das `tea-*` como instrução sobra no payload nem nos
      contratos deste repositório; as que sobram são histórico (ADRs antigos, specs
      arquivadas, plano) ou o reconhecimento do mosk.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
