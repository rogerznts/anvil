#!/usr/bin/env bash
# Estado de uma spec do anvil, lido do disco, para a skill anvil-run.
#
# Uso, de dentro do repositorio:
#   bash .omp/skills/anvil-run/frontier.sh [NNN] [--skip "NN NN"]
#
# Sem NNN, a spec sai do prefixo numerico do branch atual, {tipo}/{NNN}-{nome}.
# --skip tira do frontier os tickets que o supervisor ja despachou nesta execucao
# sem que o estado mudasse. Sai com 2 e uma linha "refusal:" quando nao ha o que
# conduzir daqui; com 0 e o estado da spec, uma linha por chave, nos outros casos.
# As chaves e os valores fixos sao em ingles e estaveis; o texto depois deles, o
# motivo para o operador, e em pt-BR.
#
# Frontier: ticket com Status: diferente de resolved, com todos os Blocked by
# resolvidos e nao travado. Travado (locked): a ultima linha Review: tem round 2 ou
# mais e verdict=fail. Bloqueio ilegivel (unreadable_blockers): o Blocked by nao e
# uma lista de numeros, e na duvida o ticket fica fora. Com a arvore suja e um next,
# o next e none e sai uma linha "halt:": o implementer seguinte commitaria o que
# sobrou junto com o ticket dele. Com a arvore suja e tudo resolvido, tambem: o
# proximo passo da spec partiria do que esta fora de commit, como o trabalho que
# a isolacao em modo patch integra sem commit. A linha abre com o modo da execucao
# e, fora do modo branch, com a configuracao que falta, e diz como sair: git stash
# -u ou um commit. O supervisor abre o relatorio com ela, como esta.
#
# ready: quantos tickets estao no frontier, para medir se o paralelo compensa.
# frontier_files: os caminhos dos tickets do frontier, na ordem da linha frontier,
# para a leva do paralelo; sem halt, o next e o primeiro deles.
#
# Isolacao: a linha "isolation:" diz o modo da execucao, lido da configuracao do
# omp com omp config get, na raiz do projeto, porque o omp le o .omp/config.yml do
# diretorio em que roda. on: task.isolation.enabled true e task.isolation.merge
# branch. misconfigured: ligada com outro merge, que integra sem commit. off: o
# resto, inclusive sem resposta do omp.
set -u

refuse() { echo "refusal: $1"; exit 2; }

# Perfil do tracker: so o do anvil, cujo titulo nomeia docs/specs, guarda spec e
# tickets onde este script le. Com outro perfil do anvil-setup (GitHub, GitLab,
# markdown local) ou sem o arquivo, ecoa o motivo da recusa; com o docs/specs, nada.
# O mesmo texto sai no stage.sh da anvil-plan.
tracker_refusal() {
    local profile=docs/agents/issue-tracker.md title
    if [ ! -f "$profile" ]; then
        echo "não há $profile, o perfil do tracker, e os condutores só funcionam com o perfil docs/specs do anvil. Rode /skill:anvil-setup para escrevê-lo."
        return
    fi
    title="$(sed -n '/^# /{s/^# *//;p;q;}' "$profile")"
    case "$title" in *docs/specs*) return ;; esac
    title="${title#Issue tracker: }"
    echo "o perfil do tracker em $profile é '${title:-sem título}', e os condutores só funcionam com o perfil docs/specs do anvil. O fluxo segue à mão, uma skill por vez, como no Claude Code."
}

arg=""; skip=""
while [ $# -gt 0 ]; do
    case "$1" in
        --skip) [ $# -ge 2 ] || refuse "--skip pede a lista de tickets"; skip="$2"; shift 2 ;;
        *)      arg="$1"; shift ;;
    esac
done
case "$arg" in
    "") ;;
    *[!0-9]*) refuse "o argumento é o número da spec, como 003, e veio '$arg'" ;;
esac

root="$(git rev-parse --show-toplevel 2>/dev/null)" || refuse "fora de um repositório git"
cd "$root" || exit 1
reason="$(tracker_refusal)"
[ -z "$reason" ] || refuse "$reason"

branch="$(git branch --show-current)"
num_of() { printf '%s\n' "$1" | sed -n 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p'; }
branch_num="$(num_of "$branch")"

if [ -z "$arg" ]; then
    [ -n "$branch_num" ] || refuse "o branch atual, '${branch:-HEAD destacado}', não é de spec. Passe o número da spec ou troque para o branch dela, {tipo}/{NNN}-{nome}."
    arg="$branch_num"
fi
spec_num=$((10#$arg))

if [ -z "$branch_num" ] || [ $((10#$branch_num)) -ne "$spec_num" ]; then
    candidates=""
    for b in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
        c="$(num_of "$b")"
        [ -n "$c" ] && [ $((10#$c)) -eq "$spec_num" ] && candidates="$candidates '$b'"
    done
    if [ -n "$candidates" ]; then
        refuse "a spec $arg roda no branch dela, e o atual é '${branch:-HEAD destacado}'. Troque para${candidates}."
    fi
    refuse "a spec $arg roda no branch dela, {tipo}/$arg-{nome}, e o atual é '${branch:-HEAD destacado}'. Nenhum branch local com esse número existe."
fi

dir=""
for d in docs/specs/[0-9]*/; do
    [ -d "$d" ] || continue
    b="$(basename "$d")"; p="${b%%[!0-9]*}"
    [ -n "$p" ] && [ $((10#$p)) -eq "$spec_num" ] && { dir="${d%/}"; break; }
done
[ -n "$dir" ] || refuse "não há pasta docs/specs/$arg-*/ neste branch. Spec arquivada não tem o que conduzir."

# Le o valor da primeira linha Blocked by em blocker_list, os numeros sem zeros a
# esquerda. Vazio ou "Nenhum"/"None" e sem bloqueador. Cada item entre virgulas e
# um numero. O item que cita um ADR-NNNN perde a citacao e sai se sobrar so um
# "ver" ou "see": "03, ver ADR-0011" bloqueia pelo 03, e "Escrever o ADR-0012",
# que pode ser o titulo de um ticket, e ilegivel. Qualquer outra coisa da
# unreadable=1.
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

# --- tickets ------------------------------------------------------------------
# Indexados pelo numero, sem zeros a esquerda: o Blocked by cita 07 ou 7.
order=""
for f in "$dir"/issues/[0-9]*.md; do
    [ -f "$f" ] || continue
    b="$(basename "$f")"; p="${b%%[!0-9]*}"; n=$((10#$p))
    file[n]="$f"; label[n]="$p"
    title[n]="$(sed -n '1{s/^# *//;s/^[0-9][0-9]*: *//;p;}' "$f")"
    status[n]="$(sed -n 's/^\**Status:\** *//p' "$f" | sed -n '1s/[[:space:]]*$//p')"
    blocked_raw[n]="$(sed -n 's/^\**Blocked by:\** *//p' "$f" | sed -n '1s/[[:space:]]*$//p')"
    read_blockers "${blocked_raw[n]}"
    blockers[n]="$blocker_list"; is_unreadable[n]="$unreadable"
    review_lines="$(grep -E '^\**Review:' "$f")"
    if [ -n "$review_lines" ]; then
        reviews[n]="$(printf '%s\n' "$review_lines" | wc -l | tr -d ' ')"
        last_review="$(printf '%s\n' "$review_lines" | sed -n '$p')"
        round="$(printf '%s\n' "$last_review" | sed -n 's/.*round=\([0-9][0-9]*\).*/\1/p')"
        verdict="$(printf '%s\n' "$last_review" | sed -n 's/.*verdict=\([a-z]*\).*/\1/p')"
        last[n]="round=${round:-?}/${verdict:-?}"
        if [ -n "$round" ] && [ "$round" -ge 2 ] && [ "$verdict" = fail ]; then
            is_locked[n]=1
            # o P1 que travou: as linhas "Review round=N ·" da ultima rodada no ## Comments
            # com P1 em posicao de classe, palavra inteira seguida de " (" ou ":", em
            # qualquer ponto depois do ponto medio. "P2 (Standards) e P1 (Spec)" conta;
            # "prova fraca do P1 anterior" nao. LC_ALL=C: a mesma leitura em qualquer locale.
            open_p1[n]="$(sed -n '/^## Comments/,$p' "$f" | LC_ALL=C grep -E "^- *Review round=$round · (.*[^[:alnum:]_])?P1( \(|:)" | sed 's/^- *//')"
            [ -n "${open_p1[n]}" ] || open_p1[n]="nenhuma linha 'Review round=$round · P1' no ## Comments"
        fi
    else
        reviews[n]=0; last[n]="-"
    fi
    order="$order $n"
done
order="$(printf '%s\n' $order | sort -n | tr '\n' ' ')"
[ -n "${order// /}" ] || refuse "a spec $dir não tem tickets em issues/."

has() { case " $1 " in *" $2 "*) return 0 ;; esac; return 1; }
is_resolved() { [ "${status[$1]:-}" = resolved ]; }
skip_set=" "; for x in $(printf '%s' "$skip" | tr ',' ' '); do
    case "$x" in *[!0-9]*|"") ;; *) skip_set="$skip_set$((10#$x)) " ;; esac
done

frontier=""; skipped=""; locked=""; all_resolved=yes; next=""
for n in $order; do
    is_resolved "$n" || all_resolved=no
    if is_resolved "$n"; then class[n]=resolved
    elif [ -n "${is_locked[n]:-}" ]; then class[n]=locked; locked="$locked $n"
    elif [ -n "${is_unreadable[n]}" ]; then class[n]=unreadable_blockers
    else
        missing=""
        for b in ${blockers[n]}; do is_resolved "$b" || missing="$missing,${label[b]:-$b}"; done
        if [ -n "$missing" ]; then class[n]="waiting:${missing#,}"
        elif has "$skip_set" "$n"; then class[n]=skipped; skipped="$skipped $n"
        else class[n]=frontier; frontier="$frontier $n"; [ -n "$next" ] || next="$n"
        fi
    fi
done

# Quem depende de um travado, direta ou indiretamente, e ainda nao esta resolvido.
closure=" $locked "; changed=1
while [ "$changed" = 1 ]; do
    changed=0
    for n in $order; do
        is_resolved "$n" && continue; has "$closure" "$n" && continue
        for b in ${blockers[n]}; do
            if has "$closure" "$b"; then closure="$closure$n "; changed=1; break; fi
        done
    done
done
dependents=""; for n in $order; do has "$closure" "$n" && ! has "$locked" "$n" && dependents="$dependents $n"; done

labels() { local s=""; for n in $1; do s="$s ${label[n]}"; done; echo "${s# }"; }
or_dash() { [ -n "$1" ] && echo "$1" || echo "-"; }

dirty="$(git status --porcelain | wc -l | tr -d ' ')"
echo "spec: $dir"
echo "branch: $branch"
[ "$dirty" = 0 ] && echo "tree: clean" || echo "tree: dirty ($dirty)"
iso_enabled="$(omp config get task.isolation.enabled 2>/dev/null)" || iso_enabled=""
iso_mode="execução sem isolação"
if [ -z "$iso_enabled" ]; then
    echo "isolation: off (task.isolation.enabled não foi lido pelo omp config get)"
elif [ "$iso_enabled" != true ]; then
    echo "isolation: off (task.isolation.enabled: $iso_enabled)"
else
    iso_merge="$(omp config get task.isolation.merge 2>/dev/null)" || iso_merge=""
    if [ "$iso_merge" = branch ]; then
        echo "isolation: on (task.isolation.enabled: true, task.isolation.merge: branch)"
        iso_mode="execução com isolação"
    else
        echo "isolation: misconfigured (task.isolation.enabled: true, task.isolation.merge: ${iso_merge:-não lido}; o trabalho isolado só volta como commits com task.isolation.merge: branch)"
        iso_mode="execução com isolação fora do modo branch, que integra o trabalho sem commit: falta task.isolation.merge: branch"
    fi
fi
# Tela: a pasta ui/ da spec, ou uma user story que fala de algo que o usuario ve.
# A palavra e so o padrao: o supervisor le as linhas story e pode subir um "no"
# para o browser QA quando a historia descreve tela com outras palavras.
# A comparacao e do perl, em UTF-8 fixo, sem caixa e so com palavra inteira: o grep
# segue o locale, e em LC_ALL=C nao iguala "PÁGINA" a "página" e ve "painel" em
# "painelão". LC_ALL=C no perl so evita o aviso de locale ausente.
stories="$(sed -n '/^## User Stories/,/^## [^#]/p' "$dir/spec.md" 2>/dev/null | grep -E '^[0-9]+\. ')"
# "interface" so conta com o que diz que ela abre na tela: web, gráfica, visual ou do
# usuário. "interface executável" ou "de linha de comando" nao e tela (falso positivo
# no ponta a ponta da spec 004).
SCREEN_WORDS='telas?|páginas?|paginas?|painel|painéis|formulários?|formularios?|interfaces? (?:web|gráficas?|graficas?|visual|visuais|do usuário|do usuario|de usuário|de usuario)|navegador|browser|botão|botões|botao|botoes|dashboard|screens?|pages?|ui|frontend|layout'
screen_story="$(printf '%s\n' "$stories" | LC_ALL=C perl -CSDA -ne '
    BEGIN { $words = shift } if (/\b(?:$words)\b/i) { print /^(\d+)\./; exit }' "$SCREEN_WORDS")"
if [ -d "$dir/ui" ]; then
    echo "screen: yes ($dir/ui/ existe)"
elif [ -n "$screen_story" ]; then
    echo "screen: yes (a user story $screen_story fala de tela)"
else
    echo "screen: no (sem $dir/ui/, e nenhuma user story usa palavra de tela)"
fi
# Com tudo resolvido e sem ui/, as historias vao na saida para o supervisor conferir.
if [ "$all_resolved" = yes ] && [ ! -d "$dir/ui" ] && [ -n "$stories" ]; then
    printf '%s\n' "$stories" | while IFS= read -r l; do echo "story: $l"; done
fi
for n in $order; do
    blocked_by=""; for b in ${blockers[n]}; do
        if [ -n "${label[b]:-}" ]; then blocked_by="$blocked_by,${label[b]}"; else blocked_by="$blocked_by,$b(não existe)"; fi
    done
    # Ilegivel: o valor do Blocked by como esta no arquivo, entre aspas.
    [ -n "${is_unreadable[n]}" ] && blocked_by="\"${blocked_raw[n]}\""
    echo "ticket ${label[n]} status=${status[n]:-?} reviews=${reviews[n]} last=${last[n]} blocked_by=$(or_dash "${blocked_by#,}") class=${class[n]} — ${title[n]}"
done
echo "frontier: $(or_dash "$(labels "$frontier")")"
files=""; for n in $frontier; do files="$files ${file[n]}"; done
echo "ready: $(set -- $frontier; echo $#)"
echo "frontier_files: $(or_dash "${files# }")"
echo "skipped: $(or_dash "$(labels "$skipped")")"
echo "locked: $(or_dash "$(labels "$locked")")"
for n in $locked; do
    printf '%s\n' "${open_p1[n]}" | while IFS= read -r l; do echo "open_p1 ${label[n]}: $l"; done
done
echo "depend_on_locked: $(or_dash "$(labels "$dependents")")"
echo "all_resolved: $all_resolved"
if [ "$dirty" != 0 ]; then
    halt_why="" halt_then=""
    if [ -n "$next" ]; then halt_why="um implementer novo os commitaria junto"
    elif [ "$all_resolved" = yes ]; then
        halt_why="o próximo passo da spec partiria deles"
        halt_then=", que recomenda o próximo passo com a árvore limpa"
    fi
    [ -z "$halt_why" ] || echo "halt: $iso_mode. A árvore tem $dirty caminhos fora de commit, e $halt_why. A saída é do operador: guardá-los com git stash -u, ou fazer um commit dele, e rodar a skill de novo$halt_then."
    next=""
fi
echo "next: $([ -n "$next" ] && echo "${file[next]}" || echo none)"
