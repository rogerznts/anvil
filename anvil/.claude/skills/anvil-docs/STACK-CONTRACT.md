# Contrato de stack

Uma **stack** no anvil é uma tecnologia com adapter completo. Ela serve a
**qualquer agente** trabalhando naquela tecnologia num projeto comum.

Adicionar uma stack é preencher três lacunas conhecidas.

## As três capacidades

| # | Capacidade | Onde | Carga |
|---|---|---|---|
| 1 | **Ciladas e fronteira de edição** | `RULE.md` | **sempre** |
| 2 | **Ofício — como escrever certo** | `reference/` | sob demanda |
| 3 | Comando de teste | `RULE.md` | — |

```
anvil-stack-<nome>/
├── RULE.md              ~60 l — vira .claude/rules/<nome>.md no projeto
├── SKILL.md             ~120 l — roteador: tabela tarefa → solução → arquivo
└── reference/           o ofício, um arquivo por assunto
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

## Como a rule chega ao projeto

O `/anvil-boot` detecta a stack na varredura — para o Payload, um
`payload.config.ts` — e **propõe** `.claude/rules/<nome>.md` com uma linha de
justificativa. Espera aprovação. Nunca escreve sozinho.

`.claude/rules/` é do projeto: o `/anvil-update` nunca toca nele.

## Checklist para uma stack nova

- [ ] `RULE.md` com as ciladas reais, a fronteira do que o agente pode editar, e
      o comando de teste. Menos de ~80 linhas. O `/anvil-boot` troca a linha do
      comando por um ponteiro para a seção de verificação do `anvil.md`
- [ ] `reference/` com o ofício, um arquivo por assunto, sem duplicar a rule
- [ ] `SKILL.md` roteador: tabela tarefa → solução → arquivo. Não repete o que
      está no `reference/`
- [ ] registro no manifesto `anvil-skills.yaml`, com origem upstream se houver

Sem origem upstream rastreável, a stack é autoral e fica fora do sync. Isso
precisa estar **explícito** no manifesto, não implícito.
