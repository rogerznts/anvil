# 01: Diretiva com escopo de idioma, cauda de roteamento e `anvil-next` sem trava

**What to build:** Num projeto em pt-BR, tudo que chega ao chat sai no idioma de comunicação do projeto: conclusão de skill, relatório de subagente repassado, veredito e resumo de saída de ferramenta. Chave de formato estável, identificador, comando, caminho e nome de skill ficam como estão. Ao fim de uma skill da lista da cauda, a sessão principal invoca o `anvil-next` na mesma resposta e entrega o prompt da próxima sessão. Tudo isso sai da fonte única das diretivas no payload e chega aos projetos pela instalação que existe hoje. A mudança de lugar da diretiva é do ticket 03. Nenhuma skill vendorizada muda.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A seção de idioma da diretiva diz que o idioma de comunicação vale para toda saída que chega ao chat, nomeando conclusão de skill, relatório de subagente repassado, veredito e resumo de saída de ferramenta. O idioma vem das rules do projeto e, sem declaração, é pt-BR.
- [ ] A diretiva manda acrescentar a linha de idioma de saída a todo brief de subagente, inclusive quando a skill dá o brief literal em inglês.
- [ ] A diretiva diz que "verbatim" de skill é sobre conteúdo, não sobre idioma. Também diz que não se traduzem a linha `Review:` e suas chaves (`round`, `sha`, `scope`, `verdict`, `p1`), as classes como `P1`, os cabeçalhos lidos por outra peça, os identificadores, os comandos, os caminhos e os nomes de skill.
- [ ] A diretiva ganha a seção cauda de roteamento. Ela lista `anvil-to-spec`, `anvil-to-tickets`, `anvil-implement`, `anvil-run`, `anvil-browser-qa`, `anvil-diagnose`, `anvil-prototype`, `anvil-docs` no verbo `archive`, `tea-open-pr` e `tea-open-fast-pr`. A regra de disparo: quando uma skill da lista termina, com sucesso ou bloqueada, a sessão principal invoca o `anvil-next` sem argumento, na mesma resposta, depois da conclusão. A cauda não dispara em subagente, dentro do `anvil-implementer` nem quando a skill para numa pergunta ao usuário. No `anvil-implement` rodado direto, a cauda vem depois de gravada a linha `Review:`.
- [ ] O texto da diretiva funciona nos dois harnesses. No omp, a cauda depende da tradução de vocabulário que a rule `anvil-harness` já faz.
- [ ] O `anvil-next` perde a trava de invocação. A descrição passa a dizer que ele roda pela cauda de roteamento ou a pedido do usuário, e o formato de saída não muda: um bloco de até 120 palavras, com alternativas opcionais. Chamá-lo à mão com foco continua funcionando.
- [ ] O `tea-open-pr` e o `tea-open-fast-pr` limitam o inglês a título, corpo e commit do PR. O que dizem ao usuário segue o idioma de comunicação.
- [ ] O agente `anvil-implementer` do omp declara o idioma do relatório que devolve. As chaves do retorno não mudam.
- [ ] O `anvil-run` troca a recomendação de próximo passo em texto pela invocação do `anvil-next`, passando como foco a rota que já calcula: QA de browser quando há tela, archive quando não há. Isso acontece só no relatório final, nunca por despacho.
- [ ] Cenário manual da Seam 2 em `workspace/`, num projeto pt-BR. O `anvil-code-review` com os dois eixos chega em pt-BR, com a linha `Review:` igual. O `anvil-diagnose` e o `anvil-browser-qa` narram em pt-BR. No `tea-open-pr`, o corpo do PR sai em inglês e o chat em pt-BR. Um projeto com outro idioma nas rules segue esse idioma. A cauda aparece no fim do `anvil-to-spec`, do `anvil-implement` rodado direto e do `/anvil-docs archive`. A cauda não aparece no `tea-commit`, dentro do `anvil-implementer` nem quando a skill termina numa pergunta. Os mesmos casos passam no omp, incluindo o relatório final do `anvil-run`.
- [ ] O `vendor-sync.sh verify` sai limpo, sem nenhuma skill vendorizada alterada.
