# 09: O boot e o bench escrevem a seção `## Git`

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=4f0587563729821f5e7197e2825763aa2b8589f7; scope=full; verdict=pass; p1=none

**What to build:** o `anvil-boot` escreve a seção `## Git` de
`.claude/rules/anvil.md` com o branch base e o forge que o resolvedor detecta,
confirmados pelo usuário, e a acrescenta num `anvil.md` que não a tem, como faz com
as outras seções. O projeto novo do bench nasce com `branch base: main` e
`forge: nenhum`.

- [x] O boot mostra o branch base e o forge detectados e escreve a seção com o que
      o usuário confirmar ou corrigir; quando o resolvedor recusa, pergunta os dois
      valores.
- [x] Num `anvil.md` existente sem a seção, o boot a acrescenta sem mexer no resto.
- [x] O bench escreve a seção no projeto novo, no primeiro commit.
- [x] Prova S1 do boot, num diretório novo de `workspace/`, com
      `workspace/45-boot-verification/` como prior art: `anvil.md` novo com a seção;
      `anvil.md` antigo ganhando a seção sem mudar o resto; o resolvedor lê a seção
      escrita.
- [x] O caso N do B1 de `workspace/66-bench-b1-real-stack/`, pelo helper: o primeiro
      commit traz a seção com `main` e `nenhum`. O código do helper sai nas saídas.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · o boot roda `resolve-git.sh`, mostra e confirma os dois valores; na recusa, pergunta ambos e espera. Depois de escrever, roda o resolvedor novamente e relata eventual pendência. O bench escreve `main` e `nenhum` antes do primeiro commit. Sob o piloto, que já tem repositório, usa os valores do resolvedor em vez de declarar uma `main` inexistente ou apagar a escolha de forge; a seção configurada fica.
- Prova S1 · `workspace/77-boot-git-section/s1.sh`, prior art `workspace/45-boot-verification/`: sessões reais com `claude-sonnet-4-5` pelo helper, dependências `anvil-docs` e `anvil-update`. N: arquivo novo com `master` e `github`; A: arquivo antigo recebe só a seção, corrigida para `develop`, lida pelo resolvedor; R: recusa com `main` e `master`, pergunta dos dois valores no primeiro turno e escrita da resposta no segundo. Vermelho: códigos do helper N=1, A=1, R=1 em `out-red/`; verde: N=0, A=0, R=0 em `out/`.
- Prova B1 · `workspace/78-bench-git-section/b1.sh`, caso N do prior art `workspace/66-bench-b1-real-stack/`, pelo helper com `--infra` e dependências `anvil-bench`, `anvil-stack-payload`, `anvil-docs`, `anvil-to-spec`. O primeiro commit traz o starter, a rule da stack, os dois perfis iguais aos templates e `anvil.md` com `branch base: main` e `forge: nenhum`; o resolvedor lê a cópia desse primeiro commit. Modelo `claude-sonnet-4-5`; código do helper vermelho `1` em `out-red/`, verde `0` em `out/`. A rede do `.env` é a do prefixo isolado.
- Verificação · `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` saiu `0` (`verify: limpo`) antes do commit de implementação. Review round=1: Standards e Spec sem achados, ambos `veredito: pass`.
