# 002 — O custo de verificar como dado do projeto

**Status:** ready-for-agent
**Branch:** `feature/adjust-code-review` — a spec corre no branch já aberto, por
decisão do usuário; o número `002` não foi reservado no `origin` pelo
`new-spec.sh`

## Problem Statement

Um projeto instalado com o anvil diagnosticou uma verificação que ficava mais
lenta a cada ticket, e registrou a decisão num ADR. Quatro coisas que o toolkit
poderia ter evitado aparecem ali:

1. **O custo escrito errado decidiu o comportamento.** As rules prometiam `~80s`
   para a suíte, e ela levava ~20 min: 14,6× de diferença. O número estava
   repetido em quatro arquivos. Pessoa e agente rodavam a suíte inteira a cada
   conferida *porque eram 80 segundos*. O `anvil-boot` grava hoje o "comando de
   teste" no `anvil.md` sem custo nenhum, e nada impede que o número se espalhe
   e envelheça.
2. **"A suíte inteira no fim" é ambíguo.** O `anvil-implement` herda do upstream
   *"the full test suite once at the end"*, que não diz se o fim é o do ticket ou
   o da spec. Validar por spec parece mais barato em CPU, mas transforma uma
   falha numa bissecção entre N tickets já entrelaçados. Também nada diz que o
   gate pode rodar em background.
3. **A revisão lia arquivo gerado.** Dois terços do diff de uma spec eram
   snapshots do Drizzle, sem uma linha revisável. O `anvil-code-review` captura
   `git diff` cru, e nada no boot aponta o problema.
4. **Talvez falte uma cilada do Payload na rule da stack.** Com `--no-isolate`,
   a suíte fica verde na primeira rodada e falha uma vez em três com
   `--sequence.shuffle`: coleções importadas são mutadas em pós-processamento, e
   a mutação de um arquivo alcança o outro. Quem não sabe disso aceita um ganho
   de 40% que introduz dependência de ordem e depois conserta o arquivo errado.
   **A atribuição ao Payload não está provada.** O caso medido tem
   pós-processamentos próprios do projeto além dos plugins, e o arquivo que
   quebrou é o do plugin multi-tenant. Pode ser do Payload, do plugin ou da
   customização.

## Solution

O custo de verificar vira dado do projeto: medido, datado e escrito num lugar
só. O critério de quando rodar o quê vira parte do perfil de verificação que as
skills já leem.

- O `anvil-boot` mede o comando de verificação na instalação e grava o tempo,
  com data e máquina, **só** no `anvil.md`. Os outros arquivos apontam para ele.
  Junto vai a instrução: quem medir diferente corrige ali, no mesmo commit.
- O perfil de verificação ganha uma seção sobre o custo: o gate é **por
  ticket**, roda em background e não bloqueia, e há uma rodada antes do merge
  que pega a interação entre tickets. A divisão entre laço curto e gate fica
  descrita como o passo seguinte, que se adota **quando o laço passar de ~2 min**,
  e não na instalação.
- Na varredura, o `anvil-boot` detecta arquivos gerados grandes e versionados e
  **propõe** um `.gitattributes` que os tira do diff, com o tamanho medido como
  evidência. O `anvil-code-review` não muda: o `git diff` que ele captura já
  respeita o atributo.
- A cilada do `--no-isolate` é reproduzida primeiro num projeto Payload puro.
  Ela entra no `RULE.md` do `anvil-stack-payload` **só se reproduzir**, e com o
  escopo que a reprodução mostrar: Payload em geral, ou só quem usa o plugin.

## User Stories

1. Como agente trabalhando num projeto, quero ler no `anvil.md` quanto a
   verificação custa, medido e datado, para decidir quantas vezes rodá-la sem
   adivinhar.
2. Como agente, quero que o custo esteja escrito num lugar só, para que ele não
   divirja entre arquivos que ninguém atualiza juntos.
3. Como mantenedor do projeto, quero que o `anvil-boot` meça o comando de
   verificação em vez de estimá-lo, para que o primeiro número já seja
   verdadeiro.
4. Como mantenedor, quero que o número venha com data e máquina, para saber se
   ainda vale quando a suíte crescer ou quando outra máquina rodar.
5. Como pessoa que mede a suíte e acha outro número, quero uma instrução
   explícita de corrigir o `anvil.md` no mesmo commit, para que a divergência
   não sobreviva.
6. Como mantenedor de um projeto adotado, com `anvil.md` já existente, quero que
   o boot **proponha** acrescentar o custo que falta, sem trocar o comando já
   configurado.
7. Como mantenedor, quero que o boot aponte custo de verificação repetido em
   `CLAUDE.md`, `project.md` ou outras rules e proponha trocar a repetição por
   um ponteiro, para que a duplicação não se instale.
8. Como agente implementando uma spec, quero saber que o gate roda ao fim de
   **cada ticket**, para que uma falha tenha um culpado e não uma bissecção.
9. Como agente, quero saber que o gate pode rodar em background enquanto sigo
   com commit e documentação, para que o tempo de máquina não vire tempo de
   espera.
10. Como agente, quero saber que existe uma rodada da suíte inteira antes do
    merge, sobre o branch completo, para pegar a interação entre tickets que
    nenhum gate individual viu.
11. Como mantenedor de um projeto novo, quero que o toolkit **não** instale a
    divisão entre laço curto e gate no primeiro dia, para que ela não vire
    cerimônia numa suíte que ainda cabe no laço.
12. Como mantenedor de um projeto cuja suíte cresceu, quero ler no perfil o sinal
    de adotar o laço curto — passar de ~2 min — e o que ele exige, para saber
    quando e como dividir.
13. Como mantenedor que adota o laço curto, quero que o `anvil.md` comporte dois
    comandos, `laço` e `gate`, cada um com seu custo medido, para que as skills
    e as pessoas saibam qual rodar em cada momento.
14. Como mantenedor, quero que o perfil deixe explícito que a seleção do laço
    curto **adia** a descoberta e nunca dispensa o gate, para que a otimização
    não vire redução de cobertura.
15. Como agente revisando código, quero que o diff não traga snapshot, lockfile
    ou código gerado, para gastar a revisão no que é revisável.
16. Como mantenedor, quero que o boot mostre quais arquivos gerados achou e
    quanto eles pesam no diff, para aprovar o `.gitattributes` com evidência.
17. Como mantenedor, quero que o boot só **proponha** o `.gitattributes` e
    espere aprovação, e que mescle com um arquivo já existente sem sobrescrever.
18. Como mantenedor, quero saber que tirar um arquivo do diff é apresentação e
    não conteúdo, e como vê-lo quando preciso (`git diff --text`), para não
    achar que ele deixou de ser versionado.
19. Como agente revisando, quero que o arquivo escrito à mão ao lado do gerado,
    como o `.ts` da migration, continue no diff, para que a regra que a suíte
    cobra continue revisável.
20. Como agente num projeto Payload, quero ler na rule da stack, se a
    reprodução confirmar, que `--no-isolate` introduz dependência de ordem,
    para não aceitar o ganho aparente.
21. Como agente num projeto Payload, quero saber qual é a causa que a
    reprodução confirmou, e que o arquivo que quebra é a vítima, para não
    consertar o arquivo errado.
22. Como mantenedor do anvil, quero que a cilada só entre depois de reproduzida
    num projeto Payload sem customização, para que a rule da stack não carregue
    um fato de um projeto só.
23. Como agente, quero saber que `--sequence.shuffle` com isolamento é o controle
    positivo que separa "a suíte é frágil" de "a flag introduziu a fragilidade".
24. Como mantenedor do anvil, quero que nenhuma destas mudanças toque uma skill
    vendorizada, para que o merge 3-way com o upstream continue limpo.
25. Como mantenedor do anvil, quero que o `docs/agents/verification.md` do
    próprio repositório continue idêntico ao template, para que o boot não
    aponte divergência no anvil.

## Implementation Decisions

- **Só skills autorais e arquivos do anvil.** Mudam o `anvil-boot`, o template
  do perfil de verificação do `anvil-docs` e o `RULE.md` do
  `anvil-stack-payload` (arquivo `keep`, do anvil). O `anvil-implement` e o
  `anvil-code-review` são vendorizados e **não mudam**. A ambiguidade do
  *"once at the end"* se resolve no perfil que eles já leem, não no texto deles.
  O `reference/` do `anvil-stack-payload` é upstream e fica intocado.
- **O custo mora no `anvil.md`, na seção do comando de verificação.** Ela passa
  a ter: o comando, o custo medido, a data, a máquina e a instrução de correção
  no mesmo commit. É a única fonte. `project.md` e `CLAUDE.md` descrevem **como**
  rodar os testes, mas apontam para o `anvil.md` quando falam de **custo**.
- **A medição é uma rodada real do comando na instalação.** Se o comando falhar
  ou não puder rodar (sem banco, sem dependência instalada), o boot grava o
  comando sem custo e diz por quê. Número estimado não se grava: número inventado
  é o defeito que a spec corrige.
- **Com `anvil.md` já existente**, vale a regra atual do passo 4: valor
  configurado não se troca. Custo ausente se propõe. Custo presente e divergente
  do medido se mostra, e a troca espera aprovação.
- **O perfil de verificação ganha a seção do custo**, ao lado das que já tem
  (classe, orçamento de rodadas, persistência). O conteúdo:
  - o gate é a suíte inteira mais o typecheck, **uma vez por ticket**, e nunca
    uma vez por spec, com o argumento da bissecção;
  - o gate roda em background e não bloqueia o próximo passo;
  - há uma rodada antes do merge sobre o branch completo;
  - o laço curto, com o sinal de adoção (~2 min), a forma genérica (o que é
    barato e transversal roda inteiro; só o caro se seleciona, numa invocação
    só) e o aviso de que a seleção adia e não dispensa o gate.
  - Nenhum número de projeto entra no perfil. O custo esperado de cada projeto
    é o que o `anvil.md` dele mede.
- **O `docs/agents/verification.md` do anvil é atualizado junto com o template**
  e fica idêntico a ele.
- **A detecção de gerados é heurística e declarada.** O boot procura arquivos
  versionados que são gerados por convenção conhecida (snapshots de migration,
  lockfiles, saída de codegen) ou por marca no próprio arquivo, e mede o peso de
  cada um no histórico recente do diff. Lista o que achou, com tamanho e
  proporção, e propõe as linhas `-diff linguist-generated=true`. Sem achado
  relevante, não propõe nada.
- **O `.gitattributes` se mescla, nunca se sobrescreve**, como o boot já faz com
  o `settings.json`.
- **A cilada do `--no-isolate` é condicionada a uma reprodução.** Antes de
  tocar o `RULE.md`, monta-se em `workspace/` um projeto Payload sem
  customização, com o plugin multi-tenant e uma suíte de teste que importe as
  coleções. Roda-se `--no-isolate --sequence.shuffle` várias vezes, e o
  controle positivo é `--sequence.shuffle` com isolamento. O resultado decide:
  - **reproduz sem o plugin** → cilada do Payload, sem ressalva;
  - **reproduz só com o plugin** → cilada que nomeia o plugin como condição;
  - **não reproduz** → não entra. O resultado fica registrado nos `## Comments`
    do ticket, para que ninguém repita o teste.

  Se entrar, segue o formato das três primeiras (sintoma, causa, jeito certo), e
  o título "As três ciladas" vira "As quatro ciladas". O `push` condicional no adapter **não** entra: é uma escolha com perda
  declarada (campo sem migration passa a quebrar), não uma cilada. Fica de fora
  desta spec.

## Testing Decisions

- O repositório não tem suíte. A verificação automática é
  `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`. Ela precisa
  continuar verde e é a prova de que nenhuma skill vendorizada foi tocada.
- **Seam do boot: um cenário manual de boot em `workspace/`.** O
  `project.md` cita os cenários `01-…08-`, mas hoje o `workspace/` não os
  contém, e o de boot precisa ser recriado. Ele é exercitado em dois projetos
  descartáveis:
  - um projeto com suíte que roda e com um arquivo gerado grande versionado: o
    `anvil.md` sai com custo medido e datado, e o boot propõe o
    `.gitattributes` com a evidência;
  - um projeto adotado com `anvil.md` já existente e custo repetido em outra
    rule: o boot propõe e não troca, e aponta a repetição.
- **Seam do perfil: igualdade de arquivo.** `docs/agents/verification.md` é
  idêntico a `anvil-docs/templates/verification-anvil.md`, a mesma conferência
  que o passo 6 do boot já faz.
- **Seam da rule Payload: a reprodução em projeto puro.** Ela é o teste e vem
  antes da escrita. Se a cilada entrar, segue o formato das outras e não cita
  número de projeto.
- Um bom teste aqui mede o que a pessoa ou o agente **lê** depois do boot, não
  como o boot chegou lá.

## Out of Scope

- O script de laço curto, a heurística de seleção por nome e os números
  medidos. Não entram no `anvil-stack-payload` nem em outra skill: a seleção
  depende da convenção de nome e da estrutura de pastas de um projeto
  específico, não do Payload.
- O banco por worker, o `TRUNCATE` e o `--pool=threads`. Também não entram no
  `anvil-stack-payload`: dependem do setup de teste do projeto (globalSetup,
  bancos, `fileParallelism`), não do Payload.
- O `push: NODE_ENV !== 'test'` no adapter do Payload.
- Mudança em `anvil-implement`, `anvil-code-review`, `anvil-diagnose` ou
  qualquer outra skill vendorizada.
- O método de medição do ADR (controle positivo, atalhos medidos e descartados,
  sinais de revisitar) como orientação de ADR no `anvil-docs`. O `anvil-docs`
  não tem template de ADR, e criar um é outra spec.

## Further Notes

- A decisão "gate por ticket, em background, com rodada antes do merge" muda o
  critério de verificação que o ADR-0010 do anvil — a verificação tem critério
  de parada — começou a escrever. No `archive`, ela é candidata a virar ADR
  próprio (`0011`), com as perdas declaradas: o gate por ticket gasta mais CPU
  que o gate por spec, de propósito.
