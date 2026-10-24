#!/usr/bin/env bash
# O branch base e o forge do projeto, e o que o PR precisa saber do remoto
# (ADR-0015, ADR-0016). Nada e escrito.
#
# Uso, da raiz do projeto, com o anvil na instalacao de usuario:
#   bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh
#
# Le a secao "## Git" de .claude/rules/anvil.md, com as linhas "branch base:" e
# "forge:". Cada valor declarado vale sobre a deteccao; o que falta e detectado.
#
# Saida em linhas "chave: valor", como o roadmap.sh; as chaves sao em ingles e
# estaveis, e o motivo para o operador e em pt-BR.
#   base:    o branch base. Declarado ou detectado, ele existe em refs/heads/.
#            Detectado: o de origin/HEAD; sem ele, o unico entre main e master
#   forge:   gitea, github ou nenhum. Sem remoto, nenhum
#   remote:  a URL do origin, como o git a usa, ou none sem origin
#   host:    o host real do origin, ou none sem origin ou com origin local
#   repo:    org/repo, ou none quando o caminho do origin nao da um
#   login:   so no Gitea, o login do tea que casa com o host real
#   refusal: <motivo>, uma por problema, quando nao ha resposta unica. Com
#            recusa nao sai nenhuma outra linha, e o script sai com 2. Argumento
#            e chamada fora de um repositorio git tambem saem so com refusal:
set -u

RULES=.claude/rules/anvil.md
SECTION="na seção \`## Git\` de $RULES"

refusals=""
add_refusal() { refusals="$refusals$1"$'\n'; }
refuse() { echo "refusal: $1"; exit 2; }

[ $# -eq 0 ] || refuse "argumento desconhecido '$1'; o resolve-git.sh não recebe argumentos"
root="$(git rev-parse --show-toplevel 2>/dev/null)" || refuse "fora de um repositório git"
cd "$root" || exit 1

# --- secao ## Git -------------------------------------------------------------
# O valor da primeira linha "<chave>: valor" da secao, de "## Git" ate o proximo
# titulo de nivel 1 ou 2. A linha pode vir em item de lista, e a chave e o valor
# em negrito ou crase: asterisco e crase nunca fazem parte de um nome de branch.
declared() {  # <chave>
    [ -f "$RULES" ] || return 0
    awk -v key="$1" '
        function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
        /^# / || /^## / { git = ($0 ~ /^## /) && trim(substr($0, 4)) == "Git"; next }
        !git { next }
        {
            line = $0; gsub(/[*`]/, "", line); sub(/^[ \t]*(-[ \t]+)?/, "", line)
            if (tolower(substr(line, 1, length(key) + 1)) == key ":") { print trim(substr(line, length(key) + 2)); exit }
        }
    ' "$RULES"
}
declared_base="$(declared "branch base")"
declared_forge="$(declared forge)"

# --- branch base --------------------------------------------------------------
has_branch() { git show-ref --verify --quiet "refs/heads/$1"; }
base=""
if [ -n "$declared_base" ]; then
    if has_branch "$declared_base"; then base="$declared_base"
    else add_refusal "o branch base declarado, '$declared_base', não existe em refs/heads/: corrija \`branch base:\` $SECTION, ou crie o branch"
    fi
elif origin_head="$(git symbolic-ref -q --short refs/remotes/origin/HEAD)"; then
    b="${origin_head#origin/}"
    if has_branch "$b"; then base="$b"
    else add_refusal "o origin/HEAD aponta para '$b', que não existe em refs/heads/: crie-o com \`git branch $b origin/$b\`, ou declare \`branch base: <nome>\` $SECTION"
    fi
else
    found=""
    for b in main master; do has_branch "$b" && found="$found $b"; done
    case "$found" in
        " main"|" master") base="${found# }" ;;
        "") add_refusal "branch base não detectado: sem origin/HEAD, e nem main nem master em refs/heads/; declare \`branch base: <nome>\` $SECTION" ;;
        *) add_refusal "branch base ambíguo: sem origin/HEAD, e main e master existem em refs/heads/; declare \`branch base: <nome>\` $SECTION" ;;
    esac
fi

# --- remoto -------------------------------------------------------------------
# A URL em kind (url, ssh ou local), ssh_target, host e path, lida como o git a
# le: com "://", pelo esquema; sem, e scp quando ha dois-pontos antes de qualquer
# barra; o resto e caminho local, sem host.
parse_remote() {  # <url>
    local u="$1" rest authority
    kind=local; ssh_target=""; path=""
    case "$u" in
        *://*)
            rest="${u#*://}"; authority="${rest%%/*}"; path="${rest#"$authority"}"
            case "${u%%://*}" in
                ssh|git+ssh|ssh+git) kind=ssh; ssh_target="${authority%:*}" ;;
                http|https|git) kind=url; host="${authority##*@}"; host="${host%:*}" ;;
            esac ;;
        *:*)
            rest="${u%%:*}"
            case "$rest" in */*|"") ;; *) kind=ssh; ssh_target="$rest"; path="${u#*:}" ;; esac ;;
    esac
}
# O host real de um alvo ssh: o hostname que o -G da com o comando de ssh que o
# git usaria, na ordem do git — GIT_SSH_COMMAND, core.sshCommand, GIT_SSH, ssh.
# Os dois primeiros rodam pelo shell, como o git os roda. Sai em host; na falha,
# o comando em ssh_cmd e o erro em ssh_error.
ssh_hostname() {  # <alvo>
    local out
    ssh_cmd="${GIT_SSH_COMMAND:-}"
    [ -n "$ssh_cmd" ] || ssh_cmd="$(git config --get core.sshCommand)"
    if [ -n "$ssh_cmd" ]; then out="$(sh -c "$ssh_cmd \"\$@\"" "$ssh_cmd" -G "$1" 2>&1)"
    else ssh_cmd="${GIT_SSH:-ssh}"; out="$("$ssh_cmd" -G "$1" 2>&1)"
    fi || { ssh_error="$(printf '%s\n' "$out" | sed -n 1p)"; return 1; }
    host="$(printf '%s\n' "$out" | sed -n 's/^hostname //p' | sed -n 1p)"
    [ -n "$host" ] || { ssh_error="a saída não tem a linha hostname"; return 1; }
}
# org/repo: os dois ultimos segmentos do caminho, sem .git.
repo_of() {  # <caminho>
    local p="${1%/}" name owner
    p="${p%.git}"; p="${p%/}"
    case "$p" in */*) ;; *) return ;; esac
    name="${p##*/}"; owner="${p%/*}"; owner="${owner##*/}"
    [ -n "$name" ] && [ -n "$owner" ] && echo "$owner/$name"
}

# --- login do tea -------------------------------------------------------------
# No Gitea, o login do tea cujo host do url ou cujo ssh_host e o host real. Sem
# --login, o tea cai no login padrao quando nenhum casa (ADR-0016); aqui, nenhum
# ou mais de um e recusa. O python3 le o JSON e devolve uma linha por login,
# separada por tabulacao: m quando casa e - quando nao, o nome, o url e o
# ssh_host, com - no campo vazio.
login=""
tea_login() {
    local json rows m name url ssh n=0 matches="" seen=""
    command -v tea >/dev/null 2>&1 || {
        add_refusal "o forge é gitea, e o tea não está no PATH: instale-o e crie o login com \`tea login add --name <nome> --url https://$host\`"; return; }
    command -v python3 >/dev/null 2>&1 || {
        add_refusal "o forge é gitea, e falta o python3 para ler o \`tea login list --output json\`"; return; }
    json="$(tea login list --output json 2>/dev/null)" || {
        add_refusal "o \`tea login list --output json\` falhou: $(tea login list --output json 2>&1 >/dev/null | sed -n 1p)"; return; }
    rows="$(printf '%s' "$json" | python3 -c '
import json, sys
from urllib.parse import urlsplit
try:
    logins = json.load(sys.stdin)
except ValueError:
    sys.exit(1)
if not isinstance(logins, list):
    sys.exit(1)
for l in logins:
    if not isinstance(l, dict):
        continue
    name, url, ssh = (str(l.get(k) or "").replace("\t", " ") for k in ("name", "url", "ssh_host"))
    try:
        url_host = urlsplit(url).hostname or ""
    except ValueError:
        url_host = ""
    hit = sys.argv[1] in (url_host, ssh.lower())
    print("\t".join(("m" if hit else "-", name or "-", url or "-", ssh or "-")))
' "$host")" || {
        add_refusal "a saída do \`tea login list --output json\` não é uma lista JSON de logins"; return; }
    while IFS=$'\t' read -r m name url ssh; do
        [ -n "$m" ] || continue
        seen="$seen${seen:+; }$name (url $url, ssh_host $ssh)"
        [ "$m" = m ] && { n=$((n + 1)); matches="$matches${matches:+, }$name"; }
    done <<EOF
$rows
EOF
    case "$n" in
        1) login="$matches" ;;
        0) add_refusal "nenhum login do tea casa com o host '$host' pelo url nem pelo ssh_host; logins vistos: ${seen:-nenhum}. Crie um com \`tea login add --name <nome> --url https://$host\`, ou acerte o url ou o ssh_host de um existente com \`tea login edit\`" ;;
        *) add_refusal "mais de um login do tea casa com o host '$host': $matches; logins vistos: $seen. Deixe um só casando, com \`tea login delete <nome>\` ou acertando o url ou o ssh_host em \`tea login edit\`" ;;
    esac
}

# --- forge --------------------------------------------------------------------
# Sem origin, o forge e nenhum, qualquer que seja o declarado: nao ha onde abrir
# PR, e a spec fecha por merge local. Origin em caminho local tambem nao tem
# forge, e com gitea ou github declarado e recusa.
forge=nenhum; remote=none; host=none; repo=none
resolve_forge() {
    case "$declared_forge" in
        ""|gitea|github|nenhum) ;;
        *) add_refusal "o forge declarado, '$declared_forge', não é gitea, github nem nenhum: corrija \`forge:\` $SECTION"; return ;;
    esac
    remote="$(git remote get-url origin 2>/dev/null)" || { remote=none; return; }
    parse_remote "$remote"
    case "$kind" in
        local)
            case "$declared_forge" in gitea|github)
                add_refusal "o forge declarado é $declared_forge, e o origin, '$remote', é um caminho local, sem host: aponte o origin para o servidor, ou corrija \`forge:\` $SECTION" ;;
            esac
            return ;;
        ssh)
            ssh_hostname "$ssh_target" || {
                add_refusal "não deu para achar o host real de '$ssh_target' com \`$ssh_cmd -G $ssh_target\`, o comando de ssh que o git usaria: $ssh_error"; return; } ;;
    esac
    host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"
    forge="$declared_forge"
    if [ -z "$forge" ]; then
        if [ "$host" = github.com ]; then forge=github
        else
            add_refusal "o origin, '$remote', está em '$host', que não é github.com, e o forge não está declarado: declare \`forge: gitea\`, \`forge: github\` ou \`forge: nenhum\` $SECTION"
            return
        fi
    fi
    repo="$(repo_of "$path")"
    if [ -z "$repo" ]; then
        repo=none
        [ "$forge" = nenhum ] || add_refusal "o forge é $forge, e o caminho do origin, '$remote', não dá um org/repo"
        return
    fi
    [ "$forge" != gitea ] || tea_login
}
resolve_forge

if [ -n "$refusals" ]; then
    printf '%s' "$refusals" | while IFS= read -r l; do echo "refusal: $l"; done
    exit 2
fi
echo "base: $base"
echo "forge: $forge"
echo "remote: $remote"
echo "host: $host"
echo "repo: $repo"
[ -z "$login" ] || echo "login: $login"
