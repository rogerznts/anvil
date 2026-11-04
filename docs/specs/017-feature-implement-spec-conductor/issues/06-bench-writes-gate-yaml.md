# 06: O bench escreve e commita o `gate.yaml` a cada gate

**What to build:** O `GATE.md` descreve o `gate.yaml` — veredito, score, série de scores, motivo, evidência, achados — e diz que ele é reescrito a cada volta, mas nenhum passo manda escrevê-lo nem commitá-lo; nas três provas do bench da spec 017 o arquivo não apareceu. Depois de cada `--reverify` da spec, quem o rodou — o bench, ou o piloto quando ele é o supervisor — escreve `docs/specs/{id}/gate.yaml` com o veredito tirado da saída, calcula o score pela contagem, anexa o score à série e commita o arquivo no branch da spec. Achado P2 do ticket 03, anterior à spec.

**Blocked by:** 03

**Status:** claimed
**Review:** round=1; sha=84d32f9; scope=full; verdict=fail; p1=open

- [x] O `GATE.md` e a fase Construir do `anvil-bench` dizem quando escrever o `gate.yaml`, com o quê e com qual commit.
- [x] Num projeto do bench com uma entrada pequena, chamado direto no omp, o `gate.yaml` existe no branch da spec depois do `--reverify`, commitado, com o veredito igual ao da saída do checker e o score calculado pela contagem.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Prova no omp real, `workspace/95-bench-implement-spec/out-6`: `gate.yaml` no branch da spec, commit `bb7ee07` `docs(spec): record the gate of spec 001` depois do `--reverify`; `gate: PASS` com `exit: 0`; `quality_score: 100` pela contagem; `score_history: [100]`; os sete campos presentes.
- Review round=1 · P1 (Standards): o `SKILL.md` diz que todo `--reverify` termina com o `gate.yaml` gravado, e o `GATE.md` isenta o do merge local — quem seguir o `SKILL.md` tenta gravar numa pasta já arquivada.
- Review round=1 · P2 (Standards): o `CONCERNS` não sai da saída do checker, e a regra manda tirar o `gate` dela — uma spec parada com P1 na rodada 2 ganharia `PASS` no arquivo.
- Review round=1 · P2 (Standards): a regra não diz de onde vêm `updated` e `evidence_ref`; a prova gravou um `updated` anterior ao `--reverify` — o arquivo data o veredito errado.
- Review round=1 · P2 (Spec): o exemplo de "O arquivo" usa `QA-1` em `top_issues`, e a regra usa o id qualificado `gates:<id>` para gate caído — quem escreve a segunda volta não sabe qual forma manter.
- Review round=1 · P3 (Standards): placeholders `{id}`, `<pasta>` e `<number>` misturados na mesma seção.
- Fora do ticket · P2: na prova, a rodada 1 achou só P2/P3 e a sessão não corrigiu nem rodou a rodada 2, embora o `anvil-bench` mande; o mesmo aconteceu no Claude Code (ticket 05). Decisão pendente do operador: o "Fix all issues" da `implement-spec` contra o "P2 e P3 registram e seguem" do ADR-0010.
