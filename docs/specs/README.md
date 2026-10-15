# Specs

Uma pasta por spec: `docs/specs/{NNN}-{tipo}-{nome}/`.

O **branch** é `{tipo}/{NNN}-{nome}` — string diferente da pasta, de propósito.
Nunca resolva uma na outra por igualdade de string; use o prefixo numérico.

Dentro da pasta, o formato é integralmente o das skills originais:

    spec.md              /anvil-to-spec
    issues/NN-slug.md    /anvil-to-tickets — um arquivo por ticket,
                         com "Blocked by:" e "Status:"
    map.md               /anvil-wayfinder, quando usado

Spec fechada vai para `archive/` via `/anvil-docs archive` — **antes de abrir o
PR**, no mesmo branch, para que o move entre no diff que vai ser revisado. A
guarda de merge bloqueia o PR enquanto a spec não estiver arquivada.

Fora das pastas de spec, direto em `docs/specs/`, moram dois arquivos que cobrem
mais de uma spec:

    roadmap.md           o roteiro do piloto automático (anvil-auto): uma seção
                         "## nome" por entrada, com Tipo:, Depende de: e, depois
                         que a spec nasce, Spec:. Escrito pelo piloto no fim do
                         grill, depois do sim do operador
    report.md            o relatório da execução do piloto, escrito por ele e
                         commitado na main a cada fronteira de spec

O roteiro não grava estado: `anvil-docs/scripts/roadmap.sh` deriva do disco o
estado de cada entrada e a próxima a construir. O formato completo está no perfil
do tracker, `docs/agents/issue-tracker.md`.
