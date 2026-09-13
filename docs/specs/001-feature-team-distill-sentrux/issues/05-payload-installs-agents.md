# 05: O payload instala, substitui e remove agentes

**What to build:** Com um payload que traz agentes, o update instala, substitui e remove agentes como já faz com skills, e deixa em paz o agente que o usuário escreveu. O lock registra os agentes, o bloco do gitignore os lista, o `verify` pega lock incompleto e agente citando caminho inexistente, e este repositório passa a ligar os agentes do payload.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] O lock ganha linhas `agent:`, e um leitor antigo as ignora sem quebrar.
- [ ] A geração do lock no `vendor-sync` emite os agentes do payload.
- [ ] O `reset-install` classifica agentes em substituídos, órfãos, alheios e preservados, e o dry-run mostra a classificação.
- [ ] O bloco `ANVIL:INSTALLED` lista os agentes instalados.
- [ ] O `verify` reprova um lock sem um agente do payload, e um agente que cita caminho inexistente.
- [ ] O `dev-link` liga os agentes do payload neste repositório.
- [ ] A migração do mosk no boot remove só as personas do mosk, não o diretório de agentes.
- [ ] Contrato de citação com a equipe (desenho, seção 3): num agente, caminho do payload se cita só em crase, relativo à raiz de instalação (`.claude/...`).
- [ ] O `verify` reprova: `name:` do agente diferente do nome do arquivo; span em crase começando com `.claude/` (sem `*`, `{` ou `<`, fora de bloco cercado) que não existe no payload; link markdown relativo num arquivo de agente.
- [ ] Achados do Review no ticket 04 que ficam aqui, porque este ticket mexe no lock e no bloco nos mesmos passos do boot:
- [ ] N1 — com skill do lock faltando no disco, a pergunta do passo do lock cobre também as skills (e agora os agentes) que o lock lista: nada do usuário volta ao lock sem ter sido perguntado.
- [ ] N2 — a busca da linha antiga e do START no passo do gitignore normaliza o fim de linha como o script (espaço, tab e `\r`).
- [ ] N3 — a troca da linha antiga pelos marcadores mantém o fim de linha do arquivo.
- [ ] N4 — a pergunta é "quais não vieram do anvil", não "quais o usuário escreveu".
- [ ] N5 — o identificador `MINHAS` nos `SKILL.md` vira `USER_SKILLS`.
- [ ] A receita do `anvil-update` para instalação sem lock deixa de pôr no lock o que não veio do anvil e não grava em `/tmp` como se fosse o lock.
- [ ] Ponto A: payload de teste com um agente, e projeto descartável com um agente do usuário.

## Comments

**Leader, 2026-09-13 — contrato com a equipe.** Os checks do `verify` deste ticket seguem a seção 3 de
o desenho em `architecture/team-shape.md` (`384fc45`), para o 06 não precisar reabrir o 05.

**Leader, 2026-09-13 — escopo acrescentado.** N1–N5 e a receita do update vêm do reteste do Review no
ticket 04 (detalhe nos comentários de lá). Cobrir no cenário: lock antigo com skill do usuário e skill
do lock faltando no disco; START com espaço no fim; troca em CRLF mantendo CRLF.
