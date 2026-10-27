# 015 — O registro da auditoria aceita o metadado como a execução o grava

**Status:** ready-for-agent

Extensão da spec 014 (`docs/specs/archive/014-feature-security-audit-record/`), que
está arquivada e não muda. Entrada `security-audit-record-metadata` do roteiro
(`docs/specs/roadmap.md`). A decisão de arquitetura continua o ADR-0019 — o
versionado é só o registro da auditoria, sem caminho nem reprodução de nenhum
achado.

## Problem Statement

O verbo `security` do `anvil-docs` recusa a execução inteira quando o
`run-metadata.json` não traz o `source_ref` como objeto com `commit` e `dirty`,
ou quando o `run_id` ou o `incomplete_reason` têm `.`, `:` ou outro caractere fora
de letras, dígitos, `-` e `_`. O upstream não fixa nenhuma dessas formas: o
`SKILL.md` da `anvil-security-audit` só diz que o `source_ref` é "o commit
revisado e se a árvore estava suja", e nenhum validador confere o
`run-metadata.json`. O agente que roda a auditoria escolhe a forma, e uma
execução válida — que passa nos dois validadores — pode ser recusada por um
campo que só serve para apresentação.

## Solution

O verbo deixa de recusar pela forma desses campos. Do `source_ref`, aceito como
objeto com os nomes comuns ou como string, o script extrai só um SHA hexadecimal e
um booleano; o que não reconhecer sai no registro como "não declarado em forma
reconhecível". O `run_id` e o `incomplete_reason` entram no registro só quando são
ficha de letras, dígitos, `-` e `_`, e senão saem como "não exibido". As recusas
que protegem o registro ficam: arquivo faltando e validador do upstream saindo
diferente de `0`.

## User Stories

1. Como usuário do anvil, quero registrar uma execução cujo `source_ref` é um objeto com `sha` em vez de `commit`, e ver o SHA no registro.
2. Como usuário do anvil, quero registrar uma execução cujo `source_ref` é um objeto com `revision`, e ver o SHA no registro.
3. Como usuário do anvil, quero que `worktree_dirty` valha como `dirty`, para que a árvore suja ou limpa apareça no registro.
4. Como usuário do anvil, quero registrar uma execução cujo `source_ref` é uma string com um SHA, e ver só o SHA no registro, sem o resto da string.
5. Como usuário do anvil, quero que uma string de `source_ref` com a palavra `dirty` marque a árvore como suja, e com `clean` como limpa, e que sem nenhuma delas o estado da árvore saia como não declarado.
6. Como usuário do anvil, quero registrar uma execução cujo `source_ref` é uma string sem SHA, e ver o commit como "não declarado em forma reconhecível", sem a string no registro.
7. Como usuário do anvil, quero registrar uma execução sem `source_ref`, e ver o commit e a árvore como "não declarado em forma reconhecível".
8. Como usuário do anvil, quero registrar uma execução cujo `run_id` tem `.` ou `:`, como um carimbo de data e hora, e ver a execução como "não exibido", sem o valor.
9. Como usuário do anvil, quero registrar uma execução incompleta cujo `incomplete_reason` é texto livre, e ver o estado `incomplete` com o motivo "não exibido".
10. Como responsável pela segurança do projeto, quero a garantia de que nenhum texto do `source_ref` além do SHA, nem `run_id` ou `incomplete_reason` fora de ficha, entra no registro, para que a tolerância não abra um vazamento.
11. Como usuário do anvil, quero que as recusas por arquivo faltando e por validador do upstream continuem, para que o registro nunca derive de artefato inválido.
12. Como leitor do `SECURITY.md`, quero as regras novas descritas no lugar das antigas, para saber o que o verbo aceita e como cada campo aparece.

## Implementation Decisions

- **Só o `audit-record.cjs` e o `SECURITY.md` mudam.** Nenhum campo novo entra no registro, e a lista branca de leitura cresce só pelos nomes alternativos do `source_ref`.
- **SHA.** Do objeto, o primeiro de `commit`, `sha` e `revision` que é string; da string, o próprio `source_ref`. Em qualquer dos dois, o SHA é a primeira palavra inteira de 7 a 64 caracteres hexadecimais; só ela vai para o registro. Sem SHA, o commit sai "não declarado em forma reconhecível".
- **Árvore.** Do objeto, o primeiro booleano entre `dirty` e `worktree_dirty`; da string, a palavra inteira `dirty` dá suja e `clean` dá limpa. Sem isso, a árvore sai "não declarado em forma reconhecível".
- **`run_id` e `incomplete_reason`.** Ficha de letras, dígitos, `-` e `_` entra como está; qualquer outra coisa, inclusive ausência ou tipo diferente de string, sai "não exibido".
- **`profile` e `run_status` continuam conferidos** contra os valores fixos do upstream (`quick`, `standard`, `deep`; `complete`, `incomplete`, `in_progress`): o `SKILL.md` do upstream os enumera, então a forma deles é fixa, e o estado da execução decide o que o registro diz sobre o motivo.
- **Recusas que ficam:** fora de repositório git, argumento inválido, arquivo faltando, validador ausente ou saindo diferente de `0`, `run-metadata.json` que não é objeto JSON, `profile` ou `run_status` fora dos valores do upstream.

## Testing Decisions

- O seam é o mesmo da 014: o verbo `security` rodado sobre um diretório de execução de exemplo, observado no arquivo gravado.
- O `Pronto quando:` da entrada é o critério de aceite, como está: sobre execuções de exemplo que passam nos dois validadores da cópia vendorizada, com o `source_ref` como objeto de nomes alternativos, como string com SHA, como string sem SHA e ausente, e com `run_id` contendo `.` e `:`, o verbo `security` grava o registro em todas, mostra o SHA quando existe, marca o que não reconheceu, e nenhum texto do `source_ref` além do SHA, nem o `run_id` fora de ficha, aparece no registro.
- Cada variante leva texto marcador único no `source_ref` e no `run_id`, e a prova de que não vaza é que nenhum marcador aparece no registro gravado.
- Precedente: os cenários manuais de `workspace/`, fora do git. O repositório não tem suíte.

## Out of Scope

- As recusas por arquivo faltando e por validador do upstream saindo diferente de 0, que continuam.
- Tirar o commit do `git` do repositório na hora do registro.
- Rodar uma auditoria real.
- Qualquer campo novo no registro.
