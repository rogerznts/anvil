# 06: Spec que não fecha sozinha fica aberta, e a corrente segue pelo que não depende dela

**Blocked by:** 05

**Status:** resolved

**What to build:** o piloto trata as paradas que não são técnicas. Uma spec sem
`PASS`, com ticket travado ou com conflito de merge fora do `docs/index.md` fica
aberta no branch dela. O piloto volta à `main`, e a corrente segue pelas entradas
que não dependem dela. Num projeto que fecha por PR, o piloto arquiva, abre o PR
pelo `tea-open-pr` e para sem merge. Uma contradição com o roteiro segue a régua
da spec: se o critério ainda é cumprível, o piloto adapta e registra "decidido
sem humano"; se não é, para a entrada. A parada antes de a spec nascer usa o
`--skip` do `roadmap.sh` na mesma execução. Chamado no branch de uma spec aberta,
o piloto retoma a spec pelo `stage.sh` e pelo `frontier.sh` e depois segue a
corrente a partir da `main`. O relatório diz onde a corrente parou, por quê, e o
que ainda espera decisão, com cada item escrito como pergunta.

A pesquisa antes de travar fica com o ticket 07. Aqui a parada técnica vai direto
para o relatório.

- [x] Uma spec sem `PASS` fica aberta no branch, o piloto volta à `main`, e a
      próxima entrada independente nasce de um branch novo saído da `main`.
- [x] Uma entrada que depende, direta ou indiretamente, da spec parada não
      começa, e a corrente termina quando o `next` vira `none`.
- [x] Num projeto que fecha por PR (pela regra do perfil do tracker mais as
      rules), o piloto faz archive, abre o PR e não faz merge. A entrada fica
      `stopped` até o merge, e as dependentes esperam.
- [x] Um projeto sem remoto fecha por merge local, mesmo que o perfil fale de PR.
- [x] Um conflito de merge fora do `docs/index.md` aborta o merge e deixa a spec
      parada, sem resolução automática.
- [x] Antes de criar a spec, o piloto confere a entrada contra o código. Com
      critério incumprível, a entrada vai para o `--skip` desta execução, sem
      `Spec:` e sem branch, e a contradição vai para "o que ainda espera decisão".
- [x] O piloto nunca edita `Entra:`, `Fica de fora:` nem `Pronto quando:`.
- [x] Uma contradição achada depois que a spec nasceu, com critério ainda
      cumprível, é adaptada dentro da spec e registrada como "decidido sem
      humano". Com critério incumprível, a spec fica parada.
- [x] Chamado no branch de uma spec aberta, o piloto retoma do ponto indicado
      pelo disco e depois segue a corrente.
- [x] O `report.md` é commitado na `main` também quando a spec fica parada ou com
      PR aberto, e quando o piloto para antes de uma spec. Ele diz onde a
      corrente parou e termina em "o que ainda espera decisão", com perguntas.
- [x] S2: fixture com ticket travado já gravado e comando de verificação saindo
      `1`, em que a dependente não começa e a independente segue; caso de PR sem
      merge; caso de retomada.

## Comments

- Implementação: o `anvil-auto` ganhou as seções "Retomada", "Conferir a
  entrada", "Contradição com o roteiro" e "Parada", e o "Fechamento" passou a
  decidir entre merge local e PR, com `git remote` primeiro e o perfil do tracker
  mais as rules depois. O laço da corrente ganhou o passo de conferir a entrada e
  o `--skip` do `roadmap.sh`. A largada troca a recusa no branch de uma spec
  aberta pela retomada, e manda ignorar a linha `do:` do `stage.sh`, que é da
  `anvil-plan`. O relatório ganhou os estados de parada, PR aberto e parada antes
  da spec, e o commit dele passou a citar a entrada, porque a entrada pulada não
  tem número.
- Decisões tomadas pelo repositório, sem operador:
  - Retomada só de spec do roteiro: no branch de uma spec cujo número não está no
    `Spec:` de nenhuma entrada, o piloto recusa e aponta a `anvil-plan` e a
    `anvil-run`, porque sem a entrada não há `Pronto quando:` para medir.
  - O `halt` do `frontier.sh` e qualquer caminho fora de commit numa parada param
    a execução inteira, sem relatório na `main`: voltar à `main` com a árvore suja
    levaria o que sobrou junto, e o `halt` diz que a saída é do operador.
  - No PR, o piloto faz `git push -u` antes do `tea-open-pr` e `git push` depois
    do commit da linha `PR:`, porque o `tea-open-pr` não leva o branch ao remoto.
    A base do PR é a `main`, e o responsável fica vazio sem indicação nas rules.
  - O ticket que parou numa pergunta que a adaptação de uma contradição cumprível
    responde volta ao despacho uma vez só.
- S2 em `workspace/48-auto-stops/s2.sh`, sobre fixtures em `/tmp`, com
  `MODELO=sonnet`; pelo jsonl, o omp atendeu por fallback com o
  `openai-codex/gpt-6.1-sol`, como nos tickets anteriores. Todo caso começa no
  branch da spec 001, o que faz de cada um uma retomada. A prova vermelha, com a
  skill do ticket 05, está em `out-red/`: os quatro casos recusam na largada.
  - T: ticket 01 travado em `round=2`, o 02 dependendo dele e `bash verifica.sh`
    saindo `1` no branch. A 001 ficou no branch sem commit novo, `conta-erros` não
    começou, `muda-legado` foi para o `--skip` sem `Spec:` nem branch, e
    `ultima-linha` nasceu como 002 de um branch saído da `main` e fechou. Houve
    dois commits de relatório antes do `Spec: 002`, um por parada.
  - P: remoto bare e `tea` como stub no `PATH`. Archive, push, PR com
    `--base main`, linha `PR:` no ticket levada ao remoto, nenhum merge;
    `conta-linhas` ficou `stopped` à espera do PR, e `conta-erros` não começou.
  - R: retomada com o ticket 02 a despachar, num projeto sem remoto cujo perfil
    fala de PR. Um `anvil-implementer` só, para o 02, e merge local.
  - M: um hook commita na `main` outra mudança no fim do `lib.sh` depois do
    archive. O merge parou em conflito no `lib.sh`, foi abortado, e a spec ficou
    parada.
- Limite do S2: o dev-link não liga o `tea-open-pr` nesta máquina. Na primeira
  rodada do P, `out/P-r1/`, o piloto não achou a skill e parou sem PR nem merge.
  A fixture final o expõe como skill do projeto, fora do git, como numa
  instalação publicada.
- Limite do S2: nenhum caso exercita a contradição achada depois que a spec
  nasceu, nem a decisão aberta do `map.md`, nem a guarda bloqueando um merge
  indevido. Essas regras estão na skill e não foram vistas rodando.
- Observação sobre a spec: o `roadmap.sh` dá a spec arquivada no branch e sem
  merge como "espera o merge do PR", também quando o merge local foi abortado por
  conflito, num projeto sem PR. No caso M, o piloto corrigiu o motivo no
  relatório, mas o índice mostra o motivo do script.
