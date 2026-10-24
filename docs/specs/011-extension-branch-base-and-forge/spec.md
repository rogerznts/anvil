# 011 — Branch base e forge neutro

**Status:** ready-for-agent

Segunda do roteiro de duas specs combinado no grill de 2026-10-23. A primeira, a
010 (`docs/specs/archive/010-extension-proof-harness/`), deu às provas o helper com
remoto bare, `gh` e `tea` falsos e dependências declaradas; esta usa o helper para
provar o que muda. As decisões são as do ADR-0015 do anvil — um branch base só,
declarado nas rules ou detectado, de onde todo trabalho sai e para onde volta, com
o hotfix num PR só — e do ADR-0016 — as skills `tea-*` viram `anvil-*` e servem
Gitea e GitHub, com remoto ssh ou https, e o `tea` nunca escolhe o login sozinho.
Os ADRs estão em `docs/architecture/adr/`.

Os termos **Branch base**, **Forge**, **Prova**, **Piloto automático** e
**Roteiro** são os de `docs/architecture/context.md`. Também entram a prova da
conferência da árvore no caminho do PR, o P2 do ticket 04 da 009, e dois defeitos
do `dev-link.sh` vistos na 010.

## Problem Statement

O toolkit supõe que todo projeto tem uma `main` e fecha PR num Gitea:

- **`main` escrita em comando.** A largada do piloto automático só segue com
  `branch: main`; o fechamento faz `git checkout main`; a conferência do merge roda
  `git rev-list <branch>..main` e `git merge-base --is-ancestor HEAD main`; a
  entrada nova sai de `git checkout -B <branch> main`. Num projeto com `master`, o
  piloto recusa a largada, e um fechamento à mão falha no meio.
- **Stash preso.** O PR rápido faz `git stash` e depois `git checkout main`. Sem
  `main`, o checkout falha com o stash já feito, e o trabalho do operador fica
  guardado sem aviso.
- **Promessa sem detecção.** A limpeza de branches diz que detecta os branches
  principais, e roda `git checkout main`.
- **Dois papéis num lugar, um no outro.** As skills de PR falam de branch estável e
  de integração, com o hotfix abrindo dois PRs; o piloto conhece um branch só. Num
  projeto com `develop`, os dois textos se contradizem.
- **Só Gitea.** Não há caminho de PR com `gh`. O perfil do tracker, o archive e o
  piloto mandam fechar por `/tea-open-pr`; num remoto GitHub, a spec que fecha por
  PR para.
- **Login errado no Gitea.** Com o remoto num alias do `~/.ssh/config`, nenhum
  login do `tea` casa, e ele cai no login padrão com um aviso no stderr. Num
  ambiente com mais de um Gitea, o PR sai no servidor errado sem erro.
- **Nenhum lugar declara.** O projeto não tem onde dizer qual é o branch base nem o
  forge, e nada os descobre.
- **Caminho do PR sem prova.** A conferência da árvore depois do push da linha
  `PR:`, que impede o que ficou fora de commit de ir para a `main` com o piloto,
  nunca rodou: as fixtures não tinham remoto.
- **Links velhos.** O `dev-link.sh` não remove o link de uma skill que saiu do
  payload, e o aviso de referência fora do roster acusa o nome de rede
  `"anvil-net"` como se fosse skill.

## Solution

- **Um resolvedor** do payload diz o branch base, o forge, o repositório, o host
  real do remoto e, no Gitea, o login do `tea`. Ele lê a seção `## Git` das rules
  do projeto e, sem ela, detecta; quando a resposta não é única, recusa com o
  motivo. Todo comando que hoje escreve `main` passa a usar o branch base que ele
  dá.
- **O `anvil-boot` escreve a seção `## Git`** com o valor detectado e confirmado
  pelo usuário.
- **As quatro skills de git viram `anvil-commit`, `anvil-open-pr`,
  `anvil-open-fast-pr` e `anvil-prune-branches`**, cada uma servindo Gitea e
  GitHub, com remoto ssh ou https. O hotfix abre um PR só, para o branch base.
- **O perfil do tracker, o archive, o piloto, as diretivas e os docs** passam a
  citar as skills novas e o branch base. A guarda fala dos dois forges e cobre o
  PR criado por `gh api`.
- **A instalação** tira os nomes `tea-*` como órfãos do lock, e o `dev-link.sh`
  tira os links que apontam para skill que saiu do payload.

## User Stories

### Branch base

1. Como operador de um projeto com `master`, quero que o piloto automático comece,
   feche e volte ao `master`, para usar o anvil sem renomear o branch.
2. Como operador de um projeto com `develop`, quero declarar `develop` como branch
   base, para que toda spec saia dela e volte a ela.
3. Como operador, quero declarar o branch base numa seção `## Git` de
   `.claude/rules/anvil.md`, para que a escolha fique versionada e visível.
4. Como operador de um projeto sem a seção, quero que o branch base seja detectado
   pelo `origin/HEAD` ou, sem ele, pelo único entre `main` e `master` que existir,
   para que o caso comum funcione sem configuração.
5. Como operador, quero que um repositório com `main` e `master`, ou sem nenhum
   dos dois e sem `origin/HEAD`, seja recusado com o motivo e a seção a escrever,
   para que o toolkit nunca escolha em silêncio.
6. Como operador, quero que um branch base declarado que não existe no repositório
   seja recusado com o motivo, para descobrir a renomeação antes de o piloto agir.
7. Como operador, quero que o branch novo de cada spec saia do branch base, e que o
   `new-spec.sh` recuse quando o checkout atual não é o branch base, para que
   nenhuma spec nasça de outra.
8. Como operador, quero que a conferência do merge compare o branch da spec com o
   branch base, para que ela funcione com `master` e `develop`.
9. Como operador, quero que a largada e a retomada do piloto reconheçam o branch
   base, e não a palavra `main`, para que o piloto não recuse um projeto válido.
10. Como pessoa que usa o bench, quero que o projeto novo nasça com `main` e com a
    seção `## Git` dizendo isso, para que o bench e o piloto leiam o mesmo valor.

### Forge

11. Como operador, quero declarar o forge na seção `## Git` como `gitea`, `github`
    ou `nenhum`, para que um Gitea próprio ou um GitHub Enterprise funcionem.
12. Como operador de um projeto sem a seção, quero que um remoto em `github.com`
    seja reconhecido como GitHub, para não configurar o caso comum.
13. Como operador, quero que um remoto noutro host, sem a seção, seja recusado com
    o motivo e a seção a escrever, para que o toolkit nunca chame o CLI errado.
14. Como operador, quero que um projeto sem remoto feche por merge local, como
    hoje, qualquer que seja o forge declarado.
15. Como operador, quero que o host do remoto seja o real, resolvido do alias de
    ssh com o mesmo comando de ssh que o git usa, para que o alias do
    `~/.ssh/config` não engane o toolkit.
16. Como operador, quero que remotos https, `git@host:org/repo` e
    `ssh://git@host:porta/org/repo` deem o mesmo repositório `org/repo`, para que a
    forma da URL não mude o resultado.

### Login do Gitea

17. Como operador do Gitea, quero que o login do `tea` seja o que casa com o host
    real do remoto, pelo `url` ou pelo `ssh_host` do login, para que o PR saia no
    servidor certo.
18. Como operador, quero que nenhum login, ou mais de um, casando com o host seja
    recusado com o motivo e o comando para resolver, para que o `tea` nunca caia
    no login padrão.
19. Como operador, quero que toda chamada do `tea` de PR leve `--login` e
    `--repo` explícitos, para que nenhuma dependa da adivinhação do `tea`.

### Skills de git

20. Como operador, quero `anvil-commit`, `anvil-open-pr`, `anvil-open-fast-pr` e
    `anvil-prune-branches` no lugar das `tea-*`, com o mesmo comportamento de hoje
    fora do forge e do branch, para que os nomes não colidam com skills de outros
    toolkits.
21. Como operador do GitHub, quero que o PR saia com `gh pr create`, com base,
    título, corpo, rótulo e responsável, para fechar a spec por PR no GitHub.
22. Como operador, quero que o rótulo seja escolhido entre os que o forge lista,
    pelo `gh label list` ou pelo `tea labels list`, para não inventar rótulo.
23. Como operador, quero que a URL do PR venha da saída de máquina do CLI — o
    stdout do `gh pr create` e o `--output json` do `tea pr create` — e vá para a
    linha `PR:` de cada ticket, para que o vínculo não dependa de ler markdown.
24. Como operador, quero que o hotfix abra um PR só, para o branch base, para que o
    fluxo seja um só.
25. Como operador, quero que o PR rápido pare antes do `git stash` quando o branch
    base não existe ou não resolve, para que nada fique guardado sem aviso.
26. Como operador, quero que a limpeza de branches atualize o branch base, e não
    uma `main` fixa, para que ela sirva em todo projeto.
27. Como operador, quero que as skills de PR recusem com o motivo do resolvedor,
    sem chamar o CLI, quando ele recusa.

### Piloto automático

28. Como operador, quero que o piloto decida entre merge local e PR pelo forge do
    resolvedor e pelas rules, e que feche pelo `/anvil-open-pr` quando fecha por
    PR, para que o caminho do PR sirva Gitea e GitHub.
29. Como operador, quero que a conferência da árvore depois do push da linha `PR:`
    pare a execução quando algo ficou fora de commit, sem voltar ao branch base,
    com prova, para que nada vá ao branch base com o piloto.

### Guarda, contratos e instalação

30. Como operador, quero que a guarda de merge bloqueie também o PR criado por
    `gh api` com `POST` em `pulls`, para que não haja um caminho de PR sem guarda.
31. Como operador, quero que a mensagem da guarda cite `gh` e `tea`, para não
    concluir que um deles passa sem conferência.
32. Como operador, quero que o perfil do tracker, nas duas cópias, o verbo
    `archive`, as diretivas, o manual `anvil-omp`, o `README` e as rules deste
    repositório citem as skills novas e o branch base, para que nenhum contrato
    mande chamar uma skill que não existe.
33. Como operador de uma máquina com a instalação publicada, quero que a próxima
    instalação tire as `tea-*` como órfãs do lock e diga o nome novo de cada uma,
    para não ficar com duas versões.
34. Como mantenedor, quero que o `dev-link.sh` tire os links que apontam para uma
    skill que saiu do payload, em `~/.claude/skills` e `~/.agents/skills`, para
    que a máquina de desenvolvimento não fique com links pendurados.
35. Como mantenedor, quero que o aviso de referência fora do roster só acuse nome
    de skill do payload, para que o `"anvil-net"` não apareça como dependência.

## Implementation Decisions

### O resolvedor

- **Um script do payload**, junto dos scripts do `anvil-docs` que todas as skills
  já chamam, rodado da raiz do projeto. Saída em linhas `chave: valor`: `base:`,
  `forge:` (`gitea`, `github` ou `nenhum`), `remote:` (a URL), `host:` (o real),
  `repo:` (`org/repo`) e, no Gitea, `login:`. Quando não há resposta única: linhas
  `refusal:` com o motivo e saída `2`, como o `roadmap.sh`.
- **Seção `## Git`** de `.claude/rules/anvil.md`, com as linhas `branch base:` e
  `forge:`. Cada valor declarado vale sobre a detecção; o que falta é detectado.
- **Branch base detectado:** `origin/HEAD`; sem ele, o único entre `main` e
  `master` em `refs/heads/`. Declarado ou detectado, ele precisa existir.
- **Forge detectado:** sem remoto, `nenhum`; com o host real `github.com`,
  `github`; outro host sem declaração, recusa.
- **Host real:** de https, o host da URL; de ssh, o `hostname` que o `-G` dá com o
  comando de ssh que o git usaria — `GIT_SSH_COMMAND`, `core.sshCommand` ou `ssh`.
  O resolvedor erra só onde o próprio git erraria.
- **Login do `tea`:** do `tea login list --output json`, o login cujo host do `url`
  ou cujo `ssh_host` é o host real. Nenhum ou mais de um: recusa, citando os
  logins vistos e o `tea login` para corrigir.
- O `stage.sh` da camada omp passa a imprimir o branch base numa linha própria, e a
  largada do piloto compara o branch atual com ela.

### As skills de git

- Renomeadas com o conteúdo: `tea-commit` → `anvil-commit` (com o `model: haiku`),
  `tea-open-pr` → `anvil-open-pr`, `tea-open-fast-pr` → `anvil-open-fast-pr`,
  `tea-prune-branches` → `anvil-prune-branches`. São skills autorais.
- Cada uma lê o resolvedor no começo e para com o motivo dele quando ele recusa.
- **Uma skill por ação.** O texto do PR, o rótulo, o responsável e a linha `PR:`
  ficam escritos uma vez; só o bloco de comando muda entre `gh` e `tea`.
- **GitHub:** `gh pr create --base <base> --head <branch> --title --body --label
  --assignee @me`, `gh label list`, e a URL do stdout. `--repo` com o `repo:` do
  resolvedor.
- **Gitea:** `tea pr create --login <login> --repo <repo> --output json`, `tea
  labels list --login <login> --repo <repo>`, e a URL do campo `url`.
- **Um papel de branch.** Some o par estável e integração; o PR vai para o branch
  base, e o hotfix também, num PR só.
- **PR rápido:** o resolvedor roda antes do `git stash`; a base do branch novo é o
  branch base.
- **Limpeza:** atualiza o branch base, pelo resolvedor.

### Piloto, bench e scripts

- **Piloto automático:** todo `git checkout main`, `rev-list <branch>..main`,
  `merge-base … main` e `checkout -B <branch> main` passa a usar o branch base. O
  fechamento por PR chama o `/anvil-open-pr`; a decisão entre PR e merge local usa
  o `forge:` do resolvedor e as rules, como hoje usa o perfil.
- **`new-spec.sh`:** recusa quando o checkout atual não é o branch base.
- **`anvil-bench`:** continua criando o projeto com `git init -b main`, e escreve a
  seção `## Git` com `branch base: main` e `forge: nenhum`.
- **`anvil-boot`:** escreve a seção `## Git` com o valor detectado e confirmado
  pelo usuário; num `anvil.md` sem a seção, a acrescenta, como faz com as outras.
- A prosa pode continuar dizendo "a `main`" com a glosa de branch base.

### Guarda

- Cobre `gh api` com método `POST` sobre um caminho de `pulls`, além do `gh pr` e
  do `tea pr`. As mensagens e o filtro rápido citam `gh` e `tea`.

### Contratos e instalação

- **Perfil do tracker, nas duas cópias:** a linha `PR:` é escrita pelo
  `anvil-open-pr` e pelo `anvil-open-fast-pr`; o fechamento cita o
  `/anvil-open-pr`; o exemplo de URL não fica preso ao Gitea.
- **Verbo `archive`, manual `anvil-omp`, `README`, rules deste repositório e
  ADR-0013:** citam os nomes novos. Os ADRs antigos ficam como histórico, salvo
  onde citam a skill como instrução.
- **Cauda de roteamento:** o `claude_boot.md`, de onde saem o bloco do `CLAUDE.md`
  e a rule de diretivas do omp, e o `CLAUDE.md` deste repositório trocam o
  `tea-open-pr`, o `tea-open-fast-pr` e o `tea-commit` pelos nomes novos.
- **Skill vendorizada:** a menção às `tea-*` no `anvil-poteto` muda pelo catálogo
  de adaptação, no manifesto, como a `anvil-sync` manda, e não por edição livre.
- **Roster do `dev-link.sh`, comentário do manifesto e `anvil-boot`:** os nomes
  novos; o `anvil-boot` continua reconhecendo as `tea-*` antigas de um projeto do
  mosk.
- **`reset-install.sh`:** os nomes `tea-*` saem pela regra de órfão do lock que já
  existe; o relatório do update diz o nome novo de cada um.
- **`dev-link.sh`:** sem `--unlink`, também tira, em `~/.claude/skills` e
  `~/.agents/skills`, o link nosso cujo alvo não existe mais no payload. O aviso de
  referência fora do roster só conta nome que é diretório de skill do payload.

## Testing Decisions

Um bom teste observa o que o operador veria: linhas do resolvedor, o log do forge
falso, commits e branches da fixture, a linha `PR:` do ticket, o stash, links em
`HOME`, a decisão da guarda. Nunca o texto de uma skill.

Toda prova nova vai num diretório novo de `workspace/`, a partir do próximo número
livre. As sessões rodam pelo helper da 010, com o código dele nas saídas e as
skills de que dependem declaradas.

### S1 — o resolvedor sem modelo (novo)

Prior art: `workspace/43-roadmap-state/`. Bash puro, no bash do `PATH` e no
`/bin/bash` 3.2, sobre repositórios de fixture:

- seção `## Git` completa, parcial e ausente;
- `origin/HEAD`, só `main`, só `master`, os dois, nenhum; branch base declarado que
  não existe;
- remotos https, `git@host:org/repo.git`, `ssh://git@host:2222/org/repo.git` e um
  alias resolvido por `GIT_SSH_COMMAND` com `-F` num config de fixture, todos dando
  o mesmo `repo:`;
- `github.com` sem seção; host desconhecido sem seção, recusado; sem remoto,
  `nenhum`;
- login do `tea` com nenhum, um e dois casamentos, por `url` e por `ssh_host`, com
  um `tea` falso que devolve a lista.

### O forge falso do helper (ampliado)

O `tea` falso passa a devolver a lista de logins que a prova configura no
`tea login list --output json`, e o `gh` e o `tea` falsos passam a responder a
listagem de rótulos. S1 do helper, como no ticket 03 da 010.

### S2 — as skills pelo helper (novo)

Com `--remote --forge` e as dependências declaradas:

- `/skill:anvil-open-pr` em fixture GitHub com `master` e em fixture Gitea com
  `develop` declarada e remoto por alias de ssh: o log mostra o CLI certo, a base
  certa, `--login` e `--repo` no `tea`, e o ticket ganha a linha `PR:` com a URL;
- um hotfix: um PR só, para o branch base;
- Gitea com dois logins casando: a skill recusa, e o log não tem `pr create`;
- `/skill:anvil-open-fast-pr` sem branch base resolvível: recusa antes do stash, e
  `git stash list` fica vazio;
- `/skill:anvil-prune-branches` em fixture com `master`: atualiza o `master`.

### S2 — o piloto pelo helper (novo)

Prior art: `workspace/57-merge-check/` e `workspace/55-auto-clean-tree/`.

- **`master`:** o piloto começa, fecha por merge local e volta ao `master`.
- **PR no GitHub:** o piloto fecha pelo `/anvil-open-pr`, a linha `PR:` é commitada
  e enviada ao bare, e ele volta ao branch base.
- **Árvore suja depois do PR:** um hook que deixa arquivo fora de commit depois do
  push da linha `PR:`; a execução para sem voltar ao branch base, e o branch base
  não recebe o arquivo.

### S1 — instalação, `dev-link.sh` e guarda (existentes)

Prior art: `workspace/03-reset-install/`, `workspace/42-dev-link/`,
`workspace/04-hook-merge/` e `workspace/40-global-guard/`, num `HOME` de fixture:

- reset com lock que tem as `tea-*`: elas saem, e o relatório diz os nomes novos;
- `dev-link.sh` com um link nosso para uma skill que saiu do payload: ele sai, em
  `~/.claude/skills` e `~/.agents/skills`; o link de outro toolkit fica;
- o aviso de referência fora do roster não acusa `anvil-net`;
- a guarda bloqueia `gh api -X POST repos/o/r/pulls` e `gh pr create --fill` numa
  spec sem archive, e a mensagem cita `gh` e `tea`.

### S3 — `vendor-sync.sh verify` (existente)

Sai `0`, com o lock regenerado e os caminhos citados pela camada omp existindo.

## Out of Scope

- **GitLab e outros forges.** A seção aceita `gitea`, `github` e `nenhum`.
- **Dois papéis de branch** e o hotfix levado à produção num projeto com
  `develop`: passo do operador, fora do toolkit.
- **Reescrever as provas antigas** de `workspace/` que fixam `main`.
- **Alias de compatibilidade** para os nomes `tea-*`.
- **Os ADRs, as specs arquivadas e o plano** que citam `tea-*` ou `main` como
  histórico.
- **As linhas A27 a A29 do acompanhamento**, que são da 010.

## Further Notes

- A renomeação muda o que o operador digita: depois da instalação, `/tea-open-pr`
  deixa de existir. O relatório do update é o único aviso.
- Na máquina de desenvolvimento, o `dev-link.sh` novo tira os links `tea-*`
  pendurados na primeira execução depois do merge.
- O `GIT_SSH_COMMAND` é o caminho pelo qual a prova dá ao resolvedor um config de
  ssh de fixture sem tocar no `~/.ssh/config`; é o mesmo que o git usa, e não um
  gancho só para teste.
