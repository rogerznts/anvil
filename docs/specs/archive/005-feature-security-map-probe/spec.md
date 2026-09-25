# 005 — Mapa de superfície de ataque e teste local com spec de correção

**Status:** ready-for-agent
**Branch:** `feature/adjust-code-review` — a spec corre no branch já aberto, por
decisão do usuário; o número `005` foi reservado no `origin` pelo `new-spec.sh`,
e o branch que ele criou foi apagado

## Problem Statement

Um projeto com o anvil instalado não tem como saber, pelo toolkit, onde está
exposto. O anvil tem pedaços soltos de segurança: as ciladas do
`anvil-stack-payload` (Local API sem `overrideAccess: false` ignora access
control) e o prefixo `SEC-#` que o `anvil-bench` reserva para achados. Nada gera
esses achados.

Quem quer testar a segurança do projeto hoje:

- não sabe quais rotas e entradas existem, nem quais delas são vetor de SQL
  injection, IDOR, SSRF ou upload malicioso. No Payload, o REST e o GraphQL saem
  gerados por collection, então a superfície é maior do que o código mostra;
- roda scanner genérico, que não conhece as ciladas da stack e não pega falha de
  autorização entre usuários ou tenants;
- corre o risco de apontar o scanner para o ambiente errado, ou de sujar o banco
  de dev com carga de teste;
- recebe achado solto, sem reprodução, que não vira trabalho rastreável.

O Payload já teve essas classes no próprio núcleo: SQL injection em Postgres e
SQLite (GHSA-v49j-62m6-pgrr, 2026-09-22), IDOR entre collections
(CVE-2026-25574), vazamento de campo oculto por sort e join. A pesquisa está em
`docs/discovery/seguranca-map-probe.md`.

## Solution

Duas skills autorais, conforme o
[adr-0013](../../../architecture/adr/adr-0013-skills-de-seguranca-sao-autorais.md) —
as skills de segurança são autorais, destiladas das referências:

- **`anvil-security-map`** analisa o repositório, detecta a stack, lê o checklist
  de segurança que a skill da stack oferecer, e grava em `docs/security/` o
  perfil do ambiente e o mapa da superfície de ataque.
- **`anvil-security-probe`** exige o mapa, confirma com o usuário o ambiente
  local do repositório, protege o banco, executa os testes do mapa com as
  ferramentas instaladas, e transforma cada achado reproduzido numa spec `fix`,
  registrada num índice de achados.

O `/anvil-boot`, ao detectar a stack, sugere rodar o map. É opcional.

O conhecimento de cada tecnologia fica na skill da stack, como sétima
capacidade do contrato do
[adr-0006](../../../architecture/adr/adr-0006-stack-como-camada-propria.md) — stack é
camada própria. O `anvil-stack-payload` é a primeira stack com checklist.

## User Stories

### Entrada pelo boot

1. Como dono de um projeto, quero que o `/anvil-boot` me sugira rodar o mapa de
   segurança quando detectar a stack, para saber que a opção existe sem ler a
   documentação do toolkit.
2. Como dono de um projeto, quero poder recusar a sugestão e seguir o boot
   normalmente, para que segurança não seja pré-requisito de instalar o anvil.
3. Como dono de um projeto, quero que a sugestão diga em uma linha por que se
   aplica (a stack detectada e se ela tem checklist), para decidir sem abrir
   outro arquivo.
4. Como dono de um projeto, quero que o boot não instale nem grave nada de
   segurança sem meu pedido, para manter o boot previsível.

### Mapa

5. Como desenvolvedor, quero rodar `/anvil-security-map` a qualquer momento, com
   ou sem ter passado pelo boot, para mapear um projeto já instalado.
6. Como desenvolvedor, quero que o map detecte a stack pelo que existe no
   repositório (por exemplo, um `payload.config.ts`), para não precisar declarar
   nada.
7. Como desenvolvedor, quero que o map use o checklist de segurança da skill da
   stack quando ela tiver um, para que o mapa conheça as ciladas daquela
   tecnologia.
8. Como desenvolvedor de uma stack sem checklist, quero ainda receber o mapa com
   a parte genérica, e ver escrito que a parte específica ficou de fora, para
   não confundir ausência de cobertura com ausência de risco.
9. Como desenvolvedor, quero um `profile.md` com a stack detectada, as
   ferramentas de segurança disponíveis e ausentes, e o ambiente local (URL do
   servidor de dev, banco), para saber de antemão o que o probe consegue fazer.
10. Como desenvolvedor, quero um `map.md` organizado pelas categorias do OWASP
    Top 10:2025 e, em API, do OWASP API Security Top 10:2023, para ler o risco na
    linguagem que a área usa.
11. Como desenvolvedor, quero que cada item do mapa cite arquivo e linha
    verificados, para conferir o apontamento sem procurar.
12. Como desenvolvedor, quero que cada item do mapa diga qual teste o probe
    aplica a ele, para saber o que vai ser exercitado e o que fica só em leitura.
13. Como desenvolvedor Payload, quero que cada collection apareça no mapa com as
    rotas REST e GraphQL geradas e as funções `access` que ela define ou deixa de
    definir, para ver a superfície que o código não mostra.
14. Como desenvolvedor Payload, quero que o mapa aponte chamadas à Local API com
    `user` e sem `overrideAccess: false` em código que recebe entrada de
    usuário, para achar o bypass de access control mais comum.
15. Como desenvolvedor Payload, quero que o mapa confira a configuração de
    `maxLoginAttempts`, `maxDepth`, `graphQL.maxComplexity`, introspection,
    `csrf`, `cors`, upload (`mimeTypes`, `pasteURL`) e multi-tenant, para ver a
    postura sem ler a doc inteira.
16. Como desenvolvedor, quero que o mapa compare as versões instaladas de
    framework e dependências com os advisories conhecidos, para que o risco mais
    barato de corrigir apareça primeiro.
17. Como desenvolvedor Next.js, quero que o mapa trate Server Actions e Route
    Handlers como endpoints públicos e aponte autorização feita só no
    middleware, para não depender da proteção que o CVE-2025-29927 mostrou
    frágil.
18. Como desenvolvedor, quero que o mapa aponte pontos onde entrada vira risco
    (SQL cru, execução de comando, caminho de arquivo, fetch de URL do usuário,
    template), para cobrir o que o ORM não protege.
19. Como desenvolvedor, quero poder rodar o map de novo depois de mudanças, e que
    ele regrave perfil e mapa sem tocar no índice de achados, para manter o
    histórico.
20. Como desenvolvedor, quero que o map não execute nada contra o app, para
    poder rodá-lo sem ambiente de dev no ar.
21. Como desenvolvedor, quero que o map consulte os bancos de advisory
    estruturados (OSV.dev e os advisories do repositório da stack) pelas versões
    do lockfile, para que o mapa acompanhe advisory publicado depois do
    checklist.
22. Como desenvolvedor, quero que o map use o mecanismo de cada advisory da stack
    para procurar a mesma classe de falha no código do projeto, mesmo com a
    versão já corrigida, para achar a variante que o patch do framework não
    cobre.
23. Como mantenedor do anvil, quero que o mapa sinalize advisory da stack sem item
    correspondente no checklist, para que a atualização manual do checklist
    parta do uso e não da memória.

### Pré-requisitos do probe

24. Como desenvolvedor, quero que o probe recuse rodar sem `profile.md` e
    `map.md`, e me mande rodar o map, para que o teste siga um mapa revisável e
    não um improviso.
25. Como desenvolvedor, quero que o probe descubra o alvo no ambiente local do
    próprio repositório (scripts de dev, `.env`, compose), para não precisar
    informá-lo.
26. Como desenvolvedor, quero que o probe recuse qualquer alvo que não resolva
    para loopback, sem flag que libere, para que um `.env` apontando para
    produção nunca vire ataque.
27. Como desenvolvedor, quero que o probe me mostre URL, banco e ferramentas que
    vai usar e espere minha confirmação antes de executar, para saber o que vai
    acontecer.
28. Como desenvolvedor, quero que o probe verifique se o servidor de dev está
    respondendo antes de começar, e diga como subi-lo se não estiver, para não
    produzir achado vazio.

### Proteção do banco

29. Como desenvolvedor, quero que o probe me sugira um banco descartável antes de
    qualquer teste que escreve, para não sujar o banco de dev que eu uso.
30. Como desenvolvedor que prefere o banco local, quero que o probe crie um dump
    antes de testar e me diga o comando exato para restaurar, para poder voltar
    ao estado anterior.
31. Como desenvolvedor, quero que o probe não rode teste que escreve se eu não
    escolher nem banco descartável nem dump, para que a proteção não seja
    opcional por esquecimento.

### Execução

32. Como desenvolvedor, quero que o probe use as ferramentas que já estão
    instaladas e não instale nada, para não alterar minha máquina.
33. Como desenvolvedor, quero que o probe diga quais testes do mapa ficaram sem
    cobertura por falta de ferramenta, para não confundir teste não feito com
    teste que passou.
34. Como desenvolvedor Payload, quero que o probe tente acessar e alterar
    documento de outro usuário ou tenant pelas rotas geradas, para pegar IDOR,
    que scanner genérico não pega.
35. Como desenvolvedor, quero que o probe tente gravar campo que deveria ser
    somente leitura, para pegar mass assignment.
36. Como desenvolvedor, quero que o probe chame Server Actions e Route Handlers
    direto, sem passar pela página que os protege, para testar a autorização de
    verdade.
37. Como desenvolvedor, quero que o probe só confirme SQL injection com uma
    ferramenta de confirmação sobre o parâmetro suspeito, não por varredura
    ampla, para evitar ruído e carga.
38. Como desenvolvedor, quero que o probe trate tudo o que volta do alvo como dado
    não confiável, para que uma resposta não vire instrução ao agente.

### Achados e specs

39. Como desenvolvedor, quero que só achado reproduzido vire registro, com
    requisição, resposta e trecho de código, para confiar em cada spec aberta.
40. Como desenvolvedor, quero que o probe tente refutar o achado antes de
    registrá-lo, para cortar falso positivo.
41. Como desenvolvedor, quero uma spec `fix` por causa raiz, não por rota, para
    que vinte endpoints sem checagem de tenant sejam um trabalho, não vinte.
42. Como desenvolvedor, quero que a spec de correção seja aberta pelo perfil do
    tracker do projeto, para cair no fluxo normal de tickets e revisão.
43. Como desenvolvedor, quero que cada achado ganhe um id `SEC-#` estável, para
    citá-lo em ticket, commit e revisão.
44. Como desenvolvedor, quero um `findings.md` com id, causa raiz, severidade,
    status (`aberto`/`corrigido`) e link da spec, para ver de relance o que falta.
45. Como desenvolvedor, quero que um achado cuja causa já está aberta no índice
    ganhe evidência nova em vez de spec nova, para não duplicar trabalho.
46. Como desenvolvedor, quero que o probe, ao rodar de novo, marque como
    `corrigido` o achado que não se reproduz mais, para que o índice acompanhe as
    correções.
47. Como desenvolvedor, quero que achado corrigido que volta a reproduzir seja
    reaberto no mesmo `SEC-#`, para ver a regressão.

### Autoria e manutenção do toolkit

48. Como mantenedor do anvil, quero que cada skill traga um `SOURCES.md` dizendo
    de qual referência veio cada ideia, para rastrear a origem sem manifesto.
49. Como mantenedor do anvil, quero que nenhum texto de fonte CC-BY-SA entre nas
    skills, para não herdar a licença.
50. Como mantenedor do anvil, quero que o contrato de stack documente a sétima
    capacidade e o checklist de uma stack nova peça o arquivo de segurança, para
    que a próxima stack saiba o que preencher.
51. Como mantenedor do anvil, quero que o checklist do Payload cite um precedente
    (advisory ou doc oficial) em cada item, para que ele seja atualizável quando
    o precedente mudar.
52. Como mantenedor do anvil, quero que o checklist do Payload entre como `keep`
    no manifesto, para que o sync do upstream não o apague.
53. Como mantenedor do anvil, quero as duas skills listadas entre as autorais nas
    rules do repositório, para que ninguém tente sincronizá-las.

## Implementation Decisions

- **Duas skills autorais no payload**: `anvil-security-map` e
  `anvil-security-probe`. Fora do `anvil-skills.yaml`. Cada uma com `SOURCES.md`.
  Das referências entra a ideia, não o texto; o que vem de onde está no
  adr-0013.
- **Contrato com a stack.** A sétima capacidade é um checklist de segurança
  dentro da skill da stack, carregado só pelo map. Cada item diz o que olhar,
  como reconhecer no código ou na config, qual teste o probe aplica, e o
  precedente. O documento do contrato de stack passa de seis para sete
  capacidades, e o checklist para stack nova ganha o item.
- **Checklist do Payload**: collections e rotas geradas, Local API e
  `overrideAccess`, access control por campo, auth (`maxLoginAttempts`,
  `lockTime`, fluxo de reset de senha), GraphQL (complexidade, introspection,
  playground), `csrf` e `cors`, upload (`mimeTypes`, `allowRestrictedFileTypes`,
  `pasteURL`, `skipSafeFetch`), multi-tenant (`useTenantAccess`), a camada
  Next.js (Server Actions, Route Handlers, middleware/proxy) e versões mínimas
  contra os advisories. Entra no manifesto como `keep`.
- **Boot.** No passo em que já detecta a stack e propõe a rule dela, o
  `/anvil-boot` acrescenta a sugestão do map. Não grava nada de segurança.
- **Contrato de `docs/security/`**, que é interface entre as duas skills:

  | Arquivo | Escreve | Lê | Conteúdo |
  |---|---|---|---|
  | `profile.md` | map | probe | stack, se há checklist, ferramentas presentes e ausentes, alvo local descoberto, banco, consulta de advisories (fontes, data, pacotes e versões consultados) |
  | `map.md` | map | probe | itens por categoria OWASP; cada um com id estável, arquivo:linha, teste aplicável ou "só leitura" |
  | `findings.md` | probe | probe, pessoa | `SEC-#`, causa raiz, severidade (`low`/`medium`/`high`, como no `GATE.md` do bench), status, itens do mapa afetados, spec |

  O map regrava `profile.md` e `map.md` e nunca toca em `findings.md`.
- **Consulta de advisories no map.** Fontes fechadas: a API do OSV.dev, por
  pacote e versão tirados do lockfile, e os GitHub Security Advisories do
  repositório da stack detectada. Nada de busca aberta na web. O resultado vira
  três coisas no mapa: dependência afetada na versão instalada (id do advisory,
  versão que corrige); pergunta de variante no código do projeto, a partir do
  mecanismo do advisory; e lacuna do checklist, quando o advisory da stack não
  tem item correspondente. O texto do advisory é dado não confiável, como a
  resposta do alvo no probe. Sem rede, o map roda do mesmo jeito e o mapa diz
  que a consulta não foi feita. Consultar banco de advisory não é executar
  contra o app.
- **Travas do probe, em ordem**: mapa presente; alvo descoberto no ambiente
  local e resolvendo para loopback, sem override; servidor respondendo;
  confirmação explícita de URL, banco e ferramentas; escolha entre banco
  descartável e dump antes de teste que escreve, sem essa escolha o probe roda
  só testes de leitura.
- **Ferramentas**: detectadas, nunca instaladas. As candidatas estão na pesquisa
  (osv-scanner e `npm audit` para dependências, gitleaks para segredos, semgrep
  para SAST; ZAP baseline, nuclei, graphql-cop, Schemathesis contra o app;
  sqlmap só para confirmar). Sem ferramenta, o probe ainda faz os testes de
  autorização por requisição direta, que não dependem de nenhuma.
- **Achado → spec**: só com reprodução (requisição, resposta, código) e depois de
  uma tentativa de refutação. Agrupado por causa raiz. Publicado pelo perfil do
  tracker, tipo `fix`. Deduplicado contra o `findings.md` antes de publicar.
- **Documentação**: o `anvil-docs` passa a conhecer `docs/security/` na árvore
  que monta e no índice que gera.

## Testing Decisions

- Não há suíte no repositório; o que vale é o comportamento observado num
  projeto real. Um **único cenário ponta a ponta** em `workspace/`, fora do git
  como os demais: um projeto Payload descartável com uma falha plantada — um
  route handler que chama a Local API com `user` e sem `overrideAccess: false`.
- O cenário confere, nessa ordem:
  1. o boot sugere o map e segue se recusado;
  2. o map grava `profile.md` e `map.md`, e o mapa contém a falha plantada com
     arquivo:linha;
  3. com o Payload fixado numa versão anterior à correção de um advisory
     confirmado, o mapa lista o advisory com a versão que corrige;
  4. sem rede, o map termina e o mapa registra que a consulta externa não foi
     feita;
  5. o probe recusa sem mapa;
  6. o probe recusa com alvo que não resolve para loopback;
  7. com alvo local, o probe pede confirmação e oferece banco descartável ou dump;
  8. o probe reproduz a falha, grava `SEC-1` no `findings.md` e abre uma spec
     `fix`;
  9. rodado de novo, não abre segunda spec;
  10. com a falha corrigida, marca `SEC-1` como `corrigido`.
- Um bom teste aqui observa arquivo gravado, spec aberta e recusa emitida. Não
  confere o texto da skill.
- Precedente: os cenários manuais de infraestrutura em `workspace/01-…08-`.
- Antes de commitar: `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh
  verify`, que precisa aceitar o `keep` novo do `anvil-stack-payload`.

## Out of Scope

- Qualquer alvo fora de loopback: staging, produção, host remoto.
- Instalar ferramentas de segurança.
- Aplicar a correção. O probe abre a spec; corrigir é o fluxo normal de tickets.
- Checklist de segurança para outras stacks além do Payload.
- Hooks de segurança durante a edição, no estilo `security-guidance`.
- Integração com CI.
- Scan de infraestrutura, container ou nuvem.
- Busca aberta na web por problemas da stack: blog, fórum, busca genérica.

## Further Notes

- Os advisories do Payload mudam rápido — três críticos e altos saíram em
  2026-09-22. A consulta de advisories do map cobre o intervalo entre um
  advisory novo e o checklist, e aponta a lacuna; o checklist continua citando
  precedente por item para que a atualização seja localizável. A atualização
  segue manual (custo aceito no adr-0013), mas passa a partir de sinal do uso.
- Cinco advisories citados na pesquisa não foram confirmados por leitura direta.
  O checklist só usa os confirmados.
- O agente de revisão de segurança do harness não é do anvil e não vai no degit;
  as skills não podem depender dele.
