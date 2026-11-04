# Proveniência

Skill **autoral** do anvil, derivada do verbo `study` do Hallmark. Não tem
upstream vivo, não está no `anvil-skills.yaml` e se edita direto no payload.

## De onde veio

| | |
|---|---|
| Projeto | [Nutlope/hallmark](https://github.com/Nutlope/hallmark) |
| Autor | Hallmark contributors |
| Submodule | `references/hallmark` |
| Pin de origem | `13ac0ec7e148655948100b6396439e481361d690` |
| Licença | MIT, texto abaixo |

| Arquivo daqui | Origem no pin |
|---|---|
| `references/study.md` | `skills/hallmark/references/study.md` |
| `references/examples.md` | `docs/study-examples.md` |
| `SKILL.md` | a seção `## hallmark study` de `skills/hallmark/SKILL.md`, mais a linha do verbo na tabela e a pergunta para imagem ou URL sem verbo |

O Hallmark tirou o `study` no commit `aec3e81` (Hallmark v2.2); no pin que o
`anvil-ui-hallmark` vendoriza, `de4999e`, o verbo não existe e não há substituto
no repositório público. O anvil decidiu manter o verbo como skill própria.

## O que mudou em relação à fonte, e por quê

O procedimento é o da fonte: modo URL e modo imagem, a checagem de segurança da
URL, a detecção de página bloqueada, as recusas (template pago, obra de
assinatura), os cinco passos, o esquema, o diagnóstico, a atestação antes de
emitir e as três saídas. Mudou só o que o Hallmark novo quebrou:

- **Handoff.** A fonte construía com o "studied-DNA" pela Condição 0 do passo 2.6
  do `SKILL.md` antigo, que não existe mais. Agora o `study` grava o DNA como
  `design.md` na raiz e chama a Skill tool com `anvil-ui-hallmark`. O pre-flight
  do Hallmark novo lê esse arquivo como sistema travado: *"`design.md` or
  `DESIGN.md` at the root (a locked system: it overrides everything below, and
  pages share it)"* (`anvil-ui-hallmark/SKILL.md`, passo 0). Como o build agora
  grava o mesmo arquivo da emissão, a atestação do modo URL vale para os dois.
- **Formato do `design.md`.** O link para `design-md.md` cruzaria a fronteira de
  skill; o modelo do Hallmark novo (`references/design-md.md` § Format) está
  reproduzido no `study.md`, com os blocos `## Provenance` e `## Notes` da fonte.
  O carimbo de topo da fonte virou a primeira linha do `## Provenance`, porque o
  formato novo não tem carimbo. Também do formato novo: nunca sobrescrever um
  `design.md` existente (*"Never overwrite"*, mesmo arquivo).
- **Vocabulário de estrutura.** Os arquétipos `H1`–`H6`, `F1`–`F6`, `T1`–`T4`,
  `N1`–`N9`, `Ft1`–`Ft8` e o `component-cookbook.md` saíram. No lugar entram as
  posturas de hero (`layout.md` § 6), as composições (§ 5), as navs e os footers
  (§ 7) e a impressão digital de seis eixos (`macrostructures.md` § The
  fingerprint). Os nomes das 21 macroestruturas continuam os mesmos.
- **Anti-padrões.** O `anti-patterns.md` saiu. A seção nova `What Hallmark will
  not carry over` resume o Floor do `SKILL.md` novo, que vale para todo build.
  Daí também as mudanças nos exemplos: rótulo mono e caixa-alta espaçada viram
  rótulo no corpo do texto (Floor 9), número digitado ao lado do título vira
  `<ol>` (gate 54).
- **Temas.** A tabela de mapeamento citava os temas como eram no pin antigo;
  foi refeita a partir do `references/themes/index.json` do pin `de4999e`, com
  os mesmos onze temas. O `Plain` do exemplo A não existe mais e virou `Ink`.
- **Fontes.** O "canon" da fonte era o `typography.md`, que saiu. O `study.md`
  define o canon pelo `fonts.md` novo: faces livres, a lista do que é banido como
  padrão e a do que é saturado. A substituição de fonte paga ficou como estava.
- **Specimen.** O `macrostructures/10-specimen.md` novo restringe a forma a tipo,
  editora e escrita; o exemplo A, um portfólio, passou para `Index-First`.
- **Carimbo de saída.** A seção *Output contract for `study`* da fonte saiu: quem
  escreve o carimbo agora é o Hallmark, no formato dele.

## Acoplamento com o `anvil-ui-hallmark`

Os nomes acima (macroestruturas, posturas, composições, navs, footers, eixos do
`design.md`, Floor, temas, listas de fontes) estão copiados do
`anvil-ui-hallmark` no pin `de4999e`. A cada `/anvil-sync` do Hallmark, confira
se algum deles mudou e atualize o `study.md` e o `examples.md` à mão.

## Licença da fonte

```text
MIT License

Copyright (c) 2026 Hallmark contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
