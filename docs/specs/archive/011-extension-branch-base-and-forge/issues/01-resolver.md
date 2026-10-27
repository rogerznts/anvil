# 01: O resolvedor diz o branch base, o forge, o repositório e o login

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=caf92b7; scope=full; verdict=pass; p1=none

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
- Review round=1 · P3 (Standards): `parse_remote` e `ssh_hostname` devolvem por globais (`kind`, `ssh_target`, `host`, `path`, `ssh_cmd`, `ssh_error`), e o caso `local` não redefine `host` — uma segunda chamada herdaria o host da anterior; hoje há uma chamada só.
- Review round=1 · P3 (Standards): o `tea login list --output json` roda de novo na falha, só para pegar o stderr — um `tea` intermitente citaria na recusa um erro diferente do que a causou.
- Review round=1 · P3 (Standards): o marcador `m`/`-` das linhas do python3 e o `found=" main"` com espaço à frente pedem o comentário para ser entendidos — custo de leitura para quem mantém.
- Review round=1 · P3 (Spec): o `GIT_SSH` na ordem do ssh não tem caso na S1 — uma regressão nesse caminho passaria sem prova.
- Review round=1 · P3 (Spec): as recusas de `origin/HEAD` para branch sem local, origin em caminho local com `gitea`/`github` declarado, caminho sem `org/repo` e argumento passado não têm caso na S1 — uma mudança nelas passaria sem prova.
- Review round=1 · P3 (Spec): o resolvedor só olha o `origin`; um projeto cujo único remoto é `upstream` sai com `forge: nenhum` e fecharia por merge local sem aviso.
- Review round=1 · P3 (Spec): a chave da seção `## Git` é lida sem diferenciar maiúsculas, o valor de `forge:` não — `forge: GitHub` é recusado, com a correção dita na recusa.
