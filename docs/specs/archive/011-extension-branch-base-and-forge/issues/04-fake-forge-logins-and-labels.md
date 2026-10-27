# 04: O forge falso responde logins e rótulos

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=e1aab35; scope=full; verdict=pass; p1=none

**What to build:** o forge falso do helper de prova passa a responder o que as
skills neutras perguntam antes de abrir o PR: a lista de logins do `tea`, que a
prova configura, e a lista de rótulos dos dois CLIs.

- [x] A prova configura os logins do `tea` falso (nome, `url`, `ssh_host`, padrão),
      e o `tea login list --output json` os devolve no formato do `tea` real, com
      `name`, `url`, `ssh_host`, `user` e `default`.
- [x] O `gh label list` e o `tea labels list` falsos devolvem uma lista de rótulos
      que a prova configura, com um padrão quando ela não configura.
- [x] Cada chamada continua no log do forge, com argumentos e diretório.
- [x] O cabeçalho do helper e a seção "Helper de prova" da `anvil-sync` dizem as
      opções novas.
- [x] Prova S1, num diretório novo de `workspace/`, com
      `workspace/61-bare-remote-forge/` como prior art: os logins configurados no
      formato do `tea`; os rótulos dos dois CLIs; as S1 dos tickets 01 a 04 e 10 da
      010 continuam passando.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · as opções novas do `proof_prepare` são `--tea-login
  <nome>,<url>,<ssh_host>,<padrão>`, uma vez por login, e `--labels
  <rótulo>,<rótulo>…`, uma vez só e vazia para o repositório sem rótulo; as duas
  pedem `--forge`, e a forma errada sai `2` antes de criar o diretório da execução.
  O formato do `tea` real foi medido no `tea` 0.16.0 da máquina, num `HOME`
  temporário e com um servidor http local no lugar do Gitea
  (`workspace/72-forge-logins-labels/real/capturar.sh`): o `default` sai como
  string `"true"`/`"false"`, e o login sem `ssh_host` sai com o host:porta do `url`
  — o falso faz o mesmo. O `user`, que o ticket não manda configurar, é `prova`.
- Implementação · o `tea labels list` falso dá a tabela do `tea` real (o formato
  padrão, sem `--output`) e o `--output json`; o `gh label list` dá a saída sem TTY
  (nome, descrição e `#cor` por tabulação) e o `--json` com `name`, `color` e
  `description`. A forma que o falso não sabe dar — `--jq`, `--template` e `--web`
  do `gh`, outro campo do `--json`, outro `--output` do `tea` — sai `1` com o motivo,
  em vez de uma resposta que o CLI real não daria. O formato do `gh` vem do código do
  `gh label list`, e não de captura: sem servidor do GitHub, não se mede aqui. Sem
  `--labels`, os rótulos são os de um repositório novo do GitHub, nos dois CLIs.
- Implementação · S1 em `workspace/72-forge-logins-labels/`, no bash 5.2 e no
  `/bin/bash` 3.2: vermelho antes, em `s1-red.out`; verde depois, em `s1.out`. A
  tabela e o JSON do `tea` esperados são as saídas do `tea` real em `real/`. As S1 da
  010 estão em `s1-anteriores.out`, antes e depois: 60, 61, 62 e 67 passam; a do
  ticket 01 (`workspace/59-proof-helper/`) falha a mesma conferência antes e depois
  deste ticket, a que exige `tea-open-pr` no payload, nome que o ticket 02 desta spec
  trocou por `anvil-open-pr`. A falha não é deste ticket, e reescrever a prova antiga
  fica fora do escopo da spec.
- Review round=1 · P2 (Spec): o critério das S1 da 010 está marcado, mas a S1 de `workspace/59-proof-helper/` falha antes e depois deste diff, pela troca de `tea-open-pr` do ticket 02 — quem ler só a caixa acha que as cinco passam, e a prova 59 segue quebrada sem ticket que a corrija.
- Review round=1 · P2 (Spec): o formato do `gh label list` falso vem do código do `gh`, não de captura, e o S1 o compara com um valor que ele mesmo declara — se o `gh` real divergir, as S2 validam as skills contra uma resposta que o GitHub não dá.
- Review round=1 · P3 (Spec): `--search` e `--limit` do `gh label list` são ignorados sem aviso, apesar da regra de sair `1` na forma que o falso não sabe dar — uma prova futura que os use passaria contra uma resposta impossível.
- Review round=1 · P3 (Spec/Standards): `gh label list --json` sem campos sai `1` com a mensagem "não tem ;", com o campo vazio — quem lê o stderr não descobre o que errou.
- Review round=1 · P3 (Standards): o `except FileNotFoundError` de `tea_logins` nunca roda, porque o `--forge` sempre grava `forge-tea-logins`, enquanto `forge-labels` só existe com `--labels` — duas convenções para "configurado ou não" confundem quem mantém.
- Review round=1 · P3 (Standards): `has_flag` e `option` repetem a regra de reconhecer uma opção (Duplicated Code) — mudar a forma aceita num só lugar faz o falso detectar a flag e ler o valor de jeitos diferentes.
- Review round=1 · P3 (Standards): o `--json` e as seis recusas do `gh label list` vão além do que alguma skill chama hoje (Speculative Generality, aceitável pelo ticket) — superfície a manter sem prova fora da S1.
- Review round=1 · P3 (Standards): a docstring do `proof-forge.py` não diz que `tea logins` e `tea login ls` também respondem — o contrato descreve menos do que o código faz.
- Review round=1 · P3 (Standards): a cascata de `tool == … and args[:1] in …` no `main` repete o mesmo despacho (Repeated Switches), uma linha passa de 150 colunas — cada verbo novo do forge a alonga.
