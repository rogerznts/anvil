# 02: O piloto confere o login antes do push

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** a A35 do acompanhamento. No fechamento por PR, o piloto
automático publica o branch e só depois o `anvil-open-pr` procura o login do `tea`;
num Gitea sem login casando, o branch fica no remoto sem PR. Agora, quando a
decisão do fechamento já deu PR, o piloto roda o resolvedor com `--pr` antes do
`git push -u`. Qualquer recusa dele deixa a spec em parada no fechamento, com as
linhas no motivo, sem push e sem `pr create`. O piloto entrega ao `anvil-open-pr` o
branch base, o repositório e o login que conferiu, e o Step 0 da skill os usa sem
rodar o resolvedor, como no Step 6 do `anvil-open-fast-pr`.

- [ ] A decisão entre merge local e PR continua igual: resolvedor sem `--pr`, e a
      ordem sem remoto, rules, forge. O `--pr` só roda quando ela deu PR.
- [ ] No "PR" do fechamento, o `resolve-git.sh --pr` vem antes do `git push -u`;
      com qualquer linha `refusal:`, a spec fica em parada no fechamento com as
      linhas copiadas como estão no motivo, sem push e sem `pr create`.
- [ ] O `anvil-open-pr`, carregado pelo piloto, usa o `<base>`, o `<repo>` e o
      `<login>` do piloto e não chama o resolvedor de novo; chamado direto pelo
      operador, o Step 0 é o de hoje.
- [ ] O manual `anvil-omp` descreve a ordem nova, se descreve o fechamento por PR.
- [ ] Prova S2 pelo helper, com `/skill:anvil-auto`, `--remote --forge` e as
      dependências declaradas, num diretório novo de `workspace/`, com
      `workspace/76-pilot-closes-by-pr/` e `workspace/81-pilot-base-and-rule/` como
      prior art: fixture Gitea com um login do `tea` que não casa com o host. O bare
      não recebe o branch, o `forge.jsonl` não tem `pr create`, e o `Estado:` do
      relatório traz a `refusal: login:`. Vermelho: o payload de `4271efd`, em que o
      bare recebe o branch. O código do helper sai nas saídas.
- [ ] A S2 do PR no GitHub de `workspace/76-pilot-closes-by-pr/` continua passando,
      com o PR aberto, a linha `PR:` no bare e a volta ao branch base.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
