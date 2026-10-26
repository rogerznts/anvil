#!/usr/bin/env bash
# Executa um comando externo no HOME dev persistente deste checkout.
# Nao muda cwd/PATH, nao importa auth/config e nao inicia shell de login.
# Nao e sandbox: ambiente, sockets, Keychain e caminhos absolutos continuam
# capacidades herdadas. Configure/login dev explicitamente pelo launcher.
# Compativel com Bash 3.2. Saida do filho preservada por exec; uso recusado: 2.
set -euo pipefail
umask 077

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd -P)"
DEV_HOME="$ROOT/workspace/anvil-dev/home"
DRY=0
fail() { printf 'erro: %s\n' "$*" >&2; exit 2; }
usage() {
    cat <<'HELP'
Uso: bash dev-run.sh [--dry-run] -- <comando> [args...]

Resolve um executavel no PATH atual, prepara todo o payload com dev-link --all
no HOME privado workspace/anvil-dev/home e executa sem mudar o diretorio atual.
Para abrir uma sessao humana, rode da raiz do checkout. Filhos herdam HOME e
seletores privados; scripts ~/ passam a usar a fonte deste checkout.

Nao copia configuracoes ou credenciais pessoais. Login/config dev sao separados.
PATH e credenciais de ambiente permanecem herdados (sem gravar seus valores).
Nao e sandbox; ferramentas arbitrarias, servicos externos e caminhos absolutos
nao sao confinados. Nao inicie shell de login: ele pode desfazer a selecao.
Expanda ~/ dentro do filho, nao no shell chamador: -- bash -c 'echo "$HOME"'.

--dry-run valida e descreve sem writes nem execucao do comando.
omp: --profile/-profile e --alias sao recusados; OMP_PROFILE e PI_CONFIG_FILES
herdados sao removidos. Codex: --remote e overrides do armazenamento de auth
sao recusados; o launcher impoe --no-daemon e cli_auth_credentials_store="file".
Overrides arbitrarios de configuracao/caminhos nao fazem parte da garantia.
HELP
}
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY=1; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        *) fail 'use [--dry-run] -- <comando> [args...]' ;;
    esac
done
[ $# -gt 0 ] || fail 'falta <comando> depois de --'
COMMAND="$1"
shift
NAME="${COMMAND##*/}"

# type -P ignora funcoes/builtins; a resolucao antecede qualquer troca de HOME.
# Converte entradas relativas do PATH em caminho absoluto sem mudar o cwd.
if ! EXECUTABLE="$(type -P -- "$COMMAND")"; then
    printf 'erro: executavel nao encontrado no PATH: %s\n' "$COMMAND" >&2
    exit 127
fi
case "$EXECUTABLE" in /*) ;; *) EXECUTABLE="$PWD/$EXECUTABLE" ;; esac
[ -f "$EXECUTABLE" ] && [ -x "$EXECUTABLE" ] || { printf 'erro: comando nao executavel: %s\n' "$COMMAND" >&2; exit 126; }

# Somente os seletores conflitantes conhecidos, nao um parser universal. Apos
# --, argumentos pertencem ao prompt/comando do cliente e nao sao flags dele.
CONFIG_VALUE=0
for arg in "$@"; do
    [ "$arg" != -- ] || break
    case "$NAME" in
        omp)
            case "$arg" in
                -profile|--profile|-profile=*|--profile=*|--alias|--alias=*)
                    fail 'omp: perfil/alias explicito e incompativel com o HOME dev' ;;
            esac ;;
        codex)
            if [ "$CONFIG_VALUE" -eq 1 ]; then
                case "$arg" in
                    *cli_auth_credentials_store*) fail 'codex: armazenamento de auth e fixado em file pelo launcher' ;;
                esac
                CONFIG_VALUE=0
                continue
            fi
            case "$arg" in
                --remote|--remote=*|--daemon|--daemon=*|--no-daemon=*)
                    fail 'codex: remoto/daemon explicito e incompativel com o HOME dev' ;;
                -c|--config) CONFIG_VALUE=1 ;;
                --config=*cli_auth_credentials_store*|-c*cli_auth_credentials_store*)
                    fail 'codex: armazenamento de auth e fixado em file pelo launcher' ;;
            esac ;;
    esac
done

if [ "$DRY" -eq 1 ]; then
    bash "$ROOT/.claude/skills/anvil-sync/scripts/dev-link.sh" --all --dry-run
    printf 'Executavel: %s\nHOME dev: %s\nCWD preservado: %s\n' "$EXECUTABLE" "$DEV_HOME" "$PWD"
    printf '%s\n' 'Exportaria HOME, CLAUDE_CONFIG_DIR, CODEX_HOME, PI_CODING_AGENT_DIR, ANVIL_DEV_ROOT,' \
        'XDG_CONFIG_HOME, XDG_DATA_HOME, XDG_CACHE_HOME, XDG_STATE_HOME, XDG_RUNTIME_DIR,' \
        'XDG_CONFIG_DIRS, XDG_DATA_DIRS e TMPDIR sob o HOME dev; removeria OMP_PROFILE e PI_CONFIG_FILES.' \
        'PATH e credenciais de ambiente herdados; argumentos nao exibidos para nao registrar segredos.'
    if [ "$NAME" = codex ]; then printf '%s\n' 'Codex: acrescentaria --no-daemon e -c cli_auth_credentials_store="file".'; fi
    exit 0
fi
bash "$ROOT/.claude/skills/anvil-sync/scripts/dev-link.sh" --all >&2
export HOME="$DEV_HOME"
export CLAUDE_CONFIG_DIR="$HOME/.claude"
export CODEX_HOME="$HOME/.codex"
export PI_CODING_AGENT_DIR="$HOME/.omp/agent"
export ANVIL_DEV_ROOT="$ROOT"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/.local/run"
export XDG_CONFIG_DIRS="$XDG_CONFIG_HOME"
export XDG_DATA_DIRS="$XDG_DATA_HOME"
export TMPDIR="$HOME/tmp"
unset OMP_PROFILE PI_CONFIG_FILES
if [ "$NAME" = codex ]; then
    exec "$EXECUTABLE" --no-daemon -c 'cli_auth_credentials_store="file"' "$@"
fi
exec "$EXECUTABLE" "$@"
