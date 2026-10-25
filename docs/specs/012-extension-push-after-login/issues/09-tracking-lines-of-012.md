# 09: O acompanhamento fecha as linhas da 012

**Blocked by:** 03, 04, 05

**Status:** ready-for-agent

**What to build:** as linhas que a 012 resolve saem de `docs/project/acompanhamento.md`
no branch da spec, como manda o cabeçalho do arquivo, e a poda de cache de build da
issue #8, que ficou fora do toolkit, entra como linha nova.

- [ ] A A35, a A36 e a A37 saem da seção da 011, e o parágrafo de origem dela deixa
      de citá-las.
- [ ] A A29 sai da seção da 010, que continua com a A27 e a A28.
- [ ] Uma seção nova, com origem na issue #8, ganha a **A38 · cache de build sem
      poda entre verificações**, na forma das outras linhas: de onde veio, o que
      acontece se ninguém mexer, e que a poda é do comando de verificação de cada
      projeto.
- [ ] Nenhuma outra linha muda.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
