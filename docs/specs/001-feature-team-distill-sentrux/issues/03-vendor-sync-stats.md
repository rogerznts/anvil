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
