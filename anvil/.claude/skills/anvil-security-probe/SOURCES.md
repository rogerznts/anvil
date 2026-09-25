# SOURCES

Skill autoral (`adr-0012` do anvil — as skills de segurança são autorais,
destiladas das referências). Desta lista entra a **ideia**, nunca o texto:
nenhuma frase de fonte CC-BY-SA-4.0 entra aqui, nem parafraseada de perto.

Este arquivo é vivo: cresce junto com a skill, ticket a ticket da spec
`005-feature-security-map-probe`. A primeira entrada cobre as cinco travas
que rodam antes de qualquer teste (ticket 04); a segunda cobre a execução
dos testes do mapa e a abertura de spec por achado (ticket 05); a
terceira cobre o fechamento e a reabertura de `SEC-#` numa reexecução
(ticket 06).

| De | Licença | O que entrou aqui |
|---|---|---|
| [TobiasVeiga00/claude-security-audit](https://github.com/TobiasVeiga00/claude-security-audit) | MIT | a ideia da trava de escopo explícita — nada vai para a rede sem alvo autorizado por escrito — usada nas travas 2 (recusa de qualquer alvo fora do combinado) e 4 (confirmação explícita antes de executar) |
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | a ideia do `repo-context` — entender o ambiente pelo que o próprio repositório declara antes de agir — usada na trava 2 para descobrir o alvo (script `dev`, `.env`, compose) em vez de aceitar um valor informado à mão |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) e `adr-0012` do anvil | anvil | nenhum candidato pesquisado cobre restringir o alvo a loopback, exigir o mapa como pré-requisito, ou proteger o banco (descartável ou dump com restauração) antes de teste que escreve — as cinco travas, a checagem de resolução DNS para loopback (`reference/target-discovery.md`) e o procedimento de proteção de banco (`reference/database-protection.md`) são desenho e implementação próprios do anvil |
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | a ideia do `validate` — reproduzir o achado contra o app já rodando antes de reportar, nunca confiar num resultado de análise estática sozinho — usada em `reference/test-execution.md` (todo teste é uma requisição real contra o alvo, nunca inferência) |
| [TobiasVeiga00/claude-security-audit](https://github.com/TobiasVeiga00/claude-security-audit) | MIT | a ideia do validador adversarial — tentar refutar o próprio achado antes de registrá-lo — usada na seção 1 de `reference/findings-and-fix-spec.md` (repetir a requisição, rodar o comparativo que aplica o access control, conferir o código, antes de gravar) |
| [trailofbits/skills](https://github.com/trailofbits/skills) | CC-BY-SA-4.0 | a ideia do `fp-check` (triagem de falso positivo) — usada, junto do validador adversarial acima, na seção 1 de `reference/findings-and-fix-spec.md` (a tentativa de refutação antes de registrar); e a ideia do `variant-analysis` (achar a mesma causa repetida em outro lugar) — usada na seção 2, para agrupar achados por causa raiz, não por rota; nenhum texto do `trailofbits/skills` entra aqui, só as duas ideias — a licença CC-BY-SA-4.0 da fonte é o motivo de a skill inteira ser autoral (adr-0012), não um trecho copiado |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) e `adr-0012` do anvil | anvil | nenhum candidato pesquisado cobre a deduplicação contra um índice de achados existente (`findings.md`) antes de abrir spec nova, o formato do achado (causa raiz, severidade `low`/`medium`/`high` na escala do `GATE.md` do `anvil-bench`, itens do mapa afetados, spec), a lacuna de cobertura por ferramenta ausente, ou a abertura da spec `fix` pelo perfil do tracker do projeto — desenho e implementação próprios do anvil, em `reference/test-execution.md` e `reference/findings-and-fix-spec.md` |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) e `adr-0012` do anvil | anvil | nenhum candidato pesquisado cobre retestar um `SEC-#` já registrado a cada rodada, fechar (`corrigido`) só quando todos os ids do achado testam limpo na mesma rodada, reabrir uma causa que volta a reproduzir no mesmo id sem spec nova, ou a lacuna de cobertura por alvo que não respondeu (não só por ferramenta ausente) deixando o `Status:` intocado — desenho e implementação próprios do anvil, na seção 6 de `reference/findings-and-fix-spec.md` |

## Atualização

Manual — esta skill está fora do `anvil-skills.yaml`, sem pin nem sync
automático (adr-0012). Atualiza quando uma referência mudar de ideia, ou
quando um novo ticket da spec acrescentar capacidade à skill.
