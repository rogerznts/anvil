# 07: Check 15 confere os blocos de código

**What to build:** O `verify` passa a conferir os caminhos da camada citados dentro dos blocos de código das skills da camada, e não só na prosa. Um erro de digitação no comando que a `anvil-run` ou a `anvil-plan` mandam rodar reprova no `verify`, em vez de quebrar a sessão do operador. É a linha A5 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] O check 15 extrai dos blocos cercados dos arquivos da camada os caminhos que casam com o padrão de caminho da camada e confere cada um contra o payload, com a mesma mensagem de falha da prosa.
- [x] A conferência da prosa continua igual.
- [x] Caso novo no S3: uma cópia com o caminho errado só dentro do bloco `bash` de uma skill da camada reprova no check 15, e em nenhum outro check.
- [x] O payload real passa limpo.

## Comments

- Leitura: o `spans_of` do `vendor-sync.sh` pulava toda linha dentro de bloco cercado. Ele ganhou um terceiro argumento opcional, `blocos`, e só o check 15 o passa, pelo `citados_of` dos `.md` da camada. Com ele, a linha do bloco se parte em palavras nos espaços, nas aspas, na crase e em `;|&()`, e sai a palavra que casa inteira com o mesmo `CAMADA_PATH_RE` da prosa. Palavra com `$` é expansão do shell e fica de fora: é o `".omp/$f"` do bloco de desinstalação da `anvil-omp`. A detecção de cerca é a mesma dos spans, e os checks 10 e 13, que chamam com dois argumentos, não mudam. O laço do check 15 é o mesmo, e a falha sai pela mesma linha `FALHA .omp-layer/<arquivo> -> <caminho>`. Nenhum laço novo: o vazamento de fd que o ticket 06 corrigiu não volta.
- O que os blocos da camada real citam e agora é conferido: `.claude/anvil.lock` três vezes no bloco da `anvil-omp`, `.omp/skills/anvil-plan/stage.sh` e `.omp/skills/anvil-run/frontier.sh`. O `.claude/anvil.lock.novo` do mesmo bloco não casa com o padrão e fica de fora.
- Caso novo no S3 (`workspace/31-omp-verify/s3.sh`), `15-bloco`: troca `bash .omp/skills/anvil-run/frontier.sh [NNN]` por `.../fronteira.sh` só no bloco `bash` da `anvil-run`, e a prosa da mesma skill continua citando o caminho certo. Vermelho antes da correção: com o script de `e23158a`, o caso saiu rc 0 e `verify: limpo`, e o S3 deu `S3: 1 falha(s)`. Depois: rc 1, a única linha FALHA é `.omp-layer/skills/anvil-run/SKILL.md -> .omp/skills/anvil-run/fronteira.sh`, sob o check 15.
- S3 inteiro, pelo `hub`: `S3: tudo passou` com `/opt/local/bin/bash` 5.2.15 e com `/bin/bash` 3.2.57, nos 14 casos. Os relatórios só diferem na última linha, que nomeia o bash, e as saídas do verify de cada caso (`fx/*.out` e `fx/*.rc`, 28 arquivos) dão `diff -r` vazio entre os dois.
- Prosa igual, medido em `/tmp/anvil-004-07/equiv.sh`: o script de `e23158a` rodou em cada caso do S3 e a saída foi comparada com a do script novo. Os 13 casos que já existiam, incluindo o `real` e os três do check 15 pela prosa e pelo `.ts` (`15-md`, `15-ts`, `15-agente`), batem byte a byte, com o rc. Só o `15-bloco` difere, pela linha FALHA nova e pelo `verify: 1 falha(s)`.
- `verify` neste repositório: `/opt/local/bin/bash` e `/bin/bash` saem com rc 0 e `verify: limpo`, e o `diff` das duas saídas é vazio.
- `frontier.sh`, `stage.sh` e as skills da camada não mudaram, e por isso o fixture golden e os S2 não rodaram.
