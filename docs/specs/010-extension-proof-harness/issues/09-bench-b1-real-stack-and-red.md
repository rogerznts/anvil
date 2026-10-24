# 09: O B1 do bench com a stack de verdade e o vermelho do caso R

**Blocked by:** 02, 04

**Status:** resolved

**What to build:** o B1 da fase 2 do bench roda pelo helper, com `/skill:anvil-bench`
e a stack subindo na infra isolada, sem `docker` falso. O caso R, projeto com spec
aberta, ganha o vermelho que faltou na 009: com o texto da fase 2 de antes, o bench
cai em *Evoluir uma ferramenta*; com o de hoje, segue para a construção da spec
aberta.

- [x] Os casos N, R e E de `workspace/58-bench-profiles/` rodam pelo helper, com a
      opção de infra, num diretório novo de `workspace/`.
- [x] Caso R: o vermelho, medido com o texto da fase 2 do `anvil-bench` de antes da
      009, cai em *Evoluir uma ferramenta*; a fixture e o pedido do turno são
      ajustados até isso acontecer. O verde segue para a construção da spec aberta.
- [x] Casos N e E: o resultado da 009 se mantém, agora com a stack no ar.
- [x] O antes e depois de containers, redes, volumes e registro da infra
      compartilhada mostra que ela não mudou.
- [x] O código do helper sai nas saídas de cada caso, e prova inválida se repete; se
      persistir, o ticket declara o limite com os modelos que responderam.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · prova em `workspace/66-bench-b1-real-stack/b1.sh`: cada caso numa
  execução própria do helper (`proof_prepare --infra`), com
  `/skill:anvil-bench <pedido>` no turno 1 e a vez até assentar, sem corte e sem
  `docker` falso. As fixtures de R e E são as da 58, provisionadas pelo `infra.sh`
  do payload sob prova, sob o prefixo, com a rede no `.env`; o app de cada caso entra
  na rede do prefixo, a limpeza do helper derruba a infra do prefixo e o script
  derruba o compose do app com os volumes (o P2 do ticket 04 — o volume
  `node_modules` que sobra). Os casos rodam um por vez, porque a porta do admin sob
  o prefixo só pula as portas em uso agora (o P3 do ticket 04). O antes e depois de
  containers, rede (com os containers ligados a ela), volumes, bancos e registro da
  infra compartilhada cerca cada rodada, e ficou igual em todas as 24 saídas
  `b1*.out`. Nenhuma sessão deu `3`: todas responderam
  `anthropic/claude-sonnet-4-5`, então nenhuma se repetiu por inválida.
- Implementação · o vermelho (`FASE2=antes`) é o payload de `HEAD` com os trechos da
  busca pela spec aberta do `SKILL.md` do `anvil-bench` trocados pelos de `8c7aa85~1`,
  o pai do commit do ticket 07 da 009: o reconhecimento da fase 2 e a abertura de
  *Evoluir uma ferramenta*. O resto fica o de `HEAD`, com o `infra.sh` que conhece o
  prefixo.
- Implementação · o pedido do turno de R é a manutenção dos equipamentos, o mesmo
  de E. Sem pedido, o texto de antes também constrói (`b1-red-sempedido-off-1.out`,
  código `0`), e com um pedido igual ao ticket 02 em aberto, também
  (`b1-r.out`; a saída do vermelho com esse pedido foi sobrescrita, e ela tinha dado
  código `0`). Com a manutenção, o texto de antes cai em *Evoluir* em todas as sete
  sessões: pergunta ❓ da entrevista do delta, sem construir
  (`b1-red-manutencao-1.out`, `b1-red-manutencao-2.out`, `b1-red-1.out` a
  `b1-red-4.out`, código `1`; `b1-red-colheita.out`, o mesmo desfecho, saiu `2` por
  um defeito do script, já corrigido, que tomava a falha de uma cópia da colheita
  pela da sessão). A fixture também mudou: os `CHECK:` rodam dentro do app
  (`pnpm vitest run …`), como o checker os roda; com o `docker compose exec` da 58, o
  verde reescrevia o ledger.
- Implementação · o texto da 009 não segurava o verde com a mudança pedida: com a
  manutenção no turno, as quatro sessões (`b1-manutencao.out`,
  `b1-manutencao-2.out`, `b1-manutencao-3.out` e, com pensamento `off`,
  `b1-manutencao-off-1.out`) foram à entrevista do delta sem construir, embora a
  fase 2 diga "Antes de qualquer ramo… sem entrevista". Para o verde, o
  `anvil-bench` mudou em três commits: a mudança pedida com spec aberta espera, sem
  entrevista nesta vez, e a entrega diz que ela fica para depois que a spec fechar
  (`6650850`); a busca ganhou o comando que lista os tickets não `resolved` e roda
  também com a mudança pedida (`9a92fef`); e *Evoluir uma ferramenta* abre dizendo
  que só vale sem spec aberta (`d98f724`). Medido: só a espera, 1 verde de 2
  (`b1-r-espera-*`, numa redação anterior) e 1 de 2 (`b1-sem-comando*`); com o
  comando, 2 de 3 (`b1-comando*`; o vermelho pulou a busca); com os três, 3 de 3
  (`b1.out`, `b1-2.out`, `b1-3.out`, código `0` em R): o ticket 02 sai `resolved`,
  o app sobe na rede do prefixo, o ledger roda, e o checklist e o `gates.md` ficam.
  A spec 010 não pedia mudança no `anvil-bench`; o operador decide se ela fica.
- Implementação · E deu `0` nas quatro rodadas (`b1-manutencao.out`,
  `b1-sem-comando.out`, `b1-comando.out`, `b1.out`). N deu `0` em três de cinco
  (`b1-manutencao.out`, `b1-sem-comando.out`, `b1-n-2.out`): o primeiro commit único
  com os dois perfis iguais aos templates, e a alocação no registro do prefixo.
  Nas outras duas, a sessão não achou a stack: o `anvil-bench` chama
  `~/.claude/skills/anvil-stack-payload/bench/env.sh` e `infra.sh`, e nesta máquina
  o `anvil-stack-payload` não está ligado em `~/.claude/skills`; o helper carrega a
  skill pelo `skills.customDirectories`, que não faz o caminho existir. Em
  `b1.out`, a sessão desistiu na preparação; em `b1-comando.out`, ela procurou no
  repositório e rodou o `infra.sh` velho de `workspace/22-distill-url-tester/`, que
  ignora o prefixo e reusou a alocação `equipamentos_ti` da infra compartilhada,
  já registrada desde 16/10 — a conferência "todo `infra.sh` que a sessão rodou é o
  da árvore sob prova" e a da rede no `.env` reprovaram, e o registro e os bancos
  ficaram iguais. O mesmo vale para o checker de `~/.claude/skills/anvil-bench/unlazy/`,
  como nos tickets 05 e 06: nos três verdes finais de R, o primeiro
  `docker compose cp` falhou e o modelo copiou o do payload sob prova.
- Observação · os caminhos da instalação de usuário que o payload cita ficam sem
  destino sob o helper para as skills fora do roster do `dev-link.sh`: ligá-las no
  `dev-link.sh` é da 011; dar à sessão da prova um `HOME` próprio, com os links,
  mudaria o helper, e fica com o operador. Até lá, N depende de o modelo achar a
  fonte, e pode ir a uma cópia velha, que o B1 acusa.
