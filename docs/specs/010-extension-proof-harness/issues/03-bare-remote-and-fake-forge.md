# 03: Remoto bare e `gh`/`tea` falsos

**Blocked by:** 01

**Status:** resolved

**What to build:** duas opções do helper para provas que passam por remoto e por
PR, sem servidor. A fixture ganha um `origin` local, e a sessão encontra um `gh` e
um `tea` que gravam cada chamada e respondem como no sucesso.

- [x] Com a opção de remoto, a fixture ganha um repositório bare dentro do
      diretório da execução como `origin`, com o branch dela publicado; `git push`
      e `git remote` funcionam na sessão.
- [x] Com a opção de forge falso, um `gh` e um `tea` ficam à frente do `PATH` da
      sessão. Cada chamada grava os argumentos e o diretório num log da execução,
      que vai para as saídas da prova.
- [x] `gh pr create` imprime uma URL de PR no stdout; `tea pr create --output json`
      imprime um objeto com `index`, `title`, `url`, `state`, `base` e `head`. As
      outras chamadas saem `0` sem efeito.
- [x] O remoto e os binários falsos saem com o diretório da execução.
- [x] Prova S1, num diretório novo de `workspace/`: o push chega ao bare; o
      `command -v` acha os falsos antes de qualquer `gh` ou `tea` real; o log grava
      argumentos e diretório; as duas saídas de sucesso no formato de cada um.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · as opções são `proof_prepare --remote` e `proof_prepare --forge`.
  O preparo ainda não conhece a fixture, então o `--remote` cria o bare
  (`$PROOF_REMOTE`, `<execução>/origin.git`) e o `proof_session` o liga como
  `origin` da fixture do `--cwd` e publica o branch atual dela, com upstream, antes
  de abrir a sessão. Fixture fora da raiz de um repositório git, sem commit ou com
  outro `origin` sai `2` com o motivo. O `gh` e o `tea` falsos (`proof-forge.py`)
  vão à frente do `PATH` só da sessão, não no do script da prova, e o log é o
  `forge.jsonl` das saídas, uma linha JSON por chamada com `tool`, `argv` e `cwd`.
- Implementação · leitura literal do ticket: só `gh pr create` e
  `tea pr create --output json` respondem; o `tea pr create` sem `--output json`,
  e os aliases do `tea` (`pulls`, `c`), saem `0` sem saída, como as outras
  chamadas.
- Implementação · prova em `workspace/61-bare-remote-forge/`: `s1.sh` (sem modelo,
  com um omp falso que roda um script no diretório e no ambiente da sessão; bash
  5.2 e `/bin/bash` 3.2) passou inteiro, e as S1 dos tickets 01 e 02
  (`workspace/59-proof-helper/`, `workspace/60-invalid-proof/`) seguem passando.
  Fora dos critérios, `s2.sh` rodou uma sessão real curta com as duas opções:
  a ferramenta de shell do omp achou o `gh` e o `tea` falsos antes dos de
  `/opt/homebrew/bin`, o `git push` chegou ao bare e o `gh pr create` respondeu a
  URL; código do helper `0`, respondida por `anthropic/claude-sonnet-4-5`.
