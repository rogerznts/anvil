# 05: O `anvil-open-pr` abre o PR no GitHub e no Gitea

**Blocked by:** 01, 02, 04

**Status:** ready-for-agent

**What to build:** o `anvil-open-pr` lê o resolvedor no começo e abre o PR no forge
dele, para o branch base, com o texto, o rótulo e a linha `PR:` escritos uma vez e
só o bloco de comando mudando entre `gh` e `tea`. O par branch estável e de
integração some; o hotfix abre um PR só.

- [ ] Com o resolvedor recusando, a skill para com o motivo dele e não chama o
      CLI.
- [ ] GitHub: `gh pr create` com `--base` no branch base, `--head`, título, corpo,
      rótulo, `--assignee @me` e `--repo` do resolvedor; a URL vem do stdout.
- [ ] Gitea: `tea pr create --login <login> --repo <repo> --output json`, com a
      base no branch base; a URL vem do campo `url`.
- [ ] O rótulo é escolhido entre os que o forge lista, pelo `gh label list` ou pelo
      `tea labels list --login --repo`.
- [ ] Cada ticket da spec ganha a linha `PR:` com a URL, uma linha a mais quando já
      tem uma.
- [ ] O hotfix abre um PR só, para o branch base.
- [ ] Prova S2 pelo helper, com `--remote --forge` e as dependências declaradas,
      num diretório novo de `workspace/`, com `/skill:anvil-open-pr`: fixture GitHub
      com `master` (o log mostra `gh pr create --base master`, e os tickets ganham a
      linha `PR:`); fixture Gitea com `develop` declarada e remoto por alias de ssh
      via `GIT_SSH_COMMAND` (o log mostra `--login`, `--repo` e a base `develop`);
      um hotfix (um `pr create` só); Gitea com dois logins casando (recusa, sem
      `pr create` no log). O código do helper sai nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
