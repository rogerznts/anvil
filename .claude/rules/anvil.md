# Configuração do anvil neste repositório

## Comunicação

pt-BR.

## Comando de verificação

Não há suíte de teste. O que faz as vezes:

```bash
bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify
```

## Modelos por papel

Lidos por `anvil-arena`, `anvil-how` e `anvil-architect`.

- `runners`: `opus`, `fable`, `sonnet`
- `how-critics`: `opus`, `fable`, `sonnet`
- `cross-judge`: `opus`, `fable`, `sonnet`
