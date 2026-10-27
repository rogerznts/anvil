# 02: O boot mede o custo da verificação e o grava num lugar só

**What to build:** Depois do `/anvil-boot`, o `anvil.md` do projeto diz quanto a verificação custa: o comando, o tempo medido numa rodada real, a data, a máquina, e a instrução de que quem medir diferente corrige ali, no mesmo commit. É a única fonte do custo — `project.md` e `CLAUDE.md` dizem como rodar os testes e apontam para o `anvil.md` quando falam de custo. Quando o projeto adotar o laço curto, a seção comporta dois comandos, `laço` e `gate`, cada um com seu custo, nos termos do perfil de verificação. Se o comando não roda na instalação, fica gravado sem custo, com o motivo — número estimado não se grava. Num projeto adotado, o boot propõe o custo que falta sem trocar o comando já configurado, mostra a divergência quando o custo gravado difere do medido, e aponta custo repetido em outras rules, propondo trocar a repetição por um ponteiro.

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=2ffd1c7; scope=full; verdict=pass; p1=none

- [x] Instalação nova: o `anvil.md` sai com comando, custo medido, data, máquina e a instrução de correção no mesmo commit.
- [x] Comando que não roda: fica gravado sem custo, com o motivo.
- [x] `anvil.md` existente sem custo: o boot propõe acrescentar e espera aprovação; o comando configurado não muda.
- [x] Custo gravado divergente do medido: o boot mostra os dois e a troca espera aprovação.
- [x] Custo repetido em `CLAUDE.md` ou em outra rule: o boot aponta e propõe o ponteiro, sem editar sozinho.
- [x] O formato de `laço` e `gate` usa os termos do perfil do ticket 01.
- [x] Exercitado num projeto descartável em `workspace/`, nos dois casos: instalação nova e projeto adotado com custo repetido.
- [x] O `verify` sai limpo.

## Comments

- Cenário em `workspace/02-boot-custo/`, fora do git, com a seção seguida à mão (a
  skill editada só carrega na próxima sessão). **Novo**: `npm test` medido em 2,1s
  e gravado no `anvil.md` com data, máquina e a instrução de correção.
  **Adotado**: `anvil.md` com o comando e sem custo → proposta de acrescentar
  1,8s, comando intocado. A busca por tempo de teste fora do `anvil.md` achou
  `CLAUDE.md:3` (`~80s`) e `.claude/rules/project.md:3` (`cerca de 2 min`), os
  dois divergentes do medido: ficam apontados, com proposta de ponteiro, sem
  edição.
- Review round=1 · P2: a spec manda gravar sem custo o comando que "falhar ou não
  puder rodar"; o boot trata só "não roda" e "recusado" — uma suíte que termina
  vermelha tem o tempo gravado como custo, o número errado que a spec evita.
- Review round=1 · P2: o exemplo de `laço` e `gate` do boot não traz a máquina
  nem a frase "Quem medir diferente corrige…" — quem copia o formato ao adotar o
  laço curto perde a instrução que segura a fonte única.
- Review round=1 · P2: o perfil define o gate como "a suíte inteira mais o
  typecheck", e o exemplo de um comando do boot (`pnpm test`) não tem typecheck
  nem o boot pede que o inclua — a prova do `anvil-auto` roda sem typecheck nos
  projetos com o bloco padrão.
- Review round=1 · P2: o cenário em `workspace/02-boot-custo/` foi exercitado
  antes do rebase, que mudou o formato com laço (o `laço` foi para a prosa depois
  do bloco) — o texto atual dessa parte não tem prova exercitada.
