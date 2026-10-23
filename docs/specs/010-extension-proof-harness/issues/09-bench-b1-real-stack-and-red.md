# 09: O B1 do bench com a stack de verdade e o vermelho do caso R

**Blocked by:** 02, 04

**Status:** ready-for-agent

**What to build:** o B1 da fase 2 do bench roda pelo helper, com `/skill:anvil-bench`
e a stack subindo na infra isolada, sem `docker` falso. O caso R, projeto com spec
aberta, ganha o vermelho que faltou na 009: com o texto da fase 2 de antes, o bench
cai em *Evoluir uma ferramenta*; com o de hoje, segue para a construção da spec
aberta.

- [ ] Os casos N, R e E de `workspace/58-bench-profiles/` rodam pelo helper, com a
      opção de infra, num diretório novo de `workspace/`.
- [ ] Caso R: o vermelho, medido com o texto da fase 2 do `anvil-bench` de antes da
      009, cai em *Evoluir uma ferramenta*; a fixture e o pedido do turno são
      ajustados até isso acontecer. O verde segue para a construção da spec aberta.
- [ ] Casos N e E: o resultado da 009 se mantém, agora com a stack no ar.
- [ ] O antes e depois de containers, redes, volumes e registro da infra
      compartilhada mostra que ela não mudou.
- [ ] O código do helper sai nas saídas de cada caso, e prova inválida se repete; se
      persistir, o ticket declara o limite com os modelos que responderam.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
