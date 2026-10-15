# 09: A entrevista do bench gera o roteiro, e cada spec tem o seu `gates.md`

**Blocked by:** 01, 08

**Status:** ready-for-agent

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

- [ ] A fase 3 lê os documentos existentes antes de perguntar e copia, ou extrai,
      o anexo para `docs/discovery/`.
- [ ] A entrevista produz um `roadmap.md` que o `roadmap.sh` aceita, com `Cobre:`
      em cada entrada, e cada item do checklist é coberto por exatamente uma
      entrada.
- [ ] A pessoa vê o roteiro em português simples (o que, em que ordem, como vai
      saber que está pronto) e confirma sobre ele. O `roadmap.md` não aparece no
      chat.
- [ ] O `briefing.md` e o `checklist.yaml` ficam nos caminhos novos, e nenhum
      dos dois é gravado dentro de uma spec.
- [ ] O `gates.md` de cada spec só tem os itens de `Cobre:` da entrada dela, e o
      `gate-lint` roda sobre ele antes da construção.
- [ ] O bench chamado direto constrói só a primeira entrada do frontier e para no
      fim da construção, com a entrega listando o archive e o merge como passos do
      operador.
- [ ] O `CHECKLIST.md` muda só se o formato da cobertura pedir. O `unlazy/` não
      muda.
- [ ] Verificação no ponta a ponta manual da spec, com a stack plugada.
- [ ] `vendor-sync.sh verify` sai `0`.
