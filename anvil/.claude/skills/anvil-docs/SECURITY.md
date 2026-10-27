# Verbo `security` — gravar o registro da auditoria

Deriva de uma execução da `anvil-security-audit` o registro da auditoria, em
`docs/security/`. O registro diz que a auditoria aconteceu, sobre que commit, com
que perfil, quanto foi coberto e quantos achados houve; o detalhe de cada achado
fica no diretório da execução, fora do git. Um achado `confirmed` versionado é uma
vulnerabilidade divulgada antes da correção (ADR-0015 do anvil).

## Quando

Depois de uma execução da auditoria, com o diretório dela à mão:
`~/security-audit-skill/<repo>/run-<N>`, ou o que a execução usou.

## Argumento

O diretório da execução. O nome dele termina em `run-<N>`, e é desse `<N>` que o
registro tira o nome.

## Rodar

Da raiz do projeto auditado:

```bash
node ~/.claude/skills/anvil-docs/scripts/audit-record.cjs <diretório da execução>
```

O registro sai do script, e não da sua redação: a garantia de que nada vaza
depende de quais campos são lidos, e isso o código impõe. Não escreva, complete
nem corrija o registro à mão, e não abra os relatórios da execução para
enriquecê-lo.

O script sai com `0` e a linha `record: docs/security/audit-<data>-run-<N>.md`, ou
com `2` e uma linha `refusal:` por problema. Na recusa, nada é gravado: mostre as
linhas ao usuário como vieram, e pare.

## Recusas

| caso | o que sai |
|---|---|
| fora de um repositório git | `refusal: fora de um repositório git` |
| argumento ausente, que não é diretório, ou cujo nome não é `run-<N>` | a linha `refusal:` com o motivo |
| falta `run-metadata.json`, `findings.json` ou `coverage-ledger.json` | uma linha `refusal: falta <arquivo> em <diretório>` por arquivo |
| a `anvil-security-audit` não está instalada ao lado do `anvil-docs` | a linha `refusal:` com o caminho do validador que falta |
| o `validate-findings.cjs` ou o `validate-coverage-ledger.cjs` sai diferente de `0` | `refusal: <validador> saiu com <código> sobre <arquivo>`, seguida da saída do validador |
| um campo lido do `run-metadata.json` falta ou foge do esperado | `refusal: run-metadata.json: <campo> deve ser <o esperado>` |

Os validadores são os da `anvil-security-audit` instalada, rodados sobre os
arquivos da execução antes de qualquer leitura para o registro.

O que o `run-metadata.json` precisa ter, porque o upstream não fixa a forma:

- `run_id` e, com `run_status` `incomplete`, `incomplete_reason`: uma ficha sem
  espaço, como `validation_budget_exhausted`. Texto livre é recusado, porque
  pode nomear um arquivo.
- `source_ref.commit`: o SHA do commit auditado, em hexadecimal.
- `source_ref.dirty`: `true` ou `false`.
- `profile`: `quick`, `standard` ou `deep`.
- `run_status`: `complete`, `incomplete` ou `in_progress`.

## O que o registro leva

O script lê só esta lista branca, e nenhum outro campo:

| arquivo | campos |
|---|---|
| `run-metadata.json` | `run_id`, `source_ref.commit`, `source_ref.dirty`, `profile`, `run_status` e, só com `incomplete`, `incomplete_reason` |
| `coverage-ledger.json` | o `status` de cada unidade, para contar |
| `findings.json` | de cada registro, o `fingerprint`, o `verdict` e o `severity.overall_severity`, que só o `confirmed` tem |

Com eles, o registro traz:

- o id da execução e o caminho absoluto do diretório dela;
- o commit auditado e se a árvore estava suja;
- o perfil;
- o estado da execução e, se incompleta, o motivo;
- a contagem de unidades do coverage ledger por estado, com o total;
- a contagem de achados por veredito, e dos `confirmed` por severidade;
- uma linha por achado, na ordem do `findings.json`, com o fingerprint, o
  veredito e a severidade.

## O que o registro nunca leva

- caminho de código, inclusive o escopo da execução, que é uma lista de caminhos;
- trecho de fonte, título, descrição, causa raiz, condição, comando, payload,
  reprodução ou correção de qualquer achado;
- o id, a superfície, a fronteira ou qualquer outro campo de unidade do ledger,
  além do estado;
- nada do `REPORT.md`, do `FINDINGS-DETAIL.md` nem do `NEEDS-VALIDATION.md`, que o
  script nunca abre.

## Nome e substituição

`docs/security/audit-<data>-run-<N>.md`, com `<data>` a data UTC do registro e
`<N>` do nome do diretório da execução. Se já existe em `docs/security/` um
registro com o mesmo `-run-<N>.md`, ele é substituído no lugar, com o nome que
tinha: cada execução tem um registro só.

`docs/security/` nasce no primeiro registro, criado pelo script.
