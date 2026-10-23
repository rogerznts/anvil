# 03: Remoto bare e `gh`/`tea` falsos

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** duas opções do helper para provas que passam por remoto e por
PR, sem servidor. A fixture ganha um `origin` local, e a sessão encontra um `gh` e
um `tea` que gravam cada chamada e respondem como no sucesso.

- [ ] Com a opção de remoto, a fixture ganha um repositório bare dentro do
      diretório da execução como `origin`, com o branch dela publicado; `git push`
      e `git remote` funcionam na sessão.
- [ ] Com a opção de forge falso, um `gh` e um `tea` ficam à frente do `PATH` da
      sessão. Cada chamada grava os argumentos e o diretório num log da execução,
      que vai para as saídas da prova.
- [ ] `gh pr create` imprime uma URL de PR no stdout; `tea pr create --output json`
      imprime um objeto com `index`, `title`, `url`, `state`, `base` e `head`. As
      outras chamadas saem `0` sem efeito.
- [ ] O remoto e os binários falsos saem com o diretório da execução.
- [ ] Prova S1, num diretório novo de `workspace/`: o push chega ao bare; o
      `command -v` acha os falsos antes de qualquer `gh` ou `tea` real; o log grava
      argumentos e diretório; as duas saídas de sucesso no formato de cada um.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
