# 01: Classificação única no `reset-install`

**What to build:** Skills e agentes passam a ser classificados — substituídos, órfãos, alheios e colisões — por uma função só no `reset-install.sh`, em vez de dois laços quase idênticos. Nada muda para o operador: dry-run e execução produzem a mesma saída e o mesmo disco de hoje. É o prefactor que deixa os tickets 02 e 03 aplicarem a mesma regra a conjuntos novos sem copiar o laço de novo.

**Blocked by:** Nenhum — pode começar agora.

**Status:** claimed
**Review:** round=1; sha=89e2755; scope=full; verdict=fail; p1=open

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
