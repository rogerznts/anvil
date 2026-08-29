# Contrato de stack

Uma **stack** no anvil é uma tecnologia com adapter completo. Ela serve dois
consumidores com um investimento só: o `/anvil-bench`, que constrói ferramentas
para leigos, e **qualquer agente** trabalhando naquela tecnologia num projeto
comum.

Adicionar uma stack é preencher seis lacunas conhecidas. O fluxo do bench não
muda.

## As seis capacidades

| # | Capacidade | Onde | Carga |
|---|---|---|---|
| 1 | **Ciladas e fronteira de edição** | `RULE.md` | **sempre** |
| 2 | **Ofício — como escrever certo** | `reference/` | sob demanda |
| 3 | Scaffold versionado | `bench/starter/` | só o bench |
| 4 | Ambiente, infra, publicação | `bench/{env,infra,deploy}.sh` | só o bench |
| 5 | Comando de teste | `RULE.md` + `bench/` | — |
| 6 | Invariantes e mapeamento do bench | `bench/INVARIANTS.md` | só o bench |

```
anvil-stack-<nome>/
├── RULE.md              ~60 l — vira .claude/rules/<nome>.md no projeto
├── SKILL.md             ~120 l — roteador: tabela tarefa → solução → arquivo
├── reference/           o ofício, um arquivo por assunto
└── bench/
    ├── INVARIANTS.md
    ├── starter/
    └── {env,infra,deploy}.sh
```

## A separação que decide tudo: rule ou reference?

Não é sobre tamanho nem importância. É sobre **quando você precisa da informação**.

**Reference** você carrega quando *sabe* que precisa. Abre o arquivo de access
control quando está pensando em access control.

**Rule** é a armadilha em que se cai **sem saber que se está perto dela**. No
Payload, `payload.find({ user })` ignora access control por padrão: sem
`overrideAccess: false` você escreve um bug de segurança achando que acertou. Não
adianta estar documentado em `QUERIES.md` — quem cai nessa não foi consultar
`QUERIES.md`.

O teste: *se a pessoa não abrir a referência, ela erra?* Se sim, é rule.

Uma `RULE.md` de sessenta linhas com três ciladas verdadeiras vale mais que uma
de trezentas com tudo que é importante. O que enche a rule deixa de ser lido.

## A outra separação: o que é da tecnologia e o que é do bench

O mosk misturava as duas num arquivo só, e isso prendia a stack ao bench.

- **Da tecnologia** — `overrideAccess: false`, `req` em operação aninhada,
  contexto anti-loop em hook. Vale para qualquer projeto Payload.
- **Do bench** — *admin sempre em pt-BR com menu completo*, *zero build local, só
  Docker*, *todo módulo é uma collection*. São decisões de produto de uma
  ferramenta para leigos, não fatos do Payload. Projeto comum não quer nenhuma.

O que é do bench mora em `bench/INVARIANTS.md` e **não entra na rule** de um
projeto comum.

## Como a rule chega ao projeto

Um template, dois chamadores:

- **`/anvil-boot`** detecta a stack na varredura — para o Payload, um
  `payload.config.ts` — e **propõe** `.claude/rules/<nome>.md` com uma linha de
  justificativa. Espera aprovação. Nunca escreve sozinho.
- **`/anvil-bench`** gera o mesmo arquivo e **acrescenta** a seção de invariantes
  e a alocação concreta do projeto.

`.claude/rules/` é do projeto: o `/anvil-update` nunca toca nele.

## Checklist para uma stack nova

- [ ] `RULE.md` com as ciladas reais, a fronteira do que o agente pode editar, e
      o comando de teste. Menos de ~80 linhas.
- [ ] `reference/` com o ofício, um arquivo por assunto, sem duplicar a rule
- [ ] `SKILL.md` roteador: tabela tarefa → solução → arquivo. Não repete o que
      está no `reference/`
- [ ] `bench/starter/` versionado, copiado sem regenerar
- [ ] `bench/{env,infra,deploy}.sh` idempotentes, com `--help` e `--dry-run`
- [ ] `bench/INVARIANTS.md` com o que é decisão de produto do bench
- [ ] registro no manifesto `anvil-skills.yaml`, com origem upstream se houver

Sem origem upstream rastreável, a stack é autoral e fica fora do sync. Isso
precisa estar **explícito** no manifesto, não implícito.
