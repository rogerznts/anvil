# 13: A guarda de merge acha a spec pelo branch que está sendo mesclado

**What to build:** Com a spec aberta — ticket sem `Status: resolved` ou spec fora de `archive/` —, um `git merge {tipo}/{NNN}-{nome}` é bloqueado de onde quer que seja disparado: do branch da spec ou da `main`. Hoje, rodado na `main`, a guarda libera, porque só olha o branch atual; no fluxo de merge local, que é o jeito natural de mesclar, ela não confere nada. A rule deste repositório deixa de ensinar o contorno.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A guarda identifica a spec pelo branch nomeado no `git merge`, além do branch atual, e opções do comando (`--no-ff`, `-m`, etc.) não atrapalham a identificação.
- [ ] Merge de branch sem número continua liberado, como hoje.
- [ ] Quando o branch atual e o branch mesclado são specs diferentes, as duas são conferidas.
- [ ] As fixtures de decisão (menção dentro de string ignora; invocação verifica) continuam passando.
- [ ] A cópia do hook instalada neste repositório fica igual à do payload.
- [ ] A rule do projeto deixa de descrever o contorno "disparar do branch da spec".
- [ ] Ponto A: num projeto descartável com spec de ticket aberto, `git merge` do branch da spec rodado na `main` sai 2, e do próprio branch da spec também; com tickets resolvidos e spec arquivada, os dois saem 0.
- [ ] O `verify` sai limpo.
