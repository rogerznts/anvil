# ADR-0021 — O grill pergunta pela ferramenta de pergunta do harness, em blocos de até 10

- Status: aceito
- Data: 2026-10-28
- Origem: [spec 016](../../specs/archive/016-extension-grill-ask-rounds/spec.md)
- Exceção nomeada ao [ADR-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md) — as skills vendorizadas seguem o padrão original —, que continua valendo

## Contexto

O `anvil-grilling` é vendorizado do mattpocock com pin, e o `anvil-grill`, o
`anvil-grill-me`, o `anvil-wayfinder` e o `anvil-bench` o carregam. O upstream
manda fazer a frontier inteira numa rodada, em texto, e cola o modelo de saída na
própria skill: título, corpo de vários parágrafos, alternativas e a resposta
recomendada, uma pergunta atrás da outra. Com 20 dúvidas, o operador recebe um
paredão, responde em prosa citando números e deixa pergunta sem resposta. O grill
também não diz quanto falta, e as decisões vivem só na conversa: uma compactação
no meio de um grill longo as perde.

Os três harnesses em que o anvil roda têm ferramenta de pergunta estruturada: o
`AskUserQuestion` no Claude Code, o `ask` no omp e o `request_user_input` no
Codex.

O [ADR-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md) proíbe
reescrever skill vendorizada para resolver incoerência: a saída é o perfil de
tracker ou uma rule do projeto, nunca o arquivo da skill.

## Decisão

**A rodada do `anvil-grilling` sai pela ferramenta de pergunta do harness, em
blocos de até 10, com estimativa, opção recomendada e opção custom em toda
pergunta, registro das decisões em disco e confirmação final por prompt.** Sem
ferramenta, o bloco sai em texto compacto, uma linha por pergunta.

A mudança entra no arquivo da skill como a regra de julgamento `ask-rounds` do
catálogo de adaptações, declarada no manifesto só no `anvil-grilling` e
sinalizada pelo `vendor-sync.sh` a cada `vendor` e `update`.

**Por que uma rule do projeto não basta.** A skill prescreve o formato de texto
literalmente, com o modelo de saída colado. Uma rule que mande perguntar pela
ferramenta contradiz esse modelo, e diretiva que a skill contradiz perde: o
modelo segue o que está escrito na skill que carregou. É o mesmo argumento que o
[ADR-0010](./adr-0010-verificacao-tem-criterio-de-parada.md) — a verificação tem
critério de parada — usou para a regra `verification-profile`: quem decide o
formato do achado é o brief colado no subagente, não a diretiva.

**O tamanho da exceção.** O delta fica no parágrafo "Work the tree in rounds…" e
no bloco "Format a round like so". Árvore de decisões, frontier, fatos buscados
por subagente e critério de término ficam verbatim. Num merge em que o upstream
mexa nesse seam, a versão do anvil ganha; o resto do arquivo segue o upstream.

**O ADR-0001 não é revogado.** A regra mestra continua: bateu dúvida, o padrão é o
da skill original. Esta é uma exceção nomeada, com seam declarado, como a do
`verification-profile`.

## Alternativas descartadas

- **Rule do projeto ou diretiva no `claude_boot.md`.** Perde para o modelo de
  saída colado na skill, pelo argumento acima.
- **Uma skill autoral nova de grill.** Duplicaria árvore, frontier e término, que
  o upstream mantém e melhora; o `anvil-grill`, o `anvil-wayfinder` e o
  `anvil-bench` teriam de trocar de skill, e o ganho do sync sumiria.
- **Mudar o `anvil-grill` e o `anvil-grill-me`.** Eles só chamam o
  `anvil-grilling`; o formato não mora neles.

## Consequências

**A favor.** O operador escolhe com um clique, sabe quanto falta e não perde
decisões numa compactação. Todo chamador do `anvil-grilling` herda o formato sem
mudar.

**Contra.** O `anvil-grilling` ganha delta permanente num trecho que o upstream
pode mexer, e cada merge nesse seam pede julgamento à mão. A saída prevista é
propor a mudança ao `grilling` do mattpocock: se ela entrar lá, a regra
`ask-rounds` sai do manifesto no sync seguinte, e o delta volta a zero.
