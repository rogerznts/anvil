# Checklist — o critério de pronto, e como ele vira gate

O `checklist.yaml` é a última pergunta da entrevista escrita em arquivo: **como a
pessoa vai saber que está funcionando.** Ele nasce na fase 3, é congelado na fase
4, e é dele que saem os testes e o ledger.

Formato mínimo de propósito. Cada campo a mais é um campo que alguém tem que
manter sincronizado com a conversa, e a conversa é a fonte.

## O arquivo

`docs/specs/{id}/checklist.yaml`

```yaml
# O critério de pronto, na fala de quem pediu. Vira gates.md na fase 4.
version: 1
items:
  - id: C1
    module: contratos
    outcome: "cadastrar um contrato com número, cliente, valor e vencimento"
    check: "pnpm vitest run tests/contratos.test.ts"

  - id: C2
    module: contratos
    outcome: "quem não é do financeiro não enxerga o valor do contrato"
    check: "pnpm vitest run tests/permissoes.test.ts"

  - id: C3
    module: avisos
    outcome: "o aviso de vencimento fala com as palavras que a empresa usa"
    note: "confirmar com quem pediu, na entrega"
```

| campo | obrigatório | o que é |
|---|---|---|
| `id` | sim | `C` + número, na ordem em que a pessoa falou |
| `outcome` | sim | uma frase, em português simples: o que passa a ser possível |
| `check` | não | o comando que observa esse resultado, escrito como ele roda **dentro do container** — é lá que o checker executa. Ausente = item manual |
| `module` | não | o módulo a que pertence, quando ajuda a nomear o teste |
| `note` | não | como se confirma à mão, nos itens manuais |

**O id nunca é reusado nem renumerado.** Item que a pessoa desistiu sai da lista
e o número morre com ele; item novo pega o próximo. É o que faz `C3` significar a
mesma coisa na volta 1 e na volta 3, tanto no ledger quanto no `top_issues` do
`gate.yaml` — a série só é legível porque o id é estável.

**`outcome` é resultado, nunca tarefa.** "criar a collection de contratos" é
trabalho seu e não se observa de fora; "cadastrar um contrato e vê-lo na lista" é
o que a pessoa consegue fazer depois. Se a frase não sobrevive à pergunta *"como
eu veria isso acontecer?"*, ela ainda é tarefa.

**Nada de estado aqui.** Sem `status`, sem `feito`, sem data. Quem sabe se está
pronto é a reexecução do ledger; um segundo lugar guardando a mesma resposta é um
lugar a mais para mentir.

## A conversão para o ledger

Um item, um gate. `id` e `outcome` atravessam sem tradução — o gate é lido por
quem escreveu o checklist:

```markdown
- [ ] C1: cadastrar um contrato com número, cliente, valor e vencimento
  CHECK: pnpm vitest run tests/contratos.test.ts
  EXPECT: CHECKLIST_C1_OK
  EVIDENCE: pending

- [ ] C3: o aviso de vencimento fala com as palavras que a empresa usa
  EVIDENCE: pending
```

**O marcador é `CHECKLIST_<id>_OK`, e quem o imprime é o teste** — a última linha
que `tests/contratos.test.ts` executa, depois do último assert. É por isso que a
fase 4 deriva os testes antes de escrever o ledger: o marcador nasce dentro
deles.

Duas armadilhas, nesta ordem, e as duas medidas contra o checker:

**Não use o vocabulário do runner.** Um `EXPECT: passed` casa em
`0 passed | 3 skipped`, que sai zero. A suíte quebrada o código de saída pega
sozinho — o gate exige `exit 0` **e** o `EXPECT` —, mas a suíte que não reprovou
porque não rodou passa direto. O linter acusa isso antes, com `weak-expect`.

**E não imprima o marcador pelo shell.** `pnpm vitest run … && echo CHECKLIST_C1_OK`
parece a mesma coisa e não é: o `&&` só repete o código de saída que o gate já
exigia, então a suíte pulada dispara o `echo` e o gate certifica que nada
aconteceu. Impresso de dentro do teste, o marcador não sai quando o arquivo
sumiu, quando o filtro não casou nada ou quando tudo foi pulado — e aí o `EXPECT`
não casa, que é o desfecho certo.

Vale a mesma regra para número: nunca escreva `EXPECT: 12 contratos`. Número
copiado do briefing é a expectativa provando a si mesma. Faça o teste calcular,
aplicar o critério, e só então imprimir o marcador.

**Item sem `check` vira gate manual** — sem `CHECK:`, sem `EXPECT:`. O linter vai
avisar, e o aviso está certo: a evidência de um gate manual vale o que vale quem
leu. Ele entra na entrega como pendência declarada, na linguagem da fase 6. Não
invente comando para fingir cobertura; um gate que não consegue reprovar é pior
que um gate ausente, porque parece prova.

Antes de construir, rode o linter sobre o ledger — ele acha o gate incapaz de
falhar. O comando está na fase 4 do [SKILL.md](SKILL.md); a reexecução que decide
o veredito está em [GATE.md](GATE.md).

## Evoluir uma ferramenta

A spec nova é aditiva, e o checklist dela também: os itens anteriores continuam
valendo, com os mesmos ids, e os novos seguem a numeração. O ledger da volta nova
carrega os dois conjuntos — é assim que a regressão inteira roda, velha e nova
junto, como a fase *Evoluir* exige.
