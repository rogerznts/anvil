# 01: Classificação única no `reset-install`

**What to build:** Skills e agentes passam a ser classificados — substituídos, órfãos, alheios e colisões — por uma função só no `reset-install.sh`, em vez de dois laços quase idênticos. Nada muda para o operador: dry-run e execução produzem a mesma saída e o mesmo disco de hoje. É o prefactor que deixa os tickets 02 e 03 aplicarem a mesma regra a conjuntos novos sem copiar o laço de novo.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved
**Review:** round=1; sha=89e2755; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=830ea33; scope=diff:89e2755..830ea33; verdict=pass; p1=none

- [x] Uma função classifica um conjunto a partir de três entradas: o que o payload novo traz, o que o lock diz possuir e o que existe no disco.
- [x] Skills e agentes usam essa função; os dois laços antigos saem.
- [x] Symlink pendurado continua contando como presente no disco, como hoje para agentes.
- [x] Dry-run e execução dos cenários `03-reset-install` e `12-payload-agents` dão saída idêntica à de antes, em bash 5 e em bash 3.2.
- [x] O `verify` sai limpo.

## Comments

- Review round=1 · P1: `for x in $disco` divide a lista do disco por espaço. Uma skill ou um agente do usuário com espaço no nome aparece no relatório de alheios partido em nomes que não existem, e a contagem sai errada. O ticket 03 herdaria o mesmo defeito para `.omp/`.
- Review round=1 · P2: a prova de "saída idêntica" compara o cenário 12, que já tinha 20 falhas antes do patch. São os checks do bloco do `.gitignore` (`--gitignore-only`) e do passo 10, que o script não tem mais. Os de classificação passam: F3, o symlink pendurado; F7, a colisão; sem lock; órfãos. Quem lê a marca pode supor que o cenário passa inteiro.
- Review round=1 · P3: em APFS, que por padrão não diferencia maiúsculas, `[ -d "$SKILLS/Foo" ]` acha um `foo`, e a busca exata na lista do disco não acha. Um diretório do usuário que difere de uma skill do payload só na caixa sairia como "intocado", e o `cp -R` o misturaria com a skill. O relatório mentiria nesse caso, e a mudança deixa de ser idêntica.
- Review round=1 · P3: `classifica` também lê `$LOCK` para a regra de colisão, e a assinatura não mostra isso. Quem a reaproveitar nos tickets 02 e 03 herda um gatilho que não aparece na chamada.
- Review round=1 · P3: a busca de skill passou de `grep -qx` (regex) para `grep -qxF`. Só muda o resultado para nomes com metacaractere, e nesses casos corrige um casamento falso. Nenhuma ação.
- Review round=2 · P1 da rodada 1 corrigido em 830ea33. Os alheios agora saem linha a linha, sem dividir nem expandir. Substituído e órfão voltaram ao teste por nome no sistema de arquivos, passado a `classifica` como predicado (`existe_skill`, `existe_agente`), o que fecha também o P3 de caixa. O `$LOCK` passou a constar no comentário da assinatura. Prova: um script descartável, `workspace/28-reset-classify/edge.sh`, compara o 772745d com a versão nova em nomes com espaço, `*` e colisão só de caixa, e a saída sai idêntica em bash 5 e em bash 3.2.
- Review round=2 · P3: a regra "symlink conta como agente", `[ -f ] || [ -L ]`, está em dois lugares: `existe_agente` e o laço que monta `disco_ag`. Se ela mudar num e não no outro, o mesmo agente passa a ser classificado de um jeito nos alheios e de outro nos substituídos/órfãos, e o relatório se contradiz. Correção: o laço chama `existe_agente`.
- Divergência aceita: uma skill do usuário chamada `x*` agora aparece como alheia. O `grep -qx` antigo casava o nome como regex contra a linha vazia do `printf '%s\n'` e a escondia do relatório. É o P3 de regex da rodada 1, e a prova está em `edge/regex.diff`.
- Fora do escopo: sob bash 3.2, o `vendor-sync.sh verify` morreu de forma intermitente com SIGTRAP (rc=133) no passo 3. Isso aconteceu duas vezes dentro do cenário 12. Em 28 execuções isoladas ou no cenário, com esta versão e com a 89e2755, ele saiu limpo. O passo 3 só lê `*.md`, então nada disso vem do `reset-install.sh`.
