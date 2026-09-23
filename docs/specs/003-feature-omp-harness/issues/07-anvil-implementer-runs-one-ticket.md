# 07: `anvil-implementer` executa um ticket

**What to build:** No omp, um ticket pode ser implementado por um agente de contexto novo que segue o fluxo manual à risca. A camada ganha o agente `anvil-implementer`, que carrega `anvil-implement`, `anvil-tdd` e `anvil-code-review`, trabalha um ticket só, commita no branch atual e devolve o ticket, o `Status:` final e a última linha `Review:`. Esta fatia prova, antes de o supervisor existir, que os dois eixos do review cabem no limite de recursão do `task`.

**Blocked by:** 05

**Status:** ready-for-agent

- [ ] O agente fica em `.omp/agents/`, com `autoloadSkills` das três skills, `task` entre as ferramentas e sem `model:`.
- [ ] As três skills carregadas são as vendorizadas, sem mudança.
- [ ] Sessão do omp com `task` → `anvil-implementer` sobre um ticket de fixture termina com o ticket `resolved`, a linha `Review:` gravada no formato do perfil e um commit no branch.
- [ ] Os eixos Standards e Spec rodam como subagentes do implementer, na profundidade 2, sem erro de recursão.
- [ ] O implementer não toca em outro ticket.
- [ ] O agente entra no lock como `omp:`; o `verify` sai limpo.

## Comments

- Se o limite de profundidade não se comportar como a documentação do omp diz, é aqui que aparece, e a decisão volta para a spec antes do ticket 08.
