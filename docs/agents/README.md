# Agents

Configuração que as skills de fluxo leem antes de publicar.

- `issue-tracker.md` — o perfil do issue tracker (`/anvil-setup`)

O `/anvil-to-spec`, o `/anvil-to-tickets`, o `/anvil-code-review` e o
`/anvil-wayfinder` não sabem por dentro o que é `docs/specs/`: eles leem esse
perfil. Sem ele, publicam no lugar errado e não reclamam.
