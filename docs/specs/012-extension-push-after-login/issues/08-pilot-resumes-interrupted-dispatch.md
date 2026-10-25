# 08: O piloto retoma o despacho interrompido

**Blocked by:** 07

**Status:** resolved

**What to build:** parte da issue #8. O piloto automático reescreve o laço da
`anvil-run` no "Despacho" em vez de carregá-la, então ganha o mesmo passo do ticket
07, com o mesmo texto: reconhecer o despacho interrompido, tentar o agente vivo,
despachar o implementer novo sem isolação, no máximo duas retomadas do despacho por
ticket e o `--resume NN` na leitura seguinte. O ticket que passa do limite segue o
caminho do pulado: o passo 1 do "Despacho" e a "Parada". Cada retomada do despacho
vai para "Decidido sem humano" no relatório.

- [x] O "Despacho" do `anvil-auto` tem o passo do ticket 07, com as exceções ao
      "não é despachado de novo nesta execução" e ao "não termine o trabalho dele"
      escritas.
- [x] Cada retomada do despacho sai em "Decidido sem humano", com o ticket e a
      tentativa.
- [x] O manual `anvil-omp` descreve a retomada do despacho, se descreve o laço do
      piloto.
- [x] Prova S2 pelo helper, com `/skill:anvil-auto` numa retomada no branch da
      spec, num diretório novo de `workspace/`, com `workspace/54-auto-skip/` como
      prior art, com o implementer falso do ticket 07: o ticket termina resolvido,
      sem `halt`, e a retomada do despacho está em "Decidido sem humano". Vermelho:
      o payload de `4271efd`, que para no `halt`.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Execução: fixed point da rodada 1 `c22c23f2481202a641d5865eab462fc8b30d4733`. Seam S2 já acordada no ticket e na spec: `/skill:anvil-auto` real pelo helper, numa retomada no branch da spec, observando os despachos, o arquivo, o ticket e o relatório. Plano: medir o vermelho em `4271efd`; portar o passo da `anvil-run` para o piloto e atualizar o manual; medir o verde; verificar e revisar em dois eixos.
- Implementação: o "Despacho" do piloto reconhece a interrupção antes da comparação de estado, preserva o `HEAD` inicial, tenta o agente ainda em execução antes de um implementer novo sem isolação e limita as duas formas a duas retomadas por ticket. O pulado segue o passo 1 e a "Parada"; com sujeira, a execução mantém o `halt`, incluindo o motivo do pulado no relatório. O manual descreve o laço, e cada tentativa é registrada em "Decidido sem humano".
- Prova S2 em `workspace/89-auto-resume/s2.sh` e `check.py`, fora do git, pelo helper e `/skill:anvil-auto` real, numa retomada de `feature/001-retomar`. Prior art: `workspace/54-auto-skip/` e o falso do ticket 07 em `workspace/88-run-resume/`, com o mesmo comportamento de interrupção e resolução sem Review. A fixture desliga a isolação em `.omp/config.yml`, registra os despachos em `.git/despachos` e observa arquivo, ticket no branch e relatório, sem conferir o texto da skill.
- Vermelho histórico: `RED=4271efd OUT=out-red-final bash workspace/89-auto-resume/s2.sh`, código `1`, modelo confirmado `anthropic/claude-sonnet-4-5` na principal e no filho, nove conferências falhando: um despacho só, ticket aberto, arquivo incompleto e parada no `halt`, sem relatório de retomada. O payload histórico foi materializado por `git archive` no overlay temporário; os caminhos absolutos dos scripts usam os links de usuário atuais, mas sem `--resume` o `frontier.sh` conserva a parada antiga pela árvore suja, observada no resultado.
- Calibração da fixture: `out-red/` e `out-green/` não contam como prova porque faltava criar `docs/specs/` antes do roteiro; a coleta foi corrigida para aceitar o ticket aberto ou arquivado no branch e o `HEAD` abreviado, formas reais do resultado, sem relaxar a contagem de despachos, a preservação do arquivo nem a leitura com `--resume`. Em `out-green-complete/`, o piloto fez os dois despachos e registrou a tentativa, mas pulou a leitura com `--resume`: código `1`, sem contar como verde. A leitura passou a ser pré-condição explícita antes da tentativa, e a conferência exige sua ordem entre os dois despachos.
- Observação fora do escopo: em `out-green-final/` e `out-green-complete/`, o piloto arquivou e mesclou a fixture apesar da ausência de Review do falso. O gate publicado de `PASS`, não alterado neste ticket, exige Review pass. Essa observação foi comunicada ao supervisor; o fechamento não é apresentado como prova do gate. O escopo desta S2 é a retomada do despacho e seu registro, não a correção do gate de fechamento.
- Verde final: `OUT=out-green-guard bash workspace/89-auto-resume/s2.sh`, código `0`, doze conferências passando e modelo confirmado `anthropic/claude-sonnet-4-5` na principal e nos dois filhos, sem fallback. Dois implementers novos, contador `2`, `--resume 01` entre os despachos, `HEAD` inicial no segundo `context`, arquivo iniciado preservado e concluído, ticket `resolved` no branch, árvore limpa, nenhuma leitura com `halt` e ticket 01 com tentativa 1/2 em "Decidido sem humano" do relatório. As saídas brutas, os comandos, os contextos e o veredito ficam em `out-green-guard/`.
- O caminho do agente vivo permanece sem prova pelo motivo da spec: o falso encerra a resposta, não permanece em execução como o implementer real. Não há typecheck nem suíte automatizada neste repositório; a verificação prescrita é `vendor-sync.sh verify`.
- Verificação antes do commit de implementação: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` saiu `0`, com `verify: limpo`.
