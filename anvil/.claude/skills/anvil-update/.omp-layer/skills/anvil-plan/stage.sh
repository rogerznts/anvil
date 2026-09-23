#!/usr/bin/env bash
# Onde o planejamento de uma spec esta, lido do disco, para a skill anvil-plan.
#
# Uso, de dentro do repositorio:
#   bash .omp/skills/anvil-plan/stage.sh
#
# A spec sai do prefixo numerico do branch atual, {tipo}/{NNN}-{nome}, casado com
# a pasta docs/specs/{NNN}-*/ pelo numero, como no perfil do tracker. Nada e
# escrito: a etapa e derivada do disco, como manda o ADR-0003.
#
#   sem spec no branch            -> next: anvil-grill
#   pasta da spec sem spec.md     -> next: anvil-to-spec
#   spec.md sem ticket em issues/ -> next: anvil-to-tickets
#   ticket em issues/             -> next: end, com a linha handoff
#
# Um anvil-grill aqui diz so que o disco esta vazio. Se o grill ja fechou nesta
# conversa, quem sabe disso e a skill.
set -u

root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "branch: -"
    echo "spec: none (fora de um repositório git)"
    echo "next: anvil-grill"
    exit 0
}
cd "$root" || exit 1

branch="$(git branch --show-current)"
num="$(printf '%s\n' "$branch" | sed -n 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p')"
echo "branch: ${branch:-HEAD destacado}"

dir=""
if [ -n "$num" ]; then
    for d in docs/specs/[0-9]*/; do
        [ -d "$d" ] || continue
        p="$(basename "$d")"; p="${p%%[!0-9]*}"
        [ -n "$p" ] && [ $((10#$p)) -eq $((10#$num)) ] && { dir="${d%/}"; break; }
    done
fi

if [ -z "$dir" ]; then
    if [ -z "$num" ]; then
        echo "spec: none (o branch não é de spec)"
    else
        echo "spec: none (nenhuma pasta docs/specs/$num-*/ neste branch)"
    fi
    echo "next: anvil-grill"
    exit 0
fi

tickets=0
for f in "$dir"/issues/[0-9]*.md; do [ -f "$f" ] && tickets=$((tickets+1)); done
echo "spec: $dir"
[ -f "$dir/spec.md" ] && echo "spec_md: yes" || echo "spec_md: no"
echo "tickets: $tickets"

if [ "$tickets" -gt 0 ]; then
    echo "next: end"
    echo "handoff: /clear, e depois /skill:anvil-run $num"
elif [ -f "$dir/spec.md" ]; then
    echo "next: anvil-to-tickets"
else
    echo "next: anvil-to-spec"
fi
