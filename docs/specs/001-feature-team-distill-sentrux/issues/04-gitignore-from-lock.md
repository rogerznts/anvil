# 04: O gitignore sai do lock

**What to build:** Num projeto descartável, o update e o boot escrevem no gitignore um bloco `ANVIL:INSTALLED` com uma linha por skill que o anvil instalou — as `tea-*` incluídas — e nada além disso. Uma skill que o usuário escreveu continua versionada. Num projeto bootado antes, a linha que ignorava `.claude/skills/` inteiro é trocada pelo bloco, com aprovação.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] Uma função única gera o bloco a partir do lock, e o update a chama depois de gravar o lock.
- [ ] O modo `--gitignore-only` reescreve só o bloco a partir do lock existente, e é o que o boot usa.
- [ ] Rodar duas vezes não muda nada, e uma skill órfã removida sai do bloco.
- [ ] O boot troca a linha antiga só quando acha o comentário exato que ele mesmo escreveu, mostrando o antes e o depois e esperando aprovação.
- [ ] Uma linha parecida sem esse comentário fica intocada.
- [ ] Pontos A e B: `reset-install --dry-run` e boot num projeto descartável com skill do usuário, `tea-*`, e a linha antiga com e sem o comentário.
