# 14: O boot adota glossário e ADRs antigos que moram fora de `docs/`

**What to build:** Num projeto que tem `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz, ou ADRs em `docs/adr/`, o boot percebe que existe documentação de domínio no layout antigo e segue pelo `adopt`, que mostra o plano de movimentação e espera aprovação, em vez de seguir pelo `scaffold`. Hoje o boot escolhe o verbo olhando só dentro de `docs/`; e, desde que o `anvil-setup` passou a procurar o glossário no layout do anvil, esse glossário antigo passa despercebido e o perfil de domínio manda "seguir em silêncio". É uma regressão desta spec.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] O passo 5 do boot trata como gatilho do `adopt` a presença de `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz, ou de ADRs em `docs/adr/`, mesmo com `docs/` ausente ou só com README de domínio.
- [ ] O `adopt` mostra o plano inteiro antes de mover qualquer coisa, como já faz para esses caminhos, e nada é movido sem aprovação.
- [ ] Projeto sem nenhum desses arquivos continua indo para o `scaffold`.
- [ ] Depois do boot, o glossário e os ADRs estão no layout do anvil e o perfil de domínio aponta para eles; nenhuma rule do projeto continua citando o caminho antigo sem aviso.
- [ ] Ponto B, com `claude -p` isolado do `CLAUDE.md` e das rules do repo pai: um projeto com `CONTEXT.md` na raiz recebe o plano do `adopt` e só move com aprovação; um projeto limpo segue pelo `scaffold`.
- [ ] O `verify` sai limpo.
