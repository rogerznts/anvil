# 03: O piloto não despacha de novo o ticket que pulou

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=e8dc7c0a443dd9bdd81bc4c40c566d58ae852444; scope=full; verdict=pass; p1=none

**What to build:** quando um implementer termina sem mudar o estado do ticket, o
piloto o anota como pulado e roda o `frontier.sh` mais uma vez, já com o
`--skip`, antes de voltar ao começo do despacho, como o passo 5 da `anvil-run`
faz. O `next` que ele segue nunca aponta um ticket já pulado.

- [x] No "Despacho" do `anvil-auto`, com pulado novo, o piloto roda o
      `frontier.sh` de novo com o `--skip` de todos os pulados e volta ao passo 1
      com essa saída.
- [x] Um ticket pulado não é despachado de novo na mesma execução.
- [x] O `frontier.sh` e a `anvil-run` não mudam.
- [x] Prova S2 (prior art `workspace/47-auto-chain/`), num diretório novo de
      `workspace/`: um ticket que o implementer termina sem mudar o estado é
      despachado uma vez só, e o `frontier.sh` roda com o `--skip` antes do
      despacho seguinte, visto no jsonl. O S2 registra o modelo que de fato
      respondeu.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- O passo 3 do "Despacho" do `anvil-auto` ganhou o que o passo 5 da `anvil-run` tem: com pulado novo, o piloto roda o `frontier.sh` mais uma vez, já com o `--skip` de todos os pulados, e volta ao passo 1 com essa saída, cujo `next` nunca aponta um pulado. O pulado não é despachado de novo nem quando o implementer caiu, abortou ou devolveu erro, como na `anvil-run`. O passo nomeia as duas saídas do `--skip` que já existiam, a "Contradição com o roteiro" e o "Abrir a rodada", para o "nunca de novo" não contradizê-las. O `frontier.sh` e a `anvil-run` não mudaram.
- Prova S2: `workspace/54-auto-skip/s2.sh`, uma retomada no branch da spec 001 sobre a fixture do caso R do `workspace/48-auto-stops/`, com `omp -p --mode json --model claude-sonnet-4-5 --thinking off`. Dois tickets independentes no frontier: o 01, `claimed`, sem `Review:`, com uma pergunta ao operador sem resposta no `## Comments` e a spec dizendo que nenhum implementer toma a decisão; o 02, que um implementer resolve. O `next` da fixture é o 01. O S2 lê do jsonl a sequência do laço, cada chamada do `frontier.sh` com o `--skip` do comando e o `next` do resultado, e cada chamada do `task` com os tickets citados.
  - vermelho, com o passo 3 de antes (`out-red/`, `s2-red.out`): laço `F skip=- next=01` · `D 01` · `F skip=- next=01` · `D 02` · `F skip=01 next=none`. O piloto despachou o 02 seguindo uma saída cujo `next` ainda era o 01, sem rodar o `frontier.sh` com o `--skip` antes; 2 falhas, as duas conferências do `--skip` antes do despacho seguinte. Respondeu só o `anthropic/claude-sonnet-4-5` (27 mensagens). Nessa rodada o modelo não redespachou o 01, mas improvisou o próximo fora do que a saída dizia;
  - verde, com o passo 3 novo (`out/`, `s2.out`): laço `F skip=- next=01` · `D 01` · `F skip=- next=01` · `F skip=01 next=02` · `D 02` · `F skip=01 next=none`. `S2: tudo passou`, 13 conferências: o 01 despachado uma vez só e com o estado da fixture, o `frontier.sh` com o `--skip` do 01 entre os dois despachos dando o `next` no 02, toda chamada depois disso com o 01 no `--skip`, o 02 `resolved` com `verdict=pass; p1=none`, a spec parada no branch e o 01 em "o que ainda espera decisão". Respondeu só o `anthropic/claude-sonnet-4-5` (23 mensagens), lido do jsonl da sessão principal.
- `vendor-sync.sh verify`: `verify: limpo`, rc 0.
- Review round=1 · P3 (Standards): possível Duplicated Code no passo 3 do "Despacho" — "todos os pulados" e "nesta execução" voltam duas vezes, e o fecho "com pulado novo, a do `--skip`" repete a primeira frase; o comportamento não quebra, mas o passo fica mais longo que o passo 5 da `anvil-run` e a próxima edição tem mais superfície para divergir.
- Review round=1 · P3 (Standards): possível Shotgun Surgery na frase "Só a 'Contradição com o roteiro' e o 'Abrir a rodada' o tiram do `--skip`", uma lista fechada que copia o que as duas seções já dizem — uma terceira saída do `--skip` acrescentada depois obriga a editar também o passo 3, e o "Só" passa a mentir se alguém esquecer.
- Review round=1 · P3 (Standards): o `s2.sh` usa o diretório fixo `/tmp/anvil-54-auto-skip`, como o P3 da rodada 2 do ticket 02 — duas execuções do S2 ao mesmo tempo colidem; o artefato publicado não é afetado.
- Review round=1 · P3 (Spec): o `modelos()` do S2 lê só o jsonl da sessão principal — o modelo do `anvil-implementer` que resolveu o 02 fica sem registro; o `## Comments` diz "lido do jsonl da sessão principal", e nenhuma afirmação fica falsa.
- Review round=1 · P3 (Spec): a conferência "o 01, pulado, foi despachado uma vez só" também passa no vermelho, e só as conferências do `--skip` antes do despacho seguinte separam o texto antigo do novo — o "uma vez só" tem prova de que vale, mas não de que a mudança o causou.
