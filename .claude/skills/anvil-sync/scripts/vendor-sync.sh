#!/usr/bin/env bash
# vendor-sync.sh — plumbing da curadoria do anvil.
#
#   status              o que mudou upstream desde o pin de cada skill
#   pull                atualiza os submodules em references/ para o HEAD remoto
#   vendor <nome>       primeira cópia de uma skill planned
#   update [<nome>]     merge 3-way do upstream sobre a cópia adaptada
#   verify              checagens de integridade do payload
#   lock                regenera o anvil.lock a partir do payload
#   stats               a métrica do README: linhas nossas contra o pin
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
# `rename` e o `invocable`. As regras de julgamento (`docs-remap`, `decursor`,
# `tracker-profile`) ele apenas SINALIZA; quem aplica é a skill anvil-sync, que sabe ler o que mudou.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
MANIFEST="$ROOT/anvil-skills.yaml"
PAYLOAD="$ROOT/anvil/.claude/skills"
AGENTS="$ROOT/anvil/.claude/agents"

die() { printf 'erro: %s\n' "$*" >&2; exit 1; }

[ -f "$MANIFEST" ] || die "manifesto não encontrado em $MANIFEST"
command -v python3 >/dev/null 2>&1 || die "python3 é necessário para ler o manifesto"
python3 -c 'import yaml' 2>/dev/null || die "PyYAML é necessário: pip install pyyaml"

# --- leitura do manifesto -----------------------------------------------------
# Emite uma linha por skill, campos separados por \x1f (Unit Separator):
#   nome  estado  submodule  path  pin  adapt(,)  keep(,)  strip(,)  extra(,)
#
# `extra` traz arquivo que vive FORA do path da skill no mesmo submodule, em
# pares `origem::destino`. Existe porque uma skill pode depender de material que
# o upstream guarda na raiz do repositorio — e trazer por `extra` o mantem no
# merge 3-way, ao contrario de copiar a mao uma vez e esquecer.
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
    # path vazio continua vazio: a skill nao tem arvore propria, so extras.
    # Concatenar o subpath aqui produziria "pstack/", que NAO e vazio e faria
    # o tree-walk varrer o plugin inteiro.
    raw = s.get('path', '')
    path = (f"{sp}/{raw}" if sp else raw) if raw else ''
    # extras sao caminhos no submodule: levam o subpath tambem.
    extra = [(f"{sp}/{e}" if sp and not e.startswith(sp + '/') else e) for e in s.get('extra', [])]
    # str() em tudo: um pin composto so de digitos e lido como int pelo YAML,
    # e o join estoura. SHA so-digitos e raro, nao impossivel.
    print('\x1f'.join(str(x) for x in [
        s['name'], s.get('state', 'planned'), sub, path, s.get('pin', ''),
        ','.join(s.get('adapt', [])), ','.join(s.get('keep', [])),
        ','.join(s.get('strip', [])), ','.join(extra),
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
    # path vazio: a skill nao tem arvore propria no upstream, so `extra`.
    # E o caso de material que o upstream publica espalhado e o anvil reune.
    [ -n "$3" ] || return 0
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

# Traz os pares `origem::destino` de `extra`, de uma ref do submodule.
#
# Sem <pin>, copia direto (primeira vendorizacao, nao ha "ours").
# Com <pin>, faz o MESMO merge 3-way dos demais arquivos. Copiar por cima no
# update apagaria qualquer adaptacao feita no extra — e o link relativo de um
# arquivo que mudou de lugar e exatamente o tipo de adaptacao que ele precisa.
copy_extras() {  # <submodule> <ref> <dest-skill> <extra-csv> [<pin>]
    local sub="$1" ref="$2" dest="$3" list="$4" pin="${5:-}" pair from to n=0
    local base theirs
    [ -n "$list" ] || { echo 0; return 0; }
    IFS=',' read -ra arr <<< "$list"
    for pair in "${arr[@]}"; do
        [ -n "$pair" ] || continue
        from="${pair%%::*}"; to="${pair##*::}"
        mkdir -p "$dest/$(dirname "$to")"
        if [ -z "$pin" ] || [ ! -f "$dest/$to" ]; then
            git -C "$ROOT/$sub" show "$ref:$from" > "$dest/$to" 2>/dev/null && n=$((n + 1))
            continue
        fi
        base="$(mktemp)"; theirs="$(mktemp)"
        git -C "$ROOT/$sub" show "$pin:$from" > "$base"   2>/dev/null || : > "$base"
        git -C "$ROOT/$sub" show "$ref:$from" > "$theirs" 2>/dev/null || : > "$theirs"
        if cmp -s "$base" "$theirs"; then rm -f "$base" "$theirs"; continue; fi
        if git merge-file -q "$dest/$to" "$base" "$theirs" 2>/dev/null; then
            n=$((n + 1))
        else
            echo "    CONFLITO no extra: $to" >&2
        fi
        rm -f "$base" "$theirs"
    done
    echo "$n"
}

# `rename` — a única regra mecânica: o name: do frontmatter casa com o diretório.
apply_rename() {  # <dir-da-skill> <nome>
    local sk="$1/SKILL.md" name="$2"
    [ -f "$sk" ] || return 0
    sed -i.bak "1,10s|^name: .*|name: $name|" "$sk" && rm -f "$sk.bak"
}

# `invocable` — mecânica: tira a trava `disable-model-invocation` do frontmatter,
# para um orquestrador conseguir despachar a skill pela Skill tool. Reaplicada
# depois de todo merge, como o rename: um conflito no frontmatter resolvido a
# favor do upstream traria a trava de volta em silêncio.
apply_invocable() {  # <dir-da-skill>
    local sk="$1/SKILL.md"
    [ -f "$sk" ] || return 0
    sed -i.bak '1,10{/^disable-model-invocation: *true *$/d;}' "$sk" && rm -f "$sk.bak"
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
    local name="${1:-}" row state sub path adapt keep strip extra head dest f
    [ -n "$name" ] || die "uso: vendor <nome-da-skill>"
    row="$(row_for "$name")"
    [ -n "$row" ] || die "'$name' não está no manifesto"
    IFS=$'\x1f' read -r _ state sub path _ adapt keep strip extra <<< "$row"
    [ "$state" = "planned" ] || die "'$name' já está vendorizada. Use 'update $name'."

    head="$(git -C "$ROOT/$sub" rev-parse HEAD)" || die "submodule $sub ausente"
    dest="$PAYLOAD/$name"

    # Destino existente passa SO quando tudo que ja esta la e `keep`. E o caso
    # de adotar material upstream DENTRO de uma skill autoral: o anvil-bench tem
    # SKILL.md e GATE.md nossos, e o unlazy entra embaixo de unlazy/. Qualquer
    # arquivo fora do keep significa sobrescrever trabalho, e a recusa continua.
    if [ -e "$dest" ]; then
        while IFS= read -r f; do
            [ -n "$f" ] || continue
            is_listed "$f" "$keep" || die "$dest ja existe e contem '$f', que nao esta no keep"
        done < <(cd "$dest" && find . -type f | sed 's|^\./||')
    fi

    mkdir -p "$dest"
    local n=0 nskip=0
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        if is_listed "$f" "$strip"; then nskip=$((nskip + 1)); continue; fi
        mkdir -p "$dest/$(dirname "$f")"
        git -C "$ROOT/$sub" show "$head:$path/$f" > "$dest/$f" || die "falha ao ler $f"
        n=$((n + 1))
    done < <(tree_files "$sub" "$head" "$path")

    local nextra; nextra="$(copy_extras "$sub" "$head" "$dest" "$extra")"
    case ",$adapt," in *,rename,*) apply_rename "$dest" "$name" ;; esac
    case ",$adapt," in *,invocable,*) apply_invocable "$dest" ;; esac
    set_pin "$name" "$head" || die "falha ao gravar o pin"
    gerar_lock >/dev/null

    echo "vendorizada: $name"
    echo "  origem : $sub/$path @ ${head:0:7}"
    echo "  copiados: $n arquivo(s); ignorados por strip: $nskip; extras: $nextra"
    [ -n "$keep" ] && echo "  keep   : $keep"
    local j=""
    case ",$adapt," in *,docs-remap,*) j="$j docs-remap" ;; esac
    case ",$adapt," in *,decursor,*)   j="$j decursor" ;; esac
    case ",$adapt," in *,tracker-profile,*) j="$j tracker-profile" ;; esac
    if [ -n "$j" ]; then
        echo
        echo "  FALTA APLICAR À MÃO:$j"
        echo "  São regras de julgamento. Veja ../ADAPT-RULES.md e revise a skill."
    fi
}

# --- update -------------------------------------------------------------------

update_one() {
    local name="$1" row state sub path pin adapt keep strip extra head dest
    row="$(row_for "$name")"
    [ -n "$row" ] || { echo "  '$name' não está no manifesto"; return 1; }
    IFS=$'\x1f' read -r _ state sub path pin adapt keep strip extra <<< "$row"
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
        copy_extras "$sub" "$head" "$dest" "$extra" "$pin" >/dev/null
        case ",$adapt," in *,rename,*) apply_rename "$dest" "$name" ;; esac
        case ",$adapt," in *,invocable,*) apply_invocable "$dest" ;; esac
        set_pin "$name" "$head"
        gerar_lock >/dev/null
        echo "    pin atualizado para ${head:0:7}"
        local j=""
        case ",$adapt," in *,docs-remap,*) j="$j docs-remap" ;; esac
        case ",$adapt," in *,decursor,*)   j="$j decursor" ;; esac
        case ",$adapt," in *,tracker-profile,*) j="$j tracker-profile" ;; esac
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

# --- lock ---------------------------------------------------------------------
# O anvil.lock diz o que uma instalacao possui, e e dele que o reset-install
# calcula os orfaos. Numa instalacao NOVA o caminho e `degit` direto, e o
# reset-install nao roda — entao o lock precisa VIR NO PAYLOAD, ja pronto.
#
# Ele e derivado: e a lista de skills e de agentes do payload. Por isso e
# regenerado a cada `vendor` e `update`, e o `verify` reprova quando desincroniza
# — um lock que esqueceu uma skill ou um agente faz o proximo update trata-lo
# como alheio e nunca substitui-lo, em silencio.
gerar_lock() {
    local dest="$ROOT/anvil/.claude/anvil.lock" d f
    {
        echo "# anvil.lock — o que esta instalacao possui."
        echo "# Derivado do payload. Regenerado por vendor, update e"
        echo "# 'vendor-sync.sh lock'. Nao edite a mao."
        for d in "$PAYLOAD"/*/; do [ -d "$d" ] && echo "skill: $(basename "$d")"; done
        for f in "$AGENTS"/*.md; do [ -f "$f" ] && echo "agent: $(basename "$f" .md)"; done
    } > "$dest"
    printf '%s skills e %s agentes no lock\n' "$(grep -c '^skill: ' "$dest")" "$(grep -c '^agent: ' "$dest")"
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
        if re.search(r'\.(md|sh|ts|css|yaml|yml)$', t):
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

    echo "7. o anvil.lock bate com o payload"
    local lock="$ROOT/anvil/.claude/anvil.lock"
    if [ ! -f "$lock" ]; then
        echo "   FALHA anvil.lock ausente — rode 'vendor-sync.sh lock'"
        falhas=$((falhas + 1))
    else
        local so_lock so_disco
        so_lock="$(comm -23 <(sed -n 's/^skill: //p' "$lock" | sort) <(find "$PAYLOAD" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort))"
        so_disco="$(comm -13 <(sed -n 's/^skill: //p' "$lock" | sort) <(find "$PAYLOAD" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort))"
        [ -n "$so_lock" ] && { echo "   FALHA no lock e nao no payload: $(echo "$so_lock" | tr '\n' ' ')"; falhas=$((falhas+1)); }
        [ -n "$so_disco" ] && { echo "   FALHA no payload e nao no lock: $(echo "$so_disco" | tr '\n' ' ')"; falhas=$((falhas+1)); }
        so_lock="$(comm -23 <(sed -n 's/^agent: //p' "$lock" | sort) <(find "$AGENTS" -maxdepth 1 -type f -name '*.md' -exec basename {} .md \; 2>/dev/null | sort))"
        so_disco="$(comm -13 <(sed -n 's/^agent: //p' "$lock" | sort) <(find "$AGENTS" -maxdepth 1 -type f -name '*.md' -exec basename {} .md \; 2>/dev/null | sort))"
        [ -n "$so_lock" ] && { echo "   FALHA agente no lock e nao no payload: $(echo "$so_lock" | tr '\n' ' ')"; falhas=$((falhas+1)); }
        [ -n "$so_disco" ] && { echo "   FALHA agente no payload e nao no lock: $(echo "$so_disco" | tr '\n' ' ')"; falhas=$((falhas+1)); }
    fi

    echo "8. skill marcada invocable não tem a trava de invocação"
    while IFS=$'\x1f' read -r n state _ _ _ a _ _ _; do
        [ "$state" = "vendored" ] || continue
        case ",$a," in *,invocable,*) ;; *) continue ;; esac
        [ -f "$PAYLOAD/$n/SKILL.md" ] || continue
        sed -n '1,10p' "$PAYLOAD/$n/SKILL.md" | grep -qE '^disable-model-invocation: *true' &&
            { echo "   FALHA $n: invocable no manifesto, mas o frontmatter ainda trava"; falhas=$((falhas+1)); }
    done < <(manifest_rows)

    # O Claude Code acha o agente pelo name:, e o lock e o bloco o acham pelo nome
    # do arquivo. Os dois tem de ser o mesmo.
    echo "9. name: do agente bate com o nome do arquivo"
    for f in "$AGENTS"/*.md; do
        [ -f "$f" ] || continue
        n="$(basename "$f" .md)"
        fm="$(awk '{ sub(/[ \t\r]+$/, "") } NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit }
                   sub(/^name: */, "") { print; exit }' "$f" | tr -d "\"'")"
        [ "$n" = "$fm" ] || { echo "   FALHA agents/$n.md: frontmatter diz '$fm'"; falhas=$((falhas+1)); }
    done

    # Contrato de citacao com a equipe (spec 001, team-shape.md, secao 3). Num agente,
    # caminho do payload se cita so em crase e relativo a raiz de instalacao, porque
    # o modelo resolve caminho a partir do cwd, a raiz do projeto, e nao do arquivo
    # do agente. Link relativo resolveria para o verify e nao para o modelo:
    # pareceria checado e quebraria em uso. Por isso o span e conferido contra
    # anvil/, a raiz do payload, e o link e falha em qualquer lugar do arquivo.
    #
    # Span em crase de uma linha, como no CommonMark: abre e fecha com a mesma
    # quantidade de crases. Fica de fora o que e padrao e nao caminho (`*`, `{`, `<`)
    # e o que esta em bloco cercado, que e exemplo. A cerca e de crase ou de til, e
    # so fecha com a mesma marca e pelo menos o mesmo comprimento: uma cerca de
    # quatro crases pode mostrar uma de tres por dentro.
    spans_of() {
        python3 - "$1" <<'PYEOF'
import re, sys
fence = None
for line in open(sys.argv[1], encoding='utf-8', errors='replace'):
    m = re.match(r' {0,3}(`{3,}|~{3,})', line)
    if fence:
        if m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence) and not line[m.end():].strip():
            fence = None
        continue
    if m:
        fence = m.group(1)
        continue
    for m in re.finditer(r'(?<!`)(`+)(?!`)(.+?)(?<!`)\1(?!`)', line):
        t = m.group(2)
        if len(t) > 1 and t[0] == ' ' and t[-1] == ' ':
            t = t[1:-1]
        if t.startswith('.claude/') and not re.search(r'[*{<]', t):
            print(t)
PYEOF
    }

    echo "10. caminho .claude/ citado por agente existe no payload"
    for f in "$AGENTS"/*.md; do
        [ -f "$f" ] || continue
        while IFS= read -r t; do
            [ -n "$t" ] || continue
            [ -e "$ROOT/anvil/$t" ] || { echo "   FALHA agents/$(basename "$f") -> $t"; falhas=$((falhas+1)); }
        done < <(spans_of "$f")
    done

    echo "11. nenhum link markdown relativo em agente"
    for f in "$AGENTS"/*.md; do
        [ -f "$f" ] || continue
        while IFS= read -r t; do
            echo "   FALHA agents/$(basename "$f"): link relativo $t"; falhas=$((falhas+1))
        done < <(python3 - "$f" <<'PYEOF'
import re, sys
for line in open(sys.argv[1], encoding='utf-8', errors='replace'):
    alvos = [m.group(1) for m in re.finditer(r'\]\(([^)]*)\)', line)]
    # link por referencia, "[p]: PROTOCOL.md"; "[^1]: ..." e nota de rodape
    m = re.match(r' {0,3}\[(?!\^)[^\]]+\]:[ \t]*<?([^\s>]+)', line)
    if m:
        alvos.append(m.group(1))
    for t in alvos:
        if '://' not in t:
            print(t)
PYEOF
)
    done

    # O papel chega ao protocolo pela linha-ponteiro (team-shape.md, secao 3). Sem
    # ela, age sem saber a delegacao que recebeu nem o retorno que deve. Conta so a
    # citacao que o check 10 confere: em crase e fora de bloco cercado.
    echo "12. agente de equipe cita o protocolo"
    for f in "$AGENTS"/anvil-team-*.md; do
        [ -f "$f" ] || continue
        spans_of "$f" | grep -qxF '.claude/skills/anvil-team/PROTOCOL.md' ||
            { echo "   FALHA agents/$(basename "$f"): nao cita .claude/skills/anvil-team/PROTOCOL.md"; falhas=$((falhas+1)); }
    done

    # Residuo do port da equipe do Maestri: nota de canvas e erro de conexao, que
    # depois do degit apontam para o nada. O check 4 e de upstream vendorizado e nao
    # os pega. Vale em qualquer arquivo e em bloco cercado tambem: nao ha uso legitimo.
    echo "13. nenhum token do Maestri em skill ou agente"
    MAESTRI='@team-protocol|@anvil-skills|@mission-control|@anvil-install|No connection to note'
    while IFS= read -r f; do
        grep -qIE "$MAESTRI" "$f" 2>/dev/null || continue
        echo "   FALHA ${f#"$ROOT/anvil/.claude/"}: $(grep -ohE "$MAESTRI" "$f" | sort -u | tr '\n' ' ')"
        falhas=$((falhas+1))
    done < <(find "$PAYLOAD" "$AGENTS" -type f 2>/dev/null)

    echo
    if [ "$falhas" -eq 0 ]; then echo "verify: limpo"; return 0; fi
    echo "verify: $falhas falha(s)"; return 1
}

# --- stats --------------------------------------------------------------------
# A métrica que o README publica. A definição mora aqui; o README cita este
# comando e a data em que ele rodou.
#
# LINHA NOSSA é a linha presente no payload e ausente da versão do pin: o lado
# nosso (`>`) do diff pin→payload. Linha que o anvil apagou não conta, e linha
# alterada conta uma vez. Por isso a skill cujo único delta é o `rename` mede
# exatamente 1, e o `invocable`, que só apaga a trava, não soma nada.
#
# A base é o pin, não o HEAD do submodule: mede a cópia contra a versão de onde
# ela saiu, e o número não muda quando o upstream anda.
#
# Cada arquivo de uma skill `vendored` cai num balde só, nesta precedência:
#
#   keep     arquivo do anvil dentro da skill. Conta à parte: arquivos e linhas.
#   extra    arquivo trazido de fora da árvore da skill (`origem::destino`).
#            Comparado com a origem no pin, mas conta à parte.
#   strip    arquivo da árvore no pin deixado de fora. Só o número de arquivos.
#   pareado  existe dos dois lados, na árvore da skill no pin e no payload. É o
#            ÚNICO balde que entra em "linhas" e "linhas nossas".
#   sem par  arquivo de um lado só que nenhuma regra acima explica. Fica fora da
#            conta, mas aparece, para não sumir em silêncio.
#
# Linhas de um arquivo contam por awk (NR), que inclui a última sem \n.
nlines() { awk 'END { print NR }' "$1"; }

nossas() {  # <base> <payload>
    diff "$1" "$2" | grep -c '^>'
}

cmd_stats() {
    local name state sub path pin keep strip extra dest f pair from to dests
    local arq lin nos k kl e el en s sp
    local t_sk=0 t_arvore=0 t_arq=0 t_lin=0 t_nos=0 t_um=0 t_s=0 t_sp=0
    local t_k=0 t_kl=0 t_e=0 t_el=0 t_en=0 sem_arvore="" sem_par="" erros=0
    local base; base="$(mktemp)"

    printf '%-26s %5s %7s %6s %5s %5s %5s %7s\n' SKILL ARQ LINHAS NOSSAS KEEP EXTRA STRIP SEM-PAR
    while IFS=$'\x1f' read -r name state sub path pin _ keep strip extra; do
        [ "$state" = "vendored" ] || continue
        dest="$PAYLOAD/$name"
        arq=0; lin=0; nos=0; k=0; kl=0; e=0; el=0; en=0; s=0; sp=0

        # Sem o pin, todo `git show` falha e cada arquivo cairia em "sem par":
        # o número sairia errado sem falha nenhuma.
        if ! git -C "$ROOT/$sub" cat-file -e "$pin^{commit}" 2>/dev/null; then
            printf '%-26s ERRO submodule %s sem o pin %s\n' "$name" "$sub" "${pin:0:7}"
            erros=$((erros + 1)); continue
        fi

        dests=""
        if [ -n "$extra" ]; then
            IFS=',' read -ra arr <<< "$extra"
            for pair in "${arr[@]}"; do
                [ -n "$pair" ] || continue
                from="${pair%%::*}"; to="${pair##*::}"
                dests="$dests,$to"
                is_listed "$to" "$keep" && continue
                if [ -f "$dest/$to" ] && git -C "$ROOT/$sub" show "$pin:$from" > "$base" 2>/dev/null; then
                    e=$((e + 1)); el=$((el + $(nlines "$dest/$to"))); en=$((en + $(nossas "$base" "$dest/$to")))
                else
                    sp=$((sp + 1)); sem_par="$sem_par$name/$to, extra sem origem no pin ou sem destino"$'\n'
                fi
            done
        fi

        # lado do payload: keep, extra (já contado), strip (contado no lado do
        # pin), pareado ou sem par
        while IFS= read -r f; do
            if is_listed "$f" "$keep"; then k=$((k + 1)); kl=$((kl + $(nlines "$dest/$f"))); continue; fi
            is_listed "$f" "$dests" && continue
            if [ -n "$path" ] && git -C "$ROOT/$sub" show "$pin:$path/$f" > "$base" 2>/dev/null; then
                is_listed "$f" "$strip" && continue
                arq=$((arq + 1)); lin=$((lin + $(nlines "$dest/$f"))); nos=$((nos + $(nossas "$base" "$dest/$f")))
            else
                sp=$((sp + 1)); sem_par="$sem_par$name/$f, só no payload"$'\n'
            fi
        done < <(cd "$dest" 2>/dev/null && find . -type f | sed 's|^\./||' | LC_ALL=C sort)

        # lado do pin: strip, ou sem par quando sumiu do payload
        while IFS= read -r f; do
            [ -n "$f" ] || continue
            is_listed "$f" "$keep" && continue
            if is_listed "$f" "$strip"; then s=$((s + 1)); continue; fi
            [ -f "$dest/$f" ] || { sp=$((sp + 1)); sem_par="$sem_par$name/$f, só no pin"$'\n'; }
        done < <(tree_files "$sub" "$pin" "$path")

        printf '%-26s %5s %7s %6s %5s %5s %5s %7s\n' "$name" "$arq" "$lin" "$nos" "$k" "$e" "$s" "$sp"
        t_sk=$((t_sk + 1))
        if [ -n "$path" ]; then t_arvore=$((t_arvore + 1)); else sem_arvore="$sem_arvore $name"; fi
        t_arq=$((t_arq + arq)); t_lin=$((t_lin + lin)); t_nos=$((t_nos + nos))
        [ "$nos" -eq 1 ] && t_um=$((t_um + 1))
        t_k=$((t_k + k)); t_kl=$((t_kl + kl))
        t_e=$((t_e + e)); t_el=$((t_el + el)); t_en=$((t_en + en))
        t_s=$((t_s + s)); t_sp=$((t_sp + sp))
    done < <(manifest_rows)
    rm -f "$base"

    echo
    printf 'skills vendored             %s (%s com árvore no upstream; só keep e extra:%s)\n' "$t_sk" "$t_arvore" "$sem_arvore"
    printf 'pareados                    %s arquivos · %s linhas\n' "$t_arq" "$t_lin"
    printf 'linhas nossas               %s — %s%%\n' "$t_nos" \
        "$(awk -v n="$t_nos" -v d="$t_lin" 'BEGIN { if (d) printf "%.2f", 100 * n / d; else printf "0" }' | tr . ,)"
    printf 'skills com 1 linha nossa    %s\n' "$t_um"
    printf 'keep, à parte               %s arquivos · %s linhas\n' "$t_k" "$t_kl"
    printf 'extra, à parte              %s arquivos · %s linhas · %s nossas\n' "$t_e" "$t_el" "$t_en"
    printf 'strip, fora                 %s arquivos\n' "$t_s"
    printf 'sem par, fora               %s arquivos\n' "$t_sp"
    printf '%s' "$sem_par" | sed 's/^/  /'
    [ "$erros" -eq 0 ] || { echo "stats: $erros skill(s) sem o pin no submodule — números incompletos"; return 1; }
}

# --- despacho -----------------------------------------------------------------

usage() {
    sed -n '3,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

case "${1:-status}" in
    status) cmd_status ;;
    pull)   cmd_pull ;;
    vendor) shift; cmd_vendor "$@" ;;
    update) shift; cmd_update "$@" ;;
    verify) cmd_verify ;;
    lock)   gerar_lock ;;
    stats)  cmd_stats ;;
    -h|--help) usage ;;
    *) echo "subcomando desconhecido: $1" >&2; usage >&2; exit 2 ;;
esac
