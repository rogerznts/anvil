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

## Comments

**Leader, 2026-09-13 — entrega do Dev** em `a701bf9` (skill: `SKILL.md` e `DISTILL.md`), `b255463` (registro como
autoral) e `b27971f` (roster). Ponto B isolado, projeto Python com rule dizendo Node de propósito, sistema de
referência Node: destilações da versão final com 166 ponteiros cada, reabertos por script sem falha; destino na
discovery da spec com branch numerado e na base sem número; stack lida do código com a divergência apontada; nada
alterado fora do documento; Origem com commit do clone, pin do submodule ou "sem versão verificável"; pedido genérico
de análise não disparou a skill. Sete sessões, US$ 8,97.

Desvios aceitos: a invariante de escrita mora no `DISTILL.md` (quem escreve) e o `SKILL.md` aponta; destino lido do
disco, porque o distill roda antes de a spec ser commitada; parar quando o branch tem número sem pasta de spec;
perguntar antes de substituir uma destilação existente.

Ajuste antes dos gates: a tabela "Quem escreve onde" do `anvil-docs` e o README de `discovery/` passam a citar o
`anvil-distill` ao lado do `anvil-research`. Riscos registrados: a sessão principal pode repassar a stack da rule como
fato ao subagente (o subagente seguiu o código); documentos grandes (770–980 linhas) custam no grill se lidos
inteiros. Ideia: registrar uma skill autoral exige mexer em quatro lugares.

**Leader, 2026-09-13 — ajuste pré-gate** em `9bc93b6` (`anvil-docs` e README de `discovery/` citam o `anvil-distill`).
Gates despachados: Review e Tester.
