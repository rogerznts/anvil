# 08: Bloco de verificação sem cerca de fechamento é recusado

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** no script do comando de verificação do piloto, o bloco `bash` da
seção `## Comando de verificação` vai da cerca de abertura até a cerca de
fechamento. Sem a cerca de fechamento, hoje ele vai até o fim do arquivo e roda o
resto das rules como comando; passa a ser recusado como as outras recusas.

- [x] Sem a cerca de fechamento, as operações de conferir e de rodar saem `2` com
      uma linha `refusal:` e o motivo, e nada roda.
- [x] Os casos de hoje continuam iguais, inclusive a linha `## ` dentro do bloco.
- [x] O cabeçalho do script diz que o bloco vai até a cerca de fechamento.
- [x] Prova S1, num diretório novo de `workspace/`, com
      `workspace/53-verification-command/` como prior art, no bash do `PATH` e no
      `/bin/bash` 3.2: bloco sem cerca seguido de mais seções nas rules dá a recusa
      nas duas operações e o comando não roda; os casos antigos passam. O caso novo
      falha antes da mudança.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Prova: `workspace/65-unterminated-verification-block/s1.sh`, no bash 5.2.15 do
  `PATH` e no `/bin/bash` 3.2.57. Antes da mudança, `s1-red.out`: os casos 10 e 10b
  — bloco sem cerca seguido de mais seções, e bloco sem cerca no fim do arquivo —
  falham 14 checagens, e o `run` criou na raiz os arquivos das linhas de depois do
  bloco. Depois, `s1.out`: tudo passa, os casos 1 a 9 do prior art inclusive.
