---
name: anvil-boot
description: "Bootstrap: prepara um projeto para o anvil — garante a instalação de usuário do toolkit, gera .claude/rules/, monta ou adota a árvore docs/, escreve o perfil do issue tracker, propõe a rule da stack detectada e registra a guarda de merge. Rode uma vez por projeto, e de novo quando a estrutura mudar bastante."
---

# Boot

Prepara um projeto para o anvil. Roda uma vez; repetir é seguro, porque cada
passo é idempotente e nada é sobrescrito sem aviso.

O toolkit não é copiado para o projeto: ele mora na instalação de usuário, que
vale para todos os projetos da máquina e que o passo 2 garante. O projeto recebe
o que é dele — `.claude/rules/`, os perfis em `docs/agents/` e a árvore de
`docs/` —, além da guarda de merge do passo 8.

**Nada é escrito sem aprovação**, exceto a árvore vazia de `docs/`. Todo o resto
— instalação de usuário, rules, perfil de tracker, rule de stack, hook — é
proposto e espera confirmação.

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
| `.claude/skills/tea-*` | as cópias do mosk. As do anvil vêm da instalação de usuário, e a cópia do mosk no projeto as sombrearia no omp |
| `.claude/hooks/guard-spec-merge.sh` | é substituído pela versão do `anvil-docs` |

Fica, sem ser tocado:

| O quê | Por quê |
|---|---|
| `.claude/agents/`, fora as personas | os agentes que o projeto escreveu |
| `.claude/rules/` | é do projeto, não do toolkit. Só o `project.md` é revisado no passo 4, porque cita caminhos do mosk |
| `docs/` | é o trabalho. O passo 5 chama o `anvil-docs`, que escolhe entre `scaffold` e `adopt` |
| `.claude/settings.json` | pode ter hook do projeto. O passo 8 **mescla**, não sobrescreve |

**No `CLAUDE.md`**, o bloco entre `<!-- MOSK:DIRECTIVES:START -->` e `END` sai
inteiro, e nada entra no lugar: as diretivas do anvil chegam pela instalação de
usuário do passo 2, não pelo `CLAUDE.md` do projeto. Não deixe o bloco do mosk,
porque as regras de idioma são diferentes — o mosk mandava escrever artefato em
inglês, o anvil manda em pt-BR.

Diga quantos arquivos serão removidos, listando os diretórios, e **espere o
"pode ir"**.

## 2. Instalação de usuário

O toolkit — skills, agentes, lock, o espelho `~/.agents/skills`, a camada omp e as
diretivas — mora no diretório do usuário. O boot garante que ele está lá:

```bash
if [ -f ~/.claude/anvil.lock ]; then
    echo "instalação de usuário presente; para trocar de versão, rode /anvil-update"
else
    TMP="$(mktemp -d)"
    npx degit rogerznts/anvil/anvil "$TMP"
    bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --dry-run --from "$TMP"
fi
```

- **Com instalação** → siga para o passo 3, sem tocar nela. Diga que a versão
  instalada fica como está e que quem troca de versão é o `/anvil-update`.
- **Sem instalação** → o dry-run lista por nome o que entra em `~/.claude/`,
  `~/.agents/skills/` e `~/.omp/agent/`, o que já estava lá e fica, e as
  colisões: skill ou agente seu com o nome de um do payload, que **será
  sobrescrito**. Diga isso numa frase, nomeando as colisões, e **espere
  aprovação**. Então instale:

```bash
bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP"
rm -rf "$TMP"
```

A instalação põe as diretivas no `~/.claude/CLAUDE.md`, entre os marcadores
`ANVIL:DIRECTIVES`, sem tocar o que está fora deles, e, com a camada omp, na rule
`~/.omp/agent/rules/anvil-directives.md`. **O `CLAUDE.md` do projeto não recebe
bloco**: o que o projeto já tinha nele fica como estava.

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
  (default pt-BR), comando de teste, a lista de modelos por papel que o
  `anvil-arena`, o `anvil-how` e o `anvil-architect` leem, e a seção de
  instalação, para quem clona o projeto.
- **`frontend.md`** — só se houver código de frontend.

A seção de modelos do `anvil.md`:

```markdown
## Modelos por papel

Lidos por `anvil-arena`, `anvil-how` e `anvil-architect`.

- `runners`: `opus`, `fable`, `sonnet`
- `how-explorer`: `sonnet`
- `how-explainer`: `opus`
- `cross-judge`: `opus`, `fable`, `sonnet`
```

A seção de instalação do `anvil.md`. O toolkit não vem no clone, e quem clona sem
ter o anvil na máquina precisa saber disso antes de achar que o projeto está
quebrado:

```markdown
## Instalação do anvil

O toolkit do anvil não vem no clone. Ele é instalado uma vez por usuário — em
`~/.claude/`, `~/.agents/skills/` e `~/.omp/agent/` — e vale para todos os
projetos da máquina; o projeto guarda só `.claude/rules/` e `docs/`. Sem a
instalação, as skills e as diretivas do anvil não existem na sessão. Para
instalar, de qualquer diretório:

    TMP="$(mktemp -d)" && npx degit rogerznts/anvil/anvil "$TMP"
    bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --dry-run --from "$TMP"
    bash "$TMP/.claude/skills/anvil-update/scripts/reset-install.sh" --from "$TMP"

O segundo comando mostra o que entra e o que fica; o terceiro instala. Para
trocar de versão depois, rode `/anvil-update`.
```

Num `anvil.md` que já existe sem a lista de modelos ou sem a seção de instalação,
proponha acrescentá-las; valor já configurado não se troca.

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
`~/.claude/skills/anvil-docs/templates/verification-anvil.md`, da instalação de
usuário. Ausente → copie.
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

## 9. O `.gitignore` de uma versão antiga

**Nada é escrito no `.gitignore`.** O toolkit não mora no projeto, e o que o
projeto tem em `.claude/` — rules, settings e as skills que ele mesmo escreveu — é
versionado como o resto. Não pergunte o que ignorar.

**Num projeto bootado por uma versão antiga, o `.gitignore` ainda ignora
`.claude/skills/`**, de duas formas: um bloco `ANVIL:INSTALLED`, ou uma linha que
cobre `.claude/skills/` inteiro, com um comentário exato em cima — em duas
versões, com e sem o `--force`. Procure as três. O `awk` tira do fim de cada linha
o espaço, o tab e o `\r` de um `.gitignore` com CRLF, porque o `grep -x` não
casaria com eles:

```bash
awk '{ sub(/[ \t\r]+$/, "") } 1' .gitignore | grep -nxF -A1 \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil . --force`' \
  -e '# anvil — o toolkit se reinstala com `npx degit rogerznts/anvil/anvil .`' \
  -e '# ANVIL:INSTALLED:START'
```

Achou alguma delas → mostre o que sairia e **espere aprovação**; é o `.gitignore`
do projeto, e tirar as linhas faz o que está em `.claude/skills/` aparecer no
`git status`.

- **O bloco.** Veja o que sai e, com a aprovação, tire:

  ```bash
  bash ~/.claude/skills/anvil-update/scripts/reset-install.sh --unignore --dry-run --to .
  bash ~/.claude/skills/anvil-update/scripts/reset-install.sh --unignore --to .
  ```

  Rodar de novo não muda nada.

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
  escreveu. Avise que ela continua ignorando a skill que ele escrever em
  `.claude/skills/`, e que tirá-la é decisão dele.

## 10. Índice e relatório

Chame o verbo `index` do `anvil-docs`.

Relate: a instalação de usuário, feita agora ou já presente; o que foi criado, o
que foi proposto e aprovado, o que foi proposto e recusado, e o que ficou
pendente. Nunca commite sozinho.
