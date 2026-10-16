# Verbo `index` — gerar `docs/index.md`

Mantém `docs/index.md` como a porta de entrada da documentação. O arquivo é
gerado; edição à mão dentro dele se perde na próxima geração — exceto o bloco
custom.

## Quem chama

As skills de fluxo chamam **em silêncio**, sem perguntar, depois de criar uma
spec, mudar o estado dos tickets ou arquivar. O usuário chama à mão quando
quiser reconciliar.

Só fale se encontrar link quebrado ou entrada obsoleta.

## Passos

1. **Carregar** [templates/docs-index.md](templates/docs-index.md).

2. **Domínios base** — para cada um de `discovery/`, `prd/`, `architecture/`,
   `ui/`, `qa/`, `project/`: se a pasta não existe, **não gere o link**. Índice
   que aponta para pasta ausente é pior que índice incompleto.

3. **Roteiro** — só quando `docs/specs/roadmap.md` existe. Sem ele, a seção
   não sai, nem o título: o índice fica como sem este passo. O estado de cada
   entrada sai do script, rodado da raiz do projeto, no checkout atual:

   ```bash
   bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh
   ```

   A seção vem logo acima de "Specs ativas", com uma linha para cada `entry:`,
   na ordem em que o script as devolve, que é a do roteiro:

   ```markdown
   - **<nome>** — <estado>[ — <spec>]
   ```

   | `state=` | `<estado>` |
   |---|---|
   | `pending` | pendente |
   | `open` | em andamento |
   | `closed` | fechada |
   | `stopped` | parada: `<reason>`, o texto do `reason=` copiado como está |

   `<spec>` só existe quando a linha tem `spec=` com número. Ele é o link da
   pasta, `[NNN](./specs/{NNN}-{tipo}-{nome}/)` ou
   `[NNN](./specs/archive/{NNN}-{tipo}-{nome}/)`, achada pelo prefixo numérico
   no checkout atual. Sem a pasta no checkout, como a spec aberta que só existe no
   branch dela, é `spec NNN`, sem link.

   Quando `docs/specs/report.md` existe, a seção termina com esta linha; sem o
   arquivo, ela não sai:

   ```markdown
   Relatório da execução: [report.md](./specs/report.md)
   ```

   **Recusa.** O script sai com `2` e linhas `refusal:` quando o roteiro não pode
   terminar. Isso não é falha da geração: a seção sai sem linha de entrada, com
   uma linha `> **Aviso:** o roadmap.sh recusou o roteiro: <motivo>` por linha
   `refusal:`, e o resto do índice é gerado normalmente. A linha do relatório
   segue a mesma regra de quando não há recusa.

4. **Specs ativas** — uma linha por pasta em `docs/specs/*/` que não esteja sob
   `archive/`. O estado é derivado, não lido de campo:

   | condição | estado |
   |---|---|
   | `spec.md` existe, sem `issues/` | especificado |
   | `issues/` com algum `Status:` ≠ `resolved` | em andamento — mostre `resolvidos/total` |
   | todos `resolved` | pronto para arquivar |

   O branch sai do `spec-meta`? Não existe mais. Reconstrua a partir do nome da
   pasta: `{NNN}-{tipo}-{nome}` → `{tipo}/{NNN}-{nome}`. Se quiser a data de
   criação, use o git, não um campo.

   Ordene por número, **decrescente**.

5. **Specs arquivadas** — uma linha por pasta em `docs/specs/archive/*/`,
   ordenadas por número decrescente.

6. **Conteúdo por domínio** — para cada domínio, liste os `.md` em ordem
   alfabética, com o título tirado do primeiro `#` e uma descrição de uma ou duas
   linhas tirada do próprio conteúdo. `README.md` de domínio não entra na lista —
   ele já é a descrição da pasta.

7. **Preservar o bloco custom.** Se `docs/index.md` já existir, leia o que está
   entre `<!-- custom -->` e `<!-- /custom -->` e reescreva idêntico no arquivo
   novo. É o único trecho que o usuário pode editar à mão.

8. **Entradas obsoletas** — arquivo que estava no índice e não existe mais:
   **pergunte** antes de remover a linha. Pode ser arquivo movido, não deletado.

9. **Escrever**, com `Last updated` em ISO 8601 UTC.

## Regras

- Nunca modifique um arquivo indexado. Este verbo só lê e escreve o índice.
- Caminho relativo começando com `./`.
- **Idempotente** a menos do timestamp: rodar duas vezes seguidas não muda mais
  nada.
- Opcionalmente rode
  `bash ~/.claude/skills/anvil-docs/scripts/validate.sh docs-paths --quiet` e
  mostre as violações como aviso não bloqueante.
