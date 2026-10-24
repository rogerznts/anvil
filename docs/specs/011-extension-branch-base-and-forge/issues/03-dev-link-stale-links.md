# 03: O `dev-link.sh` tira links pendurados e para de acusar o `anvil-net`

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** o `dev-link.sh`, sem `--unlink`, passa a tirar o link nosso cujo
alvo saiu do payload, em `~/.claude/skills` e `~/.agents/skills`, e o aviso de
referência fora do roster passa a contar só nome que é diretório de skill do
payload.

- [x] Um link nosso para uma skill que não existe mais no payload sai, nos dois
      diretórios, e o relatório o conta entre os removidos.
- [x] O link de outro toolkit, e o diretório ou arquivo real, ficam como estão.
- [x] O aviso de referência fora do roster não acusa `anvil-net` nem outro nome
      que não é skill do payload, e continua acusando a skill do payload fora do
      roster.
- [x] Prova S1, num diretório novo de `workspace/`, com `workspace/42-dev-link/`
      como prior art, num `HOME` de fixture: o link pendurado sai; o alheio fica; o
      aviso sem `anvil-net`; o aviso de uma referência real continua.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Prova S1 em `workspace/71-dev-link-stale-links/s1.sh`, no bash do `PATH` (5.2)
  e no `/bin/bash` 3.2: 23 checks, todos passam. A prova de prior art
  `workspace/42-dev-link/s1.sh` continua passando, menos os dois checks que fixam
  `tea-commit` no roster, que o ticket 02 renomeou; as provas antigas não são
  reescritas, como a spec põe fora de escopo.
