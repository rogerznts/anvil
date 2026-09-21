# ADR-0009 — O toolkit instalado fica versionado no projeto

- Status: aceito
- Data: 2026-09-21
- Revoga a decisão de ignorar o toolkit registrada na spec 001 e implementada pelo bloco `ANVIL:INSTALLED`

## Contexto

Até aqui, o `/anvil-boot` escrevia no `.gitignore` do projeto um bloco
`ANVIL:INSTALLED` gerado do `.claude/anvil.lock`, com uma linha por skill e por
agente instalado, e o `/anvil-update` regenerava esse bloco a cada reinstalação. O
argumento era o peso: ~2 MB de skill de terceiro no histórico do projeto, e um diff
gigante a cada update.

O que esse desenho cobra, medido no próprio toolkit:

- **Um clone não roda.** Quem clona o projeto tem `.claude/rules/` e o lock, mas
  nenhuma skill: precisa rodar o degit e torcer para o payload publicado ainda ser
  o mesmo. O lock diz o nome do que falta, não a versão — não há pin de payload.
- **Máquina.** Geração do bloco a partir do lock, reescrita entre marcadores,
  preservação de CRLF e de permissões, guarda de marcador fora de par, modo
  `--gitignore-only`, migração da linha antiga com aprovação, e a pergunta "alguma
  dessas não veio do anvil?" repetida em dois passos do boot.
- **Uma pergunta que o usuário não deveria precisar responder** no meio do boot, com
  um "não" deixando o projeto num estado intermediário — marcadores vazios, ou linha
  antiga convivendo com bloco novo.

O peso é real, mas é peso de repositório de código, que git comprime e que só se
paga quando o toolkit muda. O custo do outro lado é permanente e recai sobre quem
usa.

## Decisão

**Tudo que o degit instala fica versionado no projeto:** `.claude/skills/`,
`.claude/agents/` e `.claude/anvil.lock`, ao lado do que já era versionado —
`.claude/rules/`, `.claude/settings.json` e `docs/`.

**O boot não escreve no `.gitignore`**, não pergunta o que ignorar e não oferece
tirar o toolkit do repositório. **O update também não cria bloco nenhum.**

**A migração é ativa, não silenciosa.** Projeto instalado por uma versão antiga tem
o toolkit ignorado, por um bloco `ANVIL:INSTALLED` ou pela linha que cobria
`.claude/skills/` inteiro:

- o `reset-install.sh` ganha `--unignore`, que remove o bloco — e só ele — do
  `.gitignore`, preservando fim de linha e permissões;
- o passo 10 do boot procura o bloco e a linha antiga, mostra o que sairia e
  **espera aprovação** antes de tirar;
- o reset do `/anvil-update` remove o bloco sozinho e relata a remoção;
- linha parecida que o boot não escreveu continua intocada: é do usuário.

## Alternativas descartadas

- **Manter o bloco e oferecer versionar tudo como opção.** É a situação anterior:
  os dois caminhos existem, a pergunta continua no boot, e a máquina de escrever o
  bloco continua de pé para o caminho menos usado.
- **Versionar por padrão, mas deixar o bloco disponível num verbo.** Mesmo custo de
  manutenção, menos exercitado ainda.
- **Pinar o payload no lock e continuar ignorando.** Resolveria a reprodutibilidade
  e custaria mais máquina — publicar versão, resolver pin, falhar quando a tag some.
  O repositório do projeto já é o lugar onde uma versão fica congelada.

## Consequências

**A favor.** Clone do projeto já vem com o toolkit exato que foi usado. O update
vira um diff revisável em vez de uma mudança invisível. Somem o bloco, os
marcadores, a migração de linha antiga na escrita e as perguntas do boot sobre o
que ignorar.

**Contra.** O repositório do projeto engorda com o payload, e um `/anvil-update`
aparece como diff grande no `git status` — que é exatamente o que se quer revisar,
mas é volume. Projeto que não queira isso escreve a própria linha no `.gitignore`:
o toolkit respeita linha que não foi ele quem escreveu.
