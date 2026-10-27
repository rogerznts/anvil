# 01: O verbo `security` registra a execução com o metadado na forma em que vier

**What to build:** O `audit-record.cjs` deixa de recusar a execução pela forma do `source_ref`, do `run_id` e do `incomplete_reason`. Do `source_ref`, objeto ou string, extrai só um SHA e o estado da árvore; o que não reconhecer sai "não declarado em forma reconhecível". O `run_id` e o `incomplete_reason` fora de ficha saem "não exibido". O `SECURITY.md` troca as regras antigas pelas novas. Ver a spec, "Implementation Decisions".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Sobre execuções de exemplo que passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, o verbo grava o registro com o `source_ref` como objeto com `sha`, como objeto com `revision` e `worktree_dirty`, como string com SHA e `dirty`, como string sem SHA e ausente.
- [ ] O registro mostra o SHA quando o `source_ref` traz um, e "não declarado em forma reconhecível" no commit ou na árvore quando não reconhece.
- [ ] Com `run_id` contendo `.` e `:`, e com `incomplete_reason` de texto livre numa execução incompleta, o registro é gravado e esses campos saem "não exibido".
- [ ] Nenhum texto marcador posto no `source_ref`, além do SHA, nem no `run_id` ou no `incomplete_reason` fora de ficha, aparece em nenhum registro gravado.
- [ ] As recusas por arquivo faltando e por validador saindo diferente de `0` continuam, sem gravar nada; `profile` e `run_status` fora dos valores do upstream continuam recusados.
- [ ] O `SECURITY.md` descreve as regras novas, sem resto das antigas.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
