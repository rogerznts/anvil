# 10: `anvil-distill`: sistema a partir de uma URL

**What to build:** O usuário passa a URL de um repositório e as direções do que interessa. O distill pergunta se o sistema entra passageiro ou versionado, baixa, registra a versão e destila como no caso local.

**Blocked by:** 09

**Status:** ready-for-agent

- [ ] Com URL, o distill pergunta a forma de entrada, sugerindo passageiro.
- [ ] Passageiro: clone raso, com uma linha de exclusão local do git para a pasta; o gitignore do projeto não muda; a Origem registra o commit.
- [ ] Versionado: submodule; a mudança fica para o usuário commitar; a Origem registra o pin.
- [ ] Pasta já presente: sem pergunta e sem atualizar.
- [ ] Repositório privado usa a credencial que o git já tiver; o distill nunca pede credencial.
- [ ] A invariante de escrita do `DISTILL.md` passa a autorizar criar a pasta do sistema em `references/` (hoje só autoriza escrever em `docs/`).
- [ ] Ponto B: uma URL passageira some do `git status`; uma URL versionada aparece como submodule; uma pasta existente não é atualizada.
