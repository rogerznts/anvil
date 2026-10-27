# 01: O verbo `security` registra a execução com o metadado na forma em que vier

**What to build:** O `audit-record.cjs` deixa de recusar a execução pela forma do `source_ref`, do `run_id` e do `incomplete_reason`. Do `source_ref`, objeto ou string, extrai só um SHA e o estado da árvore; o que não reconhecer sai "não declarado em forma reconhecível". O `run_id` e o `incomplete_reason` fora de ficha saem "não exibido". O `SECURITY.md` troca as regras antigas pelas novas. Ver a spec, "Implementation Decisions".

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=54d339d; scope=full; verdict=pass; p1=none

- [x] Sobre execuções de exemplo que passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, o verbo grava o registro com o `source_ref` como objeto com `sha`, como objeto com `revision` e `worktree_dirty`, como string com SHA e `dirty`, como string sem SHA e ausente.
- [x] O registro mostra o SHA quando o `source_ref` traz um, e "não declarado em forma reconhecível" no commit ou na árvore quando não reconhece.
- [x] Com `run_id` contendo `.` e `:`, e com `incomplete_reason` de texto livre numa execução incompleta, o registro é gravado e esses campos saem "não exibido".
- [x] Nenhum texto marcador posto no `source_ref`, além do SHA, nem no `run_id` ou no `incomplete_reason` fora de ficha, aparece em nenhum registro gravado.
- [x] As recusas por arquivo faltando e por validador saindo diferente de `0` continuam, sem gravar nada; `profile` e `run_status` fora dos valores do upstream continuam recusados.
- [x] O `SECURITY.md` descreve as regras novas, sem resto das antigas.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Implementação · a prova é o cenário manual `workspace/06-security-record-metadata/scenario.cjs`, fora do git: monta um projeto git e execuções `run-<N>` com os achados de `validate-findings.test.cjs` e a unidade de `validate-coverage-ledger.test.cjs`, confere que passam nos dois validadores, roda o `audit-record.cjs` do payload sobre 22 variantes de metadado — `source_ref` como objeto com `commit`, `sha`, `revision`, `worktree_dirty`, nomes desconhecidos e tipos trocados, como string com SHA e `dirty`/`clean`/sem estado, sem SHA, com hexadecimal longo demais, ausente e de outro tipo; `run_id` com `.` e `:`, ausente e numérico; `incomplete_reason` de texto livre, ausente e em ficha — e confere as linhas do registro e que nenhum `LEAKMARK` aparece em nenhum registro gravado. Confere também as dez recusas que ficam (três arquivos faltando, os dois validadores, `profile` fora e ausente, `run_status` fora, metadado que não é objeto e que não é JSON), cada uma num projeto novo, sem gravar nada.
- Implementação · "palavra inteira" é a fronteira `\b` do JavaScript: o vizinho do SHA não pode ser letra, dígito nem `_`. `abc1234_x` não dá SHA; `run-abc1234` e `src/deadbeef1/x` dão, e só a palavra hexadecimal vai para o registro.
- Observação sobre a spec · a spec não diz o que vale quando a string do `source_ref` tem `dirty` e `clean` ao mesmo tempo. O script segue a ordem em que a spec os cita, e vale `dirty`; o `SECURITY.md` diz isso.
- Review round=1 · P3 (Standards): possível Duplicated Code — no `render()`, a forma "`=== null` ? marca : valor formatado" aparece no `shown()` e de novo, à mão, no commit e na árvore com `NOT_DECLARED` — o próximo campo marcado vira mais uma cópia do mesmo condicional em vez de reusar um helper.
- Review round=1 · P3 (Spec): com `commit` string sem SHA e `sha` com SHA, o script não cai para o `sha`, porque toma o primeiro campo que é string, como a spec manda ("o primeiro de `commit`, `sha` e `revision` que é string") — quem lê o código esperando "o primeiro que traz SHA" se surpreende, sem defeito de contrato.
