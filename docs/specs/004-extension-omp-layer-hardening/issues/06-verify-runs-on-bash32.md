# 06: `verify` roda até o fim no bash 3.2

**What to build:** O mantenedor no macOS sem bash novo no `PATH` roda o `vendor-sync.sh verify` em `/bin/bash` 3.2 até o fim, com a mesma saída do bash 5. Hoje ele morre com SIGTRAP no check 3. É a linha A11 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] A causa da queda está isolada e escrita no `## Comments`, com o menor caso que a reproduz.
- [x] A correção é mínima e não muda o resultado de nenhum check.
- [x] `/bin/bash` e `/opt/local/bin/bash` rodando o `verify` neste repositório dão saída idêntica e limpa.
- [x] O S3 (`workspace/31-omp-verify/s3.sh`) passa inteiro sob os dois bash.

## Comments

- Causa: dentro de uma função, o bash 3.2.57 só fecha o fd de uma process substitution usada como entrada de um laço (`done < <(...)`) quando a função volta, e não quando o laço acaba. No `cmd_verify`, os checks 2 e 3 abrem uma por arquivo `.md` do payload (`done < <(links_of "$f")`), 246 cada. Medido com `ls /dev/fd | wc -l` logo antes do check 3, com o script do `HEAD` anterior: 261 fds abertos no bash 3.2, 14 no bash 5. Passado o fd 255, o bash 3.2 cai: SIGTRAP (rc 133) no verify e SIGABRT (rc 134) no caso mínimo. Por que o fd 255 derruba o processo não foi lido no fonte do bash; a leitura provável é que o bash 3.2 guarda os fds da process substitution numa tabela de 256 posições e escreve fora dela, e o alocador do macOS aborta. A queda depende do layout da memória: no repositório ela nem sempre aparece, e nas cópias do S3 aparece nos 13 casos. Com `ulimit -n 256`, o vazamento dá `Too many open files`: parte dos checks 2 e 3 e os checks 4 a 8 não leem a entrada (`ambiguous redirect`, `Bad file descriptor`), e o verify imprime `verify: limpo` mesmo assim.
- Menor caso (`/tmp/anvil-004-06/min.sh`): uma função com `while read f; do while read l; do :; done < <(emite "$f"); done < <(seq 1 N)`. Com `ulimit -n` alto, `/bin/bash min.sh 241` passa e `/bin/bash min.sh 242` sai com rc 134; com `ulimit -n 256` sai `redirection error: cannot duplicate fd: Too many open files` e conta 240 de 300. `/opt/local/bin/bash` passa com qualquer N. Duas chamadas seguidas da função com N=150 deixam 165 fds nas duas, o que mostra que o fd fecha na volta da função. Com o laço de dentro lendo de `<<< "$(emite "$f")"`, 1000 voltas deixam 15 fds.
- Correção: nos checks 2 e 3, o laço de dentro troca `done < <(links_of "$f")` por `done <<< "$(links_of "$f")"`, com um comentário no script dizendo por quê. A saída é a mesma: o `links_of` termina com uma quebra de linha, que a command substitution tira e a here-string põe de volta, e a saída vazia continua virando uma linha vazia, que os dois laços já pulam. Os outros laços aninhados do `cmd_verify` (checks 10, 11, 13, 15 e 16) ficaram como estavam: percorrem os agentes e a camada, hoje 6 arquivos, e com eles o bash 3.2 termina com 18 fds abertos.
- Resultado igual, medido em `/tmp/anvil-004-06/equiv.sh`: o script do `HEAD` anterior (b1ccc0a) em `/opt/local/bin/bash` 5.2.15 contra o novo em `/opt/local/bin/bash` e em `/bin/bash` 3.2.57, numa cópia do repositório real e numa cópia quebrada de propósito (um link que não resolve, um `../anvil-implement/SKILL.md` que sai da skill, um `../../fora.md` que cai nos dois checks e um link quebrado dentro de bloco cercado, que os dois ignoram). As três saídas, com o rc, batem byte a byte nos dois casos. A cópia quebrada sai `verify: 4 falha(s)` e rc 1.
- `verify` neste repositório: `/bin/bash` e `/opt/local/bin/bash` saem com rc 0 e `verify: limpo`, e o `diff` das duas saídas é vazio. Com `ulimit -n 256`, o bash 3.2 também sai limpo, sem erro de fd.
- S3 (`workspace/31-omp-verify/s3.sh`): antes da correção, `BASH_BIN=/bin/bash` dava SIGTRAP nos 13 casos e `S3: 14 falha(s)`. Depois, `S3: tudo passou` com `/bin/bash` e com `/opt/local/bin/bash`. O relatório dos dois só difere na última linha, que nomeia o bash, e a saída do verify de cada caso (`fx/*.out` e `fx/*.rc`) dá `diff -r` vazio entre os dois. O cabeçalho do `s3.sh`, que dizia que o verify morria sob o bash 3.2, foi atualizado; o `workspace/` fica fora do git.
