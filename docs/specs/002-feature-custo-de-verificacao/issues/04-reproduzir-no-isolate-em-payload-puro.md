# 04: Reproduzir a falha do `--no-isolate` num Payload sem customização

**What to build:** Um veredito sobre de quem é a fragilidade que o `--no-isolate` introduz: do Payload, do plugin multi-tenant ou da customização de um projeto. Monta-se em `workspace/` um projeto Payload sem pós-processamento próprio, com o plugin multi-tenant e uma suíte de teste que importe as coleções. Roda-se `--no-isolate --sequence.shuffle` várias vezes, com e sem o plugin, e o controle positivo é `--sequence.shuffle` com isolamento, que precisa sair verde. O veredito, com as rodadas e o controle, fica registrado em `## Comments` — para que ninguém repita o teste.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] Projeto Payload sem customização em `workspace/`, com e sem o plugin multi-tenant.
- [x] Controle positivo: `--sequence.shuffle` com isolamento sai verde em todas as rodadas.
- [x] `--no-isolate --sequence.shuffle` rodado várias vezes em cada configuração, com o número de rodadas e de falhas registrado.
- [x] Veredito em `## Comments`: reproduz sem o plugin, reproduz só com o plugin, ou não reproduz — com a causa observada quando reproduz.

## Comments

**Veredito: reproduz só com o plugin multi-tenant.** O Payload sozinho não muta
a coleção importada. Quem muta é o plugin oficial.

Montagem em `workspace/04-no-isolate/`, fora do git: `payload` e
`@payloadcms/plugin-multi-tenant` 3.90.1, `vitest` 3, sem pós-processamento
próprio. Três coleções: `users` (auth), `tenants` e `posts`, as duas últimas com
`access.read: () => false`. O plugin fica ligado por variável de ambiente, com
`collections: { posts: {} }`. Seis arquivos de teste: um importa a config, dois
importam só a coleção e chamam `access.read` direto, três são enchimento. Doze
rodadas por configuração, `--sequence.shuffle --sequence.seed=1..12`:

| configuração | falhas |
|---|---|
| isolado, com plugin — **controle positivo** | 0/12 |
| `--no-isolate`, com plugin, workers padrão | 0/12 |
| `--no-isolate`, sem plugin, workers padrão | 0/12 |
| `--no-isolate`, com plugin, **1 worker** | **8/12** |
| `--no-isolate`, sem plugin, 1 worker | 0/12 |

- **Sintoma**: `expected Promise{…} to be false`, em `tenants-access` **e** em
  `posts-access`. É o mesmo do caso original. Falha sempre que o arquivo que
  importa a config roda antes, no mesmo worker; as 4 rodadas verdes são as
  ordens em que ele roda depois.
- **Causa, lida no fonte do plugin**: `addCollectionAccess` faz
  `collection.access[key] = withTenantAccess(...)` no próprio objeto da coleção
  que a config recebeu. Esse objeto é o mesmo que o arquivo de teste importa. A
  função embrulhada é assíncrona, daí o `Promise`. O plugin faz isso com a
  coleção de tenants e com **toda** coleção habilitada para tenant.
- **A condição de sharing**: com os workers padrão (16 CPUs, 6 arquivos), cada
  arquivo cai num worker próprio e nada vaza. A falha exige mais arquivos que
  workers, que é o caso de qualquer suíte real. Uma suíte pequena pode passar
  com `--no-isolate` e quebrar quando crescer.
- **A vítima não é o culpado**: os arquivos que falham só importam a coleção. O
  culpado é o que importa a config.
