#!/usr/bin/env bash
# O branch base e o forge do projeto, e o que o PR precisa saber do remoto
# (ADR-0015, ADR-0016). Nada e escrito.
#
# Uso, da raiz do projeto, com o anvil na instalacao de usuario:
#   bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh [--pr]
#
# Le a secao "## Git" de .claude/rules/anvil.md, com as linhas "branch base:" e
# "forge:". Cada valor declarado vale sobre a deteccao; o que falta e detectado.
#
# --pr: um PR vai sair, e no Gitea o resolvedor procura tambem o login do tea. Sem
# a opcao, o tea nao e chamado, e nao sai login: nem recusa de login.
#
# Saida em linhas "chave: valor", como o roadmap.sh; as chaves sao em ingles e
# estaveis, e o motivo para o operador e em pt-BR. Todo valor resolvido sai, mesmo
# com recusa noutro campo; o campo recusado nao sai.
#   base:    o branch base. Declarado ou detectado, ele existe em refs/heads/.
#            Detectado: o de origin/HEAD; sem ele, o unico entre main e master
#   forge:   gitea, github ou nenhum. Sem remoto, nenhum
#   remote:  a URL do origin, como o git a usa, ou none sem origin
#   host:    o host real do origin, ou none sem origin ou com origin local. Nao
#            sai quando o host real do alvo ssh nao se acha
#   repo:    org/repo, ou none quando o caminho do origin nao da um
#   login:   so com --pr e no Gitea, o login do tea que casa com o host real
#   refusal: <campo>: <motivo>, uma por problema, depois dos valores, quando nao
#            ha resposta unica. O campo e o que a recusa atinge: base, forge ou
#            login. A de forge cobre tambem o host real que nao se acha e o
#            caminho do origin sem org/repo, sem os quais nao ha onde abrir PR.
#            Com qualquer recusa o script sai com 2, e quem chama confere so os
#            campos de que precisa: o base, para abrir spec, comecar o piloto e
#            limpar branches; o base, o forge, o repo e o login, para abrir PR.
#            Argumento desconhecido e chamada fora de um repositorio git saem so
#            com uma refusal: base:, tambem com 2: sem eles nada se resolve, e todo
#            consumidor confere o base
set -u

RULES=.claude/rules/anvil.md
SECTION="na seção \`## Git\` de $RULES"

refusals=""
add_refusal() { refusals="$refusals$1: $2"$'\n'; }  # <campo> <motivo>
refuse() { echo "refusal: base: $1"; exit 2; }

pr=0
while [ $# -gt 0 ]; do
    case "$1" in
        --pr) pr=1; shift ;;
        *) refuse "argumento desconhecido '$1'; o único é --pr" ;;
    esac
done
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
    else add_refusal base "o branch base declarado, '$declared_base', não existe em refs/heads/: corrija \`branch base:\` $SECTION, ou crie o branch"
    fi
elif origin_head="$(git symbolic-ref -q --short refs/remotes/origin/HEAD)"; then
    b="${origin_head#origin/}"
    if has_branch "$b"; then base="$b"
    else add_refusal base "o origin/HEAD aponta para '$b', que não existe em refs/heads/: crie-o com \`git branch $b origin/$b\`, ou declare \`branch base: <nome>\` $SECTION"
    fi
else
    found=""
    for b in main master; do has_branch "$b" && found="$found $b"; done
    case "$found" in
        " main"|" master") base="${found# }" ;;
        "") add_refusal base "branch base não detectado: sem origin/HEAD, e nem main nem master em refs/heads/; declare \`branch base: <nome>\` $SECTION" ;;
        *) add_refusal base "branch base ambíguo: sem origin/HEAD, e main e master existem em refs/heads/; declare \`branch base: <nome>\` $SECTION" ;;
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

# O remoto, o host real e o org/repo saem do origin, com qualquer forge. O host
# vazio e o real que nao se achou, com o motivo em host_refusal.
remote=none; host=none; repo=none; kind=""; host_refusal=""
if remote="$(git remote get-url origin 2>/dev/null)"; then
    parse_remote "$remote"
    case "$kind" in
        local) host=none ;;
        ssh)
            ssh_hostname "$ssh_target" || {
                host=""
                host_refusal="não deu para achar o host real de '$ssh_target' com \`$ssh_cmd -G $ssh_target\`, o comando de ssh que o git usaria: $ssh_error"; } ;;
    esac
    host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"
    repo="$(repo_of "$path")"; [ -n "$repo" ] || repo=none
else
    remote=none
fi

# --- forge --------------------------------------------------------------------
# Sem origin, o forge e nenhum, qualquer que seja o declarado: nao ha onde abrir
# PR, e a spec fecha por merge local. Origin em caminho local tambem nao tem
# forge, e com gitea ou github declarado e recusa.
forge=""
resolve_forge() {
    local f="$declared_forge"
    case "$f" in
        ""|gitea|github|nenhum) ;;
        *) add_refusal forge "o forge declarado, '$f', não é gitea, github nem nenhum: corrija \`forge:\` $SECTION"; return ;;
    esac
    [ "$remote" != none ] || { forge=nenhum; return; }
    if [ "$kind" = local ]; then
        case "$f" in gitea|github)
            add_refusal forge "o forge declarado é $f, e o origin, '$remote', é um caminho local, sem host: aponte o origin para o servidor, ou corrija \`forge:\` $SECTION"
            return ;;
        esac
        forge=nenhum; return
    fi
    [ -n "$host" ] || { add_refusal forge "$host_refusal"; return; }
    if [ -z "$f" ]; then
        if [ "$host" = github.com ]; then f=github
        else
            add_refusal forge "o origin, '$remote', está em '$host', que não é github.com, e o forge não está declarado: declare \`forge: gitea\`, \`forge: github\` ou \`forge: nenhum\` $SECTION"
            return
        fi
    fi
    if [ "$repo" = none ] && [ "$f" != nenhum ]; then
        add_refusal forge "o forge é $f, e o caminho do origin, '$remote', não dá um org/repo"
        return
    fi
    forge="$f"
}
resolve_forge

# --- login do tea -------------------------------------------------------------
# So com --pr, no Gitea: o login do tea cujo host do url ou cujo ssh_host e o host
# real. Sem --login, o tea cai no login padrao quando nenhum casa (ADR-0016); aqui,
# nenhum ou mais de um e recusa. O python3 le o JSON e devolve uma linha por
# login, separada por tabulacao: m quando casa e - quando nao, o nome, o url e o
# ssh_host, com - no campo vazio.
login=""
tea_login() {
    local json rows m name url ssh n=0 matches="" seen=""
    command -v tea >/dev/null 2>&1 || {
        add_refusal login "o forge é gitea, e o tea não está no PATH: instale-o e crie o login com \`tea login add --name <nome> --url https://$host\`"; return; }
    command -v python3 >/dev/null 2>&1 || {
        add_refusal login "o forge é gitea, e falta o python3 para ler o \`tea login list --output json\`"; return; }
    json="$(tea login list --output json 2>/dev/null)" || {
        add_refusal login "o \`tea login list --output json\` falhou: $(tea login list --output json 2>&1 >/dev/null | sed -n 1p)"; return; }
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
        add_refusal login "a saída do \`tea login list --output json\` não é uma lista JSON de logins"; return; }
    while IFS=$'\t' read -r m name url ssh; do
        [ -n "$m" ] || continue
        seen="$seen${seen:+; }$name (url $url, ssh_host $ssh)"
        [ "$m" = m ] && { n=$((n + 1)); matches="$matches${matches:+, }$name"; }
    done <<EOF
$rows
EOF
    case "$n" in
        1) login="$matches" ;;
        0) add_refusal login "nenhum login do tea casa com o host '$host' pelo url nem pelo ssh_host; logins vistos: ${seen:-nenhum}. Crie um com \`tea login add --name <nome> --url https://$host\`, ou acerte o url ou o ssh_host de um existente com \`tea login edit\`" ;;
        *) add_refusal login "mais de um login do tea casa com o host '$host': $matches; logins vistos: $seen. Deixe um só casando, com \`tea login delete <nome>\` ou acertando o url ou o ssh_host em \`tea login edit\`" ;;
    esac
}
[ "$pr" -eq 0 ] || [ "$forge" != gitea ] || tea_login

[ -z "$base" ] || echo "base: $base"
[ -z "$forge" ] || echo "forge: $forge"
echo "remote: $remote"
[ -z "$host" ] || echo "host: $host"
echo "repo: $repo"
[ -z "$login" ] || echo "login: $login"
[ -n "$refusals" ] || exit 0
printf '%s' "$refusals" | while IFS= read -r l; do echo "refusal: $l"; done
exit 2
