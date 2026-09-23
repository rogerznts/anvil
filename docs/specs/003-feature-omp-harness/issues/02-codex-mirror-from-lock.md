# 02: Espelho do Codex gerado pelo lock

**What to build:** Quem usa Codex continua vendo as skills do anvil em `.agents/skills`, agora mantidas pelo update. O payload deixa de trazer o espelho pronto; o update gera um symlink relativo para `.claude/skills` por linha `skill:` do lock, remove o que saiu do payload e não toca no que é do usuário. Neste repositório, o `dev-link.sh` gera o espelho a partir das skills ligadas, e o link pendurado do `anvil-team` some.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O payload não traz mais `.agents/`.
- [ ] Depois do update, `.agents/skills` tem exatamente um symlink por linha `skill:` do lock, apontando para a skill em `.claude/skills`.
- [ ] Symlink cujo nome estava no `skill:` do lock anterior e não está no novo é removido.
- [ ] Entrada em `.agents/skills` que não é symlink para `.claude/skills` fica intocada; se tiver nome de skill do payload, aparece como colisão e não é substituída.
- [ ] Sem lock, nada em `.agents/skills` é apagado.
- [ ] O dry-run e o relatório mostram o que muda em `.agents/skills`.
- [ ] O `dev-link.sh` gera `.agents/skills` deste repositório a partir das skills ligadas, e o `--unlink` o desfaz; o link do `anvil-team` não existe mais.
- [ ] Numa sessão do omp com o espelho presente, nenhuma skill aparece duplicada.
- [ ] Cenário S1 cobre os casos acima; o `verify` sai limpo.
