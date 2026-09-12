#!/usr/bin/env bash
# dev-link.sh — expoe o payload como skills instaladas, por symlink.
#
# O anvil e construido pelo proprio anvil. A fonte das skills e
# anvil/.claude/skills/, mas o Claude Code so le .claude/skills/. Copiar criaria
# duas copias das mesmas skills, e a editada seria a errada — a que esta
# carregada. O symlink deixa uma fonte so: editar a skill instalada E editar o
# payload, e o rollback e um git checkout.
#
# Isto nao e o caminho de um projeto. La e o degit. Isto existe porque este
# repositorio E a fonte.
#
#   dev-link.sh [--dry-run]     liga o roster de fluxo
#   dev-link.sh --all           liga o payload inteiro
#   dev-link.sh --unlink        remove os symlinks, e somente eles
#
# anvil-sync nao e linkada: ela vive na raiz, e do repositorio e nao vai no degit.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PAYLOAD="$ROOT/anvil/.claude/skills"
DEST="$ROOT/.claude/skills"

[ -d "$PAYLOAD" ] || { echo "erro: payload nao encontrado em $PAYLOAD" >&2; exit 2; }

# --- o roster ------------------------------------------------------------------
# Da ideia ao commit, mais as skills que essas invocam de verdade. Nao e o
# payload inteiro: UI, stack e bench nao tem o que fazer neste repositorio e so
# competiriam por atencao — o bench, cuja description dispara em "long or
# multi-part task", chegaria a se auto-invocar dentro do implement.
#
# `anvil-update` fica de fora DE PROPOSITO: rodar o update aqui baixaria o
# payload publicado por cima do payload fonte. Nao estar instalado e a trava.
# O `anvil-boot` fica, como ficaria num projeto — e idempotente, e a estrutura
# deste repositorio ainda vai mudar.
#
# A lista e curadoria, nao deducao: prosa citando `/anvil-update` e
# sintaticamente igual a uma invocacao, e um fecho automatico religa justamente
# o que se quis manter fora. O fecho abaixo so AVISA.
ROSTER="anvil-boot
anvil-grill
anvil-grilling
anvil-domain-modeling
anvil-to-spec
anvil-to-tickets
anvil-implement
anvil-tdd
anvil-codebase-design
anvil-code-review
anvil-docs
anvil-setup
anvil-research
anvil-how
anvil-architect
anvil-arena
anvil-unslop
anvil-writing-for-agents
tea-commit"

MODO="roster"; DRY=0
while [ $# -gt 0 ]; do
    case "$1" in
        --all)     MODO="all";    shift ;;
        --unlink)  MODO="unlink"; shift ;;
        --dry-run) DRY=1;         shift ;;
        -h|--help) sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

disponiveis=""
for d in "$PAYLOAD"/*/; do
    [ -d "$d" ] && disponiveis="$disponiveis$(basename "$d")"$'\n'
done
conta() { printf '%s' "$1" | grep -c . || true; }

# --- unlink -------------------------------------------------------------------
# Remove symlink nosso, nunca diretorio real: skill escrita a mao dentro de
# .claude/skills/ nao e nossa para apagar.
if [ "$MODO" = "unlink" ]; then
    n=0
    for l in "$DEST"/*; do
        [ -L "$l" ] || continue
        case "$(readlink "$l")" in *anvil/.claude/skills/*) ;; *) continue ;; esac
        [ "$DRY" -eq 1 ] && echo "removeria $(basename "$l")" || rm -f "$l"
        n=$((n + 1))
    done
    echo "$n symlink(s) $([ "$DRY" -eq 1 ] && echo "a remover" || echo "removido(s)")."
    exit 0
fi

[ "$MODO" = "all" ] && conjunto="$disponiveis" || conjunto="$ROSTER"

# --- ligar --------------------------------------------------------------------
mkdir -p "$DEST"
ligados=0; ausentes=""; pulados=""
for s in $conjunto; do
    if [ ! -d "$PAYLOAD/$s" ]; then
        ausentes="$ausentes$s"$'\n'   # roster envelheceu: a skill saiu do payload
        continue
    fi
    alvo="$DEST/$s"
    if [ -e "$alvo" ] && [ ! -L "$alvo" ]; then
        pulados="$pulados$s"$'\n'     # diretorio real: nao e nosso para sobrescrever
        continue
    fi
    if [ "$DRY" -eq 1 ]; then
        echo "ligaria $s"
    else
        rm -f "$alvo"
        ln -s "../../anvil/.claude/skills/$s" "$alvo"
    fi
    ligados=$((ligados + 1))
done

echo
echo "$ligados de $(conta "$disponiveis") skills do payload $([ "$DRY" -eq 1 ] && echo "seriam ligadas" || echo "ligadas")."
[ -n "$ausentes" ] && { echo "NO ROSTER MAS FORA DO PAYLOAD — revise a lista:"; printf '%s' "$ausentes" | sed 's/^/  /'; }
[ -n "$pulados"  ] && { echo "pulados, porque sao diretorio real e nao symlink:"; printf '%s' "$pulados" | sed 's/^/  /'; }

# --- aviso: referencia para fora do roster ------------------------------------
# Nao religa nada. Existe para a lista nao apodrecer em silencio: uma skill
# ligada apontando para uma que nao esta e ou uma dependencia esquecida, ou uma
# ausencia deliberada. Quem decide e voce.
penduradas=""
for s in $conjunto; do
    [ -d "$PAYLOAD/$s" ] || continue
    for ref in $(grep -rhoE '"(anvil|tea)-[a-z0-9-]+"|\.\./(anvil|tea)-[a-z0-9-]+' "$PAYLOAD/$s" 2>/dev/null \
                 | grep -oE '(anvil|tea)-[a-z0-9-]+' | sort -u); do
        [ "$ref" = "$s" ] && continue
        printf '%s\n' "$conjunto"    | grep -qx "$ref" && continue
        printf '%s\n' "$penduradas"  | grep -q "^$s -> $ref\$" && continue
        penduradas="$penduradas$s -> $ref"$'\n'
    done
done
[ -n "$penduradas" ] && { echo; echo "referencias para fora do roster (nao religadas):"; printf '%s' "$penduradas" | sed 's/^/  /'; }

echo
echo "as skills so aparecem na PROXIMA sessao do Claude Code."
