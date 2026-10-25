# 012 — Push só depois do login, aviso de branch publicado e provas da 011

**Status:** ready-for-agent

Extensão da 011 (`docs/specs/archive/011-extension-branch-base-and-forge/`), decidida
no grill de 2026-10-25. Ela resolve quatro linhas de `docs/project/acompanhamento.md`:

- **A35:** o piloto publica o branch antes de saber se o PR sai;
- **A36:** a ordem "rule antes do forge recusado" não tem prova;
- **A37:** a limpeza e o bench seguindo com recusa de forge não têm prova;
- **A29:** a parada no fechamento tem três nomes no `anvil-auto`.

Os termos **Piloto automático**, **Parada**, **Parada no fechamento**, **Branch
base**, **Forge** e **Prova** são os de `docs/architecture/context.md`. As duas
entradas de parada nasceram neste grill.

## Problem Statement

- **Branch órfão no remoto.** No fechamento por PR, o piloto automático faz o
  `git push -u origin <branch>` e só depois carrega o `anvil-open-pr`, cujo primeiro
  passo roda o resolvedor com `--pr` e procura o login do `tea`. Num Gitea sem login
  que case com o host, a recusa chega com o branch já publicado: a spec fica
  parada, o branch fica no remoto sem PR, e o operador só descobre ao achar o
  branch órfão.
- **Parada sem dizer onde o branch está.** Parar depois do push não acontece só
  por login: o CLI pode estar sem autenticação, ou o `pr create` pode falhar. Em
  nenhum desses casos a "Parada" ou o relatório dizem que o branch foi publicado.
- **Três nomes para um caso.** O `anvil-auto` chama a parada de uma spec já
  arquivada que não chega ao branch base de "não fecha no fechamento", "parada no
  fechamento depois do archive" e "parada, já arquivada no branch". Quem lê casa
  três nomes, e uma regra nova pode acertar um e esquecer os outros.
- **Duas decisões da 011 sem prova.** A rule que manda fechar sem PR decide antes
  de um forge recusado (US 39 da 011), e a limpeza de branches e o bench seguem com
  uma recusa de forge (US 36 da 011). As duas têm verde, mas nenhum vermelho: um
  texto que volte a olhar o forge antes da rule, ou a parar em qualquer recusa,
  passa sem acusar.

## Solution

- **O login antes do push.** No fechamento por PR, o piloto roda o resolvedor com
  `--pr` antes do `git push`. Uma recusa dele deixa a spec em parada no fechamento,
  e nada vai para o remoto.
- **Uma resolução só por PR.** O piloto entrega ao `anvil-open-pr` o branch base, o
  repositório e o login que já conferiu, como o `anvil-open-fast-pr` faz, e o
  `anvil-open-pr` não chama o resolvedor de novo.
- **O aviso de branch publicado.** Quando o push deu certo e nenhuma URL de PR
  voltou, o `Estado:` da spec no relatório diz que o branch está publicado em
  `origin` sem PR. "O que ainda espera decisão" pergunta se é para corrigir o
  motivo e abrir o PR ou apagar o branch remoto. O piloto nunca apaga o branch
  remoto.
- **Um nome só.** "Parada no fechamento" substitui os três nomes.
- **As provas que faltam**, com vermelho medido no código de antes de cada
  mudança.

## User Stories

1. Como operador de um Gitea sem login do `tea` que case com o host, quero que o
   piloto pare antes do `git push`, para que nenhum branch fique no remoto sem PR.
2. Como operador, quero que a parada por recusa de login traga a recusa no motivo,
   copiada como o resolvedor a dá, para saber qual `tea login` rodar.
3. Como operador, quero que qualquer recusa do resolvedor com `--pr` no fechamento
   por PR, de branch base, forge ou login, pare a spec antes do push, porque o PR
   precisa de todos esses valores.
4. Como operador, quero que o PR saia para o mesmo branch base e pelo mesmo login
   que o piloto conferiu antes do push, para que a conferência e o PR não
   discordem.
5. Como operador, quero que o resolvedor com `--pr` rode uma vez por PR no
   fechamento do piloto, como no PR rápido, para que não haja uma segunda resposta
   para comparar.
6. Como operador cujas rules mandam fechar sem PR, quero que o piloto continue sem
   chamar o `tea`, para que o login só seja procurado quando um PR vai sair.
7. Como operador de um projeto sem remoto, ou com `forge: nenhum`, quero que o
   fechamento continue por merge local, sem procurar o login.
8. Como operador, quero que a parada depois de um push bem-sucedido, sem URL de PR,
   diga no `Estado:` que o branch está publicado em `origin` sem PR, para saber que
   há algo no remoto.
9. Como operador, quero que esse aviso saia qualquer que seja o motivo depois do
   push, como CLI sem autenticação, erro do `pr create` ou outra recusa do
   `anvil-open-pr`, porque o branch fica no remoto em todos.
10. Como operador, quero que "O que ainda espera decisão" pergunte se corrijo o
    motivo e abro o PR ou apago `origin/<branch>`, para decidir o destino do branch
    publicado.
11. Como operador, quero que o piloto nunca apague o branch remoto sozinho, porque
    apagar é destrutivo e a decisão é minha.
12. Como operador, quero que a parada antes do push não fale de branch publicado,
    para que o aviso só apareça quando é verdade.
13. Como operador, quero que a spec parada no fechamento, retomada depois que eu
    corrigi o login ou a autenticação, refaça o push e abra o PR, sem passo à mão.
14. Como operador, quero que o PR aberto à espera do meu merge continue dando o
    `Estado:` de PR aberto, com a URL, e não o aviso de branch publicado.
15. Como leitor do `anvil-auto`, quero um nome só para a parada de uma spec já
    arquivada que não chega ao branch base, "parada no fechamento", para casar cada
    regra com o caso certo.
16. Como leitor, quero que o nome do `anvil-auto` seja o mesmo do glossário, para
    que o relatório, a skill e o glossário falem a mesma língua.
17. Como mantenedor, quero uma prova de que, num Gitea sem login casando, o bare
    não recebe o branch e o `Estado:` traz a recusa de login, com o vermelho medido
    no payload de antes desta spec.
18. Como mantenedor, quero uma prova de que, com o `pr create` falhando depois do
    push, o bare tem o branch e o `Estado:` diz que ele está publicado sem PR.
19. Como mantenedor, quero que o forge falso do helper saiba fazer o `pr create`
    falhar com uma mensagem de autenticação, só quando a prova pede, para provar o
    aviso sem um forge real.
20. Como mantenedor, quero que o forge falso sem esse pedido continue respondendo o
    `pr create` como hoje, para que as provas da 011 sigam valendo.
21. Como mantenedor, quero uma prova de que, num Gitea sem a seção `## Git`, com a
    rule que manda fechar por merge local, o piloto fecha por merge local apesar da
    `refusal: forge:`, com vermelho no payload de antes do ticket 11 da 011.
22. Como mantenedor, quero uma prova de que a limpeza de branches segue com uma
    `refusal: forge:` e atualiza o branch base, com vermelho no payload de antes do
    ticket 11 da 011.
23. Como mantenedor, quero uma prova de que o bench, com uma `refusal: forge:`,
    escreve a seção `## Git` sem a linha `forge:`, com o mesmo vermelho.
24. Como mantenedor, quero que as linhas A29, A35, A36 e A37 saiam de
    `docs/project/acompanhamento.md` no branch desta spec, como manda o cabeçalho
    do arquivo.

## Implementation Decisions

### O fechamento por PR do piloto

- **Ordem nova do "PR":** resolvedor com `--pr`, depois `git push -u origin
  <branch>`, depois o `anvil-open-pr`. A decisão entre merge local e PR continua
  com o resolvedor sem `--pr` e na mesma ordem de hoje: sem remoto, rules, forge.
  O `--pr` só roda quando ela já deu PR.
- **Recusa antes do push:** qualquer linha `refusal:` do resolvedor com `--pr`
  deixa a spec em parada no fechamento, com as linhas no motivo, copiadas como
  estão. Não há push nem `pr create`.
- **Entrega ao `anvil-open-pr`:** o piloto carrega a skill e a segue com uma
  mudança. O Step 0 dela usa o `<base>`, o `<repo>` e o `<login>` do piloto e não
  roda o resolvedor. É a mesma forma do Step 6 do `anvil-open-fast-pr`, a convenção
  que já existe.
- **Aviso de branch publicado:** vale quando o `git push -u` saiu `0` e a skill não
  devolveu URL de PR. A forma do `Estado:` no relatório é:

  ```text
  parada no branch, publicado em origin sem PR: <passo e motivo>
  ```

  Em "O que ainda espera decisão", a pergunta é se o operador corrige `<motivo>` e
  abre o PR ou apaga `origin/<branch>`. Com URL, vale o `Estado:` de PR aberto,
  como hoje.
- **Retomada:** a spec retomada no fechamento refaz o `git push -u`, que não muda
  nada quando o branch já está no remoto, e segue a mesma ordem.
- **Sem limpeza do remoto:** o piloto nunca roda `git push --delete` nem outro
  comando que apague o branch remoto.

### O nome da parada no fechamento

- "Parada no fechamento" substitui "não fecha no fechamento", "parada no
  fechamento depois do archive" e "parada, já arquivada no branch" no `anvil-auto`,
  o único lugar da camada omp que os usa. Os casos listados na "Parada" ficam como
  estão.
- O glossário já tem as entradas **Parada** e **Parada no fechamento**, escritas
  no grill. A spec não muda nenhuma delas.

### O forge falso

- O `pr create` falso, do `gh` e do `tea`, sai `1` com uma mensagem de
  autenticação no stderr quando a execução da prova tem um arquivo de pedido de
  falha, como `pr-create-fails`. A chamada continua no log do forge.
- Sem o arquivo, o comportamento é o de hoje.

### O acompanhamento

- A29, A35, A36 e A37 saem de `docs/project/acompanhamento.md` no branch da spec.
  O parágrafo de origem da seção da 011 deixa de citar a A35 a A37. A seção da 010
  perde a A29 e continua com a A27 e a A28.

## Testing Decisions

Uma prova boa roda o comportamento pelo caminho real e confere o que fica no disco
e no remoto: o bare, o log do forge, o relatório e o branch base. Ela nunca confere
o texto da skill. Cada S2 tem vermelho medido no código de antes da mudança que
ela cobre, e nenhum vermelho vem de um texto escrito só para falhar. A sessão cujo
modelo não é o pedido é prova inválida e se repete.

### S1 — o forge falso (ampliado)

Prior art: a S1 do helper no ticket 03 da 010 e no ticket 04 da 011. Com o arquivo
de pedido, o `gh pr create` e o `tea pr create` saem `1` com a mensagem de
autenticação, e a chamada fica no log. Sem o arquivo, saem `0` com a URL, como
hoje.

### S2 — o piloto pelo helper (novo)

Prior art: `workspace/81-pilot-base-and-rule/` e as S2 do piloto da 011. Com
`--remote --forge` e as dependências declaradas:

- **login antes do push:** fixture Gitea com um login do `tea` que não casa com o
  host. O bare não recebe o branch, o log do forge não tem `pr create`, e o
  `Estado:` traz a `refusal: login:`. O vermelho é o payload de `4271efd`, em que
  o bare recebe o branch;
- **aviso depois do push:** fixture GitHub com o pedido de falha do `pr create`. O
  bare tem o branch, o `Estado:` diz "publicado em origin sem PR", e "O que ainda
  espera decisão" traz a pergunta do branch remoto. O vermelho é o payload de
  `4271efd`, sem o aviso;
- **rule antes do forge recusado (A36):** fixture Gitea sem a seção `## Git`, com a
  `refusal: forge:` e uma rule que manda fechar por merge local. A spec fecha por
  merge local no branch base, sem push e sem `pr create`. O vermelho é o payload
  de `179bc78`, de antes do ticket 11 da 011.

### S2 — a limpeza e o bench (novo)

- **`/skill:anvil-prune-branches`** com a `refusal: forge:`: a limpeza segue e
  atualiza o branch base. O vermelho é o payload de `179bc78`;
- **o bench** escrevendo a seção `## Git` com a `refusal: forge:`: a seção sai com
  a linha `branch base:` e sem a linha `forge:`. O vermelho é o payload de
  `179bc78`.

### S3 — `vendor-sync.sh verify` (existente)

Sai `0`.

## Out of Scope

- **A30 a A34**, as outras lacunas de prova da 011: são de outras skills e outros
  casos.
- **As linhas das specs 004, 006, 007 e 010**, fora a A29.
- **Mover o push para dentro do `anvil-open-pr`.** O fluxo manual do operador, que
  faz o push e chama a skill, fica como está.
- **Apagar o branch remoto**, pelo piloto ou por qualquer skill.
- **Um forge real nas provas.** O forge falso cobre o login, a falha do
  `pr create` e a listagem.

## Further Notes

- A "Parada no fechamento" do glossário inclui o PR à espera do operador. Nessa
  parada, o branch também está no remoto, mas com PR, e o `Estado:` dele já diz
  isso.
- O `anvil-open-fast-pr` já confere o login antes do push, no Step 0, e não muda.
