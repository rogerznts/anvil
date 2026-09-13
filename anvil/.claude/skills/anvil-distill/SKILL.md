---
name: anvil-distill
description: "Destila uma funcionalidade de um sistema de referência em references/ num documento com ponteiros para o código de origem e a tradução para a stack do projeto. Use quando o usuário quiser portar algo de um sistema de terceiro, ou pedir a destilação de um sistema de referência."
---

# Destilação

Uma **destilação** é o documento que mapeia uma funcionalidade de um sistema de
referência para a stack do projeto, com ponteiros que qualquer um reabre e
confere. Ela não implementa nada: é insumo para o grill e para a spec.

Quem lê o código e escreve o documento é um **subagente em background**, pelo
[DISTILL.md](DISTILL.md), que abre com a política de escrita — a invariante desta
skill. A sua sessão resolve a entrada e o destino, despacha, e devolve ao usuário
o caminho e o resumo.

## 1. Entrada

- **O sistema**: um caminho local, por padrão uma pasta em `references/`, usada
  como está. Se a pasta não existe, pare e diga ao usuário.
- **A funcionalidade**, opcional. Sem ela, a destilação cobre o sistema inteiro.
  Quando o sistema é grande demais para um documento, proponha ao usuário o
  recorte em funcionalidades antes de despachar: uma destilação por
  funcionalidade.

## 2. Destino

Com `docs/specs/`, a pasta da spec sai do prefixo numérico do branch, como manda o
perfil do tracker (`docs/agents/issue-tracker.md`). A destilação procura também em
`archive/` e lê do disco, porque a spec pode ainda não estar commitada:

```bash
git rev-parse --abbrev-ref HEAD
find docs/specs -maxdepth 2 -type d -name '{NNN}-*'   # ativa ou em archive/
```

- **A pasta existe**: destino `<pasta da spec>/discovery/`.
- **Branch com número e `docs/specs/` sem a pasta** — o `find` volta vazio: pare e
  diga ao usuário.
- **Branch sem número**, `main` e HEAD destacado inclusive, **ou projeto sem
  `docs/specs/`** — tracker GitHub ou GitLab, e o `find` falha com `No such file
  or directory`: `docs/discovery/`.

O arquivo é `distill-{sistema}.md` ou `distill-{sistema}-{funcionalidade}.md`,
em kebab-case, com `{sistema}` o nome da pasta. Se ele já existe, pergunte ao
usuário se substitui ou se a funcionalidade ganha outro nome.

## 3. Despacho

Despache um subagente `general-purpose` em background com o caminho absoluto do
`DISTILL.md`, a instrução de lê-lo inteiro e executá-lo, e o sistema, a
funcionalidade e o caminho do documento resolvidos acima. O prompt leva só isso.
A stack do projeto fica fora dele e fora do que você diz ao usuário: você não a
lê, nem a repassa da rule que tem no contexto — quem a lê, do código, é o
subagente.

Siga com o usuário enquanto ele trabalha. Quando voltar, mostre o caminho e o
resumo de três linhas que ele devolveu.
