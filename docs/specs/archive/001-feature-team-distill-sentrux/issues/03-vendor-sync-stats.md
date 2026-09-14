# 03: A métrica do README pode ser refeita com um comando

**What to build:** O mantenedor roda `vendor-sync stats` e obtém o número de skills vendorizadas, de linhas do payload e de linhas nossas que diferem do upstream, com a definição escrita no próprio script. O README passa a mostrar o comando e a data da medição ao lado dos números.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] *Linha nossa* é a linha presente no payload e ausente da versão do pin, contada só em arquivos que existem dos dois lados; `keep` e `extra` contam à parte, e `strip` não conta. A definição está escrita no script.
- [x] Duas execuções seguidas dão o mesmo resultado.
- [x] Uma skill cujo único delta é o `rename` mede exatamente uma linha nossa.
- [x] O README troca os números antigos pelos medidos, com o comando e a data.
- [x] A lista do catálogo de adaptações no README inclui `invocable` e `tracker-profile`, na mesma ordem do `ADAPT-RULES.md`.
- [x] O diagrama do fluxo no README mostra o boot chamando o `anvil-docs` sem verbo, que escolhe entre `scaffold` e `adopt` (ticket 14).
- [x] Ponto A: as três verificações acima rodam contra o payload real.

## Comments

**Leader, 2026-09-13 — entrega do Dev** em `e89099d` (verbo `stats` com a definição no `cmd_stats`), `b778ca5`
(README: números medidos com comando e data, `tracker-profile` no catálogo, boot chamando o `anvil-docs` sem verbo) e
`3c7c56d` (pin ausente dá ERRO e exit 1; um balde por arquivo). Ponto A contra o payload real: duas execuções em
`/bin/bash` 3.2 e uma em bash 5.2 idênticas por `cmp`; `anvil-research` com rename puro mede 1, e a linha é o
`name:`; somar uma linha e apagar outra dá 2; pin inexistente dá ERRO e exit 1; `verify` limpo em 3.2 e 5.
Números: 36 entradas vendored (34 com árvore upstream) · 186 pareados, 21.887 linhas · 202 nossas (0,92%) ·
17 skills com uma linha · keep 34 arquivos, 7.720 linhas · extra 45 arquivos, 5.771 linhas, 4 nossas · strip 59 ·
sem par 1. Antes: 35 / 25.064 / 171 (0,68%) / 21.

Desvios aceitos: o README publica as linhas dos pareados (o denominador da definição) e keep e extra à parte, sem
total geral; "skills com uma linha" é contagem, e a frase de que a linha é o `name:` foi conferida à mão; o `stats`
lê o working tree, como o `verify`. A medição ad hoc (34 / 21.954 / 241 / 16) não tem método escrito e não se
reconcilia.

Ajuste antes dos gates: `anvil-to-spec/scripts/new-spec.sh` é arquivo do anvil dentro de skill vendorizada e não
está no `keep` — o `stats` o mostra sem par, e o `update` não tem ordem de preservá-lo; entra `keep`. O bloco
"Comandos" da `anvil-sync/SKILL.md` passa a listar `lock` e `stats`.

**Leader, 2026-09-13 — ajuste pré-gate** em `9c2f44e` (`keep: [scripts/new-spec.sh]` no `anvil-to-spec`; README
remedido: keep 35 arquivos · 7.866 linhas, sem par 0; demais totais iguais) e `df59c26` (`lock` e `stats` no bloco
"Comandos" da `anvil-sync`). `verify` limpo em 3.2 e 5; `status` e `update anvil-to-spec` em dia. Ressalva do Dev: com
o HEAD do submodule igual ao pin, o `update` não percorre arquivos, então o caminho do `keep` num merge real não foi
exercitado; o efeito prático do `keep` é o `vendor` e a classificação no `stats`. Gates despachados: Review e Tester.

**Leader, 2026-09-13 — gate Review, rodada 1: APROVADO, sem bloqueante.** Critérios atendidos sobre `df59c26`; todos
os números da tabela do README conferidos contra o `stats` em `/bin/bash`; determinismo por `cmp` em 3.2 e 5.2; o
`keep` do `new-spec.sh` é adaptação legítima (o arquivo nasceu no anvil, e o pin só tem `SKILL.md` e
`agents/openai.yaml`); usage `3,8p` → `3,10p` corrige omissão antiga do `lock`. Achados: **F1** o laço do payload no
`cmd_stats` não consulta `strip` — arquivo em `strip` presente no payload e no pin contaria como pareado e inflaria as
linhas (0 casos hoje; o `verify` não barra cópia à mão); **F2** README diz "35 skills de cinco repositórios" e a
tabela diz 36 (ambos certos, leitura confusa); **F3** "dezessete skills com uma linha de delta" inclui
`anvil-stack-payload`, que tem 29 arquivos `keep` — a linha única vale só para os pareados. Standards: **S1**
identificadores em pt-BR (`nossas`, `sem_par`…) seguem o estilo existente do script (`gerar_lock`, `falhas`); **S2**
contadores de uma a três letras; **S3** leitura de `extra` repete `copy_extras`; **S4** `arr` não é local; **S5**
binário alterado mede 0 sem aviso; **S6** vírgula em nome de arquivo quebra as listas. Lacuna da spec: o
`docs/architecture/overview.md` repete a métrica velha (171 em 25.064, 0,68%, vinte e uma; linha 104) e nenhum
ticket a cobre — a spec diz "README e overview … a métrica ganha comando e data".

**Leader, 2026-09-13 — rodada de ajuste** em `bd67288` (F1: no laço do payload, arquivo do pin listado em `strip`
não entra em pareado; um `strip` ausente do pin segue em "sem par", sem sumir), `5a27347` (F2 e F3 no README: 36
entradas = as 35 curadas e o `anvil-bench`; a linha única vale para os pareados, e o `anvil-stack-payload` carrega 29
`keep`) e `93839e3` (métrica do `overview.md` com números, comando e data). Prova do F1 numa cópia: o script antigo
contava o `strip` plantado em dois baldes (203 nossas); o novo sai idêntico por `cmp` à cópia sem plantio. `stats` do
payload real idêntico ao publicado em 3.2 e 5.2; `verify` limpo. Conferido pelo Leader. Desvio aceito: F2 resolvido
na linha da tabela, onde o 36 aparece, e não na introdução. Aguarda o gate do Tester.

**Leader, 2026-09-13 — gate Tester, rodada 1: REPROVADO.** Numa cópia em `93839e3`. Passaram: determinismo (3.2 ×2,
5.2, 5.2 com `LC_ALL=pt_BR.UTF-8`, `cmp` idêntico); rename puro mede 1 no `anvil-handoff`, e nas 17 skills com uma
linha o único delta pareado é o `name:`, conferido por script; linha somada, apagada, alterada, arquivo novo sem e
com `keep`, `keep` de diretório, `strip` (inclusive o F1 do Review corrigido), pin inexistente, blob ou vazio,
submodule desinicializado, `.DS_Store`, nome com espaço e `extra`; todos os números do README e do `overview.md`
reproduzidos; `verify`, `status` e `lock` sem regressão. **Falha F1 (média):** arquivo só do payload com `[`, `*` ou
`?` no nome conta como pareado e soma todas as linhas como nossas, sem aparecer em "sem par" — `git show
"$pin:$path/$f"` trata o argumento como pathspec e sai 0 com saída vazia (linhas 675 e 688 do `cmd_stats`). Repro:
`[slug].md` de 5 linhas no `anvil-handoff` → 202 para 207 nossas. Caso real: tirar `bench` do `keep` do
`anvil-stack-payload` → os três arquivos `[[...segments]]`/`[...slug]` entram como pareados, 202 para 266. O número
publicado não muda (esses arquivos estão em `keep`). Correção provável: `git cat-file blob`/`-e` onde o código de
saída decide. Observações que ficam como ideia: symlink dentro de skill ignorado em silêncio; a frase curta do README
("não está na versão do pin") é menos precisa que o "lado > do diff" do script. Inconclusivo e anterior ao 03:
`verify` em `/bin/bash` 3.2 morre com SIGTRAP na checagem 3 na cópia do Tester (também com o script de `e89099d^`;
no repo real passa).

Correção vai ao Dev como parte da mesma rodada de ajuste (o gate do Tester não tinha voltado quando ela abriu).

**Leader, 2026-09-13 — correção do F1 do Tester** em `c388679`: onde o código de saída decide a existência no pin
(`cmd_stats` no `extra` e no payload, e `copy_extras`), `git show` vira `git cat-file blob`, que sai 128 com nome de
glob inexistente. Os fallbacks `|| : > base` do `update` ficam: com glob inexistente o `show` já dava a mesma base
vazia. Na cópia `workspace/19-stats-glob/`: `[slug].md` e `a*b?.md` passam a SEM-PAR 1 com totais iguais; `bench` fora
do `keep` dá sem par 27, com os três arquivos de glob; `copy_extras` com origem de glob inexistente conta 0 (antes 2).
`stats` do payload real idêntico ao publicado em 3.2 e 5.2; `verify` limpo. Reteste do Tester despachado.

**Leader, 2026-09-13 — resolvido.** Gate Tester, rodada 2: APROVADO, numa cópia nova em `df88bbd`. F1 corrigido:
`[slug].md` e `a*b?.md` vão para sem par com totais iguais; `bench` fora do `keep` põe os três arquivos de glob em sem
par (27). Regressão: os 26 casos da rodada 1 idênticos por `cmp`, exceto os três de glob. `copy_extras` pelos fluxos
reais do `anvil-ui-hallmark`: `vendor` com os três extras reais igual ao blob do pin; origens de glob inexistentes
deixam de contar (5 → 3); origem de glob existente continua copiada e pareada; `update` com destino ausente copia e
com destino presente mescla. `stats` idêntico ao publicado em 3.2 e 5.2, também depois de o HEAD andar para
`a085581`; `verify` limpo. Com o gate do Review, os gates passaram sobre `c388679`.

Ficam como ideia: origem de `extra` inexistente ainda deixa o destino como arquivo vazio (o redirect cria antes do
`cat-file`; anterior ao 03, o `stats` o põe em sem par); symlink dentro de skill ignorado em silêncio; a frase curta do
README é menos precisa que o "lado > do diff"; comentários do `c388679` sem acento, diferente do resto do script.
Riscos: SIGTRAP do `verify` em `/bin/bash` 3.2 na cópia do Tester (anterior ao 03); medir no repo real enquanto outro
papel edita o `vendor-sync.sh` pode abortar a execução.
