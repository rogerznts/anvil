# 04: Infra do bench isolada por prefixo

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** o `infra.sh` do bench aceita um prefixo de execução que dá à
infra um compose, uma rede, um registro e volumes próprios, e uma derrubada que só
vale com o prefixo. O helper ganha a opção de infra, que liga o prefixo com o id da
execução e derruba tudo no fim. Sem o prefixo, nada muda para os projetos reais.

- [ ] Com o prefixo, o nome do projeto do compose, a rede e o diretório do registro
      levam o prefixo, e os volumes ficam no compose prefixado.
- [ ] A alocação passa a imprimir a rede. O compose do app do starter lê o nome da
      rede do `.env`, com `anvil-net` como padrão, e o bench materializa a rede no
      `.env` com o resto da alocação.
- [ ] Sem o prefixo, o `infra.sh` usa a `anvil-net` e o registro em
      `~/projects/.anvil-infra/`, como hoje, e projeto sem a rede no `.env` continua
      na `anvil-net`.
- [ ] A derrubada remove o compose do prefixo com os volumes, a rede e o registro
      dele. Sem prefixo, recusa com o motivo e não toca em nada.
- [ ] A porta do admin alocada sob o prefixo continua conferida contra as portas em
      uso na máquina.
- [ ] O `INVARIANTS.md` do bench cita o prefixo como a única exceção à infra única
      por máquina, e só para prova.
- [ ] A opção de infra do helper liga o prefixo e chama a derrubada na limpeza,
      também em falha e em interrupção.
- [ ] Prova S1 com docker, num diretório novo de `workspace/`: a infra do prefixo
      sobe separada; a derrubada a remove; a derrubada sem prefixo recusa; o antes e
      depois de containers, redes, volumes e registro da infra compartilhada mostra
      que ela não mudou.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
