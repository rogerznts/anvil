# 03: A métrica do README pode ser refeita com um comando

**What to build:** O mantenedor roda `vendor-sync stats` e obtém o número de skills vendorizadas, de linhas do payload e de linhas nossas que diferem do upstream, com a definição escrita no próprio script. O README passa a mostrar o comando e a data da medição ao lado dos números.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] *Linha nossa* é a linha presente no payload e ausente da versão do pin, contada só em arquivos que existem dos dois lados; `keep` e `extra` contam à parte, e `strip` não conta. A definição está escrita no script.
- [ ] Duas execuções seguidas dão o mesmo resultado.
- [ ] Uma skill cujo único delta é o `rename` mede exatamente uma linha nossa.
- [ ] O README troca os números antigos pelos medidos, com o comando e a data.
- [ ] A lista do catálogo de adaptações no README inclui `invocable` e `tracker-profile`, na mesma ordem do `ADAPT-RULES.md`.
- [ ] O diagrama do fluxo no README mostra o boot chamando o `anvil-docs` sem verbo, que escolhe entre `scaffold` e `adopt` (ticket 14).
- [ ] Ponto A: as três verificações acima rodam contra o payload real.

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
