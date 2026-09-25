# ADR-0013 — As skills de segurança são autorais, destiladas das referências

- Status: aceito
- Data: 2026-09-24
- Exceção declarada ao [ADR-0001](./adr-0001-skills-vendorizadas-seguem-o-padrao-original.md)
- Revê em parte o [ADR-0006](./adr-0006-stack-como-camada-propria.md): o contrato de stack passa a sete capacidades

## Contexto

O anvil curadoriza em vez de escrever: skill de trabalho vem de upstream, com
pin e adaptação registrada. Autorais são as de infraestrutura — boot, docs,
bench, as `tea-*`.

Para `anvil-security-map` e `anvil-security-probe` a
[pesquisa](../../discovery/seguranca-map-probe.md) achou uma dúzia de
candidatos, e nenhum cobre o que é do anvil:

- salvar o mapa e o índice de achados em `docs/security/`;
- abrir spec de correção pelo perfil do tracker;
- puxar o checklist da skill de stack, pelo contrato do
  [ADR-0006](./adr-0006-stack-como-camada-propria.md);
- restringir o alvo ao ambiente de desenvolvimento.

Essa parte é a maior do trabalho. Vendorizar o mais próximo, o
`ghostsecurity/skills`, deixaria um delta maior que a cópia, e o acoplaria a três
binários da Ghost. Parte dos candidatos está sob CC-BY-SA-4.0, que obriga a
cópia adaptada a sair sob a mesma licença.

## Decisão

As duas skills são **autorais**. Das referências entra a ideia, não o texto:

| De | O que se aproveita |
|---|---|
| `ghostsecurity/skills` | entender o repositório antes de caçar (`repo-context`); reproduzir contra o app rodando antes de reportar (`validate`) |
| `claude-security-audit` | trava de escopo: nada vai para a rede sem alvo autorizado por escrito; validador que tenta refutar o achado |
| `trailofbits/skills` | `audit-context-building` e `fp-check` como método; `variant-analysis` para achar a causa raiz repetida |
| `claude-security` (Anthropic) | verificação independente por achado; saída legível por máquina ao lado do Markdown |
| OWASP Top 10:2025, API Top 10:2023, ASVS 5.0, WSTG | a estrutura e os ids do mapa |

Regras de destilação:

- **Texto de fonte CC-BY-SA não entra**, nem parafraseado de perto. MIT e
  Apache-2.0 podem entrar em trecho, com atribuição.
- Cada skill leva um `SOURCES.md` com o que veio de onde, no lugar do
  `VENDOR.md` das vendorizadas.
- Fica fora do `anvil-skills.yaml`: sem pin, sem sync. A atualização é manual,
  quando uma referência mudar de ideia.
- O conhecimento de cada stack fica na skill da stack, não na de segurança. A
  de segurança é agnóstica e lê o checklist que a stack oferecer.

## Desenho

**Entrada pelo boot, opcional.** O `/anvil-boot` já detecta a stack na
varredura. Ao detectar, **sugere** rodar o `/anvil-security-map`, com uma linha
de justificativa, e segue sem ele se o usuário recusar. Nada de segurança é
instalado sem pedido.

**O map é pré-requisito do probe.** O `/anvil-security-probe` confere
`docs/security/` antes de qualquer coisa. Sem o perfil e o mapa, ele para e
manda rodar o map; não improvisa um mapa próprio.

**Contrato de stack: a sétima capacidade.** A stack que quiser cobertura de
segurança traz `security/CHECKLIST.md`: o que olhar naquela tecnologia, com
precedente (advisory, doc oficial) em cada item. Só o map carrega. O boot não lê
o checklist — ele só detecta a stack e sugere o map —, então a capacidade não
conflita com a entrada pelo boot. No `anvil-stack-payload`, que é vendorizado, o
diretório entra como `keep` no manifesto, como o `RULE.md` e o `bench/`. Stack
sem checklist ainda é mapeada, só com a parte genérica, e o mapa diz isso.

**`docs/security/`**, três arquivos:

| Arquivo | Quem escreve | Conteúdo |
|---|---|---|
| `profile.md` | map | stack detectada, ferramentas disponíveis e ausentes, ambiente local (URL, banco) |
| `map.md` | map | superfície de ataque por categoria OWASP, cada item com arquivo:linha e o teste que o probe aplica |
| `findings.md` | probe | índice `SEC-#`: causa raiz, severidade, status (`aberto`/`corrigido`), link da spec |

**O probe é sempre local.** Nenhuma flag libera outro alvo:

- o alvo sai do ambiente local do próprio repositório — scripts de dev, `.env`,
  compose — e precisa resolver para loopback;
- antes de executar, o probe mostra URL, banco e ferramentas que vai usar, e
  **espera confirmação**;
- antes de qualquer teste que escreve, sugere um banco descartável; se o usuário
  preferir o banco local, o probe cria um dump e diz como restaurar.

**Achado vira spec.** Só achado reproduzido, com requisição, resposta e trecho de
código. Uma spec `fix` por causa raiz, não por rota, aberta pelo perfil do
tracker. Antes de abrir, o probe confere o `findings.md`: causa já registrada e
aberta ganha evidência nova, não spec nova.

**Ferramentas.** O probe usa o que estiver instalado, não instala nada, e
registra no `findings.md` o que ficou sem cobertura por falta de ferramenta.

**Advisories em tempo de execução.** O map consulta o OSV.dev pelas versões do
lockfile e os GitHub Security Advisories do repositório da stack. Só essas
fontes; busca aberta na web fica de fora, por ruído e por prompt injection. O
texto do advisory é dado não confiável. Sem rede, o map roda e diz que não
consultou. Advisory da stack sem item no checklist aparece no mapa como lacuna.

## Consequências

**A favor.** O desenho sai do fluxo do anvil (tracker, `docs/`, stack), e não o
contrário. Nenhuma dependência de binário de fornecedor.

**Contra.** Não há upstream que corrija a skill: ferramenta nova e mudança do
OWASP entram só quando alguém nota. É o custo que o ADR-0001 evita e que aqui
se aceita. Advisory novo é o caso atenuado: a consulta do map cobre a
dependência e aponta a lacuna no checklist, mas escrever o item continua manual.

**Pendente.** `.claude/rules/project.md` lista as skills autorais e
`STACK-CONTRACT.md` lista as seis capacidades; os dois mudam junto com a
implementação.
