# 04: Nada fora de commit chega à `main`, e o rascunho parado fica no branch

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=5c3a56cc1e1abb0bc86fa2c7bd07ef4f6fec9b2b; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Standards): a S2 só exercita o merge local num projeto sem remoto, e a conferência da árvore depois do push da linha `PR:` não tem prova executada — uma regressão no caminho do PR só aparece na primeira execução com remoto.
- Review round=1 · P3 (Standards): possível Duplicated Code — o trecho novo do "Fechamento" repete "não volte à `main`, não faça o merge e não mexa nesses arquivos", que "Fora do caminho feliz" já diz, e a mesma conferência com `git status --porcelain` também mora na "Parada"; a regra da árvore suja fica em três lugares, e quem mudar um e esquecer os outros deixa o texto se contradizendo.
- Review round=1 · P3 (Standards): no PR, a conferência aparece no próprio parágrafo do "PR" e de novo na "Parada", que lista o PR aberto e também confere a árvore antes do `git checkout main` — não muda comportamento, mas reforça a ambiguidade, que já existia, sobre se o PR passa pela "Parada" ou vai direto ao relatório.
- Review round=1 · P3 (Standards): o momento da conferência no PR ("no PR, depois do push da linha `PR:`") fica no parágrafo do "Fechamento", antes da escolha entre merge local e PR, e a seção "PR" só aponta de volta — o piloto lê a regra antes de saber o caminho e precisa voltar ao "Fechamento" para saber quando conferir; nada quebra.
- Review round=1 · P2 (Spec): a S2 não exercita a conferência depois do push da linha `PR:` — uma regressão no caminho do PR não seria pega pelo S2, embora o texto esteja certo e o caso da spec só peça o hook depois do archive.
- Review round=1 · P3 (Spec): as fixtures em `/tmp/anvil-55-auto-clean-tree` foram reescritas pelas rodadas verdes, e o vazamento dos tickets do vermelho de D para o commit `docs(spec): add spec 002` só se confere pelo `out-red/D/1.fatos` e pelas linhas `FALHA` — quem auditar depois não reabre o commit vermelho; nenhuma decisão muda.
