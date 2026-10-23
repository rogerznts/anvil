# ADR-0017 — A prova roda pelo caminho real, isolada, e pode sair inválida

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

- **Prova inválida, código `3`.** Quando o modelo do jsonl não é o pedido, a prova
  não conta como verde nem como vermelho, e se repete. O helper passa
  `--config` com `retry.modelFallback: false` só na sessão da prova, e confere o
  jsonl mesmo assim.
- **Caminho real.** O helper conduz a sessão por `--mode rpc`, em que o
  `/skill:` é expandido.
- **Isolada.** Diretório por `mktemp -d`; as skills do payload carregadas na
  sessão pelo `skills.customDirectories` do mesmo overlay, que tem precedência
  sobre a instalação de usuário, sem tocar em `~/.claude` nem em `~/.agents`; um
  remoto bare local e `gh`/`tea` falsos no PATH, que gravam a chamada; e, no
  bench, um prefixo por execução no `infra.sh` que separa o compose, a rede, o
  registro e os volumes, derrubados no fim. A stack sobe de verdade.

As provas antigas de `workspace/` não são reescritas.

## Alternativas descartadas

- **Reprovar quando o modelo troca.** Mistura "o comportamento quebrou" com "o
  provedor caiu".
- **Mudar o config de usuário do omp durante a prova.** Afeta toda sessão da
  máquina enquanto a prova roda.
- **Manter o `docker` falso.** A verificação com o app rodando nunca seria provada.
- **Helper fora do repositório.** Ele só serve às provas deste repositório; na
  instalação de usuário, iria para toda máquina sem uso.
