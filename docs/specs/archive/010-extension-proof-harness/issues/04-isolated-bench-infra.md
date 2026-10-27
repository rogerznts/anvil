# 04: Infra do bench isolada por prefixo

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=17c46b7; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Spec): os volumes do compose do app, como o `node_modules`, ficam depois da derrubada, e a spec diz que a stack "sai no fim" — se o ticket 09 não derrubar o app com o compose dele, cada B1 deixa um volume órfão na máquina.
- Review round=1 · P3 (Spec): a derrubada também remove os containers ligados à rede do prefixo, o que a spec não pede; a razão está no comentário de implementação — nenhuma decisão muda.
- Review round=1 · P3 (Spec): o `--teardown --dry-run` e a recusa de `--teardown` com `--provision` vão além do pedido — extras pequenos, sem consequência.
- Review round=1 · P3 (Spec): sob o prefixo, a porta do admin ignora as portas do registro compartilhado e só pula as em uso agora — o app da prova pode pegar a porta de um projeto real parado e colidir se ele subir durante a prova.
- Review round=1 · P3 (Spec): sob o prefixo, o log diz "subindo a infra compartilhada" (`infra.sh`) — quem lê a saída da prova acha que a infra real subiu.
- Review round=1 · P3 (Spec): o cabeçalho do `proof.sh` diz que "todo infra.sh que eles rodam usa a infra do prefixo", o que só vale para o `infra.sh` desta versão — um `infra.sh` anterior, da instalação de usuário, ignora o prefixo (risco já passado ao ticket 09).
- Review round=1 · P3 (Spec): a foto da infra compartilhada na S1 pega a rede `anvil-net` só pelo id e pela data — um container novo ligado a ela passaria sem ser visto, embora o diff dos containers do compose cubra o caso que importa.
- Review round=1 · P3 (Standards): o comentário do `infra.sh` cita `(ADR-0017)` sem "do anvil", num arquivo em que `ADR-0001` e `ADR-0003` são da série do bench — quem segue o id procura na série errada.
- Review round=1 · P3 (Standards): `"subindo a infra compartilhada..."` sai também sob o prefixo — o log de uma prova sugere que a infra compartilhada foi tocada.
- Review round=1 · P3 (Standards): `if $TEARDOWN` aparece na validação e no fluxo principal do `infra.sh` (Repeated Switches) — uma pré-condição nova da derrubada tem dois lugares possíveis.
- Review round=1 · P3 (Standards): o sufixo `-anvil-infra` está escrito em `COMPOSE_PROJECT` e em `INFRA_DIR` (Duplicated Code) — renomear um e esquecer o outro separa o registro do projeto do compose; `INFRA_DIR="$PROJECTS_DIR/.$COMPOSE_PROJECT"` resolve.
- Review round=1 · P3 (Standards): o comentário do compose da infra ainda diz `(name: anvil-net)`, e o campo agora é `${ANVIL_NETWORK:-anvil-net}` — a frase seguinte corrige, sem quem construa errado.
- Review round=1 · P3 (Standards): o cabeçalho do `proof.sh` fixa `~/projects/.<prefixo>-anvil-infra/`, que ignora o `ANVIL_PROJECTS_DIR`, e a regra de nomes está escrita também na ajuda do `infra.sh`, no `INVARIANTS.md` e no ticket (Shotgun Surgery) — mudar o nome do registro exige quatro edições, e o comentário erra com o `ANVIL_PROJECTS_DIR` sobrescrito.
