# Issue tracker: anvil `docs/specs`

Specs e tickets vivem versionados em `docs/specs/`, não em `.scratch/`. Eles são
parte do repositório e sobrevivem ao merge.

## Convenções

- Uma spec por diretório: `docs/specs/{NNN}-{tipo}-{nome}/`
- A spec é `docs/specs/{NNN}-{tipo}-{nome}/spec.md`
- Tickets de implementação são um arquivo por ticket em
  `docs/specs/{NNN}-{tipo}-{nome}/issues/{NN}-{slug}.md`, numerados a partir de
  `01` em ordem de dependência (bloqueadores primeiro), **nunca um arquivo
  combinado**
- Cada ticket declara suas arestas numa linha `Blocked by:` perto do topo
- O estado de triagem é uma linha `Status:` perto do topo. Além do vocabulário
  padrão, este perfil usa `resolved` para ticket concluído — um ticket está
  desbloqueado quando todos os que ele lista estão `resolved`
- Comentários e histórico são anexados ao fim do arquivo, sob `## Comments`
- Ticket que foi para um PR ganha uma linha `PR:` logo abaixo do `Status:`, com
  a URL. Escrita pelas skills `tea-open-pr` e `tea-open-fast-pr` depois de abrir
  o PR. Ticket retrabalhado em dois PRs tem **duas** linhas, não uma
  substituída — o histórico é o ponto

```markdown
# 03: Aplicar cupom no total do carrinho

**Blocked by:** 01, 02
**Status:** resolved
**PR:** https://gitea.exemplo/org/repo/pulls/51

- [ ] Critério de aceite 1
```

Os tickets são **arquivo**, não issue de servidor, então não existe `#47` para
fechar. A ligação com o PR é feita nos dois sentidos: o corpo do PR lista os
caminhos dos tickets que fecha, e cada ticket ganha a URL do PR. Os dois lados
resolvem no diff do próprio PR.

O **branch** é `{tipo}/{NNN}-{nome}` — string diferente do nome da pasta, de
propósito. Nunca resolva uma na outra por igualdade; use o prefixo numérico.

## Quando uma skill disser "publish to the issue tracker"

Rode `bash .claude/skills/anvil-to-spec/scripts/new-spec.sh --json`.

O script reserva o próximo número **atomicamente no `origin`**, num ref imutável
`refs/spec-numbers/{NNN}`, antes de criar o branch. Duas pessoas criando spec ao
mesmo tempo nunca colidem. O número final pode diferir da sua previsão se outra
criação ganhou a corrida — confie sempre na saída JSON, nunca na previsão.

Se você **já está** num branch de spec, não rode o script e não crie branch
novo: resolva a pasta pelo prefixo numérico do branch atual.

## Quando uma skill disser "fetch the relevant ticket"

Leia o arquivo em `docs/specs/{NNN}-*/issues/`. O usuário normalmente passa o
caminho ou o número direto.

Para achar a pasta a partir do branch: extraia o `{NNN}` do branch e case pelo
prefixo numérico em `docs/specs/`.

## Trabalhar a frontier

Qualquer ticket cujos bloqueadores estejam todos `resolved`. Numa cadeia
puramente linear isso é de cima para baixo.

Ao concluir um ticket, marque `Status: resolved`. O hook de merge varre
`issues/` atrás de arquivo sem essa marca e bloqueia o merge enquanto houver.

## Wayfinding operations

Usadas pelo `/anvil-wayfinder`. O **mapa** é um arquivo com um **filho** por
ticket.

- **Mapa**: `docs/specs/{NNN}-{tipo}-{nome}/map.md` — o corpo com Notas,
  Decisões-até-agora e Névoa
- **Ticket filho**: `docs/specs/{NNN}-{tipo}-{nome}/issues/{NN}-{slug}.md`,
  numerado a partir de `01`, com a pergunta no corpo. Uma linha `Type:` registra
  o tipo (`research`/`prototype`/`grilling`/`task`); uma linha `Status:` registra
  `claimed`/`resolved`
- **Bloqueio**: uma linha `Blocked by: NN, NN` perto do topo
- **Frontier**: varra `issues/` atrás de arquivos abertos, desbloqueados e não
  reivindicados; o menor número ganha
- **Claim**: marque `Status: claimed` e salve **antes** de qualquer trabalho
- **Resolve**: anexe a resposta sob `## Answer`, marque `Status: resolved`, e
  anexe um ponteiro de contexto às Decisões-até-agora do `map.md`

## Onde os outros documentos moram

Este perfil cobre specs e tickets. Para o resto da árvore — `discovery/`, `prd/`,
`architecture/` com o glossário e os ADRs, `ui/`, `qa/`, `project/` — e para a
regra de quando um artefato é base e quando é da spec, chame a skill
`anvil-docs`.
