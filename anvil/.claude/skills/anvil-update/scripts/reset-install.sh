#!/usr/bin/env bash
# reset-install.sh — reinstala o payload do anvil, apagando órfãos.
#
# É um RESET, não uma sobrescrita. `degit --force` sobrescreve arquivo a arquivo
# e nunca apaga: uma skill que deixou de existir upstream ficaria no disco para
# sempre, e os agentes continuariam encontrando e tentando usar. Atualizar sem
# reset acumula o entulho de todas as versões anteriores.
#
# O conjunto a apagar vem do `.claude/anvil.lock`, não de um prefixo de nome. Um
# lockfile diz a verdade; um prefixo adivinha — e adivinha errado nas skills que
# não seguem o padrão de nome, como as `tea-*`.
#
#   reset-install.sh --from <tmp> --to <projeto> [--dry-run]
#   reset-install.sh --gitignore-only --to <projeto> [--dry-run]
#
# O .gitignore do projeto ganha um bloco ANVIL:INSTALLED com uma linha por skill
# do lock. O update só regenera o bloco que já existe; quem o cria é o boot, pelo
# --gitignore-only, que lê o lock existente e reescreve só o bloco.
#
# RODE A CÓPIA RECÉM-BAIXADA, NUNCA A INSTALADA: este script apaga o próprio
# diretório onde vive, e rodar do $TMP garante que a lógica de reset é a nova.

set -euo pipefail

FROM=""; TO="."; DRY=0; GITIGNORE_ONLY=0
while [ $# -gt 0 ]; do
    case "$1" in
        --from) FROM="${2:-}"; shift 2 ;;
        --to)   TO="${2:-}";   shift 2 ;;
        --dry-run) DRY=1; shift ;;
        --gitignore-only) GITIGNORE_ONLY=1; shift ;;
        -h|--help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

TO_ABS="$(cd "$TO" && pwd)"
LOCK="$TO_ABS/.claude/anvil.lock"
SKILLS="$TO_ABS/.claude/skills"
GITIGNORE="$TO_ABS/.gitignore"

# --- bloco do .gitignore ------------------------------------------------------
# Uma linha por skill do lock, nunca por prefixo: as `tea-*` quebram o prefixo, e
# a skill que o usuario escreveu em .claude/skills/ precisa continuar versionada.
INICIO="# ANVIL:INSTALLED:START"
FIM="# ANVIL:INSTALLED:END"

# Le um lock na entrada padrao e imprime o bloco.
bloco_gitignore() {
    echo "$INICIO"
    echo "# Gerado do .claude/anvil.lock. Nao edite: o proximo update reescreve."
    sed -n 's|^skill: *\(.*\)$|.claude/skills/\1/|p'
    echo "$FIM"
}

tem_bloco() { [ -f "$GITIGNORE" ] && grep -qxF "$INICIO" "$GITIGNORE"; }

# Reescreve so o bloco, a partir do lock gravado. Sem bloco, acrescenta no fim.
escrever_gitignore() {
    local bloco tmp
    bloco="$(bloco_gitignore < "$LOCK")"
    tmp="$(mktemp)"
    if tem_bloco; then
        BLOCO="$bloco" awk -v ini="$INICIO" -v fim="$FIM" '
            $0 == ini { print ENVIRON["BLOCO"]; dentro = 1; next }
            dentro && $0 == fim { dentro = 0; next }
            !dentro { print }' "$GITIGNORE" > "$tmp"
    else
        {
            if [ -s "$GITIGNORE" ]; then
                cat "$GITIGNORE"
                [ -n "$(tail -c1 "$GITIGNORE")" ] && echo
                echo
            fi
            printf '%s\n' "$bloco"
        } > "$tmp"
    fi
    # cat em vez de mv, para o .gitignore manter as permissoes que tinha
    cat "$tmp" > "$GITIGNORE"; rm -f "$tmp"
}

# Marcador fora de um unico par START..END faria o awk engolir linhas do usuario.
# Checado antes de qualquer escrita, para o update nao parar no meio do reset.
if [ -f "$GITIGNORE" ] && ! awk -v ini="$INICIO" -v fim="$FIM" '
        $0 == ini { if (i || f) { ruim = 1; exit } i = 1 }
        $0 == fim { if (!i || f) { ruim = 1; exit } f = 1 }
        END { exit (ruim || i != f) }' "$GITIGNORE"; then
    echo "erro: $GITIGNORE tem marcadores ANVIL:INSTALLED fora de um único par START..END — conserte à mão" >&2; exit 2
fi

if [ "$GITIGNORE_ONLY" -eq 1 ]; then
    [ -f "$LOCK" ] || { echo "erro: $LOCK ausente — sem lock não há o que ignorar" >&2; exit 2; }
    if [ "$DRY" -eq 1 ]; then
        echo "(dry-run: nada foi alterado) bloco para $GITIGNORE:"
        bloco_gitignore < "$LOCK"
        exit 0
    fi
    escrever_gitignore
    echo "bloco ANVIL:INSTALLED reescrito em $GITIGNORE"
    exit 0
fi

[ -n "$FROM" ] || { echo "erro: --from é obrigatório" >&2; exit 2; }
[ -d "$FROM/.claude/skills" ] || { echo "erro: $FROM não parece um payload do anvil" >&2; exit 2; }

# Apagar a origem seria catastrófico, e o erro é fácil de cometer com `--from .`
FROM_ABS="$(cd "$FROM" && pwd)"
[ "$FROM_ABS" = "$TO_ABS" ] && { echo "erro: --from e --to apontam para o mesmo diretório" >&2; exit 2; }

# --- o que o payload novo traz ------------------------------------------------
novo=""
for d in "$FROM_ABS"/.claude/skills/*/; do
    [ -d "$d" ] && novo="$novo$(basename "$d")"$'\n'
done

# --- o que esta instalacao possui --------------------------------------------
# Sem lock, nada e considerado nosso: e a leitura segura numa instalacao que
# veio de antes do lockfile, ou de um degit feito a mao.
possui=""
if [ -f "$LOCK" ]; then
    possui="$(sed -n 's/^skill: *//p' "$LOCK")"
fi

# --- classificacao ------------------------------------------------------------
substituidos=""; orfaos=""; alheios=""
for s in $novo;   do [ -d "$SKILLS/$s" ] && substituidos="$substituidos$s"$'\n'; done
for s in $possui; do
    printf '%s\n' "$novo" | grep -qx "$s" && continue
    [ -d "$SKILLS/$s" ] && orfaos="$orfaos$s"$'\n'
done
if [ -d "$SKILLS" ]; then
    for d in "$SKILLS"/*/; do
        [ -d "$d" ] || continue
        s="$(basename "$d")"
        printf '%s\n' "$novo"   | grep -qx "$s" && continue
        printf '%s\n' "$possui" | grep -qx "$s" && continue
        alheios="$alheios$s"$'\n'
    done
fi

conta() { printf '%s' "$1" | grep -c . || true; }

# --- relatorio ----------------------------------------------------------------
echo "reset-install: $FROM_ABS -> $TO_ABS"
[ "$DRY" -eq 1 ] && echo "(dry-run: nada foi alterado)"
echo
echo "substituídos ($(conta "$substituidos")):"; printf '%s' "$substituidos" | sed 's/^/  /'
echo "órfãos, serão REMOVIDOS ($(conta "$orfaos")):"; printf '%s' "$orfaos" | sed 's/^/  /'
echo "não são do anvil, ficam intocados ($(conta "$alheios")):"; printf '%s' "$alheios" | sed 's/^/  /'
echo "preservados sempre:"
for p in ".claude/rules" ".claude/settings.json" ".claude/settings.local.json" "docs" "CLAUDE.md"; do
    [ -e "$TO_ABS/$p" ] && echo "  $p"
done

# --- lockfile -----------------------------------------------------------------
# Reescrito a cada reset. E dele que o proximo update calcula os orfaos, entao
# uma instalacao sem lock nao consegue limpar o que ela mesma deixou.
conteudo_lock() {
    echo "# anvil.lock — o que esta instalacao possui."
    echo "# Gerado por reset-install.sh. Nao edite: o proximo update reescreve."
    echo "installed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    for s in $novo; do echo "skill: $s"; done
}

if tem_bloco; then
    echo "bloco ANVIL:INSTALLED do .gitignore, será reescrito:"
    conteudo_lock | bloco_gitignore | sed 's/^/  /'
else
    echo ".gitignore sem bloco ANVIL:INSTALLED, fica intocado"
fi

[ "$DRY" -eq 1 ] && exit 0

# --- execucao -----------------------------------------------------------------
mkdir -p "$SKILLS"
for s in $orfaos;       do rm -rf "${SKILLS:?}/$s"; done
for s in $substituidos; do rm -rf "${SKILLS:?}/$s"; done
for d in "$FROM_ABS"/.claude/skills/*/; do
    [ -d "$d" ] && cp -R "${d%/}" "$SKILLS/"
done

conteudo_lock > "$LOCK"

# So regenera o bloco que o boot criou: projeto que optou por versionar tudo nao
# ganha bloco num update.
tem_bloco && escrever_gitignore

echo
echo "pronto. $(conta "$novo") skills instaladas, $(conta "$orfaos") órfão(s) removido(s)."
