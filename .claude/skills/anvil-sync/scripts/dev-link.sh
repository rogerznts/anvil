#!/usr/bin/env bash
# Prepara somente workspace/anvil-dev/home deste checkout, com links por peca.
# Nao importa configuracao/auth, nao instala o publicado e nao e sandbox.
# --unlink e uma migracao global explicita; nunca faz parte da preparacao dev.
# Compativel com Bash 3.2. Saida: 0 sucesso; 2 uso/ambiente/colisao recusados.
set -euo pipefail
umask 077

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd -P)"
SOURCE="$ROOT/anvil/.claude"
PAYLOAD="$SOURCE/skills"
LAYER="$PAYLOAD/anvil-update/.omp-layer"
DEV_HOME="$ROOT/workspace/anvil-dev/home"
MODE=roster
DRY=0

fail() { printf 'erro: %s\n' "$*" >&2; exit 2; }
usage() {
    cat <<'HELP'
Uso: bash dev-link.sh [--all] [--dry-run]
     bash dev-link.sh --unlink [--dry-run]

Prepara workspace/anvil-dev/home, sem tocar a instalacao pessoal. Por padrao
liga o roster de fluxo; --all liga todas as skills. Agentes, espelho Codex e
camada omp entram em ambos. Colisoes e ancestrais symlink sao recusados antes
de qualquer escrita. --dry-run nao cria nem altera arquivos/diretorios.

--unlink remove somente links globais deste checkout e links historicos do
projeto reconhecidos. Nao toca o HOME dev nem restaura a instalacao publicada.
Execute a migracao separadamente no HOME real; nunca dentro de dev-run.sh.
Abra clientes com dev-run.sh -- <comando> [args...], de preferencia na raiz.
HELP
}
while [ $# -gt 0 ]; do
    case "$1" in
        --all) [ "$MODE" != unlink ] || fail '--all e --unlink sao incompativeis'; MODE=all ;;
        --unlink) [ "$MODE" != all ] || fail '--all e --unlink sao incompativeis'; MODE=unlink ;;
        --dry-run) DRY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) fail "argumento desconhecido: $1" ;;
    esac
    shift
done

# Normalizacao lexical reconhece tambem links relativos e alvos que sumiram,
# sem seguir symlinks nem confundir /payload/../terceiro com fonte nossa.
normalize() {
    local part result='' count=0
    local parts=() stack=()
    IFS=/ read -r -a parts <<< "$1"
    for part in ${parts[@]+"${parts[@]}"}; do
        case "$part" in
            ''|.) ;;
            ..) if [ "$count" -gt 0 ]; then count=$((count - 1)); unset 'stack[count]'; fi ;;
            *) stack[$count]="$part"; count=$((count + 1)) ;;
        esac
    done
    for part in ${stack[@]+"${stack[@]}"}; do result="$result/$part"; done
    printf '%s\n' "${result:-/}"
}
owned() {
    local target
    [ -L "$1" ] || return 1
    target="$(readlink "$1")"
    case "$target" in /*) ;; *) target="${1%/*}/$target" ;; esac
    target="$(normalize "$target")"
    case "$target" in "$SOURCE"/*) return 0 ;; esac
    return 1
}
# Verifica todos os ancestrais, inclusive os que ja existem acima do checkout.
check_dir() {
    local path="$1"
    while [ "$path" != / ]; do
        [ ! -L "$path" ] || fail "ancestral/diretorio symlink recusado: $path"
        if [ -e "$path" ] && [ ! -d "$path" ]; then fail "diretorio ocupado por arquivo: $path"; fi
        path="${path%/*}"
        [ -n "$path" ] || path=/
    done
}
LINKS=()
TARGETS=()
REMOVALS=()
DIRS=()
LINK_COUNT=0
REMOVE_COUNT=0
add_link() {
    LINKS[$LINK_COUNT]="$1"; TARGETS[$LINK_COUNT]="$2"
    LINK_COUNT=$((LINK_COUNT + 1))
}
add_removal() {
    REMOVALS[$REMOVE_COUNT]="$1"; REMOVE_COUNT=$((REMOVE_COUNT + 1))
}

if [ "$MODE" = unlink ]; then
    [ -n "${HOME:-}" ] && [ -d "$HOME" ] || fail 'HOME deve ser um diretorio existente'
    case "$HOME" in /*) ;; *) fail 'HOME deve ser absoluto' ;; esac
    USER_HOME="$(normalize "$HOME")"
    PHYSICAL_HOME="$(cd "$HOME" && pwd -P)"
    [ "$PHYSICAL_HOME" != "$DEV_HOME" ] || fail '--unlink nao pode rodar no HOME dev'
    check_dir "$USER_HOME"
    # Primeiro valida todos os pontos de busca; find nunca atravessa symlinks.
    for dir in "$USER_HOME/.claude/skills" "$USER_HOME/.claude/agents" \
        "$USER_HOME/.agents/skills" "$USER_HOME/.omp/agent" \
        "$ROOT/.claude/skills" "$ROOT/.claude/agents" "$ROOT/.agents/skills" "$ROOT/.omp"; do
        check_dir "$dir"
    done
    for dir in "$USER_HOME/.claude/skills" "$USER_HOME/.claude/agents" "$USER_HOME/.agents/skills" "$USER_HOME/.omp/agent"; do
        [ -d "$dir" ] || continue
        while IFS= read -r -d '' link; do
            if owned "$link"; then add_removal "$link"; fi
        done < <(find "$dir" -type l -print0)
    done
    for link in "$ROOT"/.claude/skills/* "$ROOT"/.claude/agents/*; do
        [ -L "$link" ] || continue
        case "$(readlink "$link")" in
            ../../anvil/.claude/skills/*|../../anvil/.claude/agents/*)
                if owned "$link"; then add_removal "$link"; fi ;;
        esac
    done
    for link in "$ROOT"/.agents/skills/*; do
        [ -L "$link" ] || continue
        name="${link##*/}"
        [ "$(readlink "$link")" = "../../.claude/skills/$name" ] || continue
        # O formato do espelho sozinho nao identifica o toolkit: preserve uma
        # skill local real ou ligada a terceiros. Um espelho orfao so e
        # reconhecido quando a skill ainda existe neste payload.
        if owned "$ROOT/.claude/skills/$name"; then
            add_removal "$link"
        elif [ ! -e "$ROOT/.claude/skills/$name" ] && [ ! -L "$ROOT/.claude/skills/$name" ] && [ -d "$PAYLOAD/$name" ]; then
            add_removal "$link"
        fi
    done
    if [ -d "$ROOT/.omp" ]; then
        while IFS= read -r -d '' link; do
            target="$(readlink "$link")"
            case "$target" in
                ../*anvil/.claude/skills/anvil-update/.omp-layer/*)
                    if owned "$link"; then add_removal "$link"; fi ;;
            esac
        done < <(find "$ROOT/.omp" -type l -print0)
    fi
else
    [ -d "$PAYLOAD" ] || fail "payload nao encontrado: $PAYLOAD"
    # Os destinos de ambiente do launcher sao preparados nesta mesma transacao.
    DIRS=("$DEV_HOME" "$DEV_HOME/.claude/skills" "$DEV_HOME/.claude/agents"
        "$DEV_HOME/.agents/skills" "$DEV_HOME/.omp/agent" "$DEV_HOME/.codex"
        "$DEV_HOME/.config" "$DEV_HOME/.local/share" "$DEV_HOME/.cache"
        "$DEV_HOME/.local/state" "$DEV_HOME/.local/run" "$DEV_HOME/tmp")
    for dir in "${DIRS[@]}"; do check_dir "$dir"; done
    ROSTER='anvil-boot
anvil-grill
anvil-grilling
anvil-domain-modeling
anvil-to-spec
anvil-to-tickets
anvil-implement
anvil-tdd
anvil-diagnose
anvil-codebase-design
anvil-code-review
anvil-docs
anvil-setup
anvil-research
anvil-security-audit
anvil-distill
anvil-how
anvil-architect
anvil-arena
anvil-principles
anvil-prototype
anvil-unslop
anvil-writing-for-agents
anvil-browser-qa
anvil-next
anvil-commit'
    for source in "$PAYLOAD"/*; do
        [ -d "$source" ] || continue
        name="${source##*/}"
        selected=0
        if [ "$MODE" = all ]; then
            selected=1
        else
            while IFS= read -r skill; do
                if [ "$skill" = "$name" ]; then selected=1; break; fi
            done <<< "$ROSTER"
        fi
        # Um --all anterior nao e desfeito ao voltar ao roster.
        if [ "$selected" -eq 0 ] && owned "$DEV_HOME/.claude/skills/$name"; then selected=1; fi
        [ "$selected" -eq 1 ] || continue
        add_link "$DEV_HOME/.claude/skills/$name" "$source"
        add_link "$DEV_HOME/.agents/skills/$name" "$source"
    done
    for source in "$SOURCE"/agents/*.md; do
        [ -f "$source" ] || continue
        add_link "$DEV_HOME/.claude/agents/${source##*/}" "$source"
    done
    if [ -d "$LAYER" ]; then
        while IFS= read -r -d '' source; do
            add_link "$DEV_HOME/.omp/agent/${source#"$LAYER"/}" "$source"
        done < <(find "$LAYER" -type f -print0)
    fi
    # Recusa qualquer colisao antes de criar o primeiro diretorio ou link.
    for ((i=0; i<LINK_COUNT; i++)); do
        link="${LINKS[$i]}"
        check_dir "${link%/*}"
        if [ -e "$link" ] || [ -L "$link" ]; then
            owned "$link" || fail "destino nao gerenciado ja existe: $link"
        fi
    done
    # Inclui arquivos/agentes removidos e topos antigos da camada omp. Nao
    # segue links de skills nem apaga estado/terceiros dentro do HOME privado.
    for dir in "$DEV_HOME/.claude/skills" "$DEV_HOME/.claude/agents" "$DEV_HOME/.agents/skills" "$DEV_HOME/.omp/agent"; do
        [ -d "$dir" ] || continue
        while IFS= read -r -d '' link; do
            owned "$link" || continue
            [ ! -e "$link" ] || continue
            add_removal "$link"
        done < <(find "$dir" -type l -print0)
    done
fi

# A validacao abrange tambem os ancestrais de cada remocao planejada.
for link in ${REMOVALS[@]+"${REMOVALS[@]}"}; do check_dir "${link%/*}"; done
if [ "$DRY" -eq 0 ]; then
    for dir in ${DIRS[@]+"${DIRS[@]}"}; do mkdir -p "$dir"; done
fi
for link in ${REMOVALS[@]+"${REMOVALS[@]}"}; do
    if [ "$DRY" -eq 1 ]; then printf 'removeria %s\n' "$link"; else rm -- "$link"; fi
done
for ((i=0; i<LINK_COUNT; i++)); do
    link="${LINKS[$i]}"
    target="${TARGETS[$i]}"
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then continue; fi
    if [ "$DRY" -eq 1 ]; then
        printf 'ligaria %s -> %s\n' "$link" "$target"
    else
        mkdir -p "${link%/*}"
        [ ! -L "$link" ] || rm -- "$link"
        ln -s "$target" "$link"
    fi
done
if [ "$MODE" = unlink ]; then
    printf '%s link(s) globais/historicos; HOME dev intocado. Nenhuma instalacao publicada foi feita.\n' "$REMOVE_COUNT"
else
    printf 'HOME dev: %s\n%s link(s) planejados; %s link(s) obsoletos. Instalacao pessoal intocada.\n' "$DEV_HOME" "$LINK_COUNT" "$REMOVE_COUNT"
fi
