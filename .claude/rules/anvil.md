# Configuração do anvil neste repositório

## Comunicação

pt-BR.

## Comando de verificação

Não há suíte de teste. O que faz as vezes:

```bash
bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
```

Custo medido: 17s, em 2026-10-27, numa máquina Linux de 16 CPUs.

Quem medir diferente corrige este arquivo no mesmo commit. O critério de quando
rodar a verificação está em `docs/agents/verification.md`.

## Modelos por papel

Lidos por `anvil-arena`, `anvil-how`, `anvil-architect`, `anvil-swarm` e
`anvil-interrogate`.

- `runners`: `opus`, `fable`, `sonnet`
- `how-explorer`: `sonnet`
- `how-explainer`: `opus`
- `cross-judge`: `opus`, `fable`, `sonnet`
- `swarm workers`: `sonnet`
- `interrogate reviewers`: `opus`, `sonnet`
