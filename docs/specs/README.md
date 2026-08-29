# Specs

Uma pasta por spec: `docs/specs/{NNN}-{tipo}-{nome}/`.

O **branch** é `{tipo}/{NNN}-{nome}` — string diferente da pasta, de propósito.
Nunca resolva uma na outra por igualdade de string; use o prefixo numérico.

Dentro da pasta, o formato é integralmente o das skills originais:

    spec.md              /anvil-to-spec
    issues/NN-slug.md    /anvil-to-tickets — um arquivo por ticket,
                         com "Blocked by:" e "Status:"
    map.md               /anvil-wayfinder, quando usado

Spec fechada vai para `archive/` via `/anvil-docs archive`.
