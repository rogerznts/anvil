# 11: `anvil-sentrux`: detectar, instalar e registrar o MCP

**What to build:** O usuário chama a `anvil-sentrux`. Se o sentrux já está instalado, a skill mostra a versão. Se não está, mostra o comando com a versão fixada, avisa que o upstream não publica checksum e só instala depois de aprovado, sem `sudo`. Em seguida oferece registrar o servidor MCP no projeto, sugerido, ou só para o usuário.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] Skill autoral, opcional e fora do fluxo; o manifesto registra por que a `scan` do upstream não foi adotada.
- [ ] Detecção do binário e da versão instalada.
- [ ] Instalação com aprovação e versão fixada: tap do Homebrew no macOS; binário da release no diretório de binários do usuário no Linux, sem o instalador oficial; nunca `sudo`.
- [ ] Aviso de que o upstream não publica checksum, e a versão instalada registrada.
- [ ] Registro do MCP no projeto, sugerido, ou só para o usuário, com o aviso de que quem clonar sem o binário verá o servidor falhar.
- [ ] Ponto B: sem o binário, o comando aparece e nada é instalado sem aprovação; com o binário, a versão é detectada; as duas opções de registro funcionam.
