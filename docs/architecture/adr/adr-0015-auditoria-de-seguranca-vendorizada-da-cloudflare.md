# ADR-0015 — A auditoria de segurança é a skill da Cloudflare, vendorizada

- Status: aceito
- Data: 2026-10-26

## Contexto

O anvil precisa de uma auditoria de segurança dos projetos em que é instalado. A
Cloudflare publica, sob MIT, a `security-audit`: uma auditoria por código-fonte em
seis fases, com coverage ledger, validação adversarial por agente novo,
`findings.json` validado por schema e relatório. Ela grava os artefatos fora do
repositório auditado, de propósito.

## Decisão

**A auditoria de segurança do anvil é a `security-audit` da Cloudflare,
vendorizada como `anvil-security-audit`.**

- **Vendorizada, e não destilada.** Ela entra como upstream em `references/`, com
  pin e sync 3-way, pelo catálogo fechado do `ADAPT-RULES.md`. O conteúdo é o do
  upstream, e as atualizações da Cloudflare chegam pelo `vendor-sync update`.
- **A saída segue o upstream.** A auditoria grava fora do repositório auditado, em
  `~/security-audit-skill/<repo>/run-<N>`, ou dentro dele só num diretório que o
  git ignora. O `docs-remap` não alcança esse caminho, e o anvil não o altera.
- **No roster do `dev-link`.** O modo guidance, que é o padrão, não escreve arquivo
  nem dispara as seis fases sem um pedido explícito. Por isso a skill fica ligada e
  invocável pelo modelo.
- **O versionado é só o registro.** Uma peça autoral, o verbo `security` do
  `anvil-docs`, deriva de uma execução o registro da auditoria em `docs/security/`,
  indexado. Ele diz o que foi coberto e quantos achados houve, sem caminho nem
  reprodução de nenhum. O detalhe fica no diretório da execução, fora do git: um
  `confirmed` versionado é uma vulnerabilidade divulgada antes da correção.

## Opções consideradas

- **Destilar com o `anvil-distill`**, como skill autoral que grava em
  `docs/security/` e abre spec. Rejeitada porque o anvil perderia as atualizações
  do upstream e passaria a manter sozinho cerca de vinte arquivos de método.
- **Teste dinâmico contra o servidor de desenvolvimento.** Rejeitado como porta da
  auditoria. O upstream só executa código do alvo dentro de um sandbox imposto
  pelo sistema operacional e, sem ele, mantém o achado como `needs_validation`. O
  anvil aceita esse limite em vez de manter um segundo método.

## Consequências

- Nenhum achado vira spec de correção sozinho: quem decide abrir é o operador,
  pelo `/anvil-to-spec`.
