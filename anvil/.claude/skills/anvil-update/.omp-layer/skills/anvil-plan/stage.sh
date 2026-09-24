#!/usr/bin/env bash
# Onde o planejamento de uma spec esta, lido do disco, para a skill anvil-plan.
#
# Uso, de dentro do repositorio:
#   bash .omp/skills/anvil-plan/stage.sh
#
# A spec sai do prefixo numerico do branch atual, {tipo}/{NNN}-{nome}, casado com
# a pasta docs/specs/{NNN}-*/ pelo numero, como no perfil do tracker. Nada e
# escrito: a etapa e derivada do disco, como manda o ADR-0003. Saem as linhas
# next, reason com o motivo, do com o que a skill faz, e, no fim, a handoff. Toda
# etapa que o disco aponta e retomada, e retomada se propoe, nunca se carrega: o
# do diz isso ao modelo, porque na prosa o haiku carregou a etapa sem o sim.
#
#   sem spec no branch                          -> anvil-grill
#   spec do branch em docs/specs/archive/       -> none
#   sem spec.md, map.md com decisao aberta      -> anvil-wayfinder
#   sem spec.md, nos outros casos               -> anvil-to-spec
#   spec.md sem ticket de implementacao         -> anvil-to-tickets
#   spec.md com ticket de implementacao         -> end
#
# O mapa do anvil-wayfinder mora na mesma pasta: map.md, e tickets de decisao em
# issues/, com uma linha Type:. Ticket sem Type: e de implementacao. Um
# anvil-grill aqui diz so que o disco esta vazio. Se o grill ja fechou nesta
# conversa, quem sabe disso e a skill.
set -u

saida() {  # <next> <reason>: o do diz o que a skill faz com o next
    echo "next: $1"
    echo "reason: $2"
    case "$1" in
        anvil-grill) echo "do: sem spec no disco, a conversa decide; siga a regra de next: anvil-grill da skill" ;;
        end)         echo "do: mostre a linha handoff ao operador, sem executá-la, e não carregue nada" ;;
        none)        echo "do: diga ao operador que a spec deste branch está arquivada e pare, sem carregar nada" ;;
        *)           echo "do: proponha $1 ao operador e termine a vez; carregue a skill só depois do sim, numa vez seguinte" ;;
    esac
}

root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "branch: -"; echo "spec: none"
    saida anvil-grill "fora de um repositório git"
    exit 0
}
cd "$root" || exit 1

branch="$(git branch --show-current)"
num="$(printf '%s\n' "$branch" | sed -n 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p')"
echo "branch: ${branch:-HEAD destacado}"

pasta_de() {  # <diretorio pai>: a pasta de spec com o numero do branch
    local d p
    for d in "$1"/[0-9]*/; do
        [ -d "$d" ] || continue
        p="$(basename "$d")"; p="${p%%[!0-9]*}"
        [ -n "$p" ] && [ $((10#$p)) -eq $((10#$num)) ] && { echo "${d%/}"; return; }
    done
}

if [ -z "$num" ]; then
    echo "spec: none"
    saida anvil-grill "o branch não é de spec"
    exit 0
fi
dir="$(pasta_de docs/specs)"
if [ -z "$dir" ]; then
    arq="$(pasta_de docs/specs/archive)"
    if [ -n "$arq" ]; then
        echo "spec: $arq"
        saida none "a spec deste branch está arquivada"
    else
        echo "spec: none"
        saida anvil-grill "nenhuma pasta docs/specs/$num-*/ neste branch"
    fi
    exit 0
fi
echo "spec: $dir"

tickets=0; abertas=0
for f in "$dir"/issues/[0-9]*.md; do
    [ -f "$f" ] || continue
    if grep -qE '^\**Type:' "$f"; then
        st="$(sed -n 's/^\**Status:\** *//p' "$f" | sed -n '1s/[[:space:]]*$//p')"
        [ "$st" = resolved ] || abertas=$((abertas+1))
    else
        tickets=$((tickets+1))
    fi
done

if [ -f "$dir/spec.md" ]; then
    if [ "$tickets" -gt 0 ]; then
        saida end "a spec.md existe e há $tickets ticket(s) de implementação em issues/"
        echo "handoff: /clear, e depois /skill:anvil-run $num"
    else
        saida anvil-to-tickets "a spec.md existe e não há ticket de implementação"
    fi
elif [ -f "$dir/map.md" ] && [ "$abertas" -gt 0 ]; then
    saida anvil-wayfinder "o map.md do wayfinder tem $abertas decisão(ões) aberta(s), e a spec.md ainda não foi escrita"
elif [ -f "$dir/map.md" ]; then
    saida anvil-to-spec "o map.md do wayfinder não tem decisão aberta, e a spec.md ainda não foi escrita"
else
    saida anvil-to-spec "a pasta da spec existe e a spec.md ainda não foi escrita"
fi
