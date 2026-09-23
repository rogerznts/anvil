# 03: Update instala a camada omp, com a guarda

**What to build:** Primeira fatia completa da camada omp. Num projeto com omp, o `/anvil-update` instala a camada em `.omp/` e a guarda de merge passa a valer no omp. A camada viaja no payload como material dentro da `anvil-update`, não como skill, e nesta fatia traz só o hook da guarda. A detecção aceita três sinais e é pegajosa; o lock ganha linhas `omp:` e a camada tem órfãos, alheios e colisões como as skills.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A detecção instala a camada quando qualquer sinal está presente: binário `omp` no `PATH`, `~/.omp/` existente, ou linha `omp:` no lock atual.
- [ ] Sem nenhum sinal, o projeto não ganha `.omp/` nem linha `omp:`.
- [ ] Com linha `omp:` no lock e máquina sem omp, a camada é mantida e atualizada.
- [ ] O lock do projeto ganha uma linha `omp: <caminho relativo a .omp/>` por arquivo instalado; o lock do payload não ganha.
- [ ] Arquivo retirado da camada no payload novo sai do `.omp/` e do lock; arquivo em `.omp/` fora do lock fica intocado; arquivo em `.omp/` com caminho da camada e fora do lock aparece como colisão.
- [ ] Sem lock, nada em `.omp/` é apagado.
- [ ] O dry-run e o relatório dizem o sinal que decidiu e o que muda em `.omp/`.
- [ ] O hook da camada intercepta o tool `bash`, entrega o comando ao `guard-spec-merge.sh` no formato do hook do Claude e bloqueia só quando ele sai com 2, usando a saída de erro como motivo.
- [ ] Sessão headless do omp (`omp -p --mode json`) num repositório de fixture: `git merge` de spec com ticket aberto é bloqueado com o motivo do script; spec arquivada passa; branch sem número passa; `tea pr create` sem archive é bloqueado.
- [ ] O `validate.sh` e o hook do Claude ficam sem mudança.
- [ ] A `anvil-update` descreve a camada no relatório que ela já mostra.
- [ ] Cenários S1 e S2 da guarda cobrem os casos; o `verify` sai limpo.

## Comments

- A API de extensão do omp muda com o omp. Conferido na documentação embutida do omp 18.2.11: `tool_call` com `{ block, reason }`, descoberta em `.omp/hooks/pre/`.
