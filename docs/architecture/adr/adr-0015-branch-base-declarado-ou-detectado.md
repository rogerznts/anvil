# ADR-0015 — Um branch base só, declarado nas rules ou detectado

- Status: aceito
- Data: 2026-10-23
- Revê em parte o [ADR-0014](./adr-0014-piloto-automatico-fecha-sem-humano.md): o branch novo de cada entrada sai do branch base, não da `main`

## Contexto

O toolkit escreve `main` em comando: a largada do `anvil-auto` só segue com
`branch: main`, o fechamento faz `git checkout main`, a conferência do merge da
spec 009 roda `git rev-list <branch>..main`, e o `tea-open-fast-pr` faz `git stash`
antes de um `git checkout main` que, num projeto com `master`, falha e deixa o
trabalho do operador no stash. Ao mesmo tempo, as skills de PR falam de dois
papéis — o branch estável e o de integração, com o hotfix abrindo dois PRs —, e o
piloto, de um só. Nenhum lugar descobre qual é o branch do projeto.

## Decisão

**O toolkit conhece um branch só, o branch base: de onde todo trabalho sai e para
onde volta, pelo merge local ou pelo PR.** É a `main` ou a `master`, ou outro que o
usuário declarar, como uma `develop`.

- **Declarado.** A seção `## Git` de `.claude/rules/anvil.md` traz `branch base:` e
  `forge:`. O `anvil-boot` sempre a escreve, com o valor detectado e confirmado pelo
  usuário.
- **Detectado só sem a seção**, no projeto que ainda não passou pelo boot: o
  branch sai de `origin/HEAD` ou do único entre `main` e `master` que existir; o
  forge, do host do remoto. Dois candidatos, nenhum, ou host desconhecido: recusa,
  apontando a seção.
- **Um script resolve os dois valores**, e todo comando que hoje escreve `main` lê
  dele. A prosa pode continuar dizendo "a `main`" com a glosa de branch base.
- **O hotfix abre um PR só**, para o branch base, como o resto do trabalho.

## Alternativas descartadas

- **Dois papéis no toolkit inteiro, integração e estável.** O piloto, a guarda e o
  `roadmap.sh` só precisam saber para onde a spec volta; carregar o segundo papel
  em todos eles é custo para o hotfix, o único fluxo que o usa.
- **Só detectar.** Num repositório com `develop`, o `origin/HEAD` costuma ser a
  `main`, e a detecção erraria em silêncio. Gitea próprio e GitHub Enterprise não
  se reconhecem pelo host.
- **Só declarar, recusando sem a seção.** Quebra todo projeto que já existe até
  alguém rodar o boot de novo, mesmo no caso comum em que a detecção acerta.

## Consequências

Num projeto que declara a `develop` como branch base, levar um hotfix à produção é
passo do operador, fora do toolkit. Uma renomeação do branch no remoto vira recusa
visível, não mudança silenciosa.
