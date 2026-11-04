# Gate — a condição de parada do loop

Este arquivo existe porque o bench é **headless**: ele dispara agentes isolados,
o disco é a fronteira de estado entre eles, e um loop que roda sozinho precisa de
uma condição de parada que não dependa de alguém julgar.

**É o único lugar do anvil com `gate.yaml`.** No fluxo normal, o
`anvil-code-review` devolve o veredito em prosa, dois eixos lado a lado — que é
melhor para um humano ler. Aqui não há humano lendo a cada volta.

## O arquivo

`docs/specs/{id}/gate.yaml`, reescrito a cada volta:

```yaml
gate: PASS                    # PASS | CONCERNS | FAIL | WAIVED
quality_score: 90             # 0-100, calculado
score_history: [61, 68, 90]   # a série, do primeiro gate ao atual
status_reason: "uma ou duas frases sobre o veredito"
updated: "2026-08-29T14:30:00Z"
evidence_ref: qa-notes.md     # caminho relativo dentro da spec

top_issues:
  - id: QA-1                  # QA-# para gate, SEC-# para segurança
    severity: high            # low | medium | high
    title: "Login aceita tentativas sem limite"
    finding: "Nenhum rate limit no endpoint de login (auth/login.ts:42-68)"
    contradicts: 'NFR-002 — "resistir a força bruta em autenticação"'
    suggested_action: "Adicionar rate limiting antes de publicar"
```

**Todo id citado carrega a glosa na primeira menção.** `contradicts: SC-004`
sozinho obriga quem lê a abrir a spec para saber se aquilo importa. Gate que o
`--reverify` derrubou entra pelo id qualificado que o checker imprime —
`gates:C3` — e a glosa é o próprio título do gate.

**Os ids são estáveis dentro da spec:** `QA-1` na segunda volta é o mesmo defeito
da primeira. É isso que torna a série legível.

## A evidência

O `gate.yaml` é o veredito. O que o produz é a **reexecução dos ledgers** que a
fase 4 escreveu, o da spec e o de cada spec do roteiro já fechada, nunca a leitura
do que o agente disse ter feito. Rode no branch da spec, com o container de pé
(`docker compose up -d app`, se não estiver):

```
fechados="$(bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh | sed -n 's/^entry: .* state=closed spec=\([0-9]*\) .*/\1/p' |
  while read -r n; do ls docs/specs/archive/"$n"-*/gates.md 2>/dev/null; done)"
docker compose cp ~/.claude/skills/anvil-bench/unlazy/scripts/. app:/tmp/anvil-gates
docker compose exec -T app node /tmp/anvil-gates/gate-check.mjs \
  --reverify --approve --cwd . docs/specs/<pasta>/gates.md $fechados; echo "exit: $?"
[ -z "$fechados" ] || git checkout -- $fechados
```

Cinco coisas nesse comando não são detalhe de digitação.

**`--reverify`, nunca `--status`.** O `--status` lê o ledger e acredita nele: um
gate marcado à mão, com uma linha de evidência inventada, devolve `ALL MET` e sai
`0`. Medido contra o commit pinado. Só o `--reverify` reexecuta cada `CHECK:`, e
é ele que derruba o gate quando o oráculo parou de passar.

**Quem roda é o supervisor.** O agente que implementou o ticket não confere o
próprio ledger. Se escrevesse e conferisse, o gate seria o `Status: resolved`
auto-declarado outra vez, com mais cerimônia e nenhuma prova a mais. O disco é a
fronteira: o agente entrega o código, o supervisor reexecuta.

**Dentro do container.** É onde os testes já rodam e onde o Node existe sem
ninguém instalar nada na máquina (INV-4). O checker vem da instalação de usuário,
que o container não monta: o `cp` o põe lá antes de cada execução, e o projeto
continua sendo o diretório de trabalho do container. O `--approve` fica no
comando porque a aprovação do unlazy amarra o `PATH` inteiro e não sobrevive à
recriação do container: em loop headless ela é registro, não consentimento. Quem
lê os comandos antes de aprová-los é você, na fase 4, ao escrever o ledger.

**Os ledgers das specs fechadas.** Uma spec nova não pode quebrar o que já foi
entregue, e o `PASS` dela reexecuta também o ledger de cada spec do roteiro que o
`roadmap.sh` dá como `closed`, arquivado em `docs/specs/archive/`. Um gate delas
que cai é regressão, e segura a spec nova. O checker reescreve a evidência de cada
ledger que reexecuta, e uma spec arquivada não muda: o `git checkout` devolve os
ledgers dela como estavam, e o que vale é a saída. Sem roteiro, o ledger é só o da
spec.

**`--cwd .`** Os `CHECK:` são escritos como rodam da raiz do projeto, no
container. Sem ele, o checker roda cada ledger ao lado de si, e o de uma spec
arquivada fica um nível mais fundo que o de uma spec aberta.

Contexto e limites do material adotado: [unlazy/VENDOR.md](unlazy/VENDOR.md).

## O veredito

| veredito | quando | o loop |
|---|---|---|
| `PASS` | o `--reverify` dos ledgers sai `0`: smoke, testes de módulo acumulados e asserts de negócio, **todos** verdes, nesta spec e nas já fechadas | para, entrega |
| `CONCERNS` | a rodada 2 da spec ainda tem P1 — a execução da `anvil-implement-spec` parou antes de fechar os tickets —, ou defeito que não bloqueia | para, reporta o que falta |
| `FAIL` | defeito bloqueante — gate derrubado pelo `--reverify` depois da execução da `anvil-implement-spec`, nesta spec ou numa já fechada | para, reporta o que falta |
| `WAIVED` | alguém aceitou explicitamente o defeito | para, com os quatro campos de waiver preenchidos |

**Só o veredito decide.** O score não termina loop nenhum.

**E `PASS` não é julgamento.** Com ledger na spec, o veredito verde é a saída de
um processo que reexecutou os comandos; sem ledger — spec antiga, ou checklist
que nenhum teste alcança — ele volta a ser leitura do `anvil-code-review`, e a
diferença tem que aparecer no `status_reason`. Não escreva `PASS` sobre um
ledger que você não viu reexecutar.

**Grave o veredito.** Depois de cada `--reverify` da spec, quem o rodou — o bench,
ou o piloto quando ele é o supervisor — escreve `docs/specs/{id}/gate.yaml` no
formato de "O arquivo": o `gate` tirado da saída do checker por esta tabela, o
`quality_score` pela contagem de "O score", o score anexado ao `score_history`
que o arquivo já trazia, o `status_reason` com o `exit:` e a linha final do
checker, e cada gate caído em `top_issues` pelo id qualificado. Commite o arquivo
no branch da spec, antes de entregar ou de seguir:

```bash
git add docs/specs/<pasta>/gate.yaml
git commit -m "docs(spec): record the gate of spec <number>"
```

O `--reverify` do merge local, sob o piloto, não grava: ele só decide o merge, e a
pasta da spec já está arquivada.

## O score

```
quality_score = 100 − (20 × FAILs) − (10 × CONCERNS)
```

Limitado a `0..100`. **Calculado por contagem, nunca estimado** — é isso que
torna a série comparável entre voltas.

Ele existe para tornar a **trajetória** visível:

- dois `FAIL` com score parado → estagnação. Hora de parar e devolver, não de
  tentar de novo.
- dois `FAIL` com score subindo → convergência lenta. Vale a próxima volta, se a
  spec ainda tem rodada.

`score_history` é acumulado: o arquivo é reescrito a cada volta, então score que
não for anexado ali se perde.

## O teto de duas rodadas

Por spec. É o orçamento do ADR-0010 — a verificação tem critério de parada, e a
terceira rodada é escolha declarada de um humano —, que o ADR-0023 — a
`anvil-implement-spec` conduz a spec com um review único — passou a contar por
spec, com as classes de `docs/agents/verification.md`:

- a **rodada 1** mede o diff da spec inteira, quando todos os tickets ficaram
  prontos;
- a **rodada 2** mede o diff da correção que um implementer novo fez de tudo o
  que a rodada 1 levantou: remede os achados dela e o que a correção pode ter
  quebrado.

Quem conta as rodadas é a execução da `anvil-implement-spec`. O gate roda uma
vez, depois da execução.

Com P1 ainda aberto na rodada 2, a spec **para**: a execução não fecha os
tickets, o veredito é `CONCERNS`, e o loop não insiste, não abre uma terceira
rodada com outra abordagem. O gate que o `--reverify` derruba depois da execução
não reabre a spec: o veredito fica `FAIL`, e o loop para do mesmo jeito. Em
qualquer dos dois casos, o que continua aberto vai para a entrega como pendência
declarada, e os P1 da rodada 2 vão para o `build-log.md`.

A terceira rodada não é do bench. O motivo é o mesmo que justifica o loop
existir: quem está esperando a ferramenta não tem como julgar se ela vale a pena.
Parar e dizer o que falta é mais honesto que continuar tentando.

## Sob o piloto automático

No omp, quando o bench é a entrada do piloto automático, a skill `anvil-auto`, o
supervisor é o piloto. Ele roda o comando de "A evidência" no `PASS` de cada spec,
depois que a execução da `anvil-implement-spec` acabou, e lê a saída por esta
regra. Ela é a única do gate manual sob o piloto: o `anvil-auto` e o
[SKILL.md](SKILL.md) apontam para cá.

O id que o checker imprime, `gates:<id do item>`, é único no checklist e diz de
que ledger é o gate. Um gate sem `CHECK:` é manual.

- o gate com `CHECK:` que cai, nesta spec ou numa fechada, ou o checker que não
  roda, é o `FAIL` no teto, haja ou não gate manual desta spec aberto: a spec não
  volta à `anvil-implement-spec` sem a rodada extra, e o piloto pesquisa em fontes
  primárias antes de travar. A rodada extra que a pesquisa abre, com evidência
  nova, uma vez por spec, é a exceção que o piloto registra no relatório, e não
  uma terceira rodada do bench;
- sem gate com `CHECK:` caído, o gate manual aberto no ledger desta spec deixa a
  spec parada por decisão, à espera de quem confere;
- o gate manual aberto no ledger de uma spec fechada é dela e não segura esta;
- sem gate manual desta spec aberto e sem gate com `CHECK:` caído, a saída vale o
  `PASS`: o `exit: 0` com `ALL MET`, ou o `exit: 1` em que todo id abaixo de
  `UNMET:` é de gate manual de spec fechada.

Cada gate manual aberto, desta spec ou de uma fechada, vai para "o que ainda
espera decisão", no relatório, como pergunta, também quando um `CHECK:` caiu e a
spec seguiu o caminho do `FAIL` no teto: a pesquisa e a rodada extra não o
respondem. Nem o piloto nem o implementer o marcam: a evidência dele é de quem
conferiu.

O piloto roda o mesmo comando de novo no merge local, quando a `main` andou desde
o corte do branch: sobre o merge preparado, sem o `docs/specs/<pasta>/gates.md`,
porque a pasta da spec já está em `docs/specs/archive/` e o ledger dela vem no
`$fechados`. Ali, a regra acima só diz que saída vale o `PASS`. Qualquer outra
aborta o merge e deixa a spec parada por decisão, já arquivada no branch, sem
pesquisa e sem rodada extra, como diz o `anvil-auto`: a spec não volta à
`anvil-implement-spec`, e quem decide qual spec cede é o operador.

## Nova evidência

Evidência que aparece no meio do loop **amplia** o contexto e pode reclassificar
o trabalho para mais rigor. Nunca para menos: um teste que passou não apaga um
defeito encontrado antes.
