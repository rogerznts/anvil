# 04: Reproduzir a falha do `--no-isolate` num Payload sem customização

**What to build:** Um veredito sobre de quem é a fragilidade que o `--no-isolate` introduz: do Payload, do plugin multi-tenant ou da customização de um projeto. Monta-se em `workspace/` um projeto Payload sem pós-processamento próprio, com o plugin multi-tenant e uma suíte de teste que importe as coleções. Roda-se `--no-isolate --sequence.shuffle` várias vezes, com e sem o plugin, e o controle positivo é `--sequence.shuffle` com isolamento, que precisa sair verde. O veredito, com as rodadas e o controle, fica registrado em `## Comments` — para que ninguém repita o teste.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] Projeto Payload sem customização em `workspace/`, com e sem o plugin multi-tenant.
- [ ] Controle positivo: `--sequence.shuffle` com isolamento sai verde em todas as rodadas.
- [ ] `--no-isolate --sequence.shuffle` rodado várias vezes em cada configuração, com o número de rodadas e de falhas registrado.
- [ ] Veredito em `## Comments`: reproduz sem o plugin, reproduz só com o plugin, ou não reproduz — com a causa observada quando reproduz.
