# 02: O map grava o perfil e o mapa

**Blocked by:** 01
**Status:** resolved
**Review:** round=1; sha=3de00ac; scope=full; verdict=pass; p1=none

**What to build:** Um desenvolvedor roda `/anvil-security-map` num projeto com o anvil instalado, com ou sem ter passado pelo boot, e ganha `docs/security/profile.md` e `docs/security/map.md`. O map não executa nada contra o app: roda sem servidor de dev no ar.

O map detecta a stack pelo que existe no repositório, carrega o checklist da skill da stack quando houver, e soma a parte genérica: pontos onde entrada vira risco (SQL cru, execução de comando, caminho de arquivo, fetch de URL do usuário, template), autorização por rota, Server Actions e Route Handlers como endpoints públicos, autorização feita só no middleware, segredos, CORS e headers.

`profile.md`: stack, se há checklist, ferramentas de segurança presentes e ausentes, alvo local descoberto, banco. `map.md`: itens por categoria do OWASP Top 10:2025 e, em API, do API Security Top 10:2023; cada item com id estável, arquivo:linha verificado e o teste que o probe aplica ou "só leitura". No Payload, cada collection aparece com as rotas geradas e as `access` definidas ou ausentes.

A skill é autoral (adr-0013) e traz `SOURCES.md` com a origem de cada ideia.

- [x] Num projeto Payload descartável em `workspace/` com um route handler que chama a Local API com `user` e sem `overrideAccess: false`, o mapa lista essa falha com arquivo:linha correto
- [x] Numa stack sem checklist, o mapa sai com a parte genérica e diz explicitamente que a parte específica ficou de fora
- [x] Rodar o map de novo regrava `profile.md` e `map.md` e não toca em `findings.md`
- [x] O map não faz requisição ao app do projeto
- [x] A skill traz `SOURCES.md` e não contém texto de fonte CC-BY-SA

## Comments

- Review round=1 · Standards · P2: o passo 5 do `SKILL.md` restated quase
  palavra por palavra o "como reconhecer" do item 1 do checklist do Payload,
  e `reference/generic-checks.md` citava "o item 2 do checklist do Payload"
  por número — a skill agnóstica não deveria carregar conhecimento nem
  numeração de uma stack específica (adr-0013). Corrigido no mesmo commit:
  o passo 5 agora é uma regra agnóstica ("uma linha por ocorrência"), e a
  referência ao Payload em `generic-checks.md` não cita mais número de item.
- Review round=1 · Standards · P2: `command -v zap`/`graphql-cop` não bate
  com os binários reais de instalação (`zap.sh`/`zaproxy`/`zap-baseline.py`,
  `graphql-cop.py`), e a checagem de `npm audit`/`pnpm audit` testava só o
  primeiro apesar do template listar os dois juntos. Corrigido no mesmo
  commit: detecção por múltiplos nomes de binário, e uma linha por
  ferramenta no template.
- Review round=1 · Standards · P3: conflito entre "copie o teste do probe
  verbatim" (passo 5) e a substituição de texto do item de versões (passo
  8) — corrigido para deixar explícito que a nota é um acréscimo ao texto
  verbatim do checklist, não uma substituição.
- Review round=1 · Standards · P3: a linha do `claude-security` em
  `SOURCES.md` reivindicava um artefato legível por máquina (`.jsonl`/
  `.sarif`) que esta skill não grava — corrigido no mesmo commit para dizer
  que esse artefato ficou de fora, e que `arquivo:linha` faz esse papel.
- Review round=1 · Spec · P2: a prova da regravação (critério 3) veio só do
  autorrelato textual dos subagentes que exercitaram a skill, sem hash/mtime
  de arquivo comparados entre duas rodadas contra um `findings.md`
  pré-existente. Refeito após a rodada de revisão: plantei um
  `findings.md` real no cenário `payload-vulnerable`, rodei o map de novo, e
  comparei sha256/mtime antes e depois — `findings.md` saiu com hash e mtime
  idênticos (nunca tocado); `profile.md` saiu com hash diferente e mtime novo
  (reescrito, refletindo a correção de detecção de ferramentas); `map.md`
  saiu com mtime novo e hash igual (reescrito, e determinístico — confirma a
  garantia de id estável de `reference/categories.md` quando o código não
  muda).
- Review round=1 · Spec · P3: `reference/categories.md` já deixa explícito
  que o id renumera se o código mudar entre execuções — "estável" vale só
  entre execuções sem edição. Nenhuma ação: a ressalva já está no arquivo,
  ninguém é enganado ao lê-lo.
