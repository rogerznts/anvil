# 05: Prova: limpeza e bench seguem com `refusal: forge:`

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** a A37 do acompanhamento. A US 36 da 011 diz que a limpeza de
branches e o bench não param por uma recusa de forge, porque só precisam do branch
base. Nenhuma prova tem vermelho para isso. Esta prova mostra a limpeza atualizando
o branch base e o bench escrevendo a seção `## Git` sem a linha `forge:`, com o
resolvedor dando `refusal: forge:`. Se a prova mostrar que o texto não faz isso,
corrija a skill neste ticket.

- [x] Prova S2 pelo helper, com `/skill:anvil-prune-branches` e `--remote`, num
      diretório novo de `workspace/`, com `workspace/74-fast-pr-prune/` como prior
      art: fixture com remoto num host desconhecido e sem a seção, com a
      `refusal: forge:`. A limpeza segue e atualiza o branch base.
- [x] Prova S2 pelo helper do bench escrevendo a seção `## Git`, com
      `workspace/78-bench-git-section/` como prior art, com a `refusal: forge:`: a
      seção sai com a linha `branch base:` e sem a linha `forge:`.
- [x] Vermelho das duas: o payload de `179bc78`, de antes do ticket 11 da 011, em
      que a recusa para a skill. O código do helper sai nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: as duas skills já seguem com a recusa de forge; nenhuma mudança
  no payload foi necessária. A prova cobre a A37 — limpeza de branches e bench
  seguindo apesar de uma recusa de forge — e a US 36 da 011 — consumidores que só
  precisam do branch base não param por outro campo recusado.
- Provas S2 em `workspace/86-prune-and-bench-refused-forge/s2.sh`, com
  `CASO=prune` e `CASO=bench`, pelo helper real e modelo `claude-sonnet-4-5`,
  confirmado nos `verdict.txt`. Prior art: `workspace/74-fast-pr-prune/s2.sh` e
  `workspace/78-bench-git-section/b1.sh`. Fixtures sem a seção `## Git`, com remoto
  no host desconhecido `git.loja.test`: no verde o resolvedor dá o branch base,
  a `refusal: forge:`, nenhuma linha `forge:` e código `2`.
- Limpeza: `/skill:anvil-prune-branches`, helper com `--remote --forge` e
  dependência `anvil-docs`. O origin SSH usa transporte de fixture para o bare do
  helper. O master local começa atrás do remoto, que mesclou e apagou o
  `feature/velho`; o `feature/vivo` permanece. Verde (`s2-prune.out`): fetch com
  prune, pull atualizando o master até o commit remoto e exclusão segura do
  `feature/velho`; `feature/vivo` preservado, árvore limpa, bare inalterado e log do
  forge vazio; código do helper `0`. Vermelho (`s2-red-prune.out`): para após o
  resolvedor, master não atualizado e `feature/velho` preservado; quatro falhas,
  código do helper `1`.
- Bench: `/skill:anvil-auto --bench` conduz as fases iniciais reais do bench, pois
  a escrita da seção a partir do resolvedor é o ramo sob o piloto, num repositório
  existente. Helper com `--infra` e dependências `anvil-bench`,
  `anvil-stack-payload` e `anvil-docs`; fixture no main com os perfis do tracker e
  da verificação. Verde (`s2-bench.out`): passa a largada, lê `skill://anvil-bench`,
  provisiona a infra isolada e roda o resolvedor; a fase 2 copia o starter, gera a
  rule da stack e escreve `## Git` com `branch base: main`, sem `forge:`, mantendo
  Comunicação e `pt-BR.`. O resolvedor lê a seção escrita e ainda recusa só o
  forge; HEAD inalterado, como manda o bench sob o piloto; código do helper `0`.
  Vermelho (`s2-red-bench.out`): o `stage.sh` dá base indisponível pela recusa e o
  piloto para na largada, antes de carregar o bench; nenhuma seção é escrita;
  sete falhas, código do helper `1`. Esse vermelho não isola a fase 2 do bench.
- Vermelho das duas com o payload inteiro de `179bc78`, anterior ao ticket 11 da
  011 — resolvedor com recusas por campo e consumidores parando só no campo
  necessário — materializado por `git checkout 179bc78 -- anvil` e restaurado com
  `git checkout HEAD -- anvil` antes do verde. O resolvedor antigo só dá a recusa,
  sem o branch base e sem o prefixo de campo: uma falha em cada vermelho é essa
  diferença do contrato, além das falhas de comportamento declaradas acima.
- Verificação: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`
  saiu `0`; `workspace/86-prune-and-bench-refused-forge/verify.out` registra
  `verify: limpo` e `exit: 0`. Provas e saídas ficam em `workspace/`, fora do git,
  conforme as rules do projeto.
