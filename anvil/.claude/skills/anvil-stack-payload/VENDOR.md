# Proveniência

`SKILL.md`, `README.md` e `reference/` são **cópia vendorizada** de um projeto
upstream. Não edite como se fossem conteúdo do anvil.

## Upstream

| | |
|---|---|
| Projeto | [payloadcms/skills](https://github.com/payloadcms/skills) — skills oficiais da Payload para agentes |
| Autor | Payload CMS |
| Caminho de origem | `skills/payload/` |
| Pin | `832d5bc4258ae784f08cb7f03a3a674d6b2fa5f1` |
| Submodule | `references/payload-skills` |

## Modificação

**Uma linha.** O `name:` do frontmatter, de `payload` para `anvil-stack-payload`.
A `description` fica verbatim: é ela que faz a skill disparar no momento certo, e
o upstream a escreveu bem.

O `SKILL.md` **não foi enxugado.** O plano original previa cortar `Quick Start` e
`Essential Patterns` por duplicarem o `reference/`, reduzindo de 518 para ~120
linhas. Isso foi revertido: a duplicação é escolha deliberada do upstream —
`SKILL.md` é a porta de entrada que dá o suficiente para começar sem carregar
onze arquivos de referência. Cortar custaria um delta permanente de ~400 linhas,
conflito em todo update, e a perda das melhorias upstream justamente nas partes
cortadas.

## O que é do anvil

Adicionado ao redor, sem tocar no que veio de fora:

- `RULE.md` — as três ciladas e a fronteira de edição. Vira
  `.claude/rules/payload.md` no projeto.
- `bench/` — starter, scripts e invariantes do `/anvil-bench`, herdados do mosk.
- este arquivo.

`RULE.md` repete as três ciladas que também estão na seção *Security Pitfalls* do
`SKILL.md`. A duplicação é correta e proposital: a regra existe **porque** a
referência não vai ser aberta.

## Ressincronizar

Pelo `/anvil-sync`, que usa o pin acima como base do merge 3-way. Como a
modificação é de uma linha, o merge deve ser trivial.

Nunca edite `reference/` à mão. Achou erro? Reporte no upstream — a correção
volta no próximo sync e beneficia todo mundo.

## Problema conhecido no upstream

`reference/FIELD-TYPE-GUARDS.md` importa os type guards de `payload`, mas eles
são exportados de `payload/shared`. É a
[issue #16909](https://github.com/payloadcms/payload/issues/16909), aberta no
upstream. Não corrigimos aqui — corrigir criaria divergência num arquivo que o
upstream vai consertar. Se um agente esbarrar nisso, o import correto é
`from 'payload/shared'`.
