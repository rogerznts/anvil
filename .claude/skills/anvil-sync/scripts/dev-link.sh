#!/usr/bin/env bash
# dev-link.sh — liga a instalacao de usuario ao payload deste repositorio, por
# symlink.
#
# O anvil e construido pelo proprio anvil. A fonte e anvil/, e o toolkit se instala
# uma vez por usuario: ~/.claude/skills, ~/.claude/agents, o espelho
# ~/.agents/skills e a camada omp em ~/.omp/agent. Copiar criaria duas copias, e a
# editada seria a errada — a que esta carregada. O symlink deixa uma fonte so:
# editar a skill instalada E editar o payload, e o rollback e um git checkout.
# Todo projeto da maquina passa a rodar a fonte em edicao, skill editada pela
# metade inclusive.
#
# Isto nao e o caminho de uma maquina comum. La e o /anvil-update, que se recusa a
# instalar por cima destes symlinks.
#
#   dev-link.sh [--dry-run]     liga o roster de fluxo em ~/.claude/skills e os
#                               agentes em ~/.claude/agents, espelha as skills
#                               ligadas em ~/.agents/skills, e liga a camada omp
#                               em ~/.omp/agent
#   dev-link.sh --all           liga o payload inteiro
#   dev-link.sh --unlink        remove os symlinks que apontam para este payload,
#                               e somente eles
#
# anvil-sync nao e ligada: ela vive em .claude/skills deste repositorio, e dele e
# nao vai no payload.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
FONTE="$ROOT/anvil/.claude"
PAYLOAD="$FONTE/skills"
AGENTS="$FONTE/agents"
# A camada omp viaja no payload dentro da anvil-update, e o update a instala em
# ~/.omp/agent. Aqui cada arquivo dela vira um symlink no mesmo caminho relativo.
CAMADA="$PAYLOAD/anvil-update/.omp-layer"

[ -d "$PAYLOAD" ] || { echo "erro: payload nao encontrado em $PAYLOAD" >&2; exit 2; }
[ -n "${HOME:-}" ] && [ -d "$HOME" ] || { echo "erro: \$HOME nao e um diretorio — e o destino da ligacao" >&2; exit 2; }
U="$(cd "$HOME" && pwd)"
DEST="$U/.claude/skills"
DEST_AGENTS="$U/.claude/agents"
ESPELHO="$U/.agents/skills"
OMP="$U/.omp/agent"

# Nosso e o symlink que aponta para dentro deste payload. O resto de HOME — skill,
# agente, arquivo, ou symlink para outro lugar — e do usuario.
nosso() {
    [ -L "$1" ] || return 1
    case "$(readlink "$1")" in "$FONTE"/*) return 0 ;; esac
    return 1
}
curto() { printf '~%s' "${1#"$U"}"; }
# tira as pastas que a remocao deixou vazias, ate <limite>, que fica
poda() {
    local d; d="$(dirname "$1")"
    while [ "$d" != "$2" ] && rmdir "$d" 2>/dev/null; do d="$(dirname "$d")"; done
}
# Os symlinks nossos da camada em ~/.omp/agent. A busca fica nas pastas de topo da
# camada: o resto de ~/.omp/agent e do omp — sessoes, bancos, cache —, com
# milhares de arquivos.
nossos_omp() {
    local top
    for top in "$CAMADA"/*; do
        [ -d "$OMP/$(basename "$top")" ] || continue
        find "$OMP/$(basename "$top")" -type l | while IFS= read -r l; do
            if nosso "$l"; then echo "$l"; fi
        done
    done
}

# --- o projeto: o que o dev-link de antes ligava ---------------------------------
# Antes da instalacao de usuario, o dev-link ligava o payload dentro deste
# repositorio, por caminho relativo: skills e agentes em .claude/, o espelho em
# .agents/skills e a camada em .omp/. Eles duplicariam a instalacao de usuario, e
# no omp a camada do projeto pode vencer a de usuario. Saem, tanto ao ligar quanto
# no --unlink. O resto de .claude, .agents e .omp e de quem mantem o repositorio,
# anvil-sync inclusive.
antigos() {
    local l n
    for l in "$ROOT"/.claude/skills/* "$ROOT"/.claude/agents/*; do
        [ -L "$l" ] || continue
        case "$(readlink "$l")" in ../../anvil/.claude/skills/*|../../anvil/.claude/agents/*) echo "$l" ;; esac
    done
    for l in "$ROOT"/.agents/skills/*; do
        n="$(basename "$l")"
        [ -L "$l" ] && [ "$(readlink "$l")" = "../../.claude/skills/$n" ] || continue
        # o espelho de uma skill do repositorio, como a anvil-sync, aponta para diretorio real
        if [ -d "$ROOT/.claude/skills/$n" ] && [ ! -L "$ROOT/.claude/skills/$n" ]; then continue; fi
        echo "$l"
    done
    [ -d "$ROOT/.omp" ] || return 0
    find "$ROOT/.omp" -type l | while IFS= read -r l; do
        case "$(readlink "$l")" in ../*anvil/.claude/skills/anvil-update/.omp-layer/*) echo "$l" ;; esac
    done
}
# coletados antes: a poda some com pasta que o find ainda nao percorreu
tira_antigos() {
    local lista l n=0
    lista="$(antigos)"
    while IFS= read -r l; do
        [ -n "$l" ] || continue
        if [ "$DRY" -eq 1 ]; then
            echo "removeria do projeto ${l#"$ROOT"/}"
        else
            rm -f "$l"
            case "$l" in "$ROOT/.omp/"*) poda "$l" "$ROOT/.omp" ;; esac
        fi
        n=$((n + 1))
    done <<< "$lista"
    antigos_n="$n"
}

# --- o roster ------------------------------------------------------------------
# Da ideia ao commit, mais as skills que essas invocam de verdade. Nao e o
# payload inteiro: UI, stack e bench nao tem o que fazer neste repositorio e so
# competiriam por atencao — o bench, cuja description dispara em "long or
# multi-part task", chegaria a se auto-invocar dentro do implement.
#
# `anvil-update` fica de fora DE PROPOSITO: rodar o update aqui baixaria o
# payload publicado por cima do payload fonte. Nao estar instalado e a trava, e o
# reset-install ainda recusa instalar por cima destes symlinks.
# O `anvil-boot` fica, como ficaria num projeto — e idempotente, e a estrutura
# deste repositorio ainda vai mudar.
# O `anvil-security-audit` fica: o modo guidance, que e o padrao dela, nao
# escreve arquivo nem roda as seis fases sem pedido explicito (ADR-0015).
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
anvil-security-audit
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
        -h|--help) sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

disponiveis=""
for d in "$PAYLOAD"/*/; do
    [ -d "$d" ] && disponiveis="$disponiveis$(basename "$d")"$'\n'
done
conta() { printf '%s' "$1" | grep -c . || true; }

# --- unlink -------------------------------------------------------------------
# Remove symlink nosso, nunca diretorio, arquivo ou symlink para outro lugar.
if [ "$MODO" = "unlink" ]; then
    tira_antigos
    n=0
    for l in "$DEST"/* "$DEST_AGENTS"/* "$ESPELHO"/*; do
        nosso "$l" || continue
        if [ "$DRY" -eq 1 ]; then echo "removeria $(curto "$l")"; else rm -f "$l"; fi
        n=$((n + 1))
    done
    omp_links="$(nossos_omp)"
    while IFS= read -r l; do
        [ -n "$l" ] || continue
        if [ "$DRY" -eq 1 ]; then echo "removeria $(curto "$l")"; else rm -f "$l"; poda "$l" "$OMP"; fi
        n=$((n + 1))
    done <<< "$omp_links"
    echo "$n symlink(s) $([ "$DRY" -eq 1 ] && echo "a remover" || echo "removido(s)") em ~/.claude, ~/.agents/skills e ~/.omp/agent."
    [ "$antigos_n" -gt 0 ] && echo "$antigos_n symlink(s) do dev-link antigo $([ "$DRY" -eq 1 ] && echo "a remover" || echo "removido(s)") do projeto."
    exit 0
fi

[ "$MODO" = "all" ] && conjunto="$disponiveis" || conjunto="$ROSTER"

tira_antigos

# liga <alvo> <fonte>: symlink nosso ou de outro lugar e refeito; diretorio ou
# arquivo real nao e nosso para sobrescrever. Devolve 1 quando pula.
refeitos=""
liga() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then return 1; fi
    nosso "$1" && [ "$(readlink "$1")" = "$2" ] && return 0
    if [ -L "$1" ] && ! nosso "$1"; then refeitos="$refeitos$(curto "$1") -> $(readlink "$1")"$'\n'; fi
    if [ "$DRY" -eq 1 ]; then
        echo "ligaria $(curto "$1")"
    else
        mkdir -p "$(dirname "$1")" || return 1
        rm -f "$1"
        ln -s "$2" "$1"
    fi
}

# --- ligar --------------------------------------------------------------------
ligados=0; ausentes=""; pulados=""; a_ligar=""
for s in $conjunto; do
    if [ ! -d "$PAYLOAD/$s" ]; then
        ausentes="$ausentes$s"$'\n'   # roster envelheceu: a skill saiu do payload
        continue
    fi
    if ! liga "$DEST/$s" "$PAYLOAD/$s"; then
        pulados="$pulados$s"$'\n'
        continue
    fi
    ligados=$((ligados + 1)); a_ligar="$a_ligar$s"$'\n'
done

# --- agentes -------------------------------------------------------------------
# Todos, no roster e no --all. O roster poupa a atencao que as descriptions das
# skills disputam; os agentes do payload so recebem trabalho da skill que os
# despacha.
ag_ligados=0; ag_total=0; ag_pulados=""
for f in "$AGENTS"/*.md; do
    [ -f "$f" ] || continue
    a="$(basename "$f")"; ag_total=$((ag_total + 1))
    if ! liga "$DEST_AGENTS/$a" "$f"; then
        ag_pulados="$ag_pulados$a"$'\n'
        continue
    fi
    ag_ligados=$((ag_ligados + 1))
done

# --- espelho do Codex ------------------------------------------------------------
# Gerado a partir do que esta ligado agora em ~/.claude/skills, nao so do conjunto
# desta execucao: o roster nao desliga o que um --all ligou antes. Como no reset,
# o symlink com nome de skill do payload e do anvil e e refeito; o nosso de skill
# que nao esta mais ligada sai. Diretorio ou arquivo fica: `ln -s` sobre um
# diretorio criaria o link dentro dele.
ligada() {
    printf '%s' "$a_ligar" | grep -qxF -e "$1" && return 0
    nosso "$DEST/$1"
}
esp_ligados=0; esp_removidos=0; esp_pulados=""
for s in $disponiveis; do
    ligada "$s" || continue
    if ! liga "$ESPELHO/$s" "$PAYLOAD/$s"; then
        esp_pulados="$esp_pulados$s"$'\n'
        continue
    fi
    esp_ligados=$((esp_ligados + 1))
done
for l in "$ESPELHO"/*; do
    s="$(basename "$l")"
    nosso "$l" || continue
    ligada "$s" && continue
    if [ "$DRY" -eq 1 ]; then echo "removeria $(curto "$l")"; else rm -f "$l"; fi
    esp_removidos=$((esp_removidos + 1))
done

# --- camada omp ---------------------------------------------------------------
# Um symlink por arquivo da camada. Arquivo real no caminho fica, e sai do
# relatorio como pulado. O symlink nosso para um arquivo que saiu da camada sai,
# com as pastas que ficarem vazias.
omp_ligados=0; omp_removidos=0; omp_pulados=""
if [ -d "$CAMADA" ]; then
    while IFS= read -r r; do
        if ! liga "$OMP/$r" "$CAMADA/$r" 2>/dev/null; then
            omp_pulados="$omp_pulados$r"$'\n'   # arquivo real, ou pasta do caminho e arquivo
            continue
        fi
        omp_ligados=$((omp_ligados + 1))
    done < <(cd "$CAMADA" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)
fi
omp_links="$(nossos_omp)"
while IFS= read -r l; do
    [ -n "$l" ] || continue
    [ -f "$CAMADA/${l#"$OMP"/}" ] && continue
    if [ "$DRY" -eq 1 ]; then echo "removeria $(curto "$l")"; else rm -f "$l"; poda "$l" "$OMP"; fi
    omp_removidos=$((omp_removidos + 1))
done <<< "$omp_links"

seria() { [ "$DRY" -eq 1 ] && echo "$1" || echo "$2"; }
echo
echo "$ligados de $(conta "$disponiveis") skills do payload $(seria "seriam ligadas" "ligadas") em ~/.claude/skills."
echo "$ag_ligados de $ag_total agentes do payload $(seria "seriam ligados" "ligados") em ~/.claude/agents."
echo "$esp_ligados symlink(s) $(seria "seriam ligados" "ligados") e $esp_removidos $(seria "seriam removidos" "removidos") em ~/.agents/skills."
echo "$omp_ligados arquivo(s) da camada omp $(seria "seriam ligados" "ligados") e $omp_removidos symlink(s) $(seria "seriam removidos" "removidos") em ~/.omp/agent."
[ "$antigos_n" -gt 0 ] && echo "$antigos_n symlink(s) do dev-link antigo $(seria "seriam removidos" "removidos") do projeto."
[ -n "$refeitos" ] && { echo "symlinks que apontavam para outro lugar, $(seria "seriam refeitos" "refeitos"):"; printf '%s' "$refeitos" | sed 's/^/  /'; }
[ -n "$ausentes" ] && { echo "NO ROSTER MAS FORA DO PAYLOAD — revise a lista:"; printf '%s' "$ausentes" | sed 's/^/  /'; }
[ -n "$pulados"  ] && { echo "pulados, porque ~/.claude/skills tem diretorio ou arquivo real com o nome:"; printf '%s' "$pulados" | sed 's/^/  /'; }
[ -n "$ag_pulados" ] && { echo "agentes pulados, porque ~/.claude/agents tem arquivo real com o nome:"; printf '%s' "$ag_pulados" | sed 's/^/  /'; }
[ -n "$esp_pulados" ] && { echo "espelho pulado, porque ~/.agents/skills tem diretorio ou arquivo com o nome:"; printf '%s' "$esp_pulados" | sed 's/^/  /'; }
[ -n "$omp_pulados" ] && { echo "camada omp pulada, porque ~/.omp/agent tem arquivo real no caminho:"; printf '%s' "$omp_pulados" | sed 's/^/  /'; }

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
echo "as skills, os agentes e a camada omp so aparecem na PROXIMA sessao do Claude Code e do omp, em todo projeto da maquina."
