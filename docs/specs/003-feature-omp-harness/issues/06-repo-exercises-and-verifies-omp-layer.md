# 06: O repositório do anvil exercita e confere a camada

**What to build:** Quem mantém o anvil desenvolve usando a própria camada omp, e a camada não apodrece em silêncio. O `dev-link.sh` liga a camada do payload no `.omp/` deste repositório, e o `vendor-sync verify` passa a conferir a camada como já confere os agentes.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] O `dev-link.sh` liga cada arquivo da camada no `.omp/` deste repositório, e o `--unlink` desfaz sem tocar em arquivo do `.omp/` que não veio da camada.
- [ ] O `verify` confere, na camada: nome do frontmatter igual ao do arquivo ou da pasta; todo caminho citado existe; toda skill em `autoloadSkills` existe no payload e não tem trava de invocação.
- [ ] Cada checagem falha num fixture quebrado de propósito e passa no payload real.
- [ ] O `verify` sai limpo neste repositório.
