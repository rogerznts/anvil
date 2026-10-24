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

com <repo> o do --repo, ou fake/fixture, e <n> a contagem dos pr create desta
ferramenta na execução. As outras chamadas saem 0 sem efeito.
"""
import json
import os
import subprocess
import sys


def option(args, *names):
    for i, a in enumerate(args):
        for n in names:
            if a == n and i + 1 < len(args):
                return args[i + 1]
            if n.startswith('--') and a.startswith(n + '='):
                return a[len(n) + 1:]
    return None


def is_pr_create(args):
    return args[:2] == ['pr', 'create']


def current_branch():
    r = subprocess.run(['git', 'symbolic-ref', '-q', '--short', 'HEAD'], capture_output=True, text=True)
    return r.stdout.strip()


def main():
    tool = os.path.basename(sys.argv[0])
    args = sys.argv[1:]
    log = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(sys.argv[0]))), 'forge.jsonl')
    with open(log, encoding='utf-8') as f:
        calls = [json.loads(line) for line in f if line.strip()]
    with open(log, 'a', encoding='utf-8') as f:
        f.write(json.dumps({'tool': tool, 'argv': args, 'cwd': os.getcwd()}, ensure_ascii=False) + '\n')
    if not is_pr_create(args):
        return 0
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


if __name__ == '__main__':
    sys.exit(main())
