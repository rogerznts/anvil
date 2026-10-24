# 09: O B1 do bench com a stack de verdade e o vermelho do caso R

**Blocked by:** 02, 04

**Status:** resolved
**Review:** round=1; sha=62e0026; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Standards): o critério de N e E sai marcado, mas o N reprovou em `b1.out` com o texto final pelo caminho `~/.claude/skills/anvil-stack-payload` sem link, contado como `1` e não como `2` de ambiente pelo ADR-0017, e o placar de N com o texto de hoje é 1 de 2 — quem lê só a caixa toma N como provado; a falha está só na Observação.
- Review round=1 · P2 (Standards): a regra nova do `anvil-bench` — a mudança pedida espera a spec aberta fechar — é decisão de produto sem registro na spec 010 nem em ADR, só com "o operador decide se ela fica" — no archive, a decisão fica perdida num comentário de ticket.
- Review round=1 · P3 (Standards): "Essa mudança não tem entrevista nesta vez, nem depois da construção" guia pela proibição (Negation do `anvil-writing-for-agents`) — pode deixar a entrevista mais lembrada, embora a metade positiva esteja ao lado e a medição dê 3 de 3.
- Review round=1 · P3 (Standards): a abertura nova de *Evoluir* repete a regra de *2. Reconhecer* (Duplicated Code, fonte única do Pruning) — mudar a regra exige duas edições; a medição sustenta a repetição (2 de 3 sem ela).
- Review round=1 · P3 (Standards): "a vez" e "nesta vez" só aparecem nesse trecho da skill, sem definição (possível Mysterious Name) — um modelo pode ler "vez" como turno, e não como a chamada inteira do bench.
- Review round=1 · P3 (Standards): no `b1.sh`, `ok`, `nok`, `checa`, `fatos` e `infra_foto` são cópias da 58 e da 64 (possível Duplicated Code) — um conserto na foto da infra compartilhada se repete em cada prova; a `infra_foto` caberia no helper.
- Review round=1 · P3 (Standards): "antes" é a função `antes()`, o `$ANTES` e o `FASE2=antes` no `b1.sh` (possível Mysterious Name) — quem mantiver o script confunde os três.
- Review round=1 · P3 (Standards): as âncoras literais de `texto_antes` (`"\nProjeto novo:"`, `"\n- A entrevista cobre"`) prendem o `b1.sh` à prosa da skill (possível Shotgun Surgery) — mudar o texto quebra o vermelho, com mensagem clara.
- Review round=1 · P2 (Spec): com o texto de HEAD, N deu verde 1 vez em 2 e o `b1.out` final sai `1`, e no `b1-comando` o N rodou o `infra.sh` velho de `workspace/22-distill-url-tester/` com `--provision`, e a história 19 se manteve só porque o slug já estava registrado — rodar o B1 de novo não dá verde reproduzível em N; o prior art da 58 (symlinks temporários em `~/.claude/skills`) não aparece como opção no `## Comments`.
- Review round=1 · P2 (Spec): o `6650850` vai além do critério ao decidir que a mudança pedida fica para outra ativação e que a entrega avisa, sem registro na spec 010, e a prova não confere a frase do adiamento (presente nas três entregas finais) — quem lê a spec não sabe que o bench mudou, e a decisão pendente fica sem dono.
- Review round=1 · P3 (Spec): `b1-red-colheita` é descrito como "o mesmo desfecho", mas a sessão foi à `main`, escreveu o briefing e o checklist lá e perguntou sem ❓, e não tem `verdict.txt` — são 6 vermelhos com veredito do helper, não 7, e o vermelho continua firme.
- Review round=1 · P3 (Spec): "com um pedido igual ao ticket 02… também (`b1-r.out`…)" cita uma saída da fase 2 de hoje — o vermelho que construiu com esse pedido não está no disco.
- Review round=1 · P3 (Spec): "(`b1-comando*`; o vermelho pulou a busca)" chama de vermelho o verde que falhou em `b1-comando-3` — quem lê confunde as duas rodadas.
- Review round=1 · P3 (Spec): rodar os casos um por vez evita colisão de porta entre os casos, mas não o P3 do ticket 04, a colisão com um projeto real parado que suba durante a prova, e o comentário sugere que resolve.
- Operador · a regra nova do `anvil-bench` fica — com spec aberta, a mudança pedida
  espera a spec fechar, sem entrevista nesta vez, e a entrega avisa — e foi
  registrada na spec 010 (história 33 e a decisão "Mudança pedida com spec aberta,
  no bench"). O N sem verde reproduzível passa ao ticket 10, que faz o helper
  recusar com `2` quando as skills chamadas por `~/.claude/skills/` não estão
  ligadas a esta árvore e refaz o N.
