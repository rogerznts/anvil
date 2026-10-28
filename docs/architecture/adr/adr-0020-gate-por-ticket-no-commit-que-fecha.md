# ADR-0020 — O gate roda por ticket, no commit que o fecha

- Status: aceito
- Data: 2026-10-27
- Origem: [spec 002](../../specs/archive/002-feature-custo-de-verificacao/spec.md), o custo de verificar como dado do projeto, e a rodada 1 da revisão dela sobre a `main` de 2026-10-27

## Contexto

Um projeto com o anvil viu a verificação ficar mais lenta a cada ticket. As rules
diziam que a suíte levava ~80s, e ela levava ~20 min; o número errado, repetido em
quatro arquivos, fazia pessoa e agente rodarem a suíte inteira a cada conferida.
O `anvil-implement`, vendorizado, diz *"the full test suite once at the end"*, sem
dizer se o fim é o do ticket ou o da spec. E o `anvil-implementer` da camada omp
rodava o comando de verificação antes de **cada** commit — de dois a quatro por
ticket, contando o registro da revisão e a correção de P1 —, bloqueante.

O piloto automático, pelo ADR-0014 — o piloto fecha sem humano —, já roda o
comando de verificação uma vez por spec, antes de fechá-la, como prova.

## Decisão

O **gate** é o bloco `bash` da seção `## Comando de verificação` do
`.claude/rules/anvil.md`: a suíte inteira, mais o typecheck quando o projeto tem
um. O critério de quando ele roda mora no perfil `docs/agents/verification.md`.

- **Por ticket, no commit que o fecha.** O commit que marca o ticket `resolved`
  roda o gate e espera o verde, inclusive o que o devolve a `resolved` depois de
  um P1. Nunca uma vez por spec.
- **Commits do meio, pelo que mudam.** Commit que muda código roda o laço curto,
  se o projeto tiver um, e o gate se não tiver. Commit só de documento ou de
  registro, como a linha `Review:`, não roda nada.
- **Em background.** A documentação e o registro do ticket andam enquanto o gate
  roda; só o commit que fecha espera.
- **Uma rodada antes do merge**, sobre o branch completo, que pega a interação
  entre tickets. No piloto automático, é a prova que ele já roda.
- **O custo é medido e mora só no `anvil.md`**, com data e máquina. Só a rodada
  que sai `0` vira custo.

## Consequências

- O gate por ticket gasta mais CPU que o gate por spec, de propósito: em troca, o
  vermelho tem um culpado só, e não uma bissecção entre tickets entrelaçados.
- Num projeto sem laço curto, um commit de código no meio do ticket roda a suíte
  inteira; o ganho vem dos commits de registro, que deixam de rodá-la.
- A palavra **gate** passa a nomear a suíte que fecha o ticket. No ADR-0010 — a
  verificação tem critério de parada —, ela nomeia a revisão; o glossário registra
  o sentido atual.

## Alternativas descartadas

- **Gate uma vez por spec.** Mais barato em CPU; transforma uma falha numa
  bissecção, e cada tentativa custa uma suíte inteira.
- **Gate antes de cada commit.** O que o implementer fazia: paga a suíte inteira,
  bloqueante, em commits que só registram a revisão.
- **Nada nos commits do meio.** Mais simples; deixa o commit de código sem rede
  até o fechamento, e o vermelho chega tarde dentro do ticket.
- **Mudar o `anvil-implement`.** É vendorizado. A cadência mora no perfil, que o
  `anvil-code-review` e o `anvil-implementer` da camada omp leem. O
  `anvil-implement` não cita o perfil, e no fluxo direto do Claude Code o *"once
  at the end"* continua ambíguo: é a perda aceita para não tocar o upstream.
