# 04: O probe recusa, confirma e protege o banco

**Blocked by:** 02
**Status:** resolved
**Review:** round=1; sha=cc42771; scope=full; verdict=pass; p1=none

**What to build:** Um desenvolvedor roda `/anvil-security-probe` e, antes de qualquer teste, o probe passa pelas travas, nesta ordem:

1. `profile.md` e `map.md` presentes; sem eles, para e manda rodar o map, sem improvisar mapa;
2. alvo descoberto no ambiente local do repositório (scripts de dev, `.env`, compose) e resolvendo para loopback; nenhuma flag libera outro alvo;
3. servidor de dev respondendo; se não, diz como subi-lo;
4. mostra URL, banco e ferramentas que vai usar e espera confirmação explícita;
5. antes de teste que escreve, sugere banco descartável; se o usuário preferir o banco local, cria um dump e mostra o comando exato de restauração. Sem nenhuma das duas escolhas, roda só testes de leitura.

Este ticket entrega a skill com as travas. Nenhum teste de ataque ainda; a skill é autoral e traz `SOURCES.md`.

- [x] Sem `profile.md` ou `map.md`, o probe recusa e aponta o `/anvil-security-map`
- [x] Com um alvo que não resolve para loopback, o probe recusa, e nenhum argumento muda isso
- [x] Com servidor fora do ar, o probe para e diz como subi-lo
- [x] Com alvo local, o probe mostra URL, banco e ferramentas e só segue após confirmação
- [x] O probe oferece banco descartável ou dump; escolhido o dump, ele é criado e o comando de restauração aparece
- [x] Sem escolha de banco, o probe se restringe a testes de leitura
- [x] A skill traz `SOURCES.md`

## Comments

- Prova ponta a ponta em `workspace/05-security-map/` (fora do git), reusando
  o cenário `payload-vulnerable` dos tickets 02/03 e duas cópias
  descartáveis dele (`payload-vulnerable-no-map`, sem `docs/security/`;
  `payload-vulnerable-remote`, com `DATABASE_URI` apontando para o IP
  literal `203.0.113.5`, TEST-NET-3, não-loopback sem depender de DNS):
  - Trava 1: sem `profile.md`/`map.md`, a checagem recusa e aponta o map.
  - Trava 2: com `203.0.113.5` no `.env`, a checagem de loopback recusa; e,
    comportamental (não só estrutural), tentei "liberar" o alvo com
    `--allow-remote` e com uma variável de ambiente inventada — a função
    documentada em `reference/target-discovery.md` não lê nenhum dos dois,
    recusa igual.
  - Trava 3: com o servidor fora do ar, `curl` real falha (conexão
    recusada) e a mensagem cita o `next dev -p 3000`/`docker compose up -d
    postgres` reais do cenário; subindo um servidor, a checagem passa.
  - Trava 4: bloco de confirmação construído com URL/banco mascarado da
    trava 2 e a tabela de ferramentas de `profile.md`; testei respostas não
    afirmativas ("não", vazio, mudança de assunto) não avançando.
  - Trava 5, banco descartável: provado ponta a ponta com um app de
    brinquedo real (HTTP + `docker exec psql`) escrevendo primeiro no banco
    de dev (docker-compose real), depois parado e religado apontando para
    uma instância descartável (`docker run -p 127.0.0.1::5432`, porta
    efêmera confirmada só em loopback) — a escrita seguinte caiu só no
    descartável, o banco de dev ficou intacto. Repeti com uma conexão de
    cliente concorrente na mesma porta (simulando o websocket de
    live-reload do navegador) para provar que a identificação do processo
    por `ss -ltnp "sport = :porta"` (LISTEN-only) mata só o servidor, nunca
    o cliente — uma versão sem esse filtro (`lsof`/`ss` sem estado) matou o
    PID errado numa rodada de revisão anterior, corrigido antes deste
    commit.
  - Trava 5, dump: `pg_dump` real via `docker exec`, dado real corrompido
    de propósito, e o comando de restauração exato mostrado
    (`docker exec ... pg_restore ...`) rodado de verdade, restaurando o
    dado original.
  - Trava 5, sem escolha: classificação mecânica de quatro itens reais de
    `map.md` do cenário pela regra de `database-protection.md` §4 — os dois
    itens de teste misto (`API1-01`/`API3-01`, texto real "list, get,
    create, update, delete" / "ler e tentar gravar o campo") separados
    corretamente em parte-que-lê (roda) e parte-que-escreve (fica de fora);
    os dois itens de teste puro de leitura (`A01-01`, `A05-01`) rodam
    inteiros.
- Três rodadas de revisão de duas subagentes (Standards/Spec) rodaram antes
  deste registro, sem nenhuma delas ainda commitada — os P1 abaixo foram
  achados e corrigidos no mesmo trabalho, nunca chegaram a ficar `Status:
  claimed`/`verdict=fail` no ticket:
  - P1 (rodada interna 1, Spec): "sem escolha" restringia por item inteiro
    de `map.md`, e confundia a marca "só leitura" do map (sem teste ativo)
    com "teste que não escreve" — corrigido para restrição por requisição,
    dentro do mesmo item quando ele mistura verbos.
  - P1 (rodada interna 1, Spec): banco descartável só subia uma instância
    paralela sem apontar o app já no ar para ela — o teste que escreve
    continuava indo para o banco de dev por trás do app. Corrigido: a
    opção agora para o processo atual e religa o mesmo comando `dev` com a
    conexão sobrescrita, avisando isso ao oferecer a opção, não só ao
    executar.
  - P1 (rodada interna 2, Standards e Spec, mesmo achado pelos dois eixos):
    a identificação do processo por `lsof -ti :porta` sem filtro de estado
    também casa conexão de cliente (ex.: websocket de live-reload), e o
    `kill` podia matar o processo errado ou falhar por PID ambíguo.
    Corrigido: `ss -ltnp "sport = :porta"` (LISTEN-only), espera de porta
    livre antes de religar, e confirmação de que o socket novo só pode ser
    do processo novo porque a porta esteve vazia antes.
- P2 acionáveis, registrados e não bloqueantes (`docs/agents/verification.md`):
  - P2 — a prova do banco descartável não exercitou um processo filho
    (`npm` chamando `next`/`node` como processo separado) nem um
    supervisor de processo (pm2, systemd `Restart=`) religando sozinho o
    servidor antigo depois do `kill` — cenário em que o app continuaria
    ligado ao banco de dev sem que a trava perceba. A mitigação está
    documentada (`database-protection.md` §2, passo 3: perguntar se há
    supervisor e parar em vez de adivinhar), mas não foi exercitada com um
    supervisor de verdade. Quem pegar a execução real (fora de escopo
    deste ticket) deve validar contra um projeto com `next dev` via `npm`
    e, se possível, sob pm2.
  - P3 — o passo 1 de `database-protection.md` documenta a alternativa
    `lsof -ti tcp:$PORTA -sTCP:LISTEN` para quem não tem `ss` (macOS); os
    passos 3 e 4 usam `ss` direto, sem repetir a alternativa. Quem seguir
    a referência num Mac precisa lembrar de trocar o comando sozinho.
