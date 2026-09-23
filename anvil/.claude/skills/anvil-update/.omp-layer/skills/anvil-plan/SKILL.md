---
name: anvil-plan
description: Conduz o planejamento de uma spec do anvil no omp, na mesma janela, por grill, to-spec e to-tickets. Entre uma etapa e outra propõe a próxima ou um desvio, e só carrega com o sim do operador.
argument-hint: "o pedido inicial, que vai para o grill"
disable-model-invocation: true
---

# Condutor do planejamento

O operador chamou esta skill para ir do pedido aos tickets sem precisar saber a
ordem das etapas nem quando desviar. Você conduz. Cada etapa é uma skill do anvil,
e quem faz o trabalho dela é a própria skill, com as pausas que ela tem. Carregar
uma skill é lê-la com o `read` em `skill://<nome>` e segui-la.

Tudo acontece nesta janela, porque a etapa seguinte precisa do que a anterior
discutiu. Não abra subagente para uma etapa, não compacte e não sugira `/compact`,
`/handoff` nem sessão nova antes do fim.

## Onde o planejamento está

Comece sempre por aqui, com argumento ou sem, antes de dizer qualquer coisa ao
operador. No diretório em que a sessão está, que é a raiz do projeto, rode sem
`cd`:

```bash
bash .omp/skills/anvil-plan/stage.sh
```

O script lê o branch e a pasta da spec e devolve a linha `next`. A etapa não fica
gravada em lugar nenhum. Ela sai do disco, pelo script, e desta conversa. O que
fazer depende da linha `next`:

- `next: end`: os tickets existem. Vá para o fim.
- `next: anvil-to-tickets`: a `spec.md` existe e não há ticket. Diga ao operador
  qual é a spec, pela linha `spec`, e proponha `anvil-to-tickets`, como na seção
  seguinte.
- `next: anvil-to-spec`: a pasta da spec existe e a `spec.md` ainda não foi
  escrita. Diga qual é a spec e proponha `anvil-to-spec`.
- `next: anvil-grill`: não há spec no branch, e a conversa decide.
  - Se nesta conversa o operador já confirmou o entendimento do grill, proponha
    `anvil-to-spec`.
  - Se veio um pedido no argumento e o grill ainda não rodou nesta conversa,
    carregue `anvil-grill` já e dê a ele o pedido como ponto de partida. Chamar a
    skill com o pedido é o sim do operador para o grill.
  - Se não veio pedido e a conversa não tem nada do planejamento, peça o pedido e
    pare.

Com `next` diferente de `anvil-grill`, um pedido no argumento que não é a spec que
o script achou é um pedido novo. Diga isso e pare: um pedido novo começa num
branch sem spec, e trocar de branch é escolha do operador.

## A proposta

Uma etapa acaba quando a pausa final dela fecha:

- `anvil-grill`, quando o operador confirma que chegaram a um entendimento comum;
- `anvil-to-spec`, quando a spec está publicada;
- `anvil-to-tickets`, quando os tickets estão publicados.

As pausas do meio, como a rodada de perguntas do grill, a checagem dos seams do
to-spec e a da granularidade do to-tickets, são da skill carregada. Espere o
operador e siga a skill, sem proposta.

Quando uma etapa acaba, termine a sua vez com a proposta:

1. A próxima etapa, na ordem `anvil-grill`, `anvil-to-spec`, `anvil-to-tickets`,
   com uma frase sobre o que ela faz.
2. Um desvio, se um sinal da tabela abaixo apareceu, com o sinal que você viu.
3. A pergunta: pode carregar?

A proposta é a última coisa da sua vez. Não carregue a skill proposta, não rode o
script dela e não comece o trabalho dela antes da resposta. A resposta decide:

- sim: carregue a skill e siga;
- não: pare sem carregar nada, e diga que `/skill:anvil-plan` de novo retoma de onde
  o planejamento está;
- outra coisa, como uma pergunta ou uma correção: responda, e a proposta continua
  aberta.

## Desvios

| Sinal | Desvio |
|---|---|
| um fato que ninguém na conversa sabe e que o repositório não responde, como uma API de terceiro ou uma norma | `anvil-research` |
| uma pergunta que só se responde vendo rodar, como um modelo de estado ou o comportamento de uma tela | `anvil-prototype` |
| uma decisão que depende de alguém que não está na conversa | `anvil-to-questionnaire` |
| trabalho grande demais para uma spec, com decisões que dependem umas das outras em cadeia | `anvil-wayfinder` |
| uma tela no pedido sem o fluxo ou o método de design decidido | `anvil-ui` |
| a forma dos módulos em aberto: tipos, assinaturas, fronteiras | `anvil-architect` |

Um sinal que aparece no meio do grill trava uma pergunta. Proponha o desvio no fim
da rodada, ao lado das perguntas que não dependem dele. O desvio só é carregado com
o sim, como uma etapa.

Quando o desvio termina, proponha voltar à etapa de onde saiu, pelo nome dela. Com
o sim, siga a skill dessa etapa do ponto em que ela parou.

## O fim

Com os tickets publicados, rode o script de novo. Com `next: end`, o planejamento
acabou. Mostre ao operador a linha `handoff` do script, que diz `/clear` e depois
`/skill:anvil-run NNN` com o número da spec, sem executar nenhum dos dois. O
`/clear` vem antes porque o `anvil-run` lê o estado dos tickets, e esta conversa só
ocuparia a janela do supervisor.

## Nunca

- Carregar uma etapa ou um desvio sem o sim do operador, fora o grill da primeira
  chamada.
- Escrever, editar ou publicar spec ou ticket por conta própria. Isso é das skills
  `anvil-to-spec` e `anvil-to-tickets`.
- Gravar a etapa em arquivo, campo ou ticket.
- Responder a uma pausa no lugar do operador.
- Trocar de branch por conta própria, ou rodar o `anvil-run`.
