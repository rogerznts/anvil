# 02: `docs/security/` é domínio canônico e o índice lista os registros

**What to build:** `docs/security/` entra no `anvil-docs` como domínio canônico que nasce no primeiro registro: na árvore canônica, na tabela de quem escreve onde, nos domínios base do verbo `index`, nos domínios aceitos pelo `validate.sh docs-paths` e no gatilho do `adopt`. O verbo `security` termina rodando o `index`, e o `docs/index.md` lista o registro gravado. Ver a spec, "Implementation Decisions".

**Blocked by:** 01

**Status:** resolved

- [x] A árvore canônica e a tabela "Quem escreve onde" do `anvil-docs` trazem `security/`, escrito pelo verbo `security`, marcado como domínio que uma skill cria no primeiro uso.
- [x] O verbo `index` trata `security/` como domínio base: gera o link quando a pasta existe, não gera quando não existe, e lista os registros no conteúdo por domínio.
- [x] `bash ~/.claude/skills/anvil-docs/scripts/validate.sh docs-paths` não reclama de `docs/security/`, e um `docs/security/` sozinho não dispara o gatilho do `adopt`.
- [x] Num projeto de exemplo, depois do verbo `security` sobre a execução de exemplo do ticket 01, o `docs/index.md` lista o registro em `docs/security/`.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Implementação · `security/` entrou no `CANONICAL` do `validate.sh`, na lista "Conforme" do `ADOPT.md` (que é a lista de domínios canônicos do gatilho), na árvore e na tabela "Quem escreve onde" do `SKILL.md` com `◆`, no passo 2 do `INDEX.md` e no "Visão geral" do `templates/docs-index.md`. O `SECURITY.md` termina rodando o `index`, e o "Quem chama" do `INDEX.md` e a linha do `index` na tabela de verbos nomeiam o verbo `security`. O `scaffold` lista `security/` entre as pastas que não nascem com ele.
- Implementação · os seams foram os da spec ("Testing Decisions"): o verbo `security` sobre uma execução de exemplo, observando o registro gravado e o `docs/index.md`, e a saída do `validate.sh docs-paths`. A prova é o cenário manual `workspace/07-security-index/scenario.cjs`, fora do git: monta um projeto git e a execução `run-3` com as fixtures `confirmed()`/`needsValidation()`/`rejected()` e `unit()` do upstream, com os campos livres marcados `LEAK`; confere que o `docs-paths` sai `0` antes do registro e depois dele, que uma `docs/stories/` ainda reclama, e que nada `LEAK` chega ao registro. Antes da mudança, o cenário falhava com `pasta fora dos domínios: docs/security/`.
- Implementação · o `index` é verbo do modelo, sem script: a prova do quarto critério é o `docs/index.md` gerado pelo `INDEX.md` no projeto do cenário, com `[Security](./security/)` no "Visão geral" e a linha do `audit-<data>-run-3.md` em "Conteúdo por domínio".
- Fora do ticket · o `templates/issue-tracker-anvil.md` e o `docs/agents/issue-tracker.md` enumeram a árvore em "Onde os outros documentos moram" sem `security/`; a lista manda chamar o `anvil-docs`, que agora traz o domínio, e ficou como estava.
