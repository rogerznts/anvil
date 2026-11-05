# 01: O código do workz entra em `references/workz`, com pin na `v0.11.0`

**What to build:** O workz entra como submodule em `references/workz`, com pin no commit da tag `v0.11.0`, a release que o anvil instala. É sistema de referência, não upstream vendorizado: fica fora de `sources:` do `anvil-skills.yaml`, e nada dele é copiado para o payload. A tabela "Fonte e derivado" do `.claude/rules/project.md` cita o workz entre os sistemas de referência versionados, e o `vendor-sync.sh verify` continua limpo com o submodule novo.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `references/workz` existe como submodule, registrado no `.gitmodules`, com o `HEAD` no commit da tag `v0.11.0`.
- [ ] O `anvil-skills.yaml` não lista o workz em `sources:`, e o `.claude/rules/project.md` o cita como sistema de referência versionado, com pin.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments
