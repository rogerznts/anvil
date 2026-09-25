# 07: Check 15 confere os blocos de código

**What to build:** O `verify` passa a conferir os caminhos da camada citados dentro dos blocos de código das skills da camada, e não só na prosa. Um erro de digitação no comando que a `anvil-run` ou a `anvil-plan` mandam rodar reprova no `verify`, em vez de quebrar a sessão do operador. É a linha A5 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved
**Review:** round=1; sha=dc84d02; scope=full; verdict=pass; p1=none

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
- Review round=1 · P3 (Spec): o tokenizador do bloco não parte a linha em `>`, `<` nem `=`, e a palavra com prefixo não casa inteira com a regex: `cat >.omp/x/typo.sh`, `--file=.omp/x/typo.sh` e `./.omp/x/typo.sh` ficam de fora; um comando futuro escrito numa dessas formas escapa da conferência sem aviso. Hoje nenhum bloco da camada tem essa forma.
- Review round=1 · P3 (Spec): pontuação no fim da palavra do bloco (`.omp/x.sh,`) entra no caminho e reprova; é falso positivo ruidoso, não silencioso, e não afeta o payload atual.
- Review round=1 · P3 (Standards): o modo do `spans_of` chega como string solta (`sys.argv[3] == 'blocos'`), e qualquer outro valor cai sem aviso no modo só-prosa; uma chamada futura com `bloco` ou `Blocos` sai `verify: limpo` sem conferir os blocos.
- Review round=1 · P3 (Standards): o par `re.fullmatch(sys.argv[2], t)` / `print(t)` se repete no ramo do bloco, no da prosa e no do `.ts` do `citados_of`; mudar a regra de emissão pede uma edição em cada ramo, e esquecer um faz bloco e prosa aceitarem caminhos diferentes sem que o S3 aponte.
- Review round=1 · P3 (Standards): o tokenizador do bloco não parte em `<>=,` nem tira a pontuação final; `.omp/a>out` e `.omp/skills/x.` saem como palavra e reprovam em falso, e `--f=.omp/x` e `2>.omp/log` ficam de fora sem aviso. Nenhuma linha de bloco da camada real tem essas formas.
- Review round=1 · P3 (Standards): o cabeçalho do `spans_of` ainda justifica pular o bloco cercado com "que e exemplo", e o parágrafo novo abre a exceção sem dizer por que, na camada, o bloco é comando; quem ler só o cabeçalho pode achar que o modo `blocos` contradiz o contrato e removê-lo.
