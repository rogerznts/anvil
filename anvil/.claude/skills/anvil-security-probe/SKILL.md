---
name: anvil-security-probe
description: "Antes de qualquer teste contra o app, confere cinco travas em ordem: docs/security/profile.md e map.md presentes (sem eles, para e manda rodar /anvil-security-map); alvo descoberto no ambiente local do próprio repositório (scripts de dev, .env, compose) resolvendo para loopback, sem flag que libere outro; servidor de dev respondendo (senão, diz como subi-lo); confirmação explícita de URL, banco e ferramentas detectadas — nunca instaladas — antes de executar; e, antes de teste que escreve, escolha entre banco descartável ou dump com o comando exato de restauração — sem escolha, roda só testes de leitura. Use para /anvil-security-probe, sempre depois do /anvil-security-map."
---

# Travas antes de testar

Esta skill é autoral (adr-0012 — as skills de segurança são autorais,
destiladas das referências, listadas em [SOURCES.md](SOURCES.md)). Ela é a
metade que **executa** contra o ambiente de desenvolvimento local — a outra
metade, que só lê o repositório, é o `/anvil-security-map`.

Este documento cobre as cinco travas que rodam, nesta ordem, antes de
qualquer teste. Nenhuma delas é pulável por argumento, flag ou pedido do
usuário no meio da execução — a ordem e o conteúdo de cada trava são o
contrato desta skill.

## 1. Exigir o mapa

Confira se `docs/security/profile.md` e `docs/security/map.md` existem.

Falta um dos dois (ou os dois) → pare aqui. Não gere um mapa improvisado,
não infira ferramentas nem ambiente por conta própria. Diga ao usuário para
rodar `/anvil-security-map` primeiro, e por quê: sem o mapa não há lista de
itens para testar, nem o contexto de ferramentas/ambiente que a trava 4
confirma.

Os dois presentes → siga para a trava 2.

## 2. Descobrir o alvo e recusar qualquer coisa fora de loopback

Descoberta e verificação completas em
[reference/target-discovery.md](reference/target-discovery.md) — leia antes
de rodar o primeiro comando desta trava.

Resumo do contrato: o alvo (URL do app, string de conexão do banco) sai só
do que o próprio repositório declara — script `dev` de `package.json`,
`.env`/`.env.example`, `docker-compose*.yml`. Cada host descoberto (literal
ou por hostname) precisa resolver para loopback — o critério exato,
inclusive o caso de bind coringa (`0.0.0.0`/`::`) e o de hostname que não
resolve, está em `reference/target-discovery.md`. Um único host fora disso
— mesmo que os outros resolvam certo — recusa a execução inteira.

**Nenhum argumento, flag ou pedido no meio da conversa muda esse resultado.**
Esta skill não define nem lê nenhuma flag de override — não existe "modo"
que libere um alvo remoto. Se o usuário pedir para mirar outro host, recuse
e explique que é o desenho da skill (adr-0012), não uma configuração que
falta ligar.

Passou → siga para a trava 3.

## 3. Conferir se o servidor de dev está respondendo

Requisição HTTP simples contra a URL validada na trava 2 — qualquer código
de resposta conta como "no ar"; só timeout ou conexão recusada conta como
"fora do ar":

```bash
curl -sS -o /dev/null -w '%{http_code}\n' --max-time 5 "$URL" \
  || echo "fora do ar"
```

Fora do ar → pare e diga como subir, citando o comando **exato** que a
trava 2 já leu do repositório: o script `dev` de `package.json` (ex.:
`npm run dev`, que roda `next dev -p 3000`) e, se `docker-compose*.yml`
declarar um serviço de banco, o comando para subi-lo também (ex.:
`docker compose up -d postgres`). Nunca suba o servidor ou o banco por conta
própria — quem sobe é o usuário.

No ar → siga para a trava 4.

## 4. Mostrar e esperar confirmação explícita

Antes de executar qualquer coisa, mostre em bloco:

- **URL** — o alvo validado na trava 2.
- **Banco** — a string de conexão (com a senha mascarada) e a origem
  (`.env`/`docker-compose*.yml`), como a trava 2 encontrou.
- **Ferramentas** — a tabela "Ferramentas de segurança" de `profile.md`,
  como está: o map já checou presença, e presença de ferramenta não muda
  entre o map e o probe rodarem na mesma máquina. Não rode detecção de novo
  aqui.

Espere uma resposta explícita e afirmativa do usuário. Qualquer coisa que
não seja uma confirmação clara — silêncio, recusa, pergunta, mudança de
assunto — encerra aqui, sem executar nada.

Confirmado → siga para a trava 5.

## 5. Proteger o banco antes de teste que escreve

Procedimento completo em
[reference/database-protection.md](reference/database-protection.md) — leia
antes de propor qualquer opção ao usuário.

Resumo do contrato: antes do primeiro teste que grava, altera ou apaga
qualquer coisa no banco, ofereça duas opções e espere a escolha:

- **Banco descartável** — uma instância isolada, sem dado em comum com o
  banco de dev; como os testes rodam contra o app já no ar (trava 3), esta
  opção também aponta o próprio app para a instância isolada (procedimento
  completo na referência) — não basta subir um banco paralelo que o app
  nunca usa. Isso exige parar e religar o dev server do usuário: diga isso
  **ao oferecer** a opção, antes de ele escolher, não só ao executar.
- **Dump do banco local** — se o usuário preferir o banco que já está no ar,
  crie o dump antes do primeiro teste que escreve e mostre o comando exato
  de restauração, já com o caminho real do dump que acabou de ser criado
  (nunca um caminho de exemplo).

**Sem nenhuma das duas escolhas (ou com um motor de banco sem procedimento
na referência), a execução se restringe às requisições de `map.md` que não
escrevem** — por requisição, não por item inteiro: um teste que mistura
verbos (ex.: "list, get, create, update, delete" numa rota gerada) roda só
a parte `list`/`get`, e pula `create`/`update`/`delete`/mutação em massa até
uma sessão futura. Isto não é o mesmo grupo que os itens já marcados "só
leitura" em `map.md` — aqueles nunca tiveram teste ativo; esta restrição é
sobre o efeito de cada requisição, escrever ou não.

## Antes de terminar (destas cinco travas)

- As cinco travas rodaram nesta ordem, sem pular nenhuma.
- Nenhum comando de rede tocou um alvo fora de loopback.
- A confirmação da trava 4 foi uma resposta explícita do usuário, não uma
  suposição.
- Teste que escreve só roda depois de banco descartável no ar **ou** dump
  criado com o comando de restauração já mostrado; sem isso, só leitura.
