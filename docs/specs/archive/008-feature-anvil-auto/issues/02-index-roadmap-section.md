# 02: O `docs/index.md` mostra o roteiro com o estado de cada entrada

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=7f84dd9; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Spec): o critério "linka a pasta da spec, ativa ou arquivada" e a spec ("o link da spec quando há `Spec:`") ficam cumpridos só com a pasta no checkout, e a leitura vive só neste `## Comments` — na `main` do piloto, que tem o `Spec:` antes da pasta, toda entrada em andamento ou parada sai sem link, e quem lê só a spec espera o link.
- Review round=1 · P3 (Spec): a prova não exercita recusa com `report.md` presente nem roteiro sem recusa e sem `report.md` — uma regressão na regra "a linha do relatório segue a mesma regra" passaria despercebida.
- Review round=1 · P3 (Spec): o `INDEX.md` trata só a saída `2` com `refusal:` e não diz o que fazer com outra saída do script (`1`, erro do bash, script ausente) — o modelo pode abortar o índice inteiro, contra "sem quebrar a geração".
- Review round=1 · P3 (Spec): fora de um repositório git o script recusa com `fora de um repositório git`, e o aviso da prosa diz "o roadmap.sh recusou o roteiro: …" — o texto culpa o roteiro por um problema do ambiente.
- Review round=1 · P3 (Spec): o comentário do template diz "sem ele, a seção sai inteira" no sentido de "é removida", e o `INDEX.md` usa "sai" no sentido de "é emitida" — um modelo que leia só o template pode emitir o título `## Roteiro` sem roteiro.
- Review round=1 · P3 (Spec): o `s.sh` usava `haiku` como padrão, contra o comentário de que a prova usa `sonnet` — quem rodasse de novo com os padrões veria falha falsa. Corrigido no `workspace/`, fora do git: o padrão agora é `sonnet`.
- Review round=1 · P3 (Standards): o comentário do template repete em seis linhas quase toda a regra do passo 3 do `INDEX.md` (possível Duplicated Code/Shotgun Surgery) — quem mudar o formato edita os dois, e se um ficar para trás o gerador recebe instruções diferentes.
- Review round=1 · P3 (Standards): o `reason=` "copiado como está" entra cru no Markdown — um motivo com `_` ou `*` em par sai com a formatação quebrada; entre crases resolveria.
- Review round=1 · P3 (Standards): a frase "o índice fica como sem este passo" no `INDEX.md` é truncada — custa uma releitura, sem mudar o comportamento.
- Review round=1 · P3 (Standards): no primeiro comentário deste ticket, o parêntese "(uma por spec só no branch, outra por `Spec:` sem pasta nem branch)" descreve só as duas `stopped` — quem auditar a prova pode achar que há um caso `open` só no branch, e não há: o `open` da prova é a spec no checkout.
