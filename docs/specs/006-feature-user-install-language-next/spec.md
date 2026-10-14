# 006 — Instalação por usuário, idioma no chat e cauda do `anvil-next`

**Status:** ready-for-agent

Três melhorias que vieram do uso do anvil em vários projetos ao mesmo tempo. Elas
dividem uma spec porque se tocam: as diretivas que corrigem o idioma e disparam a
cauda passam a morar na instalação de usuário que esta spec cria.

## Problem Statement

**Idioma.** O projeto declara pt-BR e mesmo assim, de vez em quando, o
`anvil-code-review`, o `anvil-diagnose`, o `anvil-browser-qa` e outras skills
devolvem a resposta **no chat** em inglês. A documentação sai certa; a conversa,
não. A regra de idioma existe num lugar só, o bloco de diretivas do `CLAUDE.md`, e
nada a leva até os pontos por onde o inglês entra:

- o `anvil-code-review` despacha dois subagentes com brief em inglês, sem linha de
  idioma, e manda repassar os relatórios "verbatim or lightly cleaned";
- as skills vendorizadas têm corpo em inglês, e o modelo espelha o idioma do texto
  que acabou de ler. Traduzi-las não é opção: o catálogo de adaptação é fechado e
  diz que traduzir nunca é adaptação;
- o `tea-open-pr` e o `tea-open-fast-pr` dizem "All text must be in English" para o
  corpo do PR, sem dizer que a regra para no PR;
- o agente `anvil-implementer` do omp e os briefs de subagente do `anvil-how` e do
  `anvil-architect` não dizem em que idioma responder;
- o texto da diretiva fala de "conversa" numa linha e só de "documentação" na
  seguinte, e não fala de subagente.

**Instalação.** O toolkit está estável e roda em vários projetos. Hoje ele é
instalado **por projeto**: cada projeto tem sua cópia do payload, do lock, do
espelho do Codex, da camada omp e do hook da guarda de merge. Atualizar o anvil
significa rodar o `/anvil-update` em cada projeto, um por um, e cada projeto fica
numa versão diferente até alguém lembrar dele. O que de fato varia entre projetos
são as rules, os perfis em `docs/agents/` e o resto de `docs/` — o toolkit é o
mesmo em todos.

**Próximo passo.** O `anvil-next` é das skills mais usadas, e precisa ser chamado à
mão no fim de quase todo passo do fluxo. Ele tem trava de invocação — só o usuário
pode dispará-lo —, e nenhuma skill termina sugerindo a próxima, salvo o
`anvil-run`, que recomenda em texto.

## Solution

**Idioma.** A diretiva de idioma passa a cobrir toda saída que chega ao chat, de
onde quer que venha — relatório de subagente, veredito, resumo de ferramenta,
conclusão de skill —, e manda pôr a linha de idioma em todo brief de subagente.
Chave de formato estável continua como está; a prosa em volta sai no idioma de
comunicação do projeto. As skills autorais que hoje empurram para o inglês
delimitam a própria regra. Nenhuma skill vendorizada é tocada.

**Instalação.** O anvil passa a ser instalado **uma vez por usuário**. O
`/anvil-boot` e o `/anvil-update` instalam o toolkit obrigatoriamente no nível de
usuário — skills, agentes, lock, espelho, camada omp, diretivas e guarda de merge —,
e o projeto fica só com o que é dele: `.claude/rules/`, `docs/agents/` e `docs/`.
Um `/anvil-update` atualiza todos os projetos da máquina de uma vez. O Claude Code e
o omp passam a ler o anvil do diretório do usuário, e as rules continuam por
projeto. Um projeto instalado do jeito antigo migra quando o update ou o boot roda
nele: a cópia local sai, o que é do usuário fica.

**Próximo passo.** Ao fim de um conjunto fechado de skills, o `anvil-next` roda
sozinho, na mesma resposta, e entrega o prompt da próxima sessão. A lista vive num
lugar só, a diretiva global, porque é o único jeito de alcançar skill vendorizada
sem adaptá-la.

## User Stories

### Idioma no chat

1. Como usuário de um projeto em pt-BR, quero que a resposta final de qualquer
   skill chegue em pt-BR, para não precisar pedir tradução no meio do fluxo.
2. Como usuário, quero que o relatório dos dois eixos do `anvil-code-review`
   chegue em pt-BR, mesmo que os subagentes tenham recebido brief em inglês, para
   ler o review sem trocar de idioma.
3. Como usuário, quero que a linha `Review:` e suas chaves — `round`, `sha`,
   `scope`, `verdict`, `p1` — continuem iguais, para que o perfil do tracker e a
   guarda de merge sigam lendo o formato estável.
4. Como usuário, quero que o `anvil-diagnose` narre hipóteses, comandos e
   resultados em pt-BR, para acompanhar o diagnóstico sem esforço.
5. Como usuário, quero que o `anvil-browser-qa` relate o que viu na tela em pt-BR,
   mesmo quando a ferramenta de browser devolve saída em inglês, para entender o
   achado sem traduzir log.
6. Como usuário, quero que todo subagente despachado por uma skill receba a linha
   de idioma no brief, para que o relatório já volte no idioma certo.
7. Como usuário, quero que relatório de subagente que voltar em outro idioma seja
   reescrito antes de chegar ao chat, para que "verbatim" de uma skill vendorizada
   não vire porta de entrada do inglês.
8. Como usuário do `tea-open-pr`, quero que o corpo do PR continue em inglês e que
   o que a skill me diz no chat saia em pt-BR, para que a regra do PR não vaze para
   a conversa.
9. Como usuário do omp, quero que a regra de idioma valha igual à do Claude Code,
   para que trocar de harness não troque o idioma.
10. Como operador do `anvil-run`, quero que o `anvil-implementer` relate em pt-BR,
    para que o relatório final do supervisor não misture idiomas.
11. Como usuário de um projeto que declarou outro idioma de comunicação nas rules,
    quero que esse idioma valha no lugar do pt-BR, para que a regra continue
    configurável por projeto.
12. Como usuário, quero que identificador, comando, caminho e nome de skill citados
    no chat fiquem como são, para que eu possa copiá-los.
13. Como mantenedor do anvil, quero corrigir o idioma sem traduzir nem adaptar
    skill vendorizada, para não quebrar a regra do catálogo fechado.

### Instalação por usuário

14. Como usuário com vários projetos, quero rodar o `/anvil-update` uma vez e ter
    todos os projetos na versão nova, para não visitar projeto por projeto.
15. Como usuário, quero que o `/anvil-boot` instale o toolkit no nível de usuário
    quando ele ainda não estiver lá, para que o primeiro projeto já deixe a máquina
    pronta.
16. Como usuário, quero que o `/anvil-boot` num projeto novo escreva só rules e
    perfis, para que o projeto não carregue cópia do toolkit.
17. Como usuário, quero que o Claude Code ache as skills do anvil no diretório de
    skills do usuário, para que funcionem em qualquer projeto da máquina.
18. Como usuário do omp, quero que o omp ache as skills, os agentes, as rules e os
    hooks do anvil no diretório de usuário do omp, sem eu ligar provider à mão, para
    que o omp rode o anvil como roda hoje.
19. Como usuário do Codex, quero que o espelho de skills passe a ser o de usuário,
    para que o Codex continue achando o payload.
20. Como usuário, quero que as rules do projeto continuem por projeto, para que
    cada projeto mantenha idioma, comando de verificação, modelos por papel e stack
    próprios.
21. Como usuário, quero que as diretivas do anvil cheguem a toda sessão sem estar
    copiadas no `CLAUDE.md` de cada projeto, para que uma diretiva nova chegue a
    todos com um update.
22. Como usuário, quero que o conteúdo do meu `CLAUDE.md` fora do bloco do anvil
    fique intacto, para não perder instrução do projeto.
23. Como usuário, quero que a guarda de merge continue barrando merge de spec com
    ticket aberto ou sem archive, agora instalada uma vez por usuário, para não
    perder a única barreira de fechamento.
24. Como usuário, quero que a guarda global não faça nada num repositório que não
    é projeto anvil, para que ela não atrapalhe `git merge` em outros repositórios.
25. Como usuário do omp, quero que o hook da guarda ache o script na instalação de
    usuário, para que ele não deixe passar em silêncio por causa de um caminho
    errado.
26. Como usuário, quero que os scripts que as skills mandam rodar — reserva de
    número da spec, validação de docs, gates do bench — funcionem a partir do
    projeto com o toolkit instalado no usuário, para que o fluxo não quebre.
27. Como usuário, quero que os perfis gerados em `docs/agents/` citem os scripts
    pelo caminho que existe, para que o agente que lê o perfil ache o script.
28. Como usuário de um projeto antigo, quero que o update me avise quando um perfil
    de `docs/agents/` cita caminho da instalação por projeto, para saber que devo
    rodar o boot.
29. Como usuário, quero que o update calcule órfãos pelo lock de usuário, para que
    skill que saiu do payload saia da máquina.
30. Como usuário, quero que skill e agente que eu mesmo escrevi no diretório de
    usuário fiquem intocados pelo update, como hoje acontece no projeto.
31. Como usuário, quero que o dry-run continue obrigatório e liste o que será
    substituído, removido e preservado no nível de usuário, para revisar antes do
    reset — agora sem git por trás.
32. Como usuário, quero que a camada omp entre na instalação de usuário quando há
    sinal de omp na máquina e fique depois disso, para manter o comportamento
    pegajoso de hoje.
33. Como usuário de um projeto instalado do jeito antigo, quero que o `/anvil-update`
    rodado nele migre o projeto, para não fazer limpeza à mão.
34. Como usuário, quero que a migração remova do projeto as skills, os agentes, o
    lock, os symlinks do espelho, os arquivos da camada omp e o hook que o anvil
    instalou, guiada pelo lock do projeto, para que nada velho sombreie a versão de
    usuário.
35. Como usuário, quero que a migração remova só o bloco de diretivas do
    `CLAUDE.md`, entre os marcadores, para que o resto do arquivo fique.
36. Como usuário, quero que a migração preserve skill, agente, rule e arquivo de
    `.omp/` que eu escrevi, mesmo com a instalação antiga sem lock, perguntando o
    que não veio do anvil antes de apagar.
37. Como usuário, quero que a migração passe por dry-run e espere aprovação, para
    revisar a remoção no `git status` antes de commitar.
38. Como usuário, quero que o update nunca commite, nem na migração, para que o
    diff de remoção seja meu.
39. Como usuário, quero que o `/anvil-boot` rodado num projeto antigo também migre,
    para que qualquer porta de entrada leve ao mesmo estado.
40. Como usuário, quero que o update rode de qualquer diretório quando não há
    projeto para migrar, para atualizar a máquina sem abrir um projeto específico.
41. Como colaborador que clona um projeto anvil, quero saber que o toolkit não vem
    no clone e como instalá-lo, para não achar que o projeto está quebrado.
42. Como mantenedor do anvil, quero que a máquina de desenvolvimento ligue a
    instalação de usuário à fonte do payload, para que este repositório e os outros
    projetos da máquina rodem a skill que estou editando.
43. Como mantenedor, quero que o `dev-link` desfaça essa ligação com `--unlink`,
    para voltar a uma instalação publicada.
44. Como mantenedor, quero que o `/anvil-update` se recuse a instalar por cima de
    uma instalação de desenvolvimento, para não escrever o payload publicado dentro
    da fonte através de um symlink.
45. Como mantenedor, quero um ADR que registre a revogação do toolkit versionado no
    projeto, para que a próxima pessoa saiba por que o clone não traz mais o
    toolkit.

### Cauda do `anvil-next`

46. Como usuário, quero que o `anvil-next` rode sozinho no fim do `anvil-to-spec`,
    para já ter o prompt dos tickets.
47. Como usuário, quero o mesmo no fim do `anvil-to-tickets`, para já ter o prompt
    de implementação.
48. Como usuário, quero o mesmo no fim do `anvil-implement` rodado direto na
    sessão, depois de gravada a linha `Review:`, para seguir para o próximo ticket
    ou para a correção.
49. Como operador do `anvil-run`, quero que o relatório final termine com o bloco
    do `anvil-next`, no lugar da recomendação em texto, para colar a próxima sessão
    direto.
50. Como usuário, quero o mesmo no fim do `anvil-browser-qa`, do `anvil-diagnose`
    e do `anvil-prototype`.
51. Como usuário, quero o mesmo no fim do `/anvil-docs archive`, do `tea-open-pr` e
    do `tea-open-fast-pr`, para fechar a spec sabendo o passo seguinte.
52. Como usuário, quero que a cauda não rode dentro de subagente nem dentro do
    `anvil-implementer`, para que só a sessão principal gere o prompt.
53. Como usuário, quero que a cauda não rode quando a skill para para me perguntar
    algo, para não receber um prompt de próxima sessão no meio de uma decisão.
54. Como usuário, quero que a cauda não rode no `tea-commit`, no `anvil-tdd`, no
    `anvil-code-review` nem no `anvil-handoff`, para não ganhar ruído em passo
    frequente, interno ou que já é a forma longa.
55. Como usuário, quero continuar chamando o `anvil-next` à mão em qualquer
    momento, com foco opcional, como hoje.
56. Como usuário, quero que o bloco da cauda respeite o formato do `anvil-next` —
    um bloco de até 120 palavras, alternativas opcionais —, para que seja igual ao
    que chamo à mão.
57. Como usuário do omp, quero a cauda funcionando lá também, para que o fluxo do
    omp e o do Claude Code terminem igual.
58. Como mantenedor, quero a lista de skills com cauda num lugar só, para mudar a
    lista sem editar skill.

## Implementation Decisions

### Idioma

- **A seção de idioma da diretiva ganha escopo explícito.** O idioma de
  comunicação vale para toda saída que chega ao chat: conclusão de skill,
  relatório de subagente repassado, veredito, resumo de saída de ferramenta. O
  idioma de comunicação vem das rules do projeto; sem declaração, pt-BR.
- **"Verbatim" de skill é sobre conteúdo, não idioma.** Repassar relatório de
  subagente preserva o achado e o formato; a prosa sai no idioma de comunicação.
- **Chave de formato estável não se traduz.** A linha `Review:` e suas chaves,
  classes como `P1`, cabeçalhos que outra peça lê, identificadores, comandos,
  caminhos e nomes de skill ficam como estão. O resto se traduz.
- **Todo brief de subagente leva a linha de idioma de saída**, inclusive quando a
  skill dá o brief literal em inglês. A diretiva manda acrescentá-la ao despachar.
- **Regra de idioma de artefato não vaza para o chat.** O `tea-open-pr` e o
  `tea-open-fast-pr`, autorais, escrevem que o inglês vale para título, corpo e
  commit do PR, e que o que dizem ao usuário segue o idioma de comunicação.
- **O agente `anvil-implementer` do omp**, autoral, declara o idioma do relatório
  que devolve. As chaves do retorno ficam como estão.
- **Nenhuma skill vendorizada muda**, e nenhuma regra nova entra no catálogo de
  adaptação. O `anvil-code-review`, o `anvil-diagnose`, o `anvil-how` e o
  `anvil-architect` ficam como estão; a diretiva cobre o que eles despacham e
  repassam.
- **Mesma regra nos dois harnesses.** A diretiva chega ao Claude Code e ao omp pelo
  caminho decidido em "Diretivas" abaixo.

### Instalação por usuário

**O que fica onde.**

| Peça | Hoje, no projeto | Passa a morar |
|---|---|---|
| Skills do payload | `.claude/skills/` | diretório de skills do usuário do Claude Code, `~/.claude/skills/` |
| Agentes do payload | `.claude/agents/` | `~/.claude/agents/` |
| Lock | `.claude/anvil.lock` | um lock de usuário, ao lado das skills |
| Espelho do Codex | `.agents/skills/` | `~/.agents/skills/`, um symlink por skill |
| Camada omp | `.omp/{skills,rules,agents,hooks/pre}` | diretório de usuário do omp, `~/.omp/agent/{skills,rules,agents,hooks/pre}` |
| Diretivas | bloco `ANVIL:DIRECTIVES` no `CLAUDE.md` do projeto | nível de usuário, ver "Diretivas" |
| Guarda de merge (Claude Code) | hook em `.claude/settings.json` + cópia do script | hook nas settings do usuário, chamando o script da instalação de usuário |
| Rules, perfis, `docs/` | projeto | **projeto, sem mudança** |

**Descoberta.** O Claude Code lê skills e agentes do usuário sem configuração. O
omp lê `~/.omp/agent/{skills,rules,agents,hooks/pre}` nativamente, mas o diretório
de skills de usuário do Claude Code é um provider estrangeiro que o omp só lê com
opt-in. Por isso o payload chega ao omp pelo espelho `~/.agents/skills`, que o
provider `agents` lê por padrão, e o omp deduplica pelo caminho real. A
implementação confirma isso num omp real antes de fechar; se o espelho não bastar,
o payload ganha symlinks em `~/.omp/agent/skills/` também.

**Diretivas.** O bloco de diretivas sai do `CLAUDE.md` do projeto e vai para o
nível de usuário: um bloco entre os mesmos marcadores no `~/.claude/CLAUDE.md`, que
o Claude Code carrega em toda sessão, e uma rule `alwaysApply` na camada omp de
usuário, porque o omp não lê o `CLAUDE.md` de usuário sem opt-in e o
`~/.omp/agent/AGENTS.md`, quando existe, sombreia os arquivos de usuário de outros
harnesses. O texto é um só; as duas cópias saem da mesma fonte do payload. A
diretiva continua mandando ler `.claude/rules/*.md` do projeto.

**Precedência.** No Claude Code, skill de usuário vence skill de projeto com o
mesmo nome. Uma cópia velha no projeto fica inerte no Claude Code, mas é entulho,
e no omp a camada do projeto pode vencer a de usuário. Por isso a migração limpa
o projeto em vez de confiar na sombra.

**`/anvil-boot`.**

- Garante a instalação de usuário: instala se não houver; se houver, segue e
  aponta o `/anvil-update` para trocar de versão.
- Escreve no projeto só o que é do projeto: rules, perfis em `docs/agents/` e a
  árvore de `docs/`.
- Deixa de escrever o bloco de diretivas no `CLAUDE.md` do projeto e de instalar
  hook nas settings do projeto.
- Num projeto com instalação antiga, roda a migração descrita abaixo.

**`/anvil-update`.**

- Reinstala a instalação de usuário do zero, como reset, com órfãos pelo lock de
  usuário. Skill, agente e arquivo da camada omp fora do lock ficam intocados; a
  colisão de nome continua destacada no dry-run.
- Dry-run obrigatório e aprovação antes de executar. Não há git no diretório de
  usuário, então o relato lista por nome tudo que foi trocado e removido.
- Roda de qualquer diretório. Dentro de um projeto com instalação antiga, migra
  esse projeto na mesma execução, com dry-run e aprovação próprios. Fora de
  projeto, só atualiza o usuário.
- Continua conferindo, no projeto onde roda, perfis de `docs/agents/` que divergem
  do template novo, e passa a acusar perfil que cita script por caminho da
  instalação por projeto.
- Recusa instalar por cima de instalação de desenvolvimento: entrada do payload
  no diretório de usuário que é symlink. A mensagem aponta o `dev-link --unlink`.
- A camada omp entra quando há sinal de omp na máquina — binário `omp` no `PATH`
  ou `~/.omp/` — ou quando o lock de usuário já a registra, que a torna pegajosa.
- Nunca commita.

**Migração de projeto antigo**, um projeto por vez, disparada pelo update ou pelo
boot rodado nele:

- remove as skills e os agentes listados no lock do projeto, o próprio lock, os
  symlinks do espelho `.agents/skills` com nome de skill do payload, os arquivos da
  camada em `.omp/` listados em linhas `omp:`, a entrada do hook da guarda nas
  settings do projeto e a cópia do script da guarda;
- remove o bloco de diretivas do `CLAUDE.md` do projeto, só entre os marcadores;
- sem lock no projeto, mostra as skills e os agentes presentes e pergunta quais não
  vieram do anvil antes de apagar qualquer coisa, como o update já faz hoje;
- preserva rules, perfis, `docs/`, settings fora da entrada do hook, `CLAUDE.md`
  fora do bloco e tudo que é do usuário;
- exige árvore limpa no projeto, como o preflight de hoje, para que o diff da
  remoção seja revisável.

**Caminhos.** Toda instrução autoral que manda rodar script por caminho relativo ao
projeto passa a resolver o script na instalação de usuário: reserva de número da
spec citada pelo `tea-open-fast-pr` e pelo perfil do tracker, validação de docs
citada pelo `tea-open-pr` e pela guarda, gates do `anvil-bench`, e os verbos do
`reset-install` citados pelo boot. O template do perfil do tracker muda junto. Os
scripts continuam resolvendo a raiz do **projeto** por `git` ou pelo diretório
corrente, nunca subindo níveis a partir do próprio arquivo; o `infra.sh` do
`anvil-stack-payload`, que hoje sobe quatro níveis, passa a resolver a raiz assim.
Prosa que cita o caminho antigo se atualiza no mesmo passo.

**Guarda de merge.** Uma instalação por usuário, nos dois harnesses. Num
repositório que não é projeto anvil, sai sem fazer nada e sem mensagem; o
marcador de projeto anvil é a rule de configuração do anvil que o boot escreve. Num
projeto anvil, a raiz continua vindo do projeto e o validador vem da instalação de
usuário. O hook do omp resolve o script na instalação de usuário; script ausente
num projeto anvil é aviso visível, não passagem silenciosa.

**Máquina de desenvolvimento.** O `dev-link` passa a ligar a instalação de usuário
à fonte: `~/.claude/skills/<skill>` do roster, os agentes, o espelho em
`~/.agents/skills` e a camada omp em `~/.omp/agent/` viram symlinks para o
payload deste repositório. Todo projeto da máquina roda a fonte em edição — é a
escolha, e o risco é skill editada pela metade chegar aos outros projetos. O
`--unlink` desfaz, e o `--all` continua ligando o payload inteiro. Os symlinks de
projeto em `.claude/skills/anvil-*` deixam de ser criados; o `anvil-sync`, que é
ferramenta do repositório e não vai no payload, fica onde está. O `anvil-update`
segue fora do roster: não estar ligado continua sendo a trava, agora reforçada
pela recusa diante de instalação de desenvolvimento.

**ADR.** Um ADR novo revoga o ADR-0009 — o toolkit instalado fica versionado no
projeto — e emenda o ADR-0011 — camada omp instalada por projeto e pegajosa pelo
lock do projeto. Consequências que o ADR registra: o clone não traz o toolkit;
não há pin de versão por projeto; todos os projetos da máquina rodam a mesma
versão, que é o objetivo. As rules do repositório (`project.md`, a tabela "Fonte e
derivado" e a seção "Nunca rode `/anvil-update` aqui") e o glossário mudam junto:
o **Payload** deixa de ser "o que o anvil copia para um projeto", a **Camada de
harness** deixa de ser "instalada no projeto", e entram **Instalação de usuário**
e **Instalação de projeto antiga**.

### Cauda do `anvil-next`

- **Uma seção da diretiva global**, chamada cauda de roteamento, lista as skills
  com cauda e a regra de disparo. É o único ponto que alcança skill vendorizada
  sem adaptá-la, e o único lugar a editar para mudar a lista.
- **Lista:** `anvil-to-spec`, `anvil-to-tickets`, `anvil-implement`,
  `anvil-run`, `anvil-browser-qa`, `anvil-diagnose`, `anvil-prototype`,
  `anvil-docs` no verbo `archive`, `tea-open-pr` e `tea-open-fast-pr`.
- **Regra de disparo:** quando uma skill da lista chega ao fim, com sucesso ou
  bloqueada, a sessão principal invoca o `anvil-next` sem argumento, na mesma
  resposta, depois da conclusão da skill. Não dispara em subagente, dentro do
  `anvil-implementer` nem quando a skill para numa pergunta ao usuário.
- **`anvil-implement`** só tem cauda rodado direto na sessão. A cauda vem depois da
  linha `Review:` gravada, com o veredito, seja `pass` ou `fail`.
- **`anvil-run`**, autoral, troca a recomendação de próximo passo em texto pela
  invocação do `anvil-next`, passando como foco a rota que ele já calcula — QA de
  browser quando há tela, archive quando não há. Só no relatório final, nunca por
  despacho.
- **O `anvil-next` perde a trava de invocação.** A descrição passa a dizer que ele
  roda pela cauda de roteamento ou a pedido do usuário, para que o modelo não o
  dispare fora disso. O formato de saída não muda.
- **Nenhuma skill da lista é editada para ganhar a cauda**, salvo o `anvil-run`,
  cuja recomendação em texto é substituída.

## Testing Decisions

Um bom teste aqui observa o que o usuário veria: a árvore de arquivos no diretório
de usuário e no projeto depois do boot, do update e da migração, a decisão da
guarda, e a resposta que chega ao chat. Não confere texto de skill nem a ordem
interna do script.

**Seam 1 — instalação.** O `reset-install` e os passos do boot rodados com `HOME`
apontando para um diretório temporário, contra projetos-fixture. Cobre:

- boot num projeto novo sem instalação de usuário: o toolkit aparece em `HOME`, o
  projeto recebe só rules e perfis, nenhum bloco no `CLAUDE.md` do projeto, nenhum
  hook nas settings do projeto;
- update com instalação de usuário existente: skill que saiu do payload sai de
  `HOME`; skill do usuário fora do lock fica; colisão aparece no dry-run;
- migração de projeto antigo com lock: tudo que o lock lista sai do projeto, rule,
  perfil, `docs/`, `CLAUDE.md` fora do bloco e skill do usuário ficam;
- migração sem lock: nada é apagado antes da resposta sobre o que não veio do
  anvil;
- sinal de omp: camada aparece em `HOME/.omp/agent/`; sem sinal e sem linha no
  lock, não aparece; com linha no lock e sem sinal, fica;
- instalação de desenvolvimento em `HOME`: o update recusa e não escreve nada;
- guarda: num repositório sem marcador de projeto anvil, `git merge` passa sem
  mensagem; num projeto anvil com ticket aberto, bloqueia, chamando o validador da
  instalação de usuário; o hook do omp acha o script;
- caminhos: a reserva de número da spec roda a partir de um projeto-fixture com o
  toolkit só em `HOME`; o bench resolve a raiz do projeto, não `HOME`.

Arte anterior: os cenários manuais de infraestrutura em `workspace/01-…08-` —
degit, `reset-install`, guarda de merge, boot, adopt, lock —, o dry-run do
`reset-install` e o modo `GUARD_DECIDE_ONLY` da guarda. O `vendor-sync.sh verify`
continua passando: nenhuma skill vendorizada muda.

**Seam 2 — idioma e cauda.** Cenário manual em `workspace/`, sem suíte: rodar o
harness headless não é determinístico e custaria mais que o que protege.

- `anvil-code-review` com os dois eixos num projeto pt-BR: os relatórios chegam em
  pt-BR, a linha `Review:` com as chaves de sempre;
- `anvil-diagnose` e `anvil-browser-qa`: narrativa e conclusão em pt-BR;
- `tea-open-pr`: corpo do PR em inglês, o que chega ao chat em pt-BR;
- projeto com outro idioma nas rules: a saída segue esse idioma;
- cauda: aparece no fim do `anvil-to-spec`, do `anvil-implement` rodado direto e
  do `/anvil-docs archive`; não aparece no `tea-commit`, nem dentro do
  `anvil-implementer`, nem quando a skill termina numa pergunta;
- os mesmos casos no omp, incluindo o relatório final do `anvil-run`.

## Out of Scope

- **Migração em lote.** Passar uma lista de projetos ou varrer um diretório para
  migrar vários de uma vez. Cada projeto antigo migra quando o update ou o boot
  roda nele.
- **Seleção de skills por projeto.** Ligar ou desligar skill num projeto. Hoje não
  existe, e a instalação de usuário continua com o payload inteiro.
- **Pin de versão por projeto.** O projeto não registra em que versão do anvil foi
  trabalhado.
- **Traduzir skill vendorizada** ou criar regra de adaptação nova para idioma ou
  cauda.
- **Hook de fim de skill.** Não há evento de fim de skill no Claude Code nem no
  omp, e o `Stop` dispara a cada turno.
- **Diretivas no Codex.** O Codex continua recebendo skills pelo espelho; como ele
  recebe as diretivas não muda nesta spec.
- **Teste automatizado de idioma e cauda.**
- **Cauda no `anvil-wayfinder`, no `anvil-grill` e no `anvil-architect`.**
  Ficaram fora da lista; entram editando a lista da diretiva.

## Further Notes

- A precedência de skill de usuário sobre skill de projeto no Claude Code é fixa
  hoje, com pedido aberto para torná-la configurável
  ([anthropics/claude-code#22208](https://github.com/anthropics/claude-code/issues/22208)).
  Se isso mudar, a migração continua necessária pelo lado do omp.
- Ponto de atenção da escolha de desenvolvimento: com a instalação de usuário
  ligada à fonte, uma edição em andamento no payload vale na hora em todos os
  projetos da máquina, inclusive no meio de uma sessão aberta em outro projeto
  quando a skill for relida.
- O texto da diretiva precisa caber nos dois harnesses: no omp, a rule
  `anvil-harness` já traduz o vocabulário do Claude Code — `Skill tool`, subagente,
  `AskUserQuestion` —, e a cauda depende dessa tradução para invocar o
  `anvil-next`.
- O `anvil-bench` é o único lugar que já repete a regra de idioma para a saída de
  chat; serve de referência de redação.
