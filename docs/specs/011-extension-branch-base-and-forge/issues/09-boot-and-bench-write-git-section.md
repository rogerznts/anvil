# 09: O boot e o bench escrevem a seção `## Git`

**Blocked by:** 01

**Status:** ready-for-agent

**What to build:** o `anvil-boot` escreve a seção `## Git` de
`.claude/rules/anvil.md` com o branch base e o forge que o resolvedor detecta,
confirmados pelo usuário, e a acrescenta num `anvil.md` que não a tem, como faz com
as outras seções. O projeto novo do bench nasce com `branch base: main` e
`forge: nenhum`.

- [ ] O boot mostra o branch base e o forge detectados e escreve a seção com o que
      o usuário confirmar ou corrigir; quando o resolvedor recusa, pergunta os dois
      valores.
- [ ] Num `anvil.md` existente sem a seção, o boot a acrescenta sem mexer no resto.
- [ ] O bench escreve a seção no projeto novo, no primeiro commit.
- [ ] Prova S1 do boot, num diretório novo de `workspace/`, com
      `workspace/45-boot-verification/` como prior art: `anvil.md` novo com a seção;
      `anvil.md` antigo ganhando a seção sem mudar o resto; o resolvedor lê a seção
      escrita.
- [ ] O caso N do B1 de `workspace/66-bench-b1-real-stack/`, pelo helper: o primeiro
      commit traz a seção com `main` e `nenhum`. O código do helper sai nas saídas.
- [ ] `vendor-sync.sh verify` sai `0`.

## Comments
