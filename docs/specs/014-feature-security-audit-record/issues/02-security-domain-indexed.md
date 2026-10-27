# 02: `docs/security/` é domínio canônico e o índice lista os registros

**What to build:** `docs/security/` entra no `anvil-docs` como domínio canônico que nasce no primeiro registro: na árvore canônica, na tabela de quem escreve onde, nos domínios base do verbo `index`, nos domínios aceitos pelo `validate.sh docs-paths` e no gatilho do `adopt`. O verbo `security` termina rodando o `index`, e o `docs/index.md` lista o registro gravado. Ver a spec, "Implementation Decisions".

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=4f93665; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=e8ab4e5; scope=diff:4f93665..e8ab4e5; verdict=pass; p1=none

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
- Review round=1 · P1 (Spec): a prova do quarto critério não se reproduz — o `scenario.cjs` apaga e recria `./project` a cada execução e não roda o `index`, então o `docs/index.md` citado no comentário some na reprodução oficial, e o `[x]` do critério fica sem observação que o próximo revisor consiga repetir.
- Review round=1 · P2 (Standards): o quarto critério tem prova mais fraca que os outros — o `docs/index.md` gerado à mão não está no disco depois de rodar o cenário, e quem revisa depois tem de confiar na descrição em vez de inspecionar o resultado.
- Review round=1 · P3 (Standards): possível Shotgun Surgery — um domínio canônico novo exige editar seis arquivos do `anvil-docs` (`ADOPT.md`, `INDEX.md`, `SECURITY.md`, `SKILL.md`, `validate.sh`, `templates/docs-index.md`); é o padrão que já existia, e o próximo domínio vai pagar o mesmo custo.
- Review round=1 · P3 (Spec): a chamada ao `index` no `SECURITY.md` é uma frase solta, enquanto o `ARCHIVE.md` dá ao índice uma seção numerada própria — forma divergente entre verbos irmãos, sem efeito no comportamento.
- Correção da rodada 1 · o cenário virou três passos que não se apagam entre si: `node workspace/07-security-index/scenario.cjs` monta `./project`, com o registro, e `./project-bare`, o mesmo projeto antes do registro, sem `docs/security/`; o verbo `index` roda nos dois seguindo o `INDEX.md`; `node workspace/07-security-index/scenario.cjs check-index` confere que o `docs/index.md` de `./project` tem o link `./security/` e lista `./security/audit-<data>-run-3.md`, e que o de `./project-bare` não cita `./security/`. Rodar o primeiro passo de novo apaga os dois índices, e o comentário do topo do script diz isso. Antes do `index`, o `check-index` falha com `ENOENT` no `docs/index.md`.
- Correção da rodada 1 · o `index` desta prova rodou num agente novo, só com o `INDEX.md` e o template do worktree, e o `check-index` saiu `ok`. O que ele gerou em `./project`, no "Visão geral" e no "Conteúdo por domínio": `- **[Security](./security/)** — registros das auditorias de segurança` e `- [audit-2026-10-27-run-3.md](./security/audit-2026-10-27-run-3.md) — registro da execução run-3 (perfil standard, árvore limpa): 3 achados (1 confirmed/medium, 1 needs_validation, 1 rejected) sobre 2 unidades planned no coverage ledger.` Em `./project-bare`, o "Visão geral" tem só `Architecture`, e o "Conteúdo por domínio" fica vazio.
