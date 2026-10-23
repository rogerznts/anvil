# 05: O relatório traz o `decisions-log.md` da spec fechada

**Blocked by:** 02

**Status:** resolved
**Review:** round=1; sha=f40a15c; scope=full; verdict=pass; p1=none

**What to build:** no relatório do piloto, a seção de cada spec do bench traz o
`decisions-log.md` dela lido do branch pelo caminho que ele tem lá: depois do
archive quando a spec fechou, antes do archive quando ela parou. Hoje, numa spec
fechada, o `git show` falha e o relatório diz "nenhum".

- [x] O `anvil-auto` lê o `decisions-log.md` da spec fechada em
      `docs/specs/archive/<pasta>/` e o da spec parada em `docs/specs/<pasta>/`.
- [x] Prova S2 pelo helper, num diretório novo de `workspace/`, sobre a fixture do
      caso F de `workspace/56-manual-gate-rule/`, com `/skill:anvil-auto` no
      primeiro turno: o vermelho, com o texto de antes, diz "nenhum" na seção da
      spec fechada; o verde traz o conteúdo do arquivo. O código do helper sai nas
      saídas, e prova inválida se repete.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · a regra do "Relatório" do `anvil-auto` diz o caminho pelo archive
  commitado no branch, e não pelo "fechou/parou": a spec que para no fechamento
  depois do archive — o merge bloqueado pela guarda, o merge abortado pela
  conferência, que o `anvil-auto` já chama de "parada, já arquivada no branch", ou o
  PR aberto — tem a pasta em `docs/specs/archive/`. A frase da spec, "em
  `docs/specs/<pasta>/` quando parou", só vale para a parada antes do archive; ela
  fica como está, à espera do operador.
- Implementação · prova em `workspace/63-decisions-log-archive/s2.sh`: a fixture do
  caso F, num repositório dentro do diretório da execução, com um projeto do compose
  próprio que sai no fim; `TEXTO=<rev>` extrai, por `git archive`, o payload e o
  helper dessa revisão, e a sessão carrega as skills dali; `PENSAMENTO=<nível>` vai
  como sufixo do `--model` da sessão (`claude-sonnet-4-5:off`), porque o helper não
  tem opção de pensamento, e o `proof_verdict` pede o modelo sem o sufixo. O
  vermelho usa `TEXTO=0e2f1c7`, o `HEAD` antes desta mudança. Todas as saídas
  trazem o código do helper, e nenhuma deu `3`.
- Implementação · com pensamento `off`, como as sessões do `omp -p --thinking off` da
  56: o vermelho deu "nenhuma" e "nenhum" (`s2-red-off.out`, `s2-red-off-2.out`,
  código `1`, só a conferência do `decisions-log.md` caída); o verde trouxe o
  conteúdo (`s2-off.out`, código `0`). Dois outros verdes `off` (`s2-off-2.out`,
  `s2-off-3.out`) não mediram o relatório: recusaram na largada pela falta do comando
  de verificação, sem reconhecer o bench — o `verification.sh check` rodou junto do
  grep da rule do bench —, o que esta mudança não toca.
- Implementação · com o pensamento padrão do omp, `high`, o vermelho não reproduz:
  nas quatro sessões com o texto de antes (`s2-red-1.out` a `s2-red-4.out`, código
  `0`), o relatório trouxe o conteúdo — numa, o `git show` pelo caminho de antes do
  archive falhou e o modelo tentou o do archive; nas outras três, ele foi direto ao
  caminho do archive. O verde deu `0` nas duas (`s2.out`, `s2-2.out`). O defeito do
  texto só aparece no relatório com o raciocínio desligado.
- Observação · o `GATE.md` do bench copia o checker de
  `~/.claude/skills/anvil-bench/unlazy/scripts/.`, e o helper não liga o
  `anvil-bench` ali: em toda sessão desta prova o primeiro `docker compose cp` falhou
  e o modelo procurou o checker por conta própria — no payload sob prova, pelo
  `skill://` (`out/`, `out-red-1/`), mas também em
  `/Users/admin/Projects/open-maestri/.claude/skills/anvil-bench/` (`out-off/`) e num
  temporário alheio (`out-red-off/`). O checker que roda não é sempre o do payload
  sob prova; o B1 do ticket 09 depende dele.
- Review round=1 · P2 (Standards): o critério 1, marcado `[x]`, diz "o da spec parada em `docs/specs/<pasta>/`", e a skill lê do archive a spec parada depois do archive; a divergência com a spec (`spec.md:239-241`, história 25) está só neste `## Comments` — arquivada assim, a spec dá o caminho errado da parada no fechamento a quem a ler.
- Review round=1 · P2 (Standards): o vermelho só aparece com pensamento `off`, e só um dos três verdes `off` mediu o relatório — a prova mostra que o texto novo basta, mas não que a mudança é necessária no pensamento padrão do omp.
- Review round=1 · P3 (Standards): "parada no fechamento depois do archive" (`anvil-auto/SKILL.md:856-861`) é um terceiro nome para o caso que a "Parada" chama "não fecha no fechamento" e o "Conferir o merge" chama "parada, já arquivada no branch" (Mysterious Name) — o leitor casa três nomes para um caso só.
- Review round=1 · P2 (Spec): nos dois vermelhos `off` a sessão não tentou ler o `decisions-log.md`, nem por `git show` nem por `read`, e escreveu "nenhum(a)" direto; o verde `off` leu pelo `read` da árvore, e não pelo `git show <branch>:` — o vermelho não reproduz o mecanismo do defeito, o `git show` que falha, que só aparece em `s2-red-1`, que se recuperou, e a diferença entre vermelho e verde pode vir de o modelo pular o passo, com n=2 contra n=1.
- Review round=1 · P2 (Spec): a regra nova lê do archive a spec que para no fechamento depois do archive, contra a letra da spec ("em `docs/specs/<pasta>/` quando parou", linhas 239-241, e a história 25) e do critério 1 — quem escrever um teste ou uma regra pela spec espera `docs/specs/<pasta>/` numa parada depois do archive e acha o arquivo ausente; o critério podia ganhar a ressalva "antes do archive", por decisão do operador.
- Review round=1 · P3 (Spec): "o `verification.sh check` rodou junto do grep da rule do bench" só vale para `out-off-3`; em `out-off-2` a sessão nem rodou o grep da rule do bench — a explicação da recusa fica imprecisa para metade dos casos que ela cobre.
