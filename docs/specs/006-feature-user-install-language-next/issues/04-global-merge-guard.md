# 04: Guarda de merge global

**What to build:** A guarda de merge é instalada uma vez por usuário, nos dois harnesses, e continua barrando o merge de spec com ticket aberto ou sem archive em qualquer projeto anvil da máquina. Num repositório que não é projeto anvil, ela sai sem fazer nada e sem mensagem. A raiz continua vindo do projeto, e o validador passa a vir da instalação de usuário.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] O hook do Claude Code fica nas settings do usuário e chama o script da guarda na instalação de usuário. O `/anvil-update` o mantém, e o `/anvil-boot` deixa de instalar hook e cópia do script no projeto.
- [ ] O marcador de projeto anvil é a rule de configuração do anvil que o boot escreve. Sem ela, a guarda sai com sucesso e não imprime nada.
- [ ] Num projeto anvil, a raiz vem do projeto, e o validador de docs vem da instalação de usuário.
- [ ] O hook do omp acha o script da guarda na instalação de usuário. Script ausente num projeto anvil gera aviso visível, nunca passagem silenciosa.
- [ ] O modo `GUARD_DECIDE_ONLY` continua decidindo sem chamar o validador.
- [ ] Cenário em `workspace/` com `HOME` temporário: num repositório sem o marcador, `git merge` passa sem mensagem.
- [ ] No mesmo cenário, num projeto-fixture anvil com ticket aberto, o merge é bloqueado, e a chamada vai ao validador da instalação de usuário.
- [ ] No mesmo projeto, o hook do omp acha o script e bloqueia. Sem o script em `HOME`, ele avisa.
- [ ] O `vendor-sync.sh verify` sai limpo.
