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
# "A spec do branch" é a do branch atual E a de cada branch que o `git merge`
# nomeia. Olhando só o atual, o merge local disparado da `main` — o jeito natural
# de mesclar — passava sem conferir nada: a `main` não tem número. `git
# cherry-pick` fica de fora de propósito: é como se integra trabalho com a spec
# ainda aberta.
#
# As duas metades importam. Fechar os tickets e deixar a spec em `docs/specs/`
# é o caso do mosk de novo, um passo adiante: a spec chega ao branch padrão sem
# archive, e não sobra branch onde arquivar sem abrir um segundo PR. Por isso o
# `/anvil-docs archive` roda ANTES do merge ou do `tea pr create`, no mesmo
# branch, e é commitado: a spec é lida do commit de cada branch, não do disco.
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
#      PROVAR que toda ocorrência é menção — texto dentro de string, corpo de
#      heredoc, comentário ou argumento de outro comando (`echo git merge`).
#   3. Qualquer coisa que impeça a prova (sem python3, parse falhando, heredoc
#      sem fim) resulta em VERIFICAR, não em ignorar. E, sem prova de quais
#      branches o merge nomeia, confere todo nome no comando com cara de branch
#      de spec.
#
# O custo é falso positivo: o que não se prova menção — `sudo echo git merge`,
# uma aspa sem par — é conferido. É barato — a mensagem diz o que falta — e é o
# lado certo para errar num controle.
#
# --- O que a guarda NÃO pega --------------------------------------------------
#
# Fail-closed vale para o parse, não para tudo o que o shell e o git fazem.
# Passam sem conferência, e ficam aqui para ninguém supor o contrário:
#
#   - comando dentro de comando: `bash -c`, `sh -c`, `eval`, backticks,
#     `"$(git merge ...)"` entre aspas e texto entregue a um shell pelo pipe ou
#     por heredoc (`echo git merge x | sh`, `bash <<EOF`). O comando ali é
#     texto, e texto é menção;
#   - branch que não está na linha: `xargs git merge` é conferido, mas o branch
#     chega pelo stdin;
#   - aspa `$'...'`, que o parse não entende: a aspa escapada dentro dela
#     desalinha as outras;
#   - merge por SHA, ou por alvo que não resolve para um branch de spec: sem
#     nome de branch não há número, e sem número não há spec;
#   - outro verbo que traz o branch da spec para a `main`: `git pull . {spec}`,
#     `git rebase {spec}` e `git reset --hard {spec}` — e o merge por alias do
#     git, que tem outro nome.

set -u
INPUT="$(cat)"

# --- 1. filtro barato ---------------------------------------------------------
# `|| exit 0` seria fail-open: grep ausente devolve 127, indistinguível de "não
# encontrou" (1). Só o 1 significa ausência; qualquer outro código verifica.
# Entre `git` e `merge` não há limite: `git -C <caminho> merge` põe ali um
# caminho de qualquer tamanho.
printf '%s' "$INPUT" | grep -qE '(gh|tea)[^"]{0,4}(pr|pull)|git.*merge'
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
# Os branches que o merge nomeia, um por linha. Até o Python provar quais são,
# vale todo nome com cara de branch de spec: o falso positivo é uma spec a mais
# conferida. `\n` e `\t` do JSON viram espaço para não grudarem no nome.
ALVOS="$(printf '%s' "$INPUT" | sed 's/\\[nt]/ /g' |
    grep -oE '([A-Za-z0-9._-]+/)*[a-z]+/[0-9]{3}-[A-Za-z0-9._/-]*')"
if command -v python3 >/dev/null 2>&1; then
    # shellcheck disable=SC2016  # as aspas simples sao deliberadas: o shell nao
    # deve expandir nada dentro do codigo Python.
    SAIDA="$(printf '%s' "$INPUT" | python3 -c '
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

# Uma passada que conhece aspas tira o que o shell não executa e o shlex não sabe
# ver: comentário, corpo de heredoc e continuação de linha. O comentário do
# shlex começa em qualquer `#` e engole o newline, e `echo a#b; git merge x`
# virava comentário inteiro.
#
# Heredoc só conta fora de aspas, e o corpo vai da linha seguinte até a do
# delimitador. O resto da linha do `<<` fica: `<<\x27EOF\x27 > f` e `<<EOF | tee f`
# são as formas comuns, e procurar o delimitador só no fim da linha as perdia.
# Heredoc sem fim não prova nada.
#
# `(` e `$(` abrem um nível novo, sem aspa: o `-m "$(cat <<\x27EOF\x27 ...)"` de
# todo commit tem o heredoc dentro das aspas duplas, e uma aspa no corpo dele não
# pode fechar a de fora.
APOSTROFO, ASPAS = "\x27", "\""
HEREDOC = re.compile(r"<<(-?)[ \t]*((?:[^\s;&|<>()\x27\"\\]|\x27[^\x27\n]*\x27|\"[^\"\n]*\"|\\.)+)")

def limpa(text):
    out, pendentes, pilha, i, n = [], [], [""], 0, len(text)
    while i < n:
        c, aspa = text[i], pilha[-1]
        m = None if aspa or c != "<" else HEREDOC.match(text, i)
        if aspa == APOSTROFO:
            pilha[-1] = "" if c == APOSTROFO else aspa
            out.append(c); i += 1
        elif c == "\\":
            if not text.startswith("\\\n", i):
                out.append(text[i:i + 2])
            i += 2
        elif text.startswith("$(", i) or (c == "(" and not aspa):
            pilha.append("")
            k = 2 if c == "$" else 1
            out.append(text[i:i + k]); i += k
        elif aspa == ASPAS:
            pilha[-1] = "" if c == ASPAS else aspa
            out.append(c); i += 1
        elif c == ")" and len(pilha) > 1:
            pilha.pop()
            out.append(c); i += 1
        elif c in (APOSTROFO, ASPAS):
            pilha[-1] = c; out.append(c); i += 1
        elif c == "#" and (not out or out[-1][-1] in " \t\n;&|()"):
            while i < n and text[i] != "\n":
                i += 1
        elif text.startswith("<<<", i):
            out.append("<<<"); i += 3
        elif m:
            pendentes.append((m.group(1), re.sub(r"[\x27\"\\]", "", m.group(2))))
            out.append(m.group(0)); i = m.end()
        elif c == "\n" and pendentes:
            out.append(c); i += 1
            for tabs, delim in pendentes:
                while True:
                    fim = text.find("\n", i)
                    linha = text[i:] if fim < 0 else text[i:fim]
                    if (linha.lstrip("\t") if tabs else linha) == delim:
                        i = n if fim < 0 else fim + 1
                        break
                    if fim < 0:
                        raise ValueError("heredoc sem fim")
                    i = fim + 1
            pendentes = []
        else:
            out.append(c); i += 1
    return "".join(out)

# O newline vira pontuação, e não espaço: ele separa comandos como o `;`.
try:
    lexer = shlex.shlex(limpa(cmd), posix=True, punctuation_chars=";&|()<>\n")
    lexer.whitespace = " \t\r"
    lexer.commenters = ""
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

# O comando simples vai do começo, ou de `;`, `&&`, `|`, `(`, newline, até o
# próximo desses, e a cabeça dele é o primeiro token depois do prefixo de env.
# Cabeça `git`, `gh` ou `tea` é conferida pelo subcomando. Qualquer outra pode
# executar o resto — `command`, `sudo`, `timeout 60`, `if`, `{` —, e aí vale
# qualquer `git` do comando simples. Só a cabeça que nunca executa os argumentos
# prova menção: em `echo git merge x`, o `git` é texto. Lista curta de
# propósito: cabeça fora dela é conferida.
PONTUACAO = set(";&|()<>\n")
SEPARA = set(";&|()\n")
MENCAO = {"echo", "printf", "grep", "egrep", "fgrep", "rg"}
ENV = re.compile(r"[A-Za-z_][A-Za-z0-9_]*=")
# Opção global do git que leva o valor no token seguinte: `git -C . merge x` é
# um merge, e o subcomando é o primeiro token depois das opções.
GIT_VALOR = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
             "--super-prefix", "--config-env", "--attr-source"}

def pontuacao(tok):
    return tok != "" and set(tok) <= PONTUACAO

comandos, atual = [], []
for tok in tokens:
    if pontuacao(tok) and set(tok) & SEPARA:
        comandos.append(atual); atual = []
    else:
        atual.append(tok)
comandos.append(atual)

# Redirecionamento (`>`, `2>&1`) encerra os alvos. Opção (`--no-ff`, `-m`) não é
# branch — `-` sozinho é, o anterior; o valor dela entra na lista, e o validate
# descarta o que não é branch de spec.
verifica, alvos = False, []
for palavras in comandos:
    j = 0
    while j < len(palavras) and ENV.match(palavras[j]):
        j += 1
    if j == len(palavras) or nome(palavras[j]) in MENCAO:
        continue
    cabeca = nome(palavras[j])
    for k in ([j] if cabeca in FERRAMENTAS | {"git"} else range(j, len(palavras))):
        base = nome(palavras[k])
        if base == "git":
            s = k + 1
            while s < len(palavras) and palavras[s].startswith("-"):
                s += 2 if palavras[s] in GIT_VALOR else 1
            if palavras[s : s + 1] == ["merge"]:
                verifica = True
                for arg in palavras[s + 1 :]:
                    if pontuacao(arg):
                        break
                    if arg == "-" or not arg.startswith("-"):
                        alvos.append(arg)
        if base in FERRAMENTAS:
            resto = palavras[k + 1 : k + 3]
            if len(resto) == 2 and resto[0] in SUB_PR and resto[1] in ACOES:
                verifica = True

# `alvos` na segunda linha é a prova de que a lista saiu do parse. Sem ela, vale
# a lista larga montada pelo shell.
if verifica:
    print("verifica"); print("alvos"); print("\n".join(alvos))
else:
    print("ignora")
' 2>/dev/null)"
    DECISAO="${SAIDA%%$'\n'*}"
    case "$SAIDA" in *$'\n'alvos*) ALVOS="${SAIDA#*$'\n'alvos}" ;; esac
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

set --
while IFS= read -r alvo; do
    [ -n "$alvo" ] && set -- "$@" "$alvo"
done <<EOF
$ALVOS
EOF

if OUT="$(bash "$VALIDATE" ship-ready "$@" 2>&1)"; then
    exit 0
fi

cat >&2 <<'CABECALHO'
Bloqueado: a spec deste branch, ou a do branch mesclado, nao esta pronta para o
merge.
CABECALHO
printf '\n%s\n\n' "$OUT" >&2
cat >&2 <<'RODAPE'
A ordem e: todo ticket em Status: resolved, depois /anvil-docs archive, os dois
commitados no branch da spec, depois o merge ou o PR. A guarda le a spec do
commit de cada branch, nao do disco: o que nao foi commitado nao conta.
Para conferir: bash .claude/skills/anvil-docs/scripts/validate.sh ship-ready [branch...]
RODAPE
exit 2
