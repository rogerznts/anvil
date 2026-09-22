# O gate sem critério de parada

Nota de campo sobre um erro de processo que já se repetiu em mais de um projeto:
um par de gates independentes (Tester e Review) entra em laço e o trabalho não
fecha, embora nada esteja quebrado.

Escrita a partir do caso medido no `labstorm-idp` em 2026-09-20, e proposta como
base para ajuste nas skills do anvil.

## O caso

Duas specs, conduzidas com dois gates independentes por rodada — um que mede
executando (Tester) e um que mede lendo (Review), cada um em worktree própria
sobre um commit congelado.

| artefato | rodadas | desfecho |
|---|---|---|
| Spec 002 (Directory), código | 12 | fechou |
| Ticket 12 (desativar pessoa), código | 2 | fechou |
| Ticket 17 (Effective Access), código | 2 | fechou |
| Ticket 10 (criar pessoa), código | 3 | fechou |
| Ticket 22 (briefing ao app), **documento** | 3 e sem fim à vista | interrompido pelo usuário |

Os gates funcionaram: acharam um operador de sede que desativava outro operador
retomando uma operação admitida por papel global, uma prova de escrita que
reconhecia o `seq` que o próprio rollback devolvia ao contador, divergência falsa
e permanente numa tela de suporte, e uma tela que dizia "sucesso" quando o
segredo tinha se perdido. Nenhum desses achados seria encontrado lendo o diff com
atenção normal.

O problema não é o gate. É que ele não tem quando parar.

## O mecanismo

Um gate é instruído a **achar**. Num artefato de código essa instrução termina
sozinha, porque a superfície é finita e mensurável: existe um conjunto de
comportamentos observáveis, cada um dá para provocar, e a mutação decide se a
prova tem dentes. Quando não há mais mutação que passe despercebida, acabou.

Num documento de contrato de 500 linhas, não acaba. A superfície é a prosa
inteira, a régua é a leitura de quem mede, e cada frase nova é matéria-prima para
o achado seguinte. Pior: **a correção é a fonte da próxima rodada**. No caso
medido:

- rodada 1: 13 achados, dois deles mentiras que quebrariam o app;
- rodada 2: fecha doze e **abre três**, todos criados pela correção (uma
  referência cruzada que envelheceu, um código de status trocado, uma moldura que
  passou a contradizer o parágrafo vizinho);
- rodada 3: fecha os três e **abre outros seis**, do mesmo tipo — inclusive
  apontar que a tabela agora tem cinco linhas e o título ainda diz quatro.

A terceira rodada custou os mesmos 40 minutos da primeira e devolveu achados de
valor uma ordem de grandeza menor. Esse é o laço.

## Por que recorre

Porque o critério de parada estava implícito, e o implícito era **"nenhum achado
aberto"**. Esse critério é bom em código e péssimo em prosa, e nada no processo
distinguia os dois casos. Três coisas faltavam:

1. **Classe amarrada a consequência.** Achado que muda o que o leitor vai
   construir não é da mesma espécie de achado que corrige um intervalo de linhas
   numa citação. Sem essa distinção, os dois reprovam igual.
2. **Orçamento.** Nenhum limite de rodadas, e nenhum momento em que a decisão de
   fechar volta para uma pessoa.
3. **Escopo da rodada seguinte.** Cada rodada releu o documento inteiro, então
   cada rodada tinha a mesma chance de achar algo novo em terreno já aprovado.

Há um viés que ajuda o laço: com um par de gates independentes, quem conduz
sente que fechar com achado aberto é "baixar a régua". É o oposto. A régua é a
decisão que o artefato sustenta; polimento sem consequência não é régua, é custo.

## Como reconhecer, ainda dentro do laço

Sinais, em ordem de força:

- **A rodada N+1 acha o que a rodada N criou.** O sistema já não está sendo
  medido; a correção está.
- **A classe dos achados desce e não sobe.** Rodada 1 acha mentira, rodada 3 acha
  contagem no título.
- **Nenhum achado nomeia uma decisão que muda.** "Um time que leia isto vai
  construir X errado" é achado; "a glosa ficou imprecisa" é nota.
- **O custo por achado sobe.** Mesmo tempo de rodada, achado menor.

Dois deles bastam para parar.

## O que proponho mudar no anvil

### 1. O gate classifica por consequência, e só P1 reprova

Três classes, definidas pelo que acontece se ninguém corrigir:

- **P1 — reprova**: defeito de comportamento, ou afirmação verificável falsa num
  contrato publicado. Quem seguir o artefato constrói errado.
- **P2 — registra e segue**: o artefato está certo e a prova é fraca, ou falta
  informação que o leitor descobre sozinho no primeiro ciclo.
- **P3 — nota**: precisão, forma, referência.

O veredito do gate é sobre P1. P2 e P3 saem no relatório e viram linha no ticket
de acompanhamento; **não** seguram o fechamento. Hoje a skill de revisão não diz
isso, e o comportamento padrão de um subagente revisor é reprovar por qualquer
coisa que ele tenha achado.

### 2. Orçamento de duas rodadas, e a terceira é decisão humana

Duas rodadas por artefato. Se a segunda não aprovar, o gate **para de opinar
sobre fechamento** e entrega ao humano: o que continua P1, o que virou
acompanhamento, e quanto custou cada rodada. Abrir a terceira passa a ser escolha
declarada, não inércia.

### 3. A partir da rodada 2, o gate mede o diff, não o artefato

A rodada 1 mede o artefato inteiro. Da 2 em diante, o escopo é: os achados
remedidos, mais o diff desde o commit da rodada anterior, mais uma varredura
dirigida por regressão (o que a correção pode ter quebrado). Terreno já aprovado
não volta para a mesa — é o que transforma releitura em laço.

### 4. Artefato de prosa tem gate diferente de artefato de código

Para documento de contrato, o gate mede **afirmações verificáveis**: rota,
campo, código de status, nome de erro, citação. Cada uma vira confere / mente /
não verificável. O que não é verificável — completude, ordem, proporção,
didática — é opinião útil e entra como P3, nunca como bloqueio. No caso medido,
foi exatamente a parte não verificável que produziu as rodadas 2 e 3.

### 5. Números fora de título

Detalhe pequeno com efeito grande no laço: toda contagem escrita num título ou
numa referência cruzada ("as seis regras", "os quatro desfechos") vira dívida na
primeira edição. A regra é não numerar o conjunto, ou numerar em um lugar só. Dos
seis achados da terceira rodada, dois eram isso.

## Onde encaixa

- **ADR novo** — "o gate recomenda, o humano fecha": as três classes, o orçamento
  de rodadas e a diferença entre artefato de código e de prosa.
- **`anvil-code-review`** — seção de critério de parada: o veredito é sobre P1, o
  relatório carrega P2/P3, e a rodada 2 em diante é diff-only. A skill hoje
  descreve muito bem *como achar* (os dois eixos, a linha de base de smells) e
  nada sobre *quando parar*.
- **`anvil-implement`** — a linha "use /anvil-code-review to review the work"
  precisa dizer o que fazer com o resultado: P1 volta para o trabalho, P2/P3 vira
  linha no tracker.
- **Diretrizes do `CLAUDE.md`** — o item 4 ("Goal-Driven Execution") define
  critério de sucesso para a implementação, e não para a verificação. Uma frase
  fecha a lacuna: critério de parada da verificação é ausência de P1, não ausência
  de achado.

## Desfecho

Decidido no [adr-0010](../architecture/adr/adr-0010-verificacao-tem-criterio-de-parada.md),
com uma correção de rota sobre o que esta nota propunha: a régua **não** foi
escrita dentro do `anvil-code-review` e do `anvil-implement`, que são
vendorizadas. Copiar o texto para dentro delas dava 47 linhas de delta autoral em
arquivo do upstream — conflito em todo merge 3-way, contra o `adr-0001` e o
`adr-0004`. Ela virou perfil do projeto, `docs/agents/verification.md`, escrito
pelo `/anvil-boot` a partir de um template do `anvil-docs`, e as duas skills
ganharam só o protocolo necessário para ler e gravar a rodada, declarado no
catálogo como a regra `verification-profile`.

As propostas 1 a 4 entraram. A **5 — números fora de título** não entrou em
skill nenhuma: é regra de escrita, não de gate, e no catálogo do anvil ela cairia
numa vendorizada de escrita (`anvil-writing-for-agents`) sem regra que a cubra.
Fica como observação desta nota; um achado desse tipo é P3 pela classificação do
perfil, que é o efeito prático pretendido.
