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
resolveu o das respostas pela metade, e a spec 007 fechou os P2 das rodadas 2 e 3
com os P3 que as mesmas correções tocam. Ficam estes.

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
  marcadores `ANVIL:DIRECTIVES` do `reset-install.sh`. Enquanto ninguém mexer,
  uma correção de CRLF ou de marcador precisa ser feita nos dois scripts, e a que
  ficar só num deles faz a instalação e a migração lerem o mesmo bloco de jeitos
  diferentes.
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
  remoção, contra o "settings fora da entrada do hook intocados" da 006; o
  dry-run avisa.
- **A19 · o aviso de perfil acusa caminho da instalação de usuário.** Ticket 05
  da spec 006, rodada 1, P3 (Spec): o aviso de perfil desconta só `~/.claude/`,
  `$HOME/.claude/`, `"$HOME"/.claude/` e `${HOME}/.claude/`. Enquanto ninguém
  mexer, um perfil em `docs/agents/` que cita `/Users/<u>/.claude/skills/<s>/scripts/`
  ou `"${HOME}"/.claude/...` recebe um `BOOT PENDENTE` falso, e o usuário roda o
  `/anvil-boot` atrás de uma linha que já aponta para a instalação de usuário.
