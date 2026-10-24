# ADR-0016 — As skills de git servem Gitea e GitHub, com o nome do toolkit

- Status: aceito
- Data: 2026-10-23

## Contexto

O commit, o PR, o PR rápido e a limpeza de branches são as skills `tea-*`, escritas
para o Gitea: não há caminho de PR com `gh`, e o perfil do tracker, o `ARCHIVE.md` e
o piloto mandam fechar por `/tea-open-pr`. Num remoto GitHub, a spec que fecha por
PR para. O `tea` também tem um modo de falha silencioso: com o remoto num alias do
`~/.ssh/config`, nenhum login casa, e ele cai no login padrão só com um aviso no
stderr — num ambiente com mais de um Gitea, o PR sai no servidor errado.

## Decisão

**As quatro skills viram `anvil-commit`, `anvil-open-pr`, `anvil-open-fast-pr` e
`anvil-prune-branches`, e cada uma serve os dois forges, com remoto ssh ou https.**
O forge vem da seção `## Git` das rules, como diz o
[ADR-0015](./adr-0015-branch-base-declarado-ou-detectado.md).

- **Uma skill por ação, não uma por forge.** O texto do PR, o rótulo e a linha
  `PR:` ficam escritos uma vez; só o bloco de comando muda entre `tea` e `gh`.
- **O `tea` nunca escolhe o login sozinho.** A skill tira o host real do remoto —
  por `ssh -G` no ssh, pela URL no https —, acha o login do `tea` que casa com ele e
  passa `--login` e `--repo org/repo` explícitos. Sem casamento, ou com mais de um,
  recusa e diz como resolver. O `gh` já resolve o alias sozinho e recebe só o
  `--repo`.
- **A URL do PR vem da saída de máquina:** `tea pr create --output json` e o stdout
  do `gh pr create`.
- **Corte limpo.** Os nomes `tea-*` saem como órfãos do lock na próxima instalação,
  sem alias; o relatório do update diz o nome novo de cada um. O `dev-link.sh`
  passa a tirar os links que apontam para skill que saiu do payload.
- **A guarda** fala dos dois forges nas mensagens e passa a cobrir o
  `gh api … pulls` que cria PR.

## Alternativas descartadas

- **Nome sem prefixo** (`commit`, `open-pr`). Os diretórios de usuário são
  compartilhados com outros toolkits, e um nome genérico colide.
- **Prefixo `git-`.** Sugere um wrapper do `git`, mas abrir PR é do forge.
- **Uma `gh-open-pr` irmã da `tea-open-pr`.** Duplica umas 250 linhas que divergem
  com o tempo.
- **Alias `tea-*` por uma versão.** Shim que alguém precisa lembrar de tirar.
- **Exigir `ssh_host` no config do `tea`, ou declarar o login nas rules.** Pede
  configuração nova para o que dá para resolver pelo remoto.
