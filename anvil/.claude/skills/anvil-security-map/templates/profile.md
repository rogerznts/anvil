# Perfil de segurança

Gerado por `/anvil-security-map` em {{DATA}}. Regravado inteiro a cada
execução — não edite à mão; edite via nova execução do map.

## Stack

- {{TECNOLOGIA}} {{VERSAO}} — detectada por {{EVIDENCIA}}
- Checklist de segurança: {{presente, caminho | ausente}}
  {{- se ausente}}
  — nenhum checklist para esta stack. Este mapa cobre só a parte genérica; a
  parte específica desta tecnologia ficou de fora.
  {{- fim se}}

## Ferramentas de segurança

| Ferramenta | Presente |
|---|---|
| semgrep | {{sim/não}} |
| osv-scanner | {{sim/não}} |
| npm audit | {{sim/não}} |
| pnpm audit | {{sim/não}} |
| gitleaks | {{sim/não}} |
| trufflehog | {{sim/não}} |
| zap | {{sim/não}} |
| nuclei | {{sim/não}} |
| sqlmap | {{sim/não}} |
| schemathesis | {{sim/não}} |
| graphql-cop | {{sim/não}} |
| clairvoyance | {{sim/não}} |

## Ambiente local

- **Alvo:** {{URL descoberta em package.json/.env, ou "não encontrado"}}
- **Banco:** {{adapter e origem — .env, docker-compose —, ou "não encontrado"}}

Nenhum dos dois foi acessado. O map só leu arquivo do projeto.

## Consulta de advisories

Fontes fechadas: [OSV.dev](https://osv.dev) (API pública, por pacote e
versão) e, quando o checklist da stack detectada declarar um repositório, os
GitHub Security Advisories desse repositório. Nenhuma outra fonte —
procedimento completo em `reference/advisory-lookup.md` da skill.

- **Data da consulta:** {{DATA}}
- **Pacotes e versões consultados:** {{lista pacote@versão — todas as
  dependências diretas de package.json com versão resolvida do lockfile; se
  faltou lockfile para alguma, diga quais ficaram de fora}}
- **OSV.dev:** {{consultada com sucesso | não foi possível: <motivo — timeout, DNS, conexão recusada, HTTP de erro>}}
- **GitHub Security Advisories ({{repositório da stack, ou "—"}}):**
  {{consultada com sucesso | não se aplica — checklist da stack não declara
  repositório, ou nenhuma stack detectada | não foi possível: <motivo>}}

{{- se alguma das duas fontes não foi consultada}}

Consulta externa incompleta: os achados de dependência em `map.md` refletem
só a(s) fonte(s) que respondeu(ram); o resto do mapa (checklist, parte
genérica) não depende de rede e está completo.

{{- fim se}}
