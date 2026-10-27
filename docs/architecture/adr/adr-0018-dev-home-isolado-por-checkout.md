# ADR-0018 — O modo dev usa um HOME privado por checkout

- Status: aceito
- Data: 2026-10-26
- Revê em parte o [ADR-0013 — instalação por usuário](./adr-0013-toolkit-instalado-por-usuario.md): muda somente a ligação de desenvolvimento, não a instalação publicada.
- Revê em parte o [ADR-0017 — provas pelo caminho real](./adr-0017-prova-pelo-caminho-real-com-resultado-invalido.md): dependências executáveis deixam de exigir links no HOME real.

## Problema

A ligação dev no diretório do usuário fazia todo projeto executar a fonte em
edição e impedia o update publicado. A recusa do reset estava correta: copiar
através de um symlink sobrescreveria a fonte. Um overlay apenas de descoberta
carrega o `SKILL.md` dev, mas não redireciona os scripts chamados por
`~/.claude/skills` e `~/.omp/agent`, misturando versões.

## Uso

Na raiz do checkout:

```bash
bash .claude/skills/anvil-sync/scripts/dev-link.sh --dry-run
bash .claude/skills/anvil-sync/scripts/dev-run.sh -- omp
bash .claude/skills/anvil-sync/scripts/dev-run.sh -- claude
bash .claude/skills/anvil-sync/scripts/dev-run.sh -- codex
```

O launcher também aceita comandos comuns, para configuração e provas. Tilde que
deverá resolver no HOME dev precisa ser expandido pelo filho, não pelo shell
chamador:

```bash
bash .claude/skills/anvil-sync/scripts/dev-run.sh -- bash -c \
  'bash ~/.claude/skills/anvil-docs/scripts/validate.sh docs-paths'
```

## Forma

O `dev-link.sh` administra os links em `workspace/anvil-dev/home/`, fora do git.
O `dev-run.sh` prepara o payload inteiro ali, resolve o executável antes da troca
de ambiente e o executa com HOME e diretórios de configuração privados. Ambos
mantêm uma interface de CLI: preparar links ou lançar um comando. O chamador não
coordena descoberta de skills, espelho, camada omp e resolução de scripts.

O PATH e as credenciais já exportadas são herdados, sem impressão ou cópia para
disco pelo launcher. Configuração e login dos harnesses não são importados. Os
processos filhos herdam a mesma seleção; as provas usam essa entrada antes do
condutor RPC. Com infra, o helper fixa `ANVIL_PROJECTS_DIR` para pai e filho
usarem o mesmo registro e teardown, independentemente do HOME.

A preparação não altera o HOME real. Colisões privadas com arquivos reais ou
links alheios e ancestrais symlink são recusadas antes da escrita. O dry-run não
materializa diretórios. A fonte continua por symlink, não cópia transformada.
`dev-link.sh --unlink` é apenas a migração explícita dos antigos links globais;
abrir dev nunca a executa nem instala a versão publicada.

## Síntese e alternativas

Foram comparados dois desenhos: seleção nativa por cliente com HOME real e HOME
privado explícito. A revisão independente preferiu o segundo, simplificado para
um único HOME persistente por checkout. A ferramenta de despacho não permitia
selecionar modelos; não houve diversidade de modelos demonstrada.

- **Overlay nativo:** mantém preferências e login pessoais, mas não resolve os
  scripts `~/`. No Claude, fontes pessoais homônimas prevalecem e plugins mudam
  os nomes. Exigiria adaptadores por cliente e migração transversal de paths.
- **HOME privado com importação automática:** acrescenta política de cópia de
  credenciais, preferências e terceiros que não faz parte do pedido. Rejeitado.
- **HOME por sessão, com catálogo e locks:** separa atores, mas dificulta login e
  retomada. Um HOME por checkout basta; a concorrência de sessões é a do harness.

## Custos e limites aceitos

- Login e configuração dev são próprios. Git, Docker e outras ferramentas que
  consultam HOME também precisam de configuração dev ou variáveis explícitas.
- Terceiros pessoais permanecem intactos, mas não são importados automaticamente.
- Não é sandbox: caminhos absolutos, sockets, políticas gerenciadas e serviços do
  SO continuam acessíveis. No Claude, login Console sem API key pode desconectar
  a conta claude.ai pessoal; esse fluxo não é apresentado como isolado.
- O Codex é aberto sem daemon compartilhado e com armazenamento de credenciais
  em arquivo privado. Overrides explícitos que restauram o ambiente pessoal não
  pertencem ao contrato do launcher.
- A proteção do reset permanece: dentro de dev, recusa antes de escrever; fora
  dele, a instalação publicada pode ser atualizada. Uma máquina com os links
  globais antigos precisa removê-los explicitamente e instalar o publicado após
  revisar seu dry-run. Preparar dev sozinho não faz esse cutover.
