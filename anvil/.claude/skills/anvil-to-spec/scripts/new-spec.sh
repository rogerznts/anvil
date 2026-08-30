#!/usr/bin/env bash
# new-spec.sh — cria uma spec nova, com o número reservado atomicamente.
#
#   new-spec.sh --type feature "cupom de desconto no checkout"
#   new-spec.sh --type fix --short-name carrinho-vazio "descrição" --json
#
# Por que isto é um script e não um prompt: a reserva do número é uma CORRIDA
# CONTRA OUTRO PROCESSO NO REMOTO. Duas pessoas criando spec ao mesmo tempo
# precisam receber números diferentes, e nenhuma quantidade de instrução em
# prosa garante isso — só uma operação atômica no origin garante.
#
# Branch e pasta são strings DIFERENTES, de propósito:
#
#   branch:  {tipo}/{NNN}-{nome}              feature/012-checkout-coupon
#   pasta:   docs/specs/{NNN}-{tipo}-{nome}   docs/specs/012-feature-checkout-coupon
#
# O tipo aparece nos dois em posições diferentes: no branch agrupa na UI do git;
# na pasta mantém `docs/specs/` plano, sem um nível de diretório por tipo. Nunca
# resolva uma na outra por igualdade de string — use o prefixo numérico.

set -uo pipefail

TYPE=""; SHORT=""; DESC=""; JSON=0; NO_PUSH=0
while [ $# -gt 0 ]; do
    case "$1" in
        --type)       TYPE="${2:-}"; shift 2 ;;
        --short-name) SHORT="${2:-}"; shift 2 ;;
        --json)       JSON=1; shift ;;
        --no-push)    NO_PUSH=1; shift ;;
        -h|--help)    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        -*)           echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
        *)            DESC="${DESC:+$DESC }$1"; shift ;;
    esac
done

VALID="feature fix hotfix gmud refactor experimental extension"
[ -n "$TYPE" ] || { echo "erro: --type é obrigatório ($VALID)" >&2; exit 2; }
case " $VALID " in *" $TYPE "*) ;; *) echo "erro: tipo inválido '$TYPE' ($VALID)" >&2; exit 2 ;; esac
[ -n "$DESC$SHORT" ] || { echo "erro: descreva a spec, ou passe --short-name" >&2; exit 2; }

command -v git >/dev/null 2>&1 || { echo "erro: git não encontrado" >&2; exit 2; }
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "erro: não é um repositório git" >&2; exit 2; }
SPECS="$ROOT/docs/specs"

# --- slug ---------------------------------------------------------------------
if [ -z "$SHORT" ]; then
    SHORT="$(printf '%s' "$DESC" \
        | tr '[:upper:]' '[:lower:]' \
        | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null || printf '%s' "$DESC" | tr '[:upper:]' '[:lower:]')"
    SHORT="$(printf '%s' "$SHORT" | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-//; s/-$//' | cut -c1-40 | sed 's/-$//')"
fi
[ -n "$SHORT" ] || { echo "erro: não consegui derivar um nome a partir da descrição" >&2; exit 2; }

ORIGIN=0
git ls-remote --exit-code origin >/dev/null 2>&1 && ORIGIN=1

# --- números já em uso --------------------------------------------------------
# Quatro fontes, porque cada uma sozinha deixa passar. Ref reservado sobrevive à
# remoção do branch; pasta arquivada sobrevive ao merge; branch remoto cobre
# quem ainda não puxou.
usados() {
    # branches locais, nos dois formatos (novo `tipo/NNN-` e legado `NNN-tipo-`).
    # A ÂNCORA `^` É INEGOCIÁVEL: sem ela, qualquer "NNN-" embutido conta, e um
    # branch como `docs/adr-0012-0014-x` desvia a numeração inteira.
    git branch --format='%(refname:short)' 2>/dev/null \
        | sed -nE 's|^([a-z][a-z-]*/)?([0-9]{3})-.*|\2|p'
    if [ "$ORIGIN" -eq 1 ]; then
        git ls-remote --heads origin 2>/dev/null \
            | sed -nE 's|.*refs/heads/([a-z][a-z-]*/)?([0-9]{3})-.*|\2|p'
        # reservas duráveis: imutáveis, sobrevivem ao branch ser apagado
        git ls-remote origin 'refs/spec-numbers/*' 2>/dev/null \
            | sed -nE 's|.*refs/spec-numbers/([0-9]{3})$|\1|p'
    fi
    [ -d "$SPECS" ] && find "$SPECS" -maxdepth 2 -type d 2>/dev/null \
        | sed -nE 's|.*/([0-9]{3})-.*|\1|p'
}

# --- reserva atômica ----------------------------------------------------------
# Cria o ref imutável refs/spec-numbers/<NNN> sob uma lease de "não pode
# existir" (--force-with-lease=<ref>: com valor esperado VAZIO).
#
# O commit precisa ser ÚNICO. Se dois criadores empurrassem o mesmo objeto, o
# git responderia "Everything up-to-date" e NUNCA avaliaria a lease — os dois
# achariam que ganharam. Com objetos distintos, exatamente um push vence e o
# perdedor é recusado com "stale info".
reservar() {
    local n="$1" tree commit nome email nonce
    tree="$(git hash-object -t tree /dev/null 2>/dev/null)" || return 1
    nome="$(git config user.name 2>/dev/null)"; [ -n "$nome" ] || nome="anvil"
    email="$(git config user.email 2>/dev/null)"; [ -n "$email" ] || email="anvil@local"
    nonce="${n}-$(date -u +%s)-$$-${RANDOM}${RANDOM}-$(hostname 2>/dev/null || echo host)"
    commit="$(GIT_AUTHOR_NAME="$nome" GIT_AUTHOR_EMAIL="$email" \
              GIT_COMMITTER_NAME="$nome" GIT_COMMITTER_EMAIL="$email" \
              git commit-tree "$tree" -m "anvil: reserva o número $nonce" 2>/dev/null)" || return 1
    git push --force-with-lease="refs/spec-numbers/$n:" origin \
        "${commit}:refs/spec-numbers/$n" >/dev/null 2>&1
}

# --- escolher o número --------------------------------------------------------
maior="$(usados | grep -E '^[0-9]+$' | sed 's/^0*//' | sort -n | tail -1)"
prox=$(( ${maior:-0} + 1 ))
RESERVADO=0

if [ "$ORIGIN" -eq 1 ] && [ "$NO_PUSH" -eq 0 ]; then
    # Perder a corrida é esperado, não é erro: tenta o próximo.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        n="$(printf '%03d' "$prox")"
        if reservar "$n"; then RESERVADO=1; break; fi
        prox=$(( prox + 1 ))
    done
    [ "$RESERVADO" -eq 1 ] || echo "aviso: não consegui reservar no origin; seguindo sem garantia" >&2
fi

NUM="$(printf '%03d' "$prox")"
BRANCH="${TYPE}/${NUM}-${SHORT}"
DIR_NAME="${NUM}-${TYPE}-${SHORT}"
SPEC_DIR="$SPECS/$DIR_NAME"

# GitHub recusa nome de branch acima de 244 bytes.
if [ ${#BRANCH} -gt 244 ]; then
    corte=$(( 244 - ${#TYPE} - 5 ))
    SHORT="$(printf '%s' "$SHORT" | cut -c1-"$corte" | sed 's/-$//')"
    BRANCH="${TYPE}/${NUM}-${SHORT}"; DIR_NAME="${NUM}-${TYPE}-${SHORT}"; SPEC_DIR="$SPECS/$DIR_NAME"
    echo "aviso: nome encurtado para caber no limite de 244 bytes do GitHub" >&2
fi

# --- criar --------------------------------------------------------------------
[ -e "$SPEC_DIR" ] && { echo "erro: $SPEC_DIR já existe" >&2; exit 1; }
git rev-parse --verify "$BRANCH" >/dev/null 2>&1 && { echo "erro: branch $BRANCH já existe" >&2; exit 1; }

git checkout -q -b "$BRANCH" || { echo "erro: falha ao criar o branch $BRANCH" >&2; exit 1; }
mkdir -p "$SPEC_DIR/issues"

if [ "$JSON" -eq 1 ]; then
    printf '{"number":"%s","type":"%s","slug":"%s","branch":"%s","spec_dir":"%s","spec_file":"%s","issues_dir":"%s","reserved":%s}\n' \
        "$NUM" "$TYPE" "$SHORT" "$BRANCH" \
        "docs/specs/$DIR_NAME" "docs/specs/$DIR_NAME/spec.md" "docs/specs/$DIR_NAME/issues" \
        "$([ "$RESERVADO" -eq 1 ] && echo true || echo false)"
else
    echo "spec $NUM criada"
    echo "  branch : $BRANCH"
    echo "  pasta  : docs/specs/$DIR_NAME"
    echo "  spec   : docs/specs/$DIR_NAME/spec.md   (ainda não escrita)"
    [ "$RESERVADO" -eq 1 ] && echo "  número reservado no origin" \
                           || echo "  número NÃO reservado: sem origin, ou --no-push"
fi
