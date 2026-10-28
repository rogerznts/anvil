# 03: O grill grava as decisões em `discovery/` a cada bloco e as relê depois da compactação

**What to build:** Ao fim de cada bloco, o grill acrescenta as decisões num arquivo de discovery e só então mostra no chat o resumo, uma linha por decisão. O caminho é `docs/discovery/grill-<slug>.md` fora de branch de spec, e a pasta `discovery/` da spec num branch de spec. O `<slug>` é kebab-case e vem do assunto. A pasta nasce no primeiro registro. O arquivo é só de acréscimo: cada bloco é uma seção `## Bloco N`, com título, decisão e se a recomendação foi aceita, e a confirmação final vira `## Confirmação`. O grill escreve e não commita. Quando o contexto se perdeu, ele relê o arquivo antes do bloco seguinte e não repete pergunta registrada. O `README.md` de `docs/discovery/` menciona o registro do grill. Ver a spec, "Implementation Decisions › O arquivo de registro".

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] Num grill rodado na `main`, o fim do primeiro bloco cria `docs/discovery/grill-<slug>.md` com `## Bloco 1` e uma linha por pergunta, com título, decisão e recomendação aceita ou não. O resumo aparece no chat depois da gravação.
- [ ] Num grill rodado num branch de spec, o arquivo nasce na pasta `discovery/` da spec do branch, resolvida pelo prefixo numérico.
- [ ] Uma resposta escrita na opção custom chega ao arquivo como a decisão daquela pergunta.
- [ ] O segundo bloco acrescenta `## Bloco 2` sem reescrever o primeiro, e o "confirmar" do último prompt acrescenta `## Confirmação` com o resumo confirmado.
- [ ] Com o arquivo já contendo um bloco, uma sessão nova que retoma o mesmo grill relê o arquivo e não refaz nenhuma pergunta registrada.
- [ ] O grill não commita o arquivo.
- [ ] O `README.md` de `docs/discovery/` cita o registro do grill.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
