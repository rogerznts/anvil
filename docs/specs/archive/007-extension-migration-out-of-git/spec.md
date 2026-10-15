# 007 — Migração lista o que está fora do git e edita o alvo de symlink no repositório

**Status:** ready-for-agent

Extensão da spec 006 (`docs/specs/archive/006-feature-user-install-language-next/`),
que está arquivada e não muda. Esta spec fecha os cinco P2 que o ticket 05 da 006
(migração de projeto antigo) deixou abertos no seu `## Comments`, nas rodadas 2 e
3, e os três P3 que as mesmas correções tocam.

## Problem Statement

Quem roda o `/anvil-update` ou o `/anvil-boot` num projeto instalado do jeito
antigo espera que a migração tire a cópia do toolkit e deixe o resto, numa
execução, com tudo o que sai visível antes de aprovar. Hoje ela tropeça em três
lugares:

- **Toolkit ignorado pelo git.** Quando algo que sairia está ignorado e fora do
  git, a migração recusa com código 2 e manda fazer o passo 9 do boot. O
  `/anvil-update` para e aponta o boot, contra o "migra esse projeto na mesma
  execução" da spec 006 (P2 R2-a). Se a regra que ignora vem de
  `.git/info/exclude`, do excludes global ou de uma linha que o próprio usuário
  escreveu, o passo 9 não a tira, e boot e migração entram em laço, com uma
  mensagem que culpa "o .gitignore do projeto" (P2 R2-b). O desvio pelo passo 9
  nunca foi exercitado de ponta a ponta (P2 R2-d).
- **Ignorado dentro de item versionado.** Numa skill versionada que tem arquivos
  ignorados dentro, esses arquivos saem junto sem aparecer no dry-run nem no `git
  status`. Sem lock, uma skill do usuário esquecida no `--keep-skills` perde de
  vez o que nunca foi commitado (P2 R3).
- **`CLAUDE.md` que é symlink.** No comum `CLAUDE.md → AGENTS.md`, com o alvo
  dentro do repositório, o bloco `ANVIL:DIRECTIVES` velho fica, o script diz
  "pronto", e as skills não dizem o que fazer com o grupo "passa por symlink"
  (P2 R2-c).

Por trás de três desses achados está a mesma regra — conteúdo fora do git é
recusado —, e cada correção dela criou o achado da rodada seguinte.

Os P3 que vêm junto: o `--help` ainda diz que nada ignorado é apagado; sem lock, a
saída 3 vem antes de qualquer informação sobre o que está fora do git, e o usuário
responde sem saber; e um `CLAUDE.md` ou um settings que é symlink para um arquivo
de fora com o bloco ou a guarda da instalação de usuário — o `~/.claude/CLAUDE.md`
— faz o projeto contar como instalação antiga, exigir árvore limpa e receber um
relatório sem nada a tirar.

## Solution

O usuário continua rodando os mesmos comandos. O que muda:

- O que está fora do git deixa de ser recusado. O dry-run mostra um grupo novo,
  **"sai junto, fora do git, sem volta pelo git"**, com cada arquivo, e a
  aprovação de sempre cobre esse grupo. O `/anvil-update` migra na mesma execução,
  com o toolkit ignorado ou não, e nenhuma regra de ignore, venha de onde vier,
  põe o fluxo em laço.
- O `CLAUDE.md` e o `.claude/settings.json` que são symlink com o alvo dentro do
  repositório têm o alvo editado. Com o alvo fora, ficam intocados, e as skills
  dizem o que fazer com eles.
- Os textos dizem a verdade: o que era versionado aparece no `git status`; o resto
  aparece, por nome, no dry-run.

## User Stories

1. Como usuário que roda o `/anvil-update` num projeto antigo com o toolkit
   ignorado pelo bloco `ANVIL:INSTALLED`, quero que a migração aconteça na mesma
   execução, para não precisar descobrir que o boot é outro passo.
2. Como usuário, quero ver no dry-run, por nome, cada arquivo que vai sair sem ter
   passado pelo git, para saber o que não vou recuperar com `git checkout`.
3. Como usuário, quero que o grupo fora do git diga explicitamente "sem volta pelo
   git", para não confundir com o que aparece no `git status`.
4. Como usuário com uma regra de ignore em `.git/info/exclude` ou no excludes
   global, quero que a migração funcione do mesmo jeito, para não ficar preso
   num laço que nenhum passo do boot resolve.
5. Como usuário, quero que a mensagem nunca culpe o `.gitignore` do projeto por uma
   regra que vem de outro lugar, para não perder tempo procurando a linha errada.
6. Como usuário com uma skill versionada que tem um `.DS_Store` ou um
   `__pycache__/` ignorado dentro, quero que esses arquivos apareçam no grupo fora
   do git, para que nada saia em silêncio.
7. Como usuário de projeto sem lock, quero que a lista de skills e agentes da
   saída 3 marque quais têm conteúdo fora do git, para decidir o `--keep-skills`
   sabendo o que é irrecuperável.
8. Como usuário de projeto sem lock, quero responder quais skills são minhas uma
   vez só, sem uma segunda parada por causa do ignore, para terminar a migração em
   uma rodada de resposta.
9. Como usuário com `CLAUDE.md → AGENTS.md`, quero que o bloco `ANVIL:DIRECTIVES`
   saia do `AGENTS.md`, para que as diretivas velhas não fiquem no projeto.
10. Como usuário, quero ver a remoção do bloco no alvo pelo `git status`, para
    revisar como reviso o resto.
11. Como usuário cujo alvo do symlink só tinha o bloco, quero que o alvo e o
    symlink saiam juntos, para não sobrar um link pendurado nem um arquivo vazio.
12. Como usuário com `.claude/settings.json` que é symlink para um arquivo dentro
    do repositório, quero que a entrada da guarda saia do alvo, pela mesma regra
    do `CLAUDE.md`.
13. Como usuário cujo `CLAUDE.md` aponta para fora do repositório, quero que ele
    fique intocado, para que a migração nunca escreva em arquivo de outro projeto
    ou da instalação de usuário.
14. Como usuário com um item no grupo "passa por symlink", quero que o update e o
    boot me digam o que fazer com ele, para não ficar com uma pendência sem
    instrução.
15. Como usuário cujo `CLAUDE.md` é symlink para o `~/.claude/CLAUDE.md`, quero que
    o projeto não conte como instalação antiga por causa disso, para não ter de
    limpar a árvore por nada.
16. Como usuário que caminha por um diretório que é symlink até o alvo, quero que
    o alvo fique intocado, para que a regra "nada através de symlink de diretório"
    continue valendo.
17. Como usuário, quero que o `--help` do script descreva o comportamento real com
    o que está fora do git, para não ser enganado ao ler só a ajuda.
18. Como usuário, quero que o README, o passo 5 do update e o passo 2 do boot
    digam que o versionado aparece no `git status` e o resto aparece no dry-run,
    para que a promessa bata com o que vejo.
19. Como usuário, quero que o boot não me desvie mais para o passo 9 no meio da
    migração, para que o passo 2 termine sozinho.
20. Como usuário, quero que o passo 9 do boot continue tirando o bloco
    `ANVIL:INSTALLED` do `.gitignore`, para que o ignore velho não esconda as
    skills que eu criar no projeto depois.
21. Como usuário, quero que a migração continue exigindo árvore limpa, passando
    por dry-run, esperando aprovação e nunca commitando, para que o resto do
    contrato da 006 siga igual.
22. Como mantenedor do anvil, quero que o cenário de migração cubra o toolkit
    ignorado, o item misto, o symlink com alvo dentro e fora e a saída 3 com
    marca, cada caso falhando antes da correção, para que a regressão apareça.
23. Como mantenedor, quero que os P3 do ticket 05 que esta spec não resolve fiquem
    em `docs/project/acompanhamento.md`, com origem e consequência, para que
    ninguém os perca com a 006 arquivada.

## Implementation Decisions

- **O que está fora do git é listado, não recusado.** A migração classifica o que
  sai em duas partes: o que o git conhece, que aparece no `git status` depois da
  execução, e o que está fora dele, que só aparece no dry-run. Fora do git é o
  item sem nada versionado e o que está ignorado dentro de um item versionado. A
  árvore limpa continua exigida, então não há arquivo não versionado e não
  ignorado no caminho.
- **O grupo novo do relatório** chama "sai junto, fora do git, sem volta pelo git"
  e lista arquivo por arquivo, também na execução. Vem logo depois dos grupos do
  que sai.
- **Some a recusa por item ignorado.** O código 2 continua para os outros erros
  (sem git, árvore suja, marcadores quebrados, settings inválido, sem `python3`,
  argumento ruim). Os códigos 0 e 3 mantêm o sentido.
- **Saída 3 com marca.** Sem lock e sem resposta, a lista das skills e dos agentes
  do projeto marca os que têm conteúdo fora do git. A resposta continua em
  `--keep-skills` e `--keep-agents`, juntos.
- **Symlink com alvo no repositório.** O `CLAUDE.md` e o `.claude/settings.json`
  que são symlink são resolvidos. Se o alvo é arquivo comum dentro da raiz do
  repositório e o caminho relativo até ele não passa por diretório symlink, a
  edição vai no alvo, com as mesmas regras do arquivo comum: só o bloco sai do
  `CLAUDE.md`, só a entrada do hook sai do settings. Alvo que ficaria só com o
  bloco, ou só com a entrada, sai inteiro, e o symlink sai com ele.
- **Symlink com alvo fora do repositório**, ou caminho que passa por diretório
  symlink: intocado, no grupo "passa por symlink". Esse arquivo, sozinho, não faz
  o projeto contar como instalação antiga; ele só aparece no relatório quando o
  projeto já é instalação antiga por outra razão.
- **O que fazer com "passa por symlink"**: o passo 5 do update e o passo 2 do boot
  dizem que o item ficou porque a migração não escreve fora do projeto; se o alvo
  é do próprio projeto, tire à mão o bloco ou a entrada; se é a instalação de
  usuário (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`), deixe como está.
- **Skills e README.** O passo 5 do `anvil-update` e o passo 2 do `anvil-boot`
  perdem o ramo "Ignorado pelo git", ganham a explicação do grupo fora do git e a
  do grupo "passa por symlink". O passo 2 do boot não desvia mais para o passo 9.
  O README troca "exige o toolkit fora do `.gitignore`" pela explicação das duas
  partes. O relato final do update diz "o que era versionado está no `git status`;
  o que estava fora do git foi listado no dry-run".
- **O passo 9 do boot não muda.** Continua o único que tira o bloco
  `ANVIL:INSTALLED` do `.gitignore`.
- **Cabeçalho do script.** O texto que o `--help` imprime passa a descrever as
  duas partes e o tratamento de symlink com alvo no repositório.
- **Acompanhamento.** Os P3 da rodada 1 do ticket 05 que ficam de fora entram em
  `docs/project/acompanhamento.md` numa seção da spec 006: a menção à guarda numa
  string de `permissions` contada como instalação antiga; o awk de marcadores
  duplicado com o do `reset-install.sh`; a árvore de decisão do dry-run repetida
  nas duas skills; o `json.dump` que regrava a formatação do settings; o aviso de
  perfil que acusa `/Users/<u>/.claude/...` e `"${HOME}"/.claude/...`.

## Testing Decisions

- **Um seam: a linha de comando do `migrate-project.sh`, chamada pelos blocos de
  comando do `anvil-update` e do `anvil-boot`.** O cenário
  `workspace/41-legacy-migration/s1.sh` é a prova, com `HOME` temporário, o
  projeto-fixture antigo montado pelo `reset-install.sh` de `dd274b2` e os
  comandos tirados dos blocos das skills. O cenário observa só o que alguém de
  fora vê: os grupos do dry-run, o que sai do disco, o conteúdo dos arquivos
  editados, o `git status` e o código de saída.
- **Casos novos ou mudados**, cada um falhando antes da correção:
  - o p11 — toolkit ignorado e fora do git — passa a migrar pelo update e pelo
    boot, com cada arquivo no grupo fora do git e saída 0;
  - regra de ignore em `.git/info/exclude`: mesmo resultado do p11;
  - item misto: skill versionada com arquivo ignorado dentro, que aparece no grupo
    fora do git; o p15 (`.DS_Store` solto) continua passando;
  - `CLAUDE.md → AGENTS.md` com o bloco: o bloco sai do `AGENTS.md`, o resto fica
    byte a byte, e a mudança aparece no `git status`;
  - `CLAUDE.md → AGENTS.md` só com o bloco: os dois saem;
  - settings que é symlink para arquivo dentro do repositório: a entrada sai do
    alvo;
  - `CLAUDE.md` que é symlink para um arquivo fora do repositório com o bloco:
    intocado; sem outro sinal de instalação antiga, o projeto não migra e não
    exige árvore limpa;
  - sem lock, saída 3 com a marca de conteúdo fora do git na skill que tem;
    depois, uma rodada de resposta basta.
- **O que faz um bom teste aqui**: estado final do projeto e saída visível, nunca
  o texto exato de uma mensagem nem a ordem interna das checagens.
- **`vendor-sync.sh verify`** sai limpo.
- Os textos das skills e do README não têm seam executável; o cenário os cobre na
  medida em que tira deles os comandos, e o resto se confere lendo.

## Out of Scope

- O update tirar o bloco `ANVIL:INSTALLED` do `.gitignore`: continua só no passo 9
  do boot.
- Os cinco P3 da rodada 1 do ticket 05 listados em Implementation Decisions: vão
  para o acompanhamento, não para o código.
- Mudar a spec 006 arquivada.
- Migrar este repositório, que ainda tem artefatos da instalação por projeto por
  decisão do ticket 06 da 006.

## Further Notes

- A troca de "recusar" por "listar e aprovar" é deliberada. Três rodadas de revisão
  no ticket 05 mostraram o sinal de laço de `docs/agents/verification.md`: cada
  correção da recusa criou o achado da rodada seguinte, com a classe descendo de
  P1 para P2. Listar com aprovação dá o que a recusa queria proteger — nada sai
  sem o usuário ver — sem depender de onde vem a regra de ignore.
- O risco que a recusa evitava continua existindo e agora é visível: sem lock, a
  skill do usuário esquecida no `--keep-skills` sai, e o que estava fora do git
  dela não volta. A marca na saída 3 e o grupo do dry-run são a defesa.
