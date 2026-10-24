# 10: O helper confere as dependências da prova e julga o subagente pelo próprio modelo

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** três correções no helper de prova, decididas pelo operador
depois dos tickets 05, 06 e 09, e o caso N do B1 refeito sobre elas.

- **Dependências declaradas.** O payload chama skills por
  `~/.claude/skills/<skill>/…`, e o overlay da sessão carrega o `SKILL.md` delas,
  não esse caminho. Sem o link, a sessão procurou a stack e o checker por conta
  própria e rodou cópias de outro projeto e um `infra.sh` velho. A prova passa a
  declarar as skills de que depende; o helper confere que cada uma é um link para o
  payload desta árvore e, se não for, sai `2` mandando rodar o `dev-link.sh`.
- **Modelo do subagente.** A sessão principal continua julgada pelo modelo
  pedido; cada subagente, por um modelo só do começo ao fim. O subagente com modelo
  próprio por papel ou por frontmatter não invalida a prova e vai para o relatório.
- **Veredito que falha.** Uma falha do próprio script de veredito sai `2`, de
  ambiente, e nunca `1`.

- [x] O helper aceita a lista de skills de que a prova depende e, para cada uma,
      confere que `~/.claude/skills/<skill>` é um link para o payload desta árvore;
      se não for, sai `2` com a skill e o comando do `dev-link.sh` no motivo. O
      helper não cria nem remove link.
- [x] O veredito dá `3` quando a sessão principal tem mensagem de modelo diferente
      do pedido ou quando um subagente tem mais de um modelo. O subagente com um
      modelo só, diferente do pedido, não invalida, e o relatório lista os modelos
      de cada sessão.
- [x] Uma falha inesperada do script de veredito faz o helper sair `2`, com o
      motivo.
- [x] O cabeçalho do helper e a seção "Helper de prova" do `SKILL.md` da
      `anvil-sync` dizem as três regras e os códigos, `2` incluído.
- [x] Prova S1, sem modelo, num diretório novo de `workspace/`: dependência sem
      link e dependência com link para outro lugar dão `2`; com o link para esta
      árvore, segue; jsonl de fixture com subagente de modelo próprio dá o código
      das conferências; subagente que troca de modelo no meio dá `3`; principal com
      outro modelo dá `3`; o script de veredito quebrado dá `2`. As S1 dos tickets
      01 a 04 continuam passando.
- [x] O caso N do B1 de `workspace/66-bench-b1-real-stack/` roda pelo helper com
      `anvil-bench` e `anvil-stack-payload` declarados: com as duas ligadas pelo
      `dev-link.sh` a esta árvore, o N dá verde em três rodadas seguidas, e todo
      `infra.sh` e checker que a sessão roda é o desta árvore; sem a ligação, dá `2`
      antes de abrir a sessão.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · a lista de dependências é `proof_prepare --dep <skill>`, uma vez
  por skill. Antes de criar o diretório da execução, o helper confere que
  `~/.claude/skills/<skill>` é um symlink cujo destino resolvido é o diretório da
  skill no payload desta árvore; diretório real, link quebrado ou link para outro
  lugar saem `2` com
  `ligue com bash <repo>/.claude/skills/anvil-sync/scripts/dev-link.sh --all`. Skill
  que não existe no payload, ou nome com barra, sai `2` como opção inválida.
- Implementação · o veredito: a principal é julgada pelo modelo pedido, e cada
  subagente por um modelo só; a linha final do código `3` diz a sessão que
  invalidou. O `proof_verdict` apaga o `verdict.txt`, roda o script com o stdout
  passando e o stderr guardado, e só aceita `0`, `1` ou `3` com o `verdict.txt`
  regravado; o resto sai `2` com o stderr do script no motivo — um subagente
  ilegível com as conferências vermelhas dava `1` antes.
- Implementação · S1 em `workspace/67-proof-declared-deps/s1.sh` (`s1.out`: tudo
  passou, no bash 5.2 e no `/bin/bash` 3.2), com um `HOME` de fixture para os links,
  sem tocar no `~/.claude` da máquina. As S1 de 59 a 62 passam (`s1-anteriores.out`).
  O caso 7 da S1 do ticket 02 (`workspace/60-invalid-proof/s1.sh`) esperava `3` de
  um subagente respondido inteiro por outro modelo, a regra de antes; ele passou a
  conferir o subagente que troca do modelo pedido para outro, que continua `3`.
- Implementação · o `b1.sh` da 66 declara, com `FASE2=hoje`, as quatro skills que o
  `anvil-bench` chama por `~/.claude/skills/`: `anvil-bench`, `anvil-stack-payload`,
  `anvil-docs` (os templates dos perfis, que o N confere) e `anvil-to-spec`. Com
  `FASE2=antes`, a árvore sob prova é a cópia de `HEAD`, para a qual nenhum link
  aponta, e elas não vão declaradas. A conferência da árvore passou a cobrir também
  o `env.sh` e o checker (`unlazy/scripts`). As saídas ficam em
  `workspace/67-proof-declared-deps/`: `b1-n-1.out` a `b1-n-3.out`, três rodadas
  seguidas do N com código `0` do helper, todas de `anthropic/claude-sonnet-4-5`,
  com o `env.sh` e o `infra.sh --provision` de `~/.claude/skills/anvil-stack-payload/`,
  que resolvem para esta árvore, e nenhum checker rodado no N; `b1-n-sem-link.out`,
  com um `HOME` sem os links (e o `DOCKER_CONFIG` do usuário), dá `N=2` com o motivo
  do helper, sem `frames.jsonl` nem `session.jsonl`.
