# 02: O perfil de domínio do `anvil-setup` aponta para onde o anvil guarda glossário e ADRs

**What to build:** Num projeto descartável, o boot chega ao passo do issue tracker e roda o `anvil-setup` sem o usuário digitar nada. O perfil de domínio que ele escreve manda ler o glossário e os ADRs no layout do anvil e cita as skills pelo nome do anvil. O manifesto registra a adaptação, para que o update sinalize conflito quando o upstream mexer nessas linhas.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] O seed do perfil de domínio usa os caminhos do anvil para glossário, mapa de contextos e ADRs, por `docs-remap`.
- [ ] As referências a skills adotadas usam o nome do anvil, por `rename`; a referência a `improve-codebase-architecture`, que não foi adotada, fica verbatim.
- [ ] O manifesto registra `rename`, `docs-remap` e `invocable` para o `anvil-setup`.
- [ ] O texto do passo do tracker no boot e no scaffold não muda.
- [ ] Ponto B: num projeto descartável, o boot roda o passo do tracker sem intervenção, e o perfil de domínio escrito aponta para o layout do anvil.
- [ ] O `verify` sai limpo.
