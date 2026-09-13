# 02: O perfil de domínio do `anvil-setup` aponta para onde o anvil guarda glossário e ADRs

**What to build:** Num projeto descartável, o boot chega ao passo do issue tracker e roda o `anvil-setup` sem o usuário digitar nada. O perfil de domínio que ele escreve manda ler o glossário e os ADRs no layout do anvil e cita as skills pelo nome do anvil. O manifesto registra a adaptação, para que o update sinalize conflito quando o upstream mexer nessas linhas.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] O seed do perfil de domínio usa os caminhos do anvil para glossário, mapa de contextos e ADRs, por `docs-remap`.
- [x] As referências a skills adotadas usam o nome do anvil, por `rename`; a referência a `improve-codebase-architecture`, que não foi adotada, fica verbatim.
- [x] O manifesto registra as adaptações do `anvil-setup` (lista final no critério acrescentado abaixo, com `tracker-profile`).
- [x] O texto do passo do tracker no boot e no scaffold não muda.
- [x] Ponto B: num projeto descartável, o boot roda o passo do tracker sem intervenção, e o perfil de domínio escrito aponta para o layout do anvil.
- [x] O `verify` sai limpo.

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

- [x] O `SKILL.md` do `anvil-setup` cita o glossário, o mapa de contextos e os ADRs no layout do anvil.
- [x] O catálogo tem a regra `tracker-profile`, com natureza, quem aplica e motivo.
- [x] O manifesto registra `rename`, `docs-remap`, `tracker-profile` e `invocable` para o `anvil-setup`.
- [x] O `vendor-sync` sinaliza `tracker-profile` para revisão no `vendor` e no `update`, como faz com `docs-remap`.

**Leader, 2026-09-13 — entregas do Dev:** `a07756f` (remap do `SKILL.md`; a linha 12 fica verbatim
por nomear o tipo de arquivo, não caminho) e `adb17b3` (regra `tracker-profile`). Pendências
distribuídas: a lista do catálogo no README vai para o ticket 03, que já mexe no README.
Divergências de ADR registradas e não corrigidas, porque ADR é registro histórico: o ADR-0002 diz
que o perfil do anvil mora na pasta do setup, e ele mora no `anvil-docs`; o ADR-0004 lista as
regras sem `invocable` e sem `tracker-profile`.

**Leader, 2026-09-13 — gate Review, parte 1 (`1e21649`, `a07756f`): APROVADO, sem bloqueante.** Todas
as linhas que diferem do upstream foram classificadas em `rename`, `docs-remap`, `tracker-profile`,
`invocable` ou `strip`. Três achados ficam neste ticket, num ajuste final:

- **F1** — `SKILL.md` cita `to-tickets` e `to-spec` sem o prefixo das skills adotadas.
- **F2** — os seeds de tracker GitHub, GitLab e local gravam `/wayfinder` no projeto.
- **F3** — a definição do `docs-remap` no catálogo fala só de caminho de saída e de uma skill; a
  prática remapeia também caminhos lidos, em cinco skills.

Fica como ideia, fora da spec: o `verify` não detecta nome de skill adotada sem prefixo nem
`CONTEXT.md` na raiz, e foi por isso que F1 e F2 passaram até aqui.

Pendente: revisão curta de `adb17b3` e do ajuste final; ponto B do Tester.

**Leader, 2026-09-13 — gate Tester, ponto B: APROVADO.** Rodado isolado do `CLAUDE.md` e das rules do
repo pai, em projeto limpo e em projeto com `CONTEXT.md` na raiz: o boot chega ao passo do tracker
sem intervenção, o `anvil-setup` roda sem ser digitado, o perfil de domínio aponta para o layout do
anvil e o perfil do tracker é o do `anvil-docs`. O ponto B do Dev pode ter sido contaminado pelo
`CLAUDE.md` do repo pai; o do Tester não foi, e é ele que vale.

Achado: com `CONTEXT.md` na raiz, o glossário antigo passa despercebido, porque o boot escolhe o
`scaffold` olhando só `docs/` e o setup agora procura no layout do anvil. Regressão desta spec,
corrigida no ticket 14. Pendente para fechar o 02: revisão curta de `adb17b3` e `f51f937`.

**Leader, 2026-09-13 — resolvido.** Gate Review do delta (`adb17b3`, `f51f937`): APROVADO, sem
bloqueante — a seção `tracker-profile` descreve as três linhas reais, o aviso só avisa, o novo
`docs-remap` é mais estreito que o anterior, e o diff do `anvil-setup` contra o pin só tem
`rename`, `docs-remap`, `tracker-profile`, `invocable` e `strip`. Os três gates passaram.

Ficam como ideia, fora da spec: **N1** o bloco de diff da `tracker-profile` junta linhas distantes
(a prosa já as nomeia); **N2** o `anvil-domain-modeling` recalcula links relativos e acrescenta uma
anotação na árvore, duas coisas que o catálogo não descreve — anteriores a esta spec.
