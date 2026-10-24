# 10: A guarda cobre o `gh api` e cita os dois forges

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** a guarda de merge passa a conferir o PR criado por `gh api` com
`POST` sobre um caminho de `pulls`, além do `gh pr` e do `tea pr`, e as mensagens e
o filtro rápido citam `gh` e `tea`.

- [ ] `gh api -X POST repos/<o>/<r>/pulls …` e as formas com `--method POST` são
      conferidas numa spec sem archive e bloqueadas; um `gh api` de leitura não é.
- [ ] `gh pr create --fill` é conferido como os outros `gh pr create`.
- [ ] As mensagens da guarda, o cabeçalho dela e o texto que a explica no perfil do
      tracker e no `ARCHIVE.md` citam `gh` e `tea`.
- [ ] Prova S1, num diretório novo de `workspace/`, com `workspace/04-hook-merge/` e
      `workspace/40-global-guard/` como prior art: os dois `gh api` com `POST`
      bloqueados; o `gh api` de leitura e a menção em `echo` passam; o
      `gh pr create --fill` bloqueado; os casos antigos continuam.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
