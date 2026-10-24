# 01: O resolvedor diz o branch base, o forge, o repositório e o login

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** um script do payload, junto dos scripts do `anvil-docs`, rodado
da raiz do projeto, que diz em linhas `chave: valor` o branch base, o forge, a URL
do remoto, o host real, o repositório `org/repo` e, no Gitea, o login do `tea`. Ele
lê a seção `## Git` de `.claude/rules/anvil.md` e detecta o que falta; quando a
resposta não é única, sai `2` com linhas `refusal:` e o motivo, como o
`roadmap.sh`.

- [x] A seção `## Git` traz `branch base:` e `forge:`; cada valor declarado vale
      sobre a detecção, e o que falta é detectado.
- [x] Branch base detectado pelo `origin/HEAD`; sem ele, pelo único entre `main` e
      `master` em `refs/heads/`. Os dois ou nenhum: recusa, citando a seção a
      escrever. Branch base declarado que não existe: recusa.
- [x] Forge: sem remoto, `nenhum`; host real `github.com`, `github`; outro host sem
      declaração, recusa citando a seção.
- [x] Host real: de https, o da URL; de ssh, o `hostname` que o `-G` dá com o
      comando de ssh que o git usaria (`GIT_SSH_COMMAND`, `core.sshCommand` ou
      `ssh`). Remotos https, `git@host:org/repo.git` e
      `ssh://git@host:porta/org/repo.git` dão o mesmo `repo:`.
- [x] No Gitea, o login é o do `tea login list --output json` cujo host do `url`
      ou cujo `ssh_host` é o host real. Nenhum ou mais de um: recusa, com os logins
      vistos e o `tea login` para corrigir.
- [x] Prova S1, num diretório novo de `workspace/`, com `workspace/43-roadmap-state/`
      como prior art, no bash do `PATH` e no `/bin/bash` 3.2: seção completa,
      parcial e ausente; `origin/HEAD`, só `main`, só `master`, os dois, nenhum;
      base declarada inexistente; os três formatos de remoto e um alias resolvido
      por `GIT_SSH_COMMAND` com `-F` num config de fixture; `github.com`, host
      desconhecido e sem remoto; login do `tea` com nenhum, um e dois casamentos,
      por `url` e por `ssh_host`, com um `tea` falso local.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o resolvedor é `anvil/.claude/skills/anvil-docs/scripts/resolve-git.sh`; a prova S1 é `workspace/69-git-resolver/s1.sh` (38 conferências, bash 5.2 e `/bin/bash` 3.2, saída em `s1.out`). Leituras que a spec não fixava: o remoto é o `origin`, pela URL de `git remote get-url` (com `insteadOf` aplicado, como o git a usa); origin em caminho local não tem host e dá `forge: nenhum`, e com `gitea` ou `github` declarado é recusa; sem origin, `forge: nenhum` mesmo com forge declarado, pela história 14; `repo:` são os dois últimos segmentos do caminho; além de `GIT_SSH_COMMAND`, `core.sshCommand` e `ssh`, o `GIT_SSH` entra na ordem do git; com recusa só saem linhas `refusal:`.
