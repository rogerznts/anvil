# ADR-0019 — A auditoria de segurança é a skill da Cloudflare, vendorizada

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
  reprodução de nenhum. O detalhe fica no diretório da execução, fora do git, pelos
  motivos da seção seguinte.

## Por que o detalhe nunca entra no repositório auditado

Os artefatos de uma execução — `findings.json`, `REPORT.md`,
`FINDINGS-DETAIL.md`, `NEEDS-VALIDATION.md`, `architecture.md`, o coverage
ledger e o diretório `agents/` — nunca são gerados nem versionados dentro do
projeto auditado. Cada motivo abaixo basta sozinho.

- **Um achado confirmado é um exploit pronto.** O registro `confirmed` traz o
  arquivo e a linha, o caminho do dado até a falha, a entrada que a dispara e o
  resultado observado num teste local. Versioná-lo antes da correção é divulgar a
  vulnerabilidade a quem lê o repositório, sem embargo, no momento em que ela é
  mais explorável.
- **O git não esquece.** Apagar o arquivo depois não o tira do histórico, dos
  clones, dos forks, dos espelhos, dos caches de CI nem do diff de um PR já
  revisado. Divulgação por commit é irreversível; tirar do histórico exige
  reescrevê-lo e ainda não alcança as cópias que já saíram.
- **Ler o código não é o mesmo que ler as falhas dele.** Quem tem acesso de
  leitura ao repositório — colaborador externo, integração de CI, bot de
  dependências, ferramenta de IA que indexa o código — não precisa do mapa de onde
  atacar. O diretório da execução fica só na máquina de quem rodou a auditoria.
- **O que não foi confirmado também orienta um ataque.** `needs_validation` é uma
  hipótese de fronteira com o fato que falta, `rejected` diz que vetor já foi
  tentado, e o ledger com as lacunas mostra o que ninguém olhou. Juntos, são um
  plano de reconhecimento.
- **O próprio identificador fala.** O fingerprint é derivado da fonte, e na
  prática descreve a falha: um fingerprint na forma
  `billing.refund.amount-not-bound-to-original-charge` — exemplo inventado, na
  forma dos que a primeira execução real produziu — já diz, sozinho, onde olhar.
  Por isso o registro oculta o fingerprint que não é uma ficha opaca, e por isso
  este ADR não cita nenhum de verdade.
- **A auditoria não pode alterar o que audita.** Ela revisa um `source_ref` — um
  commit e se a árvore estava suja. Escrever dentro do alvo suja a árvore, muda o
  que a próxima execução lê como fonte e mistura artefato do auditor com código do
  projeto. As execuções seguintes leem as anteriores no diretório de saída para
  cobrir as lacunas, e isso não depende do repositório.
- **O detalhe envelhece e o código não avisa.** Cada achado vale para o commit
  auditado. Versionado ao lado do código, ele parece atual depois que o código
  mudou, e a correção feita não apaga o achado que ficou no histórico.

O que pode ir para o repositório é o que não ajuda ninguém a atacar: que a
auditoria aconteceu, sobre que commit, com que perfil, quanto foi coberto e
quantos achados houve, por veredito e severidade — o registro da auditoria.
Publicar o detalhe de um achado já corrigido, como um advisory, é decisão de
quem responde pela segurança do projeto, tomada caso a caso, e não um efeito de
rodar a skill.

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
