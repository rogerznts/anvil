#!/usr/bin/env bash
# validate.sh — verificador da organização documental do anvil.
#
# Dois subcomandos, ambos com chamador real:
#
#   ship-ready   a spec do branch atual, e a de cada branch passado, está
#                fechada e arquivada  (hook de merge)
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
#
# Procura nos DOIS lugares, e `specs/` vem primeiro. O archive roda ANTES do PR,
# dentro do mesmo branch, então quando o merge chega a spec já está sob
# `specs/archive/`. Olhando só em `specs/`, o hook bloqueava justamente o fluxo
# correto — e com a mensagem errada, "não há pasta correspondente".
#
# O branch pode vir qualificado — `refs/heads/feature/012-x`, `origin/feature/012-x`
# —, e o prefixo não muda qual spec ele é.
resolve_spec_dir() {
    local root="$1" ref="$2" branch="$3" num dir base
    num="$(printf '%s' "$branch" | sed -nE 's#^(.*/)?[a-z]+/([0-9]{3})-.*$#\2#p')"
    [ -n "$num" ] || return 1
    for base in docs/specs docs/specs/archive; do
        # Sem `grep -m1`: com pipefail, o grep saindo cedo mata o produtor com
        # SIGPIPE, e a pasta achada viraria "não achou".
        dir="$(list_entries "$root" "$ref" "$base" d | grep "^$num-")" || continue
        printf '%s' "$base/${dir%%$'\n'*}"
        return 0
    done
    return 1
}

# A spec é lida do commit, nunca do disco — a do branch atual inclusive, pelo
# HEAD. O merge e o PR levam o commit: archive e resolved feitos e não commitados
# passavam lidos do disco, e a `main` recebia a spec aberta. E a de um branch
# mesclado nem está no disco: na `main` a pasta da spec não existe.
list_entries() {
    local root="$1" ref="$2" path="$3" kind="$4"
    [ "$kind" = d ] && kind=tree || kind=blob
    git -C "$root" ls-tree "$ref" "$path/" 2>/dev/null |
        awk -F'\t' -v kind="$kind" '{ split($1, m, " "); if (m[2] == kind) { n = split($2, p, "/"); print p[n] } }'
}

read_entry() {
    git -C "$1" show "$2:$3"
}

# --- ship-ready ---------------------------------------------------------------

# Sem argumento, confere a spec do branch atual. Cada argumento é um branch que
# vai ser mesclado nele — o hook passa os que o `git merge` nomeia —, e a spec de
# cada um também é conferida. Sem isso, o merge disparado da `main` passava: a
# `main` não tem número, e a spec do branch que chegava nunca era lida.
cmd_ship_ready() {
    local root branch ref name rc=0
    root="$(get_repo_root)" || { echo "não é um repositório git."; return 0; }
    branch="$(get_current_branch)" || { echo "branch não resolvido."; return 0; }

    check_spec "$root" HEAD "$branch" || rc=1
    for ref in "$@"; do
        # A spec sai do nome do branch, não do jeito de escrevê-lo: `-` e `@{-1}`
        # são o branch anterior, e é o nome resolvido que tem o número.
        [ "$ref" = "-" ] && ref="@{-1}"
        name="$(git -C "$root" rev-parse --symbolic-full-name "$ref" 2>/dev/null)"
        name="${name:-$ref}"; name="${name#refs/heads/}"
        # O branch atual já foi conferido, e pelo mesmo commit.
        [ "$name" = "$branch" ] && continue
        check_spec "$root" "$ref" "$name" || rc=1
    done
    return "$rc"
}

check_spec() {
    local root="$1" ref="$2" branch="$3" spec_dir open_tickets total resolved f
    # Branch sem número não tem spec. Isso é o esperado para chore/, docs/, ci/ —
    # o número é o que marca "isto tem spec".
    if ! printf '%s' "$branch" | grep -qE '(^|/)[a-z]+/[0-9]{3}-'; then
        return 0
    fi

    # Ref que não resolve não mescla nada: o próprio `git merge` falha. Nem o HEAD
    # de um repositório sem commit.
    if ! git -C "$root" rev-parse -q --verify "$ref^{commit}" >/dev/null; then
        return 0
    fi

    if ! spec_dir="$(resolve_spec_dir "$root" "$ref" "$branch")"; then
        echo "branch '$branch' tem número de spec, mas não há pasta correspondente"
        echo "em docs/specs/ no commit dele. Crie e commite a spec, ou renomeie o branch."
        return 1
    fi

    if [ -z "$(list_entries "$root" "$ref" "$spec_dir" d | grep -x issues)" ]; then
        echo "spec $(basename "$spec_dir") não tem issues/ — ainda não foi ticketada."
        echo "Rode /anvil-to-tickets antes de fechar."
        return 1
    fi

    total=0; resolved=0; open_tickets=""
    while IFS= read -r f; do
        case "$f" in *.md) ;; *) continue ;; esac
        total=$((total + 1))
        if read_entry "$root" "$ref" "$spec_dir/issues/$f" |
            grep -E '^\*{0,2}Status:?\*{0,2}[[:space:]]*resolved[[:space:]]*$' >/dev/null; then
            resolved=$((resolved + 1))
        else
            open_tickets="$open_tickets  - $f\n"
        fi
    done <<EOF
$(list_entries "$root" "$ref" "$spec_dir/issues" f)
EOF

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

    # Tickets fechados não bastam. O hook existe porque uma spec do mosk chegou
    # ao branch padrão sem archive, e até aqui essa metade da garantia era só
    # prosa no rodapé da mensagem — o script nunca a verificou.
    #
    # Verificar é possível porque o archive roda ANTES do PR, no mesmo branch: o
    # move para archive/ e a promoção do ADR entram no diff que vai ser revisado.
    # Depois do merge não haveria onde commitar sem abrir um segundo PR.
    case "$spec_dir" in
        docs/specs/archive/*) ;;
        *)
            echo "spec $(basename "$spec_dir"): $total de $total tickets resolvidos,"
            echo "mas a spec ainda não foi arquivada no commit de '$branch'."
            echo "Rode /anvil-docs archive e commite no branch da spec antes do merge ou"
            echo "do PR — a promoção do ADR e o move para docs/specs/archive/ vão junto."
            return 1
            ;;
    esac

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

  ship-ready [branch...]  a spec do branch atual, e a de cada branch passado,
                          está fechada e arquivada (default)
  docs-paths [--quiet]    as saídas ficam sob os domínios canônicos

ship-ready sai 1 quando há ticket sem `Status: resolved`, ou quando a spec ainda
não está sob docs/specs/archive/. Lê o commit de cada branch, o atual pelo HEAD:
o que não foi commitado não conta. É o que o hook de merge lê. docs-paths é
consultivo e nunca deve bloquear nada.
EOF
}

case "${1:-ship-ready}" in
    ship-ready)  [ $# -gt 0 ] && shift; cmd_ship_ready "$@" ;;
    docs-paths)  cmd_docs_paths "${2:-}" ;;
    -h|--help)   usage ;;
    *)           echo "subcomando desconhecido: $1" >&2; usage >&2; exit 2 ;;
esac
