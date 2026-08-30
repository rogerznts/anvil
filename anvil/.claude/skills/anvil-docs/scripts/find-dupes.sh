#!/usr/bin/env bash
# find-dupes.sh — acha conteúdo duplicado em docs/.
#
#   find-dupes.sh [<dir>]        # default: docs/
#
# Existe porque "tome cuidado para não duplicar" é prosa, e prosa não pega
# duplicata. O `adopt` move dezenas de arquivos entre pastas; a mesma story
# costuma existir numa cópia global e noutra local, e fatiar um monolito sem
# apagar a origem deixa o conteúdo em dois lugares. Nenhum desses erros se vê
# lendo um arquivo por vez — só comparando todos.
#
# Duplicata em documentação é pior que ausência: um ticket repetido passa na
# revisão como trabalho pendente que já foi feito, e uma decisão em dois
# arquivos diverge em silêncio quando alguém edita um só.
#
# O script LISTA os candidatos. Decidir se são mesmo a mesma coisa é julgamento,
# e continua sendo do agente — mas agora ele lê uma lista em vez de precisar
# reparar sozinho.
#
# Sai 1 quando acha candidato, 0 quando não acha.

set -uo pipefail
DIR="${1:-docs}"
[ -d "$DIR" ] || { echo "nada a checar: $DIR não existe"; exit 0; }

python3 - "$DIR" <<'PY'
import hashlib, os, re, sys
from collections import defaultdict

raiz = sys.argv[1]
arquivos = []
for r, ds, fs in os.walk(raiz):
    ds[:] = [d for d in ds if d not in ('.git', 'node_modules')]
    for f in fs:
        if f.endswith('.md'):
            arquivos.append(os.path.join(r, f))

def corpo(p):
    t = open(p, encoding='utf-8', errors='replace').read()
    return re.sub(r'^---\n.*?\n---\n', '', t, flags=re.S)  # ignora front-matter

def titulo(p):
    for l in corpo(p).splitlines():
        if l.startswith('# '):
            return l[2:].strip().lower()
    return None

# Identificador de artefato: o que o layout antigo usava para amarrar story,
# tarefa e decisão. Vem do NOME e do TÍTULO, porque as duas cópias raramente
# têm o mesmo nome de arquivo — `US-014.md` e `US-014-exportar-csv.md`.
ID = re.compile(r'\b((?:US|T|QA|SEC|ADR|FR|NFR|SC)-?\d{1,4})\b', re.I)
def ids(p):
    fonte = os.path.basename(p) + ' ' + (titulo(p) or '')
    return {m.group(1).upper().replace('-', '') for m in ID.finditer(fonte)}

por_hash, por_id, por_titulo = defaultdict(list), defaultdict(list), defaultdict(list)
for p in arquivos:
    c = corpo(p).strip()
    if c:
        por_hash[hashlib.sha256(c.encode()).hexdigest()].append(p)
    for i in ids(p):
        por_id[i].append(p)
    t = titulo(p)
    if t:
        por_titulo[t].append(p)

achados = 0
def bloco(rotulo, grupos, nota):
    global achados
    g = {k: v for k, v in grupos.items() if len(v) > 1}
    if not g:
        return
    print(f"\n{rotulo} ({len(g)}):")
    print(f"  {nota}")
    for k, v in sorted(g.items()):
        print(f"\n  [{k}]")
        for p in sorted(v):
            print(f"    {p}")
        achados += 1

bloco("CONTEÚDO IDÊNTICO", por_hash,
      "byte a byte iguais. Uma cópia sobra — decida qual e diga qual descartou.")
bloco("MESMO IDENTIFICADOR", por_id,
      "o mesmo artefato em dois lugares. Conteúdo igual: mova um. Diferente: mostre os dois e pergunte.")
bloco("MESMO TÍTULO", por_titulo,
      "pode ser duplicata, pode ser coincidência. Abra os dois antes de decidir.")

print()
if achados:
    print(f"{achados} grupo(s) de candidato a duplicata em {len(arquivos)} arquivo(s).")
    sys.exit(1)
print(f"nenhuma duplicata em {len(arquivos)} arquivo(s).")
PY
