# 04: Nada fora de commit chega à `main`, e o rascunho parado fica no branch

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** o piloto confere a árvore antes de toda volta à `main` no
fechamento, e não só na "Parada": o que o archive ou o `tea-open-pr` deixarem
fora de commit para a execução, com os arquivos no motivo, em vez de ir para a
`main` com ele. E, quando uma contradição incumprível para a spec enquanto o
piloto escreve a spec ou os tickets, o rascunho é commitado no branch dela antes
da parada, para que só a spec pare e a corrente siga.

- [ ] Antes de todo `git checkout main` do fechamento (depois do commit do archive
      no merge local e, no PR, depois do push da linha `PR:`), o piloto confere
      `git status --porcelain`. Com linha na saída, a execução para, como diz "Fora
      do caminho feliz", com os arquivos no motivo.
- [ ] Com a contradição incumprível achada antes de os tickets estarem completos,
      o que o piloto escreveu na pasta da spec é commitado no branch, só essa
      pasta, com uma mensagem em inglês que diz que a spec parou num rascunho, e só
      então vale a "Parada".
- [ ] Prova S2 (prior art `workspace/48-auto-stops/`), num diretório novo de
      `workspace/`: um hook que deixa arquivo fora de commit depois do archive faz
      a execução parar antes de voltar à `main`, e a `main` não recebe o arquivo;
      uma entrada cuja contradição incumprível aparece ao escrever os tickets
      deixa o rascunho commitado no branch, a spec para, e a entrada independente
      fecha. O S2 registra o modelo que de fato respondeu.
- [ ] `vendor-sync.sh verify` sai `0`.
