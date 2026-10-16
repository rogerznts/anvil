# 02: O piloto lê e roda o comando de verificação por um script

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=bda848e6e7e73e6cfd878ee3020addcaa7aa2b47; scope=full; verdict=fail; p1=open

**What to build:** a largada e o `PASS` do piloto leem o mesmo bloco de
`## Comando de verificação` de `.claude/rules/anvil.md` por um script da camada
omp, e o `PASS` roda o comando que o projeto declarou, e não um que o modelo
digitou depois de errar o escape do `awk` inline. O relatório grava a saída do
comando declarado e a linha `exit:` que o script imprime.

- [x] Script novo na pasta do `anvil-auto` na camada omp, com duas operações:
      conferir (imprime o comando e sai `0`; sem a seção, sem bloco `bash` nela ou
      com bloco vazio, sai diferente de `0` com o motivo numa linha) e rodar (roda
      o bloco da raiz do projeto, com a saída do comando e uma última linha
      `exit: <código>`).
- [x] O título lido é o exato `## Comando de verificação`, o que o `anvil-boot`
      grava; o título não muda.
- [x] A largada do `anvil-auto` usa conferir, e o `PASS` usa rodar. O `awk` inline
      sai das duas seções.
- [x] O script é instalado com o resto da camada omp, pelo `reset-install.sh` e
      pelo `dev-link.sh`, sem passo extra.
- [x] Prova do script num diretório novo de `workspace/`: rule com a seção e um
      bloco com aspas e `$` dentro roda o comando declarado, com o `exit:` do
      comando; rule sem a seção, seção sem bloco e bloco vazio são recusados com o
      motivo.
- [x] Prova S2 (prior art `workspace/47-auto-chain/`): uma corrente com esse bloco
      fecha, e a saída gravada no relatório é a do comando declarado. O S2
      registra o modelo que de fato respondeu, lido do jsonl.
- [x] `vendor-sync.sh verify` sai `0`, e o check 15 passa com o script citado pelo
      `anvil-auto`.

## Comments

- O script é `anvil/.claude/skills/anvil-update/.omp-layer/skills/anvil-auto/verification.sh`, instalado em `~/.omp/agent/skills/anvil-auto/verification.sh`. As operações se chamam `check` (conferir) e `run` (rodar), em inglês como as chaves dos outros scripts da camada. A recusa sai como no `frontier.sh` e no `roadmap.sh`: uma linha `refusal:` com o motivo em pt-BR e saída `2`, sem rodar nada. O `run` sai com o código do comando, além de imprimir a linha `exit:`. O bloco lido é o primeiro `bash` da seção, até o título `## ` seguinte; bloco só com espaço conta como vazio. O script acha a raiz pelo `git rev-parse --show-toplevel`, como o `frontier.sh`, e fora de um repositório git recusa.
- O `anvil-auto` manda rodar o bloco só pelo script, nunca digitado, e diz que uma linha `refusal:` no lugar da `exit:` conta como o comando saindo diferente de `0`. A conferência do merge, que também usa o `run` pela spec, é de outro ticket e não entrou aqui.
- Prova S1: `workspace/53-verification-command/s1.sh`, 51 checks, todos passando, com saída idêntica no bash 5.2.15 do `PATH` e no `/bin/bash` 3.2.57. Cobre o bloco com aspas simples e duplas, `$((…))`, `$HOME` literal e leitura de arquivo pela raiz, rodado de um subdiretório; o comando que falha com `exit 3`, com stdout e stderr; a recusa sem o arquivo, sem a seção, com título parecido (`## Comando de verificação do projeto` e `### Comando de verificação`), sem bloco `bash` (prosa, bloco `sh`, bloco só na seção seguinte), com bloco vazio e com bloco em branco; a operação desconhecida. Na seção 9, confere que o `awk` saiu do `anvil-auto`, que a largada cita o `check` e o `PASS` o `run`, que todo caminho `~/.omp/agent/` citado pelo `anvil-auto` existe na camada, e que o `dev-link.sh` e o `reset-install.sh`, num `HOME` descartável, instalam o script (symlink no primeiro; linha `omp:` no lock e cópia igual no segundo). Vermelho antes do script: todos os casos 1 a 8 falharam com o script ausente (rc 127).
- Prova S2: `workspace/53-verification-command/s2.sh`, sobre o caso C do `workspace/47-auto-chain/`, com o bloco `bash -n lib.sh && printf '%s\n' "verificado: $(ls *.sh | wc -l | tr -d ' ') scripts" 'marca: $NAO_EXPANDE'`. A saída esperada de cada spec sai do próprio script rodado sobre a árvore do branch dela, e o relatório tem de trazer cada linha, inclusive a `exit: 0`, e o comando como o branch o declara. Três rodadas, com `--model claude-sonnet-4-5 --thinking off`:
  - rodada 1 (`out-r1/`, `s2-r1.out`): passou nas conferências do ticket, e respondeu só o `anthropic/claude-sonnet-4-5` (90 mensagens). O piloto não pediu o sim: no turno 1 ele leu o roteiro, disse que ia prosseguir e rodou a corrente inteira. As duas specs fecharam com o `run` no `PASS` e o relatório com a saída do script;
  - rodada 2 (`out-r2/`, `s2-r2.out`): o turno do sim caiu com `overloaded_error` do provedor no meio da corrente, depois do merge da spec 001, e deu 7 falhas de corrente incompleta. Até ali, a largada rodou o `check` e o `PASS` o `run`. Nessa rodada, o implementer mudou o bloco no branch da spec para `bash -n lib.sh conta.sh && …`, e o `PASS` rodou o bloco do branch; por isso o S2 lê o comando esperado do branch, e não da `main`;
  - rodada 3 (`out/`, `s2-r3.out`): `S2: tudo passou`, com o roteiro mostrado no turno 1 e o sim no turno 2. Respondeu `openai-codex/gpt-6.1-sol` em 77 mensagens e `anthropic/claude-sonnet-4-5` em 5: no começo dos dois turnos o Anthropic deu `overloaded_error`, e o omp caiu no fallback. Nenhum `bash` das três rodadas traz o bloco digitado nem um `awk` de extração.
- O check 15 do `verify` não lê caminho com `~/`, e o `anvil-auto` cita o script só como `~/.omp/agent/skills/anvil-auto/verification.sh`. O check passa, mas não confere esse caminho: com o script renomeado numa worktree descartável, o `verify` saiu `limpo`. A lacuna é a do P3 do ticket 04 da 008, e a spec deixa o check 15 sobre `~/` fora de escopo. A conferência de que o caminho existe na camada está na seção 9 do S1.
- Achado fora do ticket: na rodada 1 do S2, com o `claude-sonnet-4-5`, o piloto rodou a corrente sem pedir o sim sobre o roteiro que já existia, contra "a confirmação dele sobre o roteiro escrito é o único sim da execução". O S2 do 47 pararia aí; este S2 registra uma nota e mede a corrente no turno em que ela rodou.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0.
- Review round=1 · P1 (Spec): no `awk` do `verification.sh`, o `section && /^## / { exit }` vem antes do `block { print }`, e uma linha `## …` dentro do bloco `bash`, comentário válido, corta o comando ali — o `run` roda o bloco truncado e sai `0` (`echo um` / `## comentario` / `false` dá `um` e `exit: 0`), e o `PASS` fecha a spec sem ter rodado o comando declarado inteiro.
- Review round=1 · P3 (Spec): quando a saída do comando não termina em quebra de linha, o `exit:` sai colado nela (`printf sem-quebra` dá `sem-quebraexit: 0`) — quem procura a linha `exit:` no relatório não a acha sozinha.
- Review round=1 · P3 (Spec): numa rule com fim de linha CRLF, a comparação exata do título falha e a recusa diz que a seção não existe — a recusa está certa, mas o motivo engana o operador.
- Review round=1 · P3 (Standards): bloco sem a cerca de fechamento segue lendo até a próxima seção ou o fim do arquivo — um projeto com a cerca esquecida roda o que vier depois como parte do comando.
- Review round=1 · P3 (Standards): o `check` imprime o comando cru, e não no formato `chave: valor` dos scripts irmãos — quem quiser ler a saída por chave não acha uma; é o que o ticket pede.
- Review round=1 · P3 (Standards): no passo 3 da largada, "A mensagem diz onde e como declarar" vem logo depois de "Uma linha `refusal:` é recusa" e pode ser lida como a própria linha `refusal:` — um piloto pode repassar só o motivo ao operador, sem o modelo da seção.
- Review round=1 · P3 (Standards): possível Mysterious Name em "o script do comando", no passo 3 da largada, que não diz o que o script faz antes de o nome aparecer no bloco — custa só leitura.
- Correção do P1 da rodada 1: o título `## ` só encerra a seção fora do bloco (`section && !block && /^## /`), e dentro do bloco a linha é do comando. Caso novo no S1, o 3b: o bloco `echo um` / `## comentário do bash` / `false` sai inteiro no `check`, e o `run` dá `um`, `exit: 1` e sai `1`. Vermelho antes da correção, com as duas conferências do 3b em `FALHA`; depois, `S1: tudo passou` com 53 checks, nos dois bash. Os P3 da rodada 1 ficam como estão. O S2 não rodou de novo: o bloco dele não tem linha `## `, e a leitura dele não muda.
