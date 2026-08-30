---
name: anvil-boot
description: "Bootstrap: prepara um projeto para o anvil — injeta as diretivas no CLAUDE.md, gera .claude/rules/, monta ou adota a árvore docs/, escreve o perfil do issue tracker, propõe a rule da stack detectada e registra a guarda de merge. Rode uma vez por projeto, e de novo quando a estrutura mudar bastante."
---

# Boot

Prepara um projeto para o anvil. Roda uma vez; repetir é seguro, porque cada
passo é idempotente e nada é sobrescrito sem aviso.

**Nada é escrito sem aprovação**, exceto o bloco delimitado do `CLAUDE.md` e a
árvore vazia de `docs/`. Todo o resto — rules, perfil de tracker, rule de stack,
hook — é proposto e espera confirmação.

## 1. Vindo do mosk?

<!-- anvil-verify: allow-mosk-ops — a seção de migração precisa nomear os
     caminhos e marcadores do mosk; é o que o boot vai procurar no disco. -->

Se o projeto tem `.claude/mosk/` ou `.claude/agents/mosk-*.md`, ele roda o
antecessor. **Mostre o plano de migração e espere aprovação antes de apagar
qualquer coisa.**

Sai, porque não existe mais equivalente e ficar no disco só faz o agente
encontrar e tentar usar:

| O quê | Por quê |
|---|---|
| `.claude/agents/` | as doze personas. O anvil não tem agentes |
| `.claude/mosk/` | o core: tasks, templates, checklists, scripts, schemas |
| `.claude/skills/mosk-*` | os wrappers de agente e as skills soltas |
| `.claude/hooks/guard-spec-merge.sh` | é substituído pela versão do `anvil-docs` |

Fica, sem ser tocado:

| O quê | Por quê |
|---|---|
| `.claude/rules/` | é do projeto, não do toolkit. Só o `project.md` é revisado no passo 4, porque cita caminhos do mosk |
| `docs/` | é o trabalho. Vai para o verbo `adopt` no passo 5 |
| `.claude/settings.json` | pode ter hook do projeto. O passo 8 **mescla**, não sobrescreve |

As `tea-*` existem nos dois e são substituídas pelas do anvil, que já não
mencionam o mosk.

**No `CLAUDE.md`**, o bloco entre `<!-- MOSK:DIRECTIVES:START -->` e `END` vira o
bloco `ANVIL:DIRECTIVES` do passo 2. Substitua o bloco inteiro; não deixe os dois
convivendo, porque as regras de idioma deles são diferentes — o mosk mandava
escrever artefato em inglês, o anvil manda em pt-BR.

Diga quantos arquivos serão removidos, listando os diretórios, e **espere o
"pode ir"**.

## 2. Diretivas no CLAUDE.md

O conteúdo de [claude_boot.md](claude_boot.md) entra como **bloco delimitado**,
para poder ser atualizado depois sem estragar o que o projeto já tinha:

```
<!-- ANVIL:DIRECTIVES:START -->
… conteúdo do claude_boot.md …
<!-- ANVIL:DIRECTIVES:END -->
```

- `CLAUDE.md` não existe → crie, com o bloco marcado.
- Existe **com** os marcadores → substitua **só** o que está entre eles. Nada
  fora é tocado.
- Existe **sem** os marcadores → **acrescente** o bloco no topo, sem modificar
  uma linha do que já estava lá. Nunca reescreva nem parafraseie instrução do
  projeto.
- Existe um quase-duplicado sem marcador, de um boot antigo → **aponte e
  pergunte**. Não apague em silêncio.

Só siga adiante depois de confirmar que o bloco está lá e delimitado.

## 3. Varrer o projeto

Escopo: se o usuário tem uma mudança em vista, varra em volta dela. Senão, mapeie
o projeto inteiro em profundidade representativa.

- estrutura de diretórios até 3 níveis, fora dependência e VCS
- `README.md`, manifestos de pacote, configuração principal, `.env` de exemplo
- amostra de código de cada camada que existir: entrypoint ou rotas, serviços ou
  casos de uso, modelos ou repositórios, componentes de frontend, testes

O que você quer capturar: stack, entrypoints, camadas, comandos, integrações,
convenções, testes, dívida técnica e as pegadinhas operacionais. **Com caminho
verificado** — caminho citado de memória e errado é pior que ausente.

## 4. Rules

`.claude/rules/` é do projeto: o `/anvil-update` **nunca** toca nele. Markdown
puro, sem frontmatter.

- **`project.md`** — sempre. Propósito do sistema, stack, padrão de arquitetura e
  camadas, convenções de pasta, como rodar os testes, fluxos comuns, e as regras
  que o agente deve seguir neste projeto.
- **`anvil.md`** — sempre. A configuração resolvida: idioma de comunicação
  (default pt-BR), comando de teste, e a lista de modelos por papel que o
  `anvil-arena`, o `anvil-how` e o `anvil-architect` leem.
- **`frontend.md`** — só se houver código de frontend.

Depois, **sugira** rules adicionais, cada uma com uma linha de evidência do
código que a justifica, e **espere aprovação**: `coding-standards.md`,
`testing.md`, `migrations.md`, `permissions.md`, `deploy.md`, `api.md`.

Rule sem evidência não se sugere. Uma lista de seis sugestões genéricas ensina o
usuário a aprovar sem ler.

## 5. Documentação

Chame a Skill tool com **anvil-docs**:

- `docs/` ausente ou só com os README de domínio → verbo `scaffold`
- `docs/` com conteúdo fora dos domínios canônicos → verbo `adopt`

O `scaffold` cria **quatro** domínios, não oito: `architecture/`, `discovery/`,
`specs/` e `agents/` — os que têm skill escrevendo neles. `prd/`, `ui/`, `qa/` e
`project/` continuam canônicos, mas nascem quando alguém escrever ali. Pasta
vazia prometendo um autor que não existe ensina quem lê a ignorar a árvore.

Nunca presuma que dá para criar por cima. O `adopt` é a operação em que um
palpite errado sai caro de desfazer, e ele mostra o plano inteiro antes de mover
qualquer coisa.

## 6. Issue tracker

Chame a Skill tool com **anvil-setup**. Ele escreve `docs/agents/issue-tracker.md`
a partir do perfil que o `anvil-docs` fornece.

**É esse arquivo que faz o fluxo funcionar.** O `anvil-to-spec`, o
`anvil-to-tickets`, o `anvil-code-review` e o `anvil-wayfinder` publicam em
`docs/specs/` sem conhecer esse caminho por dentro — eles leem o perfil. Sem ele,
publicam no lugar errado e não reclamam.

## 7. Stack

Se a varredura encontrou uma stack conhecida — hoje, um `payload.config.ts` —
**proponha** a rule dela com uma linha de justificativa, e espere aprovação:

> *Achei `payload.config.ts` com adapter Postgres. Posso escrever
> `.claude/rules/payload.md` com as três ciladas de Local API, transação e loop
> de hook, mais a fronteira do que eu posso editar?*

A rule sai da skill `anvil-stack-payload`, arquivo `RULE.md`, com os `{{...}}`
preenchidos pelo que a varredura achou. **Sem** as invariantes do bench — aquelas
são decisão de produto do `/anvil-bench` e não valem para projeto comum.

## 8. Guarda de merge

Uma verificação que ninguém chama tem a força de uma prosa e o custo de um
programa. O mosk pagou por isso: uma spec dele chegou ao branch padrão ainda
aberta, com o verificador instalado, correto e nunca invocado.

1. `chmod +x .claude/hooks/guard-spec-merge.sh` — copie de `anvil-docs/scripts/`.
2. **Mescle** no `.claude/settings.json`, nunca sobrescreva; o projeto pode já
   ter hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command",
                     "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/guard-spec-merge.sh" } ] }
    ]
  }
}
```

3. **Confirme que dispara.** Passe um JSON de chamada falsa para o hook: num
   branch sem número ele sai 0; num branch de spec com ticket aberto, ou com a
   spec ainda fora de `docs/specs/archive/`, sai 2 e diz o que falta. Instalar
   sem verificar é repetir o erro que o hook existe para evitar.

Diga ao usuário que a guarda está ativa e o que ela bloqueia.

## 9. Ignorar o toolkit no git

`.claude/skills/` é conteúdo do toolkit, reinstalável por `npx degit`. Versionar
2 MB de skill de terceiro no repositório do projeto engorda o histórico, e todo
`/anvil-update` viraria um diff gigante que ninguém revisa.

Acrescente ao `.gitignore` do projeto, **sem duplicar** se já estiver lá:

```gitignore
# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil . --force`
.claude/skills/
```

O que **fica versionado**, porque é do projeto e não se reinstala:

- `.claude/rules/` — o contexto que o boot levantou deste projeto
- `.claude/anvil.lock` — diz qual versão instalar num clone novo
- `.claude/settings.json` — a configuração, incluindo o hook
- `docs/` — o trabalho

Avise que quem clonar o repositório precisa rodar o degit uma vez para ter as
skills, e que o `anvil.lock` diz o que esperar. Se o projeto preferir versionar
tudo — por CI que não roda instalação, por exemplo — **respeite e não escreva a
linha**; é decisão do projeto, não do toolkit.

## 10. Conferir o `anvil.lock`

O payload traz `.claude/anvil.lock` pronto — é dele que o `/anvil-update` calcula
os órfãos. Confirme que ele existe e bate com o que está instalado:

```bash
comm -3 <(sed -n 's/^skill: //p' .claude/anvil.lock | sort) \
        <(ls .claude/skills | sort)
```

Saída vazia: em dia. Divergência, ou arquivo ausente numa instalação antiga:
reescreva a partir do disco.

```bash
{ echo "# anvil.lock — o que esta instalacao possui."
  echo "# Derivado do payload. Nao edite a mao."
  ls .claude/skills | sed 's/^/skill: /'
} > .claude/anvil.lock
```

**Sem lock, o update não limpa órfão nenhum** — ele não tem como distinguir o que
o anvil instalou do que você escreveu, e o lado seguro é não apagar nada.

## 11. Índice e relatório

Chame o verbo `index` do `anvil-docs`.

Relate: o que foi criado, o que foi proposto e aprovado, o que foi proposto e
recusado, e o que ficou pendente. Nunca commite sozinho.
