#!/usr/bin/env python3
"""Veredito da prova, chamado pelo proof_verdict do helper de prova (proof.sh).
Não se roda à mão.

    proof-verdict.py <modelo pedido> <saídas> <código das conferências>

Lê toda mensagem do assistente em <saídas>/session.jsonl e em
<saídas>/subagents/*.jsonl. Uma mensagem é do modelo pedido quando ele é o
<provider>/<model> dela ou só o <model>. Imprime, e grava em <saídas>/verdict.txt,
os modelos de cada sessão com a contagem de mensagens, a sessão cuja última
mensagem do assistente terminou em erro do provedor, com a mensagem de erro, e o
total por modelo. O verdict.txt é escrito por último: sem ele, o veredito falhou.

Sai com o código da prova: 3, inválida, sobre o verde e sobre o vermelho, quando a
sessão principal tem mensagem de outro modelo que não o pedido, ou quando um
subagente tem mais de um modelo; o subagente com um modelo só, do começo ao fim,
ainda que não o pedido, é o modelo próprio dele, e não invalida. Senão, o código
das conferências, 0 ou 1.
"""
import collections
import glob
import json
import os
import sys

INVALID = 3


def read_session(path):
    """Devolve (Counter de <provider>/<model> por mensagem do assistente, a
    mensagem de erro do provedor da última mensagem do assistente ou None)."""
    models = collections.Counter()
    last = None
    with open(path, encoding='utf-8') as f:
        for line in f:
            try:
                entry = json.loads(line)
            except ValueError:
                continue
            if not isinstance(entry, dict) or entry.get('type') != 'message':
                continue
            message = entry.get('message')
            if not isinstance(message, dict) or message.get('role') != 'assistant':
                continue
            models['%s/%s' % (message.get('provider'), message.get('model'))] += 1
            last = message
    error = None
    if last is not None and last.get('stopReason') == 'error':
        error = last.get('errorMessage') or '(sem mensagem de erro)'
    return models, error


def describe(models):
    return ', '.join('%s (%d %s)' % (m, n, 'mensagem' if n == 1 else 'mensagens')
                     for m, n in models.most_common()) or 'nenhum'


def main():
    requested, out, code = sys.argv[1], sys.argv[2], int(sys.argv[3])
    main_session = os.path.join(out, 'session.jsonl')
    sessions = [main_session] + sorted(glob.glob(os.path.join(out, 'subagents', '*.jsonl')))
    total = collections.Counter()
    lines = ['proof: modelo pedido: %s' % requested]
    reasons = []
    for path in sessions:
        models, error = read_session(path)
        name = os.path.relpath(path, out)
        lines.append('proof: %s: %s' % (name, describe(models)))
        if error is not None:
            lines.append('proof: %s: terminou em erro do provedor: %s' % (name, error))
        total.update(models)
        if path == main_session:
            others = [m for m in models if m != requested and m.split('/', 1)[-1] != requested]
            if others:
                reasons.append('a sessão principal, %s, teve mensagem de %s' % (name, ', '.join(others)))
        elif len(models) > 1:
            reasons.append('o subagente %s trocou de modelo' % name)
    lines.append('proof: respondeu %s' % describe(total))
    if reasons:
        code = INVALID
        lines.append('proof: código 3, prova inválida: %s' % '; '.join(reasons))
    else:
        lines.append('proof: código %d, %s' % (code, 'verde' if code == 0 else 'vermelho'))
    report = '\n'.join(lines) + '\n'
    sys.stdout.write(report)
    with open(os.path.join(out, 'verdict.txt'), 'w', encoding='utf-8') as f:
        f.write(report)
    return code


if __name__ == '__main__':
    sys.exit(main())
