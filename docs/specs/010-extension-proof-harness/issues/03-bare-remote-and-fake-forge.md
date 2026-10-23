# 03: Remoto bare e `gh`/`tea` falsos

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=3fdc448; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Spec): o `_proof_cleanup` apaga o bare, mas não tira o `origin` nem o upstream que o `_proof_publish` grava no `.git/config` da fixture, e o cabeçalho não diz isso — uma fixture reaproveitada entre execuções fica com `origin` para um caminho apagado e a execução seguinte sai `2` com "a fixture já tem um origin".
- Review round=1 · P3 (Spec): vão além do pedido as recusas `2` para fixture fora da raiz, sem commit ou com outro `origin`, o `symbolic-ref HEAD` no bare, o `--repo` honrado e a numeração dos PRs por ferramenta, e o `rm -f` do `forge.jsonl` velho sem `--forge` — nada quebra, mas o contrato que a 011 herda fica um pouco maior.
- Review round=1 · P3 (Standards): no `proof-forge.py`, o padrão `'fake/fixture'` aparece duas vezes (Duplicated Code) — trocar um e esquecer o outro dá URLs de repositórios diferentes ao `gh` e ao `tea` na mesma prova.
- Review round=1 · P3 (Standards): o caminho do log sai da estrutura de `$PROOF_RUN` nos dois lados, `dirname(dirname(argv[0]))/forge.jsonl` no `proof-forge.py` e `$PROOF_RUN/forge.jsonl` com os links em `forge/` no `proof.sh` (Shotgun Surgery) — mudar a estrutura exige mexer nos dois, e o falso quebra com `FileNotFoundError` em vez de recusar com o motivo.
- Review round=1 · P3 (Standards): sem `--forge`, o `proof_session` apaga um `forge.jsonl` antigo de `<saídas>`, e o cabeçalho não diz — quem lê só o cabeçalho não sabe que o arquivo some.
- Review round=1 · P3 (Standards): `local fx` no `_proof_publish` destoa do `cwd` do `proof_session` e da "fixture" da prosa (Mysterious Name) — só custa leitura.
- Review round=1 · P3 (Standards): o `SKILL.md` diz que os falsos "gravam cada chamada no `forge.jsonl` das saídas", mas eles gravam em `$PROOF_RUN/forge.jsonl` e o helper copia para as saídas depois da sessão; e o comportamento do forge está descrito em três lugares (`SKILL.md`, cabeçalho do `proof.sh`, docstring do `proof-forge.py`) — três superfícies a manter em sincronia.
- Review round=1 · P3 (Standards): o `option()` do `proof-forge.py` aceita as formas curtas (`-R`, `-r`, `-t`, `-b`, `-o`) e `--x=y`, enquanto o comentário de implementação declara leitura literal e deixa os aliases do `tea` (`pulls`, `c`) sem resposta (Speculative Generality leve) — o critério fica inconsistente, sem mudar decisão.
