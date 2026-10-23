#!/usr/bin/env bash
# Estado do roteiro, docs/specs/roadmap.md, derivado do disco. Nada e escrito: o
# estado de uma entrada nao e gravado no roteiro, sai daqui (ADR-0003, ADR-0014).
#
# Uso, de dentro do repositorio, com o anvil na instalacao de usuario:
#   bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh [--skip "nome nome"]
#
# Saida em linhas "chave: valor", como o stage.sh e o frontier.sh; as chaves e os
# estados sao em ingles e estaveis, e o motivo para o operador e em pt-BR.
#   roadmap: docs/specs/roadmap.md, ou none sem o arquivo (e entao so next: none)
#   entry: <nome> state=<estado> spec=<NNN|-> depends=<a,b|-> reason=<motivo>
#          uma por entrada, na ordem do arquivo
#   frontier: as entradas pending com todas as dependencias closed, na ordem do
#          arquivo, menos as do --skip; "-" quando nao ha
#   next: a primeira do frontier, ou none
#   refusal: <motivo>, uma por problema, quando o roteiro nao pode terminar: nome
#          fora de kebab-case, nome repetido, Depende de: para nome inexistente,
#          ciclo, Tipo: fora dos tipos do new-spec.sh. Com recusa nao ha entry nem
#          frontier, o next e none e o script sai com 2, como o frontier.sh.
#          Argumento invalido e chamada fora de um repositorio git saem so com a
#          linha refusal:, tambem com 2
#
# Estado, lido do checkout atual e, para spec aberta, do commit do branch local
# de spec com o mesmo numero, sem trocar de checkout:
#   pending  sem Spec:
#   closed   pasta docs/specs/archive/{NNN}-* no checkout atual: ja esta na main
#   open     spec achada fora de archive/ sem spec.md, sem ticket, ou com ticket
#            a despachar; ou o branch dela ainda sem a pasta commitada
#   stopped  spec achada e nao fechada sem ticket a despachar (todos resolved, ou
#            os nao resolvidos travados ou dependentes de travado), spec arquivada
#            no branch e sem merge na main, ou Spec: sem pasta nem branch
set -u

roadmap=docs/specs/roadmap.md
FIELD_SEP=$'\037'
# Os tipos do new-spec.sh da anvil-to-spec, que o piloto chama com o Tipo: da entrada.
TYPES="feature fix hotfix gmud refactor experimental extension"

refuse() { echo "refusal: $1"; exit 2; }

skip=""
while [ $# -gt 0 ]; do
    case "$1" in
        --skip) [ $# -ge 2 ] || refuse "--skip pede a lista de entradas"; skip="$skip $2"; shift 2 ;;
        *) refuse "argumento desconhecido '$1'; o único é --skip \"nome nome\"" ;;
    esac
done

root="$(git rev-parse --show-toplevel 2>/dev/null)" || refuse "fora de um repositório git"
cd "$root" || exit 1

if [ ! -f "$roadmap" ]; then
    echo "roadmap: none"
    echo "next: none"
    exit 0
fi

# --- roteiro ------------------------------------------------------------------
# Cada entrada e uma secao "## nome". As chaves sao linhas "Chave: valor" no
# comeco da linha, com ou sem negrito, como o Status: dos tickets; vale a primeira
# de cada chave na secao. Sai uma linha por entrada, campos separados por
# FIELD_SEP: nome, Tipo, Depende de (nomes separados por virgula, sem espacos) e
# Spec.
parse() {
    awk -v FS_OUT="$FIELD_SEP" '
        function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
        function val(line, k) {
            got = match(line, "^\\**" k "\\**:\\**")
            return got ? trim(substr(line, RLENGTH + 1)) : ""
        }
        /^## / { n++; name[n] = trim(substr($0, 4)); next }
        n == 0 { next }
        { v = val($0, "Tipo") }       got && !(n in etype) { etype[n] = v }
        { v = val($0, "Depende de") } got && !(n in edeps) { edeps[n] = v }
        { v = val($0, "Spec") }       got && !(n in spec) { spec[n] = v }
        END {
            for (i = 1; i <= n; i++) {
                k = split(edeps[i], parts, ","); d = ""
                for (j = 1; j <= k; j++) { p = trim(parts[j]); if (p != "") d = d (d == "" ? "" : ",") p }
                print name[i] FS_OUT etype[i] FS_OUT d FS_OUT spec[i]
            }
        }
    ' "$roadmap"
}

# entries: os indices das entradas, na ordem do arquivo, para os lacos.
entries=""; count=0
while IFS="$FIELD_SEP" read -r n t d s; do
    count=$((count + 1)); entries="$entries $count"
    name[count]="$n"; entry_type[count]="$t"; deps[count]="${d//,/ }"; spec[count]="$s"
done < <(parse)

index_of() {  # <nome>: o indice da primeira entrada com o nome, ou nada
    local i
    for i in $entries; do [ "${name[i]}" = "$1" ] && { echo "$i"; return; }; done
}
has() { case " $1 " in *" $2 "*) return 0 ;; esac; return 1; }

# --- recusas ------------------------------------------------------------------
# Um roteiro que nao pode terminar: nome fora de kebab-case, nome repetido, Tipo:
# fora dos tipos do new-spec.sh, Depende de: que aponta para nome inexistente,
# ciclo. Sai uma linha refusal: por problema, sem frontier. O nome e o
# --short-name do new-spec.sh e o que o frontier: e o --skip separam por espaco.
KEBAB="minúsculas ASCII e dígitos, em grupos separados por um hífen, sem hífen no começo nem no fim"
# Letras escritas uma a uma, e nao a faixa a-z, que depende do locale.
kebab() {
    case "$1" in
        ""|-*|*-|*--*|*[!abcdefghijklmnopqrstuvwxyz0123456789-]*) return 1 ;;
    esac
}
refusals=""
add_refusal() { refusals="$refusals$1"$'\n'; }
for i in $entries; do
    if [ "$(index_of "${name[i]}")" = "$i" ]; then
        kebab "${name[i]}" ||
            add_refusal "a entrada '${name[i]}' não está em kebab-case: o nome usa $KEBAB, como 'cadastro-de-clientes'"
    else
        add_refusal "nome repetido: a entrada '${name[i]}' aparece mais de uma vez"
    fi
    case "${entry_type[i]}" in *[[:space:]]*) false ;; *) has "$TYPES" "${entry_type[i]}" ;; esac ||
        add_refusal "a entrada '${name[i]}' tem Tipo: '${entry_type[i]}', e o new-spec.sh aceita: $TYPES"
    for d in ${deps[i]}; do
        [ -n "$(index_of "$d")" ] || add_refusal "a entrada '${name[i]}' depende de '$d', que não existe no roteiro"
    done
done
# Ciclo: tira, rodada a rodada, as entradas cujas dependencias existentes ja
# sairam. Toda que sobra tem uma dependencia que tambem sobrou, e seguir essas
# dependencias a partir dela fecha um ciclo, que sai no motivo.
left="$entries "; changed=1
while [ "$changed" = 1 ]; do
    changed=0
    for i in $left; do
        blocked=no
        for d in ${deps[i]}; do j="$(index_of "$d")"; [ -n "$j" ] && has "$left" "$j" && blocked=yes; done
        [ "$blocked" = yes ] && continue
        left="${left/ $i / }"; changed=1
    done
done
if [ -n "${left// /}" ]; then
    path=" "; i="${left# }"; i="${i%% *}"
    while ! has "$path" "$i"; do
        path="$path$i "
        for d in ${deps[i]}; do j="$(index_of "$d")"; [ -n "$j" ] && has "$left" "$j" && { i="$j"; break; }; done
    done
    cycle=""; on=no
    for j in $path; do [ "$j" = "$i" ] && on=yes; [ "$on" = yes ] && cycle="$cycle${name[j]} -> "; done
    add_refusal "ciclo em Depende de: $cycle${name[i]}"
fi
if [ -n "$refusals" ]; then
    echo "roadmap: $roadmap"
    printf '%s' "$refusals" | while IFS= read -r l; do echo "refusal: $l"; done
    echo "next: none"
    exit 2
fi

# --- estado -------------------------------------------------------------------
# Uma fonte e o checkout atual (vazia) ou o commit de um branch local, lido pelo
# git sem trocar de checkout, como o validate.sh da guarda le a spec de um branch.
src_entries() {  # <fonte> <caminho> <d|f>: os nomes das pastas ou dos arquivos
    local e
    if [ -z "$1" ]; then
        for e in "$2"/*; do
            { [ "$3" = d ] && [ -d "$e" ]; } || { [ "$3" = f ] && [ -f "$e" ]; } || continue
            basename "$e"
        done
    else
        git ls-tree "$1" "$2/" 2>/dev/null | awk -F'\t' -v kind="$([ "$3" = d ] && echo tree || echo blob)" \
            '{ split($1, m, " "); if (m[2] == kind) { n = split($2, p, "/"); print p[n] } }'
    fi
}
src_cat() {  # <fonte> <caminho>
    if [ -z "$1" ]; then cat "$2"; else git show "$1:$2"; fi 2>/dev/null
}
# A pasta de spec sob <base> com o numero, pelo prefixo numerico, nunca pelo nome.
spec_dir_in() {  # <fonte> <base> <numero sem zeros>
    local d p
    for d in $(src_entries "$1" "$2" d); do
        p="${d%%[!0-9]*}"
        [ -n "$p" ] && [ $((10#$p)) -eq "$3" ] && { echo "$2/$d"; return; }
    done
}
num_of() { printf '%s\n' "$1" | sed -n 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p'; }
current="$(git branch --show-current)"
branch_of() {  # <numero sem zeros>: o branch local de spec com esse numero
    local b c
    for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
        c="$(num_of "$b")"
        [ -n "$c" ] && [ $((10#$c)) -eq "$1" ] && { echo "$b"; return; }
    done
}

# Le o valor do Blocked by em blocker_list, os numeros sem zeros a esquerda: a
# mesma leitura do frontier.sh da anvil-run. Vazio ou "Nenhum"/"None" e sem
# bloqueador; o item que cita um ADR-NNNN perde a citacao e sai se sobrar so um
# "ver" ou "see". Qualquer outra coisa da unreadable=1.
read_blockers() {
    local rest="$1," item
    blocker_list=""; unreadable=""
    case "$1" in ""|[Nn][Ee][Nn][Hh][Uu][Mm]*|[Nn][Oo][Nn][Ee]*) return ;; esac
    while [ -n "$rest" ]; do
        item="${rest%%,*}"; rest="${rest#*,}"
        item="${item#"${item%%[![:space:]]*}"}"; item="${item%"${item##*[![:space:]]}"}"
        case "$item" in *ADR-[0-9]*)
            item="$(printf '%s' "$item" | sed 's/ADR-[0-9][0-9]*//g;s/^[[:space:]]*//;s/[[:space:]]*$//')"
            case "$item" in ""|[Vv][Ee][Rr]|[Ss][Ee][Ee]) continue ;; esac ;;
        esac
        case "$item" in ""|*[!0-9]*) blocker_list=""; unreadable=1; return ;; esac
        blocker_list="$blocker_list $((10#$item))"
    done
}
# O status do ticket n da spec que o spec_state esta lendo.
resolved() { [ "${tstatus[$1]:-}" = resolved ]; }

# Estado de uma spec achada fora de archive/, em found_state e found_reason. open
# quando falta spec.md ou ticket de implementacao, ou quando ha ticket a
# despachar. stopped quando nao ha. Ticket de implementacao e o sem Type:, como no
# stage.sh da anvil-plan: com Type:, e decisao do wayfinder. A despachar e o que o
# frontier.sh da anvil-run poe no frontier, lido como ele le, sobre todos os
# tickets: nao resolved, nao travado, com o Blocked by legivel e todo resolved.
spec_state() {  # <fonte> <pasta> <onde>
    local src="$1" dir="$2" where="$3" f p n text review round verdict
    local order="" impl=0 ready="" locked="" closure changed rest="" all_resolved=yes
    local -a tstatus tblockers tunreadable tlocked tlabel
    if ! has "$(src_entries "$src" "$dir" f | tr '\n' ' ')" spec.md; then
        found_state=open; found_reason="$dir sem spec.md ($where)"; return
    fi
    for f in $(src_entries "$src" "$dir/issues" f); do
        case "$f" in [0-9]*.md) ;; *) continue ;; esac
        text="$(src_cat "$src" "$dir/issues/$f")"
        printf '%s\n' "$text" | grep -qE '^\**Type:' || impl=$((impl + 1))
        p="${f%%[!0-9]*}"; n=$((10#$p)); tlabel[n]="$p"
        tstatus[n]="$(printf '%s\n' "$text" | sed -n 's/^\**Status:\** *//p' | sed -n '1s/[[:space:]]*$//p')"
        read_blockers "$(printf '%s\n' "$text" | sed -n 's/^\**Blocked by:\** *//p' | sed -n '1s/[[:space:]]*$//p')"
        tblockers[n]="$blocker_list"; tunreadable[n]="$unreadable"
        review="$(printf '%s\n' "$text" | grep -E '^\**Review:' | sed -n '$p')"
        round="$(printf '%s\n' "$review" | sed -n 's/.*round=\([0-9][0-9]*\).*/\1/p')"
        verdict="$(printf '%s\n' "$review" | sed -n 's/.*verdict=\([a-z]*\).*/\1/p')"
        tlocked[n]=""
        [ -n "$round" ] && [ "$round" -ge 2 ] && [ "$verdict" = fail ] && tlocked[n]=1
        order="$order $n"
    done
    if [ "$impl" = 0 ]; then found_state=open; found_reason="$dir sem ticket de implementação ($where)"; return; fi
    for n in $order; do
        resolved "$n" && continue
        all_resolved=no
        if [ -n "${tlocked[n]}" ]; then locked="$locked ${tlabel[n]}"; continue; fi
        [ -z "${tunreadable[n]}" ] || continue
        p=yes; for f in ${tblockers[n]}; do resolved "$f" || p=no; done
        [ "$p" = yes ] && ready="$ready ${tlabel[n]}"
    done
    if [ -n "$ready" ]; then found_state=open; found_reason="ticket a despachar:$ready ($where)"; return; fi
    found_state=stopped
    if [ "$all_resolved" = yes ]; then found_reason="todos os tickets resolved, e a spec sem archive ($where)"; return; fi
    # Quem depende de um travado, direta ou indiretamente, e ainda nao esta resolvido.
    closure=" "; for n in $order; do [ -n "${tlocked[n]}" ] && closure="$closure$n "; done
    changed=1
    while [ "$changed" = 1 ]; do
        changed=0
        for n in $order; do
            resolved "$n" && continue; has "$closure" "$n" && continue
            for f in ${tblockers[n]}; do
                if has "$closure" "$f"; then closure="$closure$n "; changed=1; break; fi
            done
        done
    done
    local dependents=""
    for n in $order; do
        resolved "$n" && continue
        if [ -n "${tlocked[n]}" ]; then continue
        elif has "$closure" "$n"; then dependents="$dependents ${tlabel[n]}"
        else rest="$rest ${tlabel[n]}"
        fi
    done
    found_reason=""
    [ -z "$locked" ] || found_reason="travado (round 2 ou mais com verdict=fail):$locked"
    [ -z "$dependents" ] || found_reason="${found_reason:+$found_reason; }dependem de travado:$dependents"
    [ -z "$rest" ] || found_reason="${found_reason:+$found_reason; }sem como despachar (Blocked by ilegível ou que nunca se resolve):$rest"
    found_reason="nenhum ticket a despachar: $found_reason ($where)"
}

entry_state() {  # <Spec:>: o estado da entrada em found_state e found_reason
    local s="$1" num dir br src where
    case "$s" in
        "") found_state=pending; found_reason="sem Spec:"; return ;;
        *[!0-9]*) found_state=stopped; found_reason="o Spec: '$s' não é um número de spec"; return ;;
    esac
    num=$((10#$s))
    dir="$(spec_dir_in "" docs/specs/archive "$num")"
    if [ -n "$dir" ]; then found_state=closed; found_reason="arquivada em $dir"; return; fi
    br="$(branch_of "$num")"
    if [ -n "$br" ] && [ "$br" != "$current" ]; then src="$br"; where="branch $br"
    else src=""; where="checkout atual${current:+, $current}"
    fi
    if [ -n "$src" ]; then
        dir="$(spec_dir_in "$src" docs/specs/archive "$num")"
        if [ -n "$dir" ]; then
            found_state=stopped; found_reason="arquivada no branch $br e ainda sem merge na main"; return
        fi
    fi
    dir="$(spec_dir_in "$src" docs/specs "$num")"
    if [ -n "$dir" ]; then spec_state "$src" "$dir" "$where"; return; fi
    if [ -n "$br" ]; then
        found_state=open; found_reason="o branch $br ainda não tem a pasta docs/specs/$s-* commitada"
    else
        found_state=stopped; found_reason="nem pasta docs/specs/$s-* nem branch local de spec com o número $s"
    fi
}

for i in $entries; do
    entry_state "${spec[i]}"; state[i]="$found_state"; reason[i]="$found_reason"
done

# Frontier: pending com todas as dependencias closed, na ordem do arquivo, menos
# as do --skip. A dependente transitiva de uma stopped nunca entra: alguma
# dependencia dela nunca chega a closed.
frontier=""
for i in $entries; do
    [ "${state[i]}" = pending ] || continue
    waiting=""
    for d in ${deps[i]}; do
        j="$(index_of "$d")"
        [ "${state[j]}" = closed ] || waiting="$waiting, $d (${state[j]})"
    done
    if [ -n "$waiting" ]; then reason[i]="${reason[i]}; espera ${waiting#, }"
    elif has "$skip" "${name[i]}"; then reason[i]="${reason[i]}; pulada pelo --skip"
    else frontier="$frontier ${name[i]}"
    fi
done

or_dash() { [ -n "$1" ] && echo "$1" || echo "-"; }
echo "roadmap: $roadmap"
for i in $entries; do
    deplist="${deps[i]// /,}"
    echo "entry: ${name[i]} state=${state[i]} spec=$(or_dash "${spec[i]}") depends=$(or_dash "$deplist") reason=${reason[i]}"
done
frontier="${frontier# }"
echo "frontier: $(or_dash "$frontier")"
echo "next: $([ -n "$frontier" ] && echo "${frontier%% *}" || echo none)"
