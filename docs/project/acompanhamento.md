# Acompanhamento

Achados P2 e P3 que sobraram de specs fechadas e não seguraram o fechamento,
pelo critério de `docs/agents/verification.md`. Cada linha diz de onde veio e o
que acontece se ninguém mexer. Quem pegar uma linha abre uma spec `extension`
ligada à spec de origem e tira a linha daqui no mesmo branch.

## Spec 004: robustez e isolamento da camada omp

Origem: `docs/specs/004-extension-omp-layer-hardening/`, que resolveu as linhas A1
a A11 da spec 003. Fica a parte do antigo A9 que a spec deixou de fora.

- **A12 · adaptador de tracker para os condutores.** Out of Scope da spec 004. Com
  outro perfil do `anvil-setup` (GitHub, GitLab, markdown local), a `anvil-plan` e
  a `anvil-run` recusam com o nome do perfil, e o fluxo segue à mão. Conduzir
  nesses perfis pede um frontier e uma retomada que leiam issues do tracker, e
  antes disso decidir como spec e ticket aparecem em cada um, o que é decisão de
  grill. Não há projeto usando outro perfil com omp. Enquanto ninguém mexer, quem
  usa outro perfil no omp não tem condução.
- **A13 · "interface" dá falso positivo de tela.** Ticket 11 da spec 004, ponta a
  ponta. A lista de palavras de tela do `frontier.sh` tem `interface`, e a US 8 da
  spec do ponta a ponta ("manter a regra separada da interface executável") saiu
  `screen: yes`: a `anvil-run` recomendou o browser QA para um comando de terminal.
  A spec 004 fixou que a lista não muda. Enquanto ninguém mexer, spec sem tela que
  diga "interface" recebe o browser QA no lugar do archive.
- **A14 · a `anvil-to-tickets` escreve o título no `Blocked by`.** Ticket 11 da
  spec 004, ponta a ponta. O ticket 02 saiu com
  `Blocked by: 01: Contar severidades de 0 a 3 em arquivo válido`, o formato que o
  template da skill vendorizada aceita. O `frontier.sh` o deixou fora do frontier
  como bloqueio ilegível, como a spec pede, e o operador corrigiu a linha para
  `01`. Enquanto ninguém mexer, toda spec planejada pelo `anvil-plan` pode sair
  com tickets parados até o operador reescrever a linha.
