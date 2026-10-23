# 05: O relatório traz o `decisions-log.md` da spec fechada

**Blocked by:** 02

**Status:** ready-for-agent

**What to build:** no relatório do piloto, a seção de cada spec do bench traz o
`decisions-log.md` dela lido do branch pelo caminho que ele tem lá: depois do
archive quando a spec fechou, antes do archive quando ela parou. Hoje, numa spec
fechada, o `git show` falha e o relatório diz "nenhum".

- [ ] O `anvil-auto` lê o `decisions-log.md` da spec fechada em
      `docs/specs/archive/<pasta>/` e o da spec parada em `docs/specs/<pasta>/`.
- [ ] Prova S2 pelo helper, num diretório novo de `workspace/`, sobre a fixture do
      caso F de `workspace/56-manual-gate-rule/`, com `/skill:anvil-auto` no
      primeiro turno: o vermelho, com o texto de antes, diz "nenhum" na seção da
      spec fechada; o verde traz o conteúdo do arquivo. O código do helper sai nas
      saídas, e prova inválida se repete.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
