# 07: Integração com o toolkit: boot, docs e rules

**Blocked by:** 02
**Status:** resolved
**Review:** round=1; sha=e6fadd2; scope=full; verdict=pass; p1=none

**What to build:** O toolkit passa a conhecer as skills de segurança. O `/anvil-boot`, no passo em que detecta a stack e propõe a rule dela, sugere rodar o `/anvil-security-map`, com uma linha dizendo a stack e se ela tem checklist; recusado, segue normalmente e não grava nada de segurança. O `anvil-docs` passa a conhecer `docs/security/` na árvore e no índice: a pasta nasce quando o map escreve nela, como as demais pastas com escritor. O `.claude/rules/project.md` lista as duas skills entre as autorais.

- [x] Num projeto Payload, o boot sugere o map com a justificativa de uma linha
- [x] Recusada a sugestão, o boot termina sem criar `docs/security/`
- [x] O `anvil-docs` descreve `docs/security/` com `profile.md`, `map.md`, `findings.md` e quem escreve cada um, e o índice gerado lista a pasta quando ela existe
- [x] O `.claude/rules/project.md` lista `anvil-security-map` e `anvil-security-probe` entre as skills autorais

## Comments

- Prova ponta a ponta em `workspace/05-security-map/`: um subagente fresco,
  seguindo só o texto do `anvil-boot/SKILL.md`, rodou o boot inteiro num
  projeto Payload descartável (`payload-boot-fixture/`, git iniciado, sem
  `CLAUDE.md`/`docs/` prévios). No passo 7 propôs `.claude/rules/payload.md`
  (aprovado) e sugeriu `/anvil-security-map` citando a stack e o checklist —
  "A stack é Payload, que tem checklist de segurança
  (`anvil-stack-payload/security/CHECKLIST.md`)…" —; a sugestão foi recusada
  e, confirmado depois com `find docs` e `[ -d docs/security ]`, nenhum
  `docs/security/` nem chamada à skill `anvil-security-map` aconteceu. Outro
  subagente fresco, seguindo o `anvil-docs/INDEX.md`, rodou o verbo `index`
  em `payload-vulnerable/` (que já tinha `docs/security/{profile,map,findings}.md`
  gravados por tickets anteriores) e o `docs/index.md` gerado trouxe a linha
  `[Security](./security/)`, com os outros domínios ausentes (`discovery`,
  `prd`, `architecture`, `ui`, `qa`, `project`) corretamente omitidos.
- Decisão menor, registrada aqui: `dev-link.sh` **não** ganhou
  `anvil-security-map`/`anvil-security-probe` no roster de fluxo deste
  repositório. Mesma razão já documentada ali para UI/stack/bench — este
  repositório é o toolkit fonte, não um app com rota, Local API ou banco
  local para mapear/testar. O comentário do script foi estendido para
  nomear essa exceção explicitamente, em vez de deixar a ausência implícita.
- Review round=1 · Standards · P3: o rótulo do nó `B7` do mermaid no
  `README.md` lia "…e sugere /anvil-security-map / espera aprovação", dando a
  entender uma aprovação só para as duas propostas, quando o boot pede duas
  aprovações separadas. Corrigido no mesmo commit para "duas aprovações
  separadas".
- Review round=1 · Standards · P3: a linha nova de `security/` na árvore do
  `anvil-docs/SKILL.md` tinha 113 colunas (as demais chegam a ~89) e ficava
  antes de `prd/`, enquanto o README e o `CANONICAL` do `validate.sh` já
  colocavam segurança depois de `qa/` — divergência entre as três árvores.
  Corrigido no mesmo commit: reordenada para depois de `qa/`, descrição
  enxugada para ~100 colunas.
- Review round=1 · Standards · P3: `docs/architecture/overview.md` usava
  "security (2)" onde o padrão vizinho é "tea-\* (4)". Corrigido no mesmo
  commit para "security-\* (2)".
- Review round=1 · Standards · P3: a troca de "seis" por "sete lacunas" em
  `anvil-docs/SKILL.md` (a contagem de capacidades do contrato de stack)
  ficava fora do texto literal deste ticket — é resíduo do ticket 01, que já
  tinha corrigido a mesma contagem em `STACK-CONTRACT.md` e
  `docs/architecture/overview.md` mas não neste arquivo. Mantida a correção,
  no mesmo espírito do achado equivalente registrado no ticket 01. Sem
  consequência se não for revertida: a contagem certa é a sete, como
  `STACK-CONTRACT.md` já dizia.
- Review round=1 · Standards · P3, sem ação: a ressalva sobre
  `SOURCES.md`/adr-0012 aparece tanto no `README.md` quanto no
  `.claude/rules/project.md` (Duplicated Code) — mesmo padrão que o
  parágrafo do `anvil-bench` já usa nos dois arquivos, cada um por público
  diferente (README é a porta pública, `project.md` é a regra interna).
- Review round=1 · Standards · P3, sem ação: a `description` do front-matter
  do `anvil-boot` e a linha da tabela "Infraestrutura do toolkit" no
  `README.md` não citam a sugestão de segurança do passo 7. Quem lê só o
  resumo não sabe que ela existe, mas nenhum comportamento muda — o texto
  completo do `SKILL.md` é a fonte, não o resumo.
- Review round=1 · Spec · P3, sem ação: o marcador `◆` da árvore
  ("uma skill cria no primeiro uso") é genérico e não distingue que
  especificamente o **map** escreve `profile.md`/`map.md` — a distinção
  fica só na tabela "Quem escreve onde", não na árvore. A tabela já resolve
  a ambiguidade para quem lê o arquivo inteiro.
- Review round=1 · Spec · P3, sem ação: o mermaid do `README.md` não
  desenha o ramo em que a sugestão do map é aceita — só o de recusa segue
  visível no fluxograma. Não muda comportamento, só reduz o diagrama.
