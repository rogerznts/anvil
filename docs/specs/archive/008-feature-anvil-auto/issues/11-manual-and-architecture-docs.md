# 11: O manual `anvil-omp` e a arquitetura descrevem o piloto

**Blocked by:** 07, 10

**Status:** resolved
**Review:** round=1; sha=4bad5991ef6502c565b2b84c65c5dcfd293ddc11; scope=full; verdict=pass; p1=none

**What to build:** quem abre o manual da camada omp entende o que está delegando
ao piloto: como chamá-lo (`/skill:anvil-auto`, com `--bench` quando for o caso),
o único sim, o que ele faz sozinho, onde ficam o roteiro e o relatório, e o que
ele nunca faz. Entre o que ele nunca faz estão editar escopo ou critério de uma
entrada, fazer merge de PR, contornar a guarda, despachar em paralelo e rodar
duas execuções no mesmo checkout. A documentação de arquitetura e do projeto
passa a citar o piloto como peça da camada.

- [x] O manual `anvil-omp` ganha a seção do piloto, com a lista "nunca" e a regra
      de uma execução por vez.
- [x] O `docs/architecture/overview.md` cita o `anvil-auto` entre as peças da
      camada omp e aponta o ADR-0014.
- [x] O roster em `docs/project/plan.md` e o comentário da camada em
      `anvil-skills.yaml` incluem o `anvil-auto`.
- [x] O ADR-0014 não muda.
- [x] O índice é regenerado pelo verbo `index`.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Review round=1 · P2 (Spec): o manual `anvil-omp` diz que o `/anvil-bench` chamado direto "constrói a primeira entrada do roteiro" e lista archive e merge "no relatório"; pela spec é a primeira do frontier (a `open` ou a do `next:`) e a lista sai na entrega — quem lê pode achar que outra chamada direta refaz a primeira entrada, e descobre o contrário no primeiro ciclo.
- Review round=1 · P3 (Spec): o parágrafo sobre o `/anvil-bench` chamado direto, em "O que continua manual", não foi pedido pelo ticket — é mais uma cópia do comportamento do bench que precisa mudar junto com ele.
- Review round=1 · P3 (Spec): o manual diz que no bench o `PASS` "é o `--reverify`", sem os tickets `resolved` e a última `Review:` em `verdict=pass; p1=none` que a skill também exige — quem lê pode achar que review reprovada não segura o fechamento no bench; a skill segura.
- Review round=1 · P3 (Spec): o manual cita só a evidência nova e o "uma só por ticket" para a rodada extra, sem o ticket apontado e a ausência de dois sinais de laço — quem lê espera rodada extra onde a spec fica parada.
- Review round=1 · P3 (Spec): o ticket não registra a saída do `vendor-sync.sh verify` (saiu `verify: limpo`, `exit: 0` antes do commit `3bf07ce`) — quem audita precisa rodar de novo.
- Review round=1 · P3 (Standards): `anvil-omp/SKILL.md`, no item do `/skill:anvil-auto` em "Comandos", diz "plano" onde o glossário pede **Roteiro** (`_Avoid_: plano`) — quem lê o comando não o liga ao `docs/specs/roadmap.md` antes da seção.
- Review round=1 · P3 (Standards): `docs/architecture/overview.md` cita "só com `PASS`" sem glosa, e `PASS` não está no `context.md` — quem lê o overview abre o ADR-0014 para saber o que fecha uma spec.
- Review round=1 · P3 (Standards): o reflow do `overview.md` deixou a linha curta "mesmo passo mantém. Ver" — só forma.
- Review round=1 · P3 (Standards): possível Shotgun Surgery — a lista das peças da camada omp vive em cinco lugares (`anvil-skills.yaml`, `plan.md`, `overview.md`, `anvil-omp`, `context.md`); a próxima skill da camada pede as cinco edições, e uma esquecida deixa um roster mentindo. O ticket pede as cópias.
