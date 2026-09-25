# Mapa de superfície de ataque

Gerado por `/anvil-security-map` em {{DATA}}. Regravado inteiro a cada
execução — não edite à mão; edite via nova execução do map. Ids e categorias
seguem `reference/categories.md` da skill.

{{- se não houver checklist da stack}}

> Sem checklist de segurança para {{STACK}}. Este mapa cobre só a parte
> genérica; a parte específica desta tecnologia ficou de fora.

{{- fim se}}

Categoria sem achado não aparece abaixo.

## OWASP Top 10:2025

### {{CATEGORIA, ex.: A01 — Broken Access Control}}

| id | descrição | arquivo:linha | teste do probe | precedente |
|---|---|---|---|---|
| {{A01-01}} | {{descrição curta}} | {{caminho:linha}} | {{teste, ou "só leitura"}} | {{link do checklist, ou "—" no genérico}} |

## API Security Top 10:2023

Só quando o projeto expõe API gerada (Payload: sempre).

### {{CATEGORIA, ex.: API1 — Broken Object Level Authorization}}

| id | descrição | arquivo:linha | teste do probe | precedente |
|---|---|---|---|---|
| {{API1-01}} | collection `{{nome}}`: REST `GET/POST/PATCH/DELETE` e GraphQL equivalentes gerados; `access` {{define X / não define}} | {{caminho:linha}} | {{teste do item 1 do checklist}} | {{link}} |
