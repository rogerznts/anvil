# 02: O perfil de domínio do `anvil-setup` aponta para onde o anvil guarda glossário e ADRs

**What to build:** Num projeto descartável, o boot chega ao passo do issue tracker e roda o `anvil-setup` sem o usuário digitar nada. O perfil de domínio que ele escreve manda ler o glossário e os ADRs no layout do anvil e cita as skills pelo nome do anvil. O manifesto registra a adaptação, para que o update sinalize conflito quando o upstream mexer nessas linhas.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] O seed do perfil de domínio usa os caminhos do anvil para glossário, mapa de contextos e ADRs, por `docs-remap`.
- [ ] As referências a skills adotadas usam o nome do anvil, por `rename`; a referência a `improve-codebase-architecture`, que não foi adotada, fica verbatim.
- [ ] O manifesto registra as adaptações do `anvil-setup` (lista final no critério acrescentado abaixo, com `tracker-profile`).
- [ ] O texto do passo do tracker no boot e no scaffold não muda.
- [ ] Ponto B: num projeto descartável, o boot roda o passo do tracker sem intervenção, e o perfil de domínio escrito aponta para o layout do anvil.
- [ ] O `verify` sai limpo.

## Comments

**Leader, 2026-09-13 — entrega do Dev em `1e21649`, e escopo acrescentado ao ticket:**

1. **O `SKILL.md` do `anvil-setup` também é remapeado**, pelo mesmo `docs-remap`: ele ainda
   mandava procurar `CONTEXT.md` na raiz e `docs/adr/`, e prometia esse layout ao usuário,
   embora o arquivo gravado já saísse certo.
2. **Regra nova `tracker-profile`** (decisão do usuário). As três linhas que acrescentam a opção
   "anvil docs/specs" ao setup existem desde `ca39c5c` e não cabem em nenhuma regra do catálogo
   — o `docs-remap` exclui explicitamente o que o perfil de tracker resolve. A regra é de
   julgamento e estreita: a skill de setup oferece o perfil de tracker do `anvil-docs`, como
   decide o ADR-0002. Entra no catálogo com o motivo, no manifesto do `anvil-setup` e no aviso
   de revisão do `vendor-sync`.

Critérios acrescentados:

- [ ] O `SKILL.md` do `anvil-setup` cita o glossário, o mapa de contextos e os ADRs no layout do anvil.
- [ ] O catálogo tem a regra `tracker-profile`, com natureza, quem aplica e motivo.
- [ ] O manifesto registra `rename`, `docs-remap`, `tracker-profile` e `invocable` para o `anvil-setup`.
- [ ] O `vendor-sync` sinaliza `tracker-profile` para revisão no `vendor` e no `update`, como faz com `docs-remap`.

**Leader, 2026-09-13 — entregas do Dev:** `a07756f` (remap do `SKILL.md`; a linha 12 fica verbatim
por nomear o tipo de arquivo, não caminho) e `adb17b3` (regra `tracker-profile`). Pendências
distribuídas: a lista do catálogo no README vai para o ticket 03, que já mexe no README.
Divergências de ADR registradas e não corrigidas, porque ADR é registro histórico: o ADR-0002 diz
que o perfil do anvil mora na pasta do setup, e ele mora no `anvil-docs`; o ADR-0004 lista as
regras sem `invocable` e sem `tracker-profile`.
