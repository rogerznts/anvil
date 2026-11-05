# 02: O `anvil-update` instala o workz quando ele falta

**What to build:** O `reset-install.sh` confere o `workz` depois de instalar o payload. Presente no `PATH`, relata a versão. Ausente, no macOS com `brew` no `PATH`, roda `brew install rohansx/tap/workz`. Ausente em outro caso, não instala e relata a URL `https://github.com/rohansx/workz/releases/tag/v0.11.0` para o usuário instalar. O dry-run diz qual dos três casos vai acontecer, e o relatório final, qual aconteceu. A `SKILL.md` do `anvil-update` descreve o passo no contrato e no relato. Um `brew install` que falha não aborta o update: o relatório diz a falha e a URL.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] Num HOME dev com `workz` no `PATH`, o dry-run e a execução relatam a versão e não chamam o `brew`.
- [x] Num HOME dev sem `workz` no `PATH` e com `brew`, o dry-run diz que vai instalar pelo Homebrew, e a execução roda `brew install rohansx/tap/workz` — provado com um `brew` falso no `PATH` que registra a chamada.
- [x] Sem `workz` e sem `brew`, o dry-run e a execução relatam a URL da `v0.11.0` e não instalam nada; um `brew` que falha também termina com a URL no relatório e o update saindo 0.
- [x] A `SKILL.md` do `anvil-update` cita o passo no contrato e no relato.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Implementado em `051f8b3`. Prova em HOME descartável, com `PATH` controlado e `--from` em `anvil/`: com `workz` presente, relata `workz 0.11.0` sem chamar o `brew`; sem `workz` e com `brew`, o dry-run anuncia e a execução roda `brew install rohansx/tap/workz`; sem `brew`, e com `brew` saindo 1, relata a URL da `v0.11.0` e o update sai 0. `verify: limpo`.
