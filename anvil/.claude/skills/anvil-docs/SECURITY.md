# Verbo `security` — gravar o registro da auditoria

Deriva de uma execução da `anvil-security-audit` o registro da auditoria, em
`docs/security/`. O registro diz que a auditoria aconteceu, sobre que commit, com
que perfil, quanto foi coberto e quantos achados houve; o detalhe de cada achado
fica no diretório da execução, fora do git. Um achado `confirmed` versionado é uma
vulnerabilidade divulgada antes da correção (ADR-0019 do anvil).

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

Gravado o registro, rode o verbo [`index`](INDEX.md), que o lista no domínio
`security/` do `docs/index.md`.

## Recusas

| caso | o que sai |
|---|---|
| fora de um repositório git | `refusal: fora de um repositório git` |
| argumento ausente, que não é diretório, ou cujo nome não é `run-<N>` | a linha `refusal:` com o motivo |
| falta `run-metadata.json`, `findings.json` ou `coverage-ledger.json` | uma linha `refusal: falta <arquivo> em <diretório>` por arquivo |
| a `anvil-security-audit` não está instalada ao lado do `anvil-docs` | a linha `refusal:` com o caminho do validador que falta |
| o `validate-findings.cjs` ou o `validate-coverage-ledger.cjs` sai diferente de `0` | `refusal: <validador> saiu com <código> sobre <arquivo>`, seguida da saída do validador |
| o `profile` ou o `run_status` do `run-metadata.json` falta ou foge dos valores do upstream | `refusal: run-metadata.json: <campo> deve ser <os valores>` |
| o `run-metadata.json` não é JSON legível, ou não é um objeto JSON | a linha `refusal:` com o motivo |

Os validadores são os da `anvil-security-audit` instalada, rodados sobre os
arquivos da execução antes de qualquer leitura para o registro.

## Como o `run-metadata.json` é lido

O upstream enumera o `profile` e o `run_status`, e só eles recusam a execução:

- `profile`: `quick`, `standard` ou `deep`.
- `run_status`: `complete`, `incomplete` ou `in_progress`.

Dos outros campos o upstream não fixa a forma, e nenhum deles recusa a execução:
o que não vier na forma esperada sai marcado no registro.

- `source_ref`, objeto ou string. Dele só entram o SHA do commit auditado e o
  estado da árvore; o resto nunca entra.
  - O SHA é a primeira palavra inteira de 7 a 64 caracteres hexadecimais. Do
    objeto, ela é procurada no primeiro de `commit`, `sha` e `revision` que é
    string; da string, no próprio `source_ref`.
  - A árvore, do objeto, é o primeiro booleano entre `dirty` e `worktree_dirty`;
    da string, a palavra inteira `dirty` dá suja e `clean` dá limpa, e com as
    duas vale `dirty`.
  - Sem SHA, o commit sai `não declarado em forma reconhecível`; sem estado, a
    árvore sai igual. Sem `source_ref`, ou com outro tipo, os dois saem assim.
- `run_id` e, com `run_status` `incomplete`, `incomplete_reason`: entram como
  estão só quando são uma ficha de letras, dígitos, `-` e `_`, como
  `validation_budget_exhausted`. Texto livre, valor com `/`, `.` ou `:`, como um
  carimbo de data e hora, ausência ou outro tipo saem `não exibido`, porque podem
  nomear um arquivo.

## O que o registro leva

O script lê só esta lista branca, e nenhum outro campo:

| arquivo | campos |
|---|---|
| `run-metadata.json` | `run_id`, `profile`, `run_status` e, só com `incomplete`, `incomplete_reason`; do `source_ref`, o `commit`, o `sha` ou o `revision` e o `dirty` ou o `worktree_dirty`, ou a string inteira, de onde só sai o SHA e o estado da árvore |
| `coverage-ledger.json` | o `status` de cada unidade, para contar |
| `findings.json` | de cada registro, o `fingerprint`, o `verdict` e o `severity.overall_severity`, que só o `confirmed` tem |

Com eles, o registro traz:

- o id da execução, ou `não exibido`, e o caminho absoluto do diretório dela;
- o commit auditado e se a árvore estava suja, cada um `não declarado em forma
  reconhecível` quando o `source_ref` não o traz numa forma reconhecida;
- o perfil;
- o estado da execução e, se incompleta, o motivo, ou `não exibido`;
- a contagem de unidades do coverage ledger por estado, com o total;
- a contagem de achados por veredito, e dos `confirmed` por severidade;
- uma linha por achado, na ordem do `findings.json`, com o fingerprint, o
  veredito e a severidade.

O fingerprint entra na linha só quando é ficha de letras, dígitos, `-` e `_`. O
upstream o deriva da fonte e aceita nele `/`, `.`, `:`, `@` e `+`, e um
fingerprint assim pode trazer caminho de código, como `src/auth.c:csrf`: a linha
o mostra como `_oculto, posição <i>_`, com a posição do achado no `findings.json`
da execução, onde ele se acha.

## O que o registro nunca leva

- caminho de código, inclusive o escopo da execução, que é uma lista de caminhos,
  e o fingerprint que pode trazer um;
- trecho de fonte, título, descrição, causa raiz, condição, comando, payload,
  reprodução ou correção de qualquer achado;
- do `source_ref`, nada além do SHA e do estado da árvore, e o `run_id` ou o
  `incomplete_reason` fora de ficha;
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
