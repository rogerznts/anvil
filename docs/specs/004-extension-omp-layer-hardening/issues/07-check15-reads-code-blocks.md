# 07: Check 15 confere os blocos de código

**What to build:** O `verify` passa a conferir os caminhos da camada citados dentro dos blocos de código das skills da camada, e não só na prosa. Um erro de digitação no comando que a `anvil-run` ou a `anvil-plan` mandam rodar reprova no `verify`, em vez de quebrar a sessão do operador. É a linha A5 do acompanhamento.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] O check 15 extrai dos blocos cercados dos arquivos da camada os caminhos que casam com o padrão de caminho da camada e confere cada um contra o payload, com a mesma mensagem de falha da prosa.
- [ ] A conferência da prosa continua igual.
- [ ] Caso novo no S3: uma cópia com o caminho errado só dentro do bloco `bash` de uma skill da camada reprova no check 15, e em nenhum outro check.
- [ ] O payload real passa limpo.
