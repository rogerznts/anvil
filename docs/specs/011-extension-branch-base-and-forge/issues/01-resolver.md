# 01: O resolvedor diz o branch base, o forge, o repositório e o login

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** um script do payload, junto dos scripts do `anvil-docs`, rodado
da raiz do projeto, que diz em linhas `chave: valor` o branch base, o forge, a URL
do remoto, o host real, o repositório `org/repo` e, no Gitea, o login do `tea`. Ele
lê a seção `## Git` de `.claude/rules/anvil.md` e detecta o que falta; quando a
resposta não é única, sai `2` com linhas `refusal:` e o motivo, como o
`roadmap.sh`.

- [ ] A seção `## Git` traz `branch base:` e `forge:`; cada valor declarado vale
      sobre a detecção, e o que falta é detectado.
- [ ] Branch base detectado pelo `origin/HEAD`; sem ele, pelo único entre `main` e
      `master` em `refs/heads/`. Os dois ou nenhum: recusa, citando a seção a
      escrever. Branch base declarado que não existe: recusa.
- [ ] Forge: sem remoto, `nenhum`; host real `github.com`, `github`; outro host sem
      declaração, recusa citando a seção.
- [ ] Host real: de https, o da URL; de ssh, o `hostname` que o `-G` dá com o
      comando de ssh que o git usaria (`GIT_SSH_COMMAND`, `core.sshCommand` ou
      `ssh`). Remotos https, `git@host:org/repo.git` e
      `ssh://git@host:porta/org/repo.git` dão o mesmo `repo:`.
- [ ] No Gitea, o login é o do `tea login list --output json` cujo host do `url`
      ou cujo `ssh_host` é o host real. Nenhum ou mais de um: recusa, com os logins
      vistos e o `tea login` para corrigir.
- [ ] Prova S1, num diretório novo de `workspace/`, com `workspace/43-roadmap-state/`
      como prior art, no bash do `PATH` e no `/bin/bash` 3.2: seção completa,
      parcial e ausente; `origin/HEAD`, só `main`, só `master`, os dois, nenhum;
      base declarada inexistente; os três formatos de remoto e um alias resolvido
      por `GIT_SSH_COMMAND` com `-F` num config de fixture; `github.com`, host
      desconhecido e sem remoto; login do `tea` com nenhum, um e dois casamentos,
      por `url` e por `ssh_host`, com um `tea` falso local.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
