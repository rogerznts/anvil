# SOURCES

Skill autoral (`adr-0012` do anvil — as skills de segurança são autorais,
destiladas das referências). Desta lista entra a **ideia**, nunca o texto:
nenhuma frase de fonte CC-BY-SA-4.0 entra aqui, nem parafraseada de perto.

Este arquivo é vivo: cresce junto com a skill, ticket a ticket da spec
`005-feature-security-map-probe`. Esta entrada cobre as cinco travas que
rodam antes de qualquer teste (ticket 04).

| De | Licença | O que entrou aqui |
|---|---|---|
| [TobiasVeiga00/claude-security-audit](https://github.com/TobiasVeiga00/claude-security-audit) | MIT | a ideia da trava de escopo explícita — nada vai para a rede sem alvo autorizado por escrito — usada nas travas 2 (recusa de qualquer alvo fora do combinado) e 4 (confirmação explícita antes de executar) |
| [ghostsecurity/skills](https://github.com/ghostsecurity/skills) | Apache-2.0 | a ideia do `repo-context` — entender o ambiente pelo que o próprio repositório declara antes de agir — usada na trava 2 para descobrir o alvo (script `dev`, `.env`, compose) em vez de aceitar um valor informado à mão |
| pesquisa própria do anvil (`docs/discovery/seguranca-map-probe.md`, fora deste payload) e `adr-0012` do anvil | anvil | nenhum candidato pesquisado cobre restringir o alvo a loopback, exigir o mapa como pré-requisito, ou proteger o banco (descartável ou dump com restauração) antes de teste que escreve — as cinco travas, a checagem de resolução DNS para loopback (`reference/target-discovery.md`) e o procedimento de proteção de banco (`reference/database-protection.md`) são desenho e implementação próprios do anvil |

Fora daqui, porque alimentam um ticket seguinte da mesma spec, não estas
travas: o `validate`/`proxy` do Ghost e o validador adversarial do
`claude-security-audit` (reproduzir e tentar refutar um achado antes de
registrá-lo), e o `fp-check`/`variant-analysis` da Trail of Bits — a
execução dos testes do mapa e a abertura de spec por achado ainda não
existem nesta skill.

## Atualização

Manual — esta skill está fora do `anvil-skills.yaml`, sem pin nem sync
automático (adr-0012). Atualiza quando uma referência mudar de ideia, ou
quando um novo ticket da spec acrescentar capacidade à skill.
