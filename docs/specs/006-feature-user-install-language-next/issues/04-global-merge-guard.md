# 04: Guarda de merge global

**What to build:** A guarda de merge é instalada uma vez por usuário, nos dois harnesses, e continua barrando o merge de spec com ticket aberto ou sem archive em qualquer projeto anvil da máquina. Num repositório que não é projeto anvil, ela sai sem fazer nada e sem mensagem. A raiz continua vindo do projeto, e o validador passa a vir da instalação de usuário.

**Blocked by:** 03

**Status:** resolved

- [x] O hook do Claude Code fica nas settings do usuário e chama o script da guarda na instalação de usuário. O `/anvil-update` o mantém, e o `/anvil-boot` deixa de instalar hook e cópia do script no projeto.
- [x] O marcador de projeto anvil é a rule de configuração do anvil que o boot escreve. Sem ela, a guarda sai com sucesso e não imprime nada.
- [x] Num projeto anvil, a raiz vem do projeto, e o validador de docs vem da instalação de usuário.
- [x] O hook do omp acha o script da guarda na instalação de usuário. Script ausente num projeto anvil gera aviso visível, nunca passagem silenciosa.
- [x] O modo `GUARD_DECIDE_ONLY` continua decidindo sem chamar o validador.
- [x] Cenário em `workspace/` com `HOME` temporário: num repositório sem o marcador, `git merge` passa sem mensagem.
- [x] No mesmo cenário, num projeto-fixture anvil com ticket aberto, o merge é bloqueado, e a chamada vai ao validador da instalação de usuário.
- [x] No mesmo projeto, o hook do omp acha o script e bloqueia. Sem o script em `HOME`, ele avisa.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Cenário: `workspace/40-global-guard/s1.sh`, 34 checks, todos passando, e mais um com `OMP_SESSAO=opencode-go/claude-haiku-5-5`. `HOME` temporário, instalação pelo `reset-install` da árvore de trabalho com um omp falso no PATH. O hook do Claude Code é rodado como o Claude Code o roda: o comando lido do `~/.claude/settings.json`, por um shell, com o JSON no stdin e o `CLAUDE_PROJECT_DIR`. O validador de `HOME` é trocado por um que deixa rastro e segue para o real, e o projeto-fixture tem um `validate.sh` falso no caminho antigo, que liberaria tudo: o rastro mostra que só o de `HOME` é chamado. O hook do omp é carregado pelo `bun` com um `HookAPI` falso que guarda o handler e o `notify`; numa sessão real do omp 18.10.4 no mesmo `HOME`, o modelo roda o `git merge` e o tool volta barrado com o motivo do script, sem merge.
- O registro no `~/.claude/settings.json` é do `reset-install.sh`, e não do boot: o boot só roda o reset na primeira instalação, e o update é quem mantém a instalação. A entrada é achada pelo comando exato, `bash "$HOME/.claude/skills/anvil-docs/scripts/guard-spec-merge.sh"`, e acrescentada a `hooks.PreToolUse` com o resto do arquivo intocado. O JSON é lido e escrito pelo `python3`; settings que não é objeto com `hooks.PreToolUse` em lista, ou máquina sem `python3`, fica intocado e sai `ATENÇÃO` no relatório com o comando para registrar à mão. O lock não ganha linha para o hook: o formato fica o do ticket 03, e um payload futuro sem a guarda deixaria a entrada para trás.
- O validador é o `validate.sh` ao lado do script da guarda (`BASH_SOURCE`), que, chamado pelo hook, é o da instalação de usuário. Rodada do payload, como nos testers de `workspace/11-`, a guarda usa o validador do mesmo payload.
- O marcador é conferido antes de qualquer mensagem, inclusive os avisos de `grep` e `python3` indisponíveis, e o `GUARD_DECIDE_ONLY` pula a conferência: ele decide sobre o parse, dentro ou fora de projeto anvil. Os testers de `workspace/11-merge-target-tester/` montam o projeto sem o marcador e com a guarda em `.claude/hooks/`, e por isso não rodam mais como estão; uma cópia do `adv.sh` com o marcador e o `validate.sh` ao lado da guarda dá o mesmo de antes, 10 contornos e 2 falsos positivos, os conhecidos.
- Duas mudanças de comportamento além do caminho, para que "nunca passagem silenciosa" valha também no Claude Code: sem o `validate.sh` num projeto anvil, a guarda sai 1, e não 0, porque o Claude Code só mostra ao usuário a saída de erro do hook que falha sem ser 2; e o hook do omp repassa como aviso, por `notify` e por `additionalContext`, a saída de erro de qualquer código que não seja 0 nem 2. Fora de projeto anvil a guarda não chega lá.
- Sem o script em `HOME`, o hook do Claude Code falha com o erro do `bash` (código 127, não bloqueia) em todo comando, em qualquer repositório, inclusive fora de projeto anvil. Isso só acontece com a instalação de usuário quebrada e o hook ainda registrado; o comando não confere o marcador para não virar script dentro do settings.
- O passo 1 do boot, a migração do mosk, passa a tirar do `.claude/settings.json` do projeto a entrada que chama `.claude/hooks/guard-spec-merge.sh`: antes o passo 8 recopiava o script no mesmo caminho; agora o script sai e a entrada chamaria um arquivo apagado a cada comando.
- Fica para os tickets 05 e 06: este repositório ainda tem `.claude/hooks/guard-spec-merge.sh` versionado e o hook dele no `.claude/settings.json` do projeto. A cópia é a versão antiga, que chama o `validate.sh` pelo caminho do projeto e funciona aqui pelo symlink do `dev-link`. Com a guarda de usuário instalada nesta máquina, as duas rodam até a migração.
- Fica para o ticket 07: o `overview.md`, o ADR-0011 — a camada omp instalada por projeto — e o `project.md` ainda descrevem a guarda pelo `.claude/settings.json` do projeto.
