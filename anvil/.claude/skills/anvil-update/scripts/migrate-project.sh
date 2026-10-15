#!/usr/bin/env bash
# migrate-project.sh — tira de um projeto a instalação antiga do anvil, a que
# copiava o toolkit para dentro dele, e deixa o que é do projeto.
#
# O toolkit mora na instalação de usuário. Uma cópia velha no projeto fica inerte
# no Claude Code, onde a skill de usuário vence, mas no omp a camada do projeto
# pode vencer a de usuário: por isso a cópia sai, em vez de ficar sombreada.
#
# Cuida de um projeto só, o do diretório corrente, pela raiz do git. Não varre
# outros diretórios. O diretório do usuário, e o que está dentro de ~/.claude,
# ~/.agents e ~/.omp, nunca é projeto: é a instalação de usuário.
#
# Sai, guiado pelo .claude/anvil.lock do projeto:
#   .claude/skills/<s>                  uma por linha `skill:`
#   .claude/agents/<a>.md               um por linha `agent:`
#   .claude/anvil.lock                  o próprio lock
#   .agents/skills/<s>                  o symlink do espelho com nome de skill do lock
#   .omp/<f>                            um por linha `omp:`
#   .claude/settings.json               só a entrada do hook que chama
#                                       .claude/hooks/guard-spec-merge.sh
#   .claude/hooks/guard-spec-merge.sh   a cópia da guarda
#   CLAUDE.md                           só o bloco ANVIL:DIRECTIVES, com os marcadores;
#                                       o arquivo inteiro quando só tinha o bloco
#
# Sem lock, não há como saber o que veio do anvil: o script lista as skills e os
# agentes do projeto, marca os que têm conteúdo fora do git, e para, com saída 3,
# sem apagar nada. A resposta, o que NÃO veio do anvil, volta em --keep-skills e
# --keep-agents, e o resto sai. Sem lock não há linha `omp:`, e .omp/ fica.
#
# Fica: .claude/rules/, docs/, o settings fora da entrada do hook, o CLAUDE.md fora
# do bloco, e skill, agente e arquivo de .omp/ fora do lock. Nada é apagado nem
# escrito através de symlink: o item cujo caminho passa por um diretório que é
# symlink fica intocado, e o CLAUDE.md e o settings que são symlink também. O item
# que é ele mesmo symlink, como o do espelho, sai como link, sem tocar o alvo.
#
# Exige repositório git com árvore limpa e nunca commita. O que sai fica em duas
# partes. O que o git conhece aparece no git status depois da execução, e o diff
# da remoção é revisável. O que está fora do git — o item sem nada versionado e o
# arquivo ignorado dentro de item versionado, como um .DS_Store — sai junto, sem
# volta pelo git, e o relatório o lista arquivo por arquivo no grupo "sai junto,
# fora do git, sem volta pelo git", no dry-run e na execução. A regra de ignore,
# venha do .gitignore, do .git/info/exclude ou do excludes global, não faz a
# migração parar.
#
# Rodado em qualquer projeto, confere também os perfis de docs/agents/: perfil que
# cita script pelo caminho da instalação por projeto sai como BOOT PENDENTE,
# migrado ou não.
#
#   migrate-project.sh [--dry-run] [--keep-skills "<nomes>" --keep-agents "<nomes>"]
#
# Os nomes vão separados por espaço; "" quando tudo veio do anvil. As duas listas
# vão juntas.
# Saída 0: migrou, ou nada a migrar. 2: erro, nada foi alterado. 3: sem lock e sem
# a resposta, nada foi alterado.

set -euo pipefail

DRY=0; KEEP_SKILLS=""; KEEP_AGENTS=""; KS=0; KA=0
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY=1; shift ;;
        --keep-skills|--keep-agents)
            [ $# -ge 2 ] || { echo "erro: $1 pede a lista de nomes, \"\" se nenhum" >&2; exit 2; }
            if [ "$1" = --keep-skills ]; then KEEP_SKILLS="$2"; KS=1; else KEEP_AGENTS="$2"; KA=1; fi
            shift 2 ;;
        -h|--help) sed -n '2,54p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "erro: argumento desconhecido: $1" >&2; exit 2 ;;
    esac
done
# A resposta vem inteira: uma lista esquecida apagaria tudo o que ela cobre
[ "$KS" -eq "$KA" ] || { echo "erro: --keep-skills e --keep-agents vão juntos, com \"\" no que não tem nada do usuário" >&2; exit 2; }
ANSWERED=$KS

# Listas de um nome por linha: o for divide só em quebra de linha e não expande glob
IFS=$'\n'; set -f

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ROOT="$(cd "$ROOT" && pwd -P)"
# O diretório do usuário, e o que está dentro da instalação de usuário, não é
# projeto: ~/.claude/CLAUDE.md tem o bloco de diretivas da instalação de usuário.
if [ -n "${HOME:-}" ] && [ -d "$HOME" ]; then
    USER_DIR="$(cd "$HOME" && pwd -P)"
    case "$ROOT/" in
        "$USER_DIR/"|"$USER_DIR/.claude/"*|"$USER_DIR/.agents/"*|"$USER_DIR/.omp/"*)
            echo "$ROOT é da instalação de usuário, não é projeto: nada a migrar"; exit 0 ;;
    esac
fi

LOCK="$ROOT/.claude/anvil.lock"
SKILLS="$ROOT/.claude/skills"
AGENTS="$ROOT/.claude/agents"
MIRROR="$ROOT/.agents/skills"
OMP="$ROOT/.omp"
CLAUDE_MD="$ROOT/CLAUDE.md"
SETTINGS="$ROOT/.claude/settings.json"
GUARD_REF=".claude/hooks/guard-spec-merge.sh"
DIR_START="<!-- ANVIL:DIRECTIVES:START -->"
DIR_END="<!-- ANVIL:DIRECTIVES:END -->"

# --- perfis de docs/agents/ ----------------------------------------------------
# Caminho da instalação por projeto: .claude/skills/<s>/scripts/ ou a cópia da
# guarda, relativos ao projeto. Os da instalação de usuário — ~/.claude/,
# $HOME/.claude/ — saem da linha antes do teste.
report_profiles() {
    local f n
    for f in $(find "$ROOT/docs/agents" -mindepth 1 -maxdepth 1 -name '*.md' -type f 2>/dev/null | LC_ALL=C sort); do
        for n in $(awk '
            { l = $0; gsub(/(~|"?\$HOME"?|\$\{HOME\})\/\.claude\//, "", l) }
            l ~ /\.claude\/(skills\/[^\/ \t`"]+\/scripts\/|hooks\/guard-spec-merge\.sh)/ { print FNR }' "$f"); do
            echo "BOOT PENDENTE: docs/agents/$(basename "$f"):$n cita script pelo caminho da instalação por projeto, que não existe mais; rode o /anvil-boot para trazer o perfil do template"
        done
    done
}

# --- o bloco de diretivas do CLAUDE.md ------------------------------------------
# Os awk comparam o marcador com a linha sem o espaço, tab e \r do fim, como o
# reset-install: um checkout com core.autocrlf=true põe \r em toda linha.
block_lines() {  # "<início> <fim>" do bloco, em número de linha; nada sem bloco
    [ -f "$CLAUDE_MD" ] && awk -v ini="$DIR_START" -v fim="$DIR_END" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { s = NR }
        l == fim && s { print s, NR; exit }' "$CLAUDE_MD"
}
# Marcador fora de um único par START..END faria a remoção engolir linhas do usuário
markers_ok() {
    [ ! -f "$CLAUDE_MD" ] || awk -v ini="$DIR_START" -v fim="$DIR_END" '
        { l = $0; sub(/[ \t\r]+$/, "", l) }
        l == ini { if (i || f) { bad = 1; exit } i = 1 }
        l == fim { if (!i || f) { bad = 1; exit } f = 1 }
        END { exit (bad || i != f) }' "$CLAUDE_MD"
}

# --- a entrada da guarda no .claude/settings.json -------------------------------
# A entrada é a da guarda quando o comando cita .claude/hooks/guard-spec-merge.sh.
# Sai só ela; a lista, o evento ou o "hooks" que ficam vazios sem ela saem junto, e
# o settings que fica vazio sai inteiro. O resto do conteúdo fica, regravado com
# indentação de 2 espaços.
settings_guard() {  # <state|write> -> none | entry | file | invalid
    python3 - "$1" "$SETTINGS" "$GUARD_REF" <<'PYEOF'
import json, os, sys
mode, path, ref = sys.argv[1:4]
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
except (ValueError, OSError):
    print("invalid"); sys.exit()
hooks = data.get("hooks") if isinstance(data, dict) else None
pre = hooks.get("PreToolUse") if isinstance(hooks, dict) else None
if not isinstance(pre, list):
    print("none"); sys.exit()
def ours(h):
    return isinstance(h, dict) and isinstance(h.get("command"), str) and ref in h["command"]
found, kept_pre = False, []
for e in pre:
    if isinstance(e, dict) and isinstance(e.get("hooks"), list):
        kept = [h for h in e["hooks"] if not ours(h)]
        if len(kept) != len(e["hooks"]):
            found = True
            if not kept:
                continue
            e["hooks"] = kept
    kept_pre.append(e)
if not found:
    print("none"); sys.exit()
if kept_pre:
    hooks["PreToolUse"] = kept_pre
else:
    del hooks["PreToolUse"]
if not hooks:
    del data["hooks"]
state = "entry" if data else "file"
if mode == "state":
    print(state); sys.exit()
if state == "file":
    os.remove(path)
else:
    # open com "w" trunca no lugar: o arquivo mantém as permissões
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
PYEOF
}

# --- o que há no projeto --------------------------------------------------------
in_list() { grep -qxF -e "$2" <<< "$1"; }
count() { printf '%s' "$1" | grep -c . || true; }
# safe <relativo>: todo diretório entre a raiz e <relativo> é diretório de verdade.
# Apagar através de um symlink apagaria no alvo, que pode ser a instalação de usuário.
safe() {
    local p="" rest="$1"
    while [ "${rest#*/}" != "$rest" ]; do
        p="$p${p:+/}${rest%%/*}"; rest="${rest#*/}"
        { [ -d "$ROOT/$p" ] && [ ! -L "$ROOT/$p" ]; } || return 1
    done
}
present() { [ -e "$ROOT/$1" ] || [ -L "$ROOT/$1" ]; }
valid_name() { case "$1" in ""|.|..|*/*) return 1 ;; esac; }
lock_lines() {  # <chave>
    tr -d '\r' < "$LOCK" | sed -n "s/^$1: *//p" | sed 's/[[:space:]]*$//'
}
# ignored_under <relativo>...: os arquivos fora do git abaixo dos caminhos, os que o
# git ignora, venha a regra de onde vier. A árvore limpa garante que não há, no
# caminho, arquivo não versionado e não ignorado.
ignored_under() {
    [ $# -gt 0 ] || return 0
    git --literal-pathspecs -C "$ROOT" -c core.quotePath=false ls-files -o -i --exclude-standard -- "$@" | LC_ALL=C sort
}
# under <lista> <relativo>: algum caminho da lista é <relativo> ou fica abaixo dele
under() { awk -v p="$2" '$0 == p || index($0, p "/") == 1 { f = 1; exit } END { exit !f }' <<< "$1"; }

disk_skills=""; disk_agents=""
if safe ".claude/skills/x"; then
    disk_skills="$(find "$SKILLS" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -exec basename {} \; | LC_ALL=C sort)"
fi
if safe ".claude/agents/x"; then
    disk_agents="$(find "$AGENTS" -mindepth 1 -maxdepth 1 -name '*.md' \( -type f -o -type l \) -exec basename {} .md \; | LC_ALL=C sort)"
fi

has_lock=0; [ -f "$LOCK" ] && has_lock=1
block="$(block_lines || true)"
# O CLAUDE.md que só tinha o bloco, como o boot antigo o criava, sai inteiro
claude_md_gone=0
if [ -n "$block" ] && [ "${block% *}" -eq 1 ] && [ "${block#* }" -eq "$(awk 'END { print NR }' "$CLAUDE_MD")" ]; then
    claude_md_gone=1
fi
guard_in_settings=0
[ -f "$SETTINGS" ] && grep -qF "$GUARD_REF" "$SETTINGS" && guard_in_settings=1
legacy=$has_lock
[ -n "$block" ] && legacy=1
[ "$guard_in_settings" -eq 1 ] && legacy=1
present "$GUARD_REF" && legacy=1
for s in $disk_skills; do case "$s" in anvil-*) legacy=1 ;; esac; done

if [ "$legacy" -eq 0 ]; then
    echo "nenhuma instalação antiga do anvil em $ROOT: nada a migrar"
    report_profiles
    exit 0
fi

# --- pré-condições, antes de qualquer escrita -----------------------------------
git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 ||
    { echo "erro: $ROOT tem instalação antiga do anvil e não é repositório git — a migração apaga arquivos e precisa do git para o diff ser revisável" >&2; exit 2; }
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
    echo "erro: a árvore de $ROOT não está limpa; commite ou guarde (stash) antes, para que o diff mostre só a remoção:" >&2
    git -C "$ROOT" status --short >&2
    exit 2
fi
# Escrever num CLAUDE.md ou num settings que é symlink, ou que está atrás de um,
# escreveria no alvo, que pode ser de outros projetos: o item fica intocado.
behind_link=""
if [ -n "$block" ] && [ -L "$CLAUDE_MD" ]; then
    behind_link="${behind_link}CLAUDE.md, o bloco ANVIL:DIRECTIVES"$'\n'; block=""; claude_md_gone=0
fi
[ -L "$CLAUDE_MD" ] || markers_ok ||
    { echo "erro: CLAUDE.md tem marcadores ANVIL:DIRECTIVES fora de um único par START..END — conserte à mão" >&2; exit 2; }
settings_state="none"
if [ "$guard_in_settings" -eq 1 ] && { ! safe ".claude/settings.json" || [ -L "$SETTINGS" ]; }; then
    behind_link="${behind_link}.claude/settings.json, a entrada do hook que chama $GUARD_REF"$'\n'
elif [ "$guard_in_settings" -eq 1 ]; then
    command -v python3 >/dev/null 2>&1 ||
        { echo "erro: sem python3 para tirar do .claude/settings.json a entrada que chama $GUARD_REF — tire-a à mão e rode de novo" >&2; exit 2; }
    settings_state="$(settings_guard state)"
    [ "$settings_state" != invalid ] ||
        { echo "erro: .claude/settings.json não é JSON válido — conserte-o, ou tire à mão a entrada que chama $GUARD_REF, e rode de novo" >&2; exit 2; }
fi

# --- o que é do anvil -------------------------------------------------------------
anvil_skills=""; anvil_agents=""; anvil_omp=""
if [ "$has_lock" -eq 1 ]; then
    [ "$ANSWERED" -eq 0 ] ||
        { echo "erro: com .claude/anvil.lock, o que é do anvil vem do lock; --keep-skills e --keep-agents são só para projeto sem lock" >&2; exit 2; }
    for s in $(lock_lines skill); do valid_name "$s" && anvil_skills="$anvil_skills$s"$'\n'; done
    for a in $(lock_lines agent); do valid_name "$a" && anvil_agents="$anvil_agents$a"$'\n'; done
    # Caminho absoluto ou com `..` sairia de .omp/: não é da camada
    anvil_omp="$(lock_lines omp | awk 'NF && !/^\// && !/(^|\/)\.\.(\/|$)/')"
else
    if [ "$ANSWERED" -eq 0 ] && [ -n "$disk_skills$disk_agents" ]; then
        echo "migrate-project: instalação antiga do anvil em $ROOT, sem .claude/anvil.lock"
        echo "Sem lock, não há como saber o que veio do anvil. Nada foi alterado."
        # O item que tem conteúdo fora do git vem marcado: se sair, esse conteúdo não
        # volta pelo git, e quem responde precisa saber disso antes
        oog="$(ignored_under .claude/skills .claude/agents)"
        mark="  (tem conteúdo fora do git: se sair, não volta pelo git)"
        echo "skills em .claude/skills ($(count "$disk_skills")):"
        for s in $disk_skills; do echo "  $s$(under "$oog" ".claude/skills/$s" && echo "$mark")"; done
        echo "agentes em .claude/agents ($(count "$disk_agents")):"
        for a in $disk_agents; do echo "  .claude/agents/$a.md$(under "$oog" ".claude/agents/$a.md" && echo "$mark")"; done
        echo "Pergunte quais NÃO vieram do anvil e rode de novo com a resposta; o resto sai:"
        echo "  migrate-project.sh --dry-run --keep-skills \"<nomes>\" --keep-agents \"<nomes>\""
        report_profiles
        exit 3
    fi
    for k in $(printf '%s\n' "$KEEP_SKILLS" | tr ' ' '\n' | sed '/^$/d'); do
        in_list "$disk_skills" "$k" || { echo "erro: --keep-skills cita $k, que não está em .claude/skills" >&2; exit 2; }
    done
    for k in $(printf '%s\n' "$KEEP_AGENTS" | tr ' ' '\n' | sed 's/\.md$//; /^$/d'); do
        in_list "$disk_agents" "$k" || { echo "erro: --keep-agents cita $k, que não está em .claude/agents" >&2; exit 2; }
    done
    keep_s="$(printf '%s\n' "$KEEP_SKILLS" | tr ' ' '\n')"
    keep_a="$(printf '%s\n' "$KEEP_AGENTS" | tr ' ' '\n' | sed 's/\.md$//')"
    for s in $disk_skills; do in_list "$keep_s" "$s" || anvil_skills="$anvil_skills$s"$'\n'; done
    for a in $disk_agents; do in_list "$keep_a" "$a" || anvil_agents="$anvil_agents$a"$'\n'; done
fi

# Cada item do anvil sai se está no disco e o caminho até ele não passa por symlink
rm_skills=""; rm_agents=""; rm_mirror=""; rm_omp=""
take() {  # <variável> <relativo>
    present "$2" || return 0
    if safe "$2"; then printf -v "$1" '%s' "${!1}$2"$'\n'
    else behind_link="$behind_link$2"$'\n'; fi
}
for s in $anvil_skills; do
    take rm_skills ".claude/skills/$s"
    # No espelho, só o symlink é do anvil; diretório ou arquivo com o nome é do usuário
    [ -L "$MIRROR/$s" ] && take rm_mirror ".agents/skills/$s"
done
for a in $anvil_agents; do take rm_agents ".claude/agents/$a.md"; done
for f in $anvil_omp; do
    { [ -f "$OMP/$f" ] || [ -L "$OMP/$f" ]; } && take rm_omp ".omp/$f"
done
rm_lock=""; [ "$has_lock" -eq 1 ] && take rm_lock ".claude/anvil.lock"
rm_guard=""; take rm_guard "$GUARD_REF"

# O que sai fica em duas partes. O que o git conhece aparece no git status depois
# da execução. O que o git ignora sai junto sem aparecer lá: o item sem nada
# versionado e o ignorado dentro de item versionado. Esse vai para o relatório,
# arquivo por arquivo.
gone="$rm_skills$rm_agents$rm_mirror$rm_omp$rm_lock$rm_guard"
[ "$settings_state" = file ] && gone="$gone.claude/settings.json"$'\n'
[ "$claude_md_gone" -eq 1 ] && gone="${gone}CLAUDE.md"$'\n'
out_of_git=""
for f in $(ignored_under $gone); do out_of_git="$out_of_git$f"$'\n'; done

kept_skills=""; kept_agents=""; kept_omp=""
for s in $disk_skills; do in_list "$anvil_skills" "$s" || kept_skills="$kept_skills.claude/skills/$s"$'\n'; done
for a in $disk_agents; do in_list "$anvil_agents" "$a" || kept_agents="$kept_agents.claude/agents/$a.md"$'\n'; done
if safe ".omp/x"; then
    for f in $(cd "$OMP" && find . \( -type f -o -type l \) | sed 's|^\./||' | LC_ALL=C sort); do
        in_list "$anvil_omp" "$f" || kept_omp="$kept_omp.omp/$f"$'\n'
    done
fi

# --- relatório --------------------------------------------------------------------
group() {  # <título> <lista de caminhos>
    echo "  $1 ($(count "$2")):"
    printf '%s' "$2" | sed 's/^/    /'
}

echo "migrate-project: instalação antiga do anvil em $ROOT"
[ "$DRY" -eq 1 ] && echo "(dry-run: nada foi alterado)"
echo "sai do projeto:"
group "skills do anvil" "$rm_skills"
group "agentes do anvil" "$rm_agents"
group "symlinks do espelho" "$rm_mirror"
group "arquivos da camada omp, das linhas omp: do lock" "$rm_omp"
[ -n "$rm_lock" ] && echo "  .claude/anvil.lock, o lock"
[ -n "$rm_guard" ] && echo "  $GUARD_REF, a cópia da guarda"
case "$settings_state" in
    entry) echo "  .claude/settings.json: a entrada do hook que chama $GUARD_REF; o resto do conteúdo fica, regravado com indentação de 2 espaços" ;;
    file)  echo "  .claude/settings.json inteiro: só tinha a entrada do hook que chama $GUARD_REF" ;;
esac
if [ "$claude_md_gone" -eq 1 ]; then
    echo "  CLAUDE.md inteiro: só tinha o bloco ANVIL:DIRECTIVES"
elif [ -n "$block" ]; then
    echo "  CLAUDE.md: o bloco ANVIL:DIRECTIVES, linhas ${block% *} a ${block#* }, marcadores inclusive; o resto do arquivo fica byte a byte"
fi
[ -z "$out_of_git" ] || group "sai junto, fora do git, sem volta pelo git" "$out_of_git"
echo "fica no projeto:"
group "skills que não vieram do anvil" "$kept_skills"
group "agentes que não vieram do anvil" "$kept_agents"
[ -z "$kept_omp" ] || group "em .omp/, fora das linhas omp:" "$kept_omp"
[ -z "$behind_link" ] || group "do anvil, mas o caminho passa por symlink, intocados" "$behind_link"
echo "  .claude/rules/, docs/ e o resto do projeto"
echo "nada é commitado: revise com git status a remoção do que era versionado e commite"
report_profiles

[ "$DRY" -eq 1 ] && exit 0

# --- execução -----------------------------------------------------------------------
for x in $rm_skills; do rm -rf "${ROOT:?}/$x"; done
for x in $rm_agents $rm_mirror $rm_lock $rm_guard; do rm -f "${ROOT:?}/$x"; done
# O arquivo da camada sai, e a pasta que ele deixa vazia também, até .omp/
for x in $rm_omp; do
    rm -f "${ROOT:?}/$x"
    d="$(dirname "$x")"
    while [ "$d" != "." ] && rmdir "$ROOT/$d" 2>/dev/null; do d="$(dirname "$d")"; done
done
for d in .claude/hooks .claude/skills .claude/agents .agents/skills .agents; do
    rmdir "$ROOT/$d" 2>/dev/null || true
done
[ "$settings_state" = none ] || settings_guard write
# Só as linhas do bloco saem. head e tail não mexem nos bytes das outras, o \r e a
# falta de quebra no fim inclusive; cat em vez de mv mantém as permissões.
if [ "$claude_md_gone" -eq 1 ]; then
    rm -f "$CLAUDE_MD"
elif [ -n "$block" ]; then
    start="${block% *}"; end="${block#* }"
    tmp="$(mktemp)"
    # head -n 0 é erro no head do macOS
    { [ "$start" -eq 1 ] || head -n "$((start - 1))" "$CLAUDE_MD"; tail -n "+$((end + 1))" "$CLAUDE_MD"; } > "$tmp"
    cat "$tmp" > "$CLAUDE_MD"; rm -f "$tmp"
fi

echo
echo "pronto. $(count "$rm_skills") skill(s), $(count "$rm_agents") agente(s), $(count "$rm_mirror") symlink(s) do espelho e $(count "$rm_omp") arquivo(s) da camada omp tirados do projeto; nada foi commitado."
