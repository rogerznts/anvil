# 11: Cada consumidor do resolvedor para só pelo campo de que precisa

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** decisão do operador depois do ticket 10. Hoje uma recusa
qualquer do resolvedor esconde todos os valores, e uma recusa de forge ou de login
impede abrir spec, começar o piloto e limpar branches num Gitea sem `tea` ou sem a
seção `## Git`, mesmo com o branch base claro. O resolvedor passa a dar os valores
que resolveu e a dizer o campo de cada recusa, só procura o login do `tea` quando
um PR vai sair, e cada consumidor para só pelo que precisa. O fechamento do piloto
olha as rules antes do forge.

- [ ] Os valores resolvidos saem sempre; cada recusa sai como
      `refusal: base: …`, `refusal: forge: …` ou `refusal: login: …`; com qualquer
      recusa, a saída é `2`. O cabeçalho do script diz o contrato.
- [ ] O login só é procurado com `--pr`; sem a opção, o `tea` não é chamado e não
      sai `login:` nem recusa de login.
- [ ] O `new-spec.sh`, o `stage.sh` (a largada do piloto), o `anvil-prune-branches`,
      o `anvil-bench` e o `roadmap.sh` conferem só o `base:`; o `anvil-open-pr` e o
      `anvil-open-fast-pr` chamam com `--pr` e conferem o branch base, o forge, o
      repositório e o login.
- [ ] O fechamento do piloto: sem remoto, merge local; uma rule que manda fechar
      sem PR, merge local, sem consultar o forge; senão o `forge:` decide, e a
      recusa dele deixa a spec parada.
- [ ] O `roadmap.sh` cita o branch base no motivo da spec arquivada no branch e sem
      merge.
- [ ] O `new-spec.sh` acha o resolvedor por caminho absoluto, e funciona chamado
      por caminho relativo de uma subpasta.
- [ ] O manual `anvil-omp` descreve a recusa da largada e a ordem do fechamento
      como o piloto as segue.
- [ ] Prova S1, num diretório novo de `workspace/`, com
      `workspace/69-git-resolver/` e `workspace/75-pilot-on-base/` como prior art,
      no bash do `PATH` e no `/bin/bash` 3.2: num Gitea sem `tea` no `PATH` e num
      host desconhecido sem a seção, o resolvedor dá o `base:` com a recusa de
      forge ou de login marcada pelo campo; o `new-spec.sh` cria a spec; o
      `stage.sh` dá a linha `base`; com `--pr`, a recusa de login aparece; sem
      `--pr`, o `tea` falso não é chamado; o `new-spec.sh` por caminho relativo de
      uma subpasta funciona; o `roadmap.sh` com `master` cita o `master` no motivo.
      As S1 de 69 e 75 continuam passando, com as expectativas da recusa ajustadas
      ao formato novo.
- [ ] Prova S2 pelo helper, com `/skill:anvil-auto`, num diretório novo de
      `workspace/`, com `workspace/76-pilot-closes-by-pr/` como prior art: a
      largada no branch base `master` de uma entrada nova, com o
      `checkout -B <branch> master` depois do `new-spec.sh`; e uma fixture com
      `forge: github` e uma rule que manda fechar sem PR, em que o piloto fecha por
      merge local e o log do forge não tem `pr create`. O código do helper sai nas
      saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
