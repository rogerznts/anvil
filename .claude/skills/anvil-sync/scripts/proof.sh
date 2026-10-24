# proof.sh — o helper de prova do anvil, pelo ADR-0017: a prova roda pelo /skill:
# real, isolada do resto da máquina. Biblioteca de shell que o script da prova
# carrega; a fixture e as conferências continuam no script, em workspace/.
#
#   . .claude/skills/anvil-sync/scripts/proof.sh
#
#   proof_prepare [--remote] [--forge [--tea-login <l>]... [--labels <r>]] [--infra] [--dep <skill>]...
#       Cria o diretório da execução, $PROOF_RUN, com nome único (mktemp -d), e
#       nele o overlay de config do omp, $PROOF_CONFIG: skills.customDirectories
#       com as skills do payload e da camada omp desta árvore, que têm precedência
#       sobre a instalação de usuário, e retry.modelFallback: false. Arma a
#       limpeza num trap de EXIT, INT, TERM e HUP, que remove $PROOF_RUN também na
#       falha e na interrupção. O trap é do helper: a prova não arma outro.
#       --remote cria o remoto bare $PROOF_REMOTE, $PROOF_RUN/origin.git, que o
#       proof_session liga como origin da fixture. --forge cria um gh e um tea
#       falsos em $PROOF_RUN/forge (proof-forge.py), que o proof_session põe à
#       frente do PATH da sessão: cada chamada grava a ferramenta, os argumentos e
#       o diretório em $PROOF_RUN/forge.jsonl; o gh pr create imprime a URL do PR
#       no stdout, o tea pr create --output json imprime o objeto com index,
#       title, url, state, base e head, o tea login list --output json imprime os
#       logins configurados, o gh label list e o tea labels list imprimem os
#       rótulos, e as outras chamadas saem 0 sem efeito; as formas de cada resposta
#       estão no proof-forge.py.
#       --tea-login <nome>,<url>,<ssh_host>,<padrão>, uma vez por login, pede
#       --forge e configura um login do tea falso: o tea login list --output json
#       o devolve no formato do tea real, com name, url, ssh_host, user e default.
#       O ssh_host pode ir vazio, e então o tea real dá o host:porta do url; o
#       padrão é true ou false; o user é prova. Sem --tea-login, a lista é vazia.
#       --labels <rótulo>,<rótulo>…, uma vez só, pede --forge e configura os rótulos
#       que o gh label list e o tea labels list falsos devolvem, na cor ededed e sem
#       descrição; vazio, o repositório sem rótulo. Sem --labels, os rótulos são os
#       que o GitHub cria num repositório novo. O remoto e os falsos, com a
#       configuração deles, saem com $PROOF_RUN. --infra liga o prefixo de execução
#       do infra.sh do bench, ANVIL_INFRA_PREFIX, com o id da execução, exportado
#       para o script da prova e para a sessão: todo infra.sh que eles rodam usa a
#       infra do prefixo, com compose, rede, registro e volumes próprios. A limpeza
#       a derruba (infra.sh --teardown, da fonte) antes de remover $PROOF_RUN,
#       também na falha e na interrupção.
#       --dep <skill>, uma vez por skill, declara uma dependência da prova: uma
#       skill que o payload chama por ~/.claude/skills/<skill>/…, caminho que o
#       overlay não cria. Antes de criar $PROOF_RUN, o helper confere que
#       ~/.claude/skills/<skill> é um link para o payload desta árvore; se não for,
#       sai 2 com a skill e o comando do dev-link.sh no motivo. O helper não cria
#       nem remove link: quem liga é o operador.
#
#   proof_session --model <modelo> --cwd <fixture> --out <saídas> -- <turno>...
#       Conduz a sessão pelo rpc do omp (proof-rpc.py): o primeiro turno é
#       "/skill:<nome> …", como o operador digita; cada turno seguinte vai depois
#       do prompt_result e do session_settled do anterior. Os frames de subagente
#       vão assinados. Com --remote, antes de abrir a sessão, liga o bare como
#       origin da fixture, que precisa ser a raiz de um repositório git, num branch
#       com commit, e sem outro origin, e publica nele o branch atual dela, com
#       upstream; a fixture que já o tem como origin fica como está. Com --forge, o
#       gh e o tea falsos vão à frente do PATH só da sessão, e não no do script da
#       prova. Em <saídas>, que fica fora de $PROOF_RUN — o diretório da prova em
#       workspace/ —, ficam frames.jsonl, os frames do rpc; session.jsonl, a cópia
#       do jsonl da sessão principal, achado pelo sessionFile do get_state;
#       subagents/<id>.jsonl, a cópia do jsonl de cada sessão de subagente que ela
#       abriu, achado pelos frames de subagente; omp.err; e, com --forge,
#       forge.jsonl, a cópia do log do gh e do tea falsos.
#
#   proof_verdict --model <modelo> --out <saídas> <código das conferências>
#       Confere o modelo de toda mensagem do assistente em session.jsonl e em
#       subagents/*.jsonl de <saídas> (proof-verdict.py), e sai com o código da
#       prova. A sessão principal é julgada pelo modelo pedido: <modelo> casa com
#       o <provider>/<model> da mensagem ou só com o <model>. Cada subagente, por
#       um modelo só do começo ao fim: o que tem modelo próprio por papel ou por
#       frontmatter, diferente do pedido, não invalida e vai para o relatório. O
#       código das conferências é 0, verde, ou 1, vermelho. Imprime, e grava em
#       <saídas>/verdict.txt, cada modelo que respondeu com quantas mensagens deu,
#       por sessão e no total, e a sessão que terminou em erro do provedor, com a
#       mensagem de erro. Não pede proof_prepare: a prova o chama por último, com
#       as saídas de proof_session.
#
# Códigos de saída: 0 verde e 1 vermelho, os das conferências; 2 ambiente ou uso
# recusado — omp, git, docker ou python3 fora do PATH, opção inválida, o
# --tea-login ou o --labels fora da forma ou sem --forge, a fixture
# que o --remote não liga, a dependência declarada que não é link para esta árvore,
# a sessão que não se conduz, ou a falha do próprio script de veredito, que nunca
# vira 1 —, com o motivo no stderr; 3 prova inválida, quando a sessão principal tem
# mensagem de outro modelo que não o pedido ou um subagente tem mais de um modelo,
# que vale sobre o verde e sobre o vermelho.
# Nada é escrito em ~/.claude, ~/.agents nem no config de usuário do omp; a
# sessão guarda o jsonl dela em $PROOF_RUN. Com --infra, o registro do prefixo, em
# ~/projects/.<prefixo>-anvil-infra/, vive até a derrubada.

case "${BASH_SOURCE[0]}" in
    */*) _PROOF_SCRIPTS="$(cd "${BASH_SOURCE[0]%/*}" && pwd)" ;;
    *) _PROOF_SCRIPTS="$(pwd)" ;;
esac
_PROOF_SKILLS="$(cd "$_PROOF_SCRIPTS/../../../.." && pwd)/anvil/.claude/skills"
_PROOF_PID=""
_PROOF_FORGE=""
_PROOF_INFRA=""
PROOF_RUN=""
PROOF_CONFIG=""
PROOF_REMOTE=""

_proof_refuse() { echo "proof: $*" >&2; exit 2; }

# <nome>,<url>,<ssh_host>,<padrão>: quatro campos numa linha, o nome e o url não
# vazios, o ssh_host vazio ou não, e o padrão true ou false.
_proof_tea_login_ok() {
    local commas="${1//[!,]/}" name url rest
    case "$1" in *"
"*) return 1 ;; esac
    [ "${#commas}" -eq 3 ] || return 1
    name="${1%%,*}"; rest="${1#*,}"; url="${rest%%,*}"
    [ -n "$name" ] && [ -n "$url" ] || return 1
    case "${1##*,}" in true|false) return 0 ;; *) return 1 ;; esac
}

# Liga o remoto bare como origin da fixture <dir> e publica nele o branch atual dela,
# com upstream; a fixture que já o tem como origin fica como está.
_proof_publish() {
    local fx="$1" url branch
    url="$(git -C "$fx" remote get-url origin 2>/dev/null)" || url=""
    [ "$url" != "$PROOF_REMOTE" ] || return 0
    [ "$(git -C "$fx" rev-parse --show-toplevel 2>/dev/null)" = "$(cd "$fx" && pwd -P)" ] \
        || _proof_refuse "a opção --remote pede a fixture na raiz de um repositório git: $fx"
    [ -z "$url" ] || _proof_refuse "a fixture já tem um origin, $url; a opção --remote liga o dela"
    branch="$(git -C "$fx" symbolic-ref -q --short HEAD)" && git -C "$fx" rev-parse -q --verify HEAD >/dev/null \
        || _proof_refuse "a opção --remote pede a fixture num branch com commit: $fx"
    git -C "$fx" remote add origin "$PROOF_REMOTE" \
        && git -C "$fx" push -q -u origin "$branch" \
        && git --git-dir="$PROOF_REMOTE" symbolic-ref HEAD "refs/heads/$branch" \
        || _proof_refuse "não deu para publicar o branch $branch da fixture em $PROOF_REMOTE"
}

_proof_cleanup() {
    local out
    if [ -n "$_PROOF_PID" ]; then
        kill "$_PROOF_PID" 2>/dev/null
        wait "$_PROOF_PID" 2>/dev/null
        _PROOF_PID=""
    fi
    if [ -n "$_PROOF_INFRA" ]; then
        out="$(ANVIL_INFRA_PREFIX="$_PROOF_INFRA" bash "$_PROOF_SKILLS/anvil-stack-payload/bench/infra.sh" --teardown 2>&1)" \
            || echo "proof: a derrubada da infra do prefixo $_PROOF_INFRA falhou: $out" >&2
        _PROOF_INFRA=""
    fi
    [ -z "$PROOF_RUN" ] || rm -rf "$PROOF_RUN"
}

proof_prepare() {
    [ -z "$PROOF_RUN" ] || _proof_refuse "proof_prepare já rodou nesta execução: $PROOF_RUN"
    local remote="" forge="" infra="" deps="" logins="" labels="" labels_set="" skill tool tmp="${TMPDIR:-/tmp}"
    while [ $# -gt 0 ]; do
        case "$1" in
            --remote) remote=1 ;;
            --forge) forge=1 ;;
            --infra) infra=1 ;;
            --dep)
                [ $# -ge 2 ] || _proof_refuse "--dep pede o nome de uma skill"
                case "$2" in
                    ""|.|..|*/*) _proof_refuse "--dep pede o nome de uma skill do payload: $2" ;;
                esac
                [ -d "$_PROOF_SKILLS/$2" ] || _proof_refuse "--dep $2: não é skill do payload desta árvore, $_PROOF_SKILLS"
                deps="$deps $2"
                shift ;;
            --tea-login)
                [ $# -ge 2 ] && _proof_tea_login_ok "$2" \
                    || _proof_refuse "--tea-login pede <nome>,<url>,<ssh_host>,<padrão>, com o nome e o url não vazios, o ssh_host vazio ou não, e o padrão true ou false: ${2-}"
                logins="$logins$2
"
                shift ;;
            --labels)
                [ $# -ge 2 ] || _proof_refuse "--labels pede a lista de rótulos separados por vírgula, vazia para nenhum"
                [ -z "$labels_set" ] || _proof_refuse "--labels vem uma vez só"
                labels="$2"; labels_set=1
                shift ;;
            *) _proof_refuse "opção inválida: $1" ;;
        esac
        shift
    done
    [ -n "$forge" ] || [ -z "$logins$labels_set" ] \
        || _proof_refuse "--tea-login e --labels configuram o gh e o tea falsos, e pedem --forge"
    for tool in omp git docker python3; do
        command -v "$tool" >/dev/null 2>&1 || _proof_refuse "$tool não está no PATH"
    done
    # O payload chama essas skills por ~/.claude/skills/<skill>/…, que o overlay
    # não cria: o link tem de levar ao payload desta árvore. Quem liga é o operador.
    for skill in $deps; do
        [ -L "$HOME/.claude/skills/$skill" ] \
            && [ "$(cd "$HOME/.claude/skills/$skill" 2>/dev/null && pwd -P)" = "$(cd "$_PROOF_SKILLS/$skill" && pwd -P)" ] \
            || _proof_refuse "a prova depende de ~/.claude/skills/$skill, que não é um link para $_PROOF_SKILLS/$skill; ligue com bash $_PROOF_SCRIPTS/dev-link.sh --all"
    done
    trap '_proof_cleanup' EXIT
    trap 'exit 129' HUP
    trap 'exit 130' INT
    trap 'exit 143' TERM
    PROOF_RUN="$(mktemp -d "${tmp%/}/anvil-proof.XXXXXX")" || _proof_refuse "mktemp -d falhou"
    PROOF_CONFIG="$PROOF_RUN/omp-config.yml"
    printf '%s\n' \
        "# overlay do omp desta execução da prova (proof.sh)" \
        "skills:" \
        "  customDirectories:" \
        "    - \"$_PROOF_SKILLS\"" \
        "    - \"$_PROOF_SKILLS/anvil-update/.omp-layer/skills\"" \
        "retry:" \
        "  modelFallback: false" > "$PROOF_CONFIG" || _proof_refuse "não deu para escrever $PROOF_CONFIG"
    if [ -n "$remote" ]; then
        PROOF_REMOTE="$PROOF_RUN/origin.git"
        git init -q --bare "$PROOF_REMOTE" || _proof_refuse "não deu para criar o remoto bare $PROOF_REMOTE"
    fi
    if [ -n "$forge" ]; then
        _PROOF_FORGE="$PROOF_RUN/forge"
        mkdir "$_PROOF_FORGE" \
            && ln -s "$_PROOF_SCRIPTS/proof-forge.py" "$_PROOF_FORGE/gh" \
            && ln -s "$_PROOF_SCRIPTS/proof-forge.py" "$_PROOF_FORGE/tea" \
            && : > "$PROOF_RUN/forge.jsonl" \
            && printf '%s' "$logins" > "$PROOF_RUN/forge-tea-logins" \
            && { [ -z "$labels_set" ] || printf '%s' "$labels" > "$PROOF_RUN/forge-labels"; } \
            || _proof_refuse "não deu para criar o gh e o tea falsos em $_PROOF_FORGE"
    fi
    if [ -n "$infra" ]; then
        # O id da execução é o sufixo do mktemp, em hexadecimal: o prefixo do infra.sh
        # só aceita minúsculas, e o sufixo distingue maiúsculas.
        _PROOF_INFRA="proof-$(printf '%s' "${PROOF_RUN##*.}" | od -An -tx1 | tr -d ' \n')"
        export ANVIL_INFRA_PREFIX="$_PROOF_INFRA"
    fi
}

proof_session() {
    [ -n "$PROOF_RUN" ] || _proof_refuse "rode proof_prepare antes de proof_session"
    local model="" cwd="" out="" rc
    while [ $# -gt 0 ]; do
        case "$1" in
            --) shift; break ;;
            --model|--cwd|--out)
                [ $# -ge 2 ] || _proof_refuse "$1 pede um valor"
                case "$1" in --model) model="$2" ;; --cwd) cwd="$2" ;; --out) out="$2" ;; esac
                shift 2 ;;
            *) _proof_refuse "opção inválida: $1" ;;
        esac
    done
    [ -n "$model" ] || _proof_refuse "proof_session pede --model"
    [ -n "$cwd" ] && [ -d "$cwd" ] || _proof_refuse "proof_session pede --cwd com o diretório da fixture"
    [ -n "$out" ] || _proof_refuse "proof_session pede --out com o diretório das saídas"
    [ $# -gt 0 ] || _proof_refuse "proof_session pede ao menos um turno, depois de --"
    case "$1" in
        /skill:?*) ;;
        *) _proof_refuse "o primeiro turno é /skill:<nome> …, como o operador digita: $1" ;;
    esac
    mkdir -p "$out" || _proof_refuse "não deu para criar $out"
    [ -z "$PROOF_REMOTE" ] || _proof_publish "$cwd"
    # Em segundo plano, para que o trap rode no sinal sem esperar a sessão acabar. O
    # gh e o tea falsos vão à frente do PATH só da sessão.
    PATH="${_PROOF_FORGE:+$_PROOF_FORGE:}$PATH" python3 "$_PROOF_SCRIPTS/proof-rpc.py" \
        --config "$PROOF_CONFIG" --model "$model" \
        --cwd "$cwd" --session-dir "$PROOF_RUN/sessions" --out "$out" -- "$@" &
    _PROOF_PID=$!
    wait "$_PROOF_PID"; rc=$?
    _PROOF_PID=""
    if [ -n "$_PROOF_FORGE" ]; then
        cp "$PROOF_RUN/forge.jsonl" "$out/forge.jsonl" || _proof_refuse "não deu para copiar o log do forge para $out"
    else
        rm -f "$out/forge.jsonl"
    fi
    [ "$rc" -eq 0 ] || exit 2
}

proof_verdict() {
    local model="" out="" code err rc
    while [ $# -gt 1 ]; do
        case "$1" in
            --model) model="$2"; shift 2 ;;
            --out) out="$2"; shift 2 ;;
            *) _proof_refuse "opção inválida: $1" ;;
        esac
    done
    code="${1:-}"
    [ -n "$model" ] || _proof_refuse "proof_verdict pede --model"
    [ -n "$out" ] && [ -f "$out/session.jsonl" ] || _proof_refuse "proof_verdict pede --out com as saídas da sessão, e $out/session.jsonl não existe"
    case "$code" in
        0|1) ;;
        *) _proof_refuse "o código das conferências é 0 ou 1: $code" ;;
    esac
    command -v python3 >/dev/null 2>&1 || _proof_refuse "python3 não está no PATH"
    # O script de veredito sai com o código da prova e grava o verdict.txt por
    # último; o que sai de outro jeito é falha dele, de ambiente, e nunca vermelho. O
    # stdout passa; o stderr fica para o motivo.
    rm -f "$out/verdict.txt"
    { err="$(python3 "$_PROOF_SCRIPTS/proof-verdict.py" "$model" "$out" "$code" 2>&1 1>&3 3>&-)"; } 3>&1
    rc=$?
    case "$rc" in
        0|1|3) if [ -f "$out/verdict.txt" ]; then
                   [ -z "$err" ] || printf '%s\n' "$err" >&2
                   exit "$rc"
               fi ;;
    esac
    _proof_refuse "o script de veredito falhou, com saída $rc, e a prova fica sem código: ${err:-sem mensagem}"
}
