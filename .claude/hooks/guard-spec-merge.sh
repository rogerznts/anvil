#!/usr/bin/env bash
# guard-spec-merge.sh — hook PreToolUse/Bash que chama o validate.sh.
#
# Existe porque uma spec do mosk chegou ao branch padrão sem archive, com o
# verificador instalado, correto e nunca invocado. Uma garantia sem chamador tem
# a força de uma prosa e o custo de um programa.
#
# Bloqueia (exit 2) a INVOCAÇÃO de merge/PR quando a spec do branch tem ticket
# sem `Status: resolved`, ou quando ela ainda não foi arquivada. Cobre GitHub
# (`gh`), Gitea (`tea`) e `git merge`.
#
# As duas metades importam. Fechar os tickets e deixar a spec em `docs/specs/`
# é o caso do mosk de novo, um passo adiante: a spec chega ao branch padrão sem
# archive, e não sobra branch onde arquivar sem abrir um segundo PR. Por isso o
# `/anvil-docs archive` roda ANTES do `tea pr create`, no mesmo branch.
#
# --- Postura: fail-CLOSED -----------------------------------------------------
#
# A pergunta natural — "isto é uma invocação?" — produz uma blocklist, e
# blocklist erra por omissão. A security review do mosk encontrou SETE formas que
# passavam: newline separando comandos, prefixo de env, caminho absoluto,
# `command`, e três variantes de heredoc. Três delas acontecem sem nenhuma
# intenção de burlar.
#
# A pergunta foi invertida:
#
#   1. Se o comando não menciona nenhum dos verbos, ignora. Substring, barato.
#   2. Se menciona, a resposta padrão é VERIFICAR. Só ignora quando conseguir
#      PROVAR que toda ocorrência é menção — texto dentro de string ou corpo de
#      heredoc — e nunca tokens adjacentes de comando.
#   3. Qualquer coisa que impeça a prova (sem python3, parse falhando) resulta em
#      VERIFICAR, não em ignorar.
#
# O custo é falso positivo: escrever *sobre* `gh pr merge` num branch de spec
# aberta dispara a verificação. É barato — a mensagem diz o que falta — e é o
# lado certo para errar num controle.

set -u
INPUT="$(cat)"

# --- 1. filtro barato ---------------------------------------------------------
# `|| exit 0` seria fail-open: grep ausente devolve 127, indistinguível de "não
# encontrou" (1). Só o 1 significa ausência; qualquer outro código verifica.
printf '%s' "$INPUT" | grep -qE '(gh|tea)[^"]{0,4}(pr|pull)|git[^"]{0,4}merge'
GREP_RC=$?
if [ "$GREP_RC" -eq 1 ]; then
    [ "${GUARD_DECIDE_ONLY:-0}" = "1" ] && echo "ignora"
    exit 0
fi
if [ "$GREP_RC" -ne 0 ]; then
    echo "guard-spec-merge: grep indisponivel (rc=$GREP_RC) — verificando por precaucao." >&2
fi

# --- 2. tentar provar que é apenas menção -------------------------------------
DECISAO="verifica"
if command -v python3 >/dev/null 2>&1; then
    # shellcheck disable=SC2016  # as aspas simples sao deliberadas: o shell nao
    # deve expandir nada dentro do codigo Python.
    DECISAO="$(printf '%s' "$INPUT" | python3 -c '
import json, re, shlex, sys

def bail():
    # Na dúvida, verifica. Nunca ignora por falta de prova.
    print("verifica"); sys.exit(0)

try:
    cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")
except Exception:
    bail()

if not cmd:
    print("ignora"); sys.exit(0)

# Remove o CORPO de cada heredoc — ali é dado, não comando. Cortar no primeiro
# `<<` seria errado: ele aparece dentro de string e no operador aritmético.
# Aqui o delimitador é capturado e o corte vai do fim da linha até quem fecha.
def strip_heredocs(text):
    linhas = text.split("\n")
    saida, i = [], 0
    while i < len(linhas):
        linha = linhas[i]
        m = re.search(r"<<[-~]?\s*([\"\x27]?)([A-Za-z_][A-Za-z0-9_]*)\1\s*$", linha)
        if m:
            saida.append(linha[:m.start()])
            delim = m.group(2)
            i += 1
            while i < len(linhas) and linhas[i].strip() != delim:
                i += 1
            i += 1
            continue
        saida.append(linha)
        i += 1
    return "\n".join(saida)

cmd = strip_heredocs(cmd)

try:
    lexer = shlex.shlex(cmd, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    tokens = list(lexer)
except Exception:
    bail()

# posix=True desempacota strings: `echo "gh pr merge"` vira UM token com espaços
# dentro, que nunca casa uma sequência de tokens adjacentes. É isso que separa
# menção de invocação, sem precisar saber onde a string começou.
def nome(tok):
    return tok.rsplit("/", 1)[-1]   # /usr/bin/gh e gh são o mesmo comando

# Conjuntos, não tuplas fixas: `tea` aceita pulls|pull|pr para o mesmo comando e
# create|c / merge|m como ações, o que daria doze tuplas só para ele. Enumerar
# tupla a tupla é como o guardrail do mosk perdeu `tea pr create` inteiro.
FERRAMENTAS = {"gh", "tea"}
SUB_PR = {"pr", "pulls", "pull"}
ACOES = {"create", "c", "merge", "m"}

for i, tok in enumerate(tokens):
    base = nome(tok)
    if base == "git" and tokens[i + 1 : i + 2] == ["merge"]:
        print("verifica"); sys.exit(0)
    if base in FERRAMENTAS:
        resto = tokens[i + 1 : i + 3]
        if len(resto) == 2 and resto[0] in SUB_PR and resto[1] in ACOES:
            print("verifica"); sys.exit(0)

print("ignora")
' 2>/dev/null)"
    [ -n "$DECISAO" ] || DECISAO="verifica"
else
    echo "guard-spec-merge: python3 indisponivel — verificando por precaucao." >&2
fi

# Modo de teste: imprime a decisão e sai, sem chamar o validate. Existe para que
# as fixtures cubram o lado que importa — o falso negativo — sem recursão.
if [ "${GUARD_DECIDE_ONLY:-0}" = "1" ]; then
    echo "$DECISAO"
    exit 0
fi

[ "$DECISAO" = "verifica" ] || exit 0

# --- 3. verificar -------------------------------------------------------------
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
if [ -z "$ROOT" ]; then
    echo "guard-spec-merge: raiz do repositorio nao resolvida — nao foi possivel verificar." >&2
    exit 0
fi

VALIDATE="$ROOT/.claude/skills/anvil-docs/scripts/validate.sh"
if [ ! -f "$VALIDATE" ]; then
    echo "guard-spec-merge: validate.sh nao encontrado — nao foi possivel verificar." >&2
    exit 0
fi

if OUT="$(bash "$VALIDATE" ship-ready 2>&1)"; then
    exit 0
fi

cat >&2 <<'CABECALHO'
Bloqueado: a spec deste branch nao esta pronta para o merge.
CABECALHO
printf '\n%s\n\n' "$OUT" >&2
cat >&2 <<'RODAPE'
A ordem e: todo ticket em Status: resolved, depois /anvil-docs archive, depois o
PR. O move para archive/ precisa de um commit, e este branch e o ultimo lugar
onde esse commit cabe.
Para conferir: bash .claude/skills/anvil-docs/scripts/validate.sh ship-ready
RODAPE
exit 2
