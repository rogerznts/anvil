# 014 — O registro da auditoria entra versionado em `docs/security/`

**Status:** ready-for-agent

Entrada `security-audit-record` do roteiro (`docs/specs/roadmap.md`), depois da
spec 013, que trouxe a `anvil-security-audit`. A decisão de arquitetura é o
ADR-0019 — o versionado é só o registro da auditoria, sem caminho nem reprodução
de nenhum achado.

## Problem Statement

A `anvil-security-audit` grava os artefatos de cada execução da auditoria fora do
repositório auditado, de propósito: um achado confirmado e versionado é uma
vulnerabilidade divulgada antes da correção. Em troca, o projeto não guarda
nenhum histórico das auditorias: quem abre o repositório não sabe se ele já foi
auditado, em que commit, com que perfil, o que ficou de fora da cobertura e
quantos achados houve. A documentação indexada do anvil não tem onde isso morar.

## Solution

O `anvil-docs` ganha o verbo `security`. Dado o diretório de uma execução da
auditoria, ele confere os artefatos com os validadores da própria auditoria e
deriva deles o registro da auditoria, gravado em `docs/security/` e listado pelo
verbo `index`. O registro diz o que foi coberto e quantos achados houve, por
veredito e severidade, com uma linha por achado que leva só o id, o veredito e a
severidade, e aponta para o diretório da execução, onde o detalhe fica. Nenhum
caminho de código, trecho de fonte, título livre ou reprodução de achado entra no
registro.

## User Stories

1. Como usuário do anvil, quero rodar `/anvil-docs security <diretório da execução>` depois de uma auditoria, para guardar no repositório que ela aconteceu.
2. Como usuário do anvil, quero que o registro diga o commit auditado e se a árvore estava suja, para saber a que versão do código a auditoria se refere.
3. Como usuário do anvil, quero que o registro diga o perfil e o escopo da execução, para não ler uma auditoria parcial como completa.
4. Como usuário do anvil, quero que o registro diga se a execução terminou completa ou incompleta, e com que motivo, como o `run-metadata.json` declara.
5. Como usuário do anvil, quero a cobertura declarada como contagem de unidades do coverage ledger por estado, para ver quanto foi coberto e quanto ficou de fora, adiado ou bloqueado.
6. Como usuário do anvil, quero a contagem de achados por veredito — `confirmed`, `needs_validation`, `rejected` — e dos `confirmed` por severidade, para ter a dimensão do resultado sem abrir o relatório.
7. Como usuário do anvil, quero uma linha por achado com só o id, o veredito e a severidade, para poder citar um achado depois sem que o registro revele onde ele está.
8. Como usuário do anvil, quero que o registro traga o caminho do diretório da execução, para saber onde está o detalhe que não foi versionado.
9. Como responsável pela segurança do projeto, quero a garantia de que nenhum caminho de código, trecho de fonte, título, descrição, comando ou reprodução de achado entra no registro, para que versioná-lo nunca divulgue uma vulnerabilidade.
10. Como usuário do anvil, quero que o verbo recuse uma execução cujo `findings.json` ou `coverage-ledger.json` não passa nos validadores da auditoria, para que o registro nunca derive de artefato inválido.
11. Como usuário do anvil, quero que o verbo recuse um diretório sem os três arquivos, com a mensagem dizendo qual falta, para não gravar registro pela metade.
12. Como usuário do anvil, quero que registrar de novo a mesma execução substitua o registro dela, em vez de criar um segundo, para que cada execução tenha um registro só.
13. Como usuário do anvil, quero o registro em `docs/security/audit-<data>-run-<N>.md`, com o `<N>` do diretório da execução, para que os registros se ordenem e se achem pelo nome.
14. Como leitor de `docs/index.md`, quero os registros listados no domínio `security/`, para achar o histórico de auditorias pela porta de entrada da documentação.
15. Como usuário do anvil, quero que `docs/security/` seja um domínio canônico do `anvil-docs`, para que o `validate.sh docs-paths` e o gatilho do `adopt` não o tratem como conteúdo fora do lugar.
16. Como usuário do anvil, quero que `docs/security/` nasça só no primeiro registro, como os outros domínios que uma skill cria no primeiro uso, para não ter pasta vazia prometendo conteúdo.
17. Como usuário do anvil, quero que o verbo nunca copie para o repositório o `REPORT.md`, o `FINDINGS-DETAIL.md` nem o `NEEDS-VALIDATION.md`, como diz o ADR-0019.

## Implementation Decisions

- **Verbo `security` do `anvil-docs`.** Entra na tabela de verbos, com um arquivo próprio ao lado do `ARCHIVE.md` e do `INDEX.md`. O argumento é o diretório da execução. Depois de gravar, o verbo roda o `index`.
- **Derivação determinística.** O registro sai de um script do `anvil-docs`, e não da redação do modelo: a garantia de não vazar caminho depende de quais campos são lidos, e isso se impõe por código. O script é Node, sem dependência — a auditoria já exige Node para os validadores dela.
- **Lista branca de campos.** O script lê só campos nomeados: do `run-metadata.json`, o id da execução, o commit e o estado da árvore auditados, o perfil, o estado da execução e o motivo de incompleta; do `coverage-ledger.json`, só o estado de cada unidade, para contar; do `findings.json`, de cada registro, só o fingerprint, o veredito e a severidade geral. Nenhum outro campo é lido para o registro, e nenhum id de unidade do ledger sai nele.
- **Validação antes.** O verbo roda o `validate-findings.cjs` e o `validate-coverage-ledger.cjs` da `anvil-security-audit` instalada sobre os arquivos da execução. Qualquer um saindo diferente de `0` é recusa, com a saída do validador, e nada é gravado.
- **Nome e substituição.** `audit-<data>-run-<N>.md`, com `<N>` do nome do diretório da execução e `<data>` a data UTC do registro. Se já existe em `docs/security/` um registro com o mesmo `-run-<N>.md`, ele é substituído no lugar, mantendo o nome.
- **Domínio `security/`.** Entra na árvore canônica do `anvil-docs` como domínio que uma skill cria no primeiro uso, na tabela de quem escreve onde, nos domínios base do `index`, nos domínios aceitos pelo `validate.sh docs-paths` e na lista de domínios canônicos do gatilho do `adopt`.

## Testing Decisions

- O seam é o verbo `security` rodado sobre um diretório de execução de exemplo. Observa-se o arquivo gravado e o `docs/index.md`, sem mock.
- O `Pronto quando:` da entrada é o critério de aceite, como está: dados um `findings.json` e um `coverage-ledger.json` de exemplo que passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, o verbo `security` grava o registro em `docs/security/` sem caminho de código nem reprodução de nenhum achado, e o verbo `index` o lista no `docs/index.md`.
- O exemplo traz pelo menos um registro de cada veredito, com caminhos, trechos de fonte e reprodução preenchidos. A prova de que não vazam é que nenhum valor desses campos aparece no registro gravado.
- Os casos de recusa — arquivo faltando, validador falhando — se provam rodando o verbo e vendo que nada é gravado.
- Precedente: os cenários manuais de `workspace/`, fora do git. O repositório não tem suíte.

## Out of Scope

- Copiar para o repositório o `REPORT.md`, o `FINDINGS-DETAIL.md`, o `NEEDS-VALIDATION.md`, caminho de código ou reprodução de qualquer achado.
- Abrir spec de correção a partir de um achado.
- Nível de detalhe configurável por projeto.
- Mudar a `anvil-security-audit` ou o diretório de saída dela.

## Further Notes

- O nome do domínio e do verbo segue o glossário: o arquivo é o registro da auditoria; a pasta de fora é a execução da auditoria.
