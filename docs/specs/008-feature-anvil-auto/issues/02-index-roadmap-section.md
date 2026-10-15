# 02: O `docs/index.md` mostra o roteiro com o estado de cada entrada

**Blocked by:** 01

**Status:** resolved

**What to build:** quando `docs/specs/roadmap.md` existe, o verbo `index` do
`anvil-docs` gera uma seção **Roteiro** acima de "Specs ativas". A seção tem uma
linha por entrada, na ordem do arquivo, com o estado vindo do `roadmap.sh` e
mostrado em português (pendente, em andamento, fechada, parada com o motivo), o
link da spec quando a entrada tem `Spec:`, e o link para `docs/specs/report.md`
quando ele existe. O operador vê em que pé o plano está sem abrir branch nenhum.

- [x] Sem `roadmap.md`, o índice sai sem a seção, idêntico ao de hoje a menos do
      timestamp.
- [x] Com roteiro, a seção aparece acima de "Specs ativas", com uma linha por
      entrada, na ordem do arquivo e com o estado em português.
- [x] Uma entrada com `Spec:` linka a pasta da spec, ativa ou arquivada. Uma
      entrada `stopped` mostra o `reason` do script.
- [x] O link para `report.md` aparece só quando o arquivo existe.
- [x] Uma recusa do `roadmap.sh` aparece como aviso dentro da seção, e o resto do
      índice é gerado normalmente.
- [x] O verbo continua idempotente a menos do timestamp, e o bloco custom
      continua preservado.
- [x] O template do índice e o `INDEX.md` do `anvil-docs` descrevem a seção.
- [x] Prova: gerar o índice num projeto de fixture com o roteiro do S1 que tem
      entradas `pending`, `closed` e `stopped` e conferir a seção.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Prova em `workspace/44-index-roadmap/s.sh`: o verbo `index` roda numa sessão
  headless do omp (`omp -p`, modelo `sonnet`) sobre três projetos de fixture em
  `/tmp`. Casos: sem roteiro, comparado à base que a prosa de antes gerou
  (`--base`); roteiro com entradas `pending`, `open`, `closed` e `stopped` (uma por
  spec só no branch, outra por `Spec:` sem pasta nem branch), com `report.md` e
  bloco custom, gerado duas vezes; e roteiro recusado por ciclo. Todos os casos
  passam. A base com a prosa de antes saiu igual em duas gerações no `sonnet`. No
  `haiku`, a prosa de antes já variava sozinha, inventando domínios ausentes e
  errando caminhos relativos, e por isso a prova usa o `sonnet`.
- Leitura do critério "linka a pasta da spec, ativa ou arquivada": o link sai
  quando a pasta existe no checkout em que o índice é gerado. Uma spec aberta que
  só existe no branch dela, o caso comum na `main` do piloto, sai como `spec NNN`,
  sem link, pela regra do `INDEX.md` de que índice que aponta para pasta ausente
  é pior que índice incompleto.
