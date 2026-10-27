# 01: O verbo `security` grava o registro da auditoria

**What to build:** `/anvil-docs security <diretório da execução>` confere a execução com os validadores da `anvil-security-audit` e, se passa, grava em `docs/security/audit-<data>-run-<N>.md` o registro da auditoria derivado por um script Node do `anvil-docs`, que lê só a lista branca de campos da spec. O registro traz o commit e a árvore auditados, o perfil, o estado da execução, a contagem de unidades do ledger por estado, a contagem de achados por veredito e dos `confirmed` por severidade, uma linha por achado com fingerprint, veredito e severidade, e o caminho do diretório da execução. Ver a spec, "Implementation Decisions".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] O verbo `security` está na tabela de verbos do `anvil-docs`, com o arquivo próprio do verbo descrevendo argumento, recusas, o que o registro leva e o que nunca leva.
- [ ] Sobre um diretório de exemplo cujo `findings.json` e `coverage-ledger.json` passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, com pelo menos um achado de cada veredito e caminhos, trechos de fonte e reprodução preenchidos, o verbo grava o registro em `docs/security/`.
- [ ] Nenhum valor de caminho, trecho de fonte, título, descrição, comando ou reprodução de achado do exemplo aparece no registro gravado, nem id de unidade do ledger.
- [ ] Faltando um dos três arquivos, o verbo recusa dizendo qual, e nada é gravado.
- [ ] Com um validador saindo diferente de `0`, o verbo recusa com a saída dele, e nada é gravado.
- [ ] Registrar de novo a mesma execução substitui o registro dela, sem criar um segundo arquivo para o mesmo `run-<N>`.
- [ ] O script não lê nem copia o `REPORT.md`, o `FINDINGS-DETAIL.md` ou o `NEEDS-VALIDATION.md`.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
