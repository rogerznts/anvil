# Adaptadores de runtime

O Leader escolhe exatamente um adaptador por sessão. As regras de produto,
ownership, tickets e gates continuam no `SKILL.md` e no `PROTOCOL.md`.

## Codex

Selecione este adaptador quando `spawn_agent` estiver disponível.

| Operação | Ferramenta | Regra |
|---|---|---|
| despachar | `spawn_agent` | `task_name` em minúsculas, dígitos e `_`; `message` recebe a delegação completa; use `fork_turns: "all"` quando o contexto atual for útil |
| mensagem a agente ativo | `send_message` | enderece pelo id ou nome canônico devolvido pelo despacho |
| retomar agente ocioso | `followup_task` | envie a continuação completa e acionável |
| inventário | `list_agents` | use para capacidade, estado e identidade; não adote agente alheio à execução |
| aguardar | `wait_agent` | prefira espera longa; mantenha o usuário informado antes de esperas demoradas |
| interromper | `interrupt_agent` | somente quando o trabalho ficou obsoleto, inseguro ou foi substituído |

No `message`, antes da delegação, mande o papel ler integralmente:

1. `.claude/agents/anvil-team-{papel}.md`, que define sua responsabilidade;
2. `.claude/skills/anvil-team/PROTOCOL.md`, que define conduta e retorno.

Os arquivos de papel são a substituição Codex para `subagent_type`. Não presuma
que o agente recebeu automaticamente a persona do Claude Code.

Não passe override de modelo salvo exigência explícita do usuário ou das regras do
projeto. O limite de slots inclui o Leader. Se não houver slot, espere ou reutilize
um agente ocioso compatível; não declare incompatibilidade.

Os agentes compartilham o mesmo checkout. Só um escritor pode estar ativo. Papéis
somente leitura podem rodar em paralelo. Tester ou Review só podem coexistir com um
escritor quando sua Política de escrita proíbe alterações no checkout e fornece um
diretório temporário absoluto.

Mapeamento de nomes:

- lógico `dev-03` → `task_name: "dev_03"`;
- gate Review, rodada 1 → `task_name: "review_03_r1"`;
- nova instância após perda de contexto → acrescente `_r{n}` ou `_retry{n}`.

Exemplo conceitual de despacho:

```text
spawn_agent({
  task_name: "dev_03",
  fork_turns: "all",
  message: "Leia .claude/agents/anvil-team-dev.md e .claude/skills/anvil-team/PROTOCOL.md integralmente. Depois cumpra esta delegação:\n\n# Delegação · dev · spec 012 · ticket 03\n..."
})
```

## Claude Code

Selecione este adaptador quando `Agent` e `SendMessage` estiverem disponíveis e o
adaptador Codex não estiver.

Antes do primeiro despacho, verifique
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Se não estiver ligado, explique como
habilitar agent teams numa nova sessão; essa exigência nunca se aplica ao Codex.

O despacho usa `Agent` com:

- `subagent_type: "anvil-team-{papel}"`;
- `name: "{papel}-{NN}"`;
- `description: "{papel} · ticket {NN}[ · rodada {n}]"`;
- `run_in_background: true`;
- `prompt` com a delegação completa;
- `model` somente quando válido pela seção "Modelo por papel";
- `isolation: "worktree"` somente no caso previsto pela seção de paralelismo.

Use `SendMessage` para agente alcançável e `ListAgents` para inventário. Se a
ferramenta estiver diferida, carregue-a conforme o mecanismo do Claude Code.
