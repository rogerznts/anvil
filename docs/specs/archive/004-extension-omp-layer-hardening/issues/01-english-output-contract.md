# 01: Contrato de saída em inglês nos condutores

**What to build:** O `frontier.sh` passa a emitir as chaves de saída da tabela da spec, em inglês e estáveis, com os motivos ao operador ainda em pt-BR. O `frontier.sh` e o `stage.sh` ganham identificadores internos em inglês. A `anvil-run` lê as chaves novas no mesmo commit. Para o operador nada muda: é o prefactor que deixa os tickets 02 a 05 e 08 mexerem no script e na skill sem conflito de nome. Linhas A8 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved
**Review:** round=1; sha=c2111a5; scope=full; verdict=pass; p1=none
**PR:** https://github.com/rogerznts/anvil/pull/5

- [x] O `frontier.sh` emite `refusal`, `tree`, `screen`, `story`, a linha `ticket` com `status`, `reviews`, `last`, `blocked_by` e `class`, `skipped`, `locked`, `open_p1`, `depend_on_locked`, `all_resolved`, `halt` e `next`, e as classes `resolved`, `locked`, `waiting:NN`, `skipped` e `frontier`. Nenhuma chave antiga continua.
- [x] Os motivos depois das chaves seguem em pt-BR.
- [x] Identificadores internos do `frontier.sh` e do `stage.sh` em inglês; as chaves de saída do `stage.sh` não mudam.
- [x] A `anvil-run` cita só chaves que o script emite, e a troca sai num commit só.
- [x] Fixture em `/tmp` com os estados da 003 (livre, bloqueado, travado com P1, dependente, pulado, árvore suja, tudo resolvido) dá, nos dois bash, a mesma saída de antes a menos dos nomes das chaves.
- [x] O S1 e o S2 da `anvil-run` passam com as chaves novas, sem mudança de comportamento do supervisor.
- [x] O `verify` sai limpo.

## Comments

- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep`. Roda o `frontier.sh` e o `stage.sh` do `HEAD` anterior e os novos em `/opt/local/bin/bash` e `/bin/bash`, traduz a saída antiga pela tabela da spec e compara. Cobre livre, bloqueado, travado com P1, travado sem P1, dependente, dependente do dependente, bloqueador inexistente, pulado, árvore suja, tudo resolvido com e sem `ui/`, história de tela, recusas, e os estados do `stage.sh`. Resultado: `fixture: 0 falha(s)`, sem chave antiga na saída nova.
- S1 (`workspace/29-codex-mirror/s1.sh`): 104/104 nos dois bash, depois do `dev-link.sh`. Antes dele dava 103/104, porque faltava `.agents/skills` neste repositório (check "espelho = skills ligadas em .claude/skills"). Falha de ambiente, não do ticket.
- S2 (`workspace/33-omp-run/s2.sh`), evidência em `/tmp/anvil-004-01`: chaves novas passaram em 2 de 4 rodadas, o controle com as chaves antigas em 2 de 3. A falha é a mesma nos dois lados, o 06 despachado duas vezes, ruído que já existia na 003. Sem mudança de comportamento do supervisor atribuível à troca de chaves.
- `vendor-sync.sh verify`: `verify: limpo` sobre a árvore do commit c2111a5, antes do commit.
- Review round=1 · P2 (Standards e Spec): a caixa do S2 diz "passam", e a prova é 2 de 4 rodadas contra 2 de 3 do controle — quem fechar a spec ou o ticket 11 pode ler o S2 como verde, ou a falha do 06 despachado duas vezes como regressão desta troca. O que a prova sustenta é "o S2 passa tanto quanto antes".
- Review round=1 · P3 (Spec): a caixa escreve a classe como `waiting:NN`, a tabela da spec e o script como `waiting:NN,NN` — só leitura.
- Review round=1 · P3 (Standards): "Linhas A8 do acompanhamento" sai sem glosa; A8 são os identificadores em português nos scripts da camada — quem lê abre o acompanhamento para saber.
- Review round=1 · P3 (Standards): o parágrafo das chaves na `anvil-run/SKILL.md` (linhas 35-38) ficou com a quebra de linha do tamanho antigo das chaves — só forma.
- Review round=1 · P3 (Standards): o vocabulário de chaves mora em três lugares, o `frontier.sh`, a `anvil-run/SKILL.md` e a tabela da spec. Os tickets que acrescentam `unreadable_blockers` e `ready:` têm de editar os três, ou publicam um contrato que mente.
