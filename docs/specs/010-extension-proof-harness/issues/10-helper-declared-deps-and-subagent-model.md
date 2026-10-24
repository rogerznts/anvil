# 10: O helper confere as dependências da prova e julga o subagente pelo próprio modelo

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

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

- [ ] O helper aceita a lista de skills de que a prova depende e, para cada uma,
      confere que `~/.claude/skills/<skill>` é um link para o payload desta árvore;
      se não for, sai `2` com a skill e o comando do `dev-link.sh` no motivo. O
      helper não cria nem remove link.
- [ ] O veredito dá `3` quando a sessão principal tem mensagem de modelo diferente
      do pedido ou quando um subagente tem mais de um modelo. O subagente com um
      modelo só, diferente do pedido, não invalida, e o relatório lista os modelos
      de cada sessão.
- [ ] Uma falha inesperada do script de veredito faz o helper sair `2`, com o
      motivo.
- [ ] O cabeçalho do helper e a seção "Helper de prova" do `SKILL.md` da
      `anvil-sync` dizem as três regras e os códigos, `2` incluído.
- [ ] Prova S1, sem modelo, num diretório novo de `workspace/`: dependência sem
      link e dependência com link para outro lugar dão `2`; com o link para esta
      árvore, segue; jsonl de fixture com subagente de modelo próprio dá o código
      das conferências; subagente que troca de modelo no meio dá `3`; principal com
      outro modelo dá `3`; o script de veredito quebrado dá `2`. As S1 dos tickets
      01 a 04 continuam passando.
- [ ] O caso N do B1 de `workspace/66-bench-b1-real-stack/` roda pelo helper com
      `anvil-bench` e `anvil-stack-payload` declarados: com as duas ligadas pelo
      `dev-link.sh` a esta árvore, o N dá verde em três rodadas seguidas, e todo
      `infra.sh` e checker que a sessão roda é o desta árvore; sem a ligação, dá `2`
      antes de abrir a sessão.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
