# 02: O piloto confere o login antes do push

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** a A35 do acompanhamento. No fechamento por PR, o piloto
automático publica o branch e só depois o `anvil-open-pr` procura o login do `tea`;
num Gitea sem login casando, o branch fica no remoto sem PR. Agora, quando a
decisão do fechamento já deu PR, o piloto roda o resolvedor com `--pr` antes do
`git push -u`. Qualquer recusa dele deixa a spec em parada no fechamento, com as
linhas no motivo, sem push e sem `pr create`. O piloto entrega ao `anvil-open-pr` o
branch base, o repositório e o login que conferiu, e o Step 0 da skill os usa sem
rodar o resolvedor, como no Step 6 do `anvil-open-fast-pr`.

- [x] A decisão entre merge local e PR continua igual: resolvedor sem `--pr`, e a
      ordem sem remoto, rules, forge. O `--pr` só roda quando ela deu PR.
- [x] No "PR" do fechamento, o `resolve-git.sh --pr` vem antes do `git push -u`;
      com qualquer linha `refusal:`, a spec fica em parada no fechamento com as
      linhas copiadas como estão no motivo, sem push e sem `pr create`.
- [x] O `anvil-open-pr`, carregado pelo piloto, usa o `<base>`, o `<repo>` e o
      `<login>` do piloto e não chama o resolvedor de novo; chamado direto pelo
      operador, o Step 0 é o de hoje.
- [x] O manual `anvil-omp` descreve a ordem nova, se descreve o fechamento por PR.
- [x] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge` e as
      dependências declaradas, num diretório novo de `workspace/`, com
      `workspace/76-pilot-closes-by-pr/` e `workspace/81-pilot-base-and-rule/` como
      prior art: fixture Gitea com um login do `tea` que não casa com o host. O bare
      não recebe o branch, o `forge.jsonl` não tem `pr create`, e o `Estado:` do
      relatório traz a `refusal: login:`. Vermelho: o payload de `4271efd`, em que o
      bare recebe o branch. O código do helper sai nas saídas.
- [x] A S2 do PR no GitHub de `workspace/76-pilot-closes-by-pr/` continua passando,
      com o PR aberto, a linha `PR:` no bare e a volta ao branch base.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação: no "PR" do `anvil-auto`, o resolvedor com `--pr` roda antes do
  `git push -u origin <branch>`; com qualquer `refusal:`, a spec para sem push e sem
  `pr create`, e o texto dá a forma do `Estado:` com as linhas inteiras
  (`- Estado: parada no branch: resolvedor com --pr, antes do push: <cada linha refusal:, como veio>`).
  Sem recusa, o piloto guarda o `<base>`, o `<repo>` e o `<login>` e carrega o
  `anvil-open-pr` com a mudança do Step 6 do `anvil-open-fast-pr`: o Step 0 usa
  esses valores e não roda o resolvedor. O `anvil-open-pr` não muda, então chamado
  direto pelo operador o Step 0 é o de hoje. Na "Parada", o caso do fechamento
  ganhou a recusa do resolvedor com `--pr` antes do push, e "a recusa que para o
  `anvil-open-pr`" virou "a parada do `anvil-open-pr`", que no piloto já não roda o
  resolvedor. O nome "não fecha no fechamento" fica para o ticket 03. O manual
  `anvil-omp` descreve a ordem nova.
- Prova S2 em `workspace/83-pilot-login-before-push/s2.sh`, retomada no branch da
  001 pronta para fechar, com origin `https://git.loja.example/acme/loja.git`,
  `forge: gitea` declarado e um login do `tea` falso, `outro`, em
  `https://gitea.com`; o bare começa só com o master. Vermelho com o payload igual
  ao de `4271efd` (`git diff 4271efd -- anvil` vazio, `s2-red.out`): o
  `git push -u` veio antes do `--pr`, e o bare recebeu o branch; 3 falhas, código
  do helper 1. Primeira rodada verde (`s2-r1.out`): o push saiu da ordem, mas o
  `Estado:` resumiu a recusa; o texto passou a dar a forma do `Estado:`. Verde
  (`s2.out`): o `--pr` depois do archive, nenhum `git push`, o bare só com o
  master, nenhum `pr create`, e o `Estado:` com a `refusal: login:` inteira; código
  do helper 0. A S2 `github` de `workspace/76-pilot-closes-by-pr/` passa
  (`s2-76-github.out`, código 0), com um só `resolve-git.sh --pr`, antes do push.
  `vendor-sync.sh verify` sai `0` (`verify.out`).
