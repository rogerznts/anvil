# 04: Nada fora de commit chega à `main`, e o rascunho parado fica no branch

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** o piloto confere a árvore antes de toda volta à `main` no
fechamento, e não só na "Parada": o que o archive ou o `tea-open-pr` deixarem
fora de commit para a execução, com os arquivos no motivo, em vez de ir para a
`main` com ele. E, quando uma contradição incumprível para a spec enquanto o
piloto escreve a spec ou os tickets, o rascunho é commitado no branch dela antes
da parada, para que só a spec pare e a corrente siga.

- [x] Antes de todo `git checkout main` do fechamento (depois do commit do archive
      no merge local e, no PR, depois do push da linha `PR:`), o piloto confere
      `git status --porcelain`. Com linha na saída, a execução para, como diz "Fora
      do caminho feliz", com os arquivos no motivo.
- [x] Com a contradição incumprível achada antes de os tickets estarem completos,
      o que o piloto escreveu na pasta da spec é commitado no branch, só essa
      pasta, com uma mensagem em inglês que diz que a spec parou num rascunho, e só
      então vale a "Parada".
- [x] Prova S2 (prior art `workspace/48-auto-stops/`), num diretório novo de
      `workspace/`: um hook que deixa arquivo fora de commit depois do archive faz
      a execução parar antes de voltar à `main`, e a `main` não recebe o arquivo;
      uma entrada cuja contradição incumprível aparece ao escrever os tickets
      deixa o rascunho commitado no branch, a spec para, e a entrada independente
      fecha. O S2 registra o modelo que de fato respondeu.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- O "Fechamento" do `anvil-auto` ganhou a conferência da árvore antes de toda volta à `main`: no merge local, logo depois do commit do archive; no PR, depois do push da linha `PR:`. Com linha no `git status --porcelain`, a execução para por "Fora do caminho feliz", com os arquivos no motivo, sem voltar à `main`, sem merge e sem mexer nos arquivos. O "Merge local" passa a abrir com "Com a árvore limpa" e o "PR" confere a árvore antes do `git checkout main`. Na "Contradição com o roteiro", o critério incumprível achado antes de os tickets estarem completos commita no branch só a pasta da spec, com `docs(spec): stop spec <number> at a draft`, e só então segue a "Parada"; sem nada novo na pasta, não há commit. "Fora do caminho feliz" já listava "caminho fora de commit quando a spec para ou fecha" e não mudou.
- Prova S2: `workspace/55-auto-clean-tree/s2.sh`, retomadas no branch da spec 001 sobre fixtures derivadas da do `workspace/48-auto-stops/`, com `omp -p --mode json --model claude-sonnet-4-5 --thinking off`, projeto sem remoto, fechando por merge local. O modelo que respondeu é lido do jsonl da sessão principal.
  - Caso S, árvore suja no fechamento: um hook `post-commit` da fixture, no commit que arquiva a spec 001, deixa `sobra.txt` fora de commit. Vermelho, com o texto de antes (`out-red/S`, `s2-red-S.out`): o piloto voltou à `main` e fez o merge, o `sobra.txt` foi junto para a árvore da `main` e entrou em commit (a conferência de nenhum commit com ele caiu), e a corrente seguiu e fechou a spec 002 da `ultima-linha`; 6 falhas. Verde (`out/S`, `s2-S.out`): `git status --porcelain` logo depois do commit do archive, a vez termina no branch da 001 com o `sobra.txt` no motivo, a `main` como a fixture a deixou, nenhum commit com o `sobra.txt`, nenhum merge, e a `ultima-linha` independente não começa; `S2: tudo passou`, 11 conferências. Respondeu só o `anthropic/claude-sonnet-4-5` nas duas rodadas (65 e 34 mensagens).
  - Caso D, rascunho parado: a spec 001 tem a `spec.md` commitada e nenhum ticket; o `Pronto quando:` pede o `conta_erros` de `lib.sh`, que não existe, e o `Fica de fora:` proíbe mudar `lib.sh`. A spec da fixture traz a lista dos três tickets e manda rodar, depois de escrevê-los e antes do commit, um `checa-tickets.sh` do projeto, que diz a função que falta. Vermelho, com o texto de antes (`out-red/D`, `s2-red-D.out`): o piloto achou a contradição e voltou à `main` com os três tickets fora de commit; eles entraram no commit `docs(spec): add spec 002` do branch da `ultima-linha` e chegaram à `main` pelo merge dela; 4 falhas. Verde (`out/D`, `s2-D.out`): o branch da 001 ganha `docs(spec): stop spec 001 at a draft`, só com os três tickets da pasta, como último commit; nenhum arquivo da pasta chega à `main`, nada é despachado, `lib.sh` não muda, a 002 nasce da `main` e fecha com merge, e o relatório leva a 001 em "o que ainda espera decisão"; `S2: tudo passou`, 16 conferências. Respondeu só o `anthropic/claude-sonnet-4-5` (63 e 71 mensagens).
  - Duas fixtures de D anteriores ficaram em `out-r1/`, `out-r2/`: sem o passo de conferência depois de escrever, o piloto leu o `lib.sh` antes de escrever qualquer ticket, rodou o commit do rascunho sem nada novo e parou a spec, como o texto novo manda, e o commit do rascunho não teve o que provar. Daí a ordem que a fixture impõe; em `out-r3/` ficou a primeira rodada verde, antes da conferência de vazamento. Em duas vezes (`out-r4/D` e a primeira tentativa do vermelho de S), o modelo leu a skill e parou pedindo um pedido, sem rodar a largada, no branch da spec — instabilidade do modelo, fora deste ticket.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0.
