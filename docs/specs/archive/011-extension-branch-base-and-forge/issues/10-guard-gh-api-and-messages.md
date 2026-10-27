# 10: A guarda cobre o `gh api` e cita os dois forges

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=9bb8cc0; scope=full; verdict=pass; p1=none

**What to build:** a guarda de merge passa a conferir o PR criado por `gh api` com
`POST` sobre um caminho de `pulls`, além do `gh pr` e do `tea pr`, e as mensagens e
o filtro rápido citam `gh` e `tea`.

- [x] `gh api -X POST repos/<o>/<r>/pulls …` e as formas com `--method POST` são
      conferidas numa spec sem archive e bloqueadas; um `gh api` de leitura não é.
- [x] `gh pr create --fill` é conferido como os outros `gh pr create`.
- [x] As mensagens da guarda, o cabeçalho dela e o texto que a explica no perfil do
      tracker e no `ARCHIVE.md` citam `gh` e `tea`.
- [x] Prova S1, num diretório novo de `workspace/`, com `workspace/04-hook-merge/` e
      `workspace/40-global-guard/` como prior art: os dois `gh api` com `POST`
      bloqueados; o `gh api` de leitura e a menção em `echo` passam; o
      `gh pr create --fill` bloqueado; os casos antigos continuam.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o `gh api` conta como PR quando o método é POST e o endpoint é
  `repos/<o>/<r>/pulls` (com ou sem `/` no começo, URL inteira ou `/api/v3/` do
  Enterprise). O método vem do `-X`/`--method`, inclusive `-XPOST`, `--method=POST`
  e minúsculo; sem ele, é POST quando há `-f`, `-F` ou `--input`, como o próprio
  `gh api --help` diz ("adding request parameters will automatically switch the
  request method to `POST`"). Método ou endpoint com `$` ou crase é conferido,
  pela postura fail-closed da guarda. O POST em `pulls/<n>/reviews` e o
  `gh api graphql`, o `PUT .../pulls/<n>/merge` e o `curl` direto passam, e ficam
  na lista "O que a guarda NÃO pega" do cabeçalho: a spec pede o PR criado por
  `POST` em `pulls`.
- Implementação · o filtro rápido ganhou `gh[^"]{0,4}api`; sem `python3`, todo
  `gh api` é conferido, como o resto do que o filtro pega.
- Implementação · o `gh pr create --fill` já era conferido (o parse olha só
  `gh pr create`); a prova o fixa.
- Implementação · além do perfil do tracker e do `ARCHIVE.md`, o manual
  `anvil-omp` e o aviso de guarda ausente do hook da camada omp citam `gh` e
  `tea` (o ticket 02 deixou a menção ao `tea pr create` do manual para este).
- Implementação · prova em `workspace/79-guard-gh-api/s1.sh`, no bash do `PATH` e
  no `/bin/bash` 3.2: 40 casos novos e os 120 de
  `workspace/11-merge-target/run.sh` em `antigos.sh`, que os roda na guarda de hoje
  (com a rule `anvil.md`, sem a qual a guarda sai 0 desde a 006); o
  `workspace/40-global-guard/s1.sh` também passa. `vendor-sync.sh verify` limpo.
- Review round=1 · P3 (Standards): `gh_api_abre_pr`, `incognita`, `GH_API_VALOR` e `GH_API_PARAMETRO` em pt-BR contrariam a seção Idioma do `CLAUDE.md` (identificador em inglês), seguindo o estilo do arquivo (`nome`, `redireciona`) — só aumenta a dívida de idioma do script.
- Review round=1 · P3 (Standards): possível Duplicated Code — o `incognita()` novo não é usado na linha do `gh api` (`"$" in palavras[k]`) nem nas checagens antigas do `git`, e duas das três grafias ignoram a crase (`` `which gh` api -X POST repos/o/r/pulls `` dá `ignora`, como `` `which git` merge `` já dava) — quem fechar essa lacuna precisa achar os três lugares.
- Review round=1 · P3 (Standards): possível Duplicated Code — `GH_API_PARAMETRO` é subconjunto de `GH_API_VALOR` escrito por extenso duas vezes; uma opção de parâmetro nova posta numa lista só faz a regra "parâmetro sem `-X` é POST" divergir em silêncio.
- Review round=1 · P3 (Standards): possível Duplicated Code — o salto de redirecionamento do `gh_api_abre_pr` repete o do laço de alvos do merge — dois lugares a manter iguais.
- Review round=1 · P3 (Standards): `post = parametro if metodo is None else metodo.upper() == "POST" or incognita(metodo)` só está certo pela precedência da expressão condicional; sem parênteses, quem ler pode entender `(… else …) or incognita(metodo)`.
- Review round=1 · P3 (Standards): na lista "O que a guarda NÃO pega", o item antigo termina em ponto e o novo vem depois, quebrando a série em `;`; e o reflow do parágrafo da guarda no manual `anvil-omp` deixou uma linha curta no meio — só forma.
- Review round=1 · P3 (Spec): o filtro rápido não vê `"gh" api -X POST repos/o/r/pulls` (nem `"gh" pr create`, que já passava), porque `[^"]{0,4}` não atravessa a aspa, e a lista "O que a guarda NÃO pega" só dá exemplos do `git` — quem ler pode supor que o `gh` entre aspas é conferido.
- Review round=1 · P3 (Spec): o perfil do tracker e o `ARCHIVE.md` dizem que o hook bloqueia "o `git merge` e a criação do PR", mas a guarda também confere `gh pr merge` e `tea pr merge` — o texto não mente, descreve menos do que a guarda confere.
