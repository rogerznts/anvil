# 01: A skill da Cloudflare entra no payload, vendorizada e verificada

**What to build:** O repositório `cloudflare/security-audit-skill` vira upstream do anvil e a pasta `skills/security-audit/` dele entra no payload como `anvil-security-audit`, copiada pelo `vendor-sync.sh vendor`, com pin, com o `rename` como única adaptação e com um `VENDOR.md` do anvil que registra a origem e a licença MIT. A cópia é a do upstream, testes e validadores inclusos, e prova sozinha que funciona. Ver a spec, "Implementation Decisions".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] O upstream é um submodule em `references/`, registrado no `.gitmodules`, e a fonte `cloudflare` está em `sources:` do `anvil-skills.yaml`.
- [ ] A entrada `anvil-security-audit` está em `skills:` com `source: cloudflare`, `path: skills/security-audit`, `adapt: [rename]`, `keep: [VENDOR.md]`, `state: vendored` e o `pin` igual ao HEAD do submodule, gravados pelo `vendor-sync.sh vendor`, e não à mão.
- [ ] A cópia tem todos os arquivos de `skills/security-audit/` do upstream, iguais byte a byte ao pin, menos o `name:` do `SKILL.md`, que é `anvil-security-audit`.
- [ ] O `VENDOR.md` traz a URL do upstream, o caminho da pasta, a adaptação aplicada e o texto da licença MIT do upstream com o aviso de copyright.
- [ ] O `anvil.lock` lista a skill.
- [ ] `node --test` sobre os `*.test.cjs` da cópia em `anvil/.claude/skills/anvil-security-audit/` passa.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh status` mostra a skill sem nada andado desde o pin.
