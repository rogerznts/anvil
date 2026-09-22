# Verificação: critério de parada

Perfil que as skills de verificação leem. Ele responde **quando a verificação
acaba** — a pergunta que nenhuma skill de revisão responde sozinha, e cuja
ausência põe gate e trabalho em laço.

A decisão que originou este perfil é o ADR-0010 do anvil, escrito a partir de um
caso medido: doze rodadas sobre código convergiram e acharam defeito real; três
rodadas sobre um documento de contrato não convergiram, porque cada correção
virou a matéria-prima da rodada seguinte.

## Classe, decidida pela consequência

Todo achado carrega uma classe, e a classe sai do que acontece **se ninguém
corrigir**:

| classe | o que é | efeito |
|---|---|---|
| **P1** | defeito de comportamento, ou afirmação verificável falsa num contrato publicado — quem seguir o artefato constrói errado | **reprova** |
| **P2** | o artefato está certo e a prova é fraca, ou falta informação que o leitor descobre sozinho no primeiro ciclo | registra e segue |
| **P3** | precisão, forma, intervalo de citação | nota |

**O veredito é sobre P1.** P2 e P3 saem no relatório e viram linha no ticket de
acompanhamento; não seguram fechamento. Achado cujo corpo não consegue nomear a
decisão que muda é P3 por construção.

Quem revisa declara a classe **e a consequência na mesma frase** — "P1: um time
que leia isto liga a permissão ao papel errado". Consequência escrita é
revisável; classe solta não é.

Não conte achados. Uma mentira de contrato e um intervalo de linha errado contam
1 cada, e a contagem esconde a diferença.

## Orçamento: duas rodadas

- **Rodada 1** mede o artefato inteiro.
- **Rodada 2 em diante** mede o **diff**: remedir os achados da rodada anterior,
  ler o diff desde o commit dela, e varrer dirigido por regressão — o que a
  correção pode ter quebrado. Terreno já aprovado não volta para a mesa.
- Se a **rodada 2 não aprovar**, a verificação para de opinar sobre fechamento e
  entrega a quem conduz: o que continua P1, o que virou acompanhamento, e o que
  cada rodada custou. A terceira rodada existe — como escolha declarada, não como
  inércia.

## Persistência da rodada

O ticket persiste cada rodada numa linha `Review:` definida em
`docs/agents/issue-tracker.md`:

```markdown
**Review:** round=1; sha=4f2a91c; scope=full; verdict=fail; p1=open
```

- Sem `Review:`, a próxima revisão é `round=1`, mede o artefato inteiro e usa o
  fixed point que o usuário passou.
- Com uma linha, a próxima é `round=2`: o `sha` da última rodada vira o fixed
  point, e o escopo é `diff:<sha-anterior>..<HEAD>`.
- Com duas linhas, **pare antes de abrir outra**. Uma terceira rodada exige
  escolha explícita de quem responde pelo trabalho.
- Ao terminar, a revisão devolve uma linha pronta com o `HEAD` que mediu. Quem
  conduz a grava no ticket; achados P2/P3 ficam por extenso em `## Comments`,
  sempre com classe e consequência.

## Prosa não é código

Num documento de contrato, briefing ou runbook, o que se mede são **afirmações
verificáveis** — rota, campo, código de status, nome de erro, citação —, uma a
uma: confere / mente / não verificável aqui. Completude, ordem, proporção e
didática são opinião útil: entram como P3 e nunca bloqueiam.

É nesse artefato que o laço aparece, porque **cada correção reescreve a
superfície que a rodada seguinte lê**.

## Reconhecer o laço ainda dentro dele

Dois destes bastam para parar:

- a rodada N+1 acha o que a rodada N criou;
- a classe dos achados desce em vez de subir;
- nenhum achado nomeia uma decisão que muda;
- mesmo custo por rodada, achado menor.

## O que fazer com o resultado

- **P1** volta para o trabalho: grave a linha da rodada com `verdict=fail`, mude
  o `Status:` do ticket de `resolved` para `claimed`, e corrija. A rodada seguinte
  mede o diff da correção.
- **Sem P1**, grave `verdict=pass` e mantenha `Status: resolved`.
- **P2 e P3** ficam por extenso em `## Comments`, pelo perfil em
  `docs/agents/issue-tracker.md`. Não se abre rodada de verificação para limpar
  P2.
