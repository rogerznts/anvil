# 07: Integração com o toolkit: boot, docs e rules

**Blocked by:** 02
**Status:** claimed

**What to build:** O toolkit passa a conhecer as skills de segurança. O `/anvil-boot`, no passo em que detecta a stack e propõe a rule dela, sugere rodar o `/anvil-security-map`, com uma linha dizendo a stack e se ela tem checklist; recusado, segue normalmente e não grava nada de segurança. O `anvil-docs` passa a conhecer `docs/security/` na árvore e no índice: a pasta nasce quando o map escreve nela, como as demais pastas com escritor. O `.claude/rules/project.md` lista as duas skills entre as autorais.

- [x] Num projeto Payload, o boot sugere o map com a justificativa de uma linha
- [x] Recusada a sugestão, o boot termina sem criar `docs/security/`
- [x] O `anvil-docs` descreve `docs/security/` com `profile.md`, `map.md`, `findings.md` e quem escreve cada um, e o índice gerado lista a pasta quando ela existe
- [x] O `.claude/rules/project.md` lista `anvil-security-map` e `anvil-security-probe` entre as skills autorais
