#!/usr/bin/env python3
"""O gh e o tea falsos da opção --forge do helper de prova (proof.sh). Não se roda à
mão: o proof_prepare liga <execução>/forge/gh e <execução>/forge/tea a este arquivo,
e a ferramenta é o nome pelo qual ele foi chamado.

Cada chamada grava uma linha em <execução>/forge.jsonl, com a ferramenta, os
argumentos e o diretório: {"tool": "gh", "argv": [...], "cwd": "..."}. Responde
como no sucesso, sem servidor:

- gh pr create imprime no stdout a URL do PR, https://github.com/<repo>/pull/<n>;
- tea pr create --output json imprime o objeto com index, title, url, state, base e
  head, a base sendo main quando não vem --base, e o head, o branch atual quando
  não vem --head;
- tea login list --output json (ou -o json) imprime os logins que a prova configurou
  com --tea-login, no formato do tea real: a lista com name, url, ssh_host, user e
  default, o default como "true" ou "false", o ssh_host vazio dando o host:porta do
  url, como o tea faz, e o user, prova; sem --tea-login, a lista vazia;
- gh label list (ou ls) imprime os rótulos como o gh sem TTY, uma linha por rótulo com
  nome, descrição e #cor separados por tabulação, e nada quando não há rótulo; com
  --json <campos>, entre name, color e description, a lista compacta com as chaves em
  ordem;
- tea labels list (ou label, ou ls, ou sem o list) imprime os rótulos na tabela do tea
  real, com Index, Color, Name, Description e Level; com --output json, a lista do tea
  real;

com <repo> o do --repo, ou fake/fixture, e <n> a contagem dos pr create desta
ferramenta na execução. Os rótulos são os que a prova configurou com --labels, na cor
ededed e sem descrição, ou, sem --labels, os que o GitHub cria num repositório novo.
A forma de listar rótulos que este arquivo não sabe dar — o --jq, o --template e o
--web do gh, campo do --json fora dos três, outro --output do tea — sai 1 com o motivo
no stderr, em vez de uma resposta que o CLI real não daria. As outras chamadas saem 0
sem efeito.
"""
import json
import os
import subprocess
import sys
from urllib.parse import urlsplit

# Os rótulos que o GitHub cria num repositório novo: nome, cor, descrição.
GH_NEW_REPO_LABELS = [
    ('bug', 'd73a4a', "Something isn't working"),
    ('documentation', '0075ca', 'Improvements or additions to documentation'),
    ('duplicate', 'cfd3d7', 'This issue or pull request already exists'),
    ('enhancement', 'a2eeef', 'New feature or request'),
    ('good first issue', '7057ff', 'Good for newcomers'),
    ('help wanted', '008672', 'Extra attention is needed'),
    ('invalid', 'e4e669', "This doesn't seem right"),
    ('question', 'd876e3', 'Further information is requested'),
    ('wontfix', 'ffffff', 'This will not be worked on'),
]
CONFIGURED_LABEL_COLOR = 'ededed'
TEA_LOGIN_USER = 'prova'
GH_LABEL_FIELDS = ('name', 'color', 'description')


def option(args, *names):
    for i, a in enumerate(args):
        for n in names:
            if a == n and i + 1 < len(args):
                return args[i + 1]
            if n.startswith('--') and a.startswith(n + '='):
                return a[len(n) + 1:]
    return None


def has_flag(args, *names):
    return any(a == n or (n.startswith('--') and a.startswith(n + '=')) for a in args for n in names)


def refuse(tool, why):
    print('%s falso (proof-forge.py): %s' % (tool, why), file=sys.stderr)
    return 1


def is_pr_create(args):
    return args[:2] == ['pr', 'create']


def current_branch():
    r = subprocess.run(['git', 'symbolic-ref', '-q', '--short', 'HEAD'], capture_output=True, text=True)
    return r.stdout.strip()


def labels(run):
    """Os rótulos da execução: (nome, cor, descrição)."""
    try:
        with open(os.path.join(run, 'forge-labels'), encoding='utf-8') as f:
            raw = f.read()
    except FileNotFoundError:
        return GH_NEW_REPO_LABELS
    return [(n.strip(), CONFIGURED_LABEL_COLOR, '') for n in raw.split(',') if n.strip()]


def tea_logins(run):
    """Os logins que a prova configurou, uma linha <nome>,<url>,<ssh_host>,<padrão> cada."""
    rows = []
    try:
        with open(os.path.join(run, 'forge-tea-logins'), encoding='utf-8') as f:
            lines = [l.rstrip('\n') for l in f if l.strip()]
    except FileNotFoundError:
        lines = []
    for line in lines:
        name, url, ssh_host, default = line.split(',', 3)
        if not ssh_host:  # o tea real dá o host:porta do url
            try:
                ssh_host = urlsplit(url).netloc.rpartition('@')[2]
            except ValueError:
                ssh_host = ''
        rows.append({'name': name, 'url': url, 'ssh_host': ssh_host, 'user': TEA_LOGIN_USER, 'default': default})
    return rows


def gh_label_list(args, run):
    for flag in ('--jq', '-q', '--template', '-t', '--web', '-w'):
        if has_flag(args, flag):
            return refuse('gh', 'o gh label list falso não implementa %s' % flag)
    rows = labels(run)
    if not has_flag(args, '--json'):
        for name, color, description in rows:
            print('%s\t%s\t#%s' % (name, description, color))
        return 0
    fields = (option(args, '--json') or '').split(',')
    unknown = [f for f in fields if f not in GH_LABEL_FIELDS]
    if unknown:
        return refuse('gh', 'o --json do gh label list falso não tem %s; ele dá %s'
                      % (', '.join(unknown), ', '.join(GH_LABEL_FIELDS)))
    print(json.dumps([{f: v for f, v in zip(GH_LABEL_FIELDS, r) if f in fields} for r in rows],
                     sort_keys=True, separators=(',', ':'), ensure_ascii=False))
    return 0


def box_table(headers, rows):
    """A tabela do tea real: cabeçalho em maiúsculas centrado, células à esquerda."""
    widths = [max(len(c) for c in col) for col in zip(headers, *rows)]

    def rule(left, mid, right):
        return left + mid.join('─' * (w + 2) for w in widths) + right

    def row(cells):
        return '│' + '│'.join(' %s ' % c for c in cells) + '│'

    def center(text, width):
        extra = width - len(text)
        return ' ' * (extra // 2) + text + ' ' * (extra - extra // 2)

    out = [rule('┌', '┬', '┐'), row(center(h.upper(), w) for h, w in zip(headers, widths))]
    if rows:
        out.append(rule('├', '┼', '┤'))
        out += [row(c.ljust(w) for c, w in zip(r, widths)) for r in rows]
    out.append(rule('└', '┴', '┘'))
    return '\n'.join(out)


def tea_labels_list(args, run):
    fmt = option(args, '--output', '-o') or 'table'
    headers = ['Index', 'Color', 'Name', 'Description', 'Level']
    rows = [[str(i + 1), color, name, description, 'Repository']
            for i, (name, color, description) in enumerate(labels(run))]
    if fmt == 'table':
        print(box_table(headers, rows))
    elif fmt == 'json':
        print(json.dumps([dict(zip([h.lower() for h in headers], r)) for r in rows], indent=2, ensure_ascii=False))
    else:
        return refuse('tea', 'o tea labels list falso dá table e json, e não --output %s' % fmt)
    return 0


def pr_create(tool, args, calls):
    index = 1 + sum(1 for c in calls if c['tool'] == tool and is_pr_create(c['argv']))
    if tool == 'gh':
        print('https://github.com/%s/pull/%d' % (option(args, '--repo', '-R') or 'fake/fixture', index))
    elif tool == 'tea' and option(args, '--output', '-o') == 'json':
        repo = option(args, '--repo', '-r') or 'fake/fixture'
        print(json.dumps({
            'index': index,
            'title': option(args, '--title', '-t') or '',
            'url': 'https://gitea.example/%s/pulls/%d' % (repo, index),
            'state': 'open',
            'base': option(args, '--base', '-b') or 'main',
            'head': option(args, '--head') or current_branch(),
        }, ensure_ascii=False))
    return 0


def main():
    tool = os.path.basename(sys.argv[0])
    args = sys.argv[1:]
    run = os.path.dirname(os.path.dirname(os.path.abspath(sys.argv[0])))
    log = os.path.join(run, 'forge.jsonl')
    with open(log, encoding='utf-8') as f:
        calls = [json.loads(line) for line in f if line.strip()]
    with open(log, 'a', encoding='utf-8') as f:
        f.write(json.dumps({'tool': tool, 'argv': args, 'cwd': os.getcwd()}, ensure_ascii=False) + '\n')
    if is_pr_create(args):
        return pr_create(tool, args, calls)
    if tool == 'gh' and args[:1] == ['label'] and args[1:2] in (['list'], ['ls']):
        return gh_label_list(args[2:], run)
    if tool == 'tea' and args[:1] in (['labels'], ['label']) and (len(args) == 1 or args[1] in ('list', 'ls') or args[1].startswith('-')):
        return tea_labels_list(args[1:], run)
    if tool == 'tea' and args[:1] in (['login'], ['logins']) and args[1:2] in (['list'], ['ls']) \
            and option(args, '--output', '-o') == 'json':
        print(json.dumps(tea_logins(run), indent=2, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main())
