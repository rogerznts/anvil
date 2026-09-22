# ADR-0010 — A verificação tem critério de parada, e ele é ausência de P1

- Status: aceito
- Data: 2026-09-21
- Origem: [gate-sem-criterio-de-parada.md](../../discovery/gate-sem-criterio-de-parada.md), nota de campo do caso medido no `labstorm-idp`

## Contexto

O anvil manda verificar: o `/anvil-implement` termina chamando o
`/anvil-code-review`, e quem conduz uma spec grande costuma montar dois gates
independentes — um que mede executando, outro que mede lendo — sobre um commit
congelado.

Nenhuma dessas peças diz **quando a verificação acaba**. Na ausência de regra, o
critério que se instala sozinho é "nenhum achado aberto", e ele tem dois
comportamentos opostos conforme o artefato:

- **Código**: termina. A superfície é finita, cada comportamento se provoca, e a
  mutação decide se a prova tem dentes. Doze rodadas na spec 002 do `labstorm-idp`
  convergiram e acharam defeito real em quase todas — inclusive um caminho em que
  um operador de sede desativava outro operador, e uma prova de escrita que
  reconhecia um número que o próprio rollback devolvia ao contador.
- **Prosa**: não termina. A superfície é o texto inteiro, a régua é a leitura de
  quem mede, e **a correção vira a matéria-prima da rodada seguinte**. No ticket
  22, um documento de contrato de ~500 linhas: a rodada 1 achou 13 coisas, duas
  delas graves; a rodada 2 fechou doze e abriu três, todas criadas pela correção;
  a rodada 3 fechou as três e abriu seis, do mesmo tipo — uma delas era o título
  dizer "quatro" depois de a tabela ganhar a quinta linha. Mesmo custo por rodada,
  achado cada vez menor. O usuário interrompeu, e estava certo.

Há um viés que sustenta o laço: com gates independentes, fechar com achado aberto
parece baixar a régua. É o contrário. A régua é a decisão que o artefato sustenta;
polimento sem consequência é custo.

## Decisão

**1. O gate classifica por consequência, e o veredito é sobre P1.**

- **P1** — defeito de comportamento, ou afirmação verificável falsa num contrato
  publicado: quem seguir o artefato constrói errado. **Reprova.**
- **P2** — o artefato está certo e a prova é fraca, ou falta informação que o
  leitor descobre sozinho no primeiro ciclo. **Registra e segue.**
- **P3** — precisão, forma, referência. **Nota.**

P2 e P3 saem no relatório e viram linha no tracker. Não seguram fechamento.

**2. Orçamento de duas rodadas por artefato.** Se a segunda não aprovar, o gate
para de opinar sobre fechamento e entrega ao humano o que continua P1, o que
virou acompanhamento e o que cada rodada custou. A terceira rodada existe, e é
escolha declarada.

**3. Da rodada 2 em diante, o escopo é o diff.** Remedir os achados, medir o diff
desde o commit da rodada anterior e varrer dirigido por regressão. Terreno já
aprovado não volta para a mesa.

**4. Artefato de prosa tem régua própria.** O gate mede afirmações verificáveis —
rota, campo, status, nome de erro, citação — e cada uma é confere / mente / não
verificável. Completude, ordem, proporção e didática são opinião útil: entram como
P3 e nunca bloqueiam.

## Onde a regra passa a valer

Pelo mesmo mecanismo do [adr-0002](./adr-0002-organizacao-documental-e-um-perfil-de-tracker.md):
**a régua é um documento do projeto, e a skill o lê.** Copiar o texto para dentro
de uma skill vendorizada criaria delta permanente e conflito em todo merge 3-way,
contra o [adr-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md) e
o [adr-0004](./adr-0004-sync-por-merge-3-way-sem-cache.md).

| onde | o que entra |
|---|---|
| `anvil-docs/templates/verification-anvil.md` | o perfil, autoral: classes, orçamento, persistência da rodada, diff-only, prosa e sinais do laço |
| `anvil-docs/templates/issue-tracker-anvil.md` | a linha `Review:` por rodada, com número, SHA, escopo, veredito e P1; P2/P3 por extenso em `## Comments` |
| `/anvil-boot` passo 6 | confirma que os dois perfis chegaram ao projeto sem sobrescrever ajuste local |
| `reset-install.sh` | a cópia nova avisa, já no primeiro update, quando diretiva ou perfil ainda precisam do boot |
| `anvil-code-review` | lê a última `Review:`, deriva rodada e fixed point, classifica no brief e devolve a próxima linha pronta |
| `anvil-implement` | grava a linha; P1 muda `Status:` para `claimed`, e P2/P3 viram comentários |
| `claude_boot.md`, diretiva 4 | a frase que fecha a lacuna entre critério de sucesso e critério de parada |
| catálogo de adaptação | regra `verification-profile`, declarada no manifesto e sinalizada pelo `vendor-sync` |

As mudanças nas duas skills vendorizadas são **ponteiro e protocolo mínimo**, não
o conteúdo da régua: o texto vive nos dois perfis autorais.

## Alternativas descartadas

- **Contar achados ("aprova com até N")**. Achado não tem tamanho igual: uma
  mentira de contrato e um intervalo de linha errado contam 1 cada. A classe é o
  que distingue, e ela já é o que o gate precisa decidir para escrever o relatório.
- **Deixar o gate julgar sozinho quando parar.** É o estado atual. Um subagente
  instruído a achar não é o juiz certo da própria suficiência.
- **Não verificar prosa.** O ticket 22 prova o contrário: a primeira rodada achou
  que o documento garantia igualdade de slug onde o sistema desempata com sufixo,
  e um app construído com aquele texto ligaria permissões ao papel errado sem
  erro nenhum. A rodada 1 se paga.

## Consequências

**A favor.** A verificação passa a ter fim. O custo fica onde o risco está: uma
rodada completa, uma de regressão, e a decisão volta para quem responde pelo
trabalho. O relatório continua carregando tudo que foi achado, então nada se
perde — muda só o que segura o fechamento.

**Contra.** P2 acumulado no tracker é dívida visível, e dívida visível cobra
disciplina de quem prioriza. E existe a chance de um P2 mal classificado ser um
P1 disfarçado: a defesa é que a classe se justifica pela consequência escrita, e
consequência escrita é revisável.
