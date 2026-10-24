#!/usr/bin/env bash
# O comando de verificacao do projeto, para o piloto automatico, a skill anvil-auto.
#
# Uso, de dentro do repositorio, com a camada na instalacao de usuario:
#   bash ~/.omp/agent/skills/anvil-auto/verification.sh check
#   bash ~/.omp/agent/skills/anvil-auto/verification.sh run
#
# O comando e o primeiro bloco bash da secao de .claude/rules/anvil.md cujo titulo
# e exatamente "## Comando de verificação", o que o anvil-boot grava: da cerca de
# abertura "```bash" ate a cerca de fechamento "```". check imprime o comando e sai
# com 0. run o roda com o bash, da raiz do repositorio, e imprime, depois da saida
# dele, uma ultima linha "exit: <codigo>"; sai com o codigo do comando. Sem o
# arquivo, sem a secao, sem bloco bash nela, com o bloco sem a cerca de fechamento
# ou com o bloco vazio, as duas saem com 2 e uma linha "refusal:", com o motivo em
# pt-BR, sem rodar nada.
set -u

refuse() { echo "refusal: $1"; exit 2; }

case "${1:-}" in
    check|run) op="$1" ;;
    *) refuse "a operação é check ou run, e veio '${1:-}'" ;;
esac

root="$(git rev-parse --show-toplevel 2>/dev/null)" || refuse "fora de um repositório git"
cd "$root" || exit 1

rule=.claude/rules/anvil.md
title='## Comando de verificação'
[ -f "$rule" ] || refuse "não há $rule, onde mora a seção '$title'"

# awk sai com 3 sem a secao, com 4 sem bloco bash nela, com 5 sem a cerca de
# fechamento do bloco. Dentro do bloco, uma linha "## " e comentario do bash, e nao
# titulo.
command="$(awk -v title="$title" '
    $0 == title { section = 1; next }
    section && !block && /^## / { exit }
    section && $0 == "```bash" { block = 1; next }
    block && $0 == "```" { closed = 1; exit }
    block { print }
    END { if (!section) exit 3; if (!block) exit 4; if (!closed) exit 5 }
' "$rule")"
case $? in
    0) ;;
    3) refuse "$rule não tem a seção '$title', com esse título exato" ;;
    4) refuse "a seção '$title' de $rule não tem bloco bash" ;;
    5) refuse "o bloco bash da seção '$title' de $rule não tem a cerca de fechamento \`\`\`" ;;
    *) refuse "$rule não pôde ser lido" ;;
esac
case "$command" in
    *[![:space:]]*) ;;
    *) refuse "o bloco bash da seção '$title' de $rule está vazio" ;;
esac

if [ "$op" = check ]; then
    printf '%s\n' "$command"
    exit 0
fi
bash -c "$command"
code=$?
echo "exit: $code"
exit "$code"
