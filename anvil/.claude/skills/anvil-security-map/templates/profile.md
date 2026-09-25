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
| npm audit / pnpm audit | {{sim/não}} |
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
