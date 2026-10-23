# 04: Infra do bench isolada por prefixo

**Blocked by:** 01

**Status:** resolved

**What to build:** o `infra.sh` do bench aceita um prefixo de execução que dá à
infra um compose, uma rede, um registro e volumes próprios, e uma derrubada que só
vale com o prefixo. O helper ganha a opção de infra, que liga o prefixo com o id da
execução e derruba tudo no fim. Sem o prefixo, nada muda para os projetos reais.

- [x] Com o prefixo, o nome do projeto do compose, a rede e o diretório do registro
      levam o prefixo, e os volumes ficam no compose prefixado.
- [x] A alocação passa a imprimir a rede. O compose do app do starter lê o nome da
      rede do `.env`, com `anvil-net` como padrão, e o bench materializa a rede no
      `.env` com o resto da alocação.
- [x] Sem o prefixo, o `infra.sh` usa a `anvil-net` e o registro em
      `~/projects/.anvil-infra/`, como hoje, e projeto sem a rede no `.env` continua
      na `anvil-net`.
- [x] A derrubada remove o compose do prefixo com os volumes, a rede e o registro
      dele. Sem prefixo, recusa com o motivo e não toca em nada.
- [x] A porta do admin alocada sob o prefixo continua conferida contra as portas em
      uso na máquina.
- [x] O `INVARIANTS.md` do bench cita o prefixo como a única exceção à infra única
      por máquina, e só para prova.
- [x] A opção de infra do helper liga o prefixo e chama a derrubada na limpeza,
      também em falha e em interrupção.
- [x] Prova S1 com docker, num diretório novo de `workspace/`: a infra do prefixo
      sobe separada; a derrubada a remove; a derrubada sem prefixo recusa; o antes e
      depois de containers, redes, volumes e registro da infra compartilhada mostra
      que ela não mudou.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o prefixo é a variável `ANVIL_INFRA_PREFIX` do `infra.sh`, no
  formato de nome de projeto do compose, `[a-z0-9][a-z0-9_-]*`; fora dele, o script
  sai `1` com o motivo. Com ela, o projeto do compose é `<prefixo>-anvil-infra`
  (passado por `-p`, que vale sobre o `name:` do arquivo), a rede é
  `<prefixo>-anvil-net` e o registro fica em `~/projects/.<prefixo>-anvil-infra/`.
  O compose da infra e o do app leem o nome da rede de `ANVIL_NETWORK`, com
  `anvil-net` como padrão; o `infra.sh` a passa ao compose da infra, a alocação a
  imprime em `ALLOC_NETWORK`, e o `.env.example` do starter ganhou a chave. A
  derrubada é `infra.sh --teardown`; sem o prefixo, ou com ele vazio, sai `1` com o
  motivo, na convenção `ERRO:` do script, antes de qualquer chamada ao docker.
- Implementação · a derrubada remove também os containers ligados à rede do
  prefixo, como o app da prova, que prenderiam a rede; a rede só existe para a
  prova. Os volumes do compose do app, como o `node_modules`, não são da infra e
  ficam: quem sobe o app na prova o derruba com o compose dele.
- Implementação · o helper ganhou `proof_prepare --infra`: exporta
  `ANVIL_INFRA_PREFIX=proof-<sufixo do mktemp em hexadecimal>` para o script da
  prova e para a sessão, e a limpeza roda o `--teardown` do `infra.sh` da fonte
  antes de remover o diretório da execução. O hexadecimal é porque o sufixo do
  `mktemp` distingue maiúsculas, e o prefixo não as aceita.
- Implementação · prova em `workspace/62-isolated-bench-infra/s1.sh`, com docker,
  passou inteira: o `--dry-run` e o reuso real sem prefixo na `anvil-net`; a infra
  do prefixo com Postgres e Redis, rede, volumes, registro e banco próprios; a
  porta do admin pulando uma porta ocupada por um ouvinte; o app do starter, por
  `docker compose run` com a rede no `.env`, resolvendo o `postgres` no IP do
  Postgres do prefixo, e o projeto sem a chave na `anvil-net`; a derrubada sem
  prefixo e com prefixo vazio recusando sem tocar em nada; a derrubada com prefixo
  sem deixar nada, e repetida saindo `0`; o `--infra` do helper no verde (pela
  sessão do omp falso), na falha e num `TERM`, no bash 5.2 e no `/bin/bash` 3.2;
  e o antes e depois de containers, rede, volumes, bancos e registro da infra
  compartilhada iguais. As S1 dos tickets 01, 02 e 03 seguem passando.
- Implementação · fora do escopo, já existia: o `--provision --dry-run` escreve o
  cabeçalho do `registry.yaml` quando ele falta (`registry_init` roda antes do
  teste de `--dry-run`), e a ajuda diz que o `--dry-run` não escreve no registro.
  Sob o prefixo, a derrubada remove o arquivo.
- Implementação · para o ticket 09: o `anvil-bench` chama o `infra.sh` por
  `~/.claude/skills/anvil-stack-payload/bench/infra.sh`, e nesta máquina o
  `anvil-stack-payload` não está ligado em `~/.claude/skills`; a derrubada do
  helper usa o `infra.sh` da fonte.
