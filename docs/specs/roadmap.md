# Roteiro

## security-audit-vendor

Tipo: feature
Depende de:
Spec: 013

Entra: o upstream `cloudflare/security-audit-skill` como submodule em `references/`, com a fonte em `sources:` e a skill em `skills:` do `anvil-skills.yaml`; a pasta `skills/security-audit/` inteira vendorizada pelo `vendor-sync.sh vendor` como `anvil-security-audit`, com os `*.test.cjs`, sem `invocable`; um `VENDOR.md` em `keep:` com a origem e o aviso da licença MIT; a skill no roster do `dev-link.sh`; o ADR-0015 e a documentação do anvil que lista as skills.
Fica de fora: qualquer mudança no conteúdo do upstream fora do catálogo de adaptação, incluindo o diretório de saída da auditoria; o `README.md` da raiz do upstream; a sugestão da auditoria no `anvil-boot`; checklist de segurança como capacidade de stack.
Pronto quando: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0, `node --test` sobre os `*.test.cjs` da cópia em `anvil/.claude/skills/anvil-security-audit/` passa, e `anvil-security-audit` aparece ligada em `~/.claude/skills/` depois do `dev-link.sh`.

## security-audit-record

Tipo: feature
Depende de: security-audit-vendor
Spec: 014

Entra: o verbo `security` do `anvil-docs`, que lê o `run-metadata.json`, o `coverage-ledger.json` e o `findings.json` de uma execução da auditoria e grava o registro da auditoria em `docs/security/audit-<data>-run-<N>.md`: commit e perfil auditados, cobertura declarada e lacunas, contagem por veredito e severidade, uma linha por achado com id e severidade, e o caminho do diretório da execução; o `docs/security/` como domínio do `anvil-docs`, listado pelo verbo `index`.
Fica de fora: copiar para o repositório o `REPORT.md`, o `FINDINGS-DETAIL.md`, o `NEEDS-VALIDATION.md`, caminho de código ou reprodução de qualquer achado; abrir spec de correção a partir de um achado; nível de detalhe configurável por projeto.
Pronto quando: dados um `findings.json` e um `coverage-ledger.json` de exemplo que passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, o verbo `security` grava o registro em `docs/security/` sem caminho de código nem reprodução de nenhum achado, e o verbo `index` o lista no `docs/index.md`.

## security-audit-record-metadata

Tipo: extension
Depende de: security-audit-record

Entra: o verbo `security` deixa de recusar a execução pela forma dos campos de apresentação do `run-metadata.json`. Do `source_ref`, aceito como objeto com os nomes comuns (`commit`, `sha` ou `revision`; `dirty` ou `worktree_dirty`) ou como string, o script extrai só um SHA hexadecimal e um booleano; o que não reconhecer sai no registro como "não declarado em forma reconhecível". O `run_id` e o `incomplete_reason` só entram no registro quando são ficha de letras, dígitos, `-` e `_`, e senão saem como "não exibido". O `SECURITY.md` descreve as novas regras.
Fica de fora: as recusas por arquivo faltando e por validador do upstream saindo diferente de 0, que continuam; tirar o commit do `git` do repositório na hora do registro; rodar uma auditoria real; qualquer campo novo no registro.
Pronto quando: sobre execuções de exemplo que passam nos dois validadores da cópia vendorizada, com o `source_ref` como objeto de nomes alternativos, como string com SHA, como string sem SHA e ausente, e com `run_id` contendo `.` e `:`, o verbo `security` grava o registro em todas, mostra o SHA quando existe, marca o que não reconheceu, e nenhum texto do `source_ref` além do SHA, nem o `run_id` fora de ficha, aparece no registro.
