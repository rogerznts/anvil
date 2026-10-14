# 02: Caminhos de script resolvidos pela instalação de usuário

**What to build:** Os scripts que as skills e os perfis mandam rodar funcionam a partir de um projeto que não tem cópia do toolkit, com o toolkit só no diretório do usuário. Isso cobre a reserva de número da spec, a validação de docs, os gates do bench e os verbos do `reset-install`. Toda instrução autoral que cita script por caminho relativo ao projeto passa a citar o script na instalação de usuário. Os scripts continuam achando a raiz do **projeto** por `git` ou pelo diretório corrente, nunca subindo níveis a partir do próprio arquivo.

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=0d30bba; scope=full; verdict=pass; p1=none

- [x] O `tea-open-fast-pr`, o template do perfil do tracker e o perfil do tracker deste repositório citam o `new-spec.sh` na instalação de usuário.
- [x] O `tea-open-pr` e o `anvil-docs` citam o `validate.sh` na instalação de usuário. A resolução do validador pela guarda de merge fica para o ticket 04.
- [x] Os gates do `anvil-bench` e os verbos do `reset-install` citados pelo `anvil-boot` são resolvidos na instalação de usuário.
- [x] O `infra.sh` do `anvil-stack-payload` resolve a raiz do projeto por `git` ou pelo diretório corrente e não sobe mais quatro níveis. O documento de invariantes do bench muda junto.
- [x] A prosa autoral que cita o caminho antigo muda no mesmo passo. Nenhuma skill vendorizada é tocada.
- [x] Cenário em `workspace/` com `HOME` temporário e o toolkit copiado só em `HOME`: a reserva de número da spec roda a partir de um projeto-fixture sem `.claude/skills/` e devolve o JSON de sempre.
- [x] No mesmo cenário, o bench resolve a raiz do projeto-fixture, não `HOME`.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Cenário: `workspace/38-script-paths/s1.sh`, 46 checks, todos passando em `dd274b2`. `HOME` temporário recebe `anvil/.claude/skills` em `~/.claude/skills` e a camada omp em `~/.omp/agent`; cada caso tira o comando do texto que o cita, na cópia em `HOME`, e o roda de um projeto-fixture sem `.claude/`. Cobre a reserva pelos dois perfis e pelo `tea-open-fast-pr` (JSON de sempre, `reserved:true`, pasta no projeto), o `validate.sh` do `tea-open-pr` e do `anvil-docs`, o `find-dupes.sh`, o `--unignore` e o `--layers` do boot, o `infra.sh` (de um subdiretório, a raiz é a do fixture; sem `git`, o diretório corrente), os gates do bench num container `node:22-alpine`, inclusive com a skill como symlink, e o `frontier.sh` e o `stage.sh` da camada omp.
- Spec, achado da implementação: o `INSTALL_ROOT` que o `infra.sh` calculava subindo quatro níveis nunca era usado — o script não lia a raiz do projeto. Agora ela sai do `git` ou do diretório corrente e aparece na linha `projeto:` do `--provision`, o único uso, que é o que torna o critério observável.
- Os gates do bench rodam dentro do container, que monta só o projeto. O script da instalação de usuário entra por `docker compose cp …/scripts/. app:/tmp/anvil-gates` antes de cada execução; o `cp` é idempotente e segue a skill ligada por symlink.
- Além dos critérios, pela frase "toda instrução autoral" do ticket: o `stage.sh` do `anvil-plan` e o `frontier.sh` do `anvil-run` passam a ser citados em `~/.omp/agent/skills/`, onde a spec põe a camada omp; o `deploy.sh` do bench e o checklist do `STACK-CONTRACT.md` seguem a mesma regra.
- Fica para o ticket 04, como o critério 2 manda: o `guard-spec-merge.sh` ainda chama e cita `.claude/skills/anvil-docs/scripts/validate.sh` do projeto, e o hook omp ainda aponta o script da guarda no projeto.
- Até o ticket 03 instalar no usuário, e o 06 ligar a fonte nesta máquina, os caminhos citados não existem: neste repositório, criar spec nova pelo perfil do tracker, ou rodar o `anvil-run`/`anvil-plan` no omp, falha até lá.
- Review round=1 · P2 (Spec): no cenário, o caso `--layers` só confere que a saída cita o lock do projeto, e o script ainda tira a camada do próprio projeto (`FROM_ABS="$TO_ABS"`) — não há prova de que o verbo funciona sem cópia no projeto, e se o ticket 03 não refizer essa origem ninguém percebe.
- Review round=1 · P3 (Spec): a linha `projeto:` do `infra.sh --provision` não foi pedida por critério — é mais uma linha de progresso para o agente traduzir; o bloco `ALLOC_*` que monta o `.env` não muda.
- Review round=1 · P3 (Spec): o cabeçalho do `reset-install.sh` (linhas 26–37) ainda diz que a camada vem da `anvil-update` do projeto e que o `--layers` roda da cópia instalada, como faz o boot — quem lê o cabeçalho acha uma descrição do boot que não é mais a do `anvil-boot`.
- Review round=1 · P3 (Spec): fora o `echo`, nada usa o `PROJECT_ROOT`, e o parágrafo "Caminhos" da spec sugere que a raiz serve a algo — quem lê só a spec supõe que ela alimenta a alocação; o achado está só neste `## Comments`.
- Review round=1 · P3 (Standards): possível Speculative Generality no `infra.sh` — o `--help` ("chamado do diretório do projeto") e o `INVARIANTS.md` fazem o provisionamento parecer depender da raiz, mas banco, porta e Redis saem só do argumento `<projeto>`; quem ler procura um vínculo que não existe.
- Review round=1 · P3 (Standards): possível Duplicated Code — o `docker compose cp ~/.claude/skills/anvil-bench/unlazy/scripts/. app:/tmp/anvil-gates` se repete no `anvil-bench/SKILL.md` e no `GATE.md`; trocar o destino exige editar os dois, e o esquecido roda script velho ou não acha o script.
- Review round=1 · P3 (Standards): possível Shotgun Surgery — o prefixo `~/.claude/skills/` fica literal em cerca de 20 citações em 14 arquivos; se a raiz da instalação de usuário mudar (por exemplo, com `CLAUDE_CONFIG_DIR`), todas quebram juntas. A spec fixa esse local.
- Review round=1 · P3 (Standards): o checklist do `STACK-CONTRACT.md` diz que `bench/{env,infra,deploy}.sh` acham o projeto pelo `git` ou pelo diretório corrente, mas o `env.sh` não resolve projeto e o `deploy.sh` usa só `pwd` — o autor de uma stack nova lê uma obrigação mais uniforme que o modelo real.
- Review round=1 · P3 (Standards): o critério "Nenhuma skill vendorizada é tocada" está marcado, e o `anvil-stack-payload`, vendorizado, foi tocado em arquivos `keep` (`bench/`) — sem essa ressalva, quem audita o ticket lê o critério como falso.
