# 09: A entrevista do bench gera o roteiro, e cada spec tem o seu `gates.md`

**Blocked by:** 01, 08

**Status:** resolved
**Review:** round=1; sha=d253641c010e97337d7c4c5af3a7ac467743818a; scope=full; verdict=pass; p1=none

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
- Review round=1 · P2 (Standards): o `SKILL.md` do bench aponta para
  `docs/agents/issue-tracker.md` do projeto (formato do roteiro, l.158-159, e
  regra de fechamento, l.321), mas o starter não traz esse arquivo e nenhum passo
  do bench o cria; o ponta a ponta o semeou na fixture — quem seguir o ponteiro
  num projeto novo não acha o perfil, e o `anvil-to-spec` e o `anvil-to-tickets`
  rodam sem ele.
- Review round=1 · P2 (Standards): a retomada de construção começada fora do
  bench commita o `docs/qa/checklist.yaml` no branch da spec, e esse arquivo é o
  sinal do ramo *Ferramenta que o bench construiu*; reativado no meio dessa
  retomada, sem roteiro, o bench cai em *Evoluir*, o `roadmap.sh` dá
  `next: none` e os tickets abertos ficam sem construção.
- Review round=1 · P2 (Spec): o passo 1 de "Uma entrada do roteiro" manda não
  construir nada com `next: none`, e a retomada sem roteiro (`roadmap: none`, que
  sai com `next: none`) segue pelos tickets não `resolved`; o passo 1 não abre a
  exceção — quem o seguir ao pé da letra para a retomada.
- Review round=1 · P3 (Spec): a spec (seção "Formato do roteiro", "Só o piloto o
  escreve") continua contradizendo as duas cópias do perfil do tracker sobre
  quem escreve o `Spec:` — quem ler só a spec acha o perfil errado, até o
  operador decidir o desvio registrado acima.
- Review round=1 · P3 (Spec): o bloco "para quem opera o anvil" da entrega lista
  `/anvil-docs archive` e o merge no chat, ao lado do "Nunca" que proíbe mostrar
  comando a quem pediu (INV-6, quem pediu não vê jargão, log nem comando); a
  spec pede a lista, e o bloco à parte não foi declarado como exceção — o "Nunca"
  e a entrega se desmentem para quem lê.
- Review round=1 · P3 (Spec): o `anvil-docs/SKILL.md` (l.94) ainda atribui `qa/`
  só ao `anvil-browser-qa`, e o bench agora grava `docs/qa/checklist.yaml` — a
  tabela de quem escreve cada pasta fica imprecisa.
- Review round=1 · P3 (Spec): o `GATE.md` escreve `docs/specs/<id>/gates.md` e o
  `SKILL.md` escreve `docs/specs/<pasta>/gates.md` para o mesmo caminho — o
  leitor estranha os dois marcadores.
- Review round=1 · P3 (Standards): possível Duplicated Code / Shotgun Surgery —
  o passo 2 de "Uma entrada do roteiro" repete o "Abrir a spec" do `anvil-auto`
  (`new-spec.sh`, volta à `main`, `Spec:`, commit, `git checkout -B`); uma
  mudança de protocolo editada só de um lado faz o bench e o piloto gravarem o
  `Spec:` de jeitos diferentes.
- Review round=1 · P3 (Standards): possível Duplicated Code — a regra "cada item
  no `Cobre:` de exatamente uma entrada" está no `CHECKLIST.md`, no `SKILL.md` e
  no `diff` de cobertura, e o exemplo de roteiro repete o do perfil; as cópias
  podem divergir na próxima edição.
