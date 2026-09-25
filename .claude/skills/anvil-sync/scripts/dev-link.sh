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
#   dev-link.sh [--dry-run]     liga o roster de fluxo e os agentes, espelha as
#                               skills ligadas em .agents/skills, e liga a camada
#                               omp em .omp/
#   dev-link.sh --all           liga o payload inteiro
#   dev-link.sh --unlink        remove os symlinks, e somente eles
#
# anvil-sync nao e linkada: ela vive na raiz, e do repositorio e nao vai no degit.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PAYLOAD="$ROOT/anvil/.claude/skills"
DEST="$ROOT/.claude/skills"
AGENTS="$ROOT/anvil/.claude/agents"
DEST_AGENTS="$ROOT/.claude/agents"
# .agents/skills e por onde o Codex le as skills. O espelho e um symlink por skill
# ligada, na forma que o reset-install.sh gera num projeto. Como la, o symlink com
# nome de skill do payload e nosso, aponte para onde apontar; o symlink na forma
# gerada tambem, mesmo com nome que saiu do payload. Diretorio e arquivo nunca.
ESPELHO="$ROOT/.agents/skills"
na_forma() { [ "$(readlink "$ESPELHO/$1")" = "../../.claude/skills/$1" ]; }
nosso_espelho() { [ -L "$ESPELHO/$1" ] && { [ -d "$PAYLOAD/$1" ] || na_forma "$1"; }; }
# A camada omp viaja no payload dentro da anvil-update, e num projeto o update a
# instala em .omp/. Aqui cada arquivo dela vira um symlink em .omp/, e editar a
# camada instalada e editar o payload. Nosso e o symlink que aponta para dentro da
# camada; o resto de .omp/ e de quem mantem o repositorio.
CAMADA="$PAYLOAD/anvil-update/.omp-layer"
OMP="$ROOT/.omp"
da_camada() {
    [ -L "$1" ] || return 1
    case "$(readlink "$1")" in *anvil/.claude/skills/anvil-update/.omp-layer/*) return 0 ;; esac
    return 1
}
# tira as pastas que a remocao deixou vazias, ate .omp, que fica
poda() {
    local d; d="$(dirname "$1")"
    while [ "$d" != "$OMP" ] && rmdir "$d" 2>/dev/null; do d="$(dirname "$d")"; done
}
nossos_omp() { [ -d "$OMP" ] && find "$OMP" -type l | while IFS= read -r l; do da_camada "$l" && echo "$l"; done; return 0; }

[ -d "$PAYLOAD" ] || { echo "erro: payload nao encontrado em $PAYLOAD" >&2; exit 2; }

# --- o roster ------------------------------------------------------------------
# Da ideia ao commit, mais as skills que essas invocam de verdade. Nao e o
# payload inteiro: UI, stack, bench e as duas de seguranca nao tem o que fazer
# neste repositorio e so competiriam por atencao — o bench, cuja description
# dispara em "long or multi-part task", chegaria a se auto-invocar dentro do
# implement. `anvil-security-map`/`anvil-security-probe` mapeiam e testam a
# superficie de ataque de um app (rotas, Local API, banco local) — este
# repositorio e o toolkit fonte, nao um app com superficie para mapear.
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
anvil-diagnose
anvil-codebase-design
anvil-code-review
anvil-docs
anvil-setup
anvil-research
anvil-distill
anvil-how
anvil-architect
anvil-arena
anvil-principles
anvil-prototype
anvil-unslop
anvil-writing-for-agents
anvil-browser-qa
anvil-next
tea-commit"

MODO="roster"; DRY=0
while [ $# -gt 0 ]; do
    case "$1" in
        --all)     MODO="all";    shift ;;
        --unlink)  MODO="unlink"; shift ;;
        --dry-run) DRY=1;         shift ;;
        -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

disponiveis=""
for d in "$PAYLOAD"/*/; do
    [ -d "$d" ] && disponiveis="$disponiveis$(basename "$d")"$'\n'
done
conta() { printf '%s' "$1" | grep -c . || true; }

# --- unlink -------------------------------------------------------------------
# Remove symlink nosso, nunca diretorio ou arquivo real: skill ou agente escrito a
# mao dentro de .claude/ nao e nosso para apagar.
if [ "$MODO" = "unlink" ]; then
    n=0
    for l in "$DEST"/* "$DEST_AGENTS"/*; do
        [ -L "$l" ] || continue
        case "$(readlink "$l")" in *anvil/.claude/skills/*|*anvil/.claude/agents/*) ;; *) continue ;; esac
        if [ "$DRY" -eq 1 ]; then echo "removeria $(basename "$l")"; else rm -f "$l"; fi
        n=$((n + 1))
    done
    for l in "$ESPELHO"/*; do
        nosso_espelho "$(basename "$l")" || continue
        if [ "$DRY" -eq 1 ]; then echo "removeria .agents/skills/$(basename "$l")"; else rm -f "$l"; fi
        n=$((n + 1))
    done
    # coletados antes: a poda some com pasta que o find ainda nao percorreu
    omp_links="$(nossos_omp)"
    while IFS= read -r l; do
        [ -n "$l" ] || continue
        if [ "$DRY" -eq 1 ]; then echo "removeria ${l#"$ROOT"/}"; else rm -f "$l"; poda "$l"; fi
        n=$((n + 1))
    done <<< "$omp_links"
    echo "$n symlink(s) $([ "$DRY" -eq 1 ] && echo "a remover" || echo "removido(s)")."
    exit 0
fi

[ "$MODO" = "all" ] && conjunto="$disponiveis" || conjunto="$ROSTER"

# --- ligar --------------------------------------------------------------------
mkdir -p "$DEST"
ligados=0; ausentes=""; pulados=""; a_ligar=""
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
    ligados=$((ligados + 1)); a_ligar="$a_ligar$s"$'\n'
done

# --- agentes -------------------------------------------------------------------
# Todos, no roster e no --all. O roster poupa a atencao que as descriptions das
# skills disputam; os agentes do payload so recebem trabalho da skill que os
# despacha, e ela os procura em .claude/agents/.
ag_ligados=0; ag_total=0; ag_pulados=""
for f in "$AGENTS"/*.md; do
    [ -f "$f" ] || continue
    a="$(basename "$f")"; ag_total=$((ag_total + 1))
    alvo="$DEST_AGENTS/$a"
    if [ -e "$alvo" ] && [ ! -L "$alvo" ]; then
        ag_pulados="$ag_pulados$a"$'\n'   # arquivo real: nao e nosso para sobrescrever
        continue
    fi
    if [ "$DRY" -eq 1 ]; then
        echo "ligaria .claude/agents/$a"
    else
        mkdir -p "$DEST_AGENTS"
        rm -f "$alvo"
        ln -s "../../anvil/.claude/agents/$a" "$alvo"
    fi
    ag_ligados=$((ag_ligados + 1))
done

# --- espelho do Codex ------------------------------------------------------------
# Gerado a partir do que esta ligado agora em .claude/skills, nao so do conjunto
# desta execucao: o roster nao desliga o que um --all ligou antes. Symlink nosso que
# aponta para outro lugar e refeito, e o de skill que nao esta mais ligada sai.
# Diretorio ou arquivo fica, mesmo com nome de skill: `ln -s` sobre um diretorio
# criaria o link dentro dele.
ligada() {
    printf '%s' "$a_ligar" | grep -qxF -e "$1" && return 0
    [ -d "$PAYLOAD/$1" ] && [ -L "$DEST/$1" ] || return 1
    case "$(readlink "$DEST/$1")" in *anvil/.claude/skills/*) return 0 ;; esac
    return 1
}
esp_criados=0; esp_removidos=0; esp_pulados=""
for s in $disponiveis; do
    ligada "$s" || continue
    if [ -L "$ESPELHO/$s" ] && na_forma "$s"; then continue; fi
    if [ -e "$ESPELHO/$s" ] && [ ! -L "$ESPELHO/$s" ]; then
        esp_pulados="$esp_pulados$s"$'\n'
        continue
    fi
    if [ "$DRY" -eq 1 ]; then
        echo "espelharia $s"
    else
        mkdir -p "$ESPELHO"
        rm -f "$ESPELHO/$s"
        ln -s "../../.claude/skills/$s" "$ESPELHO/$s"
    fi
    esp_criados=$((esp_criados + 1))
done
for l in "$ESPELHO"/*; do
    s="$(basename "$l")"
    nosso_espelho "$s" || continue
    ligada "$s" && continue
    if [ "$DRY" -eq 1 ]; then echo "removeria do espelho $s"; else rm -f "$l"; fi
    esp_removidos=$((esp_removidos + 1))
done

# --- camada omp ---------------------------------------------------------------
# Um symlink por arquivo da camada, no mesmo caminho relativo em .omp/. Arquivo real
# no caminho fica, e o arquivo sai do relatorio como pulado. O symlink nosso para um
# arquivo que saiu da camada sai, com as pastas que ficarem vazias.
omp_ligados=0; omp_removidos=0; omp_pulados=""
if [ -d "$CAMADA" ]; then
    while IFS= read -r r; do
        alvo="$OMP/$r"
        if [ -e "$alvo" ] && [ ! -L "$alvo" ]; then
            omp_pulados="$omp_pulados.omp/$r"$'\n'
            continue
        fi
        # um ../ por nivel de .omp/<r> ate a raiz
        rel="$(printf '%s' ".omp/$r" | sed 's|[^/]*/|../|g; s|[^/]*$||')anvil/.claude/skills/anvil-update/.omp-layer/$r"
        if [ "$DRY" -eq 1 ]; then
            echo "ligaria .omp/$r"
        else
            if ! mkdir -p "$(dirname "$alvo")" 2>/dev/null; then
                omp_pulados="$omp_pulados.omp/$r"$'\n'   # pasta do caminho e arquivo real
                continue
            fi
            rm -f "$alvo"
            ln -s "$rel" "$alvo"
        fi
        omp_ligados=$((omp_ligados + 1))
    done < <(cd "$CAMADA" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)
fi
omp_links="$(nossos_omp)"
while IFS= read -r l; do
    [ -n "$l" ] || continue
    [ -f "$CAMADA/${l#"$OMP"/}" ] && continue
    if [ "$DRY" -eq 1 ]; then echo "removeria ${l#"$ROOT"/}"; else rm -f "$l"; poda "$l"; fi
    omp_removidos=$((omp_removidos + 1))
done <<< "$omp_links"

echo
echo "$ligados de $(conta "$disponiveis") skills do payload $([ "$DRY" -eq 1 ] && echo "seriam ligadas" || echo "ligadas")."
echo "$ag_ligados de $ag_total agentes do payload $([ "$DRY" -eq 1 ] && echo "seriam ligados" || echo "ligados")."
echo "$esp_criados symlink(s) $([ "$DRY" -eq 1 ] && echo "seriam criados" || echo "criados") e $esp_removidos $([ "$DRY" -eq 1 ] && echo "seriam removidos" || echo "removidos") em .agents/skills."
echo "$omp_ligados arquivo(s) da camada omp $([ "$DRY" -eq 1 ] && echo "seriam ligados" || echo "ligados") e $omp_removidos symlink(s) $([ "$DRY" -eq 1 ] && echo "seriam removidos" || echo "removidos") em .omp/."
[ -n "$ausentes" ] && { echo "NO ROSTER MAS FORA DO PAYLOAD — revise a lista:"; printf '%s' "$ausentes" | sed 's/^/  /'; }
[ -n "$pulados"  ] && { echo "pulados, porque sao diretorio real e nao symlink:"; printf '%s' "$pulados" | sed 's/^/  /'; }
[ -n "$ag_pulados" ] && { echo "agentes pulados, porque sao arquivo real e nao symlink:"; printf '%s' "$ag_pulados" | sed 's/^/  /'; }
[ -n "$esp_pulados" ] && { echo "espelho pulado, porque .agents/skills tem diretorio ou arquivo com o nome:"; printf '%s' "$esp_pulados" | sed 's/^/  /'; }
[ -n "$omp_pulados" ] && { echo "camada omp pulada, porque .omp/ tem arquivo real no caminho:"; printf '%s' "$omp_pulados" | sed 's/^/  /'; }

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
        [ -f "$AGENTS/$ref.md" ] && continue   # agente do payload, nao skill: ja ligado acima
        printf '%s\n' "$conjunto"    | grep -qx "$ref" && continue
        printf '%s\n' "$penduradas"  | grep -q "^$s -> $ref\$" && continue
        penduradas="$penduradas$s -> $ref"$'\n'
    done
done
[ -n "$penduradas" ] && { echo; echo "referencias para fora do roster (nao religadas):"; printf '%s' "$penduradas" | sed 's/^/  /'; }

echo
echo "as skills, os agentes e a camada omp so aparecem na PROXIMA sessao do Claude Code e do omp."
