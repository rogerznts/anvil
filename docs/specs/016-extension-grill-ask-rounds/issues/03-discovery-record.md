# 03: O grill grava as decisões em `discovery/` a cada bloco e as relê depois da compactação

**What to build:** Ao fim de cada bloco, o grill acrescenta as decisões num arquivo de discovery e só então mostra no chat o resumo, uma linha por decisão. O caminho é `docs/discovery/grill-<slug>.md` fora de branch de spec, e a pasta `discovery/` da spec num branch de spec. O `<slug>` é kebab-case e vem do assunto. A pasta nasce no primeiro registro. O arquivo é só de acréscimo: cada bloco é uma seção `## Bloco N`, com título, decisão e se a recomendação foi aceita, e a confirmação final vira `## Confirmação`. O grill escreve e não commita. Quando o contexto se perdeu, ele relê o arquivo antes do bloco seguinte e não repete pergunta registrada. O `README.md` de `docs/discovery/` menciona o registro do grill. Ver a spec, "Implementation Decisions › O arquivo de registro".

**Blocked by:** 02

**Status:** resolved

- [x] Num grill rodado na `main`, o fim do primeiro bloco cria `docs/discovery/grill-<slug>.md` com `## Bloco 1` e uma linha por pergunta, com título, decisão e recomendação aceita ou não. O resumo aparece no chat depois da gravação.
- [x] Num grill rodado num branch de spec, o arquivo nasce na pasta `discovery/` da spec do branch, resolvida pelo prefixo numérico.
- [x] Uma resposta escrita na opção custom chega ao arquivo como a decisão daquela pergunta.
- [x] O segundo bloco acrescenta `## Bloco 2` sem reescrever o primeiro, e o "confirmar" do último prompt acrescenta `## Confirmação` com o resumo confirmado.
- [x] Com o arquivo já contendo um bloco, uma sessão nova que retoma o mesmo grill relê o arquivo e não refaz nenhuma pergunta registrada.
- [x] O grill não commita o arquivo.
- [x] O `README.md` de `docs/discovery/` cita o registro do grill.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Evidências

Cenários reais no omp pelo `dev-run.sh`, em `workspace/91-grill-ask-rounds/` (fora do git):

- `out-rec-main/`: registro em `docs/discovery/`, três blocos e 19 decisões. Escrita antes do resumo demonstrada em `jsonl-order.txt`; preservação integral do prefixo entre versões em `prefix-cmp.txt`; confirmação acrescentada no fim. A fixture ficou apenas com o registro não rastreado, sem commit novo.
- `out-rec-spec/`: branch `feature/007-reservas`, com specs 006 e 007 disponíveis. Registro criado só em `docs/specs/007-feature-reservas/discovery/`. Uma sessão nova leu o registro antes do primeiro `ask`, não repetiu as dez decisões registradas, continuou em `## Bloco 2` e acrescentou `## Confirmação`, preservando o conteúdo anterior. Sem commit novo.
- `out-rec-custom/`: reprova após explicitar que só selecionar a opção recomendada conta como aceitação. A resposta personalizada foi preservada literalmente e marcada como não aceita; as opções recomendadas selecionadas ficaram como aceitas. Prefixos preservados, escrita antes do resumo e nenhum commit novo.

O `verify` final saiu 0. O delta contra o pin continua limitado a `rename` e à substituição do seam original das linhas 8–22.
