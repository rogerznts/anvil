# 09: O acompanhamento fecha as linhas da 012

**Blocked by:** 03, 04, 05

**Status:** resolved
**Review:** round=1; sha=fca185e0ae3d56438ac562a420dac0fdf979e3e4; scope=full; verdict=pass; p1=none

**What to build:** as linhas que a 012 resolve saem de `docs/project/acompanhamento.md`
no branch da spec, como manda o cabeçalho do arquivo, e a poda de cache de build da
issue #8, que ficou fora do toolkit, entra como linha nova.

- [x] A A35, a A36 e a A37 saem da seção da 011, e o parágrafo de origem dela deixa
      de citá-las.
- [x] A A29 sai da seção da 010, que continua com a A27 e a A28.
- [x] Uma seção nova, com origem na issue #8, ganha a **A38 · cache de build sem
      poda entre verificações**, na forma das outras linhas: de onde veio, o que
      acontece se ninguém mexer, e que a poda é do comando de verificação de cada
      projeto.
- [x] Nenhuma outra linha muda.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: saem do acompanhamento a A29 — os três nomes da parada no
  fechamento —, a A35 — push antes da conferência do login —, a A36 — falta de
  prova da rule antes do forge recusado — e a A37 — falta de prova da limpeza e do
  bench com recusa de forge. O parágrafo da 011 deixa de citá-las; as outras
  linhas ficam intactas. A A38 — cache de build sem poda entre verificações —
  entra com origem na issue #8, o `target/` de 191 GB no `ore`, o risco de disco
  cheio durante a corrente e a poda atribuída ao comando de cada projeto.
- Verificação: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`
  saiu `0` (`verify: limpo`). Alteração só de documentação, sem seam executável
  nova para TDD; não há suíte nem typechecking neste repositório.
