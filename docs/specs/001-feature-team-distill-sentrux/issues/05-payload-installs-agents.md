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
- [ ] Ponto A: payload de teste com um agente, e projeto descartável com um agente do usuário.

## Comments

**Leader, 2026-09-13 — contrato com a equipe.** Os checks do `verify` deste ticket seguem a seção 3 de
o desenho em `architecture/team-shape.md` (`384fc45`), para o 06 não precisar reabrir o 05.
