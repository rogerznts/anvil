---
name: anvil-sync
description: "Manutenção da curadoria do anvil: vendorizar uma skill nova de um repositório upstream, ressincronizar as já vendorizadas quando o upstream andar, e verificar a integridade do payload. Use ao adotar uma skill, ao atualizar as adotadas, ou antes de publicar uma versão."
---

# Sync da curadoria

Esta skill **não vai no degit**. É ferramenta de manutenção do repositório anvil.

O anvil não escreve suas skills de trabalho — ele curadoriza skills de terceiros.
Isso só se sustenta se der para **voltar ao upstream** quando ele andar. É o que
esta skill faz.

## Como funciona, em uma frase

Os `references/*` são submodules pinados por commit no manifesto, e **o pin é a
base do merge 3-way**:

```
base   = git -C <submodule> show <pin>:<path>/<arquivo>
theirs = git -C <submodule> show <HEAD>:<path>/<arquivo>
ours   = anvil/.claude/skills/<nome>/<arquivo>
```

Nenhum snapshot é guardado. Enquanto o commit existir no submodule — e existe,
porque submodule é clone completo — a base é recuperável de graça.

## Comandos

```bash
S=.claude/skills/anvil-sync/scripts/vendor-sync.sh

bash $S status              # o que andou upstream desde cada pin
bash $S pull                # atualiza os submodules para o HEAD remoto
bash $S vendor <nome>       # primeira cópia de uma skill `planned`
bash $S update [<nome>]     # merge 3-way; sem argumento, todas
bash $S verify              # integridade do payload
```

O script faz o **mecânico**: mover bytes, rodar `merge-file`, aplicar o `rename`,
gravar o pin. Você faz o **julgamento**: `docs-remap` e `decursor`, e resolver
conflito. O script sinaliza o que falta, sempre.

## Adotar uma skill nova

1. **Registre no manifesto** `anvil-skills.yaml`, com `state: planned` e as
   regras de `adapt:` que ela vai precisar. Sem entrada, o script não a conhece.
2. `bash $S vendor <nome>` — copia do submodule no HEAD atual, aplica o `rename`,
   grava o pin e marca `vendored`.
3. **Aplique as regras de julgamento** que o script listou. Leia o arquivo; não
   faça `sed` às cegas. O catálogo está em [ADAPT-RULES.md](ADAPT-RULES.md).
4. `bash $S verify`.
5. Se a skill tiver origem que mereça registro — licença, fork, problema conhecido
   no upstream — escreva um `VENDOR.md` dentro dela e adicione-o ao `keep:`.

**Antes de adaptar qualquer coisa, releia a regra que governa tudo:** o padrão é
o da skill original; o anvil impõe só *onde* o arquivo é salvo dentro de `docs/`.
Bateu dúvida, o padrão é do autor.

## Ressincronizar

```bash
bash $S pull
bash $S status        # quem ficou atrasada
bash $S update        # todas, ou uma por vez
```

**Merge limpo** → o script grava o pin novo e diz quais regras de julgamento
revisar. Confira o diff mesmo assim: limpo não quer dizer certo.

**Conflito** → o pin **não** avança. Resolva os marcadores nos arquivos que o
script listou e rode o `update` de novo. Ao resolver, o lado do anvil só ganha
quando há uma regra do catálogo justificando; caso contrário, o upstream ganha.

**Arquivo que sumiu upstream** → o script **reporta e não apaga**. Decida:
sumiu porque foi renomeado (então há um arquivo novo correspondente), ou porque
o autor removeu (então provavelmente deve sair daqui também).

## Se o merge der trabalho demais

Um conflito grande é sinal de que a skill foi modificada além do catálogo. Nesse
caso o problema não é o merge — é a modificação. Volte, veja o que foi mudado e
por quê, e pergunte se aquilo não deveria estar no perfil de tracker
(`docs/agents/issue-tracker.md`) ou numa rule do projeto, em vez de dentro do
arquivo da skill.

## O que o `verify` checa

1. `name:` do frontmatter casando com o diretório
2. links relativos resolvendo — pulando `starter/` e `templates/`, cujos links
   apontam para o projeto-alvo, não para a própria posição
3. nenhum caminho relativo cruzando fronteira de skill — dependência entre skills
   se declara chamando a Skill tool, não com `../../`
4. denylist de tokens do upstream que deveriam ter sido adaptados
5. nenhum identificador **operacional** do mosk — caminho ou nome de runtime que
   não existe depois do degit. Menção em prosa é documentação e passa; um arquivo
   pode declarar `anvil-verify: allow-mosk-ops` com motivo, e a dispensa é
   **impressa**, nunca silenciosa
6. toda skill `vendored` no manifesto existe no payload

## Requisitos

`python3` com `PyYAML`, para ler o manifesto. Só nesta ferramenta — o payload que
o degit copia não depende disso.
