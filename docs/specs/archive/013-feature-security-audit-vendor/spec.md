# 013 — A auditoria de segurança da Cloudflare entra vendorizada

**Status:** ready-for-agent

Entrada `security-audit-vendor` do roteiro (`docs/specs/roadmap.md`). A decisão de
arquitetura é o ADR-0015 — a auditoria de segurança é a `security-audit` da
Cloudflare, vendorizada como `anvil-security-audit`.

## Problem Statement

Quem usa o anvil num projeto não tem como pedir uma auditoria de segurança do
código com método: o toolkit não traz nenhuma skill de segurança. A Cloudflare
publica, sob MIT, uma auditoria por código-fonte em seis fases, com coverage
ledger, validação adversarial e achados validados por schema, mas ela só chega ao
projeto instalada à parte, sem pin, sem sync e fora da curadoria do anvil.

## Solution

A `security-audit` entra no payload como skill vendorizada, `anvil-security-audit`:
o repositório da Cloudflare vira upstream em `references/`, com pin e sync 3-way,
a pasta da skill é copiada inteira pelo `vendor-sync.sh`, os validadores e os
testes vêm junto, a origem e a licença ficam num `VENDOR.md`, e a skill entra no
roster do `dev-link.sh`. Quem instala o anvil recebe a skill como qualquer outra,
e o modo guidance responde a perguntas de segurança sem escrever arquivo.

## User Stories

1. Como usuário do anvil, quero pedir "faça uma auditoria de segurança deste repositório", para que o agente rode as seis fases da Cloudflare sem eu instalar nada à parte.
2. Como usuário do anvil, quero fazer uma pergunta de segurança pontual e receber orientação sem que a skill crie diretório nem artefato, para não ter efeito colateral numa pergunta.
3. Como usuário do anvil, quero que a auditoria grave os artefatos fora do repositório auditado, como o upstream manda, para que nenhum achado sem correção vá parar no git.
4. Como mantenedor do anvil, quero o repositório da Cloudflare como submodule com pin em `references/`, para que o `vendor-sync update` faça o merge 3-way quando o upstream andar.
5. Como mantenedor do anvil, quero a fonte registrada em `sources:` e a skill em `skills:` do `anvil-skills.yaml`, para que o `status` mostre o que andou no upstream desde o pin.
6. Como mantenedor do anvil, quero a skill copiada pelo `vendor-sync.sh vendor`, e não à mão, para que o pin e o `anvil.lock` saiam do mesmo passo que a cópia.
7. Como mantenedor do anvil, quero o `rename` para `anvil-security-audit` como única adaptação, para que o conteúdo seja o do upstream e o sync não traga conflito artificial.
8. Como mantenedor do anvil, quero que a skill continue invocável pelo modelo, sem `invocable`, porque o upstream já não tem trava e o modo guidance é o padrão dela.
9. Como mantenedor do anvil, quero o `report-schema.json`, os dois validadores `.cjs` e os dois `*.test.cjs` na cópia, para que a skill funcione completa e a cópia prove, depois de cada sync, que os validadores passam.
10. Como mantenedor do anvil, quero rodar `node --test` sobre os `*.test.cjs` da cópia no payload e vê-los passar, para saber que a cópia não quebrou nenhum caminho relativo.
11. Como mantenedor do anvil, quero um `VENDOR.md` na skill, em `keep:`, com a origem, o pin de referência e o aviso de copyright e a permissão da MIT, para cumprir a licença e para que o sync não o apague.
12. Como mantenedor do anvil, quero o `README.md` da raiz do upstream fora da cópia, porque ele está fora da pasta da skill e descreve instalação pelo Skills CLI, que não é o caminho do anvil.
13. Como mantenedor do anvil, quero o `vendor-sync.sh verify` saindo 0 com a skill nova, para que o payload continue íntegro: `name:` igual ao diretório, links relativos válidos, sem token da denylist, lock em dia.
14. Como mantenedor do anvil, quero `anvil-security-audit` no `ROSTER` do `dev-link.sh`, para que, nesta máquina, a skill apareça ligada em `~/.claude/skills/` e no espelho do omp.
15. Como leitor do README, quero a skill na tabela de skills com a origem `cloudflare`, e a Cloudflare entre os upstreams, para saber de onde ela vem.
16. Como leitor da documentação do anvil, quero o ADR-0015 explicando por que a auditoria é vendorizada e grava fora do repositório, para não "corrigir" isso depois.
17. Como usuário do omp, quero a skill disponível pelo espelho `~/.agents/skills`, sem entrada na camada omp, porque ela não depende de nada específico do harness.

## Implementation Decisions

- **Upstream novo.** O repositório `https://github.com/cloudflare/security-audit-skill.git` entra como submodule em `references/`, num diretório próprio, e como fonte `cloudflare` em `sources:`. O `vendor-sync.sh` não cria submodule: o `git submodule add` é feito à mão, antes do `vendor`.
- **Entrada da skill no manifesto.** `name: anvil-security-audit`, `source: cloudflare`, `path: skills/security-audit`, `state: planned` até o `vendor`, `adapt: [rename]`, `keep: [VENDOR.md]`. Sem `strip`: a pasta inteira é copiada, testes inclusos. O `README.md` e o `LICENSE` da raiz ficam de fora por estarem fora do `path`, e não por `strip`.
- **Sem adaptação de julgamento.** O conteúdo não cita glossário, ADR, tracker ou perfil de verificação do anvil; o `docs-remap`, o `decursor`, o `tracker-profile` e o `verification-profile` não se aplicam. O diretório de saída da auditoria, `~/security-audit-skill/<repo>/run-<N>`, fica como está: está fora do alcance do catálogo (ADR-0015).
- **`rename`.** Só o `name:` do frontmatter muda, de `security-audit` para `anvil-security-audit`, como o script faz. Menções ao nome no corpo ficam como estão.
- **`VENDOR.md`.** Arquivo do anvil dentro da skill, em `keep:`, com a URL do upstream, o caminho da pasta, a regra de adaptação aplicada e o texto da licença MIT do upstream, que inclui o aviso de copyright.
- **Roster.** `anvil-security-audit` entra na lista `ROSTER` do `dev-link.sh`. Nenhuma mudança na camada omp nem no `anvil-update`.
- **README.** A skill entra na tabela de skills, com a origem `cloudflare`; a Cloudflare entra onde o README lista os upstreams.

## Testing Decisions

- O seam é um só: a cópia no payload, `anvil/.claude/skills/anvil-security-audit/`. Tudo o que importa se observa ali, sem mock.
- O `Pronto quando:` da entrada é o critério de aceite, como está: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0, `node --test` sobre os `*.test.cjs` da cópia em `anvil/.claude/skills/anvil-security-audit/` passa, e `anvil-security-audit` aparece ligada em `~/.claude/skills/` depois do `dev-link.sh`.
- Os testes são os do upstream, sem teste novo do anvil: eles cobrem o comportamento dos validadores, e rodá-los sobre a cópia prova que a cópia funciona. Precedente: o `anvil-bench` traz scripts Node do `unlazy` no payload.
- O `vendor-sync.sh status` mostra a skill nova com o pin igual ao HEAD do submodule.

## Out of Scope

- Qualquer mudança no conteúdo do upstream fora do catálogo de adaptação, incluindo o diretório de saída da auditoria.
- O `README.md` da raiz do upstream.
- A sugestão da auditoria no `anvil-boot`.
- Checklist de segurança como capacidade de stack.
- O registro da auditoria versionado em `docs/security/`: é a entrada `security-audit-record` do roteiro.

## Further Notes

- O upstream exige um sandbox imposto pelo sistema operacional para executar código do alvo; sem ele, a skill mantém o achado como `needs_validation`. O anvil não provê o sandbox.
- Os testes do upstream rodam com Node, sem dependência; o ambiente tem Node 25.
