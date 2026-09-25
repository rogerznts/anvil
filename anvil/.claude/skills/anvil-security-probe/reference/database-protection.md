# Proteção do banco antes de teste que escreve

Usado pela trava 5 do `SKILL.md`, só depois da confirmação da trava 4.
Nenhum teste que grava roda antes de uma das duas opções abaixo estar
resolvida.

Os testes rodam por HTTP contra o app que a trava 3 já confirmou no ar —
não contra o banco direto. O app fixa a conexão com o banco no processo que
já está rodando; subir um banco descartável **sem** apontar esse mesmo
processo para ele não protege nada, porque o teste continua escrevendo no
banco de dev por trás do app. As duas opções abaixo levam isso em conta.

## 1. Identificar o motor

De `profile.md` (seção "Ambiente local") e do adapter que o checklist da
stack declarar, quando houver — Postgres, MySQL, MongoDB e SQLite são os
casos cobertos abaixo. Motor fora dessa lista, ou sem `docker-compose*.yml`
nem instalação local do motor → nenhuma das duas opções tem procedimento
aqui; não invente comando — trate como a seção 4 (sem escolha).

## 2. Opção A — banco descartável

Uma instância isolada do mesmo motor, sem nenhum dado em comum com o banco
de dev — **e o app já no ar reapontado para ela**, senão o teste que
escreve continua indo para o banco de dev por trás do app. Reapontar exige
parar o processo do dev server do usuário e subir outro em seu lugar; **diga
isso ao oferecer esta opção**, antes de o usuário escolher — quem escolhe
esta opção está consentindo com o dev server atual parar durante a sessão,
não é um efeito colateral escondido.

1. **Identifique quem escuta na porta do app** — só o processo em estado
   `LISTEN` nessa porta local, nunca "qualquer processo que mencione essa
   porta" (o que incluiria uma conexão de cliente, como o websocket de
   live-reload de um navegador aberto na página):

   ```bash
   ss -ltnp "sport = :$PORTA_DO_APP" | grep -oP 'pid=\K[0-9]+'
   ```

   (Sem `ss`, equivalente com `lsof -ti tcp:"$PORTA_DO_APP" -sTCP:LISTEN` —
   o filtro de estado `-sTCP:LISTEN` é obrigatório; sem ele, `lsof -ti
   :porta` sozinho também devolve conexões de cliente para essa porta.)
   Mais de um PID nesse resultado (cluster/`SO_REUSEPORT`) → pare todos.

2. **Suba a instância descartável**, com porta efêmera **só em loopback**
   — nunca publicada em todas as interfaces, nem por um instante. Os
   valores abaixo (porta interna, variáveis, imagem) vêm do serviço que
   `docker-compose*.yml` declara — o exemplo é Postgres; para MySQL/Mongo,
   troque a porta interna e as variáveis pelas do serviço correspondente:

   ```bash
   NAME="anvil-probe-$(date +%s)"
   docker run -d --name "$NAME" -p "127.0.0.1::<porta interna do compose>" \
     -e POSTGRES_USER="<do compose>" -e POSTGRES_PASSWORD="<do compose>" -e POSTGRES_DB="<do compose>" \
     "<imagem do compose>"
   docker port "$NAME" "<porta interna do compose>"
   ```

   (`docker-compose*.yml` sem porta fixa colidindo: pode-se usar
   `docker compose -p anvil-probe-$(date +%s) up -d <serviço>` normalmente;
   com porta fixa publicada, o Compose funde a lista `ports` de duas
   invocações em vez de substituí-la, e a subida falha por porta já
   alocada — por isso o `docker run` avulso acima, com o mesmo
   imagem/variáveis que o serviço do compose declara.)

3. **Pare o(s) processo(s) do passo 1, confirme a porta livre, e só então
   suba o mesmo comando `dev`** (o mesmo texto que a trava 2 leu de
   `package.json`), com a mesma variável de ambiente que a trava 2
   identificou (`DATABASE_URI`/`MONGODB_URI`/…) sobrescrita — protocolo,
   usuário e nome do banco são as partes que a trava 2 já separou; só o
   host:porta mudam, para o endereço que `docker port` devolveu:

   ```bash
   for pid in $(ss -ltnp "sport = :$PORTA_DO_APP" | grep -oP 'pid=\K[0-9]+'); do kill "$pid"; done
   # a espera confere existência de um socket em LISTEN, não o PID visível
   # (o dono pode ser outro usuário, ex.: docker-proxy — o PID some do
   # comando acima sem que a porta esteja livre) — com limite de tempo:
   n=0
   until ! ss -ltn "sport = :$PORTA_DO_APP" | grep -q LISTEN; do
     n=$((n + 1))
     [ "$n" -gt 20 ] && { echo "porta não liberou — pare, não prossiga"; exit 1; }
     sleep 0.5
   done

   DATABASE_URI="$DB_SCHEME://$DB_USER:$DB_PASSWORD@127.0.0.1:<porta-efêmera>/$DB_NAME" npm run dev &
   ```

   Repita a checagem "no ar" da trava 3 contra a mesma URL. O passo anterior
   garantiu a porta livre antes de subir este comando, então o socket que
   aparecer agora é deste processo novo. **Exceção que exige parar, não
   presumir**: se o usuário roda o dev server sob um supervisor que religa
   processo sozinho (pm2, systemd com `Restart=`, `nodemon` com watch), o
   `kill` do passo 1 pode voltar o processo **antigo**, ainda ligado ao
   banco de dev, antes desta trava perceber. Pergunte ao usuário se há
   supervisor; havendo, peça para desligá-lo antes de continuar — não
   prossiga tentando adivinhar pelo PID. Só depois de afastada essa
   exceção, rode teste que escreve.
4. **Ao final da sessão**: pare esse processo (mesmo comando do passo 3,
   `ss`+`kill`), derrube o container descartável (`docker rm -f -v "$NAME"`
   — o `-v` remove o volume anônimo), e diga ao usuário que o dev server
   foi parado para a sessão e precisa ser religado com o comando normal (o
   mesmo da mensagem "como subir" da trava 3) — o banco de dev nunca foi
   tocado, mas o processo que hoje aponta para ele não está mais rodando.

**Sem Compose, mas o motor está instalado localmente** (ex.: SQLite —
arquivo local, sem container): copie o arquivo do banco para um caminho
temporário (`mktemp`) e repita só os passos 1 e 3 (parar o processo,
confirmar porta livre, subir de novo apontando a variável de caminho do app
para a cópia) — não há container para o passo 2 nem para derrubar no
passo 4, só a cópia temporária para apagar ao final.

## 3. Opção B — dump do banco local, com restauração

Quando o usuário prefere manter o banco (e o app) que já estão no ar, sem
reapontar nada.

Crie o dump **antes do primeiro teste que escreve**, num diretório
temporário (`mktemp -d`) — nunca dentro do repositório, porque um dump pode
conter dado real do projeto:

```bash
DUMP_DIR=$(mktemp -d -t anvil-security-probe.XXXXXX)
```

Em todos os casos abaixo, host/porta/usuário/banco vêm só do que a trava 2
já separou de `DATABASE_URI`/`MONGODB_URI` — nunca de outra instância do
mesmo motor que por acaso esteja rodando na máquina.

- **Postgres** (`pg_dump` local, ou `docker exec <container> pg_dump ...`
  quando `pg_dump` não estiver instalado no host):

  ```bash
  pg_dump --format=custom --no-owner -f "$DUMP_DIR/db.dump" "$DATABASE_URI"
  ```

  Restauração — o par exato do comando acima (mesmo container/host que fez
  o dump). **Mostre este comando, com o caminho real de `$DUMP_DIR`,
  imediatamente depois de criar o dump**:

  ```bash
  pg_restore --clean --if-exists --no-owner -d "$DATABASE_URI" "$DUMP_DIR/db.dump"
  # ou, no mesmo container que gerou o dump por docker exec:
  # docker exec -i <container> pg_restore --clean --if-exists --no-owner -U <user> -d <database> < "$DUMP_DIR/db.dump"
  ```

- **MySQL** — `$DB_HOST`/`$DB_PORT`/`$DB_USER`/`$DB_PASSWORD`/`$DB_NAME` são
  as partes de `DATABASE_URI` (`mysql://user:senha@host:porta/banco`) que a
  trava 2 já separou:

  ```bash
  mysqldump --single-transaction -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" \
    --result-file="$DUMP_DIR/db.sql" "$DB_NAME"
  # restauração:
  mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$DUMP_DIR/db.sql"
  ```

- **MongoDB:**

  ```bash
  mongodump --uri="$MONGODB_URI" --archive="$DUMP_DIR/db.archive"
  # restauração:
  mongorestore --uri="$MONGODB_URI" --archive="$DUMP_DIR/db.archive" --drop
  ```

- **SQLite** — `$SQLITE_PATH` é o caminho de arquivo que `.env`/
  `.env.example` declara para o banco (ex.: `DATABASE_URI=file:./dev.db` →
  `./dev.db`), nunca um caminho adivinhado; copiar o arquivo já é o dump,
  sem ferramenta dedicada:

  ```bash
  cp "$SQLITE_PATH" "$DUMP_DIR/db.sqlite.bak"
  # restauração:
  cp "$DUMP_DIR/db.sqlite.bak" "$SQLITE_PATH"
  ```

O comando de restauração mostrado ao usuário é sempre o par exato do dump
que acabou de rodar — mesmo caminho, mesmas flags. Nunca um comando genérico
de exemplo.

## 4. Sem escolha (ou motor sem procedimento acima)

Sem banco descartável no ar (app reapontado) e sem dump criado — inclusive
quando o motor não está entre os cobertos nas seções 2–3 — a sessão se
restringe às **requisições** de `map.md` que não escrevem. A restrição é
por requisição, não por item inteiro: vários itens do checklist do Payload
descrevem, no mesmo "teste do probe", uma mistura de verbos — por exemplo,
"requisição direta a cada rota gerada (list, get, create, update, delete, e
a operação em massa por `where`)" (item de collections e rotas geradas).
Desse teste, rode só `list`/`get` (leitura); pule `create`/`update`/
`delete`/a mutação em massa por `where` até a sessão ter banco descartável
ou dump. O mesmo vale para um teste escrito como "ler e tentar gravar o
campo" (item de access control por campo): rode a leitura, pule a tentativa
de gravação.

Teste cujo verbo não é ambíguo segue direto: uma leitura simples (ex.:
"chamar a rota... e conferir se o retorno respeita o access control") roda
inteira; um teste que só cria, atualiza, apaga ou dispara uma ação (POST/
PATCH/DELETE isolado, tentativa de login repetida, upload, mutação GraphQL,
sem parte de leitura) fica inteiro de fora.

Isto não é o mesmo grupo que os itens que `map.md` já marca "só leitura" —
aqueles nunca tiveram teste ativo, porque o map os resolveu por inspeção; a
distinção aqui é sobre o efeito de cada requisição do teste que existe,
escrever ou não, não sobre a marca do map.
