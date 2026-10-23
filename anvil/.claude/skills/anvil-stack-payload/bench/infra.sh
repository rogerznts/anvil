#!/usr/bin/env bash
# infra.sh — infra compartilhada + provisionamento por projeto (ADR-0001).
#
# Modo padrão (sem --provision): detecta/cria/reusa a infra compartilhada de
# forma idempotente (FR-005) e aplica o health gate pg_isready + redis-cli ping
# (FR-006).
#
# Modo --provision <projeto>: aloca de forma determinística, sem colisão, e grava
# em ~/projects/.anvil-infra/registry.yaml (FR-007/008):
#   - banco Postgres próprio  (slug [a-z0-9_], checa pg_database antes de CREATE)
#   - índice Redis livre      (0-15, fallback prefixo "<slug>:")
#   - porta livre do admin    (bind-test a partir de 3000)
#
# Modo --teardown: só com o prefixo de execução de uma prova (ANVIL_INFRA_PREFIX),
# derruba a infra do prefixo; sem ele, recusa sem tocar em nada.
#
# Idempotente. Suporta --help e --dry-run.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# O script roda da instalação de usuário, e o projeto é onde ele é chamado: a
# raiz do git, ou o diretório corrente quando o git ainda não foi iniciado. Do
# próprio arquivo só sai o que é da skill, como o compose da infra.
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STARTER_INFRA="$SCRIPT_DIR/starter/.anvil-infra/docker-compose.yml"

# Diretório de projetos do usuário (overridable para testes).
PROJECTS_DIR="${ANVIL_PROJECTS_DIR:-$HOME/projects}"

# Prefixo de execução, só para prova (ADR-0017): com ele, o projeto do compose, a
# rede e o diretório do registro levam o prefixo, e os volumes ficam no projeto do
# compose prefixado. Sem ele, a infra é a compartilhada, como sempre.
INFRA_PREFIX="${ANVIL_INFRA_PREFIX:-}"
COMPOSE_PROJECT=""
if [[ -n "$INFRA_PREFIX" ]]; then
    if [[ ! "$INFRA_PREFIX" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        echo "ERRO: ANVIL_INFRA_PREFIX inválido: '$INFRA_PREFIX' (use [a-z0-9][a-z0-9_-]*)." >&2
        exit 1
    fi
    COMPOSE_PROJECT="$INFRA_PREFIX-anvil-infra"
    INFRA_DIR="$PROJECTS_DIR/.$INFRA_PREFIX-anvil-infra"
    NETWORK_NAME="$INFRA_PREFIX-anvil-net"
else
    INFRA_DIR="$PROJECTS_DIR/.anvil-infra"
    NETWORK_NAME="anvil-net"
fi
INFRA_COMPOSE="$INFRA_DIR/docker-compose.yml"
REGISTRY="$INFRA_DIR/registry.yaml"

PORT_START=3000
PORT_MAX=3999
REDIS_MAX_INDEX=15

DRY_RUN=false
PROVISION=""
TEARDOWN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --provision)
            shift
            PROVISION="${1:-}"
            if [[ -z "$PROVISION" ]]; then
                echo "ERRO: --provision exige o nome do projeto." >&2
                exit 1
            fi
            ;;
        --teardown)
            TEARDOWN=true
            ;;
        --help|-h)
            cat <<'EOF'
Usage:
  infra.sh [--dry-run]                    # detecta/cria/reusa a infra + health gate
  infra.sh --provision <projeto> [--dry-run]  # aloca db/porta/redis do projeto
  ANVIL_INFRA_PREFIX=<prefixo> infra.sh --teardown [--dry-run]  # derruba a infra do prefixo

Infra compartilhada por máquina (ADR-0001): Postgres + Redis + rede anvil-net,
uma vez só, reusada por todos os projetos. Fonte da verdade da alocação:
~/projects/.anvil-infra/registry.yaml.

A única exceção, e só para prova, é o prefixo de execução em ANVIL_INFRA_PREFIX:
com ele, a infra é outra, com projeto do compose <prefixo>-anvil-infra (e os
volumes dele), rede <prefixo>-anvil-net e registro em
~/projects/.<prefixo>-anvil-infra/.

Modo padrão:
  - Se a rede anvil-net não existe: copia o compose da infra para
    ~/projects/.anvil-infra/ e sobe (docker compose up -d).
  - Se existe e roda: reusa sem tocar.
  - Se está parada: up -d.
  - Health gate: pg_isready + redis-cli ping antes de liberar.

Modo --provision <projeto>, chamado do diretório do projeto:
  - Projeto: a raiz do git, ou o diretório corrente sem git.
  - Banco próprio: slug sanitizado [a-z0-9_]; checa pg_database antes do CREATE.
  - Índice Redis livre: 0-15; se todos ocupados, cai para prefixo "<slug>:".
  - Porta livre: bind-test a partir de 3000.
  - Grava tudo em registry.yaml (idempotente: projeto já provisionado é reusado).
  - A alocação impressa (ALLOC_*) traz a rede em ALLOC_NETWORK, que vai para o
    ANVIL_NETWORK do .env do projeto.

Modo --teardown, só com ANVIL_INFRA_PREFIX:
  - Remove os containers do compose do prefixo e os que estão na rede dele, os
    volumes do compose, a rede e o diretório do registro.
  - Sem o prefixo, recusa e não toca em nada: a infra compartilhada não se
    derruba por aqui.

OPTIONS:
  --dry-run   Mostra o que faria; não sobe containers nem escreve no registry.
  --help, -h  Mostra esta ajuda.

Env:
  ANVIL_PROJECTS_DIR  Sobrescreve ~/projects (padrão) — útil para testes.
  ANVIL_INFRA_PREFIX  Prefixo de execução de uma prova, [a-z0-9][a-z0-9_-]*.

O script é idempotente: rodar 2x não corrompe o estado.
EOF
            exit 0
            ;;
        *)
            echo "ERRO: opção desconhecida '$1'. Use --help." >&2
            exit 1
            ;;
    esac
    shift
done

if $TEARDOWN; then
    if [[ -z "$INFRA_PREFIX" ]]; then
        echo "ERRO: --teardown só derruba a infra de um prefixo de execução, e ANVIL_INFRA_PREFIX está vazio; a infra compartilhada não se derruba por aqui. Nada foi tocado." >&2
        exit 1
    fi
    if [[ -n "$PROVISION" ]]; then
        echo "ERRO: --teardown não se combina com --provision." >&2
        exit 1
    fi
fi

# O compose da infra lê o nome da rede de ANVIL_NETWORK; o projeto prefixado vem
# do -p, que vale sobre o name: do arquivo.
compose_infra() {
    ANVIL_NETWORK="$NETWORK_NAME" docker compose -f "$INFRA_COMPOSE" ${COMPOSE_PROJECT:+-p "$COMPOSE_PROJECT"} "$@"
}

# ---------- infra compartilhada (FR-005/006) ----------

network_exists() { docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; }

infra_running() {
    # true se ao menos o container do postgres estiver "running".
    [[ -f "$INFRA_COMPOSE" ]] || return 1
    local ids
    ids="$(compose_infra ps -q postgres 2>/dev/null || true)"
    [[ -n "$ids" ]] && [[ "$(docker inspect -f '{{.State.Running}}' "$ids" 2>/dev/null)" == "true" ]]
}

ensure_infra() {
    if $DRY_RUN; then
        if network_exists; then
            echo "would  reusar infra existente (rede $NETWORK_NAME presente)."
        else
            echo "would  copiar $STARTER_INFRA -> $INFRA_COMPOSE e subir (docker compose up -d)."
        fi
        return 0
    fi

    mkdir -p "$INFRA_DIR"
    # Copia o compose da infra se ainda não existe no destino (idempotente).
    if [[ ! -f "$INFRA_COMPOSE" ]]; then
        if [[ ! -f "$STARTER_INFRA" ]]; then
            echo "ERRO: compose da infra não encontrado no template: $STARTER_INFRA" >&2
            exit 1
        fi
        cp "$STARTER_INFRA" "$INFRA_COMPOSE"
        echo "copiado compose da infra -> $INFRA_COMPOSE"
    fi

    if network_exists && infra_running; then
        echo "infra já de pé — reusando (rede $NETWORK_NAME + Postgres/Redis rodando)."
    else
        echo "subindo a infra compartilhada (primeira vez pode demorar um pouco)..."
        compose_infra up -d
    fi
}

health_gate() {
    if $DRY_RUN; then
        echo "would  aplicar health gate (pg_isready + redis-cli ping)."
        return 0
    fi
    echo "verificando saúde da infra..."
    local i
    for i in $(seq 1 30); do
        if compose_infra exec -T postgres pg_isready -U anvil >/dev/null 2>&1 \
           && [[ "$(compose_infra exec -T redis redis-cli ping 2>/dev/null | tr -d '\r')" == "PONG" ]]; then
            echo "  ok  Postgres e Redis prontos."
            return 0
        fi
        sleep 2
    done
    echo "ERRO: a infra não ficou saudável a tempo (Postgres/Redis). Tente de novo." >&2
    exit 1
}

# ---------- provisionamento por projeto (FR-007/008) ----------

sanitize_slug() {
    # minúsculas, tudo fora de [a-z0-9_] vira _, colapsa múltiplos _, apara bordas.
    local raw="$1"
    echo "$raw" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[^a-z0-9_]/_/g' -e 's/_\{2,\}/_/g' -e 's/^_//' -e 's/_$//'
}

registry_init() {
    if [[ ! -f "$REGISTRY" ]]; then
        mkdir -p "$INFRA_DIR"
        cat > "$REGISTRY" <<'EOF'
# Fonte da verdade da alocação por projeto (ADR-0001, FR-008).
# Gerado/atualizado por infra.sh --provision. Não editar à mão.
projects:
EOF
    fi
}

# Lê o valor de uma chave de um projeto já registrado. Uso: registry_get <slug> <chave>
registry_get() {
    local slug="$1" key="$2"
    [[ -f "$REGISTRY" ]] || return 0
    awk -v slug="$slug" -v key="$key" '
        $0 ~ "^  " slug ":[[:space:]]*$" { inblock=1; next }
        inblock && /^  [^ ]/ { inblock=0 }
        inblock && $0 ~ "^    " key ":" {
            sub("^    " key ":[[:space:]]*", "", $0)
            gsub(/"/, "", $0)
            print $0
            exit
        }
    ' "$REGISTRY"
}

project_registered() {
    local slug="$1"
    [[ -f "$REGISTRY" ]] || return 1
    grep -qE "^  ${slug}:[[:space:]]*$" "$REGISTRY"
}

# Coleta todos os valores já usados de uma chave (uma por linha).
registry_used() {
    local key="$1"
    [[ -f "$REGISTRY" ]] || return 0
    awk -v key="$key" '
        $0 ~ "^    " key ":" {
            sub("^    " key ":[[:space:]]*", "", $0)
            gsub(/"/, "", $0)
            if ($0 != "") print $0
        }
    ' "$REGISTRY"
}

port_in_use() {
    # 0 se a porta está ocupada (algo escuta), 1 se livre.
    local port="$1"
    if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
        exec 3>&- 3<&- 2>/dev/null || true
        return 0
    fi
    return 1
}

find_free_port() {
    local used_ports port p
    used_ports="$(registry_used admin_port)"
    for ((port=PORT_START; port<=PORT_MAX; port++)); do
        # pula portas já registradas
        local taken=0
        for p in $used_ports; do
            [[ "$p" == "$port" ]] && { taken=1; break; }
        done
        [[ "$taken" == "1" ]] && continue
        port_in_use "$port" && continue
        echo "$port"
        return 0
    done
    return 1
}

find_free_redis_index() {
    local used p i
    used="$(registry_used redis_index)"
    for ((i=0; i<=REDIS_MAX_INDEX; i++)); do
        local taken=0
        for p in $used; do
            [[ "$p" == "$i" ]] && { taken=1; break; }
        done
        [[ "$taken" == "1" ]] && continue
        echo "$i"
        return 0
    done
    return 1  # todos ocupados -> chamador cai para prefixo
}

db_exists() {
    local db="$1"
    local out
    out="$(compose_infra exec -T postgres psql -U anvil -tAc \
        "SELECT 1 FROM pg_database WHERE datname='$db'" 2>/dev/null | tr -d '[:space:]')"
    [[ "$out" == "1" ]]
}

provision_project() {
    local name="$1"
    local slug
    slug="$(sanitize_slug "$name")"
    if [[ -z "$slug" ]]; then
        echo "ERRO: nome de projeto inválido: '$name'." >&2
        exit 1
    fi
    echo "projeto: $PROJECT_ROOT"

    registry_init

    # Idempotência: projeto já provisionado -> reusa e sai (US2, FR-021).
    if project_registered "$slug"; then
        local ex_db ex_port ex_idx ex_prefix
        ex_db="$(registry_get "$slug" db)"
        ex_port="$(registry_get "$slug" admin_port)"
        ex_idx="$(registry_get "$slug" redis_index)"
        ex_prefix="$(registry_get "$slug" redis_prefix)"
        echo "projeto '$slug' já provisionado — reusando (sem reprovisionar)."
        emit_allocation "$slug" "$ex_db" "$ex_port" "$ex_idx" "$ex_prefix"
        return 0
    fi

    # Porta livre (bind-test).
    local port
    if ! port="$(find_free_port)"; then
        echo "ERRO: nenhuma porta livre entre $PORT_START e $PORT_MAX." >&2
        exit 1
    fi

    # Índice Redis livre (0-15) ou fallback prefixo.
    local redis_index redis_prefix=""
    if redis_index="$(find_free_redis_index)"; then
        redis_prefix=""
    else
        redis_index=0
        redis_prefix="${slug}:"
    fi

    local db="$slug"

    if $DRY_RUN; then
        echo "would  provisionar projeto '$slug':"
        echo "         db=$db (CREATE DATABASE se não existir)"
        echo "         admin_port=$port (bind-test ok)"
        if [[ -n "$redis_prefix" ]]; then
            echo "         redis_index=$redis_index (compartilhado) + prefixo '$redis_prefix'"
        else
            echo "         redis_index=$redis_index"
        fi
        echo "would  gravar a alocação em $REGISTRY"
        emit_allocation "$slug" "$db" "$port" "$redis_index" "$redis_prefix"
        return 0
    fi

    # Cria o banco se ainda não existir (checa pg_database antes — FR-007).
    if db_exists "$db"; then
        echo "banco '$db' já existe — reusando."
    else
        echo "criando banco '$db'..."
        compose_infra exec -T postgres psql -U anvil -c "CREATE DATABASE \"$db\"" >/dev/null
    fi

    # Grava no registry.yaml.
    local now
    now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    cat >> "$REGISTRY" <<EOF
  ${slug}:
    db: "${db}"
    admin_port: ${port}
    redis_index: ${redis_index}
    redis_prefix: "${redis_prefix}"
    created_at: "${now}"
EOF
    echo "alocação gravada em $REGISTRY"
    emit_allocation "$slug" "$db" "$port" "$redis_index" "$redis_prefix"
}

# Emite a alocação em formato consumível pelo modo (para montar o .env).
emit_allocation() {
    local slug="$1" db="$2" port="$3" idx="$4" prefix="$5"
    echo "---"
    echo "ALLOC_PROJECT=$slug"
    echo "ALLOC_DB=$db"
    echo "ALLOC_ADMIN_PORT=$port"
    echo "ALLOC_REDIS_INDEX=$idx"
    echo "ALLOC_REDIS_PREFIX=$prefix"
    echo "ALLOC_DATABASE_URI=postgresql://anvil:anvil@postgres:5432/$db"
    echo "ALLOC_REDIS_URL=redis://redis:6379/$idx"
    echo "ALLOC_NETWORK=$NETWORK_NAME"
}

# ---------- derrubada do prefixo ----------

# Só roda sob o prefixo, que o fluxo de argumentos já exigiu. Os containers da rede
# do prefixo, como o app de uma prova, saem junto: estão numa rede que só existe
# para ela, e prenderiam a rede.
teardown_infra() {
    local ids vols
    ids="$( { docker ps -aq --filter "label=com.docker.compose.project=$COMPOSE_PROJECT"
              docker ps -aq --filter "network=$NETWORK_NAME"; } | sort -u)"
    vols="$(docker volume ls -q --filter "label=com.docker.compose.project=$COMPOSE_PROJECT")"
    if $DRY_RUN; then
        echo "would  remover containers:" $ids
        echo "would  remover volumes:" $vols
        echo "would  remover a rede $NETWORK_NAME e o diretório $INFRA_DIR"
        return 0
    fi
    [[ -z "$ids" ]] || docker rm -fv $ids >/dev/null
    [[ -z "$vols" ]] || docker volume rm $vols >/dev/null
    if network_exists; then
        docker network rm "$NETWORK_NAME" >/dev/null
    fi
    rm -rf "$INFRA_DIR"
    echo "infra do prefixo $INFRA_PREFIX derrubada (compose $COMPOSE_PROJECT, rede $NETWORK_NAME, $INFRA_DIR)."
}

# ---------- fluxo principal ----------

if $TEARDOWN; then
    teardown_infra
elif [[ -n "$PROVISION" ]]; then
    # Provisionar pressupõe a infra de pé (a menos que dry-run).
    if ! $DRY_RUN; then
        ensure_infra
        health_gate
    fi
    provision_project "$PROVISION"
else
    ensure_infra
    health_gate
    echo "infra pronta."
fi
