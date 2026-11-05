#!/usr/bin/env bash
# workz-worktree.sh — ganchos WorktreeCreate e WorktreeRemove do Claude Code,
# feitos com o workz.
#
#   workz-worktree.sh create            JSON do WorktreeCreate no stdin
#   workz-worktree.sh remove [caminho]  caminho como argumento, ou JSON do
#                                       WorktreeRemove no stdin
#
# Existe porque o `workz hook claude` da v0.11.0 imprime uma receita que não cria
# o worktree, e o Claude Code espera do gancho de criação o worktree pronto e o
# caminho dele no stdout. Quando houver release do workz com o `claude-hook`
# nativo, este script pode dar lugar a ele. Usa só comandos da v0.11.0.
#
# Só age em projeto que tem a seção `## Worktrees` no .claude/rules/anvil.md, com
# a linha `provisionar: <comando>`. Sem ela, o projeto não usa o workz, e o
# `create` recusa.
#
# `create`:
#   - o nome vem de `name`, depois `branch`, depois o nome-base de
#     `worktree_path`, reduzido a [A-Za-z0-9._-] — o resto vira `-`;
#   - branch `worktree-<nome>` a partir do HEAD do checkout principal, no caminho
#     `<pai do repo>/<repo>--worktree-<nome>`, o mesmo que o `workz done` deduz do
#     branch. Outro caminho e o `remove` não acharia o worktree;
#   - roda o `provisionar:` dentro do worktree. Falhou, desfaz worktree e branch;
#   - nome que já tem worktree é reusado: devolve o mesmo caminho, sem rodar nada.
#
# O stdout é do Claude Code: a última linha não vazia é o caminho do worktree.
# Por isso toda saída — do git, do workz, do `provisionar:` — vai para stderr, e
# o stdout recebe só o caminho, absoluto e sem symlink, e só no sucesso.
#
# `remove` roda `workz done <branch> --force --delete-branch` a partir do checkout
# principal: o `workz done` acha o repositório pelo diretório atual e o worktree
# pelo branch, e libera a porta que o `--isolated` alocou.

set -u

# O stdout original fica no descritor 3; o 1 passa a ser o stderr.
exec 3>&1 1>&2

# `>&2` explícito: a falha dentro de `$(...)` teria o 1 capturado.
falha() {
    echo "workz-worktree: $*" >&2
    exit 1
}

exige_python() {
    command -v python3 >/dev/null 2>&1 ||
        falha "python3 nao encontrado no PATH — e ele que le o JSON do Claude Code."
}

# Lê o JSON do stdin e imprime o campo pedido. `create` quer o nome; `remove`, o
# caminho. Sai 1 com o JSON inválido ou sem o campo.
campo_json() {
    python3 -c '
import json, os, sys
try:
    dados = json.load(sys.stdin)
except Exception:
    sys.exit(1)
if not isinstance(dados, dict):
    sys.exit(1)
def texto(chave):
    valor = dados.get(chave)
    return valor.strip() if isinstance(valor, str) else ""
if sys.argv[1] == "remove":
    valor = texto("worktree_path")
else:
    valor = texto("name") or texto("branch") or os.path.basename(texto("worktree_path").rstrip("/"))
if not valor:
    sys.exit(1)
print(valor)
' "$1"
}

# Checkout principal, achado pelo diretório comum do git: chamado de dentro de um
# worktree, o `--show-toplevel` daria o worktree.
raiz_principal() {
    local comum
    comum="$(git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" ||
        falha "$1 nao esta num repositorio git."
    (cd "$(git -C "$(dirname "$comum")" rev-parse --show-toplevel)" && pwd -P) ||
        falha "checkout principal nao encontrado a partir de $comum."
}

exige_workz() {
    command -v workz >/dev/null 2>&1 ||
        falha "workz nao encontrado no PATH. Instale a v0.11.0 com /anvil-update ou de https://github.com/rohansx/workz/releases/tag/v0.11.0"
}

# O `workz done` acha o repositório pelo diretório atual: roda da raiz.
workz_done() {
    (cd "$1" && workz done "$2" --force --delete-branch)
}

criar() {
    local nome slug raiz regra provisionar branch wt
    exige_python
    nome="$(campo_json create)" ||
        falha "JSON do WorktreeCreate sem name, branch nem worktree_path no stdin."
    slug="$(printf '%s' "$nome" | LC_ALL=C tr -c 'A-Za-z0-9._-' '-')"
    branch="worktree-$slug"
    git check-ref-format --branch "$branch" >/dev/null 2>&1 ||
        falha "o nome '$nome' nao da um branch valido ($branch)."

    raiz="$(raiz_principal .)" || exit 1
    regra="$raiz/.claude/rules/anvil.md"
    grep -q '^## Worktrees[[:space:]]*$' "$regra" 2>/dev/null ||
        falha "$regra sem a secao ## Worktrees: o projeto nao usa o workz. Configure com /anvil-boot."
    provisionar="$(awk '
        /^## / { dentro = ($0 ~ /^## Worktrees[[:space:]]*$/); next }
        dentro && /^provisionar:/ { sub(/^provisionar:[[:space:]]*/, ""); print; exit }
    ' "$regra")"
    [ -n "$provisionar" ] ||
        falha "a secao ## Worktrees de $regra nao tem a linha provisionar: <comando>."
    exige_workz

    wt="$(dirname "$raiz")/$(basename "$raiz")--$branch"

    if git -C "$raiz" worktree list --porcelain | grep -qxF "worktree $wt"; then
        echo "workz-worktree: reusando o worktree existente em $wt"
        printf '%s\n' "$wt" >&3
        exit 0
    fi
    [ ! -e "$wt" ] ||
        falha "$wt ja existe e nao e worktree deste repositorio."
    git -C "$raiz" show-ref --verify --quiet "refs/heads/$branch" &&
        falha "o branch $branch ja existe sem worktree. Apague-o (git branch -D $branch) ou use outro nome."

    git -C "$raiz" worktree add -b "$branch" "$wt" HEAD ||
        falha "git worktree add falhou para $wt."

    if ! (cd "$wt" && sh -c "$provisionar" </dev/null); then
        echo "workz-worktree: '$provisionar' falhou em $wt — desfazendo worktree e branch."
        workz_done "$raiz" "$branch" || {
            git -C "$raiz" worktree remove --force "$wt"
            git -C "$raiz" branch -D "$branch"
        }
        exit 1
    fi

    printf '%s\n' "$wt" >&3
}

remover() {
    local alvo wt branch raiz esperado
    alvo="${1:-}"
    if [ -z "$alvo" ]; then
        exige_python
        alvo="$(campo_json remove)" ||
            falha "sem caminho: passe-o como argumento ou em worktree_path no JSON do stdin."
    fi
    [ -d "$alvo" ] || falha "worktree nao encontrado em $alvo."
    wt="$(cd "$alvo" && pwd -P)"
    raiz="$(raiz_principal "$wt")" || exit 1
    [ "$wt" != "$raiz" ] || falha "$wt e o checkout principal, nao um worktree."
    branch="$(git -C "$wt" symbolic-ref --quiet --short HEAD)" ||
        falha "$wt nao esta num branch: o workz done acha o worktree pelo branch."
    esperado="$(dirname "$raiz")/$(basename "$raiz")--$(printf '%s' "$branch" | tr '/\\' '--')"
    [ "$wt" = "$esperado" ] ||
        falha "$wt fora da convencao do workz done para o branch $branch ($esperado)."
    exige_workz
    workz_done "$raiz" "$branch"
}

case "${1:-}" in
    create) criar ;;
    remove) shift; remover "${1:-}" ;;
    *) falha "uso: workz-worktree.sh create | remove [caminho]" ;;
esac
