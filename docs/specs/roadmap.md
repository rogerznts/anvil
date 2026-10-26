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

Entra: o verbo `security` do `anvil-docs`, que lê o `run-metadata.json`, o `coverage-ledger.json` e o `findings.json` de uma execução da auditoria e grava o registro da auditoria em `docs/security/audit-<data>-run-<N>.md`: commit e perfil auditados, cobertura declarada e lacunas, contagem por veredito e severidade, uma linha por achado com id e severidade, e o caminho do diretório da execução; o `docs/security/` como domínio do `anvil-docs`, listado pelo verbo `index`.
Fica de fora: copiar para o repositório o `REPORT.md`, o `FINDINGS-DETAIL.md`, o `NEEDS-VALIDATION.md`, caminho de código ou reprodução de qualquer achado; abrir spec de correção a partir de um achado; nível de detalhe configurável por projeto.
Pronto quando: dados um `findings.json` e um `coverage-ledger.json` de exemplo que passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, o verbo `security` grava o registro em `docs/security/` sem caminho de código nem reprodução de nenhum achado, e o verbo `index` o lista no `docs/index.md`.
