# ADR-0004 — Sync por merge 3-way, com o pin do submodule como base

- Status: aceito
- Data: 2026-08-28
- Depende de: [adr-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md)

## Contexto

O anvil vendoriza 33 skills de quatro repositórios que continuam evoluindo. Sem
mecanismo de re-sincronização, a curadoria congela na data em que foi feita — e
o valor de adotar skills mantidas por outros desaparece.

Três desenhos foram considerados:

1. **Wrapper fino** — o payload aponta para `references/`. Zero divergência, mas o
   `degit` não leva o conteúdo: o projeto que instala não teria as skills.
2. **Fork total** — copia uma vez, updates viram leitura manual de diff. Liberdade
   máxima, "atualizar" vira trabalho braçal indefinido.
3. **Cópia com patch registrado** — a escolhida.

Dentro da terceira, a pergunta é o que serve de **base do merge**. O reflexo é
guardar um snapshot pristino do upstream junto da cópia adaptada. Mas os
`references/*` já são submodules pinados por commit.

## Decisão

**O pin do submodule no manifesto é a base do merge.** Não há snapshot a manter.

```
base   = git -C references/skills show <pin>:skills/engineering/to-spec/SKILL.md
theirs = git -C references/skills show <novo-HEAD>:…
ours   = anvil/.claude/skills/anvil-to-spec/SKILL.md

git merge-file ours base theirs
```

Se `base == theirs`, o upstream não mudou e a skill é pulada.

O manifesto é `anvil-skills.yaml`, na raiz, fora do `degit`:

```yaml
skills:
  - name: anvil-setup
    source: mattpocock
    path: skills/engineering/setup-matt-pocock-skills
    pin: 6654f6b…
    adapt: [rename]
    add:   [issue-tracker-anvil.md]
    strip: [agents/openai.yaml]
```

O `pin` é **por skill**, não global: uma pode ficar para trás sem travar as
outras. `add` registra arquivo do anvil injetado dentro de skill vendorizada;
`strip`, arquivo deliberadamente deixado de fora — ambos para o update não os
re-adicionar nem tentar remover.

O catálogo de adaptações é fechado e vive em `anvil-sync/ADAPT-RULES.md`:
`rename` · `docs-remap` · `decursor` · `add`/`strip`. Não há regra de idioma:
nada é traduzido.

## Consequências

**A favor.** Nada de cache para manter sincronizado — a base é reconstruível de
graça, para sempre, enquanto o commit existir no submodule. Como o
[adr-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md) mantém o
delta em 14 linhas, o merge tende a ser trivial.

**Contra.** Depende de o commit pinado continuar alcançável. Force-push ou
rebase agressivo no upstream quebra a base. Mitigação: os submodules são clones
completos, então o commit sobrevive localmente mesmo se sumir do remoto.

**O que precisa ser provado.** Apontar o pin de uma skill para um commit antigo,
rodar o update e conferir que ele traz o diff upstream sem conflito. Enquanto
esse teste não rodar, a máquina não está provada — só descrita.
