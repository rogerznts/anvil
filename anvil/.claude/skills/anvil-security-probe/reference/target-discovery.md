# Descoberta do alvo e checagem de loopback

Usado pela trava 2 do `SKILL.md`. Só leitura do repositório e do resolvedor
de DNS do sistema — nenhuma requisição ao app ainda; isso é a trava 3.

## 1. Onde procurar

Na ordem — o primeiro valor encontrado para cada campo vence:

- **URL do app:**
  1. `.env` (se existir) e depois `.env.example` — `PORT`, `HOST`,
     `APP_URL` e variantes por framework (`NEXT_PUBLIC_*`).
  2. Script `dev` de `package.json` — flags `-p`/`--port`,
     `-H`/`--hostname` (Next.js, Vite e equivalentes).
  3. Sem nenhum dos dois, a porta padrão do framework que `profile.md`
     detectou (Next.js: `3000`); sem stack detectada e sem porta declarada
     em lugar nenhum, `profile.md` já diz "não encontrado" — pare e diga
     que não há alvo de app para verificar.
  Host ausente em qualquer um deles → `localhost`. Host declarado como
  coringa de bind (`0.0.0.0`, `::`, `*`) → não é um alvo em si, é instrução
  de "todas as interfaces"; o alvo que esta trava resolve e verifica é
  `localhost` — o app aceita conexão por loopback do mesmo jeito.

- **String de conexão do banco:** `.env`/`.env.example` —
  `DATABASE_URI`/`DATABASE_URL`/`MONGODB_URI`/`MONGO_URL` e variantes —,
  com `docker-compose*.yml` como contexto (imagem, porta publicada) quando
  o serviço bate com o host da string.

Nada disso executa ferramenta nem conecta a nada — é leitura de arquivo,
igual ao passo 3 do `SKILL.md` do map.

## 2. Resolver cada host

Para cada host encontrado (app e banco, quando forem hosts diferentes):

```bash
# IP literal: já está resolvido, use como está.
# Hostname: resolva todos os endereços que o sistema devolver.
getent ahosts "$HOST" | awk '{print $1}' | sort -u
```

Sem `getent` (não-Linux), equivalente:

```bash
python3 -c 'import socket,sys; print("\n".join(sorted({i[4][0] for i in socket.getaddrinfo(sys.argv[1], None)})))' "$HOST"
```

## 3. Checar loopback

Todo endereço resolvido precisa cair em `127.0.0.0/8` (IPv4) ou ser `::1`
(IPv6) — inclusive o mapeamento `::ffff:127.0.0.0/8`. Um único endereço fora
disso, em qualquer host (app ou banco), recusa a trava inteira. **Zero
endereços resolvidos** (hostname que não resolve) também recusa — não é
"todos os endereços em loopback" por vacuidade, é falha de descoberta:

```bash
is_loopback() {
  case "$1" in
    127.*) return 0 ;;
    ::1) return 0 ;;
    ::ffff:127.*) return 0 ;;
    *) return 1 ;;
  esac
}
```

`localhost` sem entrada customizada em `/etc/hosts` resolve para
`127.0.0.1`/`::1` — é o caso comum. O que esta trava pega é o `.env` (ou o
compose) apontando para um host de verdade: IP de rede interna, domínio
público, nome de serviço gerenciado.

## 4. Recusar ou seguir

Achou um endereço fora de loopback → pare e diga qual campo (URL do app ou
string do banco), qual valor bruto do repositório gerou o host, e para qual
endereço ele resolveu. Não hesite por causa de argumento ou pedido do
usuário: esta skill não tem flag de override — a única forma de mudar o
resultado é mudar o repositório.

Todos os endereços em loopback → registre, para as travas 3 e 5: a URL; a
string de conexão do banco, íntegra (a senha só é mascarada na hora de
*mostrar* algo ao usuário — trava 4 — nunca no valor guardado internamente,
que a trava 5 precisa para rodar `mysqldump`/copiar o arquivo SQLite); as
partes já separadas dessa string (protocolo, usuário, senha, host, porta,
nome do banco — de `protocolo://usuário:senha@host:porta/banco`), para a
trava 5 não ter que reanalisar a string; e o texto exato do script `dev` de
`package.json` e do comando do serviço de banco em `docker-compose*.yml`
(imagem, variáveis), já lidos no passo 1 — as travas seguintes citam esse
texto, não voltam a procurá-lo. Siga para a trava 3.
