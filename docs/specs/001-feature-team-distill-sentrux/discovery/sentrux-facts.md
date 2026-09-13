# sentrux: fatos para a `anvil-sentrux`

- **Data do levantamento:** 2026-09-13
- **Repositório:** https://github.com/sentrux/sentrux (MIT, Rust)
- **Release consultada:** `v0.5.7`, tag no commit `f36da08a53e7f06c5b6aec33eb05816b371000ea`
- **Ponta da `main` consultada:** `6f8ff3c14b0423e4b58f42d1813d4d5f7fdc1d11`
- **Tap consultado:** `sentrux/homebrew-tap`, commit `fd00bae45bb82e15796df75902a390ad046ad701`
- **Ferramentas locais:** Claude Code `2.1.270`, Homebrew `6.0.22-306-gb48a6f3`

**Convenções.** Todo código citado vem da tag `v0.5.7`, que é o que a release
publica, a menos que o texto diga `main`. `S/` abrevia
`https://github.com/sentrux/sentrux/blob/f36da08a53e7f06c5b6aec33eb05816b371000ea/`.
**[F]** marca fato com fonte, **[I]** marca inferência com o trecho que a sustenta,
e **[Impl]** marca consequência para os tickets 11 e 12, sem decidir por eles.

**Método.** Leitura via `gh api`, `curl` de arquivos raw, clone completo em
scratchpad e docs oficiais. Os binários da release `v0.5.7` (linux x86_64, linux
aarch64, darwin arm64) foram **baixados sem permissão de execução e só inspecionados
estaticamente** (`shasum`, `file`, `objdump -p`, `otool -L`, `strings`). Nada foi
executado, instalado ou registrado.

---

## Resumo para o Dev

- **Tag a fixar:** `v0.5.7`, publicada em 2026-03-18T23:24:28Z, sem prerelease e sem
  draft. É a última release das 37.
- **Assets de binário:** `sentrux-darwin-arm64`, `sentrux-linux-x86_64`,
  `sentrux-linux-aarch64` e `sentrux-windows-x86_64.exe`, todos **binário cru, sem
  tarball**. Não existe asset para macOS Intel.
- **Checksum:** o upstream não publica `SHA256SUMS`, `.sig` nem attestation (a API
  devolve 404). Existem, porém, duas coisas que mudam o aviso:
  1. o campo `digest` que o **GitHub** calcula no upload de cada asset;
  2. o `sha256` declarado na **fórmula do tap**, que o Homebrew confere no download.
     Nos dois assets que a fórmula cobre, o valor é igual ao `digest`.
- **macOS:** `brew install sentrux/tap/sentrux`. O tap é o repositório
  `sentrux/homebrew-tap` e a fórmula é `Formula/sentrux.rb`. Hoje ela aponta `0.5.7`.
  Ela não recebe versão como argumento e não há `sentrux@0.5.7`: para fixar, os
  caminhos são `brew pin sentrux` depois de instalar, ou `brew extract` para um tap
  próprio. A fórmula só cobre macOS arm e Linux x86_64.
- **Linux x86_64:**
  `https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-linux-x86_64`
  (sha256 `3237f80fe20d54aad4deefa8a143f0d60543bb5d2d6ad891eb42432f155725a6`).
- **Linux aarch64:**
  `https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-linux-aarch64`
  (sha256 `27e1b4a3e4716b341dd76e9736a5553c6737c24e165cc27e0dbc399cc5b4d786`).
- **Destino no Linux:** `$HOME/.local/bin/sentrux`, que é o local da XDG Base Directory
  Specification para executáveis do usuário. Os binários Linux dependem de
  `libgtk-3.so.0`, `libssl.so.3` e glibc ≥ 2.35.
- **Versão:** `sentrux --version` ou `sentrux -V` imprimem `sentrux 0.5.7` no stdout
  e saem com 0. Pode vir uma segunda linha `  Update available: v… → brew upgrade sentrux`.
  **Qualquer invocação**, inclusive `--version`, pode baixar gramáticas (cerca de
  9 MB) e mandar ping de telemetria antes de ler os argumentos.
- **Servidor MCP:** `sentrux --mcp` (a config do upstream usa esse, e o código o marca
  como alias oculto) ou `sentrux mcp` (o subcomando). Transporte stdio, JSON-RPC por
  linha. O código registra **9 ferramentas**: `scan`, `rescan`, `session_start`,
  `session_end`, `health`, `check_rules`, `git_stats`, `dsm` e `test_gaps`.
- **Registro no projeto:** `claude mcp add --scope project sentrux -- sentrux --mcp`,
  que grava em `.mcp.json` na raiz.
- **Registro local:** `claude mcp add --scope local sentrux -- sentrux --mcp` (local é o
  padrão), que grava em `~/.claude.json`, dentro de `projects["<caminho do projeto>"]`.
- **Check:** `sentrux check [path]`, com `path` padrão `.`. Sai com 0 sem violação e
  com 1 em qualquer violação, sem `rules.toml`, com TOML inválido, com caminho que não
  é diretório ou com falha de scan. Erro de uso do clap sai com 2.
- **Gate:** `sentrux gate --save [path]` grava `<path>/.sentrux/baseline.json`.
  `sentrux gate [path]` compara com a linha de base e sai com 0 sem degradação, com 1
  degradado e com 1 se não houver linha de base. **Não existe `--json`**: o PR #40, que
  o adiciona, está aberto.
- **O que o gate compara:** `quality_signal` com queda maior que 0.02, `coupling_score`
  com alta maior que 0.05, ciclos, god files e funções complexas, esses três em
  qualquer aumento. O gate **não lê** o `rules.toml`.
- **Esqueleto de `rules.toml` com a semântica real da v0.5.7.** Ela é o contrário da
  documentação (ver item 7 e Surpresas):

  ```toml
  [constraints]
  max_cycles = 0

  # v0.5.7: violação quando order(importador) > order(importado).
  # order menor = camada de cima, que pode importar as de order maior.
  [[layers]]
  name = "app"
  paths = ["src/app/**"]
  order = 0

  [[layers]]
  name = "domain"
  paths = ["src/domain/**"]
  order = 1

  [[boundaries]]
  from = "src/domain/**"
  to = "src/infra/**"
  reason = "ADR-0004: domínio não depende de infraestrutura"
  ```

- **Riscos:**
  - `order` está invertido em relação à doc. O PR #67 inverte o código e está aberto;
    se entrar numa release futura, a mesma regra passa a dizer o oposto.
  - `[[layers]]` não tem `reason`, só `[[boundaries]]` tem.
  - Chave desconhecida ou com erro de digitação é **ignorada em silêncio**. O
    `max_coupling = "B"` do próprio README é um exemplo.
  - O glob só aceita curinga no fim do padrão.
  - O scan de um repositório git só vê arquivos rastreados: arquivo novo sem `git add`
    não entra no gate.
  - O binário macOS linka o openssl do Homebrew em `/opt/homebrew`.
  - O binário publicado é compilado de um repositório **privado** (`sentrux-pro`).
  - O último merge de PR foi em 2026-03-13 e o bug #66 está aberto.

---

## 1. Versão a fixar

### 1.1 Última release

**[F]** Comando e trecho da saída:

```
$ gh api repos/sentrux/sentrux/releases/tags/v0.5.7 --jq '{tag_name, name, draft, prerelease, published_at, created_at, target_commitish}'
{"created_at":"2026-03-18T23:24:04Z","draft":false,"name":"v0.5.7 — WCAG color system, universal resolver, plugin versions","prerelease":false,"published_at":"2026-03-18T23:24:28Z","tag_name":"v0.5.7","target_commitish":"main"}
```

**[F]** `git rev-list -n1 v0.5.7` no clone devolve
`f36da08a53e7f06c5b6aec33eb05816b371000ea`. `gh release list` marca `v0.5.7` como
`Latest`.

### 1.2 Assets da `v0.5.7`

**[F]** Saída de `gh api repos/sentrux/sentrux/releases/tags/v0.5.7`, com os campos
`name`, `size`, `content_type` e `digest`:

| Asset | Plataforma e arquitetura | Tipo | Tamanho (bytes) | `digest` (GitHub) |
|---|---|---|---|---|
| `sentrux-darwin-arm64` | macOS arm64 | `application/octet-stream` | 23014208 | `sha256:30ae1a44d4478adf294019fce6d65ce5686c25bc863eb715b320c5234927f6c2` |
| `sentrux-linux-x86_64` | Linux x86_64 (gnu) | `application/octet-stream` | 36471096 | `sha256:3237f80fe20d54aad4deefa8a143f0d60543bb5d2d6ad891eb42432f155725a6` |
| `sentrux-linux-aarch64` | Linux aarch64 (gnu) | `application/octet-stream` | 34901056 | `sha256:27e1b4a3e4716b341dd76e9736a5553c6737c24e165cc27e0dbc399cc5b4d786` |
| `sentrux-windows-x86_64.exe` | Windows x86_64 (msvc) | `application/x-msdos-program` | 23951360 | `sha256:40dd2e47804bf9f006015eb742abfe178a824f42d4a19eb00478a7d705697cac` |
| `grammars-darwin-arm64.tar.gz` | gramáticas, macOS arm64 | `application/gzip` | 8949349 | `sha256:942a1597fae6c33823dcf7158a9850e4b67258cadf89100c20c980fc3abaf48f` |
| `grammars-linux-x86_64.tar.gz` | gramáticas, Linux x86_64 | `application/gzip` | 8360514 | `sha256:8849f1eb07df3f6d4ea1ed422d8dee4b9b79a250682fa5646675dae466554454` |
| `grammars-linux-aarch64.tar.gz` | gramáticas, Linux aarch64 | `application/gzip` | 8153035 | `sha256:f1fb8b4d10f962f3cdca71eaf68662dfa971e50e22d3b8947d1bc229c417f253` |
| `grammars-windows-x86_64.tar.gz` | gramáticas, Windows x86_64 | `application/gzip` | 8944584 | `sha256:6b35c7e4e03203648f189e9852907d48c2cbea570c1413ebb48bf9c8d76efbd9` |

**[F]** O mapa de asset para target vem de `S/.github/workflows/release.yml#L16-L27`:
`aarch64-apple-darwin`, `x86_64-unknown-linux-gnu` e `aarch64-unknown-linux-gnu`
(esses dois em `ubuntu-22.04`) e `x86_64-pc-windows-msvc`.

**[F]** Os tipos confirmados pelo `file` nos binários baixados:

```
sentrux-darwin-arm64:  Mach-O 64-bit executable arm64
sentrux-linux-aarch64: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, ... for GNU/Linux 3.7.0, not stripped
sentrux-linux-x86_64:  ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, ... for GNU/Linux 3.2.0, not stripped
```

**[F]** O `shasum -a 256` local dos três binários baixados bate com o `digest` da API:
`30ae1a44…`, `27e1b4a3…` e `3237f80f…`.

### 1.3 Checksum, assinatura e attestation

- **[F]** Nenhuma das 37 releases tem asset cujo nome case
  `sha|SHA|sig|asc|minisig|intoto|sbom`. O filtro rodou em
  `gh api repos/sentrux/sentrux/releases --paginate` e voltou vazio.
- **[F]** Não há attestation:

  ```
  $ gh api repos/sentrux/sentrux/attestations/sha256:3237f80f…
  {"message":"Not Found",...,"status":"404"}
  ```

  O mesmo 404 aparece para o digest do darwin-arm64.
- **[F]** O `release.yml` não gera checksum nem assinatura: só `softprops/action-gh-release@v2`
  com os quatro binários (`S/.github/workflows/release.yml#L116-L124`).
- **[F]** O campo `digest` é calculado pelo GitHub, não publicado pelo upstream. O
  [changelog de 2025-06-03](https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/)
  diz que os SHA256 são "generated at upload time" e "immutable", e expostos na UI, na
  REST, na GraphQL e no `gh`. Ver também a
  [REST API de release assets](https://docs.github.com/en/rest/releases/assets).
- **[F]** A fórmula do tap declara `sha256`, calculado pelo CI com `sha256sum` nos
  artefatos antes de gravar a fórmula (`S/.github/workflows/release.yml#L130-L132`).
  Ver o item 2.

### 1.4 Releases recentes, para contexto

**[F]** `gh release list -R sentrux/sentrux -L 15`:

| Tag | Publicada (UTC) |
|---|---|
| `v0.5.7` | 2026-03-18T23:24:28Z |
| `v0.5.6` | 2026-03-18T14:54:22Z |
| `v0.5.5` | 2026-03-17T08:57:35Z |
| `v0.5.4` | 2026-03-17T04:27:42Z |
| `v0.5.3` | 2026-03-16T11:41:11Z |
| `v0.5.2` | 2026-03-16T10:39:05Z |
| `v0.5.1` | 2026-03-16T09:19:39Z |
| `v0.5.0` | 2026-03-16T07:43:53Z |
| `v0.4.10` | 2026-03-15T21:58:30Z |
| `v0.4.9` | 2026-03-15T10:26:33Z |

As 37 releases saíram entre 2026-03-12T02:06:50Z (a primeira) e 2026-03-18T23:24:28Z.
Não há release depois disso. `v0.5.6` e `v0.5.5` têm o mesmo conjunto de oito assets
da `v0.5.7`.

---

## 2. macOS

### 2.1 Tap e fórmula

- **[F]** O tap é o repositório `sentrux/homebrew-tap` (branch `main`, não arquivado,
  último push 2026-03-18T23:39:49Z). A árvore inteira tem `.gitignore`, `Formula` e
  `Formula/sentrux.rb`, e nenhuma outra fórmula: não existe `sentrux@x`.
- **[F]** O comando indicado pelo upstream é `brew install sentrux/tap/sentrux`
  (`S/README.md#L56`, [sentrux.dev/docs/installation](https://sentrux.dev/docs/installation/),
  e `S/sentrux-bin/src/main_impl.rs#L243`).
- **[F]** Conteúdo literal da fórmula em
  https://github.com/sentrux/homebrew-tap/blob/fd00bae45bb82e15796df75902a390ad046ad701/Formula/sentrux.rb:

  ```ruby
  class Sentrux < Formula
    desc "Live codebase visualization and structural quality gate"
    homepage "https://github.com/sentrux/sentrux"
    version "0.5.7"
    license "MIT"

    on_macos do
      on_arm do
        url "https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-darwin-arm64"
        sha256 "30ae1a44d4478adf294019fce6d65ce5686c25bc863eb715b320c5234927f6c2"
      end
    end

    on_linux do
      on_intel do
        url "https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-linux-x86_64"
        sha256 "3237f80fe20d54aad4deefa8a143f0d60543bb5d2d6ad891eb42432f155725a6"
      end
    end

    def install
      if OS.mac? && Hardware::CPU.arm?
        bin.install "sentrux-darwin-arm64" => "sentrux"
      elsif OS.linux? && Hardware::CPU.intel?
        bin.install "sentrux-linux-x86_64" => "sentrux"
      end
    end

    test do
      assert_match "sentrux", shell_output("#{bin}/sentrux --help 2>&1", 1)
    end
  end
  ```

- **[F]** A fórmula tem `sha256`, e ele é igual ao `digest` do GitHub nos dois assets
  cobertos.
- **[F]** Não há bloco `bottle`. A fórmula não declara `depends_on`.
- **[F]** Ela cobre só macOS arm e Linux Intel: não há `url` para macOS Intel nem para
  Linux arm.
- **[F]** O Homebrew confere o download contra o checksum declarado:
  `Library/Homebrew/downloadable.rb#L324-L338` no commit
  `b3625f73d3e3574c5789ee32eb7b06627b788ec4` do `Homebrew/brew`
  (`def verify_download_integrity(filename)` →
  `Downloadable.verification_cache.verify(filename, checksum)`).
- **[F]** A fórmula é gerada e sobrescrita pelo CI a cada tag, via
  `PUT repos/sentrux/homebrew-tap/contents/Formula/sentrux.rb`
  (`S/.github/workflows/release.yml#L126-L178`).
- **[F]** O histórico do tap tem um commit por versão: `fd00bae` "Update sentrux to
  v0.5.7" em 2026-03-18T23:39:49Z, `d966502` para v0.5.6, `570b848` para v0.5.5, e
  assim por diante (`gh api repos/sentrux/homebrew-tap/commits`).
- **[F]** Hoje a fórmula aponta `0.5.7`, que é a última release.

### 2.2 Fixar versão no Homebrew

Tudo aqui é o que o Homebrew documenta.

- **[F]** `brew install <formula>` instala a versão declarada na fórmula no momento e
  não aceita versão como argumento. A synopsis é `install [options] formula|cask […]`
  ([Manpage](https://docs.brew.sh/Manpage)). Com o formato desta fórmula, instalar
  pelo tap dá a versão da ponta do tap. **[I]** Isso vem de a fórmula ter um único
  `version` e ser sobrescrita a cada release.
- **[F]** `brew pin`: "Pin the specified package, preventing it from being upgraded when
  issuing the brew upgrade formula or cask command"
  ([Manpage](https://docs.brew.sh/Manpage)). Em
  [Versions, "Locking installed formulae at specific versions"](https://docs.brew.sh/Versions#locking-installed-formulae-at-specific-versions),
  o contra é "you will not receive updates for that package, including security
  updates, while it remains pinned".
- **[F]** `$HOMEBREW_NO_INSTALL_UPGRADE`: "Unless $HOMEBREW_NO_INSTALL_UPGRADE is set,
  brew install formula will upgrade formula if it is already installed but outdated"
  ([Manpage](https://docs.brew.sh/Manpage)). A página Versions acrescenta "this does
  not pin versions".
- **[F]** `brew extract [--version=] [--git-revision=] [--force] formula tap`: "Look
  through repository history to find the most recent version of formula and create a
  copy in tap … at tap/Formula/formula@version.rb … To extract a formula from a tap that
  is not homebrew/core use its fully-qualified form of user/repo/formula"
  ([Manpage](https://docs.brew.sh/Manpage)). **[I]** Como o tap tem um commit por
  versão, `brew extract --version=0.5.7 sentrux/tap/sentrux <user>/<tap>` teria de onde
  tirar. Não foi testado, e a skill precisaria criar um tap próprio.
- **[F]** `brew version-install formula[@version]`: "Extract a specific version of
  formula into a personal tap and install it. The default tap is user/versions"
  ([Manpage](https://docs.brew.sh/Manpage)). A página Versions o apresenta com o
  exemplo `brew version-install automake@1.12`, que é do homebrew-core. **Não
  documentado** se funciona com fórmula de tap de terceiro.
- **[F]** Confiança em tap (Homebrew ≥ 6.0.0): "Non-official taps require explicit trust
  by default since Homebrew 6.0.0" e "Installing a fully qualified formula or cask name
  trusts only that item: `brew install user/repository/formula`"
  ([Tap Trust](https://docs.brew.sh/Tap-Trust)). Logo,
  `brew install sentrux/tap/sentrux` já concede a confiança necessária. O `brew` local
  é `6.0.22`.

### 2.3 Dependências do binário macOS

**[F]** `otool -L sentrux-darwin-arm64`, trecho:

```
/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib (compatibility version 3.0.0, current version 3.0.0)
/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib (compatibility version 3.0.0, current version 3.0.0)
/System/Library/Frameworks/AppKit.framework/... Metal.framework/... OpenGL.framework/...
```

- **[F]** `otool -l` mostra os dois openssl como `LC_LOAD_DYLIB`, não
  `LC_LOAD_WEAK_DYLIB`, com `minos 11.0` e `sdk 15.5`.
- **[I]** Numa máquina sem `openssl@3` do Homebrew em `/opt/homebrew`, o binário não
  deve carregar, porque o dyld recusa dylib não fraca ausente. Isso não foi executado.
  A fórmula não declara `depends_on "openssl@3"`.
- **[F]** Não há macOS Intel: `install.sh:22-26` aborta com "macOS Intel (x86_64)
  binary not available yet", e a issue #47 ("Intel Mac support is missing.") está
  aberta.

---

## 3. Linux

### 3.1 URLs da `v0.5.7`

- **[F]** x86_64: `https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-linux-x86_64`
- **[F]** aarch64: `https://github.com/sentrux/sentrux/releases/download/v0.5.7/sentrux-linux-aarch64`
- **[F]** O asset é o executável cru, sem tarball. O CI copia
  `target/<target>/release/sentrux` para o nome do asset e faz `chmod +x`
  (`S/.github/workflows/release.yml#L93-L101`). O download via `curl` chega sem bit de
  execução; foi observado localmente com modo `-rw-r--r--`.
- **[F]** O `install.sh` mapeia `uname -m`: `x86_64` → `sentrux-linux-x86_64` e
  `aarch64|arm64` → `sentrux-linux-aarch64` (`S/install.sh#L30-L36`).
- **[F]** O asset aarch64 existe na release, mas a fórmula do tap não o cobre (item 2.1).

### 3.2 Dependências dinâmicas

**[F]** `objdump -p` (seção dinâmica) e os símbolos versionados:

```
== sentrux-linux-x86_64
  NEEDED libgtk-3.so.0  libglib-2.0.so.0  libssl.so.3  libcrypto.so.3  libz.so.1
         libgcc_s.so.1  libm.so.6  libc.so.6  ld-linux-x86-64.so.2
  maior GLIBC_ exigido: GLIBC_2.35
== sentrux-linux-aarch64
  NEEDED libgtk-3.so.0  libgobject-2.0.so.0  libglib-2.0.so.0  libssl.so.3  libcrypto.so.3
         libz.so.1  libgcc_s.so.1  libm.so.6  libc.so.6  ld-linux-aarch64.so.1
  maior GLIBC_ exigido: GLIBC_2.35
```

- **[F]** O build roda em `ubuntu-22.04` com `libgtk-3-dev libxcb-render0-dev
  libxcb-shape0-dev libxcb-xfixes0-dev libxkbcommon-dev libssl-dev libvulkan-dev`
  (`S/.github/workflows/release.yml#L19-L62`). É glibc, não musl.
- **[F]** O sentrux tem GUI: o modo padrão, sem subcomando, abre uma janela eframe/wgpu
  com fallback para glow (`S/sentrux-bin/src/main_impl.rs#L689-L802`). A crate `rfd`
  entra com a feature `gtk3` (`S/sentrux-core/Cargo.toml#L16`).
- **[F]** O README diz "Pure Rust. Single binary. No runtime dependencies."
  (`S/README.md#L69`), o que não bate com a lista `NEEDED` acima.
- **[I]** Mesmo `check`, `gate` e `mcp`, que não abrem janela, precisam que
  `libgtk-3.so.0` e `libssl.so.3` existam para o loader resolver o `NEEDED`. Não foi
  executado.

### 3.3 Diretório de binários do usuário

- **[F]** Na [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/),
  versão 0.8 de 08/05/2021: "User-specific executable files may be stored in
  $HOME/.local/bin. Distributions should ensure this directory shows up in the UNIX
  $PATH environment variable, at an appropriate place."
- **[F]** A mesma seção avisa: "Since $HOME might be shared between systems of different
  architectures, installing compiled binaries to $HOME/.local/bin could cause problems
  when used on systems of differing architectures."
- **[Impl]** Para checar o PATH, sem fonte normativa, só a expansão POSIX de string:

  ```sh
  case ":$PATH:" in *":$HOME/.local/bin:"*) echo "no PATH" ;; *) echo "fora do PATH" ;; esac
  ```

### 3.4 O que o `install.sh` oficial faz

**[F]** Trechos de `S/install.sh`, por número de linha:

- L7: `VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed ...)`.
  Sempre baixa a **latest**.
- L12: `INSTALL_DIR="/usr/local/bin"`.
- L15-16: `OS=$(uname -s)` e `ARCH=$(uname -m)`.
- L18-41: Darwin arm64/aarch64 → `sentrux-darwin-arm64`, Darwin x86_64 → erro, Linux
  x86_64/aarch64/arm64 → asset correspondente, outros → erro.
- L43: `URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARTIFACT}"`.
- L48-56: `mktemp`, depois `curl -fsSL` ou `wget -qO`.
- L58: `chmod +x "${TMP}"`, **sem verificar checksum**.
- L60-65: se `/usr/local/bin` é gravável, `mv`; senão `sudo mv "${TMP}" "${INSTALL_DIR}/sentrux"`.
- L69-71: sugere `sentrux`, `sentrux --mcp` e `sentrux check .`.

**[F]** `install.sh`, README e `claude-plugin` são idênticos entre `v0.5.7` e `main`
(`git diff --quiet v0.5.7 main -- README.md claude-plugin install.sh .sentrux`).

---

## 4. Detecção

### 4.1 Comando e formato

- **[F]** O clap entra por derive: `#[command(name = "sentrux", about = …, version = version_string(), …)]`
  (`S/sentrux-bin/src/main_impl.rs#L47-L53`).
- **[F]** A versão vem de `version_string()` (`S/sentrux-bin/src/main_impl.rs#L29-L45`):

  ```rust
  let base = if edition.is_empty() {
      env!("CARGO_PKG_VERSION").to_string()
  } else {
      format!("{} ({})", env!("CARGO_PKG_VERSION"), edition)
  };
  if let Some(latest) = sentrux_core::app::update_check::available_update() {
      format!("{}\n  Update available: v{} → brew upgrade sentrux", base, latest)
  } else {
      base
  }
  ```

- **[F]** `edition_name()` devolve `"Pro"` se o tier for ≥ Pro e `""` nos demais casos
  (`S/sentrux-bin/src/main_impl.rs#L20-L27`).
- **[F]** `CARGO_PKG_VERSION` vale `0.5.7`: `version = "0.5.7"` em `S/sentrux-bin/Cargo.toml#L3`.
- **[F]** No clap `4.6.0` (versão travada em `Cargo.lock`), a flag padrão é
  `Arg::new(Id::VERSION).short('V').long("version")`, e o texto sai de
  `format!("{display_name} {ver}\n")`, em
  `clap_builder/src/builder/command.rs#L4829-L4833` e `#L4894-L4910` no commit
  `9ab6dee710aa384e02ec5e9e2cfeadb2f35abf2a` (tag `v4.6.0` do `clap-rs/clap`).
  `DisplayVersion` vai para o stdout e sai com `SUCCESS_CODE = 0`
  (`clap_builder/src/error/mod.rs#L218-L239` e `src/util/mod.rs#L26`).
- **[F]** A doc oficial mostra
  `sentrux --version` → `# sentrux 0.5.7`
  ([sentrux.dev/docs/installation](https://sentrux.dev/docs/installation/)).
- **[I]** Formatos possíveis na primeira linha: `sentrux 0.5.7` ou, com licença Pro,
  `sentrux 0.5.7 (Pro)`. Se `~/.sentrux/latest_version` guardar uma versão mais nova,
  vem a segunda linha `  Update available: vX.Y.Z → brew upgrade sentrux`, sempre com
  a sugestão de brew, mesmo no Linux (`S/sentrux-core/src/app/update_check.rs#L38-L58`,
  `#L78-L80`).
- **[Impl]** Para extrair a versão, ler só a primeira linha e o segundo token.

### 4.2 Efeitos colaterais de qualquer invocação

**[F]** Em `run()`, antes de `Cli::parse()` (`S/sentrux-bin/src/main_impl.rs#L157-L172`):

```rust
ensure_grammars_installed();                                   // L162
sentrux_core::analysis::plugin::sync_embedded_plugins();       // L167
app::update_check::check_for_updates_async(env!("CARGO_PKG_VERSION")); // L170
let cli = Cli::parse();                                        // L172
```

- **[F]** `ensure_grammars_installed()` roda se falta alguma gramática em
  `~/.sentrux/plugins`. Nesse caso baixa
  `https://github.com/sentrux/sentrux/releases/download/v{version}/grammars-{platform}.tar.gz`
  com `curl` e extrai com `tar xzf`, sem checksum, com mensagens no stderr
  (`S/sentrux-bin/src/main_impl.rs#L826-L903`).
  - A env `SENTRUX_SKIP_GRAMMAR_DOWNLOAD` pula esse passo (L829-831).
  - O diretório é `dirs::home_dir()/.sentrux/plugins`
    (`S/sentrux-core/src/analysis/plugin/loader.rs#L43-L45`).
- **[F]** As gramáticas são `.so`/`.dylib` carregadas como código nativo, e a verificação
  de checksum é um TODO (`S/sentrux-core/src/analysis/plugin/loader.rs#L174-L189`):

  ```rust
  // TODO: Add sha2 dependency and verify properly.
  let _ = (expected, bytes);
  Ok(())
  ```

- **[F]** `check_for_updates_async` manda, uma vez a cada 24 h, um GET por `curl` para
  `https://api.sentrux.dev/version?v=…&p=…&new=…&m=…&pl=…&t=…&s=…&mc=…&g=…&f=…&gr=…&dev=…`
  (`S/sentrux-core/src/app/update_check.rs#L83`, `#L334-L385`).
  - Ele pula se `~/.sentrux/telemetry_opt_out` existir (L242-248).
  - `sentrux analytics off` grava `"1"` nesse arquivo
    (`S/sentrux-bin/src/main_impl.rs#L220-L223`, `#L270-L276`).
- **[I]** Rodado pela primeira vez, `sentrux --version` pode baixar cerca de 9 MB e
  mandar o ping. O ping sai porque o opt-out é checado antes do parse, e só existe se
  foi criado antes.
- **[Impl]** Se a skill quiser detectar sem rede, dá para criar
  `~/.sentrux/telemetry_opt_out` e exportar `SENTRUX_SKIP_GRAMMAR_DOWNLOAD=1` só na
  chamada de versão. Isso é decisão do ticket, não do upstream.

---

## 5. MCP

### 5.1 Comando e transporte

- **[F]** Subcomando: `Mcp` documentado como "Start the MCP (Model Context Protocol)
  server for AI agent integration" (`S/sentrux-bin/src/main_impl.rs#L93-L94`).
- **[F]** Flag: `#[arg(long = "mcp", hide = true)] mcp_flag: bool` com a doc "Start MCP
  server (hidden alias for `sentrux mcp`)" (L62-64), tratada como "Hidden --mcp flag for
  backward compat with MCP client configs" (L174-178). As duas chamam
  `app::mcp_server::run_mcp_server(None)`.
- **[F]** Transporte stdio, uma mensagem JSON-RPC por linha
  (`S/sentrux-core/src/app/mcp_server/mod.rs#L1-L5`, `#L66-L98`). Métodos: `initialize`,
  `initialized`, `tools/list`, `tools/call` e `ping`. `protocolVersion` é `"2024-11-05"`
  (L140-155).
- **[F]** A doc do módulo diz "All analysis runs locally. Zero network calls." (L5), mas
  o processo passa pelo `run()` do item 4.2, com gramáticas e ping.
- **[F]** `claude-plugin/.mcp.json` no upstream, literal (`S/claude-plugin/.mcp.json`):

  ```json
  {
    "mcpServers": {
      "sentrux": {
        "command": "sentrux",
        "args": ["--mcp"]
      }
    }
  }
  ```

  O README traz o mesmo bloco (`S/README.md#L94-L103`), e a doc MCP também
  ([sentrux.dev/docs/mcp](https://sentrux.dev/docs/mcp/)). O `.gitignore` do upstream
  ignora `.mcp.json` e reinclui `claude-plugin/.mcp.json` (`S/.gitignore#L8-L9`).

### 5.2 Ferramentas: código, README, skill `scan` e doc

**[F]** O código registra 9 em `build_registry()`
(`S/sentrux-core/src/app/mcp_server/mod.rs#L218-L241`):

| Nome registrado | Definição | Parâmetros |
|---|---|---|
| `scan` | `handlers.rs#L46-L61` | `path` (string, **obrigatório**, "Absolute path") |
| `rescan` | `handlers.rs#L248-L257` | nenhum |
| `session_start` | `handlers.rs#L180-L189` | nenhum; a linha de base fica em memória |
| `session_end` | `handlers.rs#L207-L216` | nenhum |
| `health` | `handlers.rs#L94-L103` | nenhum |
| `check_rules` | `handlers.rs#L281-L290` | nenhum |
| `git_stats` | `handlers_evo.rs#L62-L75` (função `evolution_def`) | `days` (inteiro, padrão 90) |
| `dsm` | `handlers_evo.rs#L118-L128` | nenhum |
| `test_gaps` | `handlers_evo.rs#L182-L192` | `limit` (inteiro, padrão 20) |

- **[F]** O código diz que as outras foram removidas:
  "Redundant tools removed: coupling, cycles, architecture, blast_radius, hottest, level."
  (`S/sentrux-core/src/app/mcp_server/handlers.rs#L172`).
- **[F]** O binário publicado tem os mesmos 9 `_def`. Nos símbolos do
  `sentrux-linux-x86_64` (não stripado), os únicos `…mcp_server…_def` são
  `scan_def`, `rescan_def`, `session_start_def`, `session_end_def`, `health_def`,
  `check_rules_def`, `evolution_def`, `dsm_def` e `test_gaps_def`. **[I]** Não aparecem
  ferramentas extras do `sentrux_pro`: os únicos símbolos dele são `sentrux_pro::init`
  e `sentrux_pro::license::load_and_validate`.
- **[F]** O README lista 9, mas com `evolution` no lugar de `git_stats`:
  "9 tools: `scan` · `health` · `session_start` · `session_end` · `rescan` · `check_rules` · `evolution` · `dsm` · `test_gaps`"
  (`S/README.md#L202`).
- **[F]** A skill `scan` do upstream lista 15:
  "`scan` · `health` · `architecture` · `coupling` · `cycles` · `hottest` · `evolution` · `dsm` · `test_gaps` · `check_rules` · `session_start` · `session_end` · `rescan` · `blast_radius` · `level`"
  (`S/claude-plugin/skills/scan/SKILL.md#L14`).
  - Delas, 7 não existem no código: `architecture`, `coupling`, `cycles`, `hottest`,
    `evolution`, `blast_radius` e `level`.
  - Falta `git_stats`, que existe.
- **[F]** A doc MCP do site lista os 9 nomes corretos, com `git_stats`
  ([sentrux.dev/docs/mcp](https://sentrux.dev/docs/mcp/)).
- **[F]** No tier Free, `check_rules` do MCP verifica **no máximo 3 regras**. As
  constraints contam como uma, e cada layer e cada boundary como uma. A resposta ganha
  `"truncated"` e a mensagem "Checking up to 3 rules. More available with sentrux Pro"
  (`S/sentrux-core/src/app/mcp_server/handlers.rs#L304-L341`). A CLI `sentrux check`
  não trunca (`S/sentrux-bin/src/main_impl.rs#L285-L319`).
- **[F]** No tier Free, `health` não devolve `diagnostics`, devolve `upgrade`
  (`handlers.rs#L137-L167`).

### 5.3 `claude mcp add`: sintaxe e escopos

**[F]** Saída literal local (`claude --version` → `2.1.270 (Claude Code)`):

```
Usage: claude mcp add [options] <name> <commandOrUrl> [args...]
...
  # Add stdio server with subprocess flags:
  claude mcp add my-server -- my-command --some-flag arg1

Options:
  ...
  -s, --scope <scope>          Configuration scope (local, user, or project)
                               (default: "local")
  -t, --transport <transport>  Transport type (stdio, sse, http). Defaults to
                               stdio if not specified.
```

**[F]** Da doc oficial [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp):

- Sintaxe stdio: `claude mcp add [options] <name> -- <command> [args...]`. "the `--`
  (double dash) separates Claude's own options, such as `--transport`, `--env`, and
  `--scope`, from the command and arguments that run the server"
  (seção "Option 3: Add a local stdio server").
- Tabela "MCP installation scopes":

  | Scope | Loads in | Shared with team | Stored in |
  |---|---|---|---|
  | Local | Current project only | No | `~/.claude.json` |
  | Project | Current project only | Yes, via version control | `.mcp.json` in project root |
  | User | All your projects | No | `~/.claude.json` |

- Local: "Local scope is the default … Claude Code stores it in `~/.claude.json` under
  that project's path". O exemplo resultante é
  `{"projects": {"/path/to/your/project": {"mcpServers": {...}}}}`.
- Project: "When you add a project-scoped server, Claude Code automatically creates or
  updates this file". O exemplo de `.mcp.json` é `{"mcpServers": {"shared-server": {"type": "http", "url": …}}}`.
  Também diz que se pode, em vez disso, "add the entry under `mcpServers` in `.mcp.json`
  at your project root and commit it".
- Aprovação: "Claude Code prompts for approval in interactive sessions before using
  project-scoped servers from `.mcp.json` files. To reset those approval choices, run
  `claude mcp reset-project-choices`." Em `claude -p`, no Agent SDK e em sessões cloud,
  carrega sem perguntar.
- Entrada sem `type`: "Claude Code reads an entry with no `type` as a stdio server".
  Logo, o bloco do upstream, sem `type`, é válido.
- Expansão: `${VAR}` e `${VAR:-default}` valem em `command`, `args`, `env`, `url` e
  `headers` (seção "Environment variable expansion").
- Precedência entre escopos: Local > Project > User, casando pelo nome.

**[Impl]** Comandos para a `v0.5.7`:

```sh
claude mcp add --scope project sentrux -- sentrux --mcp   # grava .mcp.json na raiz
claude mcp add --scope local   sentrux -- sentrux --mcp   # grava ~/.claude.json (projects[<cwd>])
```

- **Não documentado:** o JSON exato que `claude mcp add` grava para um servidor stdio.
  A doc só mostra o resultado para `http`. **[I]** As entradas stdio já presentes no
  `~/.claude.json` desta máquina têm as chaves `type,command,args,env` ou `args,command`;
  só as chaves foram lidas, e não dá para saber quais foram gravadas pelo CLI.
- **[I]** O `command: "sentrux"` depende do PATH do processo do Claude Code. Com
  instalação em `~/.local/bin` fora do PATH, o servidor falha.
- **[Impl]** A spec fala em "só para o usuário". A doc distingue `local` (este projeto,
  privado) de `user` (todos os projetos). O pedido do Leader mapeia para `local`.

---

## 6. CLI

### 6.1 Subcomandos da `v0.5.7`

**[F]** `enum Command` (`S/sentrux-bin/src/main_impl.rs#L67-L151`):

| Subcomando | Doc no código |
|---|---|
| `check [path]` | "Enforce architectural rules defined in .sentrux/rules.toml". `path` padrão `"."` |
| `gate [--save] [path]` | "Structural regression gate — compare against a saved baseline". `--save`: "Save current metrics as the new baseline". `path` padrão `"."` |
| `scan [path]` | "Open the GUI with a pre-loaded directory" |
| `mcp` | "Start the MCP (Model Context Protocol) server for AI agent integration" |
| `plugin list\|add-standard\|add <name>\|remove <name>\|init <name>\|validate <dir>` | "Manage language plugins" |
| `analytics [on\|off]` | "Control anonymous aggregate usage analytics" |
| `login` | "Upgrade to Sentrux Pro" |
| (sem subcomando) `[path]` | "Directory to open in the GUI" |
| `--mcp` (oculta) | "Start MCP server (hidden alias for `sentrux mcp`)" |

- **[F]** Não existe `--json` em `check` nem em `gate`. O PR #40, "feat: add --json output
  for check/gate and cycle path reporting", está aberto desde 2026-03-30.
- **[F]** A `main` tem 5 commits depois da tag, que acrescentam `sentrux pro
  activate/status/deactivate/update` (`6f8ff3c` "Add Pro CLI commands…"). Eles **não
  estão** na `v0.5.7`. A página
  [sentrux.dev/docs/pro](https://sentrux.dev/docs/pro/) já documenta esses comandos.

### 6.2 `sentrux check`

**[F]** `run_check` e `print_check_results` (`S/sentrux-bin/src/main_impl.rs#L285-L348`):

| Situação | Saída | Exit |
|---|---|---|
| `path` não é diretório | stderr `Error: not a directory: {path}` | 1 |
| `RulesConfig::try_load` devolve `None` | stderr `No .sentrux/rules.toml found in {path}` | 1 |
| Falha de scan | stderr `Scan failed: {e}` | 1 |
| Sem violações | stdout `sentrux check — N rules checked`, `Quality: X`, `✓ All rules pass` | 0 |
| Com violações | stdout `{icon} [{Severity:?}] {rule}: {message}`, os arquivos indentados, `✗ N violation(s) found` | 1 |

- **[F]** `try_load` devolve `None` também quando o TOML **não parseia**. Nesse caso
  imprime antes `Warning: Failed to parse …` (`S/sentrux-core/src/metrics/rules/mod.rs#L113-L128`).
  A mensagem seguinte ainda diz "No .sentrux/rules.toml found".
- **[F]** O `Scanning {path}...` vai para o stderr (L301).
- **[F]** O exit 1 sai quando `check.violations` não está vazio (L331-347). Hoje toda
  violação tem `Severity::Error`.
- **[F]** Erro de uso do clap (argumento inválido) sai com `USAGE_CODE = 2`
  (`clap_builder/src/util/mod.rs#L32`, `error/mod.rs#L233-L239` no commit `9ab6dee`).

### 6.3 `sentrux gate --save` e `sentrux gate`

- **[F]** O caminho da linha de base é `root.join(".sentrux").join("baseline.json")`,
  relativo ao `path` passado (`S/sentrux-bin/src/main_impl.rs#L362`).
- **[F]** `gate --save` cria `.sentrux/` se preciso e grava JSON com
  `serde_json::to_string_pretty` (`S/sentrux-core/src/metrics/arch/mod.rs#L191-L197`).
  Imprime `Baseline saved to …`, `Quality: X` e
  ``Run `sentrux gate` after making changes to compare.``, e sai com 0. Falha de escrita
  sai com 1 (`main_impl.rs#L387-L412`).
- **[F]** Formato da linha de base, `struct ArchBaseline` (`arch/mod.rs#L119-L141`):

  ```json
  {
    "timestamp": 0.0,
    "quality_signal": 0.0,
    "coupling_score": 0.0,
    "cycle_count": 0,
    "god_file_count": 0,
    "hotspot_count": 0,
    "complex_fn_count": 0,
    "max_depth": 0,
    "total_import_edges": 0,
    "cross_module_edges": 0
  }
  ```

  Os valores acima são só ilustrativos, mas as chaves são as reais. `quality_signal`
  fica na escala 0–1; a saída de texto multiplica por 10000.
- **[F]** `gate` sem `--save`:
  - sem linha de base, stderr `Failed to load baseline at …` e ``Run `sentrux gate --save` first to create one.``, exit 1;
  - com linha de base, stdout `Quality: A -> B`, `Coupling: …`, `Cycles: …`,
    `God files: …`, e então `✓ No degradation detected` com exit 0 ou `✗ DEGRADED` com
    a lista e exit 1 (`main_impl.rs#L414-L452`).
- **[F]** O que conta como degradação, em `ArchBaseline::diff` (`arch/mod.rs#L209-L249`):
  - `quality_signal` cai mais de 0.02 → "Quality signal dropped: …";
  - `coupling_score` sobe mais de 0.05 → "Coupling degraded: …";
  - `circular_dep_count` aumenta → "Cycles increased: …";
  - `god_files.len()` aumenta → "God files increased: …";
  - `complex_functions.len()` aumenta → "Complex functions increased: …";
  - `degraded` é verdadeiro se houver qualquer um desses.
- **[F]** O gate não lê `.sentrux/rules.toml`: `run_gate` só calcula `health` e
  `arch_report` (`main_impl.rs#L355-L385`).
- **[F]** O `.gitignore` do upstream ignora a própria linha de base:
  `.sentrux/baseline.json` (`S/.gitignore#L12`).
- **[F]** O `session_start` do MCP **não** grava arquivo: guarda a linha de base em
  `state.baseline`, na memória (`handlers.rs#L191-L201`). Ela não se mistura com a da CLI.

### 6.4 O que o scan enxerga

- **[F]** Num repositório git, os arquivos vêm de `git ls-files -z`. Só cai no walk do
  sistema de arquivos se não for repositório ou se o git falhar
  (`S/sentrux-core/src/analysis/scanner/mod.rs#L86-L107`).
- **[I]** `git ls-files` sem flags lista o índice. Arquivo novo que ainda não passou por
  `git add` não entra no scan e, portanto, não entra no gate. O PR #50, "[codex] Include
  untracked files in scans on request", está aberto. O conteúdo lido é o do disco
  (`fs::read`, `scanner/mod.rs#L211`).
- **[F]** Os caminhos dos nós e das arestas são relativos à raiz escaneada, com `/`:
  `collected.path.strip_prefix(root)` seguido de `normalize_path`
  (`scanner/mod.rs#L204-L206`).
- **[F]** Não há exclusão configurável: `exclude_globs` e `.sentruxignore` não existem
  (issue #41, aberta). O único filtro é por extensão (`IGNORED_EXTENSIONS`,
  `scanner/common.rs#L81-L87`) e, no walk, por diretório.

---

## 7. Regras (`.sentrux/rules.toml`)

### 7.1 Onde o arquivo é procurado

**[F]** O arquivo é `root.join(".sentrux").join("rules.toml")`, com `root` igual ao
`path` do `check` ou ao `path` do último `scan` do MCP
(`S/sentrux-core/src/metrics/rules/mod.rs#L113-L128`, `handlers.rs#L298-L302`). Não
sobe para diretórios pais.

### 7.2 Structs de desserialização

**[F]** `RulesConfig` (`rules/mod.rs#L37-L55`):

```rust
pub struct RulesConfig {
    #[serde(default)] pub constraints: Constraints,
    #[serde(default)] pub language: std::collections::HashMap<String, LanguageConstraints>,
    #[serde(default)] pub layers: Vec<LayerDef>,
    #[serde(default)] pub boundaries: Vec<BoundaryRule>,
}
```

**[F]** `[constraints]`, `struct Constraints` (`rules/checks.rs#L16-L48`), com
`#[derive(Deserialize, Default)]`:

| Campo | Tipo | Padrão | Checagem |
|---|---|---|---|
| `min_quality` | `Option<f64>` (0.0–1.0) | ausente | `quality_signal < min` |
| `min_modularity` | `Option<f64>` | ausente | score `< min` |
| `min_acyclicity` | `Option<f64>` | ausente | score `< min` |
| `min_depth` | `Option<f64>` | ausente | score `< min` |
| `min_equality` | `Option<f64>` | ausente | score `< min` |
| `min_redundancy` | `Option<f64>` | ausente | score `< min` |
| `max_coupling_score` | `Option<f64>` | ausente | `coupling_score > max` |
| `max_cycles` | `Option<usize>` | ausente | `circular_dep_count > max` |
| `max_cc` | `Option<u32>` | ausente | alguma função com CC `> max` |
| `max_file_lines` | `Option<u32>` | ausente | algum arquivo `> max` linhas |
| `max_fn_lines` | `Option<u32>` | ausente | alguma função `> max` linhas |
| `no_god_files` | `bool` com `#[serde(default)]` | `false` | algum god file ("fan-out > 15") |
| `max_upward_violations` | `Option<usize>` | ausente | `upward_violations.len() > max` |

- **[F]** Constraint ausente não é checada (`rules/mod.rs#L148-L172`).
- **[F]** `[language.<nome>.constraints]` é parseado, mas `effective_constraints` não tem
  chamador fora da própria definição. `check_rules` só usa `config.constraints`
  (`rules/mod.rs#L145`). A busca `grep -rn effective_constraints` fora de testes só
  encontra a definição.
- **[F]** Nenhuma struct usa `#[serde(deny_unknown_fields)]` (`grep` devolve 0 em
  `sentrux-core` e `sentrux-bin`). Pela
  [doc do serde](https://serde.rs/container-attrs.html): "When this attribute is not
  present, by default unknown fields are ignored for self-describing formats like JSON."
  **[I]** O mesmo vale para o `toml` 0.8 via serde, e a issue #41 relata isso com
  `exclude_globs`. Chave com erro de digitação, como `max_coupling = "B"`, some sem aviso.

**[F]** `[[layers]]`, `struct LayerDef` (`rules/mod.rs#L77-L87`):

```rust
pub struct LayerDef {
    pub name: String,          // obrigatório
    pub paths: Vec<String>,    // obrigatório
    /// Layer order (lower = more foundational). Layers can only depend downward.
    /// If not specified, order is determined by position in the array.
    pub order: Option<u32>,
}
```

Não há campo `reason` em `LayerDef`.

**[F]** `[[boundaries]]`, `struct BoundaryRule` (`rules/mod.rs#L89-L99`):

```rust
/// Deny rule: files matching `from` must not import files matching `to`.
pub struct BoundaryRule {
    pub from: String,              // obrigatório
    pub to: String,                // obrigatório
    #[serde(default)]
    pub reason: String,            // opcional, texto livre, padrão ""
}
```

### 7.3 Semântica de `order`: o que o código faz

**[F]** `check_layers` (`rules/mod.rs#L190-L233`):

```rust
let order = l.order.unwrap_or(i as u32) as usize;   // L200: sem order, usa a posição no array
...
if let (Some((from_ord, from_name)), Some((to_ord, to_name))) = (from_layer, to_layer) {
    // Violation: importing from a higher-order (less foundational) layer
    // Lower order = more foundational. A file in order=2 importing order=0 is wrong
    // (infrastructure importing presentation).
    if from_ord > to_ord {
        violations.push(RuleViolation { rule: "layer_direction".into(), severity: Severity::Error,
            message: format!("Layer violation: {} ({}) imports {} ({}). {} must not depend on {}.", …), … });
```

**[F]** Os testes da tag fixam esse sentido (`rules/tests.rs#L169-L225`):

- `presentation` com `order = 0` e `infrastructure` com `order = 2`;
- "Infrastructure imports presentation = violation" (edge `src/scanner.rs` → `src/ui/panel.rs`);
- "Presentation imports infrastructure = correct direction" (edge inverso).

**Fato resultante.** Na `v0.5.7`, um arquivo de `order` N **pode** importar camadas de
`order` ≥ N. Importar camada de `order` menor é `layer_direction`. O `order` menor é,
portanto, a camada de **cima** (a que importa), e o maior é a fundação.

**[F]** Isso contradiz quatro textos do próprio upstream:

- o doc comment do campo, "lower = more foundational. Layers can only depend downward"
  (`rules/mod.rs#L84`);
- o comentário do `rules.toml` do repositório, "higher order depends on lower order only"
  (`S/.sentrux/rules.toml#L10`);
- a doc do site: "Lower `order` = more foundational. Higher layers can depend on lower
  layers, but not vice versa. app (order 2) → can depend on service and core"
  ([sentrux.dev/docs/rules-engine](https://sentrux.dev/docs/rules-engine/));
- o exemplo do README com `core` em `order = 0` e `app` em `order = 2` (`S/README.md#L217-L225`).
  **[I]** Pelo código, esse exemplo acusa `app` importando `core`.

**[F]** A issue #46, "layer ordering mismatch in v0.5.7", aberta em 2026-05-03, aponta
exatamente isso, sem nenhuma resposta.

**[F]** O PR #67, "reverse layers.order compare logic, and add 规则说明.md to explain the
params in rules.toml", de @perphyyoung:

- estado `OPEN`, criado em 2026-08-29, atualizado em 2026-09-07, sem merge, sem review e
  sem comentário;
- troca `if from_ord > to_ord` por `if from_ord < to_ord`, reescreve os comentários
  ("Dependencies flow upward: foundational layers can be imported by higher layers, but
  not vice versa") e inverte os testes;
- acrescenta um teste `glob_has_no_middle_wildcard_support` e um documento em chinês;
- o corpo diz "developed on Windows 11 using AI and is **minimally tested**";
- a origem é a `main` do fork (`gh pr view 67 --json …`, `gh pr diff 67`).

**[I]** Se o PR #67 entrar numa release, um mesmo `rules.toml` passa a acusar a direção
oposta.

### 7.4 Outras regras de avaliação

- **[F]** Camadas só são checadas se houver **pelo menos 2** (`rules/mod.rs#L175-L178`).
  Toda a checagem de camadas conta como 1 regra, e cada boundary conta como 1.
- **[F]** Um arquivo pertence à **primeira** camada, na ordem do array, cujo padrão case
  (`find_layer`, L236-248). Arquivo fora de todas as camadas não é checado.
- **[F]** Na boundary, a violação sai quando `glob_match(from, edge.from_file)` e
  `glob_match(to, edge.to_file)` casam juntos (L289-314).
- **[F]** O `reason` **não** vira campo próprio. Ele é concatenado na `message`:

  ```rust
  "Boundary violation: {} imports {}{}", edge.from_file, edge.to_file,
  if rule.reason.is_empty() { String::new() } else { format!(" — {}", rule.reason) }
  ```

  Na CLI fica `✗ [Error] boundary: Boundary violation: a.rs imports b.rs — <reason>`,
  seguido dos dois arquivos. No MCP, o JSON de cada violação tem só `rule`, `severity`,
  `message` e `files` (`handlers.rs#L326-L331`). A doc do site mostra um JSON com
  `from`, `to` e `reason` separados, que o código não produz.
- **[F]** `passed` só é falso se houver violação `Error` (L186). Na CLI, qualquer
  violação dá exit 1.

### 7.5 Casamento de caminhos: `glob_match`

**[F]** `rules/mod.rs#L250-L287`, aplicado sobre caminhos relativos à raiz, com `/`:

| Padrão | Regra do código | Observação |
|---|---|---|
| igual ao caminho | `pattern == path` | |
| `dir/**/*` | `path.starts_with(dir) && path.len() > dir.len()` | qualquer profundidade |
| `dir/**` | igual ao anterior | qualquer profundidade |
| `dir/*` | tira o prefixo `dir`, depois um `/` opcional, e exige que o resto não tenha `/` | **só filhos diretos** |
| `*.ext` | `path.ends_with(".ext")` | em qualquer lugar |
| `dir` | `path.starts_with(dir)` e o próximo byte é `/` | prefixo de diretório |
| qualquer outro | `false` | sem curinga no meio: `*/src/*` e `**/x` não casam |

- **[I]** `dir/**` e `dir/*` não checam a fronteira de `/` depois do prefixo. Pelo
  código, `src/core/**` também casa `src/core_extra/a.rs`, e `src/core/*` casa
  `src/core_x.rs`, porque `strip_prefix("src/core")` deixa `"_x.rs"`, sem `/`.
- **[I]** O `rules.toml` do próprio repositório não casa nenhum arquivo. Os padrões são
  `src/core/*` e similares, e o repositório não tem `src/` na raiz: `git ls-files | grep -c '^src/'`
  devolve 0, porque o código vive em `sentrux-core/src/…`. O PR #67 inclui um teste que
  afirma `!glob_match("src/renderer/*", "sentrux-core/src/renderer/x.rs")`.

### 7.6 Exemplos reais

**[F]** O `.sentrux/rules.toml` do repositório, literal (`S/.sentrux/rules.toml`):

```toml
# Sentrux Architectural Rules
# These constraints are checked by `sentrux check` and the `check_rules` MCP tool.

[constraints]
max_cycles = 0           # No circular dependencies allowed
max_cc = 25              # Max cyclomatic complexity per function
max_fn_lines = 100       # Max function length
no_god_files = false     # Allow god files for now

# Layer definitions: higher order depends on lower order only.
[[layers]]
name = "core"
paths = ["src/core/*"]
order = 0

[[layers]]
name = "analysis"
paths = ["src/analysis/*"]
order = 1

[[layers]]
name = "metrics"
paths = ["src/metrics/*"]
order = 2

[[layers]]
name = "layout"
paths = ["src/layout/*"]
order = 3

[[layers]]
name = "renderer"
paths = ["src/renderer/*"]
order = 4

[[layers]]
name = "app"
paths = ["src/app/*"]
order = 5

# Boundary rules: forbidden cross-layer shortcuts
[[boundaries]]
from = "src/renderer/*"
to = "src/analysis/*"
reason = "Renderer must not depend on analysis directly"

[[boundaries]]
from = "src/layout/*"
to = "src/app/*"
reason = "Layout must not depend on app layer"
```

**[F]** O exemplo do README (`S/README.md#L210-L231`):

```toml
[constraints]
max_cycles = 0
max_coupling = "B"
max_cc = 25
no_god_files = true

[[layers]]
name = "core"
paths = ["src/core/*"]
order = 0

[[layers]]
name = "app"
paths = ["src/app/*"]
order = 2

[[boundaries]]
from = "src/app/*"
to = "src/core/internal/*"
reason = "App must not depend on core internals"
```

**[F]** `max_coupling` não existe na struct; o campo é `max_coupling_score: Option<f64>`.
A doc do site repete `max_coupling = "B"` e acrescenta uma camada `service` com
`order = 1` ([rules-engine](https://sentrux.dev/docs/rules-engine/)).

---

## 8. Manutenção hoje

**[F]** Comandos rodados em 2026-09-13:

| Item | Valor | Fonte |
|---|---|---|
| Último commit na `main` | `6f8ff3c14b0423e4b58f42d1813d4d5f7fdc1d11`, 2026-03-19T02:23:12Z, "Add Pro CLI commands: login, pro activate/status/deactivate/update" | `gh api repos/sentrux/sentrux/commits/main` |
| `pushed_at` do repositório | 2026-03-19T02:23:12Z | `gh api repos/sentrux/sentrux` |
| Último merge de PR | #13 "feat: add Elixir import resolution for cohesion metrics", 2026-03-13T22:59:06Z | `gh pr list --state merged -L 500`, ordenado por `mergedAt` |
| PRs mergeados no total | 6 | idem, `jq length` |
| PRs abertos | 9 (#67, #65, #59, #50, #49, #40, #39, #34, #26) | `gh pr list --state open -L 500 --json number \| jq length` |
| Issues abertas | 25 | `gh issue list --state open -L 500 --json number \| jq length` |
| `open_issues_count` da API (issues + PRs) | 34 = 25 + 9 | `gh api repos/sentrux/sentrux` |
| Última release vs. último commit | `v0.5.7` em `f36da08` (2026-03-18T23:24Z); a `main` está 5 commits à frente (Pro license/loader/CLI), sem release | `git log --oneline v0.5.7..main` |

- **[F]** Bug #66 (issue, não PR: `pull_request` nulo na API):
  - título: "Removing a file from the scanned set redirects its inbound import edges to
    the package entry point, inventing false cycles";
  - estado `OPEN`, criada em 2026-08-26 por @undeemed, sem comentários;
  - resumo: quando um arquivo sai do conjunto escaneado, as importações para ele são
    redirecionadas ao entry point do pacote e inventam ciclos inexistentes. Foi
    reproduzido na 0.5.7, Linux x86_64.
- **[F]** PR #67: ver o item 7.3. Estado `OPEN`, 2026-08-29, sem merge.
- **[F]** Outras issues abertas que tocam os tickets:
  - #46, `order` invertido;
  - #41, sem exclusão configurável;
  - #47, sem Intel Mac;
  - #48, "Could not find where sentrux produces logs about rules violation in headless mode usage";
  - #20, auditoria de segurança de 2026-03-15 sobre a v0.4.9. Ela aponta falta de
    checksum no `install.sh` e nos tarballs de gramática, e a verificação de checksum
    das gramáticas como código morto. O código da `v0.5.7` ainda tem o TODO (item 4.2).
- **[F]** Nenhuma issue foi fechada depois de 2026-03-19. Ordenando todas as fechadas
  por `closedAt`, a mais recente é a #28, em 2026-03-19T08:30:34Z
  (`gh issue list --state closed -L 500 --json number,closedAt`).

---

## Achados anteriores: conferência

| Achado | Veredito | Fonte |
|---|---|---|
| Último push de código em 2026-03-19 | **Vale.** Commit `6f8ff3c` em 2026-03-19T02:23:12Z, igual ao `pushed_at` | item 8 |
| PRs e bugs abertos sem merge, inclusive #66 (ciclos falsos) | **Vale, com precisão:** 9 PRs e 25 issues abertos, último merge em 2026-03-13. O #66 é **issue** de bug, não PR. Também está aberto o PR #67, que muda a semântica de `order` | item 8 |
| A skill `scan` cita 15 ferramentas e o README cita 9 | **Vale, e é pior.** O código registra 9, mas o README usa `evolution` onde o código diz `git_stats`, e 7 das 15 da skill não existem | item 5.2 |
| Releases publicam binários sem checksum | **Vale para o upstream** (sem arquivo, assinatura ou attestation). **Mudou a nuance:** todo asset tem `digest` sha256 calculado pelo GitHub, e a fórmula do tap declara `sha256`, que o Homebrew confere | itens 1.3 e 2.1 |
| O `install.sh` baixa `latest` e usa `sudo mv` | **Vale.** `latest` na L7; `sudo mv` na L64, só quando `/usr/local/bin` não é gravável | item 3.4 |

---

## Surpresas

Pontos que contradizem a spec, os achados anteriores ou a documentação do upstream.

1. **O binário publicado não sai do código público.** O `release.yml` faz checkout do
   repositório privado `sentrux/sentrux-pro` e compila com
   `--manifest-path ../sentrux-pro/Cargo.toml` (`S/.github/workflows/release.yml#L64-L91`).
   Os símbolos do binário Linux incluem `sentrux_pro::init` e
   `sentrux_pro::license::load_and_validate`. A página Pro do site diz "The free binary
   is 100% open source (MIT)".
   **[I]** O comportamento descrito neste documento vem do código público e pode
   divergir no binário. Os nomes das 9 ferramentas MCP, as mensagens de `check` e `gate`
   e o caminho `baseline.json` aparecem como strings no binário, o que reduz esse risco.
2. **`order` está invertido em relação a toda a documentação** (item 7.3). A issue #46
   não tem resposta, e o PR #67, que inverte o código, está aberto.
3. **`reason` não aparece como campo** na saída. Vai concatenado na `message` após ` — `.
   `[[layers]]` não tem `reason`.
4. **Chaves desconhecidas são ignoradas em silêncio.** O próprio README usa
   `max_coupling = "B"`, que não faz nada. TOML inválido gera a mensagem enganosa "No
   .sentrux/rules.toml found" e exit 1.
5. **O glob é limitado.** `dir/*` só pega filhos diretos, não há curinga no meio, e o
   prefixo não checa a fronteira de `/`. O `rules.toml` do próprio repositório não casa
   nenhum arquivo.
6. **A fórmula do Homebrew tem `sha256`**, igual ao `digest` do GitHub, e o Homebrew o
   verifica. O aviso "não há checksum" é exato para o Linux e o upstream, mas não para o
   caminho brew no sentido de integridade do download.
7. **Todo asset tem `digest` do GitHub**, que dá para conferir no Linux sem depender do
   upstream. **[Impl]** Por exemplo:
   `gh api repos/sentrux/sentrux/releases/tags/v0.5.7 --jq '.assets[]|select(.name=="sentrux-linux-x86_64").digest'`
   contra `sha256sum`. Ou gravar na skill os digests desta tabela.
8. **O binário macOS linka `/opt/homebrew/opt/openssl@3`** e a fórmula não declara a
   dependência. Não há build Intel.
9. **O binário Linux não é "No runtime dependencies"**: exige `libgtk-3.so.0`,
   `libssl.so.3` e glibc ≥ 2.35. O asset aarch64 existe, mas a fórmula não o cobre.
10. **Qualquer invocação tem rede e escrita em `~/.sentrux`**, inclusive `--version` e
    `mcp`: gramáticas sem checksum carregadas como código nativo, e ping diário de
    telemetria ligado por padrão.
11. **O scan só vê arquivos rastreados pelo git.** O ponto B do ticket 12, "o gate acusa
    degradação numa sessão que cria um ciclo", só funciona se os arquivos novos do ciclo
    estiverem no índice.
12. **O gate não usa `rules.toml`.** Fronteira violada não degrada o gate; quem falha é o
    `check`. O `check_rules` do MCP no tier Free trunca em 3 regras; a CLI não.
13. **O nome real da ferramenta é `git_stats`**, não `evolution`.
14. **"Só para o usuário" na spec é ambíguo** entre os escopos `local` e `user` do Claude
    Code.

---

## Não documentado / limitações

- **Nada foi executado.**
  - O formato de `--version` vem do código e da doc do site, não de uma execução.
  - O efeito real da falta de `openssl@3` no macOS e das libs no Linux é inferência.
  - O binário vem de código privado (Surpresa 1).
- **O JSON exato que `claude mcp add` grava para stdio** não aparece na doc, que só
  mostra `http`. Não foi testado, por instrução de não registrar servidor.
- **`brew extract` e `brew version-install` com esta fórmula de tap** não foram testados.
  A doc do `version-install` só exemplifica com o homebrew-core.
- **Limiares de god file e de função complexa usados pelo gate:** o código usa
  `fan_out_threshold_for_path` e a lista `complex_functions` do `HealthReport`. Os
  valores exatos por linguagem e caminho não foram levantados. `no_god_files` só diz
  "fan-out > 15" na mensagem.
- **Se o `sentrux_pro::init` do binário muda algo em `check`, `gate` ou no MCP** (tier,
  truncamento, ferramentas extras): não documentado, e o código é privado.
- **Comportamento do `toml` 0.8 com chave desconhecida:** inferido do padrão do serde
  mais o relato da issue #41, sem teste isolado.
- **A doc do site não é versionada.** A página Pro já descreve comandos da `main` que não
  estão na `v0.5.7`.
- **Tamanho e tempo do primeiro download de gramáticas:** o código diz "~30MB"
  (`main_impl.rs#L863`), mas o tarball da `v0.5.7` tem de 8,1 a 8,9 MB compactado.
