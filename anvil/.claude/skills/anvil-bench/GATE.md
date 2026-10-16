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
| `CONCERNS` | ticket travado em `round=2` — a rodada 2 dele não aprovou, e a última `Review:` está em `round=2` com `verdict=fail` —, ou defeito que não bloqueia | para, reporta o que falta |
| `FAIL` | defeito bloqueante — P1 na `Review:` da rodada 1, ou gate derrubado pelo `--reverify` | volta para o `anvil-implement` se o ticket ainda tem rodada; no teto, para e reporta o que falta |
| `WAIVED` | alguém aceitou explicitamente o defeito | para, com os quatro campos de waiver preenchidos |

**Só o veredito decide.** O score não termina loop nenhum.

**E `PASS` não é julgamento.** Com ledger na spec, o veredito verde é a saída de
um processo que reexecutou os comandos; sem ledger — spec antiga, ou checklist
que nenhum teste alcança — ele volta a ser leitura do `anvil-code-review`, e a
diferença tem que aparecer no `status_reason`. Não escreva `PASS` sobre um
ledger que você não viu reexecutar.

## O score

```
quality_score = 100 − (20 × FAILs) − (10 × CONCERNS)
```

Limitado a `0..100`. **Calculado por contagem, nunca estimado** — é isso que
torna a série comparável entre voltas.

Ele existe para tornar a **trajetória** visível:

- dois `FAIL` com score parado → estagnação. Hora de parar e devolver, não de
  tentar de novo.
- dois `FAIL` com score subindo → convergência lenta. Vale a próxima volta, se o
  ticket ainda tem rodada.

`score_history` é acumulado: o arquivo é reescrito a cada volta, então score que
não for anexado ali se perde.

## O teto de duas rodadas

Por ticket, não por spec. É o orçamento do ADR-0010 — a verificação tem critério
de parada, e a terceira rodada é escolha declarada de um humano —, o mesmo que
vale no resto do anvil, com as classes e a persistência de
`docs/agents/verification.md`:

- a **rodada 1** mede o ticket inteiro;
- a **rodada 2** mede o diff da correção: remede os achados da rodada 1 e o que a
  correção pode ter quebrado.

Cada rodada deixa uma linha `Review:` no ticket, e é por ela que se conta: o
disco diz em que rodada o ticket está, não a memória da sessão. Um gate derrubado
pelo `--reverify` também gasta a rodada em que caiu, e o ticket volta para a
seguinte.

A rodada 2 que não aprova **trava** o ticket: a última `Review:` dele fica em
`round=2` com `verdict=fail`. O veredito é `CONCERNS`, e o loop **para** — não
insiste, não abre uma terceira rodada com outra abordagem. O gate que cai depois
da rodada 2 também esgota o teto: o veredito fica `FAIL`, e o loop para do mesmo
jeito. Em qualquer dos dois casos, o que continua aberto vai para a entrega como
pendência declarada; no ticket travado, os P1 ficam no `## Comments` dele.

A terceira rodada não é do bench. O motivo é o mesmo que justifica o loop
existir: quem está esperando a ferramenta não tem como julgar se ela vale a pena.
Parar e dizer o que falta é mais honesto que continuar tentando.

## Sob o piloto automático

No omp, quando o bench é a entrada do piloto automático, a skill `anvil-auto`, o
supervisor é o piloto. Ele roda o comando de "A evidência" no `PASS` de cada spec,
depois que o despacho acabou, e lê a saída por esta regra. Ela é a única do gate
manual sob o piloto: o `anvil-auto` e o [SKILL.md](SKILL.md) apontam para cá.

O id que o checker imprime, `gates:<id do item>`, é único no checklist e diz de
que ledger é o gate. Um gate sem `CHECK:` é manual.

- o gate manual aberto no ledger desta spec deixa a spec parada à espera de quem
  confere, e vai para o relatório como pergunta. Nem o piloto nem o implementer o
  marcam: a evidência dele é de quem conferiu;
- o gate manual aberto no ledger de uma spec fechada é dela e não segura esta: vai
  para "o que ainda espera decisão", também como pergunta, e ninguém o marca;
- o gate com `CHECK:` que cai, nesta spec ou numa fechada, ou o checker que não
  roda, é o `FAIL` no teto: nenhum ticket volta ao despacho sem a rodada extra, e
  o piloto pesquisa em fontes primárias antes de travar. A rodada extra que a
  pesquisa abre, com evidência nova, é a exceção que o piloto declara no ticket, e
  não uma terceira rodada do bench;
- sem gate manual desta spec aberto e sem gate com `CHECK:` caído, a saída vale o
  `PASS`: o `exit: 0` com `ALL MET`, ou o `exit: 1` em que todo id abaixo de
  `UNMET:` é de gate manual de spec fechada.

## Nova evidência

Evidência que aparece no meio do loop **amplia** o contexto e pode reclassificar
o trabalho para mais rigor. Nunca para menos: um teste que passou não apaga um
defeito encontrado antes.
