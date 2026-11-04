# ADR-0022 — A camada de UI fica com dois métodos: o redesign e os presets saem

- Status: aceito
- Data: 2026-11-04
- Revê em parte o [ADR-0005](./adr-0005-ui-com-roteador.md): o roteador continua, e só escolhe entre `anvil-ui-hallmark` e `anvil-ui-taste`

## Contexto

O ADR-0005 montou a camada de UI com um roteador, dois métodos rivais, uma skill
de redesign e quatro presets de estilo, todos do repositório do taste fora o
hallmark: `anvil-ui-redesign`, `anvil-ui-brutalist`, `anvil-ui-minimalist`,
`anvil-ui-soft` e `anvil-ui-stitch`.

No sync de 2026-11-04, os dois upstreams tinham mudado de forma:

- **taste**, de `c184364` para `12af471`. A `taste-skill` virou a
  `design-taste-frontend` v2: uma skill com scripts em Node, uma biblioteca de 20
  direções, um inspector que mede a página num Chrome real e crítica por
  screenshots. Ela passou a cobrir tela de app — dashboard, admin, settings — e
  ganhou uma rota própria de redesign, restyle e review. A `redesign-skill` foi
  aposentada no v2.1.1, com o aviso de que o SKILL.md principal a substitui. Os
  presets viraram *classics* opt-in e, no commit seguinte, foram para outro
  repositório, o `Leonxlnx/taste-skill-classics`. Em `skills/` sobrou só a
  `taste-skill`.
- **hallmark**, de `13ac0ec` para `de4999e`. Virou uma skill de build: os temas
  são dados, com um catálogo de 50 sorteado pelo `scripts/theme.mjs`, e há um
  Floor que o `sloplint` confere. O verbo `study` saiu; `redesign` e `audit`
  ficaram, e só rodam quando o usuário nomeia o Hallmark. Os componentes
  prontos e os arquivos de fora da pasta da skill que o anvil trazia por `extra`
  sumiram.

O ADR-0005 já previa o problema: se o taste passasse a cobrir dashboard, a regra
de despacho envelheceria em silêncio. Envelheceu: as três linhas dele mandavam o
código existente para uma skill que o upstream retirou, e a tabela comparativa
descrevia dials numéricos e um roteamento para design system oficial que o taste
v2 não tem mais.

## Decisão

**A camada de UI fica com o roteador `anvil-ui` e dois métodos, o
`anvil-ui-hallmark` e o `anvil-ui-taste`.** O `anvil-ui-redesign` e os quatro
presets saem do payload, do manifesto e do lock.

O roteador continua escolhendo um método e só um, com regra total e a escolha
declarada numa linha. O despacho foi reescrito a partir do que os dois upstreams
novos dizem de si:

1. o usuário nomeia um dos dois → esse;
2. mexer num design que já existe → taste, porque o hallmark se recusa sem ser
   nomeado e o taste tem a rota própria;
3. componente isolado e novo → hallmark, que tem escopo de componente com os
   oito estados;
4. um visual que a casa do taste proíbe — monospace, fio fino, gradiente, sombra
   → hallmark, que tem esses materiais no catálogo de temas;
5. página nova num projeto que já tem build de um dos dois → o mesmo;
6. o resto → taste.

A dependência do taste, Node 22+ e um Chrome, fica dita no roteador, e não muda
o despacho: sem ela, o próprio taste degrada para o `lint.mjs`.

### Alternativa considerada

**Seguir os presets até o `taste-skill-classics`.** Seria um submodule novo para
cinco skills que o próprio autor marcou como opt-in e tirou do caminho padrão.
Os presets se aplicavam por cima de um método que, no taste, não existe mais: o
v2 sorteia a direção inteira, tipo e paleta inclusive. Descartada.

## Consequências

**A favor.** O roteador volta a descrever skills que existem como estão. A
camada passa de sete skills de UI para duas, e cada uma acompanha o upstream sem
skill aposentada no meio.

**Contra — a perda deliberada.** Os quatro estilos nomeados deixam de existir
como skill: o brutalist, de tipografia suíça e terminal CRT; o minimalist,
editorial contido; o soft, de acabamento de agência; e o stitch, que gerava um
`DESIGN.md` para o Google Stitch. Quem pedia um deles pelo nome não tem mais um
preset para chamar. O pedido cai na linha 4 do roteador e vai ao hallmark, cujo
Step 1 pergunta o tom e cujo catálogo tem temas como `brutal` e `terminal`; o
`DESIGN.md` para o Stitch não tem substituto. O verbo `study` do hallmark, que o
ADR-0005 usava como motivo para despachar, também se foi, e por decisão do
upstream.

**Verificação.** Três pedidos — redesign de página existente, componente
isolado, landing nova sem nada nomeado — despacham para taste, hallmark e taste,
e nunca dois ao mesmo tempo.
