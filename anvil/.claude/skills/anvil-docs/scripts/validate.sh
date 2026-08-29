#!/usr/bin/env bash
# validate.sh — verificador da organização documental do anvil.
#
# Dois subcomandos, ambos com chamador real:
#
#   ship-ready   a spec do branch atual está fechada  (chamado pelo hook de merge)
#   docs-paths   as saídas ficam sob os domínios canônicos  (aviso do verbo index)
#
# O verificador do mosk tinha oito subcomandos e 600 linhas. Cinco deles
# (prerequisites, tasks-sync, self-check, fixtures, single-source) existiam para
# conferir o pipeline.yaml e as tasks, que não sobreviveram ao fim dos agentes.
# Uma verificação sem chamador tem a força de uma prosa e o custo de um programa.
#
# Sem dependência de biblioteca: os cinco helpers que este script usava do
# common.sh estão inlinados abaixo. O common.sh tinha quinze funções para seis
# chamadas, e três dos cinco clientes faziam `source` sem usar nada.

set -uo pipefail

# --- helpers (inlinados do common.sh) ----------------------------------------

has_git() { command -v git >/dev/null 2>&1; }

get_repo_root() {
    has_git || return 1
    git rev-parse --show-toplevel 2>/dev/null
}

get_current_branch() {
    has_git || return 1
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Resolve a pasta da spec a partir do branch, SEMPRE por prefixo numérico.
#
# O branch é `{tipo}/{NNN}-{nome}` e a pasta é `{NNN}-{tipo}-{nome}`: strings
# diferentes de propósito. Comparar por igualdade quebra — é o erro que o
# ADR-0017 do mosk documentou depois de uma spec ser lida com o número errado.
resolve_spec_dir() {
    local root="$1" branch="$2" num dir
    num="$(printf '%s' "$branch" | sed -nE 's|^[a-z]+/([0-9]{3})-.*$|\1|p')"
    [ -n "$num" ] || return 1
    for dir in "$root"/docs/specs/"$num"-*/; do
        [ -d "$dir" ] || continue
        printf '%s' "${dir%/}"
        return 0
    done
    return 1
}

# --- ship-ready ---------------------------------------------------------------

cmd_ship_ready() {
    local root branch spec_dir open_tickets total resolved
    root="$(get_repo_root)" || { echo "não é um repositório git."; return 0; }
    branch="$(get_current_branch)" || { echo "branch não resolvido."; return 0; }

    # Branch sem número não tem spec. Isso é o esperado para chore/, docs/, ci/ —
    # o número é o que marca "isto tem spec".
    if ! printf '%s' "$branch" | grep -qE '^[a-z]+/[0-9]{3}-'; then
        return 0
    fi

    if ! spec_dir="$(resolve_spec_dir "$root" "$branch")"; then
        echo "branch '$branch' tem número de spec, mas não há pasta correspondente"
        echo "em docs/specs/. Crie a spec ou renomeie o branch."
        return 1
    fi

    if [ ! -d "$spec_dir/issues" ]; then
        echo "spec $(basename "$spec_dir") não tem issues/ — ainda não foi ticketada."
        echo "Rode /anvil-to-tickets antes de fechar."
        return 1
    fi

    total=0; resolved=0; open_tickets=""
    for f in "$spec_dir"/issues/*.md; do
        [ -f "$f" ] || continue
        total=$((total + 1))
        if grep -qE '^\*{0,2}Status:?\*{0,2}[[:space:]]*resolved[[:space:]]*$' "$f"; then
            resolved=$((resolved + 1))
        else
            open_tickets="$open_tickets  - $(basename "$f")\n"
        fi
    done

    if [ "$total" -eq 0 ]; then
        echo "spec $(basename "$spec_dir") tem issues/ vazio."
        return 1
    fi

    if [ -n "$open_tickets" ]; then
        echo "spec $(basename "$spec_dir"): $resolved de $total tickets resolvidos."
        echo "Ainda abertos:"
        printf '%b' "$open_tickets"
        return 1
    fi

    return 0
}

# --- docs-paths ---------------------------------------------------------------

CANONICAL='discovery prd architecture ui qa project specs agents'

cmd_docs_paths() {
    local root quiet="${1:-}" violations=0 entry name
    root="$(get_repo_root)" || { echo "não é um repositório git."; return 0; }
    [ -d "$root/docs" ] || return 0

    for entry in "$root"/docs/*; do
        [ -e "$entry" ] || continue
        name="$(basename "$entry")"

        if [ -f "$entry" ]; then
            # index.md é o único arquivo que pode morar solto na raiz de docs/.
            [ "$name" = "index.md" ] && continue
            [ "$quiet" = "--quiet" ] || echo "  arquivo solto na raiz: docs/$name"
            violations=$((violations + 1))
            continue
        fi

        case " $CANONICAL " in
            *" $name "*) ;;
            *)
                [ "$quiet" = "--quiet" ] || echo "  pasta fora dos domínios: docs/$name/"
                violations=$((violations + 1))
                ;;
        esac
    done

    if [ "$violations" -gt 0 ]; then
        [ "$quiet" = "--quiet" ] || {
            echo
            echo "$violations entrada(s) fora do padrão. Rode o verbo adopt da skill"
            echo "anvil-docs para classificar e realocar. Este aviso não bloqueia nada."
        }
        return 1
    fi
    return 0
}

# --- despacho -----------------------------------------------------------------

usage() {
    cat <<'EOF'
validate.sh <subcomando>

  ship-ready              a spec do branch atual está fechada (default)
  docs-paths [--quiet]    as saídas ficam sob os domínios canônicos

ship-ready sai 1 quando há ticket sem `Status: resolved`. É o que o hook de
merge lê. docs-paths é consultivo e nunca deve bloquear nada.
EOF
}

case "${1:-ship-ready}" in
    ship-ready)  cmd_ship_ready ;;
    docs-paths)  cmd_docs_paths "${2:-}" ;;
    -h|--help)   usage ;;
    *)           echo "subcomando desconhecido: $1" >&2; usage >&2; exit 2 ;;
esac
