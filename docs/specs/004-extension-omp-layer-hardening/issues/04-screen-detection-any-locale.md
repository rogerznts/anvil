# 04: Tela em qualquer locale e exemplos da `anvil-run`

**What to build:** A detecção de tela do `frontier.sh` passa a funcionar em qualquer locale, e a `anvil-run` dá ao supervisor exemplos do caso que o script não reconhece. O operador de uma spec com tela recebe a recomendação do browser QA mesmo com `LC_ALL=C` ou com a tela descrita em outras palavras. Linhas A4 e A6 do acompanhamento.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] A comparação da lista de palavras de tela é feita com `perl` em modo Unicode, sem distinguir maiúsculas e só com palavra inteira; a lista não muda.
- [ ] "PÁGINA", "BOTÃO" e "PAINÉIS" numa user story dão `screen: yes` em `LC_ALL=C` e em UTF-8, nos dois bash.
- [ ] "paginar" continua sem contar, e palavra de tela fora das User Stories também.
- [ ] O item `screen: no` da `anvil-run` usa exemplos que o script não reconhece: gráfico que o usuário filtra, mapa clicável, cards que se arrastam entre colunas.
- [ ] Cenário novo no S2 da `anvil-run`: spec resolvida, sem `ui/`, com uma user story de cards que se arrastam entre colunas, recebe `/skill:anvil-browser-qa` citando a história; o cenário B, de somar uma coluna, segue com o archive.
- [ ] O `verify` sai limpo.
