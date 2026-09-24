# 05: Condutores recusam fora do perfil `docs/specs`

**What to build:** Num projeto com o tracker no GitHub, no GitLab ou em markdown local, o `/skill:anvil-run` e o `/skill:anvil-plan` recusam dizendo que os condutores só funcionam com o perfil `docs/specs` e que o fluxo segue à mão. Sem o arquivo do perfil, sugerem o `/anvil-setup`. Com o perfil `docs/specs`, nada muda. É a parte da linha A9 que entra nesta spec.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O `frontier.sh` lê o título de `docs/agents/issue-tracker.md` antes de resolver a spec: outro perfil dá `refusal` com o nome do perfil achado e a frase do fluxo à mão; arquivo ausente dá `refusal` sugerindo o `/anvil-setup`.
- [ ] O `stage.sh` faz a mesma leitura antes de tudo e sai com `next: refused`, o motivo em `reason` e um `do` que manda dizer o motivo e parar sem carregar nada.
- [ ] A `anvil-plan` trata `next: refused` mostrando o motivo e parando, inclusive quando chamada com um pedido.
- [ ] Com o perfil `docs/specs`, a saída dos dois scripts é idêntica à de antes, por fixture nos dois bash.
- [ ] Fixtures com os perfis GitHub, GitLab e local markdown do `anvil-setup`, e sem o arquivo, dão a recusa esperada nos dois scripts.
- [ ] O manual `anvil-omp` diz nos Limites que os condutores recusam fora do perfil `docs/specs`.
- [ ] A camada continua instalada com outro perfil: a detecção do `reset-install.sh` não muda.
- [ ] O `verify` sai limpo.
