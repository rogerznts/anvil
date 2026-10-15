# 04: P3 da rodada 1 do ticket 05 da 006 vão para o acompanhamento

**What to build:** Os P3 da rodada 1 do ticket 05 da spec 006 (migração de projeto antigo) que a 007 não resolve deixam de existir só no `## Comments` de uma spec arquivada. Eles ganham uma seção da spec 006 em `docs/project/acompanhamento.md`, no formato das seções que já estão lá: origem e, em cada linha, o que acontece se ninguém mexer.

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=c0db4c7; scope=full; verdict=pass; p1=none

- [x] A seção da spec 006 aponta a origem: a pasta arquivada da 006 e o ticket 05.
- [x] Uma linha por P3, cada uma com a consequência:
  - qualquer menção à guarda no settings, numa string de `permissions` por exemplo, faz o projeto contar como instalação antiga;
  - o awk de marcadores da migração repete o do `reset-install.sh`;
  - a árvore de decisão do dry-run se repete no passo 2 do boot e no passo 5 do update;
  - o `json.dump` regrava a formatação do settings inteiro;
  - o aviso de perfil acusa `/Users/<u>/.claude/...` e `"${HOME}"/.claude/...` como caminho da instalação por projeto.
- [x] As linhas seguem a numeração `A<n>` do arquivo, a partir da próxima livre.

## Comments

- Seção `## Spec 006` em `docs/project/acompanhamento.md`, linhas A15 a A19, na ordem dos critérios. A próxima livre é a A15: a A13 já foi usada e saiu do arquivo em `a2a3bdd`, e o arquivo não reaproveita número — a A14 ficou com o seu depois disso.
- Sem teste: o ticket é só documentação, e a spec diz que texto sem seam executável se confere lendo. Cada consequência foi conferida contra o `migrate-project.sh` atual: o `grep -qF` da guarda no settings inteiro, o `json.dump(indent=2)`, o regex do aviso de perfil e o awk de marcadores comentado "como o reset-install".
- Review round=1 · P3 (Spec): a A16 diz que a instalação e a migração leriam "o mesmo bloco", mas o `reset-install.sh` lê o `~/.claude/CLAUDE.md` e a migração o `CLAUDE.md` do projeto — é o mesmo formato de marcadores, não o mesmo bloco; quem pegar a linha pode procurar um arquivo compartilhado que não existe.
- Review round=1 · P3 (Spec): no parágrafo de origem, "resolveu o das respostas pela metade" não nomeia o P3 do `--keep-skills` sem `--keep-agents`; o leitor precisa abrir o `## Comments` da 006 para saber qual P3 ficou fora da seção.
- Review round=1 · P3 (Standards): a A19 diz que o aviso "desconta só" quatro formas, mas o `"?\$HOME"?` também desconta `"$HOME/.claude/` e `$HOME"/.claude/`; quem pegar a linha pode corrigir um caso que não está quebrado.
- Review round=1 · P3 (Standards): a A18 atribui o "settings fora da entrada do hook intocados" à 006 em geral, mas a frase vem do critério da linha 21 do ticket 05 da 006, não do `spec.md`; quem procurar a citação na spec não a acha.
- Review round=1 · P3 (Standards): neste `## Comments`, a A13 e a A14 aparecem sem glosa na primeira menção, contra o "citar id sempre com a glosa" do `CLAUDE.md`; quem lê não sabe o que eram essas linhas sem abrir o `a2a3bdd`.
- Review round=1 · P3 (Standards): o comentário acima diz que cada consequência foi conferida contra o `migrate-project.sh`, mas a da A17 está nas duas skills, o passo 2 do `anvil-boot` e o passo 5 do `anvil-update`; a frase aumenta o que foi conferido, embora a A17 esteja certa.
- Fechamento (archive): os quatro P3 sobre o texto da seção 006 — A16, A18, A19 e o parágrafo de origem — foram corrigidos no próprio `acompanhamento.md`. Os dois sobre este `## Comments` (A13/A14 sem glosa, "conferido contra o `migrate-project.sh`") foram aceitos: o comentário congela com a spec.
