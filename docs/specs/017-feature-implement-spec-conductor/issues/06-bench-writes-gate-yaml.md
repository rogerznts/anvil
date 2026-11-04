# 06: O bench escreve e commita o `gate.yaml` a cada gate

**What to build:** O `GATE.md` descreve o `gate.yaml` — veredito, score, série de scores, motivo, evidência, achados — e diz que ele é reescrito a cada volta, mas nenhum passo manda escrevê-lo nem commitá-lo; nas três provas do bench da spec 017 o arquivo não apareceu. Depois do `--reverify`, quem conduz o bench escreve `docs/specs/{id}/gate.yaml` com o veredito tirado da saída, calcula o score pela contagem, anexa o score à série e commita o arquivo no branch da spec. O piloto, no modo bench, lê o veredito do arquivo commitado. Achado P2 do ticket 03, anterior à spec.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] O `GATE.md` e a fase Construir do `anvil-bench` dizem quando escrever o `gate.yaml`, com o quê e com qual commit.
- [ ] Num projeto do bench com uma entrada pequena, chamado direto no omp, o `gate.yaml` existe no branch da spec depois do `--reverify`, commitado, com o veredito igual ao da saída do checker e o score calculado pela contagem.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
