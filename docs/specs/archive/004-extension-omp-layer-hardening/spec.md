# 004 — Robustez e isolamento da camada omp

**Status:** ready-for-agent

Extensão da spec 003 (`docs/specs/archive/003-feature-omp-harness/`), que está
arquivada e não muda. Esta spec resolve as linhas A1 a A11 de
`docs/project/acompanhamento.md`.

## Problem Statement

A camada omp da spec 003 funciona no caminho feliz. Fora dele, o operador que
conduz uma spec pelo `/skill:anvil-run` ou pelo `/skill:anvil-plan` tropeça em
defeitos que o fechamento da 003 registrou e não corrigiu:

- Um `Blocked by` fora do formato `NN, NN` perde bloqueadores em silêncio, e o
  `anvil-run` despacha um ticket em cima de um bloqueador travado.
- O ticket travado com o P1 numa linha combinada ("P2 (Standards) e P1 (Spec)")
  aparece no relatório sem o P1, e o operador decide a terceira rodada sem ver o
  achado que travou.
- Com locale `C`, "PÁGINA" e "BOTÃO" não contam como palavra de tela, e o
  relatório recomenda o archive para uma spec que tem tela. Os exemplos que a
  `anvil-run` dá para subir um `nao` são justamente palavras que o script já
  reconhece, e o supervisor fica sem exemplo do caso que importa.
- As chaves que o `frontier.sh` devolve estão em português, contra a regra de
  idioma do código, e o contrato de saída mistura chave estável com mensagem.
- Num projeto com outro perfil de tracker, os condutores quebram sem explicar: o
  `anvil-run` recusa por um motivo enganoso e o `anvil-plan` volta ao grill para
  sempre.
- Um implementer que cai no meio deixa a árvore suja, e a execução seguinte para
  em vez de retomar, ao contrário do que a US 45 da 003 (rodar de novo retoma de
  onde parou) promete.
- Tickets independentes esperam um pelo outro, porque o frontier é em série, e
  ninguém mediu quanto isso custa.
- O `vendor-sync.sh verify` não confere o comando que as skills da camada mandam
  rodar, só o caminho citado na prosa, e morre no check 3 sob o bash 3.2 do macOS.
  Quem mantém o anvil fica sem a checagem que protege a camada.
- Dos seis desvios que o `anvil-plan` oferece, só dois rodaram uma vez. Não há
  medida de quantas vezes o condutor propõe o desvio certo, nem garantia repetida
  de que ele nunca carrega uma etapa sem o sim do operador.

## Solution

O operador continua chamando os mesmos comandos. O que muda:

- O `frontier.sh` passa a ler `Blocked by` e P1 com a regra "na dúvida, bloqueia":
  linha que ele não entende segura o ticket e aparece no relatório.
- A detecção de tela passa a funcionar em qualquer locale, e a `anvil-run` ganha
  exemplos do caso que o script não pega.
- A saída dos dois scripts dos condutores vira um contrato estável, com chaves em
  inglês. Só as mensagens para o operador ficam em pt-BR.
- Os condutores leem o perfil do tracker e recusam com o motivo certo quando ele
  não é o `docs/specs`.
- Com a isolação de tarefas do omp ligada, cada implementer trabalha num
  workspace isolado, e a sobra de um implementer que caiu não chega ao branch da
  spec. Com isolação, o `anvil-run` aceita rodar vários tickets do frontier ao
  mesmo tempo, sob pedido explícito. O relatório passa a medir quantos tickets
  estavam prontos a cada rodada.
- O `verify` passa a conferir o comando dentro dos blocos de código da camada e
  roda até o fim sob o bash 3.2.
- Um conjunto de cenários repetidos mede o `anvil-plan`: a regra de nunca
  carregar sem sim é exigida em todas as rodadas, e o reconhecimento dos desvios
  é medido e reportado.

## User Stories

### Bloqueios lidos com segurança

1. Como operador, quero que um ticket com `Blocked by` que o script não consegue ler fique fora do frontier, para que o `anvil-run` nunca despache um ticket em cima de um bloqueador que ele não viu.
2. Como operador, quero que o relatório liste o ticket de bloqueio ilegível com a linha `Blocked by` como está no arquivo, para que eu saiba o que corrigir.
3. Como operador, quero que "03, ver ADR-0011" continue bloqueando só pelo 03, para que citar um ADR no `Blocked by` não invente um ticket 11.
4. Como operador, quero que `Blocked by: 01, 02` e `Blocked by: 01,02` sigam funcionando como hoje, para que os tickets já escritos não mudem de classe.
5. Como operador, quero que "01 e 02", "01 (a), 02 (b)", "`05`" e "01; 05" deixem o ticket fora do frontier como bloqueio ilegível, para que um formato inesperado nunca solte o ticket.
6. Como operador, quero que um bloqueador que cita um ticket inexistente continue aparecendo como "não existe" na linha do ticket, para que eu veja o erro de digitação.
7. Como operador, quero que um ticket sem linha `Blocked by`, ou com a linha dizendo que não há bloqueador ("Nenhum — pode começar agora.", "None (can start immediately)"), continue livre, para que os tickets da 003 e o template da `anvil-to-tickets` não virem bloqueio ilegível.

### O P1 do travado sempre aparece

8. Como operador, quero que o relatório do travado traga toda linha da última rodada no `## Comments` que cita P1, mesmo combinada com outra classe, para que eu decida a terceira rodada vendo o achado que travou.
9. Como operador, quero que uma linha "P2 (Standards): prova fraca do P1 anterior" não conte como P1, para que o relatório não me mostre um achado a mais.
10. Como operador, quero que o travado sem nenhuma linha P1 continue dizendo isso por extenso, para que eu saiba que o registro está incompleto.

### Tela detectada em qualquer ambiente

11. Como operador, quero que "PÁGINA", "BOTÃO" e "PAINÉIS" em caixa alta contem como palavra de tela com qualquer locale, para que um ambiente com `LC_ALL=C` não me mande arquivar uma spec com tela.
12. Como operador, quero que "paginar" continue sem contar como tela, para que a correção não crie falso positivo.
13. Como operador, quero que a palavra de tela fora das User Stories continue sem contar, para que a regra da 003 não mude.
14. Como supervisor, quero que a `anvil-run` me dê exemplos de história que descreve tela com palavras que o script não reconhece, como um gráfico que o usuário filtra, um mapa clicável ou cards que se arrastam entre colunas, para que eu saiba quando subir um `no` para o browser QA.
15. Como operador, quero que saída de terminal, arquivo, log e API continuem não contando como tela, para que o browser QA só seja recomendado para algo que abre no navegador.

### Contrato de saída dos condutores

16. Como mantenedor, quero que as chaves de saída do `frontier.sh` estejam em inglês e sejam estáveis, para que a `anvil-run` leia um contrato e não uma frase.
17. Como operador, quero que os motivos que o script mostra continuem em pt-BR, para que o relatório siga na minha língua.
18. Como mantenedor, quero que os identificadores internos do `frontier.sh` e do `stage.sh` estejam em inglês, para que os scripts sigam a regra de idioma do código do `CLAUDE.md`.
19. Como mantenedor, quero que a troca de chaves saia no mesmo commit da skill que as lê, para que nunca exista uma camada em que a skill procure uma chave que o script não emite.
20. Como operador, quero que o `anvil-run` se comporte igual antes e depois da troca de chaves, para que a mudança seja invisível para mim.

### Perfil do tracker

21. Como operador com o tracker no GitHub, no GitLab ou em markdown local, quero que o `/skill:anvil-run` recuse dizendo que os condutores só funcionam com o perfil `docs/specs`, para que eu entenda na hora por que ele não roda.
22. Como operador com outro perfil, quero que o `/skill:anvil-plan` recuse com o mesmo motivo, em vez de voltar ao grill a cada chamada, para que eu não perca uma conversa achando que ele funciona.
23. Como operador sem `docs/agents/issue-tracker.md`, quero que os condutores recusem sugerindo o `/anvil-setup`, para que eu saiba o passo que falta.
24. Como operador com o perfil `docs/specs`, quero que os condutores sigam exatamente como hoje, para que a checagem nova não me custe nada.
25. Como operador com outro perfil, quero que a camada continue instalada, com a guarda de merge e a rule, para que eu mantenha o que funciona em qualquer perfil.
26. Como operador, quero que a recusa me diga que o fluxo segue à mão, como no Claude Code, para que eu saiba o caminho alternativo.

### Isolamento e retomada

27. Como operador com a isolação de tarefas do omp ligada, quero que cada implementer rode num workspace isolado, para que a sobra de um implementer que caiu não chegue ao branch da spec.
28. Como operador com isolação, quero que o trabalho do implementer volte ao branch da spec como commits, para que o histórico continue um commit por passo como no modo sem isolação.
29. Como operador com isolação, quero que rodar a skill de novo depois de uma queda despache de novo o ticket que não mudou de estado, para que a retomada da US 45 da 003 funcione.
30. Como operador sem isolação, quero que a árvore suja continue parando o despacho, para que um implementer novo nunca commite a sobra de outro.
31. Como operador sem isolação, quero que a linha de parada e o manual `anvil-omp` digam como sair dela, com `git stash` ou com um commit meu, para que eu não precise descobrir sozinho.
32. Como operador, quero que o relatório diga se a execução rodou com ou sem isolação, para que eu saiba qual regra de retomada valeu.
33. Como operador com isolação mal configurada, que devolve patch sem commit, quero que a árvore suja resultante pare o laço e o relatório aponte a configuração, para que o erro não passe como sucesso.

### Frontier em paralelo

34. Como operador com isolação, quero pedir ao `/skill:anvil-run` que rode até N tickets do frontier ao mesmo tempo, para que tickets independentes não esperem um pelo outro.
35. Como operador, quero que sem o pedido explícito o `anvil-run` continue em série, para que o paralelo seja escolha minha.
36. Como operador sem isolação, quero que o pedido de paralelo seja recusado com o motivo, e a execução siga em série, para que dois implementers nunca dividam a mesma árvore.
37. Como operador, quero que só tickets do frontier saiam juntos, para que nenhum ticket rode antes do bloqueador dele estar resolvido.
38. Como operador, quero que o script seja relido depois de cada leva, para que o próximo despacho venha do disco e não da memória do supervisor.
39. Como operador, quero que um ticket da leva que termina sem mudar de estado, inclusive por falha ao integrar, seja tratado como pulado, para que a regra da 003 continue valendo e ele seja tentado de novo na próxima execução.
40. Como operador, quero que um conflito na integração que deixe a árvore suja pare o laço com a parada de sempre, para que eu decida o que fazer com ele.
41. Como operador, quero que o relatório diga quantos tickets estavam no frontier a cada rodada, para que eu meça se o paralelo compensa.
42. Como operador, quero que cada ticket de uma leva siga com o review dentro do próprio implementer, como em série, para que o paralelo não mude o que é verificado.

### Verify da camada

43. Como mantenedor, quero que o `verify` confira o caminho da camada citado dentro dos blocos de código das skills da camada, para que um erro de digitação no comando que a skill manda rodar reprove antes de chegar ao operador.
44. Como mantenedor, quero que o `verify` continue conferindo o caminho citado na prosa, para que a checagem nova some à antiga.
45. Como mantenedor no macOS sem bash novo no `PATH`, quero que o `verify` rode até o fim sob `/bin/bash` 3.2, para que eu tenha a checagem da camada sem instalar nada.
46. Como mantenedor, quero que o `verify` dê a mesma saída no bash 3.2 e no bash 5, para que o resultado não dependa da máquina.

### Prova dos desvios do `anvil-plan`

47. Como mantenedor, quero um cenário para cada um dos seis desvios saindo do grill, para que cada skill de desvio tenha rodado pelo menos no conjunto.
48. Como mantenedor, quero um cenário com desvio saindo do to-spec e um saindo do to-tickets, para que a volta à etapa de origem seja medida fora do grill.
49. Como mantenedor, quero que cada cenário rode várias vezes, para que o resultado meça consistência e não uma rodada de sorte.
50. Como mantenedor, quero que nenhuma rodada de nenhum cenário carregue uma etapa sem a proposta no turno anterior e o sim do operador, para que a regra de segurança do condutor valha sempre.
51. Como mantenedor, quero que o conjunto reporte, por cenário, em quantas rodadas o desvio certo foi proposto e em quantas a volta à origem foi proposta, para que eu saiba onde o condutor erra.
52. Como mantenedor, quero que a conferência seja feita por código sobre as sessões gravadas, e que as sessões fiquem guardadas, para que eu possa ler a conversa quando o número mudar.
53. Como mantenedor, quero que o conjunto registre o modelo que respondeu em cada rodada, para que um fallback de modelo não se passe pelo modelo pedido.

### Acompanhamento

54. Como mantenedor, quero que as linhas A1 a A11 saiam de `docs/project/acompanhamento.md` no branch desta spec, e que a parte do A9 que não entra aqui fique reescrita como linha própria, para que o acompanhamento diga só o que continua aberto.

## Implementation Decisions

### `frontier.sh`

- **Leitura do `Blocked by`, na dúvida bloqueia.** Da primeira linha `Blocked by`,
  sai o item, entre vírgulas, que só cita um `ADR-NNNN`, sozinho ou depois de "ver"
  ou "see". O resto tem de casar com uma lista de números
  separados por vírgula, com espaço opcional. Linha vazia, ausente, ou que começa
  por "Nenhum" ou "None", sem distinguir maiúsculas, é "sem bloqueador": são as
  formas da 003 e do template da `anvil-to-tickets`. Qualquer outra coisa faz o
  ticket ganhar a classe de bloqueio
  ilegível, que nunca entra no frontier nem no próximo, e a linha do ticket traz o
  texto original do `Blocked by`. Um ticket que depende de um ticket de bloqueio
  ilegível espera por ele como espera por qualquer bloqueador aberto.
- **P1 do travado.** No `## Comments`, conta toda linha que começa por
  `Review round=N ·`, com o `N` da última rodada, e tem `P1` como palavra inteira em
  qualquer posição depois do ponto médio. "P1 anterior" dentro de uma frase de P2
  não conta: o `P1` tem de estar na posição de classe, seguido de espaço e
  parêntese ou de dois-pontos. A mesma leitura vale em locale `C`.
- **Tela.** A lista de palavras não muda, fora o `interface` (ver a nota). A
  comparação passa a ser feita com `perl` em modo Unicode, ignorando maiúsculas e
  só com palavra inteira, e não depende do locale. O `perl` vem no macOS e nas distribuições Linux de uso comum.
  Conferido na pesquisa: com o grep BSD 2.6.0, `LC_ALL=C` dá 0 para "PÁGINA" e o
  `perl -CSD` dá 1.

  _Nota (decisão do operador, durante o ticket 11):_ uma palavra da lista muda. O
  `interface` (ou `interfaces`) sozinho só conta como tela com `web`, `gráfica`,
  `visual`, `do usuário` ou `de usuário` depois. No ponta a ponta, a user story
  "manter a regra separada da interface executável" deu `screen: yes`, e a
  `anvil-run` recomendou o browser QA para um comando de terminal.
- **Chaves de saída.** O contrato passa a ser este, com o valor humano em pt-BR
  depois da chave quando há motivo:

  | chave hoje | chave nova | valores |
  |---|---|---|
  | `recusa:` | `refusal:` | motivo |
  | `spec:` | `spec:` | pasta |
  | `branch:` | `branch:` | nome |
  | `arvore:` | `tree:` | `clean` ou `dirty (N)` |
  | `tela:` | `screen:` | `yes` ou `no`, com o motivo |
  | `historia:` | `story:` | a user story |
  | linha `ticket` | linha `ticket` | campos `status`, `reviews`, `last`, `blocked_by` e `class`; com `class=unreadable_blockers`, o `blocked_by` é o texto original da linha, entre aspas |
  | classes | classes | `resolved`, `locked`, `waiting:NN,NN`, `skipped`, `frontier`, `unreadable_blockers` |
  | `frontier:` | `frontier:` | números |
  | `pulados:` | `skipped:` | números |
  | `travados:` | `locked:` | números |
  | `p1_aberto NN:` | `open_p1 NN:` | a linha do `## Comments` |
  | `dependem_de_travado:` | `depend_on_locked:` | números |
  | `tudo_resolvido:` | `all_resolved:` | `yes` ou `no` |
  | `parada:` | `halt:` | motivo |
  | `proximo:` | `next:` | caminho do ticket ou `none` |
  | — | `isolation:` | `on`, `off` ou `misconfigured`, com o que o `omp config get` leu |
  | — | `ready:` | quantos tickets estão no frontier, para a medição do paralelo |
  | — | `frontier_files:` | os caminhos dos tickets do frontier, na ordem da linha `frontier`, para a leva do paralelo |

  O `--skip` e o argumento da spec não mudam. Os identificadores internos passam
  para o inglês.
- **Perfil do tracker.** Antes de resolver a spec, o script lê o título de
  `docs/agents/issue-tracker.md`. Só o perfil do anvil, cujo título nomeia
  `docs/specs`, segue. Outro perfil dá `refusal` com o nome do perfil achado e a
  frase de que o fluxo segue à mão. Arquivo ausente dá `refusal` sugerindo o
  `/anvil-setup`.
- **Parada.** A linha `halt` passa a dizer como sair dela, com `git stash` ou com
  um commit do operador. Ela abre com o modo da execução, e com
  `misconfigured` também com a configuração que falta,
  `task.isolation.merge: branch`. A `anvil-run` abre o relatório com essa linha
  copiada como está. Decisão do operador depois das rodadas 14 a 19 do S2 do
  ticket 08: no caminho da parada, o haiku abria o relatório pela parada e
  deixava de fora a linha do modo que a skill pedia.
- **Isolação.** Na raiz do projeto, o script roda
  `omp config get task.isolation.enabled` e, com `true`, também
  `omp config get task.isolation.merge`, e escreve a linha `isolation`: `on` com
  `true` e `branch`; `misconfigured` com `true` e outro merge; `off` com qualquer
  outro valor ou sem resposta do omp. O omp lê o `.omp/config.yml` do diretório em
  que roda, e não sobe até a raiz, por isso o script roda o comando depois do `cd`
  para a raiz.

### `stage.sh`

- Identificadores internos em inglês. As chaves de saída já estão em inglês e não
  mudam.
- Mesma leitura do perfil do tracker, antes de tudo. Perfil diferente ou ausente
  sai como `next: refused`, com o motivo em `reason` e um `do` que manda dizer o
  motivo ao operador e parar sem carregar nada.

### Skill `anvil-run`

- Lê as chaves novas. Nenhuma regra do laço muda por causa da troca.
- O item `screen: no` troca os exemplos por descrições que o script não
  reconhece: gráfico que o usuário filtra, mapa clicável, cards que se arrastam
  entre colunas.
- **Modo de isolação.** O supervisor lê o modo da linha `isolation` do
  `frontier.sh`. Com `on`, todo despacho sai com `isolated: true`. Com `off`, o
  laço segue como na 003. Com `misconfigured`, o supervisor diz ao operador, antes
  de despachar, que a isolação está fora do modo branch e aponta
  `task.isolation.merge: branch`; os despachos saem com `isolated: true`, e a
  parada por árvore suja continua como rede de segurança. O relatório abre dizendo
  o modo lido.

  _Nota (decisão do operador, durante o ticket 08):_ a primeira versão desta
  decisão mandava o supervisor olhar se o `task` oferece o campo `isolated`, que o
  omp só põe no schema com a isolação ligada. Na prática, isso depende de o modelo
  raciocinar sobre a própria definição do tool. Em sondas com `--thinking off`, o
  `claude-haiku-4-5` e o `claude-sonnet-4-6` erraram o modo nos dois sentidos. Com
  `--thinking low`, o haiku acertou as sondas curtas, mas no S2 inteiro errou o
  modo no A2 da rodada 7; na rodada 6, com `off` fora dos cenários de isolação,
  errou no A. O `omp config get` lê a mesma configuração que liga o campo, fora do
  modo plan, e não depende do modelo.
- **Paralelo.** Argumento opcional de paralelo, com N de 2 em diante. Com
  isolação, cada leva é uma chamada do `task` com até N itens, um por ticket do
  frontier, na ordem do script. Depois da leva, o script roda de novo, e cada
  ticket da leva passa pela comparação de antes e depois da 003: estado igual é
  pulado. Sem isolação, o pedido de paralelo é recusado na primeira linha de
  andamento, com o motivo, e a execução segue em série. Com `misconfigured`,
  também: o modo patch integra sem commit, e a leva misturaria o trabalho de
  vários tickets fora de commit antes da parada. Os caminhos da leva vêm da linha
  `frontier_files`, porque a linha `ticket` não traz o arquivo. Decisões do
  operador durante o ticket 09.
- **Medição.** O relatório final traz a linha `ready` de cada rodada.
- A regra "nunca despachar dois tickets ao mesmo tempo" passa a valer só para o
  modo sem isolação.

### Integração do trabalho isolado

- Quem traz os commits do workspace isolado para o branch da spec é o omp, no
  modo branch da isolação: ele commita num branch próprio da tarefa e faz o
  cherry-pick no branch de origem. O supervisor continua sem commitar e sem fazer
  merge.
- O modo patch não serve, porque aplica a mudança sem commit. O `anvil-run` avisa
  antes de despachar, pela linha `isolation: misconfigured`, e a árvore suja que o
  patch deixa é pega pela parada de sempre. O manual `anvil-omp` diz qual modo a
  isolação precisa.
- Conflito no cherry-pick não tem tratamento próprio. Se o ticket não mudou de
  estado no branch da spec, ele é pulado. Se a árvore ficou suja, o laço para. Os
  dois casos já existem na 003.
- O comportamento do omp no conflito foi lido na documentação do omp 18.2.11, não
  observado. O primeiro ticket do paralelo confere na prática e registra o que viu.
  Conferido no ticket 09, com o omp 18.3.0: o resultado está no ADR-0012, que é a
  fonte; a `anvil-run` e o manual `anvil-omp` levam dele só o que o supervisor e o
  operador precisam fazer.

### Manual `anvil-omp`

- Os Limites passam a dizer que os condutores recusam fora do perfil `docs/specs`.
  Hoje dizem só que quebram.
- Seção nova sobre isolação: o que ela muda na retomada, que o paralelo depende
  dela, qual modo de integração ela precisa e como ligá-la na configuração do omp.
- O limite "o frontier é em série" passa a dizer que o paralelo existe sob pedido,
  com isolação.

### `vendor-sync.sh verify`

- **Check 15.** Além dos spans da prosa, extrai dos blocos de código cercados dos
  arquivos da camada os caminhos que casam com o mesmo padrão de caminho da camada
  (`.omp/…`, `.claude/skills/…`, `.claude/agents/…`, lock) e confere cada um contra
  o payload, com a mesma mensagem de falha.
- **Check 3 no bash 3.2.** A troca no check 3 é mínima: sai a construção que
  derruba o bash 3.2, e o resultado fica igual. O trace com `bash -x` mostra o
  processo morrendo no primeiro arquivo do check 3, logo depois dos laços do check 2
  com uma process substitution por arquivo. A causa exata ainda não foi isolada, e
  o ticket começa por ela.
- Nenhuma checagem de versão do bash no topo, porque o script tem de rodar no 3.2.

### Conjunto de cenários do `anvil-plan`

- Oito cenários: os seis desvios (`anvil-research`, `anvil-prototype`,
  `anvil-to-questionnaire`, `anvil-wayfinder`, `anvil-ui`, `anvil-architect`)
  saindo do grill, um desvio saindo do to-spec e um saindo do to-tickets. Cada
  cenário tem um roteiro de operador cuja fala carrega o sinal do desvio.
- Três rodadas por cenário, com o modelo padrão do ponta a ponta da 003.
- Conferência por código sobre as sessões gravadas:
  - **invariante**: nenhuma skill de etapa ou de desvio é lida sem a proposta no
    turno anterior e o sim do operador. Tem de valer nas 24 rodadas;
  - **medido**: o desvio proposto é o do sinal; depois do desvio, a volta à etapa
    de origem é proposta. Reportados por cenário, como rodadas certas sobre três;
  - **modelo**: cada rodada registra o modelo que respondeu, e rodada com modelo
    diferente do pedido não conta.
- O resultado de cada cenário mostra também o pass^3, a chance de as três rodadas
  passarem, que é a métrica de consistência do τ-bench e do guia de avaliação de
  agentes da Anthropic.

## Testing Decisions

Um bom teste aqui observa o que o operador ou o supervisor veria: as linhas que o
script devolve para uma pasta de spec montada em disco, a recomendação que o
supervisor dá, a saída do `verify`. Não se testa a forma interna do script, nem o
texto da skill.

Fronteiras, confirmadas com o operador:

1. **Saída do `frontier.sh` e do `stage.sh`**, sobre repositórios montados em
   `/tmp`, em `/opt/local/bin/bash` e `/bin/bash`, com saída idêntica nos dois.
   Cobre bloqueios, P1 do travado, tela em `LC_ALL=C` e em UTF-8, chaves novas,
   perfil do tracker, `ready` e o texto da parada. Precedente: os fixtures em
   `/tmp` do review dos tickets 08 e 09 da 003, e a seção 7j do S1
   (`workspace/29-codex-mirror/s1.sh`), que roda nos dois bash.
2. **Recomendação e laço do supervisor**, no S2 da `anvil-run`
   (`workspace/33-omp-run/s2.sh`), com o implementer de mentira do próprio S2.
   Cenários a acrescentar: uma spec cuja user story descreve tela só com palavras
   que o script não reconhece, que tem de receber `/skill:anvil-browser-qa`; a
   leitura das chaves novas sem mudança de comportamento nos cenários existentes;
   o modo com isolação, com o relatório dizendo o modo; o pedido de paralelo sem
   isolação, recusado; uma leva de dois tickets com isolação, com o script relido
   depois da leva.

Fora dessas duas, sem fronteira nova:

- O `verify` pelo S3 (`workspace/31-omp-verify/s3.sh`), que monta cópias do
  repositório com um defeito por caso: um caminho errado só dentro do bloco
  `bash` de uma skill da camada tem de reprovar no check 15; o S3 inteiro roda sob
  `/bin/bash` 3.2 e dá a mesma saída do bash 5.
- O conjunto de cenários do `anvil-plan` é ele mesmo a prova do A7. Precedente: o
  S2 da `anvil-plan` (`workspace/34-omp-plan/s2.sh`) e o `check.sh` com o
  `plan_check.py` do ponta a ponta (`workspace/35-omp-e2e/`), que já confere
  proposta antes da carga e o modelo por turno.
- O ponta a ponta da 003 roda de novo uma vez, sem isolação, para mostrar que a
  troca de chaves não mudou o caminho inteiro.

Prova de cenário probabilístico segue o registro da 003: número de rodadas,
quantas passaram e o modelo que respondeu.

## Out of Scope

- **Adaptador de tracker.** Frontier e retomada lendo issues do GitHub, do GitLab
  ou de markdown local. Pede decidir como spec e ticket aparecem em cada tracker,
  que é decisão de grill, e não há projeto usando outro perfil com omp. Fica como
  linha de acompanhamento.
- Resolver conflito de integração automaticamente, por modelo ou por ferramenta.
- Paralelo sem isolação, ou com worktree gerido pelo anvil em vez do omp.
- Paralelo no `anvil-plan`. O planejamento continua numa janela só.
- Modelo por papel no omp.
- Mudar skill vendorizada, inclusive o template de ticket da `anvil-to-tickets`,
  que aceita títulos no `Blocked by`.
- Usar o conjunto de cenários como trava de merge ou rodá-lo em CI.
- Alterar a spec 003 arquivada.

## Further Notes

- O paralelo revê em parte a alternativa descartada do ADR-0011, "frontier em
  paralelo com worktree isolado". O ticket que o implementa escreve o ADR-0012,
  com o que a conferência do conflito no omp mostrar.
- Comportamento da isolação lido em `omp://tools/task.md` (omp 18.2.11):
  - `isolated` por item do `task`, disponível só com `task.isolation.enabled`;
  - modo branch commita em `omp/task/<id>` e faz cherry-pick no branch de origem;
  - o workspace isolado é sempre limpo no fim.
- Base de mercado, da pesquisa que originou esta spec:
  - fail-closed para parser de controle ([AuthZed](https://authzed.com/blog/fail-open));
  - um registro por achado, com classe em campo próprio ([reviewdog rdformat](https://github.com/reviewdog/reviewdog/blob/master/proto/rdf/README.md));
  - contrato de saída estável, separado da mensagem, como o `--porcelain` do git
    ([Git](https://git-scm.com/book/en/v2/Git-Internals-Plumbing-and-Porcelain));
  - um workspace isolado por agente e integração num ponto só
    ([Augment Code](https://www.augmentcode.com/guides/how-to-run-a-multi-agent-coding-workspace));
  - conflito em 27,67% dos PRs de agentes ([AgenticFlict](https://arxiv.org/pdf/2604.03551));
  - pass^k e leitura de sessões
    ([Anthropic](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents),
    [τ-bench](https://arxiv.org/pdf/2406.12045)).
- O arquivamento desta spec tira as linhas A1 a A11 de
  `docs/project/acompanhamento.md` e deixa no lugar do A9 uma linha só para o
  adaptador de tracker.
- Glossário: *Condutor*, *Camada de harness* e *Frontier* em
  `docs/architecture/context.md`. *Travado* e *bloqueio ilegível* não são termos
  do glossário. O primeiro já é usado na 003, e o segundo nasce aqui.
