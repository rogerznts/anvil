# 09: A entrevista do bench gera o roteiro, e cada spec tem o seu `gates.md`

**Blocked by:** 01, 08

**Status:** resolved

**What to build:** a entrevista do bench cobre a ferramenta inteira e gera um
roteiro com N entradas, no formato de `docs/specs/roadmap.md`. Cada entrada diz
em `Cobre:` quais itens do checklist cobre. Antes de perguntar, a entrevista lê o
que o projeto já tem, e o anexo da pessoa vai para `docs/discovery/`. O combinado
sai das pastas de spec: o `briefing.md` vai para `docs/discovery/briefing.md` e o
`checklist.yaml` para `docs/qa/checklist.yaml`, ambos congelados uma vez. A
pessoa confirma sobre uma versão do roteiro em português simples, e o
`roadmap.md` técnico fica gravado ao lado, fora da conversa (INV-6: quem pediu
não vê jargão, log nem comando). O `gates.md`, os testes derivados e o
`gate-lint` passam a ser feitos por spec, no começo de cada uma, só com os itens
de `Cobre:`. Chamado direto, no Claude Code ou no omp sem o piloto, o bench
constrói a primeira entrada do frontier e para no fim da construção, sem
recusar. A entrega diz que o fechamento ficou com o operador e lista o archive e
o merge.

- [x] A fase 3 lê os documentos existentes antes de perguntar e copia, ou extrai,
      o anexo para `docs/discovery/`.
- [x] A entrevista produz um `roadmap.md` que o `roadmap.sh` aceita, com `Cobre:`
      em cada entrada, e cada item do checklist é coberto por exatamente uma
      entrada.
- [x] A pessoa vê o roteiro em português simples (o que, em que ordem, como vai
      saber que está pronto) e confirma sobre ele. O `roadmap.md` não aparece no
      chat.
- [x] O `briefing.md` e o `checklist.yaml` ficam nos caminhos novos, e nenhum
      dos dois é gravado dentro de uma spec.
- [x] O `gates.md` de cada spec só tem os itens de `Cobre:` da entrada dela, e o
      `gate-lint` roda sobre ele antes da construção.
- [x] O bench chamado direto constrói só a primeira entrada do frontier e para no
      fim da construção, com a entrega listando o archive e o merge como passos do
      operador.
- [x] O `CHECKLIST.md` muda só se o formato da cobertura pedir. O `unlazy/` não
      muda.
- [x] Verificação no ponta a ponta manual da spec, com a stack plugada.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · desvio da spec para o operador decidir: a spec (seção
  "Formato do roteiro") diz que só o piloto escreve o `Spec:`. O bench chamado
  direto também o escreve, com os mesmos passos do piloto (`new-spec.sh`, volta à
  `main`, commit do roteiro, `git checkout -B`). Sem isso, a entrada construída
  ficaria `pending` no `roadmap.sh`, e a próxima ativação, ou o piloto, abriria
  outra spec para ela. O perfil do tracker, nas duas cópias
  (`docs/agents/issue-tracker.md` e o template do `anvil-docs`), passou a dizer
  que o roteiro é escrito pelo piloto ou pelo bench, e o `Spec:` por quem abre a
  spec da entrada.
- Implementação · o `CHECKLIST.md` mudou em três pontos, todos pedidos pela
  cobertura por spec: o caminho do arquivo (`docs/qa/checklist.yaml`), a regra
  de que o `gates.md` de uma spec leva só os itens do `Cobre:` dela, e o
  parágrafo *Evoluir*, que dizia que o ledger de cada volta carregava todos os
  itens.
- Implementação · além do `next`, o bench chamado direto retoma uma entrada
  `open` do roteiro (construção que parou no meio), do ponto que o disco indica.
  E o projeto novo nasce com `git init -b main` e o starter no primeiro commit,
  porque o roteiro e o `Spec:` são commitados na `main`.
- Implementação · o `--reverify` acumulado, sobre o ledger da spec e o de cada
  spec já fechada, é do ticket 10. Até lá, o gate do bench reexecuta só o ledger
  da spec. A regressão dos itens antigos fica com a suíte inteira, como manda
  *Evoluir*, e o `GATE.md` continua falando em "testes de módulo acumulados" no
  `PASS`.
- Ponta a ponta em `workspace/50-bench-roadmap/e2e.sh` (fora do git): o bench
  chamado direto no Claude Code (`claude -p`, sonnet), com a stack Payload
  plugada, num projeto novo em `/tmp` com uma nota em `docs/discovery/` e uma
  planilha anexa de fora. Passaram as 22 conferências (`e2e.out`, e
  `e2e-checar.out` depois de corrigir um falso positivo da conferência das
  perguntas). Resultado: roteiro de duas entradas mostrado em português simples
  no turno 2, sim no turno 3; briefing, checklist, roteiro e anexo na `main`;
  spec 001 com `gates.md` só com C1–C4, `gate-lint` antes do `anvil-to-spec`;
  dois tickets `resolved` com `verdict=pass`; sem archive nem merge; a entrega
  lista o archive e o merge para o operador. A rodada vermelha, com o `SKILL.md`
  de antes do ticket (`out-red/`, `e2e-red.out`), falha: não há roteiro, e o
  briefing e o checklist ficam dentro da spec.
- Observação · no ponta a ponta, o bench marcou à mão o gate manual C4 (os três
  equipamentos da planilha), depois de conferir pela lista. Segurar o fechamento
  num gate manual é do ticket 10.
