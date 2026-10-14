# 02: Caminhos de script resolvidos pela instalação de usuário

**What to build:** Os scripts que as skills e os perfis mandam rodar funcionam a partir de um projeto que não tem cópia do toolkit, com o toolkit só no diretório do usuário. Isso cobre a reserva de número da spec, a validação de docs, os gates do bench e os verbos do `reset-install`. Toda instrução autoral que cita script por caminho relativo ao projeto passa a citar o script na instalação de usuário. Os scripts continuam achando a raiz do **projeto** por `git` ou pelo diretório corrente, nunca subindo níveis a partir do próprio arquivo.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] O `tea-open-fast-pr`, o template do perfil do tracker e o perfil do tracker deste repositório citam o `new-spec.sh` na instalação de usuário.
- [ ] O `tea-open-pr` e o `anvil-docs` citam o `validate.sh` na instalação de usuário. A resolução do validador pela guarda de merge fica para o ticket 04.
- [ ] Os gates do `anvil-bench` e os verbos do `reset-install` citados pelo `anvil-boot` são resolvidos na instalação de usuário.
- [ ] O `infra.sh` do `anvil-stack-payload` resolve a raiz do projeto por `git` ou pelo diretório corrente e não sobe mais quatro níveis. O documento de invariantes do bench muda junto.
- [ ] A prosa autoral que cita o caminho antigo muda no mesmo passo. Nenhuma skill vendorizada é tocada.
- [ ] Cenário em `workspace/` com `HOME` temporário e o toolkit copiado só em `HOME`: a reserva de número da spec roda a partir de um projeto-fixture sem `.claude/skills/` e devolve o JSON de sempre.
- [ ] No mesmo cenário, o bench resolve a raiz do projeto-fixture, não `HOME`.
- [ ] O `vendor-sync.sh verify` sai limpo.
