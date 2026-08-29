# ADR-0002 — A organização documental do anvil é um perfil de issue tracker

- Status: aceito
- Data: 2026-08-28
- Depende de: [adr-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md)

## Contexto

O anvil quer que os artefatos caiam em `docs/specs/{NNN}-{tipo}-{nome}/`. As
skills do Matt, no padrão de fábrica, publicam em `.scratch/<feature-slug>/`.

O caminho óbvio seria reescrever as quatro skills de fluxo (`to-spec`,
`to-tickets`, `code-review`, `wayfinder`) para conhecerem `docs/specs/`. Isso
viola o [adr-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md) e
cria delta em quatro arquivos.

Só que o tracker **não está hardcoded em skill nenhuma**. Ele vive em
`docs/agents/issue-tracker.md`, um documento do projeto gerado a partir de um
seed, e o `setup-matt-pocock-skills` diz textualmente:

> *"For 'other' issue trackers, write `docs/agents/issue-tracker.md` from scratch
> using the user's description."*

O ponto de extensão já existe, e é declarado.

## Decisão

**A organização documental do anvil é um quarto perfil de tracker**, ao lado de
`issue-tracker-github.md`, `issue-tracker-gitlab.md` e `issue-tracker-local.md`.

O `setup-matt-pocock-skills` é vendorizado como `anvil-setup`, e o anvil
acrescenta um único arquivo à pasta dele: `issue-tracker-anvil.md`. O
`/anvil-boot` chama o setup, que escreve o perfil no projeto.

O perfil declara, no formato do seed local:

- uma spec por diretório, `docs/specs/{NNN}-{tipo}-{nome}/`
- a spec é `spec.md`; os tickets são um arquivo por ticket em `issues/`
- *publish to the issue tracker* → rodar `new-spec.sh`
- *fetch the relevant ticket* → resolver a pasta pelo prefixo numérico
- as operações de wayfinding, com `map.md` e os filhos em `issues/`

**Nenhuma skill de fluxo sabe o que é `docs/specs/`.** Todas seguem o perfil.

O estado "concluído" usa `Status: resolved`, que já é vocabulário do Matt — o
perfil local dele define `claimed`/`resolved` para os tickets de wayfinding, e o
anvil só estende esse uso para os tickets de implementação.

## Consequências

**A favor.** A adaptação vira um arquivo em vez de quatro patches. `to-tickets` e
`code-review` ficam com **zero** modificação: o `.scratch/` que o primeiro cita
está dentro de *"How depends on the tracker configured"* — é exemplo, não caminho
fixo; e o segundo aponta para `docs/agents/issue-tracker.md` e procura spec em
`docs/`/`specs/`, que já é onde elas ficam.

**Contra.** O perfil vira um ponto único de falha silenciosa: se
`docs/agents/issue-tracker.md` não existir ou estiver errado, as skills publicam
no lugar errado sem reclamar. Mitigação: o `/anvil-boot` escreve o perfil como
parte do bootstrap, e a verificação ponta a ponta confere que os artefatos caem
no lugar certo.

**O que isso torna barato.** Mudar o modelo de pastas depois é editar um arquivo,
não revisitar as skills.
