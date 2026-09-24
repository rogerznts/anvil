# 06: `verify` roda até o fim no bash 3.2

**What to build:** O mantenedor no macOS sem bash novo no `PATH` roda o `vendor-sync.sh verify` em `/bin/bash` 3.2 até o fim, com a mesma saída do bash 5. Hoje ele morre com SIGTRAP no check 3. É a linha A11 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] A causa da queda está isolada e escrita no `## Comments`, com o menor caso que a reproduz.
- [ ] A correção é mínima e não muda o resultado de nenhum check.
- [ ] `/bin/bash` e `/opt/local/bin/bash` rodando o `verify` neste repositório dão saída idêntica e limpa.
- [ ] O S3 (`workspace/31-omp-verify/s3.sh`) passa inteiro sob os dois bash.
