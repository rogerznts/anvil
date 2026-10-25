# 11: Cada consumidor do resolvedor para só pelo campo de que precisa

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=a4ec4f4; scope=full; verdict=pass; p1=none

**What to build:** decisão do operador depois do ticket 10. Hoje uma recusa
qualquer do resolvedor esconde todos os valores, e uma recusa de forge ou de login
impede abrir spec, começar o piloto e limpar branches num Gitea sem `tea` ou sem a
seção `## Git`, mesmo com o branch base claro. O resolvedor passa a dar os valores
que resolveu e a dizer o campo de cada recusa, só procura o login do `tea` quando
um PR vai sair, e cada consumidor para só pelo que precisa. O fechamento do piloto
olha as rules antes do forge.

- [x] Os valores resolvidos saem sempre; cada recusa sai como
      `refusal: base: …`, `refusal: forge: …` ou `refusal: login: …`; com qualquer
      recusa, a saída é `2`. O cabeçalho do script diz o contrato.
- [x] O login só é procurado com `--pr`; sem a opção, o `tea` não é chamado e não
      sai `login:` nem recusa de login.
- [x] O `new-spec.sh`, o `stage.sh` (a largada do piloto), o `anvil-prune-branches`,
      o `anvil-bench` e o `roadmap.sh` conferem só o `base:`; o `anvil-open-pr` e o
      `anvil-open-fast-pr` chamam com `--pr` e conferem o branch base, o forge, o
      repositório e o login.
- [x] O fechamento do piloto: sem remoto, merge local; uma rule que manda fechar
      sem PR, merge local, sem consultar o forge; senão o `forge:` decide, e a
      recusa dele deixa a spec parada.
- [x] O `roadmap.sh` cita o branch base no motivo da spec arquivada no branch e sem
      merge.
- [x] O `new-spec.sh` acha o resolvedor por caminho absoluto, e funciona chamado
      por caminho relativo de uma subpasta.
- [x] O manual `anvil-omp` descreve a recusa da largada e a ordem do fechamento
      como o piloto as segue.
- [x] Prova S1, num diretório novo de `workspace/`, com
      `workspace/69-git-resolver/` e `workspace/75-pilot-on-base/` como prior art,
      no bash do `PATH` e no `/bin/bash` 3.2: num Gitea sem `tea` no `PATH` e num
      host desconhecido sem a seção, o resolvedor dá o `base:` com a recusa de
      forge ou de login marcada pelo campo; o `new-spec.sh` cria a spec; o
      `stage.sh` dá a linha `base`; com `--pr`, a recusa de login aparece; sem
      `--pr`, o `tea` falso não é chamado; o `new-spec.sh` por caminho relativo de
      uma subpasta funciona; o `roadmap.sh` com `master` cita o `master` no motivo.
      As S1 de 69 e 75 continuam passando, com as expectativas da recusa ajustadas
      ao formato novo.
- [x] Prova S2 pelo helper, com `/skill:anvil-auto`, num diretório novo de
      `workspace/`, com `workspace/76-pilot-closes-by-pr/` como prior art: a
      largada no branch base `master` de uma entrada nova, com o
      `checkout -B <branch> master` depois do `new-spec.sh`; e uma fixture com
      `forge: github` e uma rule que manda fechar sem PR, em que o piloto fecha por
      merge local e o log do forge não tem `pr create`. O código do helper sai nas
      saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o resolvedor recebe `[--pr]` e qualquer outro argumento é recusa.
  Saem `base:`, `forge:`, `remote:`, `host:`, `repo:` e, só com `--pr` no Gitea,
  `login:`, cada um quando resolvido, e depois deles uma linha
  `refusal: <campo>: <motivo>` por recusa; com qualquer recusa a saída é `2`. O
  campo recusado não sai. O `remote:` e o `repo:` saem sempre que há repositório,
  e o `host:` só falta quando o `ssh -G` não acha o host real do alias. Leituras que
  a spec não fixava: o host real que não se acha e o caminho do origin sem
  `org/repo` (com `gitea` ou `github`) são `refusal: forge:`, porque sem eles não há
  onde abrir PR e só os três campos da spec são campos de recusa; argumento
  desconhecido e chamada fora de um repositório git saem só com uma
  `refusal: base:`, porque todo consumidor confere o `base:`. O `remote:`, o
  `host:` e o `repo:` passam a ser lidos antes do forge, e saem também quando o
  forge é recusado.
- Implementação · o `new-spec.sh` acha o resolvedor pelo caminho físico do próprio
  diretório (`cd -P`) e mostra, sem o `base:`, só as linhas `refusal: base:`, como
  `erro:`; o `stage.sh` dá, sem o `base:`, só as recusas do campo base em
  `base_refusal:`; o `roadmap.sh` roda o resolvedor ao lado dele, uma vez, só quando
  acha uma spec arquivada no branch e sem merge, e o motivo diz "sem merge no
  branch base <nome>" (ou só "branch base" sem o `base:`). O `anvil-prune-branches`
  para só sem a linha `base:`; o `anvil-bench`, sob o piloto, escreve o
  `branch base:` do resolvedor e o `forge:` só quando ele sai; o `anvil-open-pr` e o
  `anvil-open-fast-pr` rodam o resolvedor com `--pr` e param com qualquer recusa.
- Implementação · fora da lista do ticket, mas preso ao contrato: o `anvil-boot`
  passa a dizer que o resolvedor dá os valores e as recusas por campo, e o exemplo
  da recusa depois de escrever a seção troca o "login do `tea` ambíguo", que sem
  `--pr` não sai mais, por "forge que não se resolve".
- Implementação · no `anvil-auto`, o passo 4 da largada diz que só a recusa do
  branch base para a largada; o fechamento roda o resolvedor e decide nesta ordem —
  `remote: none`, merge local; rule que fecha sem PR ou perfil sem o
  `/anvil-open-pr`, merge local, sem olhar `forge:` nem `refusal: forge:`; senão
  `refusal: forge:` deixa a spec parada, `nenhum` fecha por merge local e
  `github`/`gitea` por PR. A recusa que para o `anvil-open-pr` (a de login, que só
  sai com `--pr`) também deixa a spec parada, e a lista da "Parada" passou a dizer
  isso. O manual `anvil-omp` acompanha.
- Implementação · a S2 achou dois defeitos do texto do piloto, corrigidos no
  segundo commit: o commit do `Spec:` e o `git checkout -B` saíam em duas chamadas
  paralelas, o checkout vinha antes e o `Spec:` caía no branch da spec, e não no
  branch base (`workspace/81-pilot-base-and-rule/out-largada-r1/`); e o piloto
  procurava a rule de fechar sem PR por `grep "merge local"`, não achava
  "`git merge` local no `master`, sem PR" e abria o PR (`out-regra-r1/`). O passo 3
  de "Abrir a spec" passou a dar os dois comandos num só, com `&&`, e o passo 2 do
  fechamento manda ler cada arquivo de `.claude/rules/` inteiro, com o `read`.
- Implementação · com o login só procurado no `anvil-open-pr`, um Gitea sem login
  do `tea` casando recusa depois do `git push -u origin <branch>` do "PR" do piloto,
  e não antes, como no texto de antes: o branch fica publicado sem PR, com a spec
  parada. É o que a spec decidiu ("o login só com `--pr`"); mover o push para
  depois do Step 0 do `anvil-open-pr` é decisão do operador.
- Prova S1 · `workspace/80-resolver-refusal-per-field/s1.sh`, no bash 5.2 e no
  `/bin/bash` 3.2, 20 conferências por bash, verde em `s1.out`: Gitea declarado sem
  `tea` no `PATH` (um `PATH` de espelhos sem o `tea`), sem `--pr` sai `0` sem
  `login:` e com `--pr` dá `refusal: login:` com os valores; host desconhecido sem
  a seção dá `base: master` e só a `refusal: forge:`; o `stage.sh` (com um `HOME` de
  fixture) dá `base: master` nos dois, e o `new-spec.sh` cria a spec nos dois; o
  `new-spec.sh` por caminho relativo de `sub/` cria a pasta na raiz; o `tea` falso
  não é chamado sem `--pr` e dá o login com `--pr`, ou a recusa dele; com `main` e
  `master` e host desconhecido, o `stage.sh` e o `new-spec.sh` mostram só a recusa
  do base; fora do git, `refusal: base:`; o `roadmap.sh` com `master` diz "sem
  merge no branch base master". O vermelho, com o payload de 179bc78
  (`s1.sh --vermelho`), tem 36 falhas (`s1-red.out`). A S1 de
  `workspace/69-git-resolver/` passou a conferir o campo da recusa e a ausência da
  linha dele, com os casos de login por `--pr`, e passa (`s1.out`); a de
  `workspace/75-pilot-on-base/` passa sem mudança.
- Prova S2 · `workspace/81-pilot-base-and-rule/s2.sh`, pelo helper com `--remote
  --forge`, dependências `anvil-docs` e `anvil-to-spec`, modelo
  `claude-sonnet-4-5`. `largada`: a vez começa no `master`, origin em
  `https://git.loja.test/acme/loja.git` sem a seção (o resolvedor dá `base: master`
  e `refusal: forge:`); o roteiro como está no primeiro turno e o sim no segundo; o
  `new-spec.sh`, a volta ao `master`, o commit do `Spec:` no `master` e o
  `git checkout -B feature/001-conta-linhas master`, com o primeiro commit do branch
  filho do commit do `Spec:`; no fechamento, a recusa de forge deixa a spec parada,
  sem merge, sem push e sem `pr create`. `regra`: retomada no branch da 001, origin
  em `github.com`, `forge: github` declarado e a rule "fecha … com `git merge` local
  no `master`, sem PR": merge local no `master`, sem push, sem ler o
  `anvil-open-pr` e sem `pr create` no log do forge. Código do helper: `largada` 0 e
  `regra` 0 (`s2-largada.out`, `s2-regra.out`); vermelho da largada com o payload
  de 179bc78, código 1 (`s2-red-largada.out`); a primeira rodada, com o texto de
  dbb34ee, código 1 nos dois (`s2-largada-r1.out`, `s2-regra-r1.out`).
- Verificação · `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` saiu
  `0` (`verify: limpo`), com a saída em `workspace/80-resolver-refusal-per-field/verify.out`.
- Review round=1 · P2 (Spec): a ordem "rule antes do forge recusado", centro da US 39 (a rule que manda fechar sem PR não para num forge não resolvido), não tem prova: o caso `regra` da S2 usa `forge: github` resolvido e não tem vermelho — um texto que volte a olhar a `refusal: forge:` antes da rule passa nas duas S2, e um Gitea sem a seção cuja rule fecha por merge local volta a parar sem aviso.
- Review round=1 · P2 (Spec): no "PR" do `anvil-auto`, o `git push -u origin <branch>` vem antes do Step 0 do `anvil-open-pr`, onde o login é procurado; num Gitea sem login do `tea` casando, o branch fica publicado sem PR, e nem a "Parada" nem o relatório dizem que ele ficou no remoto — o operador só descobre ao achar o branch órfão.
- Review round=1 · P2 (Spec): a limpeza seguindo com uma `refusal: forge:` (US 36, limpar branches) e o bench escrevendo a seção sem a linha `forge:` não têm prova — um texto que volte a parar em qualquer recusa passa sem acusar.
- Review round=1 · P3 (Spec): o passo 4 da largada do `anvil-auto`, o cabeçalho do `stage.sh` e o manual `anvil-omp` citam a recusa de login (e o "Gitea sem `tea`") como uma que a largada ignora, mas sem `--pr` ela nem sai — o leitor espera na largada uma recusa que não acontece; a regra de não parar continua certa.
- Review round=1 · P3 (Spec): com `forge: nenhum` declarado e o host ssh que não se acha, o resolvedor dá `refusal: forge:`, contra o próprio cabeçalho ("sem os quais não há onde abrir PR") e a isenção do `nenhum` — no fechamento a spec para em vez de fechar por merge local; comportamento herdado do ticket 01, caso raro.
- Review round=1 · P3 (Spec): no `s2.sh`, a linha final "conferências 0" mostra o código de saída das conferências, não uma contagem — nas saídas verdes parece "nenhuma conferência".
- Review round=1 · P3 (Standards): o comentário novo do `roadmap.sh` (`base_label`) tem acento, e o resto do arquivo é ASCII — só a forma fica inconsistente.
- Review round=1 · P3 (Standards): possível Mysterious Name — `base_name` no `roadmap.sh` guarda o rótulo "branch base master", não o nome do branch; quem reaproveitar a variável num comando git recebe a frase inteira.
- Review round=1 · P3 (Standards): o `refuse()` do `resolve-git.sh` marca argumento desconhecido e chamada fora do git como `refusal: base:` (escolha documentada no cabeçalho) — um consumidor futuro que traduza `refusal: base:` em "declare o branch base" dá o conselho errado.
- Review round=1 · P3 (Standards): possível Duplicated Code / Shotgun Surgery — o `new-spec.sh` e o `stage.sh` repetem o parse do resolvedor (o `base:`, o filtro de `refusal: base:` e a mensagem de reserva), e o parágrafo do Step 0 se repete no `anvil-open-pr` e no `anvil-open-fast-pr`; o padrão de skill autocontida vence, mas a próxima mudança de formato repete as edições espalhadas.
