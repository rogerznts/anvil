# 03: O `dev-link.sh` tira links pendurados e para de acusar o `anvil-net`

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=f95856e; scope=full; verdict=pass; p1=none

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
- Review round=1 · P3 (Standards): `pend_removidos` e "symlink(s) pendurado(s)" (symlink cujo alvo sumiu) convivem no `dev-link.sh` com `penduradas` (referência para fora do roster) — quem lê o código ou o relatório confunde as duas listas, sem mudar comportamento.
- Review round=1 · P3 (Standards): o comentário de `ligada()` não diz que o `[ -e "$DEST/$1" ]` só pesa no `--dry-run`, quando o pendurado ainda está em `~/.claude/skills` — quem o apagar por redundante faz o dry-run deixar de listar os pendurados de `~/.agents/skills`, e a prova que pega isso fica fora do git.
- Review round=1 · P3 (Standards): a linha `if [ "$DRY" -eq 1 ]; then echo "removeria …"; else rm -f …; fi` passa a existir em mais um laço — mudar o formato do "removeria" exige editar vários lugares.
- Review round=1 · P3 (Standards): o cabeçalho de uso cita a remoção dos pendurados só no modo padrão, e o `--all` também remove — quem lê só o cabeçalho pode achar que o `--all` não limpa.
- Review round=1 · P3 (Spec): o comentário acima atribui à spec a decisão de deixar os dois checks `tea-commit` da `workspace/42-dev-link/` falhando, mas o Out of Scope da spec só fala das provas que fixam `main` — quem lê o ticket acha que a spec decidiu o que foi decisão do implementador.
- Review round=1 · P3 (Spec): no `--dry-run`, um link nosso com nome do roster que aponta para skill que saiu do payload (por exemplo `anvil-commit → …/tea-commit`) aparece como "ligaria" e também "removeria", e conta 1 pendurado, enquanto a execução real o refaz e conta 0 — o dry-run mostra uma remoção que não acontece, sem mudar o `HOME` final.
