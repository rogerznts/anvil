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
  a URL. Escrita pelas skills `anvil-open-pr` e `anvil-open-fast-pr` depois de
  abrir o PR. Ticket retrabalhado em dois PRs tem **duas** linhas, não uma
  substituída — o histórico é o ponto
- Cada rodada de verificação acrescenta uma linha `Review:` logo abaixo do
  `Status:`. Formato estável: `round`, `sha`, `scope`, `verdict` e `p1`
  (`open` ou `none`). Quem conduz o `/anvil-code-review` grava a linha que ele
  devolve. As classes e o orçamento vêm de `docs/agents/verification.md`

```markdown
# 03: Aplicar cupom no total do carrinho

**Blocked by:** 01, 02
**Status:** resolved
**Review:** round=1; sha=4f2a91c; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=9c1de07; scope=diff:4f2a91c..9c1de07; verdict=pass; p1=none
**PR:** https://gitea.exemplo/org/repo/pulls/51

- [ ] Critério de aceite 1

## Comments

- Review round=1 · P1: desconto negativo passa pelo total — comprador paga valor errado.
- Review round=2 · P2: prova não cobre arredondamento — regressão apareceria no primeiro ciclo.
```

`Review:` é **histórico**, não estado: cada rodada acrescenta uma linha, nunca
substitui. A última linha dá à próxima rodada o número e o fixed point. Sem linha,
a próxima é `round=1`, com `scope=full`; depois dela, o escopo é o diff desde seu
`sha`. Depois de `round=2`, uma terceira rodada exige escolha explícita.

O campo guarda o estado da rodada; cada achado P2/P3 acionável fica por extenso
em `## Comments`, com classe e consequência. Não reduza achados a uma contagem.

P1 reabre o trabalho: grave `verdict=fail`, mude `Status:` de `resolved` para
`claimed` e corrija. Sem P1, grave `verdict=pass` e mantenha `resolved`. Assim a
guarda de merge não libera um ticket que a revisão reprovou.

A única rodada que não segue o orçamento de `docs/agents/verification.md` é a
rodada extra do piloto automático, a skill `anvil-auto`, que ele declara no
ticket como exceção ao ADR-0010 do anvil. A declaração é uma linha no
`## Comments`:

```markdown
- Piloto · rodada <N> aberta por `docs/specs/<pasta>/discovery/<arquivo>`: <a fonte e o que ela explica da falha>.
```

Só o piloto automático escreve essa linha, uma vez por ticket, em qualquer
execução, no fim do `## Comments`: o caminho do arquivo da pesquisa entre crases,
dois-pontos, a fonte e o que ela explica. O `N` é a rodada seguinte à última
`Review:` do ticket, ou `1` sem `Review:`. O `anvil-implementer` que encontra a
linha e nenhuma `Review:` com `round=<N>` lê o arquivo e mede a rodada N, com
qualquer `Status:`.

Os tickets são **arquivo**, não issue de servidor, então não existe `#47` para
fechar. A ligação com o PR é feita nos dois sentidos: o corpo do PR lista os
caminhos dos tickets que fecha, e cada ticket ganha a URL do PR. Os dois lados
resolvem no diff do próprio PR.

O **branch** é `{tipo}/{NNN}-{nome}` — string diferente do nome da pasta, de
propósito. Nunca resolva uma na outra por igualdade; use o prefixo numérico.

## Quando uma skill disser "publish to the issue tracker"

Rode `bash ~/.claude/skills/anvil-to-spec/scripts/new-spec.sh --json`, da raiz do
projeto. O script vem da instalação de usuário do anvil, e o branch e a pasta
nascem no repositório em que ele roda.

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

Ao concluir um ticket, marque `Status: resolved` e commite. O hook de merge varre
`issues/` no commit do branch atrás de arquivo sem essa marca e bloqueia o merge
enquanto houver.

## Fechar a spec

Quando o último ticket vira `resolved`, a spec ainda não terminou. A ordem, toda
no mesmo branch:

```
/anvil-docs archive   promove o que virou canônico, move p/ docs/specs/archive/
/anvil-open-pr        um PR por spec; cada ticket ganha a linha PR: de volta
merge
```

O `archive` vem **antes** do PR, não depois do merge: mover a pasta é mudança em
arquivo e precisa de um commit, e depois do merge não sobra branch onde ele
caiba. O hook bloqueia o `git merge` e a criação do PR, pelo `gh` (`gh pr create`
e `gh api` com `POST` em `pulls`) ou pelo `tea` (`tea pr create`), enquanto a spec
não estiver arquivada no commit do branch — o `git merge` disparado da `main`
inclusive, porque a spec do branch mesclado também é conferida.

## Roteiro e relatório

Dois arquivos moram direto em `docs/specs/`, fora das pastas de spec, porque
cobrem mais de uma spec. Nenhum dos dois é spec, e a guarda de merge não os lê.

- `docs/specs/roadmap.md` — o **roteiro**: o plano de várias specs que o piloto
  automático, a skill `anvil-auto`, executa. Há um roteiro ativo por projeto.
  Quem o escreve é o piloto, no fim do grill, ou o `anvil-bench`, no fim da
  entrevista, e o commita na `main` depois do sim sobre o texto, que no bench é a
  versão em português simples. Depois disso, só se acrescenta a linha `Spec:` de
  uma entrada quando a spec dela nasce. O histórico do roteiro fica no git, sem
  arquivo de versão.
- `docs/specs/report.md` — o **relatório** da execução do piloto: o que foi
  feito, o que foi decidido sem humano, onde a corrente parou e, por último, o
  que ainda espera decisão, cada item como pergunta. O piloto o escreve à medida
  que a corrente avança e o commita na `main` a cada fronteira de spec.

No roteiro, cada entrada é uma seção de segundo nível cujo título é o **nome**
da entrada, em kebab-case e único no arquivo. Kebab-case aqui é letras minúsculas
ASCII e dígitos, em grupos separados por um hífen, sem hífen no começo nem no
fim: `a`, `cadastro-de-clientes` e `fase-2-relatorios` valem; `Cadastro de
clientes`, `cadastro_de_clientes`, `-cadastro` e `cadastro--clientes`, não. O
nome é o `--short-name` do `new-spec.sh` e é o que as outras entradas citam em
`Depende de:`. As chaves são linhas `Chave: valor` no começo da linha, com ou
sem negrito, como o `Status:` dos tickets:

```markdown
# Roteiro

## cadastro-de-clientes

Tipo: feature
Depende de:
Spec: 009

Entra: cadastro, busca e edição de clientes.
Fica de fora: importação de planilha.
Pronto quando: um atendente cadastra, encontra e corrige um cliente.

## pedidos

Tipo: feature
Depende de: cadastro-de-clientes

Entra: …
Fica de fora: …
Pronto quando: …
```

- `Tipo:` é um dos tipos do `new-spec.sh`.
- `Depende de:` é uma lista de nomes separados por vírgula. Vazia ou ausente,
  a entrada não tem dependência.
- `Cobre:` traz os ids do `docs/qa/checklist.yaml` e só existe no bench.
- `Spec:` não existe enquanto a spec não nasce, e só quem abre a spec da entrada
  o escreve: o piloto, ou o bench chamado direto.
- `Entra:`, `Fica de fora:` e `Pronto quando:` vêm do grill, e o piloto nunca os
  edita.
- A ordem das seções é a ordem do roteiro.
- O roteiro não tem `Status:`. O estado de cada entrada (`pending`, `open`,
  `closed` ou `stopped`) e a próxima a construir saem do disco, pelo script
  `bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh`, da raiz do projeto. Ele
  recusa, com o motivo, o roteiro com nome fora de kebab-case, nome repetido,
  `Depende de:` para nome inexistente, ciclo ou `Tipo:` inválido.

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
