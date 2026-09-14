# 09: `anvil-distill`: destilação de um sistema local

**What to build:** O usuário tem um sistema de referência numa pasta de `references/` e pede a destilação de uma funcionalidade. Em background, o distill devolve o caminho de um documento e um resumo curto. O documento mapeia a funcionalidade, cita o código de origem com `caminho:linha`, traduz cada conceito para a stack que o projeto realmente usa e diz o que não portar. Nada no código do projeto nem no sistema de referência é alterado.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] Skill autoral, sem trava de invocação, registrada como fora do sync no manifesto e no README.
- [x] Roda em subagente em background e devolve o caminho e um resumo de três linhas.
- [x] Em branch com prefixo numérico, o documento cai na discovery da spec; em qualquer outro branch, na discovery da base.
- [x] Nome `distill-{sistema}` ou `distill-{sistema}-{funcionalidade}`, um arquivo por destilação.
- [x] Seis seções: Origem; Mapa da funcionalidade; Ponteiros verificáveis; Tradução para a stack, em quatro classes e com ponteiro do equivalente existente; O que não portar; Perguntas abertas.
- [x] A stack é lida do código; a rule do projeto serve de atalho, e a divergência entre as duas é apontada.
- [x] A política de escrita está no texto da skill como invariante.
- [x] Ponto B: cada ponteiro abre e contém o trecho citado; o `git status` só mostra o documento novo; o destino muda entre branch com e sem número.

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

**Leader, 2026-09-13 — gate Review, rodada 1: APROVADO, sem bloqueante.** Critérios atendidos sobre `9bc93b6`;
`check-pointers.py` reexecutado (p-spec 166/45, p-base 166/49, sem falha); p-neg sem skill; destilação da r3 lida
inteira e julgada útil a quem implementa (21 conceitos nas quatro classes, 8 perguntas abertas). Achados:
**R1** o `ls -d` do destino (`SKILL.md:33`) aborta em zsh quando um dos globs não casa — o caso comum, spec não
arquivada — e a pasta existente some da saída; o p-spec bateu nisso e se recuperou com outro comando; um modelo
menos insistente pararia em branch válido. **S1** a sessão principal repassou a stack da rule como fato ao
subagente nas duas rodadas finais (o risco já registrado se repetiu). **N1** a árvore do `anvil-docs/SKILL.md:54`
ainda cita só o `anvil-research` em `discovery/`, e a linha 87 tem "dentro dele" ambíguo. **N2** a regra de destino
repete o perfil do tracker; num projeto com perfil GitHub/GitLab (sem `docs/specs/`), `feature/123-login` cai no
"pare". Sugestões: sem funcionalidade cobre o sistema inteiro também no `DISTILL.md`; ponteiro "a partir da raiz"
com referência fora do projeto; criar `docs/` quando não existe; nomear "não executar a referência nem os testes";
critério de "grande demais". Fora do ticket: `docs/architecture/overview.md:30-31` desatualizado (contagem de
autorais, sem `anvil-team`).

**Leader, 2026-09-13 — gate Tester, rodada 1: APROVADO.** Isolado, payload igual a `696ae61`, referência Ruby
(faraday-retry 1.0.3) e projeto-alvo Go com a rule dizendo outra stack de propósito. Branch `fix/042-…` → discovery
da spec, seis seções, 105 ponteiros limpos, quatro classes com trecho do projeto, divergência rule × `go.mod` com
ponteiro dos dois lados, Origem "sem versão verificável" para cópia versionada no próprio git; `feat/…` sem número →
`docs/discovery/` mesmo com spec existente como isca; `fix/043-…` sem pasta → parou antes de despachar, sem escrever;
"porta X de references/Y" disparou; "analisa esse código" (no projeto e em `references/`) não disparou; `git status`
só com o documento e referência intacta. Sete sessões, US$ 5,21. Achados: **A** a stack da rule foi repassada como
fato em 4 de 4 despachos (o S1 do Review, já no ajuste); **B** em `-p` com `permissionMode` default o Write do
subagente em background é negado e nada é gravado — a skill avisa e oferece retomar; no interativo não foi testado
(risco, coerente com a M4 do ticket 06); **C** o `check-pointers.py` do Dev aprova 10 de 16 ponteiros falsos
(`workspace/16-distill-tester/checker/fakes.py`); o verificador estrito do Tester confirma r2 e r3 limpos.

Rodada única de ajuste com o Dev: R1, S1 (= A), N1, N2 (sem `docs/specs/`, número no branch vai para a base) e duas
linhas no `DISTILL.md` (sem funcionalidade cobre o sistema inteiro; não executar a referência nem os testes).
Ficam como ideia: `check-pointers.py` estrito se for reusado como prova; ponteiro com referência fora do projeto;
criar `docs/` quando não existe; critério de "grande demais"; `overview.md` desatualizado (autorais, `anvil-team`).

**Leader, 2026-09-13 — resolvido.** Rodada de ajuste em `0c9867a` e `66d78af`, conferida pelo Leader: **R1** o destino
usa `find docs/specs -maxdepth 2 -type d -name '{NNN}-*'` — uma saída só por caso, igual em zsh 5.9, bash 5.2 e
`/bin/bash` 3.2 (ativa, arquivada, ausente, sem `docs/specs/`); **S1** o prompt do despacho leva só o que está
listado, e a sessão não lê nem repassa a stack (run isolado: prompt sem stack, divergência só no resumo do
subagente); **N2** sem `docs/specs/`, branch com número vai para `docs/discovery/` (run isolado com perfil GitHub:
seis seções, 109 ponteiros limpos no verificador estrito do Tester; regressão do "pare" com `docs/specs/` sem a
pasta); **N1** árvore e tabela do `anvil-docs`; duas frases no `DISTILL.md`. `verify` limpo. US$ 1,07.

Desvios aceitos: `-maxdepth 2` a partir de `docs/specs` em vez das duas raízes, que devolveriam ruído com rc=1 no caso
comum sem `archive/`; a linha da tabela do `anvil-docs` não ganha a exceção de projeto sem `docs/specs/`, porque a
árvore descrita ali é a do perfil local.
