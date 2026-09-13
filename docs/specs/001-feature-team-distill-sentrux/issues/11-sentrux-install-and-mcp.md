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

## Comments

**Leader, 2026-09-13 — fatos do Analyst** em `discovery/sentrux-facts.md` (`371d1e0`), a usar na implementação:

- Versão fixada: **v0.5.7**. Assets são binários crus (`sentrux-darwin-arm64`, `sentrux-linux-x86_64`,
  `sentrux-linux-aarch64`). **Não há macOS Intel** (a skill detecta e diz que não há suporte).
- macOS: `brew install sentrux/tap/sentrux`; a fórmula não aceita versão (fixar por `brew pin`), declara `sha256` e o
  Homebrew confere; o binário linka `openssl@3` do Homebrew sem declarar a dependência.
- Linux: binário da release em `~/.local/bin`; exige `libgtk-3`, `libssl.so.3` e glibc ≥ 2.35.
- **Checksum existe**: o `digest` sha256 que o GitHub calcula por asset. A spec dizia "sem checksum" — corrigido: a
  instalação no Linux confere o digest; o aviso passa a ser que o upstream não publica arquivo de checksum nem
  assinatura, e que o anvil confere o digest do GitHub.
- Detecção: `sentrux --version` imprime `sentrux 0.5.7`. MCP: `sentrux --mcp` (stdio, 9 ferramentas);
  `claude mcp add --scope project|local sentrux -- sentrux --mcp`. "Só para o usuário" é o escopo `local`.
- Pendente de decisão do usuário: download de gramáticas sem conferência e telemetria diária em qualquer invocação.
