#!/usr/bin/env bash
# vendor-sync.sh — plumbing da curadoria do anvil.
#
#   status              o que mudou upstream desde o pin de cada skill
#   pull                atualiza os submodules em references/ para o HEAD remoto
#   vendor <nome>       primeira cópia de uma skill planned
#   update [<nome>]     merge 3-way do upstream sobre a cópia adaptada
#   verify              checagens de integridade do payload
#
# A BASE do merge é reconstruída do submodule pelo pin do manifesto:
#
#   base   = git -C <submodule> show <pin>:<path>/<arquivo>
#   theirs = git -C <submodule> show <HEAD>:<path>/<arquivo>
#   ours   = anvil/.claude/skills/<nome>/<arquivo>
#
# Nenhum snapshot é guardado. Enquanto o commit existir no submodule — e ele
# existe, porque submodule é clone completo — a base é recuperável de graça.
#
# O script faz o que é MECÂNICO: mover bytes, rodar merge-file, aplicar o
# `rename`. As regras de julgamento (`docs-remap`, `decursor`) ele apenas
# SINALIZA; quem aplica é a skill anvil-sync, que sabe ler o que mudou.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MANIFEST="$ROOT/anvil-skills.yaml"
PAYLOAD="$ROOT/anvil/.claude/skills"

die() { printf 'erro: %s\n' "$*" >&2; exit 1; }

[ -f "$MANIFEST" ] || die "manifesto não encontrado em $MANIFEST"
command -v python3 >/dev/null 2>&1 || die "python3 é necessário para ler o manifesto"
python3 -c 'import yaml' 2>/dev/null || die "PyYAML é necessário: pip install pyyaml"

# --- leitura do manifesto -----------------------------------------------------
# Emite uma linha por skill, campos separados por \x1f (Unit Separator):
#   nome  estado  submodule  path  pin  adapt(,)  keep(,)  strip(,)
#
# NAO use tab: tab e whitespace, e `read` com IFS de whitespace COLAPSA
# delimitadores consecutivos. Um campo vazio no meio — o pin de uma skill
# ainda `planned` — desapareceria e deslocaria todos os seguintes.
manifest_rows() {
    python3 - "$MANIFEST" <<'PY'
import sys, yaml
m = yaml.safe_load(open(sys.argv[1], encoding='utf-8'))
src = m.get('sources', {})
for s in m.get('skills', []):
    o = src.get(s['source'], {})
    sub = o.get('submodule', '')
    sp = o.get('subpath', '')
    path = f"{sp}/{s['path']}" if sp else s['path']
    print('\x1f'.join([
        s['name'], s.get('state', 'planned'), sub, path, s.get('pin', ''),
        ','.join(s.get('adapt', [])), ','.join(s.get('keep', [])),
        ','.join(s.get('strip', [])),
    ]))
PY
}

row_for() {
    manifest_rows | awk -F'\037' -v n="$1" '$1 == n'
}

# Grava o pin de uma skill e marca como vendored, preservando o resto do YAML.
set_pin() {
    python3 - "$MANIFEST" "$1" "$2" <<'PY'
import re, sys
path, name, pin = sys.argv[1], sys.argv[2], sys.argv[3]
txt = open(path, encoding='utf-8').read()

# Formato de bloco:  - name: x\n    pin: y
blk = re.compile(r'(-\s+name:\s*' + re.escape(name) + r'\s*\n(?:[ \t]+\S.*\n)*)')
m = blk.search(txt)
if m:
    b = m.group(1)
    nb = re.sub(r'^(\s*)pin:.*$', lambda x: f"{x.group(1)}pin: {pin}", b, count=1, flags=re.M)
    if nb == b:
        nb = re.sub(r'^(\s*)state:', lambda x: f"{x.group(1)}pin: {pin}\n{x.group(1)}state:", b, count=1, flags=re.M)
    nb = re.sub(r'^(\s*)state:\s*planned\s*$', lambda x: f"{x.group(1)}state: vendored", nb, count=1, flags=re.M)
    open(path, 'w', encoding='utf-8').write(txt[:m.start(1)] + nb + txt[m.end(1):])
    sys.exit(0)

# Formato inline:  - { name: x, ... }
inl = re.compile(r'(-\s*\{[^}]*\bname:\s*' + re.escape(name) + r'\b[^}]*\})', re.S)
m = inl.search(txt)
if m:
    b = m.group(1)
    nb = b.replace('state: planned', f'pin: {pin}, state: vendored')
    open(path, 'w', encoding='utf-8').write(txt[:m.start(1)] + nb + txt[m.end(1):])
    sys.exit(0)

print(f"entrada '{name}' não encontrada no manifesto", file=sys.stderr)
sys.exit(1)
PY
}

# Lista os arquivos de um diretório numa árvore git, relativos a esse diretório.
tree_files() {  # <submodule> <ref> <path>
    git -C "$ROOT/$1" ls-tree -r --name-only "$2" -- "$3" 2>/dev/null \
        | sed "s|^$3/||"
}

is_listed() {  # <arquivo> <lista-csv>  — casa exato ou prefixo de diretório
    local f="$1" list="$2" item
    [ -n "$list" ] || return 1
    IFS=',' read -ra arr <<< "$list"
    for item in "${arr[@]}"; do
        [ -n "$item" ] || continue
        [ "$f" = "$item" ] && return 0
        case "$f" in "$item"/*) return 0 ;; esac
    done
    return 1
}

# `rename` — a única regra mecânica: o name: do frontmatter casa com o diretório.
apply_rename() {  # <dir-da-skill> <nome>
    local sk="$1/SKILL.md" name="$2"
    [ -f "$sk" ] || return 0
    sed -i.bak "1,10s|^name: .*|name: $name|" "$sk" && rm -f "$sk.bak"
}

# --- status -------------------------------------------------------------------

cmd_status() {
    local name state sub path pin head n_changed
    printf '%-26s %-9s %-10s %s\n' SKILL ESTADO UPSTREAM DETALHE
    while IFS=$'\x1f' read -r name state sub path pin _ _ _; do
        if [ "$state" != "vendored" ]; then
            printf '%-26s %-9s %-10s %s\n' "$name" "$state" '-' "$path"
            continue
        fi
        head="$(git -C "$ROOT/$sub" rev-parse HEAD 2>/dev/null)"
        if [ -z "$head" ]; then
            printf '%-26s %-9s %-10s %s\n' "$name" "$state" 'ERRO' "submodule $sub ausente"
            continue
        fi
        if [ "$head" = "$pin" ]; then
            printf '%-26s %-9s %-10s %s\n' "$name" "$state" 'em-dia' "${pin:0:7}"
            continue
        fi
        n_changed="$(git -C "$ROOT/$sub" diff --name-only "$pin" "$head" -- "$path" 2>/dev/null | wc -l | tr -d ' ')"
        if [ "$n_changed" = "0" ]; then
            printf '%-26s %-9s %-10s %s\n' "$name" "$state" 'em-dia' "submodule andou, a skill não"
        else
            printf '%-26s %-9s %-10s %s\n' "$name" "$state" 'ATRASADA' "$n_changed arquivo(s): ${pin:0:7} -> ${head:0:7}"
        fi
    done < <(manifest_rows)
}

# --- pull ---------------------------------------------------------------------

cmd_pull() {
    local sub
    for sub in $(manifest_rows | cut -d$'\x1f' -f3 | sort -u); do
        [ -n "$sub" ] || continue
        printf '%s: %s -> ' "$sub" "$(git -C "$ROOT/$sub" rev-parse --short HEAD)"
        git -C "$ROOT/$sub" fetch -q origin 2>/dev/null
        git -C "$ROOT/$sub" checkout -q "$(git -C "$ROOT/$sub" rev-parse --abbrev-ref origin/HEAD | sed 's|^origin/||')" 2>/dev/null
        git -C "$ROOT/$sub" pull -q --ff-only 2>/dev/null
        printf '%s\n' "$(git -C "$ROOT/$sub" rev-parse --short HEAD)"
    done
    echo
    echo "Rode 'status' para ver quais skills ficaram atrasadas."
}

# --- vendor -------------------------------------------------------------------

cmd_vendor() {
    local name="${1:-}" row state sub path adapt keep strip head dest f
    [ -n "$name" ] || die "uso: vendor <nome-da-skill>"
    row="$(row_for "$name")"
    [ -n "$row" ] || die "'$name' não está no manifesto"
    IFS=$'\x1f' read -r _ state sub path _ adapt keep strip <<< "$row"
    [ "$state" = "planned" ] || die "'$name' já está vendorizada. Use 'update $name'."

    head="$(git -C "$ROOT/$sub" rev-parse HEAD)" || die "submodule $sub ausente"
    dest="$PAYLOAD/$name"
    [ -e "$dest" ] && die "$dest já existe"

    mkdir -p "$dest"
    local n=0 nskip=0
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        if is_listed "$f" "$strip"; then nskip=$((nskip + 1)); continue; fi
        mkdir -p "$dest/$(dirname "$f")"
        git -C "$ROOT/$sub" show "$head:$path/$f" > "$dest/$f" || die "falha ao ler $f"
        n=$((n + 1))
    done < <(tree_files "$sub" "$head" "$path")

    case ",$adapt," in *,rename,*) apply_rename "$dest" "$name" ;; esac
    set_pin "$name" "$head" || die "falha ao gravar o pin"

    echo "vendorizada: $name"
    echo "  origem : $sub/$path @ ${head:0:7}"
    echo "  copiados: $n arquivo(s); ignorados por strip: $nskip"
    [ -n "$keep" ] && echo "  keep   : $keep"
    local j=""
    case ",$adapt," in *,docs-remap,*) j="$j docs-remap" ;; esac
    case ",$adapt," in *,decursor,*)   j="$j decursor" ;; esac
    if [ -n "$j" ]; then
        echo
        echo "  FALTA APLICAR À MÃO:$j"
        echo "  São regras de julgamento. Veja ../ADAPT-RULES.md e revise a skill."
    fi
}

# --- update -------------------------------------------------------------------

update_one() {
    local name="$1" row state sub path pin adapt keep strip head dest
    row="$(row_for "$name")"
    [ -n "$row" ] || { echo "  '$name' não está no manifesto"; return 1; }
    IFS=$'\x1f' read -r _ state sub path pin adapt keep strip <<< "$row"
    [ "$state" = "vendored" ] || { echo "  $name: planned, use 'vendor'"; return 0; }

    head="$(git -C "$ROOT/$sub" rev-parse HEAD)" || { echo "  $name: submodule ausente"; return 1; }
    dest="$PAYLOAD/$name"
    [ -d "$dest" ] || { echo "  $name: $dest não existe"; return 1; }

    if [ "$head" = "$pin" ]; then echo "  $name: em dia"; return 0; fi

    local limpos=0 conflitos=0 novos=0 apagados=0 conf_list="" f
    local base theirs

    # arquivos presentes no upstream novo
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        is_listed "$f" "$strip" && continue

        base="$(mktemp)"; theirs="$(mktemp)"
        git -C "$ROOT/$sub" show "$pin:$path/$f"  > "$base"   2>/dev/null || : > "$base"
        git -C "$ROOT/$sub" show "$head:$path/$f" > "$theirs" 2>/dev/null || : > "$theirs"

        if cmp -s "$base" "$theirs"; then rm -f "$base" "$theirs"; continue; fi

        if [ ! -f "$dest/$f" ]; then
            mkdir -p "$dest/$(dirname "$f")"
            cp "$theirs" "$dest/$f"
            novos=$((novos + 1))
            rm -f "$base" "$theirs"; continue
        fi

        if git merge-file -q "$dest/$f" "$base" "$theirs" 2>/dev/null; then
            limpos=$((limpos + 1))
        else
            conflitos=$((conflitos + 1)); conf_list="$conf_list    $f\n"
        fi
        rm -f "$base" "$theirs"
    done < <(tree_files "$sub" "$head" "$path")

    # arquivos que sumiram do upstream — reportados, nunca apagados
    local del_list=""
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        is_listed "$f" "$strip" && continue
        is_listed "$f" "$keep" && continue
        if ! git -C "$ROOT/$sub" cat-file -e "$head:$path/$f" 2>/dev/null; then
            apagados=$((apagados + 1)); del_list="$del_list    $f\n"
        fi
    done < <(tree_files "$sub" "$pin" "$path")

    printf '  %s: %s limpo(s), %s conflito(s), %s novo(s), %s sumiram upstream\n' \
        "$name" "$limpos" "$conflitos" "$novos" "$apagados"
    [ "$conflitos" -gt 0 ] && { echo "    CONFLITO — resolva os marcadores:"; printf "%b" "$conf_list"; }
    [ "$apagados" -gt 0 ] && { echo "    SUMIRAM upstream (não apagados aqui):"; printf "%b" "$del_list"; }

    if [ "$conflitos" -eq 0 ]; then
        case ",$adapt," in *,rename,*) apply_rename "$dest" "$name" ;; esac
        set_pin "$name" "$head"
        echo "    pin atualizado para ${head:0:7}"
        local j=""
        case ",$adapt," in *,docs-remap,*) j="$j docs-remap" ;; esac
        case ",$adapt," in *,decursor,*)   j="$j decursor" ;; esac
        [ -n "$j" ] && echo "    revise as regras de julgamento:$j"
    else
        echo "    pin NÃO atualizado — resolva os conflitos e rode de novo."
    fi
    return 0
}

cmd_update() {
    local target="${1:---all}" name state
    if [ "$target" != "--all" ]; then update_one "$target"; return $?; fi
    echo "update de todas as vendorizadas:"
    while IFS=$'\x1f' read -r name state _ _ _ _ _ _; do
        [ "$state" = "vendored" ] && update_one "$name"
    done < <(manifest_rows)
}

# --- verify -------------------------------------------------------------------

DENY='[~]/\.cursor|cursor-team-kit|claude-fable-5-thinking|gpt-5\.6-sol|grok-4\.6-fast|setup-matt-pocock-skills'

cmd_verify() {
    local falhas=0 d n fm f l t

    echo "1. name: do frontmatter bate com o diretório"
    for d in "$PAYLOAD"/*/; do
        n="$(basename "$d")"
        [ -f "$d/SKILL.md" ] || { echo "   FALHA $n: sem SKILL.md"; falhas=$((falhas+1)); continue; }
        fm="$(sed -n 's/^name: *//p' "$d/SKILL.md" | head -1 | tr -d '"')"
        [ "$n" = "$fm" ] || { echo "   FALHA $n: frontmatter diz '$fm'"; falhas=$((falhas+1)); }
    done

    # Extrai links IGNORANDO bloco de codigo cercado: ali o link e EXEMPLO do
    # que o arquivo do projeto-alvo vai conter, nao um link deste documento.
    # Tambem ignora URL (contem ://) e caminho com placeholder ({{...}}, <...>).
    links_of() {
        python3 - "$1" <<'PYEOF'
import re, sys
out, fence = [], False
for line in open(sys.argv[1], encoding='utf-8', errors='replace'):
    if line.lstrip().startswith('```'):
        fence = not fence
        continue
    if fence:
        continue
    for m in re.finditer(r'\]\(([^)\s]+?)(?:#[^)]*)?\)', line):
        t = m.group(1)
        if '://' in t or t.startswith('#') or '{{' in t or '<' in t:
            continue
        if re.search(r'\.(md|sh|ts|yaml|yml)$', t):
            out.append(t)
print('\n'.join(out))
PYEOF
    }

    echo "2. links relativos resolvem"
    while IFS= read -r f; do
        d="$(dirname "$f")"
        while IFS= read -r l; do
            [ -n "$l" ] || continue
            [ -e "$d/$l" ] || { echo "   FALHA ${f#"$PAYLOAD"/} -> $l"; falhas=$((falhas+1)); }
        done < <(links_of "$f")
    done < <(find "$PAYLOAD" -name '*.md' -not -path '*/starter/*' -not -path '*/templates/*')

    # Dependencia entre skills se declara chamando a Skill tool, nunca com
    # caminho relativo: apos o degit, uma skill pode nao estar instalada, e o
    # ponteiro morre em silencio. Resolve o link e confere se sai do diretorio
    # da propria skill — `../` na raiz da skill JA escapa.
    echo "3. nenhum caminho relativo cruza fronteira de skill"
    while IFS= read -r f; do
        skill_dir="$PAYLOAD/$(printf '%s' "${f#"$PAYLOAD"/}" | cut -d/ -f1)"
        d="$(dirname "$f")"
        while IFS= read -r l; do
            case "$l" in ../*) ;; *) continue ;; esac
            abs="$(cd "$d" 2>/dev/null && cd "$(dirname "$l")" 2>/dev/null && pwd)"
            [ -n "$abs" ] || abs="$d/$l"
            case "$abs" in "$skill_dir"|"$skill_dir"/*) ;;
                *) echo "   FALHA ${f#"$PAYLOAD"/} -> $l"; falhas=$((falhas+1)) ;; esac
        done < <(links_of "$f")
    done < <(find "$PAYLOAD" -name '*.md' -not -path '*/starter/*' -not -path '*/templates/*')

    echo "4. denylist de tokens do upstream"
    while IFS= read -r f; do
        if grep -qE "$DENY" "$f" 2>/dev/null; then
            echo "   FALHA ${f#"$PAYLOAD"/}: $(grep -ohE "$DENY" "$f" | sort -u | tr '\n' ' ')"
            falhas=$((falhas+1))
        fi
    done < <(find "$PAYLOAD" -name '*.md' -not -path '*/starter/*')

    # Identificador OPERACIONAL do mosk — caminho ou nome de runtime que
    # simplesmente não existe depois do degit. Menção em prosa ("o mosk fazia
    # assim, e por isso mudamos") é documentação, não contrabando: explica a
    # decisão para quem vier depois. Proibir as duas coisas apagaria o motivo.
    echo "5. nenhum identificador operacional do mosk"
    MOSK_OPS='\.claude/mosk/|mosk-net|\.mosk-infra|/mosk-[a-z]|MOSK:DIRECTIVES'
    #
    # Escape hatch: um arquivo pode declarar `anvil-verify: allow-mosk-ops` com
    # um motivo. A dispensa é IMPRESSA, nunca silenciosa — quem roda o verify vê
    # o que foi dispensado e por quê, e pode discordar.
    t=0
    while IFS= read -r f; do
        grep -qE "$MOSK_OPS" "$f" 2>/dev/null || continue
        if grep -q 'anvil-verify: allow-mosk-ops' "$f" 2>/dev/null; then
            echo "   dispensa ${f#"$PAYLOAD"/}: $(sed -n 's/.*allow-mosk-ops *[—-] *//p' "$f" | head -1)"
            continue
        fi
        echo "   FALHA ${f#"$PAYLOAD"/}: $(grep -ohE "$MOSK_OPS" "$f" | sort -u | tr '\n' ' ')"
        t=$((t + 1))
    done < <(find "$PAYLOAD" -type f -not -path '*/starter/*')
    falhas=$((falhas + t))

    echo "6. skills vendorizadas existem no payload"
    while IFS=$'\x1f' read -r n state _ _ _ _ _ _; do
        [ "$state" = "vendored" ] || continue
        [ -d "$PAYLOAD/$n" ] || { echo "   FALHA $n: no manifesto como vendored, ausente do payload"; falhas=$((falhas+1)); }
    done < <(manifest_rows)

    echo
    if [ "$falhas" -eq 0 ]; then echo "verify: limpo"; return 0; fi
    echo "verify: $falhas falha(s)"; return 1
}

# --- despacho -----------------------------------------------------------------

usage() {
    sed -n '3,8p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

case "${1:-status}" in
    status) cmd_status ;;
    pull)   cmd_pull ;;
    vendor) shift; cmd_vendor "$@" ;;
    update) shift; cmd_update "$@" ;;
    verify) cmd_verify ;;
    -h|--help) usage ;;
    *) echo "subcomando desconhecido: $1" >&2; usage >&2; exit 2 ;;
esac
