# 03: Update instala a camada omp, com a guarda

**What to build:** Primeira fatia completa da camada omp. Num projeto com omp, o `/anvil-update` instala a camada em `.omp/` e a guarda de merge passa a valer no omp. A camada viaja no payload como material dentro da `anvil-update`, não como skill, e nesta fatia traz só o hook da guarda. A detecção aceita três sinais e é pegajosa; o lock ganha linhas `omp:` e a camada tem órfãos, alheios e colisões como as skills.

**Blocked by:** 01

**Status:** resolved

- [x] A detecção instala a camada quando qualquer sinal está presente: binário `omp` no `PATH`, `~/.omp/` existente, ou linha `omp:` no lock atual.
- [x] Sem nenhum sinal, o projeto não ganha `.omp/` nem linha `omp:`.
- [x] Com linha `omp:` no lock e máquina sem omp, a camada é mantida e atualizada.
- [x] O lock do projeto ganha uma linha `omp: <caminho relativo a .omp/>` por arquivo instalado; o lock do payload não ganha.
- [x] Arquivo retirado da camada no payload novo sai do `.omp/` e do lock; arquivo em `.omp/` fora do lock fica intocado; arquivo em `.omp/` com caminho da camada e fora do lock aparece como colisão.
- [x] Sem lock, nada em `.omp/` é apagado.
- [x] O dry-run e o relatório dizem o sinal que decidiu e o que muda em `.omp/`.
- [x] O hook da camada intercepta o tool `bash`, entrega o comando ao `guard-spec-merge.sh` no formato do hook do Claude e bloqueia só quando ele sai com 2, usando a saída de erro como motivo.
- [x] Sessão headless do omp (`omp -p --mode json`) num repositório de fixture: `git merge` de spec com ticket aberto é bloqueado com o motivo do script; spec arquivada passa; branch sem número passa; `tea pr create` sem archive é bloqueado.
- [x] O `validate.sh` e o hook do Claude ficam sem mudança.
- [x] A `anvil-update` descreve a camada no relatório que ela já mostra.
- [x] Cenários S1 e S2 da guarda cobrem os casos; o `verify` sai limpo.

## Comments

- A API de extensão do omp muda com o omp. Conferido na documentação embutida do omp 18.2.11: `tool_call` com `{ block, reason }`, descoberta em `.omp/hooks/pre/`.
- A camada passa por `classifica` com o predicado `existe_omp`: arquivo ou symlink, mesmo pendurado, como `existe_agente`. O nome de cada arquivo é o caminho relativo a `.omp/`. Os alheios saem da lista que o `find` acha em `.omp/`, linha a linha. Os arquivos novos são calculados logo depois da chamada, como os symlinks novos do espelho.
- A guarda de raiz do espelho virou a função `fora_do_lugar`, e a camada a usa. A camada inteira fica com o usuário quando `.omp`, ou uma pasta no caminho de um arquivo dela, é symlink ou arquivo, e também quando um arquivo da camada existe como diretório. Nesses casos nada em `.omp/` é tocado e o lock guarda as linhas `omp:` que tinha: sem elas, a camada perderia a posse e a regra pegajosa. O relatório diz qual caminho impediu.
- Linha `omp:` com caminho absoluto ou com `..` é ignorada. Ela não conta como da camada, e o `rm` do órfão nunca sai de `.omp/`.
- A pasta que um órfão deixa vazia sai junto, até `.omp`, que fica.
- O hook chama o `guard-spec-merge.sh` de `.claude/skills/anvil-docs/scripts/`, que o update mantém em dia, e não a cópia do boot em `.claude/hooks/`. A raiz é o `git rev-parse --show-toplevel` do cwd da sessão e vai no `CLAUDE_PROJECT_DIR`, como no Claude Code. Sem o script, o hook deixa passar.
- Sem lock, um arquivo do usuário com caminho da camada é sobrescrito sem aparecer como colisão, como as skills: sem lock não há como separar o que é do anvil. Nada é apagado.
- Payload sem `omp-layer/`, como o das fixtures `03` e `12`, dá uma linha própria: "o payload não traz camada omp, .omp/ fica intocado".
- Prova: o S1 (`workspace/29-codex-mirror/s1.sh`) passa com 73 checks em `/opt/local/bin/bash` e em `/bin/bash`, 23 deles novos, na seção 7. O S2 (`workspace/30-omp-guard/s2.sh`) instala o payload real num repositório de fixture e roda um turno de `omp -p --mode json` por caso, com o omp 18.2.11. Os quatro casos passam, e o motivo devolvido pelo tool é a saída de erro do script, com cabeçalho, ticket aberto e rodapé.
- Antes/depois com `workspace/28-reset-classify/capture.sh` (`antes-03`, `depois-03`), em bash 5 e bash 3.2: nenhuma linha antiga sumiu. A única linha nova é a da camada nas fixtures sem `omp-layer/`, e o resto da diferença é o hash dos `.out` e da cópia do script na árvore das fixtures. O `12-run.out` saiu idêntico, e bash 5 e bash 3.2 dão a mesma saída.
- Fica para o ticket 04: o caso do S1 "modo de camadas chamado pelo boot produz o mesmo resultado que o update". O modo ainda não existe.
