# 09: `anvil-distill`: destilação de um sistema local

**What to build:** O usuário tem um sistema de referência numa pasta de `references/` e pede a destilação de uma funcionalidade. Em background, o distill devolve o caminho de um documento e um resumo curto. O documento mapeia a funcionalidade, cita o código de origem com `caminho:linha`, traduz cada conceito para a stack que o projeto realmente usa e diz o que não portar. Nada no código do projeto nem no sistema de referência é alterado.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] Skill autoral, sem trava de invocação, registrada como fora do sync no manifesto e no README.
- [ ] Roda em subagente em background e devolve o caminho e um resumo de três linhas.
- [ ] Em branch com prefixo numérico, o documento cai na discovery da spec; em qualquer outro branch, na discovery da base.
- [ ] Nome `distill-{sistema}` ou `distill-{sistema}-{funcionalidade}`, um arquivo por destilação.
- [ ] Seis seções: Origem; Mapa da funcionalidade; Ponteiros verificáveis; Tradução para a stack, em quatro classes e com ponteiro do equivalente existente; O que não portar; Perguntas abertas.
- [ ] A stack é lida do código; a rule do projeto serve de atalho, e a divergência entre as duas é apontada.
- [ ] A política de escrita está no texto da skill como invariante.
- [ ] Ponto B: cada ponteiro abre e contém o trecho citado; o `git status` só mostra o documento novo; o destino muda entre branch com e sem número.
