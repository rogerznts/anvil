# 01: As rules deste repositório descrevem o fluxo por spec e os dois sentidos de `references/`

**What to build:** Um agente aberto neste repositório sabe, pela rule do projeto, que trabalho com spec vai num branch `{tipo}/{NNN}-{nome}`, fechado com archive e merge local na `main`, sem PR, e que trabalho sem spec vai direto na `main`. E sabe que `references/` guarda dois tipos de coisa: upstream vendorizado, que é submodule com pin e base do merge 3-way, e sistema de referência, que entra passageiro, fora do git, ou versionado.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] A rule do projeto descreve o fluxo git por branch de spec, com archive e merge local na `main`, sem PR, e o trabalho sem spec indo direto na `main`.
- [x] A rule deixa de dizer que a guarda de merge nunca vale neste repositório.
- [x] A tabela de fonte e derivado distingue upstream vendorizado de sistema de referência, com os termos do glossário.
- [x] O `verify` sai limpo.

## Comments

**Leader, 2026-09-13 — resolvido.** Entrega do Dev em `771082a`. Gate Review: APROVADO, sem
bloqueante (verify limpo; `mosk` fora de `sources:` e `multiagent-config` no exclude local
conferidos; o contorno da guarda descrito na rule está correto hoje). Sem gate de Tester: o
ticket muda só texto de rule.

Os achados não bloqueantes do Review vão para o ticket 13, que reescreve o mesmo parágrafo:
**P1** a rule diz merge local sem PR e o perfil do tracker manda `/tea-open-pr`; **P2** o critério
da guarda repetido na rule; **P3** `mosk` sem glosa, `unlazy` descrito como skill, e a abertura
da rule ainda tratando todo `references/` como upstream.
