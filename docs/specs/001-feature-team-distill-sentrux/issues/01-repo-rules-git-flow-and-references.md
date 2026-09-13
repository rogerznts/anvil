# 01: As rules deste repositório descrevem o fluxo por spec e os dois sentidos de `references/`

**What to build:** Um agente aberto neste repositório sabe, pela rule do projeto, que trabalho com spec vai num branch `{tipo}/{NNN}-{nome}`, fechado com archive e merge local na `main`, sem PR, e que trabalho sem spec vai direto na `main`. E sabe que `references/` guarda dois tipos de coisa: upstream vendorizado, que é submodule com pin e base do merge 3-way, e sistema de referência, que entra passageiro, fora do git, ou versionado.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] A rule do projeto descreve o fluxo git por branch de spec, com archive e merge local na `main`, sem PR, e o trabalho sem spec indo direto na `main`.
- [ ] A rule deixa de dizer que a guarda de merge nunca vale neste repositório.
- [ ] A tabela de fonte e derivado distingue upstream vendorizado de sistema de referência, com os termos do glossário.
- [ ] O `verify` sai limpo.
