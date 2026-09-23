#!/usr/bin/env bash
# Estado de uma spec do anvil, lido do disco, para a skill anvil-run.
#
# Uso, de dentro do repositorio:
#   bash .omp/skills/anvil-run/frontier.sh [NNN] [--skip "NN NN"]
#
# Sem NNN, a spec sai do prefixo numerico do branch atual, {tipo}/{NNN}-{nome}.
# --skip tira do frontier os tickets que o supervisor ja despachou nesta execucao
# sem que o estado mudasse. Sai com 2 e uma linha "recusa:" quando nao ha o que
# conduzir daqui; com 0 e o estado da spec, uma linha por chave, nos outros casos.
#
# Frontier: ticket com Status: diferente de resolved, com todos os Blocked by
# resolvidos e nao travado. Travado: a ultima linha Review: tem round 2 ou mais e
# verdict=fail. Com a arvore suja, o proximo e nenhum e sai uma linha "parada:":
# o implementer seguinte commitaria o que sobrou junto com o ticket dele.
set -u

recusa() { echo "recusa: $1"; exit 2; }

arg=""; skip=""
while [ $# -gt 0 ]; do
    case "$1" in
        --skip) [ $# -ge 2 ] || recusa "--skip pede a lista de tickets"; skip="$2"; shift 2 ;;
        *)      arg="$1"; shift ;;
    esac
done
case "$arg" in
    "") ;;
    *[!0-9]*) recusa "o argumento é o número da spec, como 003, e veio '$arg'" ;;
esac

raiz="$(git rev-parse --show-toplevel 2>/dev/null)" || recusa "fora de um repositório git"
cd "$raiz" || exit 1

branch="$(git branch --show-current)"
num_de() { printf '%s\n' "$1" | sed -n 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p'; }
bnum="$(num_de "$branch")"

if [ -z "$arg" ]; then
    [ -n "$bnum" ] || recusa "o branch atual, '${branch:-HEAD destacado}', não é de spec. Passe o número da spec ou troque para o branch dela, {tipo}/{NNN}-{nome}."
    arg="$bnum"
fi
n_spec=$((10#$arg))

if [ -z "$bnum" ] || [ $((10#$bnum)) -ne "$n_spec" ]; then
    candidatos=""
    for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
        c="$(num_de "$b")"
        [ -n "$c" ] && [ $((10#$c)) -eq "$n_spec" ] && candidatos="$candidatos '$b'"
    done
    if [ -n "$candidatos" ]; then
        recusa "a spec $arg roda no branch dela, e o atual é '${branch:-HEAD destacado}'. Troque para${candidatos}."
    fi
    recusa "a spec $arg roda no branch dela, {tipo}/$arg-{nome}, e o atual é '${branch:-HEAD destacado}'. Nenhum branch local com esse número existe."
fi

dir=""
for d in docs/specs/[0-9]*/; do
    [ -d "$d" ] || continue
    b="$(basename "$d")"; p="${b%%[!0-9]*}"
    [ -n "$p" ] && [ $((10#$p)) -eq "$n_spec" ] && { dir="${d%/}"; break; }
done
[ -n "$dir" ] || recusa "não há pasta docs/specs/$arg-*/ neste branch. Spec arquivada não tem o que conduzir."

# --- tickets ------------------------------------------------------------------
# Indexados pelo numero, sem zeros a esquerda: o Blocked by cita 07 ou 7.
ordem=""
for f in "$dir"/issues/[0-9]*.md; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"; p="${b%%[!0-9]*}"; n=$((10#$p))
    arq[n]="$f"; rot[n]="$p"
    titulo[n]="$(sed -n '1{s/^# *//;s/^[0-9][0-9]*: *//;p;}' "$f")"
    st[n]="$(sed -n 's/^\**Status:\** *//p' "$f" | sed -n '1s/[[:space:]]*$//p')"
    bl[n]="$(sed -n 's/^\**Blocked by:\** *//p' "$f" | sed -n 1p | grep -oE '[0-9]+' | while read -r x; do echo $((10#$x)); done | tr '\n' ' ')"
    rv="$(grep -E '^\**Review:' "$f")"
    if [ -n "$rv" ]; then
        nrev[n]="$(printf '%s\n' "$rv" | wc -l | tr -d ' ')"
        u="$(printf '%s\n' "$rv" | sed -n '$p')"
        r="$(printf '%s\n' "$u" | sed -n 's/.*round=\([0-9][0-9]*\).*/\1/p')"
        v="$(printf '%s\n' "$u" | sed -n 's/.*verdict=\([a-z]*\).*/\1/p')"
        ult[n]="round=${r:-?}/${v:-?}"
        if [ -n "$r" ] && [ "$r" -ge 2 ] && [ "$v" = fail ]; then
            trav[n]=1
            # o P1 que travou: as linhas da ultima rodada no ## Comments, no formato do perfil
            p1[n]="$(sed -n '/^## Comments/,$p' "$f" | grep -E "^- *Review round=$r[^0-9].*P1" | sed 's/^- *//')"
            [ -n "${p1[n]}" ] || p1[n]="nenhuma linha 'Review round=$r · P1' no ## Comments"
        fi
    else
        nrev[n]=0; ult[n]="-"
    fi
    ordem="$ordem $n"
done
ordem="$(printf '%s\n' $ordem | sort -n | tr '\n' ' ')"
[ -n "${ordem// /}" ] || recusa "a spec $dir não tem tickets em issues/."

tem() { case " $1 " in *" $2 "*) return 0 ;; esac; return 1; }
resolvido() { [ "${st[$1]:-}" = resolved ]; }
pular=" "; for x in $(printf '%s' "$skip" | tr ',' ' '); do
    case "$x" in *[!0-9]*|"") ;; *) pular="$pular$((10#$x)) " ;; esac
done

frontier=""; pulados=""; travados=""; tudo=sim; proximo=""
for n in $ordem; do
    resolvido "$n" || tudo=nao
    if resolvido "$n"; then classe[n]=resolvido
    elif [ -n "${trav[n]:-}" ]; then classe[n]=travado; travados="$travados $n"
    else
        falta=""
        for b in ${bl[n]}; do resolvido "$b" || falta="$falta,${rot[b]:-$b}"; done
        if [ -n "$falta" ]; then classe[n]="aguardando:${falta#,}"
        elif tem "$pular" "$n"; then classe[n]=pulado; pulados="$pulados $n"
        else classe[n]=frontier; frontier="$frontier $n"; [ -n "$proximo" ] || proximo="$n"
        fi
    fi
done

# Quem depende de um travado, direta ou indiretamente, e ainda nao esta resolvido.
fecho=" $travados "; mudou=1
while [ "$mudou" = 1 ]; do
    mudou=0
    for n in $ordem; do
        resolvido "$n" && continue; tem "$fecho" "$n" && continue
        for b in ${bl[n]}; do
            if tem "$fecho" "$b"; then fecho="$fecho$n "; mudou=1; break; fi
        done
    done
done
dependentes=""; for n in $ordem; do tem "$fecho" "$n" && ! tem "$travados" "$n" && dependentes="$dependentes $n"; done

rotulos() { local s=""; for n in $1; do s="$s ${rot[n]}"; done; echo "${s# }"; }
ou_traco() { [ -n "$1" ] && echo "$1" || echo "-"; }

sujos="$(git status --porcelain | wc -l | tr -d ' ')"
echo "spec: $dir"
echo "branch: $branch"
[ "$sujos" = 0 ] && echo "arvore: limpa" || echo "arvore: suja ($sujos caminhos)"
[ -d "$dir/ui" ] && echo "tela: $dir/ui/ existe" || echo "tela: sem $dir/ui/"
for n in $ordem; do
    bb=""; for b in ${bl[n]}; do
        if [ -n "${rot[b]:-}" ]; then bb="$bb,${rot[b]}"; else bb="$bb,$b(não existe)"; fi
    done
    echo "ticket ${rot[n]} status=${st[n]:-?} reviews=${nrev[n]} ultima=${ult[n]} bloqueado_por=$(ou_traco "${bb#,}") classe=${classe[n]} — ${titulo[n]}"
done
echo "frontier: $(ou_traco "$(rotulos "$frontier")")"
echo "pulados: $(ou_traco "$(rotulos "$pulados")")"
echo "travados: $(ou_traco "$(rotulos "$travados")")"
for n in $travados; do
    printf '%s\n' "${p1[n]}" | while IFS= read -r l; do echo "p1_aberto ${rot[n]}: $l"; done
done
echo "dependem_de_travado: $(ou_traco "$(rotulos "$dependentes")")"
echo "tudo_resolvido: $tudo"
if [ -n "$proximo" ] && [ "$sujos" != 0 ]; then
    echo "parada: a árvore tem $sujos caminhos fora de commit, e um implementer novo os commitaria junto. O operador decide o que fazer com eles."
    proximo=""
fi
echo "proximo: $([ -n "$proximo" ] && echo "${arq[proximo]}" || echo nenhum)"
