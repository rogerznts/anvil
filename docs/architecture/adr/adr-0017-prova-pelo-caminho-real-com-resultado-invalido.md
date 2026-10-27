# ADR-0017 — A prova roda pelo caminho real, isolada, e pode sair inválida

- Revisto em parte pelo [ADR-0018 — HOME dev por checkout](./adr-0018-dev-home-isolado-por-checkout.md): o launcher da prova resolve suas dependências no HOME privado, sem exigir links globais.

- Status: aceito
- Data: 2026-10-23

## Contexto

As provas das specs 008 e 009 — sessões headless do omp em `workspace/`, fora do
git — mediram menos do que diziam. Quando a Anthropic devolvia `overloaded_error`,
o omp trocava o modelo pelo `openai-codex/gpt-6.1-sol`, e uma prova da 008 calibrou
o piloto por um modelo que ninguém pediu. No `-p`, o `/skill:x` chega ao modelo
como texto, então nenhuma prova exercitou o caminho que o usuário digita. Cada
`s2.sh` reinventava a ligação das skills, que ficava à mão, e o diretório em
`/tmp`, de nome fixo. As provas do bench usaram o Postgres, o Redis e o registro
dos projetos reais, ou um `docker` falso que impedia o app de subir.

## Decisão

**Um helper de prova versionado em `.claude/skills/anvil-sync/scripts/`**, porque
ele não varia por projeto: é a infraestrutura das provas do próprio toolkit, e a
fixture de cada prova continua em `workspace/`.

- **Prova inválida, código `3`.** A sessão principal tem de ser respondida pelo
  modelo pedido, e cada sessão de subagente, por um modelo só, do começo ao fim:
  a que diverge torna a prova inválida, que não conta como verde nem como
  vermelho, e se repete. O subagente com modelo próprio por papel ou por
  frontmatter, como `model: haiku`, não é fallback e não invalida; o relatório
  lista os modelos. O helper passa `--config` com `retry.modelFallback: false`
  só na sessão da prova, e confere o jsonl mesmo assim. Uma falha do próprio
  helper ao dar o veredito é ambiente, `2`, nunca vermelho.
- **Caminho real.** O helper conduz a sessão por `--mode rpc`, em que o
  `/skill:` é expandido.
- **Isolada.** Diretório por `mktemp -d`; as skills do payload carregadas na
  sessão pelo `skills.customDirectories` do mesmo overlay, que tem precedência
  sobre a instalação de usuário, sem tocar em `~/.claude` nem em `~/.agents`; um
  remoto bare local e `gh`/`tea` falsos no PATH, que gravam a chamada; e, no
  bench, um prefixo por execução no `infra.sh` que separa o compose, a rede, o
  registro e os volumes, derrubados no fim. A stack sobe de verdade.
- **Dependências declaradas.** O payload cita `~/.claude/skills/<skill>/…` nos
  comandos que o modelo copia, e o overlay carrega o `SKILL.md`, não o caminho. A
  prova declara as skills de que precisa nesse caminho, e o helper confere que
  cada uma é um link para o payload desta árvore; se não for, sai `2` mandando
  ligar com o `dev-link.sh`. Quem liga é o operador, e a prova continua sem
  escrever em `~/.claude`.

As provas antigas de `workspace/` não são reescritas.

## Alternativas descartadas

- **Reprovar quando o modelo troca.** Mistura "o comportamento quebrou" com "o
  provedor caiu".
- **Mudar o config de usuário do omp durante a prova.** Afeta toda sessão da
  máquina enquanto a prova roda.
- **Manter o `docker` falso.** A verificação com o app rodando nunca seria provada.
- **Um `HOME` próprio na sessão, com os links.** Obriga a ligar também o que o
  omp, o git e o docker leem do `HOME`, e cada ferramenta que o lê vira risco.
- **Uma variável no lugar de `~/.claude/skills` nos comandos do payload.** Espalha
  um ponto de teste pelo texto que o Claude Code também lê.
- **Julgar todo subagente pelo modelo pedido.** Torna inválida, por desenho, toda
  prova em que o piloto escolhe um agente com modelo próprio. A brecha aceita é o
  subagente cuja primeira chamada já cai no fallback, rara com o fallback
  desligado.
- **Helper fora do repositório.** Ele só serve às provas deste repositório; na
  instalação de usuário, iria para toda máquina sem uso.
