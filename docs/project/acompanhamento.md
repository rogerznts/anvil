# Acompanhamento

Achados P2 e P3 que sobraram de specs fechadas e não seguraram o fechamento,
pelo critério de `docs/agents/verification.md`. Cada linha diz de onde veio e o
que acontece se ninguém mexer. Quem pegar uma linha abre uma spec `extension`
ligada à spec de origem e tira a linha daqui no mesmo branch.

## Spec 004: robustez e isolamento da camada omp

Origem: `docs/specs/archive/004-extension-omp-layer-hardening/`, que resolveu as linhas A1
a A11 que a spec 003 (omp como harness, com camada própria) deixou aqui: bloqueio
fora do formato, árvore suja, P1 em linha combinada, caixa alta acentuada, check 15,
exemplos do `tela: nao`, desvios sem prova, identificadores em português,
condutores presos ao perfil `docs/specs`, frontier em paralelo e `verify` no bash
3.2. Fica a parte do antigo A9 (os condutores só funcionam com o perfil
`docs/specs`) que a spec deixou de fora.

- **A12 · adaptador de tracker para os condutores.** Out of Scope da spec 004,
  registrado no fechamento, sem classe: é escopo, não achado de review. Com
  outro perfil do `anvil-setup` (GitHub, GitLab, markdown local), a `anvil-plan` e
  a `anvil-run` recusam com o nome do perfil, e o fluxo segue à mão. Conduzir
  nesses perfis pede um frontier e uma retomada que leiam issues do tracker, e
  antes disso decidir como spec e ticket aparecem em cada um, o que é decisão de
  grill. Não há projeto usando outro perfil com omp. Enquanto ninguém mexer, quem
  usa outro perfil no omp não tem condução.
- **A14 · a `anvil-to-tickets` escreve o título no `Blocked by`.** Ticket 11 da
  spec 004, achado do ponta a ponta antes da rodada 1, sem classe: o `frontier.sh`
  fez o que a spec pede, e o defeito é da skill vendorizada. O ticket 02 saiu com
  `Blocked by: 01: Contar severidades de 0 a 3 em arquivo válido`, o formato que o
  template da skill vendorizada aceita. O `frontier.sh` o deixou fora do frontier
  como bloqueio ilegível, como a spec pede, e o operador corrigiu a linha para
  `01`. Enquanto ninguém mexer, toda spec planejada pelo `anvil-plan` pode sair
  com tickets parados até o operador reescrever a linha.

## Spec 006: instalação por usuário, idioma no chat e cauda do `anvil-next`

Origem: `docs/specs/archive/006-feature-user-install-language-next/`, ticket 05
(migração de projeto antigo), P3 da rodada 1 no `## Comments`. A própria 006
resolveu o P3 da resposta pela metade, `--keep-skills` sem `--keep-agents`, que
agora para com código 2. A spec 007 fechou os P2 das rodadas 2 e 3 e os P3 que as
mesmas correções tocam. Ficam estes.

- **A15 · menção à guarda no settings conta como instalação antiga.** Ticket 05
  da spec 006, rodada 1, P3 (Standards). A migração procura
  `.claude/hooks/guard-spec-merge.sh` no `.claude/settings.json` inteiro, não só
  no comando de um hook. Enquanto ninguém mexer, um settings que cita a guarda
  numa string de `permissions`, por exemplo, faz o projeto contar como instalação
  antiga: o relatório diz "instalação antiga" sem nada a tirar e exige árvore
  limpa sem motivo.
- **A16 · o awk de marcadores da migração repete o do `reset-install.sh`.**
  Ticket 05 da spec 006, rodada 1, P3 (Standards), possível Duplicated Code: o
  `block_lines` e o `markers_ok` do `migrate-project.sh` refazem o awk de
  marcadores `ANVIL:DIRECTIVES` do `reset-install.sh`. Os dois leem arquivos
  diferentes, o `CLAUDE.md` do projeto e o `~/.claude/CLAUDE.md`, com o mesmo
  formato de marcadores. Enquanto ninguém mexer, uma correção de CRLF ou de
  marcador precisa ser feita nos dois scripts, e a que ficar só num deles faz a
  instalação e a migração lerem o mesmo formato de jeitos diferentes.
- **A17 · a árvore de decisão do dry-run se repete nas duas skills.** Ticket 05
  da spec 006, rodada 1, P3 (Standards), possível Duplicated Code e Shotgun
  Surgery: o que fazer com cada saída do dry-run da migração está escrito no passo
  2 do `anvil-boot` e no passo 5 do `anvil-update`. Enquanto ninguém mexer, mudar
  o comportamento do script exige editar as duas skills, e uma tende a ficar para
  trás.
- **A18 · o `json.dump` regrava a formatação do settings inteiro.** Ticket 05 da
  spec 006, rodada 1, P3 (Spec): ao tirar a entrada da guarda, o
  `json.dump(indent=2)` regrava o `.claude/settings.json` inteiro, ou o alvo dele
  quando é symlink dentro do repositório. Enquanto ninguém mexer, um settings com
  outra indentação ou com `\uXXXX` ganha mudança de formatação no diff além da
  remoção, contra o "settings fora da entrada do hook intocados" do critério da
  linha 21 do ticket 05 da 006; o dry-run avisa.
- **A19 · o aviso de perfil acusa caminho da instalação de usuário.** Ticket 05
  da spec 006, rodada 1, P3 (Spec): o aviso de perfil desconta `~/.claude/`,
  `${HOME}/.claude/` e `$HOME/.claude/` com ou sem aspas em volta do `$HOME`
  (`"$HOME"/`, `"$HOME/`, `$HOME"/`). Enquanto ninguém mexer, um perfil em
  `docs/agents/` que cita `/Users/<u>/.claude/skills/<s>/scripts/` ou
  `"${HOME}"/.claude/...` recebe um `BOOT PENDENTE` falso, e o usuário roda o
  `/anvil-boot` atrás de uma linha que já aponta para a instalação de usuário.

## Spec 007: migração lista o que está fora do git e edita o alvo de symlink no repositório

Origem: `docs/specs/archive/007-extension-migration-out-of-git/`, rodada 1 dos
tickets 01 e 03, no `## Comments` de cada um. Os demais P2 e P3 abertos dos quatro
tickets foram aceitos no fechamento, e a decisão está registrada nos `## Comments`.

- **A20 · o grupo "passa por symlink" não mostra o alvo.** Ticket 03, rodada 1,
  P2 (Standards). A linha do `CLAUDE.md` e a do `.claude/settings.json` nesse
  grupo não dizem para onde o link aponta, e o passo 5 do `anvil-update` e o
  passo 2 do `anvil-boot` mandam decidir pelo alvo: do projeto, tirar à mão; da
  instalação de usuário, deixar. Enquanto ninguém mexer, o agente roda `readlink`
  para saber o que dizer ao usuário.
- **A21 · edição parcial em arquivo ignorado não aparece em lugar nenhum.**
  Tickets 01 e 03, rodada 1, P3 (Spec), o mesmo achado. Quando o `CLAUDE.md`, o
  `.claude/settings.json` ou o alvo do symlink de um deles está ignorado pelo git
  e perde só o bloco ou a entrada da guarda, a mudança não aparece no `git status`
  nem no grupo "sai junto, fora do git, sem volta pelo git". Enquanto ninguém
  mexer, o README e as duas skills mandam procurar a mudança onde ela não está; a
  edição aparece só em "sai do projeto", antes da aprovação, e nenhuma linha do
  usuário se perde.
- **A22 · o relato final do boot não fala do que saiu fora do git.** Ticket 01,
  rodada 1, P3 (Standards). O passo 10 do `anvil-boot` diz só que o diff espera o
  commit do usuário; o relato do update ganhou a parte fora do git. Enquanto
  ninguém mexer, quem migra pelo boot não ouve no fim que parte do que saiu não
  volta pelo git.
- **A23 · o grupo fora do git mostra nomes escapados.** Ticket 01, rodada 1, P3
  (Spec). O `git ls-files` que monta o grupo roda sem `-z`, e o
  `core.quotePath=false` não desliga as aspas e os escapes de nome com `"`, `\`
  ou caractere de controle. Enquanto ninguém mexer, esse arquivo aparece no grupo
  com um nome diferente do que está no disco, embora continue listado.
- **A24 · link absoluto por um prefixo symlink conta como fora do repositório.**
  Ticket 03, rodada 1, P3 (Standards e Spec). A raiz vem de `pwd -P`, e um
  `CLAUDE.md` ou settings que aponta para o próprio repositório por um caminho
  absoluto com prefixo symlink, como `/var` → `/private/var` no macOS, é tratado
  como alvo de fora. Enquanto ninguém mexer, o bloco ou a entrada fica para ser
  tirado à mão; a falha é conservadora e não escreve nada indevido.
- **A25 · cadeia de links: um salto só, e as skills dão o motivo errado.** Ticket
  03, rodada 1, P3 (Spec), sobre a decisão do implementer de seguir um salto só.
  Uma cadeia dentro do repositório, `CLAUDE.md → A.md → B.md`, fica intocada no
  grupo "passa por symlink", e as skills dizem que isso acontece porque a
  migração não escreve fora do projeto. Enquanto ninguém mexer, o usuário recebe
  o motivo errado; a ação indicada, tirar à mão o que é do projeto, continua
  certa.
- **A26 · as regras das duas partes e do symlink estão escritas em vários
  lugares.** Tickets 01 e 03, rodada 1, P3 (Standards), Duplicated Code. O
  parágrafo "o que o git conhece / o que está fora do git" está quase igual no
  passo 5 do `anvil-update`, no passo 2 do `anvil-boot`, no README, no cabeçalho
  do `migrate-project.sh` e num comentário em linha; a regra do symlink, em quatro
  comentários do script. Enquanto ninguém mexer, a próxima mudança numa delas
  exige editar todas as cópias, e a que ficar para trás volta a mentir. Vizinha
  da A17, que cobre a árvore de decisão do dry-run nas duas skills.

## Spec 010: helper de prova e sobras da 009

Origem: `docs/specs/archive/010-extension-proof-harness/`. P2 que o operador
deixou para depois no grill de 2026-10-24, por não mudarem o que as provas da
spec afirmam.

- **A27 · o `origin` da fixture fica apontando para o bare apagado.** Ticket 03,
  rodada 1, P2 (Spec). A limpeza do helper apaga o repositório bare, mas deixa o
  `origin` e o upstream no `.git/config` da fixture. Enquanto ninguém mexer, uma
  fixture reaproveitada entre execuções sai `2` na execução seguinte; as provas de
  hoje recriam a fixture a cada vez.
- **A28 · o volume do app sobra depois da derrubada da infra do prefixo.** Ticket
  04, rodada 1, P2. O `--teardown` tira os containers da rede do prefixo, mas não
  os volumes do compose do app, como o `node_modules`. Enquanto ninguém mexer,
  cada prova do bench que não derruba o app com o compose dele deixa um volume
  órfão na máquina; o B1 do ticket 09 derruba.
- **A29 · a parada no fechamento tem três nomes no `anvil-auto`.** Ticket 05,
  rodada 1, P3 (Standards), Mysterious Name. "Parada no fechamento depois do
  archive", "não fecha no fechamento" e "parada, já arquivada no branch" são o
  mesmo caso. Enquanto ninguém mexer, quem lê a skill casa três nomes para um caso
  só, e uma regra nova pode acertar um nome e esquecer os outros.

## Spec 011: branch base e forge neutro

Origem: `docs/specs/archive/011-extension-branch-base-and-forge/`. Lacunas de
prova que o operador deixou para depois no grill de 2026-10-25: todas têm verde, e
nenhuma muda comportamento. A A35 a A37 vêm da rodada 1 do ticket 11 e foram
aceitas no fechamento, no mesmo dia; a A35 é de comportamento, não de prova.

- **A30 · a limpeza de branches passa também com o texto antigo.** Ticket 06,
  rodada 1, P2 (Spec). O caso `prune` saiu `0` com o texto de antes, em que o
  modelo atualizou o `master` apesar do `git checkout main` escrito. Enquanto
  ninguém mexer, uma regressão para a `main` fixa na limpeza passa verde.
- **A31 · a prova do PR rápido não conta as chamadas do resolvedor.** Ticket 06,
  rodada 2, P2 (Spec). O vermelho do `origin-head` saiu `0`. Enquanto ninguém
  mexer, um texto que volte a mandar rodar o resolvedor duas vezes, com o branch
  saindo de uma base e o PR indo para outra, passa enquanto o modelo ignorar a
  instrução.
- **A32 · a prova do PR não confere o responsável no Gitea.** Ticket 05, rodada
  1, P2. Enquanto ninguém mexer, uma regressão no responsável do PR do Gitea passa
  sem a prova ver.
- **A33 · o `gh label list` falso não foi capturado do `gh` real.** Ticket 04,
  rodada 1, P2 (Spec). O formato vem do código do `gh`. Enquanto ninguém mexer, se
  o `gh` real divergir, as provas validam as skills contra uma resposta que o
  GitHub não dá.
- **A34 · a regra do `origin` com o bare só está no helper.** Ticket 05, rodada 1,
  P2 (Spec). A fixture cuja URL de push do `origin` é o bare fica como está; isso
  está só no cabeçalho do `proof.sh` e na seção da `anvil-sync`. Enquanto ninguém
  mexer, quem escreve outra prova com forge esbarra na recusa do `origin` local
  sem saber por quê.
- **A35 · o piloto publica o branch antes de saber se o PR sai.** Ticket 11,
  rodada 1, P2 (Spec). No "PR" do `anvil-auto`, o `git push -u origin <branch>`
  vem antes do Step 0 do `anvil-open-pr`, onde o login do `tea` é procurado.
  Enquanto ninguém mexer, num Gitea sem login que case com o host o branch fica no
  remoto sem PR, a spec para, e nem a "Parada" nem o relatório dizem que ele foi
  publicado: o operador só descobre ao achar o branch órfão.
- **A36 · a ordem "rule antes do forge recusado" não tem prova.** Ticket 11,
  rodada 1, P2 (Spec), sobre a US 39 (a rule que manda fechar sem PR não para num
  forge não resolvido). O caso `regra` da S2 usa `forge: github` resolvido e não
  tem vermelho. Enquanto ninguém mexer, um texto que volte a olhar a `refusal:
  forge:` antes da rule passa verde, e um Gitea sem a seção `## Git` cuja rule
  fecha por merge local volta a parar sem aviso.
- **A37 · a limpeza e o bench seguindo com recusa de forge não têm prova.** Ticket
  11, rodada 1, P2 (Spec). Nenhuma prova cobre a limpeza de branches com uma
  `refusal: forge:` (US 36) nem o bench escrevendo a seção sem a linha `forge:`.
  Enquanto ninguém mexer, um texto que volte a parar em qualquer recusa passa sem
  acusar.
