# 11: O manual `anvil-omp` e a arquitetura descrevem o piloto

**Blocked by:** 07, 10

**Status:** ready-for-agent

**What to build:** quem abre o manual da camada omp entende o que está delegando
ao piloto: como chamá-lo (`/skill:anvil-auto`, com `--bench` quando for o caso),
o único sim, o que ele faz sozinho, onde ficam o roteiro e o relatório, e o que
ele nunca faz. Entre o que ele nunca faz estão editar escopo ou critério de uma
entrada, fazer merge de PR, contornar a guarda, despachar em paralelo e rodar
duas execuções no mesmo checkout. A documentação de arquitetura e do projeto
passa a citar o piloto como peça da camada.

- [ ] O manual `anvil-omp` ganha a seção do piloto, com a lista "nunca" e a regra
      de uma execução por vez.
- [ ] O `docs/architecture/overview.md` cita o `anvil-auto` entre as peças da
      camada omp e aponta o ADR-0014.
- [ ] O roster em `docs/project/plan.md` e o comentário da camada em
      `anvil-skills.yaml` incluem o `anvil-auto`.
- [ ] O ADR-0014 não muda.
- [ ] O índice é regenerado pelo verbo `index`.
- [ ] `vendor-sync.sh verify` sai `0`.
