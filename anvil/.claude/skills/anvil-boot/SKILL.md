---
name: anvil-boot
description: "Bootstrap: prepara um projeto para o anvil — injeta as diretivas no CLAUDE.md, gera .claude/rules/, monta ou adota a árvore docs/, escreve o perfil do issue tracker, propõe a rule da stack detectada e registra a guarda de merge. Rode uma vez por projeto, e de novo quando a estrutura mudar bastante."
---

# Boot

Prepara um projeto para o anvil. Roda uma vez; repetir é seguro, porque cada
passo é idempotente e nada é sobrescrito sem aviso.

**Nada é escrito sem aprovação**, exceto o bloco delimitado do `CLAUDE.md` e a
árvore vazia de `docs/`. Todo o resto — rules, perfil de tracker, rule de stack,
`.gitattributes`, hook — é proposto e espera confirmação.

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
| `docs/` | é o trabalho. O passo 5 chama o `anvil-docs`, que escolhe entre `scaffold` e `adopt` |
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

### Arquivo gerado fora do diff

A revisão lê `git diff`. Arquivo gerado e versionado entra nele inteiro, sem uma
linha revisável: snapshot de migration, saída de codegen, lockfile. Num projeto
com migrations, cada snapshot tem o tamanho do schema inteiro, e o seguinte é
maior que o anterior. Ele cresce a cada spec e ocupa o que a revisão deveria
gastar no código.

Procure os gerados versionados por convenção (diretório de snapshot de
migration, arquivo de tipos gerado, `*.generated.*`, `__generated__/`) e por
marca no próprio arquivo (`@generated`, `DO NOT EDIT`). Meça o peso de cada um no
histórico recente:

```bash
git log -n 50 --numstat --format= | awk '$1 != "-" {
  l[$3] += $1 + $2; t += $1 + $2 }
  END { for (f in l) printf "%d\t%.0f%%\t%s\n", l[f], 100 * l[f] / t, f }' |
  sort -rn | head -20
```

**Achado relevante** é quando os gerados somam uma fatia que a revisão sentiria:
algo como 20% das linhas mudadas, ou um arquivo que cresce a cada migration. O
número é arbitrário; o ponto é a evidência. Sem achado relevante, não proponha
nada.

Com achado, mostre a lista (arquivo, linhas no histórico, proporção) e proponha
uma linha por padrão:

```gitattributes
src/migrations/*.json -diff linguist-generated=true
```

- **Espere aprovação.** Um `.gitattributes` que já existe se **mescla**: só
  entram as linhas que faltam, e as do projeto não se tocam.
- **Diga que é apresentação, não conteúdo.** O arquivo continua versionado e no
  `git add`, e o que depende dele segue funcionando. Para vê-lo:
  `git diff --text -- <arquivo>`.
- **O arquivo escrito à mão ao lado do gerado continua no diff.** O padrão pega o
  snapshot, não a migration que a pessoa escreveu. Confira isso antes de propor.
- **Lockfile é proposta separada.** Tirá-lo do diff esconde troca de dependência,
  e isso é decisão do projeto, não do boot.

Nada muda no `anvil-code-review`: o `git diff` que ele captura já respeita o
atributo.

## 4. Rules

`.claude/rules/` é do projeto: o `/anvil-update` **nunca** toca nele. Markdown
puro, sem frontmatter.

- **`project.md`** — sempre. Propósito do sistema, stack, padrão de arquitetura e
  camadas, convenções de pasta, como rodar os testes, fluxos comuns, e as regras
  que o agente deve seguir neste projeto.
- **`anvil.md`** — sempre. A configuração resolvida: idioma de comunicação
  (default pt-BR), comando de teste com o custo medido, e a lista de modelos por
  papel que o `anvil-arena`, o `anvil-how` e o `anvil-architect` leem.
- **`frontend.md`** — só se houver código de frontend.

A seção de modelos do `anvil.md`:

```markdown
## Modelos por papel

Lidos por `anvil-arena`, `anvil-how` e `anvil-architect`.

- `runners`: `opus`, `fable`, `sonnet`
- `how-critics`: `opus`, `fable`, `sonnet`
- `cross-judge`: `opus`, `fable`, `sonnet`
```

Num `anvil.md` que já existe sem a lista, proponha acrescentá-la; valor já
configurado não se troca.

### O custo da verificação

O comando de teste vai no `anvil.md` **com o custo medido**. É esse número que
decide quantas vezes a suíte roda durante um ticket. Um número errado faz rodar a
suíte inteira a cada conferida, *porque é rápida*, ou pular a verificação,
*porque é lenta*. Os dois erros vêm do dado, não da disciplina.

**Meça, não estime.** Peça para rodar o comando uma vez: rodar a suíte pode levar
minutos e mexer em banco de teste. Rode em background e cronometre. Com o tempo
em mãos, a seção fica assim:

~~~markdown
## Comando de verificação

```bash
pnpm test
```

Custo medido: 3min12s, em 2026-09-23, numa máquina Linux de 16 CPUs.

Quem medir diferente corrige este arquivo no mesmo commit. O critério de quando
rodar a suíte está em `docs/agents/verification.md`.
~~~

- **O comando não roda** (falta banco, dependência ou serviço) → grave o comando
  sem custo, com o motivo numa linha. Número estimado não se grava: é o defeito
  que esta seção existe para evitar.
- **Recusado** → grave o comando sem custo e diga que ele ficou sem medição.

**O custo mora só aqui.** O `project.md` diz *como* rodar os testes; quando falar
de custo, aponta para o `anvil.md`. Número repetido em dois arquivos diverge no
primeiro que alguém atualizar e esquecer o outro.

Quando o projeto adotar o laço curto do perfil de verificação, a seção passa a ter
dois comandos, cada um com o seu custo, nos termos do perfil:

```markdown
- `laço`: `pnpm test:ticket`. Custo medido: 1min10s, em 2026-09-23.
- `gate`: `pnpm test && npx tsc --noEmit`. Custo medido: 16min, em 2026-09-23.
```

O boot não propõe essa divisão. Ela se adota quando o laço passar de ~2 min, e o
perfil diz por quê.

**Num `anvil.md` que já existe**, o comando configurado não se troca.

- **Sem custo** → proponha medir e acrescentar, e espere aprovação.
- **Com custo, e o medido difere** → mostre os dois, com a data de cada um, e
  espere aprovação para trocar.
- **Custo repetido fora do `anvil.md`** → procure tempo de teste em `CLAUDE.md` e
  nas outras rules. Aponte cada ocorrência, com arquivo e linha, e proponha
  trocá-la por um ponteiro para o `anvil.md`. Não edite sozinho: fora do bloco
  delimitado, o `CLAUDE.md` é do projeto.

Depois, **sugira** rules adicionais, cada uma com uma linha de evidência do
código que a justifica, e **espere aprovação**: `coding-standards.md`,
`testing.md`, `migrations.md`, `permissions.md`, `deploy.md`, `api.md`.

Rule sem evidência não se sugere. Uma lista de seis sugestões genéricas ensina o
usuário a aprovar sem ler.

## 5. Documentação

Chame a Skill tool com **anvil-docs**, sem verbo. Quem escolhe entre `scaffold` e
`adopt` é a regra "Sem verbo explícito" dele, que olha também o glossário e os
ADRs do layout antigo, fora de `docs/`.

As rules do passo 4 foram escritas antes da movimentação do `adopt`. Se ele moveu
glossário ou ADR, as rules que citam o caminho antigo entram na lista de
referências que ele avisa: proponha trocar pelo caminho novo e espere aprovação.

## 6. Issue tracker

Chame a Skill tool com **anvil-setup**. Ele escreve `docs/agents/issue-tracker.md`
a partir do perfil que o `anvil-docs` fornece.

**É esse arquivo que faz o fluxo funcionar.** O `anvil-to-spec`, o
`anvil-to-tickets`, o `anvil-code-review` e o `anvil-wayfinder` publicam em
`docs/specs/` sem conhecer esse caminho por dentro — eles leem o perfil. Sem ele,
publicam no lugar errado e não reclamam.

Confirme que o passo de documentação deixou
`docs/agents/verification.md` igual a
`.claude/skills/anvil-docs/templates/verification-anvil.md`. Ausente → copie.
Idêntico → siga sem perguntar. Divergente → mostre o diff e espere aprovação;
**nunca sobrescreva** o perfil que o projeto pode ter ajustado. É dele que o
`anvil-code-review` tira classe, orçamento e escopo diff-only; sem ele, o critério
que se instala sozinho é "nenhum achado aberto".

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
os órfãos. O lock tem uma linha `skill:` por skill e uma `agent:` por agente.
Confira se algum
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
usuário escreveu, e não entra no lock: o que está no lock é tratado como do anvil,
e o update o apaga como órfão.

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

## 10. O toolkit fica versionado

**Nada é escrito no `.gitignore`.** O que o degit instalou — `.claude/skills/`,
`.claude/agents/` e o `.claude/anvil.lock` — é versionado como o resto do projeto,
junto com `.claude/rules/`, `.claude/settings.json` e `docs/`. Não pergunte o que
ignorar, e não ofereça tirar o toolkit do repositório.

A razão é a reprodutibilidade: quem clona o repositório tem o toolkit na versão em
que o projeto foi trabalhado, sem rodar instalação nenhuma, e o diff de um
`/anvil-update` é a revisão do que mudou.

**Num projeto instalado por uma versão antiga, o toolkit está ignorado**, de duas
formas: um bloco `ANVIL:INSTALLED`, ou uma linha que cobre `.claude/skills/`
inteiro, com um comentário exato em cima — em duas versões, com e sem o `--force`.
Procure as três. O `awk` tira do fim de cada linha o espaço, o tab e o `\r` de um
`.gitignore` com CRLF, porque o `grep -x` não casaria com eles:

```bash
awk '{ sub(/[ \t\r]+$/, "") } 1' .gitignore | grep -nxF -A1 \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil . --force`' \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil .`' \
  -e '# ANVIL:INSTALLED:START'
```

Achou alguma delas → mostre o que sairia e **espere aprovação**; é o `.gitignore`
do projeto, e tirar as linhas faz as skills instaladas aparecerem no `git status`.

- **O bloco.** Veja o que sai e, com a aprovação, tire:

  ```bash
  bash .claude/skills/anvil-update/scripts/reset-install.sh --unignore --dry-run --to .
  bash .claude/skills/anvil-update/scripts/reset-install.sh --unignore --to .
  ```

  Rodar de novo não muda nada, e o `/anvil-update` remove o bloco sozinho na
  reinstalação.

- **A linha antiga**, quando o comentário do boot está em cima dela. Apague as
  duas com o comando, não à mão: cada linha mantém o fim de linha que tinha, `\r`
  inclusive, e o `.gitignore` mantém as permissões.

  ```bash
  LINE=2   # o número do comentário, que a busca mostrou antes do ":"
  awk -v n="$LINE" '
      { cr = sub(/\r$/, "") ? "\r" : "" }
      NR == n || NR == n + 1 { next }
      { print $0 cr }' .gitignore > .gitignore.anvil &&
  cat .gitignore.anvil > .gitignore && rm .gitignore.anvil
  ```

  Recusado → as duas linhas ficam. Avise que elas continuam ignorando todo o
  `.claude/skills/`, a skill do usuário inclusive.

- **Linha parecida sem esse comentário** → não toque nela. Foi o usuário que
  escreveu. Avise que ela continua ignorando o toolkit e a skill que ele escrever
  ali, e que tirá-la é decisão dele.

## 11. Índice e relatório

Chame o verbo `index` do `anvil-docs`.

Relate: o que foi criado, o que foi proposto e aprovado, o que foi proposto e
recusado, e o que ficou pendente. Nunca commite sozinho.
