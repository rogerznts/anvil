# 02: `docs/security/` é domínio canônico e o índice lista os registros

**What to build:** `docs/security/` entra no `anvil-docs` como domínio canônico que nasce no primeiro registro: na árvore canônica, na tabela de quem escreve onde, nos domínios base do verbo `index`, nos domínios aceitos pelo `validate.sh docs-paths` e no gatilho do `adopt`. O verbo `security` termina rodando o `index`, e o `docs/index.md` lista o registro gravado. Ver a spec, "Implementation Decisions".

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A árvore canônica e a tabela "Quem escreve onde" do `anvil-docs` trazem `security/`, escrito pelo verbo `security`, marcado como domínio que uma skill cria no primeiro uso.
- [ ] O verbo `index` trata `security/` como domínio base: gera o link quando a pasta existe, não gera quando não existe, e lista os registros no conteúdo por domínio.
- [ ] `bash ~/.claude/skills/anvil-docs/scripts/validate.sh docs-paths` não reclama de `docs/security/`, e um `docs/security/` sozinho não dispara o gatilho do `adopt`.
- [ ] Num projeto de exemplo, depois do verbo `security` sobre a execução de exemplo do ticket 01, o `docs/index.md` lista o registro em `docs/security/`.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
