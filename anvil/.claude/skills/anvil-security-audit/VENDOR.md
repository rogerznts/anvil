# Proveniência

Tudo nesta pasta, menos este arquivo, é **cópia vendorizada** de um projeto
upstream. Não edite como se fosse conteúdo do anvil.

## Upstream

| | |
|---|---|
| Projeto | [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) — auditoria de segurança por código-fonte |
| Autor | Cloudflare, Inc. |
| Caminho de origem | `skills/security-audit/` |
| Pin de referência | `c1c8a8c1471069fb0e188eeaff69b8e8db6564a8` |
| Submodule | `references/security-audit-skill` |
| Licença | MIT, texto abaixo |

O pin desta tabela é o da primeira cópia. O pin vigente, base do merge 3-way, é o
do `anvil-skills.yaml`.

A pasta veio inteira: o `SKILL.md`, as referências, o `report-schema.json`, os
dois validadores `.cjs` e os testes deles. O `README.md` e o `LICENSE` da raiz do
upstream ficam de fora, por estarem fora do caminho de origem; o texto da licença
está reproduzido abaixo.

## Adaptação

**Só o `rename`.** O `name:` do frontmatter do `SKILL.md`, de `security-audit`
para `anvil-security-audit`. A `description` e o corpo ficam verbatim, inclusive o
diretório de saída da auditoria, fora do repositório auditado (ADR-0015 do anvil).

## Ressincronizar

Pelo `/anvil-sync`, que usa o pin do manifesto como base do merge 3-way. Depois de
cada sync, os testes do upstream provam que a cópia funciona:

```bash
node --test anvil/.claude/skills/anvil-security-audit/*.test.cjs
```

Achou erro no conteúdo? Reporte no upstream: a correção volta no próximo sync.

## Licença do upstream

```text
MIT License

Copyright (c) 2025-2026 Cloudflare, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
