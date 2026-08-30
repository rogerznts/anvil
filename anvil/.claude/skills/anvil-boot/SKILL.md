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

## 1. Diretivas no CLAUDE.md

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

## 2. Varrer o projeto

Escopo: se o usuário tem uma mudança em vista, varra em volta dela. Senão, mapeie
o projeto inteiro em profundidade representativa.

- estrutura de diretórios até 3 níveis, fora dependência e VCS
- `README.md`, manifestos de pacote, configuração principal, `.env` de exemplo
- amostra de código de cada camada que existir: entrypoint ou rotas, serviços ou
  casos de uso, modelos ou repositórios, componentes de frontend, testes

O que você quer capturar: stack, entrypoints, camadas, comandos, integrações,
convenções, testes, dívida técnica e as pegadinhas operacionais. **Com caminho
verificado** — caminho citado de memória e errado é pior que ausente.

## 3. Rules

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

## 4. Documentação

Chame a Skill tool com **anvil-docs**:

- `docs/` ausente ou só com os README de domínio → verbo `scaffold`
- `docs/` com conteúdo fora dos domínios canônicos → verbo `adopt`

Nunca presuma que dá para criar por cima. O `adopt` é a operação em que um
palpite errado sai caro de desfazer, e ele mostra o plano inteiro antes de mover
qualquer coisa.

## 5. Issue tracker

Chame a Skill tool com **anvil-setup**. Ele escreve `docs/agents/issue-tracker.md`
a partir do perfil que o `anvil-docs` fornece.

**É esse arquivo que faz o fluxo funcionar.** O `anvil-to-spec`, o
`anvil-to-tickets`, o `anvil-code-review` e o `anvil-wayfinder` publicam em
`docs/specs/` sem conhecer esse caminho por dentro — eles leem o perfil. Sem ele,
publicam no lugar errado e não reclamam.

## 6. Stack

Se a varredura encontrou uma stack conhecida — hoje, um `payload.config.ts` —
**proponha** a rule dela com uma linha de justificativa, e espere aprovação:

> *Achei `payload.config.ts` com adapter Postgres. Posso escrever
> `.claude/rules/payload.md` com as três ciladas de Local API, transação e loop
> de hook, mais a fronteira do que eu posso editar?*

A rule sai da skill `anvil-stack-payload`, arquivo `RULE.md`, com os `{{...}}`
preenchidos pelo que a varredura achou. **Sem** as invariantes do bench — aquelas
são decisão de produto do `/anvil-bench` e não valem para projeto comum.

## 7. Guarda de merge

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
   branch sem número ele sai 0; num branch de spec com ticket aberto sai 2 e diz
   o que falta. Instalar sem verificar é repetir o erro que o hook existe para
   evitar.

Diga ao usuário que a guarda está ativa e o que ela bloqueia.

## 8. Índice e relatório

Chame o verbo `index` do `anvil-docs`.

Relate: o que foi criado, o que foi proposto e aprovado, o que foi proposto e
recusado, e o que ficou pendente. Nunca commite sozinho.
