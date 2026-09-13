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
# não seguem o padrão de nome, como as `tea-*`. Vale para skills e agentes: o lock
# tem uma linha `skill:` por skill e uma `agent:` por agente.
#
#   reset-install.sh --from <tmp> --to <projeto> [--dry-run]
#   reset-install.sh --gitignore-only --to <projeto> [--dry-run]
#
# O .gitignore do projeto ganha um bloco ANVIL:INSTALLED com uma linha por skill
# e por agente do lock. O update só regenera o bloco que já existe; quem o cria
# é o boot, pelo --gitignore-only, que lê o lock existente e reescreve só o bloco.
#
# NO RESET, RODE A CÓPIA RECÉM-BAIXADA, NUNCA A INSTALADA: o reset apaga o próprio
# diretório onde o script vive, e rodar do $TMP garante que a lógica é a nova. O
# --gitignore-only não apaga nada e roda da cópia instalada, como faz o boot.

set -euo pipefail

FROM=""; TO="."; DRY=0; GITIGNORE_ONLY=0
while [ $# -gt 0 ]; do
    case "$1" in
        --from) FROM="${2:-}"; shift 2 ;;
        --to)   TO="${2:-}";   shift 2 ;;
        --dry-run) DRY=1; shift ;;
        --gitignore-only) GITIGNORE_ONLY=1; shift ;;
        -h|--help) sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

if [ "$GITIGNORE_ONLY" -eq 1 ] && [ -n "$FROM" ]; then
    echo "erro: --gitignore-only não usa --from — o bloco sai do lock de --to" >&2; exit 2
fi

TO_ABS="$(cd "$TO" && pwd)"
LOCK="$TO_ABS/.claude/anvil.lock"
SKILLS="$TO_ABS/.claude/skills"
AGENTS="$TO_ABS/.claude/agents"
GITIGNORE="$TO_ABS/.gitignore"

# --- bloco do .gitignore ------------------------------------------------------
# Uma linha por skill e por agente do lock, nunca por prefixo: as `tea-*` quebram o
# prefixo, e a skill ou o agente que o usuario escreveu precisa continuar versionado.
INICIO="# ANVIL:INSTALLED:START"
FIM="# ANVIL:INSTALLED:END"

# Le um lock na entrada padrao e imprime o bloco. O \r de um lock CRLF sai antes:
# ".claude/skills/tea-x\r/" nao casa com diretorio nenhum.
bloco_gitignore() {
    echo "$INICIO"
    echo "# Gerado do .claude/anvil.lock. Nao edite: o proximo update reescreve."
    tr -d '\r' | sed -n -e 's|^skill: *\(.*\)$|.claude/skills/\1/|p' -e 's|^agent: *\(.*\)$|.claude/agents/\1.md|p'
    echo "$FIM"
}

# Os tres awk comparam o marcador com a linha sem o espaco, tab e \r do fim (l): um
# checkout com core.autocrlf=true poe \r em toda linha, e o bloco tem de continuar
# sendo achado.
tem_bloco() {
    [ -f "$GITIGNORE" ] && awk -v ini="$INICIO" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { achou = 1; exit }
        END { exit !achou }' "$GITIGNORE"
}

# Reescreve so o bloco, a partir do lock gravado. Sem bloco, acrescenta no fim. O
# bloco sai com o fim de linha da primeira linha do arquivo, CRLF ou LF.
escrever_gitignore() {
    local bloco tmp cr=""
    bloco="$(bloco_gitignore < "$LOCK")"
    [ -f "$GITIGNORE" ] && head -n1 "$GITIGNORE" | grep -q $'\r$' && cr=$'\r'
    tmp="$(mktemp)"
    if tem_bloco; then
        BLOCO="$bloco" CR="$cr" awk -v ini="$INICIO" -v fim="$FIM" '
            { l = $0; sub(/[ \t\r]+$/, "", l) }
            l == ini { n = split(ENVIRON["BLOCO"], b, "\n")
                       for (i = 1; i <= n; i++) print b[i] ENVIRON["CR"]
                       dentro = 1; next }
            dentro && l == fim { dentro = 0; next }
            !dentro { print }' "$GITIGNORE" > "$tmp"
    else
        {
            if [ -s "$GITIGNORE" ]; then
                cat "$GITIGNORE"
                [ -n "$(tail -c1 "$GITIGNORE")" ] && printf '%s\n' "$cr"
                printf '%s\n' "$cr"
            fi
            printf '%s\n' "$bloco" | while IFS= read -r linha; do printf '%s%s\n' "$linha" "$cr"; done
        } > "$tmp"
    fi
    # cat em vez de mv, para o .gitignore manter as permissoes que tinha
    cat "$tmp" > "$GITIGNORE"; rm -f "$tmp"
}

# Marcador fora de um unico par START..END faria o awk engolir linhas do usuario.
# Checado antes de qualquer escrita, para o update nao parar no meio do reset.
if [ -f "$GITIGNORE" ] && ! awk -v ini="$INICIO" -v fim="$FIM" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { if (i || f) { ruim = 1; exit } i = 1 }
        l == fim { if (!i || f) { ruim = 1; exit } f = 1 }
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
# Agente e arquivo, nao diretorio: um laco por arquivo, com a mesma classificacao.
# Payload sem .claude/agents/ e valido, e so nao traz agente nenhum.
novo_ag=""
for f in "$FROM_ABS"/.claude/agents/*.md; do
    [ -f "$f" ] && novo_ag="$novo_ag$(basename "$f" .md)"$'\n'
done

# --- o que esta instalacao possui --------------------------------------------
# Sem lock, nada e considerado nosso: e a leitura segura numa instalacao que
# veio de antes do lockfile, ou de um degit feito a mao.
possui=""; possui_ag=""
if [ -f "$LOCK" ]; then
    possui="$(tr -d '\r' < "$LOCK" | sed -n 's/^skill: *//p')"
    possui_ag="$(tr -d '\r' < "$LOCK" | sed -n 's/^agent: *//p')"
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

substituidos_ag=""; orfaos_ag=""; alheios_ag=""
for a in $novo_ag;   do [ -f "$AGENTS/$a.md" ] && substituidos_ag="$substituidos_ag$a"$'\n'; done
for a in $possui_ag; do
    printf '%s\n' "$novo_ag" | grep -qxF "$a" && continue
    [ -f "$AGENTS/$a.md" ] && orfaos_ag="$orfaos_ag$a"$'\n'
done
for f in "$AGENTS"/*.md; do
    [ -f "$f" ] || continue
    a="$(basename "$f" .md)"
    printf '%s\n' "$novo_ag"   | grep -qxF "$a" && continue
    printf '%s\n' "$possui_ag" | grep -qxF "$a" && continue
    alheios_ag="$alheios_ag$a"$'\n'
done

conta() { printf '%s' "$1" | grep -c . || true; }
# Skill sai pelo nome, agente pelo caminho: as duas listas dividem o mesmo grupo.
lista() {
    printf '%s' "$1" | sed 's/^/  /'
    printf '%s' "$2" | sed 's|^\(.*\)$|  .claude/agents/\1.md|'
}

# --- relatorio ----------------------------------------------------------------
echo "reset-install: $FROM_ABS -> $TO_ABS"
[ "$DRY" -eq 1 ] && echo "(dry-run: nada foi alterado)"
echo
echo "substituídos ($(conta "$substituidos$substituidos_ag")):"; lista "$substituidos" "$substituidos_ag"
echo "órfãos, serão REMOVIDOS ($(conta "$orfaos$orfaos_ag")):"; lista "$orfaos" "$orfaos_ag"
echo "não são do anvil, ficam intocados ($(conta "$alheios$alheios_ag")):"; lista "$alheios" "$alheios_ag"
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
    for a in $novo_ag; do echo "agent: $a"; done
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

for a in $orfaos_ag; do rm -f "${AGENTS:?}/$a.md"; done
if [ -n "$novo_ag" ]; then
    mkdir -p "$AGENTS"
    for a in $novo_ag; do
        # rm antes do cp: um symlink no lugar do agente, mesmo pendurado, seria
        # escrito por dentro, e o alvo nao e desta instalacao
        rm -f "${AGENTS:?}/$a.md"
        cp "$FROM_ABS/.claude/agents/$a.md" "$AGENTS/"
    done
fi

conteudo_lock > "$LOCK"

# So regenera o bloco que o boot criou: projeto que optou por versionar tudo nao
# ganha bloco num update.
tem_bloco && escrever_gitignore

echo
echo "pronto. $(conta "$novo") skills e $(conta "$novo_ag") agentes instalados, $(conta "$orfaos$orfaos_ag") órfão(s) removido(s)."
