# 02: O `docs/index.md` mostra o roteiro com o estado de cada entrada

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** quando `docs/specs/roadmap.md` existe, o verbo `index` do
`anvil-docs` gera uma seção **Roteiro** acima de "Specs ativas". A seção tem uma
linha por entrada, na ordem do arquivo, com o estado vindo do `roadmap.sh` e
mostrado em português (pendente, em andamento, fechada, parada com o motivo), o
link da spec quando a entrada tem `Spec:`, e o link para `docs/specs/report.md`
quando ele existe. O operador vê em que pé o plano está sem abrir branch nenhum.

- [ ] Sem `roadmap.md`, o índice sai sem a seção, idêntico ao de hoje a menos do
      timestamp.
- [ ] Com roteiro, a seção aparece acima de "Specs ativas", com uma linha por
      entrada, na ordem do arquivo e com o estado em português.
- [ ] Uma entrada com `Spec:` linka a pasta da spec, ativa ou arquivada. Uma
      entrada `stopped` mostra o `reason` do script.
- [ ] O link para `report.md` aparece só quando o arquivo existe.
- [ ] Uma recusa do `roadmap.sh` aparece como aviso dentro da seção, e o resto do
      índice é gerado normalmente.
- [ ] O verbo continua idempotente a menos do timestamp, e o bloco custom
      continua preservado.
- [ ] O template do índice e o `INDEX.md` do `anvil-docs` descrevem a seção.
- [ ] Prova: gerar o índice num projeto de fixture com o roteiro do S1 que tem
      entradas `pending`, `closed` e `stopped` e conferir a seção.
- [ ] `vendor-sync.sh verify` sai `0`.
