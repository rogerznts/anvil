#!/usr/bin/env python3
"""Condutor da sessão rpc do omp, chamado pelo proof_session do helper de prova
(proof.sh). Não se roda à mão.

Abre o omp em --mode rpc --no-ui, com o overlay de config, o modelo e a fixture.
Manda cada turno como frame prompt e espera o prompt_result dele e, quando o turno
chegou ao agente, o session_settled; só então manda o seguinte. Depois do último,
pede o get_state, fecha o stdin e copia o sessionFile para <out>/session.jsonl.
Grava em <out>/frames.jsonl todo frame que o omp escreveu, e em <out>/omp.err o
stderr dele.

Sai 0 com a sessão assentada e copiada; 1 quando o omp sai, recusa um comando ou
não diz o sessionFile, com o motivo no stderr. Num sinal, encerra o omp antes de
sair.
"""
import argparse
import json
import os
import shutil
import signal
import subprocess
import sys


class SessionError(Exception):
    pass


class Rpc:
    def __init__(self, proc, frames):
        self.proc = proc
        self.frames = frames

    def send(self, command):
        try:
            self.proc.stdin.write((json.dumps(command) + '\n').encode('utf-8'))
            self.proc.stdin.flush()
        except BrokenPipeError:
            raise SessionError('o omp saiu (rc=%s) antes de receber %s; veja omp.err'
                               % (self.proc.wait(), command['type']))

    def next_frame(self, waiting):
        line = self.proc.stdout.readline()
        if not line:
            raise SessionError('o omp saiu (rc=%s) esperando %s; veja omp.err' % (self.proc.wait(), waiting))
        self.frames.write(line)
        self.frames.flush()
        try:
            return json.loads(line)
        except ValueError:
            return {}

    def until(self, waiting, matches):
        while True:
            frame = self.next_frame(waiting)
            if matches(frame):
                return frame

    def turn(self, n, message):
        """Manda o turno n e devolve (agentInvoked, status) do prompt_result dele."""
        tid = 'turn-%d' % n
        self.send({'id': tid, 'type': 'prompt', 'message': message})
        while True:
            frame = self.next_frame('o prompt_result do turno %d' % n)
            if frame.get('id') != tid:
                continue
            if frame.get('type') == 'response':
                if not frame.get('success'):
                    raise SessionError('o omp recusou o turno %d: %s' % (n, frame.get('error')))
                if (frame.get('data') or {}).get('agentInvoked') is False:
                    return False, 'local'
            elif frame.get('type') == 'prompt_result':
                return bool(frame.get('agentInvoked')), frame.get('status')

    def session_file(self):
        self.send({'id': 'state', 'type': 'get_state'})
        frame = self.until('a resposta do get_state',
                           lambda f: f.get('id') == 'state' and f.get('type') == 'response')
        path = (frame.get('data') or {}).get('sessionFile')
        if not frame.get('success') or not path:
            raise SessionError('o get_state não disse o sessionFile: %s' % frame.get('error'))
        return path

    def close(self):
        """Fecha o stdin e lê o resto do stdout até o omp sair."""
        self.proc.stdin.close()
        for line in self.proc.stdout:
            self.frames.write(line)
        rc = self.proc.wait()
        if rc != 0:
            raise SessionError('o omp saiu com rc=%d ao encerrar a sessão; veja omp.err' % rc)


def stop(proc):
    if proc.poll() is None:
        proc.terminate()
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()


def exit_on_signal(signum, _frame):
    raise SystemExit(128 + signum)


def main():
    p = argparse.ArgumentParser(description='Condutor da sessão rpc do helper de prova.')
    p.add_argument('--config', required=True)
    p.add_argument('--model', required=True)
    p.add_argument('--cwd', required=True)
    p.add_argument('--session-dir', required=True)
    p.add_argument('--out', required=True)
    p.add_argument('turns', nargs='+')
    a = p.parse_args()
    for s in (signal.SIGTERM, signal.SIGHUP):
        signal.signal(s, exit_on_signal)

    out = os.path.abspath(a.out)
    cwd = os.path.abspath(a.cwd)
    command = ['omp', '--mode', 'rpc', '--no-ui', '--config', a.config, '--model', a.model,
               '--cwd', cwd, '--session-dir', os.path.abspath(a.session_dir)]
    with open(os.path.join(out, 'frames.jsonl'), 'wb') as frames, \
            open(os.path.join(out, 'omp.err'), 'wb') as err:
        proc = subprocess.Popen(command, cwd=cwd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=err)
        rpc = Rpc(proc, frames)
        try:
            rpc.until('o ready', lambda f: f.get('type') == 'ready')
            for n, message in enumerate(a.turns, 1):
                invoked, status = rpc.turn(n, message)
                print('proof: turno %d: %s' % (n, status), file=sys.stderr)
                if invoked:
                    rpc.until('o session_settled do turno %d' % n, lambda f: f.get('type') == 'session_settled')
            path = rpc.session_file()
            rpc.close()
            if not os.path.isfile(path):
                raise SessionError('o sessionFile do get_state não existe: %s' % path)
            shutil.copyfile(path, os.path.join(out, 'session.jsonl'))
        except SessionError as e:
            print('proof: %s' % e, file=sys.stderr)
            return 1
        finally:
            stop(proc)
    return 0


if __name__ == '__main__':
    sys.exit(main())
