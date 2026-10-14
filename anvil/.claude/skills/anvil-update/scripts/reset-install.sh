#!/usr/bin/env bash
# reset-install.sh — reinstala o payload do anvil na instalação de usuário,
# apagando órfãos.
#
# É um RESET, não uma sobrescrita. `degit --force` sobrescreve arquivo a arquivo
# e nunca apaga: uma skill que deixou de existir upstream ficaria no disco para
# sempre, e os agentes continuariam encontrando e tentando usar. Atualizar sem
# reset acumula o entulho de todas as versões anteriores.
#
# O destino é o diretório do usuário, $HOME, e não um projeto: o toolkit é
# instalado uma vez por usuário e vale para todos os projetos da máquina.
#
#   ~/.claude/skills/      as skills do payload
#   ~/.claude/agents/      os agentes do payload
#   ~/.claude/anvil.lock   o lock de usuário, ao lado das skills
#   ~/.agents/skills/      o espelho: um symlink para ~/.claude/skills por skill.
#                          O Codex lê as skills dali, e o omp também
#   ~/.omp/agent/          a camada omp: skills, rules, agents e hooks/pre
#   ~/.claude/CLAUDE.md    o bloco ANVIL:DIRECTIVES, que o Claude Code carrega
#                          em toda sessão
#
# O conjunto a apagar vem do lock de usuário, não de um prefixo de nome. Um
# lockfile diz a verdade; um prefixo adivinha — e adivinha errado nas skills que
# não seguem o padrão de nome, como as `tea-*`. O lock tem uma linha `skill:` por
# skill e uma `agent:` por agente; o que está fora dele é do usuário e fica.
# O espelho sai do mesmo lock: um symlink por linha `skill:`, e o que o lock
# deixou de listar sai.
# A camada omp vem de .claude/skills/anvil-update/.omp-layer/ do payload e entra
# quando há sinal de omp: o binário no PATH, ~/.omp/, ou uma linha `omp:` no lock.
# A última torna a camada pegajosa: máquina sem omp a mantém. O lock ganha uma
# linha `omp:` por arquivo, com o caminho relativo a ~/.omp/agent/, e a
# classificação é a mesma das skills.
# As diretivas saem do claude_boot.md do payload, em dois lugares: o bloco entre
# os marcadores ANVIL:DIRECTIVES do ~/.claude/CLAUDE.md, sem tocar o que está fora
# dele, e a rule alwaysApply rules/anvil-directives.md da camada omp, porque o omp
# não lê o CLAUDE.md de usuário.
#
# Nada é escrito em projeto, e nada é commitado. Rodado de dentro de um projeto
# anvil — o que tem .claude/rules/anvil.md —, o relatório confere os perfis de
# docs/agents/ contra o template novo e aponta o /anvil-boot quando divergem.
#
#   reset-install.sh --from <tmp> [--dry-run]
#   reset-install.sh --unignore --to <projeto> [--dry-run]
#
# O --unignore tira do .gitignore do projeto o bloco ANVIL:INSTALLED que uma
# versão antiga escreveu, e só ele. É o que o boot chama.
#
# NO RESET, RODE A CÓPIA RECÉM-BAIXADA, NUNCA A INSTALADA: o reset apaga o próprio
# diretório onde o script vive, e rodar do $TMP garante que a lógica é a nova. O
# --unignore não apaga skill nenhuma e roda da cópia instalada, como faz o boot.

set -euo pipefail

FROM=""; TO=""; DRY=0; UNIGNORE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --from) FROM="${2:-}"; shift 2 ;;
        --to)   TO="${2:-}";   shift 2 ;;
        --dry-run) DRY=1; shift ;;
        --unignore) UNIGNORE=1; shift ;;
        -h|--help) sed -n '2,50p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done

# Os awk comparam o marcador com a linha sem o espaco, tab e \r do fim (l): um
# checkout com core.autocrlf=true poe \r em toda linha, e o bloco tem de continuar
# sendo achado.
tem_bloco() {  # <arquivo> <marcador de inicio>
    [ -f "$1" ] && awk -v ini="$2" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { achou = 1; exit }
        END { exit !achou }' "$1"
}
# Marcador fora de um unico par START..END faria o awk engolir linhas do usuario.
# Checado antes de qualquer escrita, para o reset nao parar no meio.
marcadores_ok() {  # <arquivo> <inicio> <fim>
    [ ! -f "$1" ] || awk -v ini="$2" -v fim="$3" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { if (i || f) { ruim = 1; exit } i = 1 }
        l == fim { if (!i || f) { ruim = 1; exit } f = 1 }
        END { exit (ruim || i != f) }' "$1"
}

# --- --unignore: o .gitignore de um projeto antigo ---------------------------
if [ "$UNIGNORE" -eq 1 ]; then
    [ -z "$FROM" ] || { echo "erro: --unignore não usa --from — ele só mexe no .gitignore de --to" >&2; exit 2; }
    [ -n "$TO" ] || { echo "erro: --unignore pede --to <projeto>" >&2; exit 2; }
    GITIGNORE="$(cd "$TO" && pwd)/.gitignore"
    INICIO="# ANVIL:INSTALLED:START"
    FIM="# ANVIL:INSTALLED:END"
    if ! marcadores_ok "$GITIGNORE" "$INICIO" "$FIM"; then
        echo "erro: $GITIGNORE tem marcadores ANVIL:INSTALLED fora de um único par START..END — conserte à mão" >&2; exit 2
    fi
    if ! tem_bloco "$GITIGNORE" "$INICIO"; then
        echo "sem bloco ANVIL:INSTALLED em $GITIGNORE — nada a tirar"; exit 0
    fi
    if [ "$DRY" -eq 1 ]; then
        echo "(dry-run: nada foi alterado) sairiam de $GITIGNORE:"
        awk -v ini="$INICIO" -v fim="$FIM" '
            { l = $0; sub(/[ \t\r]+$/, "", l) }
            l == ini { dentro = 1 }
            dentro   { print "  " $0; if (l == fim) dentro = 0 }' "$GITIGNORE"
        exit 0
    fi
    # Tira o bloco inteiro, e com ele a linha em branco que o precedia: o bloco foi
    # acrescentado no fim depois de uma linha vazia que, sem ele, nao separa mais
    # nada. A linha em branco fica pendente ate se saber o que vem depois dela.
    tmp="$(mktemp)"
    awk -v ini="$INICIO" -v fim="$FIM" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { pend = 0; dentro = 1; next }
        dentro   { if (l == fim) dentro = 0; next }
        pend     { print vazia; pend = 0 }
        l == ""  { vazia = $0; pend = 1; next }
                 { print }
        END      { if (pend) print vazia }' "$GITIGNORE" > "$tmp"
    # cat em vez de mv, para o .gitignore manter as permissoes que tinha
    cat "$tmp" > "$GITIGNORE"; rm -f "$tmp"
    echo "bloco ANVIL:INSTALLED removido de $GITIGNORE"
    exit 0
fi

# --- o reset: origem e destino -----------------------------------------------
[ -z "$TO" ] || { echo "erro: o reset instala no usuário, em \$HOME; --to só vale com --unignore" >&2; exit 2; }
[ -n "$FROM" ] || { echo "erro: --from é obrigatório" >&2; exit 2; }
[ -d "$FROM/.claude/skills" ] || { echo "erro: $FROM não parece um payload do anvil" >&2; exit 2; }
[ -n "${HOME:-}" ] && [ -d "$HOME" ] || { echo "erro: \$HOME não é um diretório — é o destino da instalação" >&2; exit 2; }

U="$(cd "$HOME" && pwd)"
# Apagar a origem seria catastrófico, e o erro é fácil de cometer com `--from ~`
FROM_ABS="$(cd "$FROM" && pwd)"
[ "$FROM_ABS" = "$U" ] && { echo "erro: --from aponta para \$HOME, que é o destino" >&2; exit 2; }

LOCK="$U/.claude/anvil.lock"
SKILLS="$U/.claude/skills"
AGENTS="$U/.claude/agents"
ESPELHO="$U/.agents/skills"
OMP="$U/.omp/agent"
CLAUDE_MD="$U/.claude/CLAUDE.md"
DIR_INI="<!-- ANVIL:DIRECTIVES:START -->"
DIR_FIM="<!-- ANVIL:DIRECTIVES:END -->"

if ! marcadores_ok "$CLAUDE_MD" "$DIR_INI" "$DIR_FIM"; then
    echo "erro: ~/.claude/CLAUDE.md tem marcadores ANVIL:DIRECTIVES fora de um único par START..END — conserte à mão" >&2; exit 2
fi

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
# A camada omp e uma arvore de arquivos, e o nome de cada um e o caminho relativo
# a ~/.omp/agent/. Payload sem .omp-layer/ e valido, e so nao traz camada. A pasta
# e oculta porque o Codex acha SKILL.md em subpasta de skill abaixo de
# ~/.agents/skills, seguindo o symlink da anvil-update, e so pula pasta oculta: sem
# o ponto, as skills da camada entrariam na lista do Codex.
# A rule de diretivas nao esta na pasta: ela e gerada do claude_boot.md, a mesma
# fonte do bloco do CLAUDE.md, e entra na camada como qualquer arquivo dela.
CAMADA_OMP="$FROM_ABS/.claude/skills/anvil-update/.omp-layer"
DIRETIVAS="$FROM_ABS/.claude/skills/anvil-boot/claude_boot.md"
REGRA_DIRETIVAS="rules/anvil-directives.md"
novo_omp=""
if [ -d "$CAMADA_OMP" ]; then
    novo_omp="$(cd "$CAMADA_OMP" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)"
fi
if [ -f "$DIRETIVAS" ]; then
    novo_omp="$(printf '%s\n%s\n' "$novo_omp" "$REGRA_DIRETIVAS" | sed '/^$/d' | LC_ALL=C sort -u)"
fi

# --- o que esta instalacao possui --------------------------------------------
# Sem lock, nada e considerado nosso: e a primeira instalacao de usuario, e o que
# ja esta em ~/.claude e do usuario.
possui=""; possui_ag=""; possui_omp=""
if [ -f "$LOCK" ]; then
    possui="$(tr -d '\r' < "$LOCK" | sed -n 's/^skill: *//p')"
    possui_ag="$(tr -d '\r' < "$LOCK" | sed -n 's/^agent: *//p')"
    # Caminho absoluto ou com `..` sairia de ~/.omp/agent no rm do orfao: nao e da camada.
    possui_omp="$(tr -d '\r' < "$LOCK" | sed -n 's/^omp: *//p' | awk '!/^\// && !/(^|\/)\.\.(\/|$)/')"
fi

# --- o que esta no disco -----------------------------------------------------
# A lista e o que o glob acha, um nome por linha, e da os alheios. Substituido e
# orfao saem do teste por nome, que o sistema de arquivos responde: num volume que
# nao diferencia caixa, `Foo` no disco existe como `foo`, e a lista nao o acharia.
existe_skill() { [ -d "$SKILLS/$1" ]; }
# Symlink conta como agente no disco, mesmo pendurado: o [ -f ] segue o link, e um
# orfao pendurado ficaria no disco sem aparecer em grupo nenhum.
existe_agente() { [ -f "$AGENTS/$1.md" ] || [ -L "$AGENTS/$1.md" ]; }

disco=""
for d in "$SKILLS"/*/; do
    [ -d "$d" ] && disco="$disco$(basename "$d")"$'\n'
done
disco_ag=""
for f in "$AGENTS"/*.md; do
    existe_agente "$(basename "$f" .md)" && disco_ag="$disco_ag$(basename "$f" .md)"$'\n'
done

# O espelho tem um symlink por skill do payload, na forma ../../.claude/skills/<nome>.
# Nele o symlink e do anvil, e o diretorio ou arquivo e do usuario. A posse nao
# depende do alvo: um symlink pendurado com nome de skill do payload e refeito.
nosso_espelho() { [ -L "$ESPELHO/$1" ]; }
# Qualquer entrada com o nome, symlink pendurado inclusive
ocupado_espelho() { [ -e "$ESPELHO/$1" ] || [ -L "$ESPELHO/$1" ]; }
# A raiz tambem e do usuario quando ~/.agents ou ~/.agents/skills e symlink ou
# arquivo, como ~/.agents/skills -> ../.claude/skills: o `ln -s` cairia dentro da
# skill recem-copiada, e o `mkdir -p` abortaria o reset antes da escrita do lock.
# Entao o espelho inteiro fica intocado. A camada omp usa a mesma guarda.
fora_do_lugar() { [ -L "$1" ] || { [ -e "$1" ] && [ ! -d "$1" ]; }; }
raiz_espelho=1
for c in "$U/.agents" "$ESPELHO"; do
    if fora_do_lugar "$c"; then raiz_espelho=0; fi
done
disco_esp=""
if [ "$raiz_espelho" -eq 1 ]; then
    for e in "$ESPELHO"/*; do
        ocupado_espelho "$(basename "$e")" && disco_esp="$disco_esp$(basename "$e")"$'\n'
    done
fi

# A camada omp entra com qualquer sinal. A linha `omp:` no lock e o que a torna
# pegajosa: a ausencia do binario nunca remove nada.
sinais_omp=""
if command -v omp >/dev/null 2>&1; then sinais_omp="omp no PATH"; fi
if [ -d "$U/.omp" ]; then sinais_omp="${sinais_omp:+$sinais_omp, }~/.omp/"; fi
if [ -n "$possui_omp" ]; then sinais_omp="${sinais_omp:+$sinais_omp, }linha omp: no lock"; fi

# Symlink conta como arquivo da camada, mesmo pendurado, como no agente.
existe_omp() { [ -f "$OMP/$1" ] || [ -L "$OMP/$1" ]; }
# A camada inteira e do usuario quando ~/.omp/agent, ou uma pasta no caminho de um
# arquivo dela, e symlink ou arquivo: escrever ali escreveria por dentro do alvo,
# ou abortaria o reset antes do lock. Diretorio no lugar de um arquivo da camada
# tambem: o cp o encheria por dentro. Grava em raiz_omp o primeiro caminho que
# impede, relativo a ~/.omp/agent.
raiz_omp=""
confere_raiz_omp() {
    local f p resto
    if fora_do_lugar "$OMP"; then raiz_omp="."; return; fi
    for f in $novo_omp $possui_omp; do
        p=""; resto="$f"
        while [ "${resto#*/}" != "$resto" ]; do
            p="$p${p:+/}${resto%%/*}"; resto="${resto#*/}"
            if fora_do_lugar "$OMP/$p"; then raiz_omp="$p"; return; fi
        done
    done
    for f in $novo_omp; do
        if [ -d "$OMP/$f" ] && [ ! -L "$OMP/$f" ]; then raiz_omp="$f"; return; fi
    done
}
# O disco da camada e so o das pastas dela. O resto de ~/.omp/agent e do omp —
# sessoes, bancos, cache, config.yml —, e listar milhares de arquivos ali afogaria
# o dry-run. O orfao sai do lock, nao desta lista.
PASTAS_OMP="skills rules agents hooks/pre"
instala_omp=0
disco_omp=""
if [ -n "$sinais_omp" ] && [ -n "$novo_omp$possui_omp" ]; then
    confere_raiz_omp
    if [ -z "$raiz_omp" ]; then
        instala_omp=1
        for p in $PASTAS_OMP; do
            [ -d "$OMP/$p" ] || continue
            disco_omp="$disco_omp$(cd "$OMP" && find "$p" \( -type f -o -type l \))"$'\n'
        done
        disco_omp="$(printf '%s' "$disco_omp" | sed '/^$/d' | LC_ALL=C sort)"
    fi
fi

# --- classificacao ------------------------------------------------------------
tem() { printf '%s\n' "$1" | grep -qxF -e "$2"; }

# classifica <sufixo> <novo> <possui> <disco> <existe>
# Grava substituidos<sufixo>, orfaos<sufixo>, alheios<sufixo> e colisoes<sufixo>.
# <existe> e a funcao que testa um nome no disco.
# Substituido que o lock nao lista e do usuario com o nome de um do payload: sera
# sobrescrito, e o relatorio o destaca como colisao para o aviso nomea-lo. Sem
# lock, todo substituido e colisao: nao ha instalacao de usuario anterior que o
# explique.
classifica() {
    local novo="$2" possui="$3" disco="$4" existe="$5" x sub="" orf="" alh="" col=""
    for x in $novo;   do "$existe" "$x" && sub="$sub$x"$'\n'; done
    for x in $possui; do tem "$novo" "$x" || { "$existe" "$x" && orf="$orf$x"$'\n'; }; done
    # Linha a linha, sem dividir nem expandir: nome do usuario pode ter espaco ou *.
    while IFS= read -r x; do
        [ -n "$x" ] || continue
        tem "$novo" "$x" || tem "$possui" "$x" || alh="$alh$x"$'\n'
    done <<< "$disco"
    for x in $sub; do tem "$possui" "$x" || col="$col$x"$'\n'; done
    printf -v "substituidos$1" '%s' "$sub"
    printf -v "orfaos$1" '%s' "$orf"
    printf -v "alheios$1" '%s' "$alh"
    printf -v "colisoes$1" '%s' "$col"
}

classifica ""    "$novo"    "$possui"    "$disco"    existe_skill
classifica "_ag" "$novo_ag" "$possui_ag" "$disco_ag" existe_agente

substituidos_esp=""; orfaos_esp=""; alheios_esp=""; colisoes_esp=""; criados_esp=""; refeitos_esp=""
if [ "$raiz_espelho" -eq 1 ]; then
    classifica "_esp" "$novo" "$possui" "$disco_esp" nosso_espelho

    # Do symlink com nome de skill do payload, so o que aponta para outro lugar e
    # refeito; o que ja esta na forma fica como esta.
    for x in $substituidos_esp; do
        if [ "$(readlink "$ESPELHO/$x")" != "../../.claude/skills/$x" ]; then
            refeitos_esp="$refeitos_esp$x"$'\n'
        fi
    done
    # A colisao do espelho nao e a do lock: e nome de skill do payload ocupado por
    # diretorio ou arquivo. Ela fica como esta e fica sem symlink, porque o `ln -s`
    # sobre um diretorio criaria o link dentro dele. O nome do payload sem entrada
    # nenhuma ganha o symlink.
    colisoes_esp=""
    for x in $novo; do
        if nosso_espelho "$x"; then continue; fi
        if ocupado_espelho "$x"; then colisoes_esp="$colisoes_esp$x"$'\n'
        else criados_esp="$criados_esp$x"$'\n'; fi
    done
    # Diretorio ou arquivo com nome que o lock anterior listava nao e orfao, porque
    # nao e symlink, nem alheio pela regra do lock: entra nos alheios aqui.
    while IFS= read -r x; do
        [ -n "$x" ] || continue
        if tem "$possui" "$x" && ! tem "$novo" "$x" && ! nosso_espelho "$x"; then
            alheios_esp="$alheios_esp$x"$'\n'
        fi
    done <<< "$disco_esp"
fi

substituidos_omp=""; orfaos_omp=""; alheios_omp=""; colisoes_omp=""; criados_omp=""
if [ "$instala_omp" -eq 1 ]; then
    classifica "_omp" "$novo_omp" "$possui_omp" "$disco_omp" existe_omp
    for x in $novo_omp; do
        if ! existe_omp "$x"; then criados_omp="$criados_omp$x"$'\n'; fi
    done
fi

# O bloco de diretivas do ~/.claude/CLAUDE.md: o que esta entre os marcadores e o
# claude_boot.md do payload, byte a byte.
bloco_atual() {
    awk -v ini="$DIR_INI" -v fim="$DIR_FIM" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == fim { dentro = 0 }
        dentro   { print }
        l == ini { dentro = 1 }' "$CLAUDE_MD"
}
estado_diretivas=""
if [ ! -f "$DIRETIVAS" ]; then estado_diretivas="sem-fonte"
elif [ ! -f "$CLAUDE_MD" ]; then estado_diretivas="arquivo-novo"
elif ! tem_bloco "$CLAUDE_MD" "$DIR_INI"; then estado_diretivas="bloco-novo"
elif bloco_atual | cmp -s - "$DIRETIVAS"; then estado_diretivas="em-dia"
else estado_diretivas="substituido"; fi

# --- o projeto de onde roda ---------------------------------------------------
# Projeto anvil e o que tem a rule de configuracao que o boot escreve. A raiz vem
# do git, ou do diretorio corrente fora de repositorio.
raiz="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PROJETO=""
[ -f "$raiz/.claude/rules/anvil.md" ] && PROJETO="$raiz"

# Perfis sao do projeto e o reset nao os escreve. A checagem roda da copia NOVA,
# em $FROM_ABS, para que ate um /anvil-update invocado pela skill velha avise o
# que o boot precisa promover.
reporta_perfis() {
    local fonte="$FROM_ABS/.claude/skills/anvil-docs/templates/verification-anvil.md"
    local destino="$PROJETO/docs/agents/verification.md"
    [ -f "$fonte" ] || return 0
    if [ ! -f "$destino" ]; then
        echo "BOOT PENDENTE: sem docs/agents/verification.md"
    elif ! cmp -s "$destino" "$fonte"; then
        echo "BOOT PENDENTE: docs/agents/verification.md diverge do template novo"
    fi
}

# --- relatorio ----------------------------------------------------------------
conta() { printf '%s' "$1" | grep -c . || true; }
# Skill sai pelo nome, agente pelo caminho: as duas listas dividem o mesmo grupo.
lista() {
    printf '%s' "$1" | sed 's/^/  /'
    printf '%s' "$2" | sed 's|^\(.*\)$|  ~/.claude/agents/\1.md|'
}
espelho() { printf '%s' "$1" | sed 's|^\(.*\)$|    ~/.agents/skills/\1|'; }
na_camada() { printf '%s' "$1" | sed 's|^\(.*\)$|    ~/.omp/agent/\1|'; }

echo "reset-install: $FROM_ABS -> $U (instalação de usuário)"
[ "$DRY" -eq 1 ] && echo "(dry-run: nada foi alterado)"
echo
echo "skills em ~/.claude/skills e agentes em ~/.claude/agents:"
echo "substituídos ($(conta "$substituidos$substituidos_ag")):"; lista "$substituidos" "$substituidos_ag"
if [ -n "$colisoes$colisoes_ag" ]; then
    echo "ATENÇÃO, substituídos fora do lock, possível colisão com arquivo do usuário ($(conta "$colisoes$colisoes_ag")):"
    lista "$colisoes" "$colisoes_ag"
fi
echo "órfãos, serão REMOVIDOS ($(conta "$orfaos$orfaos_ag")):"; lista "$orfaos" "$orfaos_ag"
echo "não são do anvil, ficam intocados ($(conta "$alheios$alheios_ag")):"; lista "$alheios" "$alheios_ag"
echo "preservados sempre:"
for p in .claude/settings.json .claude/settings.local.json .claude/rules .omp/agent/config.yml; do
    if [ -e "$U/$p" ]; then echo "  ~/$p"; fi
done
echo "  o resto de ~/.claude, ~/.agents e ~/.omp, fora do que está listado aqui"
if [ "$raiz_espelho" -eq 1 ]; then
    echo "espelho em ~/.agents/skills, symlinks para ~/.claude/skills:"
    echo "  symlinks novos ($(conta "$criados_esp")):"; espelho "$criados_esp"
    echo "  symlinks refeitos, apontavam para outro lugar ($(conta "$refeitos_esp")):"; espelho "$refeitos_esp"
    echo "  órfãos, serão REMOVIDOS ($(conta "$orfaos_esp")):"; espelho "$orfaos_esp"
    if [ -n "$colisoes_esp" ]; then
        echo "  colisões, diretório ou arquivo com nome de skill do anvil, fica e NÃO ganha symlink ($(conta "$colisoes_esp")):"
        espelho "$colisoes_esp"
    fi
    echo "  não são do anvil, ficam intocados ($(conta "$alheios_esp")):"; espelho "$alheios_esp"
else
    echo "espelho: ~/.agents ou ~/.agents/skills é symlink ou arquivo, fica intocado"
fi
if [ -z "$sinais_omp" ]; then
    echo "camada omp: não instalada, nenhum sinal de omp (omp no PATH, ~/.omp/, linha omp: no lock)"
elif [ -n "$raiz_omp" ]; then
    if [ -L "$OMP/$raiz_omp" ]; then tipo_omp="symlink"
    elif [ -d "$OMP/$raiz_omp" ]; then tipo_omp="diretório"
    else tipo_omp="arquivo"; fi
    echo "camada omp: ~/.omp/agent/${raiz_omp#.} é $tipo_omp, ~/.omp/agent fica intocado"
elif [ "$instala_omp" -eq 0 ]; then
    echo "camada omp: o payload não traz camada omp, ~/.omp/agent fica intocado (sinal: $sinais_omp)"
else
    if [ -n "$possui_omp" ]; then estado_omp="mantida"; else estado_omp="nova neste update"; fi
    echo "camada omp em ~/.omp/agent, $estado_omp (sinal: $sinais_omp):"
    echo "  arquivos novos ($(conta "$criados_omp")):"; na_camada "$criados_omp"
    echo "  substituídos ($(conta "$substituidos_omp")):"; na_camada "$substituidos_omp"
    if [ -n "$colisoes_omp" ]; then
        echo "  colisões, arquivo fora do lock com caminho da camada, será SUBSTITUÍDO ($(conta "$colisoes_omp")):"
        na_camada "$colisoes_omp"
    fi
    echo "  órfãos, serão REMOVIDOS ($(conta "$orfaos_omp")):"; na_camada "$orfaos_omp"
    echo "  não são do anvil, ficam intocados ($(conta "$alheios_omp")):"; na_camada "$alheios_omp"
fi
case "$estado_diretivas" in
    sem-fonte)    echo "diretivas: o payload não traz claude_boot.md, ~/.claude/CLAUDE.md fica intocado" ;;
    arquivo-novo) echo "diretivas em ~/.claude/CLAUDE.md: o arquivo não existe e será criado com o bloco ANVIL:DIRECTIVES" ;;
    bloco-novo)   echo "diretivas em ~/.claude/CLAUDE.md: bloco ANVIL:DIRECTIVES novo, no topo; o resto do arquivo fica intocado" ;;
    em-dia)       echo "diretivas em ~/.claude/CLAUDE.md: bloco ANVIL:DIRECTIVES em dia" ;;
    substituido)  echo "diretivas em ~/.claude/CLAUDE.md: bloco ANVIL:DIRECTIVES será SUBSTITUÍDO; fora do bloco fica intocado" ;;
esac
if [ -n "$PROJETO" ]; then
    echo "projeto anvil em $PROJETO: nada é escrito nele; perfis de docs/agents/ conferidos contra o template novo"
    reporta_perfis
else
    echo "fora de projeto anvil: só a instalação de usuário"
fi

# --- lockfile -----------------------------------------------------------------
# Reescrito a cada reset. E dele que o proximo update calcula os orfaos.
# A camada que nao foi tocada, por raiz do usuario, continua no lock: sem a linha,
# a camada perderia a posse e a regra pegajosa.
conteudo_lock() {
    local omp_lock
    echo "# anvil.lock — o que esta instalacao de usuario possui."
    echo "# Gerado por reset-install.sh. Nao edite: o proximo update reescreve."
    echo "installed_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    for s in $novo; do echo "skill: $s"; done
    for a in $novo_ag; do echo "agent: $a"; done
    if [ "$instala_omp" -eq 1 ]; then omp_lock="$novo_omp"; else omp_lock="$possui_omp"; fi
    for f in $omp_lock; do echo "omp: $f"; done
}
# A rule de diretivas do omp: o claude_boot.md com o frontmatter de rule
regra_diretivas() {
    printf -- '---\ndescription: "Diretivas do anvil: o mesmo texto do bloco ANVIL:DIRECTIVES do ~/.claude/CLAUDE.md."\nalwaysApply: true\n---\n\n'
    cat "$DIRETIVAS"
}

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

# Espelho: so symlink sai ou e refeito; o novo so e criado onde nao ha entrada nenhuma
for x in $orfaos_esp; do rm -f "${ESPELHO:?}/$x"; done
for x in $refeitos_esp; do
    rm -f "${ESPELHO:?}/$x"
    ln -s "../../.claude/skills/$x" "$ESPELHO/$x"
done
if [ -n "$criados_esp" ]; then
    mkdir -p "$ESPELHO"
    for x in $criados_esp; do ln -s "../../.claude/skills/$x" "$ESPELHO/$x"; done
fi

# Camada omp: o orfao sai, e a pasta que ele deixa vazia tambem, ate ~/.omp/agent,
# que fica. O arquivo da camada e reescrito com rm antes do cp, como o agente.
if [ "$instala_omp" -eq 1 ]; then
    for f in $orfaos_omp; do
        rm -f "${OMP:?}/$f"
        d="$(dirname "$f")"
        while [ "$d" != "." ] && rmdir "$OMP/$d" 2>/dev/null; do d="$(dirname "$d")"; done
    done
    for f in $novo_omp; do
        mkdir -p "$OMP/$(dirname "$f")"
        rm -f "${OMP:?}/$f"
        if [ "$f" = "$REGRA_DIRETIVAS" ]; then regra_diretivas > "$OMP/$f"
        else cp "$CAMADA_OMP/$f" "$OMP/$f"; fi
    done
fi

conteudo_lock > "$LOCK"

# Diretivas: so o que esta entre os marcadores muda. Sem marcador, o bloco entra
# no topo, seguido de uma linha em branco, e o resto do arquivo vem como estava.
# cat em vez de mv, para o arquivo manter as permissoes, e o alvo, se for symlink.
escreve_diretivas() {
    local tmp; tmp="$(mktemp)"
    case "$estado_diretivas" in
        arquivo-novo|bloco-novo)
            { echo "$DIR_INI"; cat "$DIRETIVAS"; echo "$DIR_FIM"
              if [ -f "$CLAUDE_MD" ]; then echo; cat "$CLAUDE_MD"; fi; } > "$tmp" ;;
        substituido)
            awk -v ini="$DIR_INI" -v fim="$DIR_FIM" -v src="$DIRETIVAS" '
                { l = $0; sub(/[ \t\r]+$/, "", l) }
                l == ini { print; while ((getline linha < src) > 0) print linha; dentro = 1; next }
                dentro   { if (l == fim) { dentro = 0; print }; next }
                         { print }' "$CLAUDE_MD" > "$tmp" ;;
    esac
    cat "$tmp" > "$CLAUDE_MD"; rm -f "$tmp"
}
case "$estado_diretivas" in
    arquivo-novo|bloco-novo|substituido) escreve_diretivas ;;
esac

echo
echo "pronto. $(conta "$novo") skills e $(conta "$novo_ag") agentes instalados em ~/.claude, $(conta "$orfaos$orfaos_ag") órfão(s) removido(s)."
