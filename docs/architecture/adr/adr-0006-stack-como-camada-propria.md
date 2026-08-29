# ADR-0006 — Stack é camada própria, com contrato de seis capacidades

- Status: aceito
- Data: 2026-08-28

## Contexto

No mosk, "stack" era conceito exclusivo do bench: um adapter com starter,
scripts, template de rule, comando de teste e um mapeamento. O `payload-rule-tmpl.md`
(77 l) carregava as **restrições** — INV-1..6, e a fronteira *"o LLM só edita
`src/collections/` e labels, nunca o compose"* — e nenhum ofício.

O anvil recebeu uma skill `payload` de 409 l mais 6.243 l de referência em 11
arquivos, cobrindo fields, hooks, access control, queries, adapters, endpoints e
plugins. Ela tem o **ofício** e nenhuma restrição.

São metades da mesma coisa. E três itens dentro da skill não são referência —
são armadilha:

- `payload.find({ user })` **ignora access control** por padrão; sem
  `overrideAccess: false` você escreve um bug de segurança achando que acertou
- operação aninhada em hook sem passar `req` **quebra a atomicidade da transação**
- hook que dispara operação que dispara o mesmo hook → **loop infinito**

Referência se carrega quando você *sabe* que precisa dela. Nessas três se cai
**sem saber que se está perto**.

## Decisão

**A stack vira camada própria**, com três níveis separados por disciplina de
carregamento:

```
anvil-stack-payload/
├── RULE.md      SEMPRE (~60 l) — as 3 ciladas + fronteira de edição
│                + fatos do projeto (adapter, onde ficam collections, teste)
├── SKILL.md     SOB DEMANDA (409 → ~120 l) — roteador: a tabela de 30 linhas.
│                Sai Quick Start e Essential Patterns, que duplicam reference/
├── reference/   SOB DEMANDA — 11 arq, 6.243 l
└── bench/       SÓ O BENCH — INVARIANTS.md, starter/ (23 arq), 3 .sh
```

A separação que o mosk não fez: `INV-4` (*zero build local, só Docker*) e `INV-1`
(*admin sempre pt-BR com menu completo*) **não são fatos do Payload** — são
decisões de produto do bench. Um projeto Payload comum não quer nenhuma das
duas. Isolá-las é o que torna a stack utilizável fora do bench.

Um template de rule, **dois chamadores**: o `/anvil-boot` acha `payload.config.ts`
na varredura e **propõe** `.claude/rules/payload.md` aguardando aprovação; o
`/anvil-bench` gera o mesmo arquivo e **acrescenta** invariantes e alocação.

**O contrato de stack passa de cinco capacidades para seis:**

| # | Capacidade | Onde |
|---|---|---|
| 1 | Rule sempre carregada — ciladas e fronteira | `RULE.md` |
| 2 | **Ofício — como escrever certo** | `reference/` |
| 3 | Scaffold versionado | `bench/starter/` |
| 4 | Ambiente, infra, publicação | `bench/{env,infra,deploy}.sh` |
| 5 | Comando de teste | `RULE.md` + `bench/` |
| 6 | Mapeamento e invariantes do bench | `bench/INVARIANTS.md` |

A sexta — o ofício — é a que a skill nova trouxe e o mosk nunca teve. O contrato
fica registrado em `anvil-docs/STACK-CONTRACT.md`: adicionar stack é preencher
seis lacunas conhecidas, sem tocar no fluxo do bench.

## Consequências

**A favor.** A stack serve dois públicos com um investimento só: o bench e
qualquer agente trabalhando naquela tecnologia. As ciladas ficam sempre
carregadas, onde precisam estar.

**Contra.** Mais uma decisão de curadoria por skill de stack: separar o que é
armadilha do que é referência exige ler o material inteiro, e errar significa
uma rule inchada ou uma cilada escondida atrás de carga sob demanda.

**Pendência.** A origem upstream da skill `payload` precisa ser identificada e
registrada no manifesto. Sem origem rastreável ela é autoral, fica fora do sync
do [adr-0004](./adr-0004-sync-por-merge-3-way-sem-cache.md), e isso tem que
estar explícito — não implícito.

**Verificação.** Num projeto Payload com a rule ativa, pedir uma operação de
Local API em nome de um usuário e conferir que o `overrideAccess: false` aparece
**sem ninguém ter aberto o `reference/QUERIES.md`**. É o que separa rule de
referência.
