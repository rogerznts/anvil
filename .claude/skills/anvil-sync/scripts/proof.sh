# proof.sh — o helper de prova do anvil, pelo ADR-0017: a prova roda pelo /skill:
# real, isolada do resto da máquina. Biblioteca de shell que o script da prova
# carrega; a fixture e as conferências continuam no script, em workspace/.
#
#   . .claude/skills/anvil-sync/scripts/proof.sh
#
#   proof_prepare
#       Cria o diretório da execução, $PROOF_RUN, com nome único (mktemp -d), e
#       nele o overlay de config do omp, $PROOF_CONFIG: skills.customDirectories
#       com as skills do payload e da camada omp desta árvore, que têm precedência
#       sobre a instalação de usuário, e retry.modelFallback: false. Arma a
#       limpeza num trap de EXIT, INT, TERM e HUP, que remove $PROOF_RUN também na
#       falha e na interrupção. O trap é do helper: a prova não arma outro.
#
#   proof_session --model <modelo> --cwd <fixture> --out <saídas> -- <turno>...
#       Conduz a sessão pelo rpc do omp (proof-rpc.py): o primeiro turno é
#       "/skill:<nome> …", como o operador digita; cada turno seguinte vai depois
#       do prompt_result e do session_settled do anterior. Em <saídas>, que fica
#       fora de $PROOF_RUN — o diretório da prova em workspace/ —, ficam
#       frames.jsonl, os frames do rpc; session.jsonl, a cópia do jsonl da sessão
#       principal, achado pelo sessionFile do get_state; e omp.err.
#
# Saída 2: ambiente ou uso recusado — omp, git, docker ou python3 fora do PATH,
# opção inválida, ou a sessão que não se conduz —, com o motivo no stderr. Nada
# é escrito em ~/.claude, ~/.agents nem no config de usuário do omp; a sessão
# guarda o jsonl dela em $PROOF_RUN.

case "${BASH_SOURCE[0]}" in
    */*) _PROOF_SCRIPTS="$(cd "${BASH_SOURCE[0]%/*}" && pwd)" ;;
    *) _PROOF_SCRIPTS="$(pwd)" ;;
esac
_PROOF_SKILLS="$(cd "$_PROOF_SCRIPTS/../../../.." && pwd)/anvil/.claude/skills"
_PROOF_PID=""
PROOF_RUN=""
PROOF_CONFIG=""

_proof_refuse() { echo "proof: $*" >&2; exit 2; }

_proof_cleanup() {
    if [ -n "$_PROOF_PID" ]; then
        kill "$_PROOF_PID" 2>/dev/null
        wait "$_PROOF_PID" 2>/dev/null
        _PROOF_PID=""
    fi
    [ -z "$PROOF_RUN" ] || rm -rf "$PROOF_RUN"
}

proof_prepare() {
    [ $# -eq 0 ] || _proof_refuse "opção inválida: $1"
    [ -z "$PROOF_RUN" ] || _proof_refuse "proof_prepare já rodou nesta execução: $PROOF_RUN"
    local tool tmp="${TMPDIR:-/tmp}"
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
    # Em segundo plano, para que o trap rode no sinal sem esperar a sessão acabar.
    python3 "$_PROOF_SCRIPTS/proof-rpc.py" --config "$PROOF_CONFIG" --model "$model" \
        --cwd "$cwd" --session-dir "$PROOF_RUN/sessions" --out "$out" -- "$@" &
    _PROOF_PID=$!
    wait "$_PROOF_PID"; rc=$?
    _PROOF_PID=""
    [ "$rc" -eq 0 ] || exit 2
}
