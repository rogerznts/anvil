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
| `.claude/agents/mosk-*.md` | as doze personas. Só elas: o diretório fica |
| `.claude/mosk/` | o core: tasks, templates, checklists, scripts, schemas |
| `.claude/skills/mosk-*` | os wrappers de agente e as skills soltas |
| `.claude/hooks/guard-spec-merge.sh` | é substituído pela versão do `anvil-docs` |

Fica, sem ser tocado:

| O quê | Por quê |
|---|---|
| `.claude/agents/`, fora as personas | os agentes do anvil e os que o projeto escreveu |
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

- `docs/` ausente ou só com os README de domínio → verbo `scaffold`, **salvo**
  se houver `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz, ou ADR em `docs/adr/` →
  verbo `adopt`
- `docs/` com conteúdo fora dos domínios canônicos → verbo `adopt`

Confira no disco antes de escolher; qualquer linha na saída leva ao `adopt`. Sem
glob: no zsh, um `docs/adr/*` que não casa aborta o comando inteiro e esconde o
`CONTEXT.md`.

```bash
ls -d CONTEXT.md CONTEXT-MAP.md 2>/dev/null; find docs/adr -type f 2>/dev/null
```

São o glossário e os ADRs do layout antigo. O `scaffold` só olha dentro de `docs/`,
e o perfil de domínio que o passo 6 grava, `docs/agents/domain.md`, os procura no
layout do anvil: sem o `adopt`, eles ficam esquecidos, e o perfil manda seguir em
silêncio. O `adopt` já sabe para onde cada um vai.

As rules do passo 4 foram escritas antes da mudança. Se o `adopt` moveu algum
desses arquivos, as que citam o caminho antigo entram na lista de referências que
ele avisa: proponha trocar pelo caminho novo e espere aprovação.

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

## 9. Conferir o `anvil.lock`

O payload traz `.claude/anvil.lock` pronto. É dele que o `/anvil-update` calcula
os órfãos e que o passo 10 gera o bloco do `.gitignore`, por isso vem antes. O
lock tem uma linha `skill:` por skill e uma `agent:` por agente. Confira se algum
item do lock falta no disco:

```bash
comm -23 <(sed -n 's/^skill: *//p' .claude/anvil.lock | tr -d '\r' | sort) \
         <(ls .claude/skills | sort)
comm -23 <(sed -n 's/^agent: *//p' .claude/anvil.lock | tr -d '\r' | sed 's/$/.md/' | sort) \
         <(ls .claude/agents 2>/dev/null | sort)
```

- **Saída vazia** → em dia.
- **Saiu nome** — o lock dá como instalada uma skill ou um agente (`nome.md`) que
  não está no disco — ou **não há o arquivo**, numa instalação antiga →
  divergência: reescreva o lock a partir do disco.

**Skill ou agente no disco fora do lock não é divergência.** Costuma ser o que o
usuário escreveu, e não entra no lock: o que está no lock é tratado como do anvil
— o update o apaga como órfão, e o bloco do `.gitignore` o ignora.

Por isso, antes de reescrever, mostre **todas** as skills de `.claude/skills/` e
todos os agentes de `.claude/agents/`, inclusive os que o lock lista, e **pergunte
quais não vieram do anvil**. Os que estão fora do lock atual são os candidatos
mais prováveis, mas não os únicos: um boot antigo reescrevia o lock a partir do
disco, e pode ter posto ali uma skill do usuário. Nada do usuário volta ao lock
sem ter sido perguntado. Os que não vieram do anvil entram em `USER_SKILLS` e
`USER_AGENTS` e ficam fora:

```bash
USER_SKILLS="minha-skill outra-skill"   # skills que não vieram do anvil; vazio se nenhuma
USER_AGENTS="meu-agente"                # agentes que não vieram do anvil, sem o .md; vazio se nenhum
{ echo "# anvil.lock — o que esta instalacao possui."
  echo "# Derivado do payload. Nao edite a mao."
  ls .claude/skills | while read -r s; do
    case " $USER_SKILLS " in *" $s "*) ;; *) echo "skill: $s" ;; esac
  done
  ls .claude/agents 2>/dev/null | sed -n 's/\.md$//p' | while read -r a; do
    case " $USER_AGENTS " in *" $a "*) ;; *) echo "agent: $a" ;; esac
  done
} > .claude/anvil.lock
```

**Sem lock, o update não limpa órfão nenhum** — ele não tem como distinguir o que
o anvil instalou do que você escreveu, e o lado seguro é não apagar nada.

## 10. Ignorar o toolkit no git

As skills e os agentes que o anvil instalou são conteúdo do toolkit,
reinstalável por `npx degit`. Versionar 2 MB de skill de terceiro no repositório do projeto engorda
o histórico, e todo `/anvil-update` viraria um diff gigante que ninguém revisa.

Mas `.claude/skills/` e `.claude/agents/` não são só do anvil: a skill ou o agente
que o usuário escreve ali é do projeto e continua versionado. Por isso o
`.gitignore` ganha um bloco com **uma linha por skill e por agente do
`.claude/anvil.lock`**, nunca por prefixo — as `tea-*` não seguem o padrão de nome:

```gitignore
# ANVIL:INSTALLED:START
# Gerado do .claude/anvil.lock. Nao edite: o proximo update reescreve.
.claude/skills/anvil-architect/
…
.claude/skills/tea-commit/
.claude/agents/{agente}.md
# ANVIL:INSTALLED:END
```

O bloco sai do lock que o passo 9 conferiu. Veja o que o script vai escrever:

```bash
bash .claude/skills/anvil-update/scripts/reset-install.sh --gitignore-only --dry-run --to .
```

**Antes de tudo, alguma dessas não veio do anvil?** Com o lock em dia, o passo 9
não pega a skill do usuário que já está dentro dele — um boot antigo reescrevia o
lock do disco com ela junto. Mostre as skills e os agentes que o bloco vai ignorar
e **pergunte se algum não veio do anvil**; se o passo 9 acabou de reescrever o lock
com essa pergunta, não repita. Se algum não veio, ele sai do lock pela reescrita
do passo 9, com `USER_SKILLS` e `USER_AGENTS` levando tudo que não veio do anvil —
esse e os que já estavam fora do lock. **Nunca edite o lock à mão.** Rode o dry-run
de novo: o bloco sai sem ele.

**Depois, a linha antiga.** Um boot anterior ignorava `.claude/skills/` inteiro,
com um comentário exato em cima — em duas versões, com e sem o `--force`. Procure
pelas duas, e pelo início do bloco. O `awk` tira do fim de cada linha o espaço, o
tab e o `\r` de um `.gitignore` com CRLF, como o script faz, porque o `grep -x`
não casaria com eles:

```bash
awk '{ sub(/[ \t\r]+$/, "") } 1' .gitignore | grep -nxF -A1 \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil . --force`' \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil .`' \
  -e '# ANVIL:INSTALLED:START'
```

- **Achou um dos comentários, e a linha seguinte é `.claude/skills/`** → foi o
  boot que escreveu. Mostre o antes (as duas linhas) e o depois (o bloco do
  dry-run) e **espere aprovação**. Ela vale para a troca e para o bloco juntos:
  não pergunte do bloco de novo, porque um "não" ali deixaria um par de
  marcadores vazio. Aprovado:
  - a busca **não achou** `# ANVIL:INSTALLED:START` → troque as duas linhas
    por `# ANVIL:INSTALLED:START` e `# ANVIL:INSTALLED:END`; o script preenche o
    bloco no lugar;
  - a busca **achou** o início do bloco — um boot anterior o escreveu, com a troca
    recusada → **só apague as duas linhas**. Trocá-las por marcadores daria um
    segundo par, e o script para com erro.

  Faça a troca com o comando, não com edição à mão: cada linha mantém o fim de
  linha que tinha, `\r` inclusive, e o `.gitignore` mantém as permissões.

  ```bash
  LINE=2        # o número do comentário, que a busca mostrou antes do ":"
  HAS_BLOCK=0   # 1 se a busca achou # ANVIL:INSTALLED:START; senão, 0
  awk -v n="$LINE" -v has="$HAS_BLOCK" '
      { cr = sub(/\r$/, "") ? "\r" : "" }
      NR == n     { if (!has) print "# ANVIL:INSTALLED:START" cr; next }
      NR == n + 1 { if (!has) print "# ANVIL:INSTALLED:END" cr; next }
      { print $0 cr }' .gitignore > .gitignore.anvil &&
  cat .gitignore.anvil > .gitignore && rm .gitignore.anvil
  ```

  Recusado → as duas linhas ficam. Avise que elas continuam ignorando todo o
  `.claude/skills/`, a skill do usuário inclusive, e pergunte do bloco à parte.
- **Não achou nenhum dos comentários** → não toque em linha nenhuma que ignore
  `.claude/skills/`, mesmo parecida. Foi o usuário que escreveu. Avise que ela
  continua ignorando as skills que ele escrever ali, e pergunte do bloco.

**Por fim, o bloco.** Com a aprovação, grave:

```bash
bash .claude/skills/anvil-update/scripts/reset-install.sh --gitignore-only --to .
```

O script lê o lock e reescreve **só o bloco**: substitui entre os marcadores se
eles existem, acrescenta no fim se não. Rodar de novo não muda nada, e o
`/anvil-update` regenera o bloco a cada reinstalação.

O que **fica versionado**, porque é do projeto e não se reinstala:

- `.claude/rules/` — o contexto que o boot levantou deste projeto
- `.claude/anvil.lock` — diz qual versão instalar num clone novo
- `.claude/settings.json` — a configuração, incluindo o hook
- `docs/` — o trabalho

Avise que quem clonar o repositório precisa rodar o degit uma vez para ter as
skills, e que o `anvil.lock` diz o que esperar. Se o projeto preferir versionar
tudo — por CI que não roda instalação, por exemplo — **respeite e não escreva o
bloco**; é decisão do projeto, não do toolkit. Sem o bloco, o update também não o
cria.

## 11. Índice e relatório

Chame o verbo `index` do `anvil-docs`.

Relate: o que foi criado, o que foi proposto e aprovado, o que foi proposto e
recusado, e o que ficou pendente. Nunca commite sozinho.
