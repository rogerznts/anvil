# 02: O map grava o perfil e o mapa

**Blocked by:** 01
**Status:** resolved

**What to build:** Um desenvolvedor roda `/anvil-security-map` num projeto com o anvil instalado, com ou sem ter passado pelo boot, e ganha `docs/security/profile.md` e `docs/security/map.md`. O map não executa nada contra o app: roda sem servidor de dev no ar.

O map detecta a stack pelo que existe no repositório, carrega o checklist da skill da stack quando houver, e soma a parte genérica: pontos onde entrada vira risco (SQL cru, execução de comando, caminho de arquivo, fetch de URL do usuário, template), autorização por rota, Server Actions e Route Handlers como endpoints públicos, autorização feita só no middleware, segredos, CORS e headers.

`profile.md`: stack, se há checklist, ferramentas de segurança presentes e ausentes, alvo local descoberto, banco. `map.md`: itens por categoria do OWASP Top 10:2025 e, em API, do API Security Top 10:2023; cada item com id estável, arquivo:linha verificado e o teste que o probe aplica ou "só leitura". No Payload, cada collection aparece com as rotas geradas e as `access` definidas ou ausentes.

A skill é autoral (adr-0012) e traz `SOURCES.md` com a origem de cada ideia.

- [x] Num projeto Payload descartável em `workspace/` com um route handler que chama a Local API com `user` e sem `overrideAccess: false`, o mapa lista essa falha com arquivo:linha correto
- [x] Numa stack sem checklist, o mapa sai com a parte genérica e diz explicitamente que a parte específica ficou de fora
- [x] Rodar o map de novo regrava `profile.md` e `map.md` e não toca em `findings.md`
- [x] O map não faz requisição ao app do projeto
- [x] A skill traz `SOURCES.md` e não contém texto de fonte CC-BY-SA
