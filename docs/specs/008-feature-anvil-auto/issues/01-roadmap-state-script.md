# 01: `roadmap.sh` deriva o estado do roteiro e o frontier do disco

**Blocked by:** None (can start immediately)

**Status:** resolved

**What to build:** o operador, e mais tarde o piloto e o verbo `index`, roda o
script de estado do roteiro na raiz de um projeto. O script lê
`docs/specs/roadmap.md` e devolve, em linhas `chave: valor` como o `stage.sh` e o
`frontier.sh`, o estado derivado de cada entrada, o frontier do roteiro e o
`next`. Ele recusa roteiro que não pode terminar e não escreve nada. O formato do
roteiro e a derivação estão na spec, em "Formato do roteiro" e "`roadmap.sh`:
estado derivado e frontier". O script mora no núcleo, dentro de `anvil-docs`, e é
chamado pela instalação de usuário.

O formato do roteiro fica documentado onde o perfil `docs/specs` é descrito: no
template do perfil do tracker que o `anvil-setup` escreve, na cópia deste
repositório e no `README` de `docs/specs/`. Esses três lugares registram que
`roadmap.md` e `report.md` moram em `docs/specs/`, fora das pastas de spec.

- [x] Sem `roadmap.md`, a saída é `roadmap: none` e `next: none`.
- [x] Cada entrada sai numa linha `entry:`, na ordem do arquivo, com `state`
      (`pending`, `open`, `closed` ou `stopped`), `spec`, `depends` e `reason`.
- [x] `closed` exige a pasta `docs/specs/archive/{NNN}-*` no checkout atual.
- [x] Spec aberta só no branch local dela é lida pelo commit desse branch, sem
      trocar de checkout e sem mexer na árvore.
- [x] `stopped` cobre todos os casos da tabela da spec: todos `resolved` sem
      archive; não resolvidos travados (`round` 2 ou mais com `verdict=fail`) ou
      dependentes de travado; spec arquivada no branch e sem merge; e `Spec:` sem
      pasta nem branch. Cada caso sai com o seu `reason`.
- [x] `frontier:` traz as entradas `pending` com todas as dependências `closed`,
      na ordem do arquivo. A dependente transitiva de uma `stopped` nunca entra.
- [x] `--skip "a b"` tira essas entradas do frontier, e o `next` passa para a
      seguinte.
- [x] Nome repetido, `Depende de:` que aponta para nome inexistente, ciclo e
      `Tipo:` fora dos tipos do `new-spec.sh` saem com `refusal:` e o motivo, sem
      frontier.
- [x] As chaves são aceitas com ou sem negrito, como o `Status:` dos tickets.
- [x] O cenário S1, descrito em Testing Decisions da spec, roda num diretório
      novo de `workspace/` sobre repositórios de fixture e passa em todos os casos
      listados lá.
- [x] O template do perfil do tracker, a cópia deste repositório e o `README` de
      `docs/specs/` descrevem o `roadmap.md` (formato e quem escreve) e o
      `report.md`.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai `0`.

## Comments

- S1 em `workspace/43-roadmap-state/s1.sh`: todos os casos da spec passam, com o
  script rodado no bash 5 e no `/bin/bash` 3.2 do macOS, com saídas iguais.
- A spec diz que o nome da entrada é kebab-case, mas não põe o nome fora de
  kebab-case entre as recusas. O script segue a lista da spec e não recusa; um
  nome com espaço quebraria a linha `frontier:` e o `--skip`, que separam nomes
  por espaço. Fica para decisão do operador se vira recusa.
