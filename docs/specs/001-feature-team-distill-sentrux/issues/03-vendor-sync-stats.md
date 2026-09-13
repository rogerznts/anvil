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
