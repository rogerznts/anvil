# 06: `dev-link` para o diretório do usuário e recusa do update

**What to build:** Na máquina de desenvolvimento, o `dev-link` liga a instalação de usuário ao payload deste repositório. Com isso, este repositório e todos os outros projetos da máquina rodam a skill em edição. O `--unlink` volta a uma máquina pronta para receber a instalação publicada. O `/anvil-update` se recusa a instalar por cima de uma instalação de desenvolvimento, para não escrever o payload publicado dentro da fonte através de um symlink.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] O `dev-link` cria symlinks para o payload deste repositório em quatro lugares: `~/.claude/skills/<skill>` para cada skill do roster, os agentes, o espelho em `~/.agents/skills` e a camada omp em `~/.omp/agent/`.
- [ ] O `--all` continua ligando o payload inteiro, e o `--dry-run` continua mostrando sem alterar.
- [ ] O `--unlink` remove só os symlinks que apontam para o payload deste repositório e deixa intocado o que não aponta para ele.
- [ ] Os symlinks de projeto em `.claude/skills/anvil-*` deixam de ser criados. O `anvil-sync` fica onde está, e o `anvil-update` segue fora do roster.
- [ ] O `reset-install` recusa instalar quando alguma entrada do payload no diretório de usuário é symlink. Nesse caso não escreve nada e aponta o `dev-link --unlink` na mensagem.
- [ ] Cenário em `workspace/` com `HOME` temporário. Depois do `dev-link`, as entradas de `HOME` são symlinks para o payload. O update recusa e não escreve nada.
- [ ] No mesmo cenário, depois do `--unlink`, o update instala normalmente.
- [ ] O `vendor-sync.sh verify` sai limpo.
