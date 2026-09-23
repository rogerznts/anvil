# 01: Classificação única no `reset-install`

**What to build:** Skills e agentes passam a ser classificados — substituídos, órfãos, alheios e colisões — por uma função só no `reset-install.sh`, em vez de dois laços quase idênticos. Nada muda para o operador: dry-run e execução produzem a mesma saída e o mesmo disco de hoje. É o prefactor que deixa os tickets 02 e 03 aplicarem a mesma regra a conjuntos novos sem copiar o laço de novo.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] Uma função classifica um conjunto a partir de três entradas: o que o payload novo traz, o que o lock diz possuir e o que existe no disco.
- [x] Skills e agentes usam essa função; os dois laços antigos saem.
- [x] Symlink pendurado continua contando como presente no disco, como hoje para agentes.
- [x] Dry-run e execução dos cenários `03-reset-install` e `12-payload-agents` dão saída idêntica à de antes, em bash 5 e em bash 3.2.
- [x] O `verify` sai limpo.
