# ADR-0013 — O toolkit é instalado uma vez por usuário

- Status: aceito
- Data: 2026-10-14
- Revoga o [ADR-0009](./adr-0009-toolkit-instalado-fica-versionado.md): o toolkit deixa de ficar versionado no projeto
- Emenda o [ADR-0011](./adr-0011-omp-como-harness-com-camada-propria.md): a camada omp e o espelho `.agents/skills` passam à instalação de usuário, e a linha `omp:` que torna a camada pegajosa passa a ser a do lock de usuário
- Origem: spec 006 (`docs/specs/archive/006-feature-user-install-language-next/`)

## Contexto

O [ADR-0009](./adr-0009-toolkit-instalado-fica-versionado.md) pôs no git de cada
projeto tudo que o degit instala — `.claude/skills/`, `.claude/agents/` e
`.claude/anvil.lock` —, para que o clone trouxesse o toolkit exato que foi usado.
O [ADR-0011](./adr-0011-omp-como-harness-com-camada-propria.md) instalou a camada
omp em `.omp/` do projeto, pegajosa pela linha `omp:` do lock do projeto, e gerou
o espelho do Codex em `.agents/skills` do projeto.

Com o toolkit estável e rodando em vários projetos, o custo desse desenho mudou de
lado:

- **Um update por projeto.** Atualizar o anvil é rodar o `/anvil-update` em cada
  projeto, um por um, e cada projeto fica numa versão diferente até alguém lembrar
  dele.
- **O que varia entre projetos não é o toolkit.** São as rules, os perfis em
  `docs/agents/` e o resto de `docs/`. O payload, o lock, o espelho, a camada omp,
  as diretivas no `CLAUDE.md` e o hook da guarda de merge são os mesmos em todos.
- **Uma diretiva nova não chega sozinha.** O bloco `ANVIL:DIRECTIVES` vivia
  copiado no `CLAUDE.md` de cada projeto, e só mudava ali com um update naquele
  projeto.

## Decisão

**O toolkit é instalado uma vez por usuário, e o projeto fica só com o que é
dele:** `.claude/rules/`, os perfis em `docs/agents/` e o resto de `docs/`.

| Peça | Antes, no projeto | Agora, no usuário |
|---|---|---|
| Skills do payload | `.claude/skills/` | `~/.claude/skills/` |
| Agentes do payload | `.claude/agents/` | `~/.claude/agents/` |
| Lock | `.claude/anvil.lock` | `~/.claude/anvil.lock` |
| Espelho do Codex | `.agents/skills/` | `~/.agents/skills/`, um symlink `../../.claude/skills/<nome>` por skill |
| Camada omp | `.omp/{skills,rules,agents,hooks/pre}` | `~/.omp/agent/{skills,rules,agents,hooks/pre}` |
| Diretivas | bloco `ANVIL:DIRECTIVES` no `CLAUDE.md` do projeto | bloco entre os mesmos marcadores no `~/.claude/CLAUDE.md` e a rule `alwaysApply` `~/.omp/agent/rules/anvil-directives.md` |
| Guarda de merge no Claude Code | hook em `.claude/settings.json` e cópia do script | hook em `~/.claude/settings.json`, chamando o script das skills instaladas |

**Um `/anvil-update` atualiza a máquina.** Ele reinstala o usuário como reset, com
os órfãos calculados pelo lock de usuário, roda de qualquer diretório, passa por
dry-run e aprovação e nunca commita. Skill, agente e arquivo da camada fora do lock
ficam intocados. O `/anvil-boot` garante a instalação de usuário e escreve no
projeto só rules, perfis e a árvore de `docs/`.

**As diretivas saem de uma fonte só, o `claude_boot.md` do payload, para dois
lugares.** O Claude Code carrega o `~/.claude/CLAUDE.md` em toda sessão. O omp não
o lê sem opt-in, e o `~/.omp/agent/AGENTS.md`, quando existe, sombreia os arquivos
de usuário de outros harnesses; por isso, no omp, a diretiva vai como rule
`alwaysApply` da camada de usuário. Ela continua mandando ler `.claude/rules/*.md`
do projeto.

**O que muda no ADR-0011.** A camada omp entra em `~/.omp/agent/` quando há sinal
de omp — `command -v omp`, `~/.omp/` ou linha `omp:` no lock de usuário — e a
linha `omp:` do lock de usuário é o que a torna pegajosa. O payload chega ao omp
pelo espelho `~/.agents/skills`, que o provider `agents` lê por padrão, e não pelo
`~/.claude/skills`, que o omp só lê com opt-in; conferido no omp 18.10.4, onde o
espelho bastou. A guarda vale por usuário nos dois harnesses e só age em projeto
anvil, o que tem a rule `.claude/rules/anvil.md` que o boot escreve: em outro
repositório, sai sem fazer nada e sem mensagem. Os condutores, o
`anvil-implementer` e a automação só no omp não mudam.

**Projeto instalado do jeito antigo migra quando o update ou o boot roda nele.** A
migração tira do projeto o que o lock do projeto lista — skills, agentes, o próprio
lock, os symlinks do espelho com nome de skill do payload, os arquivos da camada em
`.omp/` —, a entrada do hook da guarda nas settings e a cópia do script, e o bloco
de diretivas do `CLAUDE.md`, só entre os marcadores. Sem lock, pergunta o que não
veio do anvil antes de apagar. Exige árvore limpa, para que a remoção seja um diff
revisável, e não commita.

**Na máquina de desenvolvimento do anvil, a instalação de usuário aponta para a
fonte.** O `dev-link` liga `~/.claude/skills`, os agentes, o espelho e a camada omp
ao payload do repositório, por symlink, e o `--unlink` desfaz. O `/anvil-update`
recusa instalar por cima de uma entrada do payload que, no usuário, é symlink, e
aponta o `dev-link --unlink`.

## Limitação conhecida: a cauda de roteamento no omp

A diretiva traz a cauda de roteamento: ao fim de uma lista fechada de skills, a
sessão principal invoca o `anvil-next`. No omp, a diretiva segue entregue como rule
`alwaysApply` em `~/.omp/agent/rules/`, por decisão do operador, porque é o único
caminho que alcança o omp no nível de usuário: ele não lê o `~/.claude/CLAUDE.md`.

Medido no `workspace/37-language-tail/s2.sh` com `USER_INSTALL=1`, três execuções
por caso, com a diretiva como rule de usuário:

- **o idioma melhorou** — rules em `English.` com pedido em pt-BR saem em inglês em
  2 de 3; antes, com a diretiva no `CLAUDE.md` do projeto, em nenhuma;
- **a cauda não se sustenta** — no `tea-open-pr`, 0 de 3, igual a antes; no
  `anvil-diagnose`, 0 de 3, antes 3 de 3; no `diagnose-en`, 1 de 3. Quando falha,
  a sessão fecha com um prompt de próxima sessão escrito de memória.

A user story 57 da spec 006 — a cauda funcionando no omp como no Claude Code —
fica sem cumprimento estável no omp. Um mecanismo próprio de cauda no omp fica
fora desta decisão.

## Alternativas descartadas

- **Manter a instalação por projeto e confiar na sombra.** No Claude Code, skill de
  usuário vence skill de projeto com o mesmo nome, e a cópia velha ficaria inerte;
  no omp, a camada do projeto pode vencer a de usuário. A migração limpa o projeto
  em vez de confiar na precedência.
- **Ler `~/.claude/skills` no omp por provider ligado à mão.** Pediria
  configuração em cada máquina; o espelho `~/.agents/skills` já é lido por padrão,
  e o omp deduplica pelo caminho real.
- **Diretivas no omp pelo `~/.omp/agent/AGENTS.md`.** Sombrearia os arquivos de
  usuário de outros harnesses, e o arquivo pode já ser do usuário.
- **Pin de versão por projeto.** Devolveria a cada projeto a versão própria que
  esta decisão quer tirar; o projeto não registra em que versão do anvil foi
  trabalhado.

## Consequências

**A favor.** Um `/anvil-update` põe todos os projetos da máquina na mesma versão,
que é o objetivo. Uma diretiva nova chega a toda sessão com um update. O projeto
deixa de carregar o payload no git, e o diff de update some do projeto.

**Contra.**

- **O clone não traz o toolkit.** Quem clona precisa da instalação de usuário; a
  rule `anvil.md` que o boot escreve diz isso e traz os comandos de instalação.
- **Não há pin de versão por projeto.** O projeto não diz com que versão do anvil
  foi trabalhado, e o clone de um ano atrás roda o toolkit de hoje.
- **Todos os projetos da máquina rodam a mesma versão.** Um update que quebra,
  quebra todos. Na máquina de desenvolvimento, uma skill editada pela metade chega
  a todos os projetos, inclusive a uma sessão aberta em outro projeto quando a
  skill é relida.
- **O diretório de usuário não tem git.** O dry-run lista por nome o que será
  trocado, removido e preservado, e é a única revisão antes do reset.
- **A cauda de roteamento não se sustenta no omp**, como registrado acima.
