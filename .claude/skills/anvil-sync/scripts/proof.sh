# proof.sh — o helper de prova do anvil, pelo ADR-0017: a prova roda pelo /skill:
# real, isolada do resto da máquina. Biblioteca de shell que o script da prova
# carrega; a fixture e as conferências continuam no script, em workspace/.
#
#   . .claude/skills/anvil-sync/scripts/proof.sh
#
#   proof_prepare [--remote] [--forge]
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
#       title, url, state, base e head, e as outras chamadas saem 0 sem efeito. O
#       remoto e os falsos saem com $PROOF_RUN.
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
#       prova. <modelo> casa com o <provider>/<model> da mensagem ou só com o
#       <model>; o código das conferências é 0, verde, ou 1, vermelho. Imprime, e
#       grava em <saídas>/verdict.txt, cada modelo que respondeu com quantas
#       mensagens deu, por sessão e no total, e a sessão que terminou em erro do
#       provedor, com a mensagem de erro. Não pede proof_prepare: a prova o
#       chama por último, com as saídas de proof_session.
#
# Códigos de saída: 0 verde e 1 vermelho, os das conferências; 2 ambiente ou uso
# recusado — omp, git, docker ou python3 fora do PATH, opção inválida, a fixture
# que o --remote não liga, ou a sessão que não se conduz —, com o motivo no stderr;
# 3 prova inválida, quando alguma mensagem é de outro modelo, que vale sobre o
# verde e sobre o vermelho.
# Nada é escrito em ~/.claude, ~/.agents nem no config de usuário do omp; a
# sessão guarda o jsonl dela em $PROOF_RUN.

case "${BASH_SOURCE[0]}" in
    */*) _PROOF_SCRIPTS="$(cd "${BASH_SOURCE[0]%/*}" && pwd)" ;;
    *) _PROOF_SCRIPTS="$(pwd)" ;;
esac
_PROOF_SKILLS="$(cd "$_PROOF_SCRIPTS/../../../.." && pwd)/anvil/.claude/skills"
_PROOF_PID=""
_PROOF_FORGE=""
PROOF_RUN=""
PROOF_CONFIG=""
PROOF_REMOTE=""

_proof_refuse() { echo "proof: $*" >&2; exit 2; }

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
    if [ -n "$_PROOF_PID" ]; then
        kill "$_PROOF_PID" 2>/dev/null
        wait "$_PROOF_PID" 2>/dev/null
        _PROOF_PID=""
    fi
    [ -z "$PROOF_RUN" ] || rm -rf "$PROOF_RUN"
}

proof_prepare() {
    [ -z "$PROOF_RUN" ] || _proof_refuse "proof_prepare já rodou nesta execução: $PROOF_RUN"
    local opt remote="" forge="" tool tmp="${TMPDIR:-/tmp}"
    for opt in "$@"; do
        case "$opt" in
            --remote) remote=1 ;;
            --forge) forge=1 ;;
            *) _proof_refuse "opção inválida: $opt" ;;
        esac
    done
    for tool in omp git docker python3; do
        command -v "$tool" >/dev/null 2>&1 || _proof_refuse "$tool não está no PATH"
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
            || _proof_refuse "não deu para criar o gh e o tea falsos em $_PROOF_FORGE"
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
    local model="" out="" code
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
    python3 "$_PROOF_SCRIPTS/proof-verdict.py" "$model" "$out" "$code"
    exit $?
}
