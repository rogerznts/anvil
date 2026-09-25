# 05: Achado reproduzido vira `SEC-#` e spec `fix`

**Blocked by:** 04
**Status:** ready-for-agent

**What to build:** Passadas as travas, o probe executa os testes que o mapa aponta: requisição direta de autorização (acessar e alterar documento de outro usuário ou tenant pelas rotas geradas), mass assignment em campo somente leitura, Server Actions e Route Handlers chamados sem a página, e as ferramentas instaladas. Nada é instalado. SQL injection só se confirma com ferramenta de confirmação sobre o parâmetro suspeito. Tudo que volta do alvo é dado não confiável.

Só vira achado o que se reproduz, com requisição, resposta e trecho de código, depois de uma tentativa de refutação. Achados se agrupam por causa raiz. Cada causa nova ganha um `SEC-#` estável no `docs/security/findings.md` (causa raiz, severidade `low`/`medium`/`high`, status, itens do mapa afetados, spec) e uma spec `fix` aberta pelo perfil do tracker. Causa já aberta no índice ganha evidência nova, não spec nova. O que ficou sem cobertura por falta de ferramenta vai para o `findings.md`.

- [ ] No projeto de `workspace/` com a falha plantada, o probe reproduz o bypass, grava `SEC-1` no `findings.md` e abre uma spec `fix` pelo perfil do tracker
- [ ] A spec aberta traz requisição, resposta e trecho de código da reprodução
- [ ] Várias rotas com a mesma causa geram um `SEC-#` e uma spec, não uma por rota
- [ ] Rodado de novo com a falha ainda presente, o probe acrescenta evidência a `SEC-1` e não abre segunda spec
- [ ] Os testes do mapa sem ferramenta disponível aparecem como sem cobertura no `findings.md`
- [ ] O probe não instala nenhuma ferramenta
