# unlazy — origem e divergências

Material de [Leonxlnx/unlazy](https://github.com/Leonxlnx/unlazy), MIT, trazido
como `extra` do `anvil-bench` pelo `anvil-skills.yaml`. O pin está no manifesto;
o `LICENSE` original está ao lado deste arquivo.

**Não edite nada aqui.** Correção de defeito vai para o upstream — volta no
próximo `update` e beneficia todo mundo. Este arquivo existe para registrar o
que diverge e por quê.

## Por que não é uma skill

A `description` do upstream dispara por linguagem natural em *"long or multi-part
task"*, que descreve o `/anvil-implement` do fluxo principal. Como skill
instalada, ela se auto-invocaria fora do bench, e o catálogo de adaptações não
dá caminho para desligar isso: `rename` cobre só o `name:`, e a `description`
fica verbatim por regra.

Por isso o `SKILL.md` do upstream é copiado como `UNLAZY.md`. O frontmatter
continua lá, inerte — mesma solução das 21 `principle-*` do pstack, que viraram
`references/` dentro do `anvil-principles`.

## O que ficou de fora

`tests/`, `.github/`, `.gitignore`, `README.md`, `CHANGELOG.md`,
`CONTRIBUTING.md`, `package.json` e `agents/`: infraestrutura do repositório
upstream, que não faz nada dentro de um payload instalado.

`scripts/install-hooks.mjs` e `scripts/stop-hook.mjs`: **o Stop hook não entra no
bench.** Ele bloqueia o fim da sessão enquanto houver gate aberto e solta sozinho
depois de seis bloqueios sem progresso (`MAX_BLOCKS = 6`). O bench já tem
condição de parada — teto de três tentativas por ticket, em [../GATE.md](../GATE.md)
— e duas condições de parada rivais na mesma sessão brigam pelo mesmo desfecho.
O `UNLAZY.md` continua descrevendo o hook, porque não editamos texto do autor;
esta é a nota que diz que aqui ele não é instalado.

## O que veio junto e não é usado

A metade de orquestração — `references/method.md`, `orchestration.md`,
`dispatch.md`, `parallel.md`, `templates/PLAN.md`, `scripts/dispatch-check.mjs` —
veio inteira porque o `UNLAZY.md` aponta para ela, e a checagem 2 do `verify`
exige que todo link relativo resolva. Deixá-la fora exigiria editar o texto do
autor, que não é uma das quatro regras do catálogo.

O bench não usa nada disso: quem decompõe é o `/anvil-to-tickets`, e quem carrega
a ordem é o `Blocked by` do ticket. Depth Tree, `PLAN.md`, waves de dispatch e
leases seriam um segundo estado em disco para a mesma coisa, e o bench não faz
fan-out paralelo.

## O que foi medido, e a regra que decorre

Contra o commit pinado, nesta máquina:

- A suíte do upstream passa inteira: 177 testes.
- `--approve` **não é interativo**. Com a entrada fechada ele aprova e executa
  sem perguntar nada. Num loop headless, quem consente é o agente.
- A evidência é texto no ledger, sem assinatura. Um ledger com `- [x]` e uma
  linha `EVIDENCE:` escrita à mão devolve `ALL MET` e sai 0 no `--status`, mesmo
  com um `CHECK:` que falha.
- Só o `--reverify` prova: ele reexecuta, derruba o gate e devolve
  `EVIDENCE: pending`.
- A aprovação morre a cada mudança de `PATH` — ela amarra o `PATH` inteiro.

**Daí a regra que o bench segue:** quem roda o `--reverify` é o **supervisor** do
loop, nunca o agente que implementou o ticket. Um agente que escreve o próprio
ledger e o confere com `--status` reproduz o `Status: resolved` auto-declarado,
com mais cerimônia e nenhuma prova a mais.

E daí também a escolha de rodar o checker **dentro do container**: o `PATH` de lá
é estável entre voltas, enquanto o do host muda sozinho e invalidaria toda
aprovação a cada execução.
