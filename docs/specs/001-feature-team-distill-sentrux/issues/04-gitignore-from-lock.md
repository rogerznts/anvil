# 04: O gitignore sai do lock

**What to build:** Num projeto descartável, o update e o boot escrevem no gitignore um bloco `ANVIL:INSTALLED` com uma linha por skill que o anvil instalou — as `tea-*` incluídas — e nada além disso. Uma skill que o usuário escreveu continua versionada. Num projeto bootado antes, a linha que ignorava `.claude/skills/` inteiro é trocada pelo bloco, com aprovação.

**Blocked by:** Nenhum — pode começar agora.

**Status:** ready-for-agent

- [ ] Uma função única gera o bloco a partir do lock, e o update a chama depois de gravar o lock.
- [ ] O modo `--gitignore-only` reescreve só o bloco a partir do lock existente, e é o que o boot usa.
- [ ] Rodar duas vezes não muda nada, e uma skill órfã removida sai do bloco.
- [ ] O boot troca a linha antiga só quando acha o comentário exato que ele mesmo escreveu, mostrando o antes e o depois e esperando aprovação.
- [ ] Uma linha parecida sem esse comentário fica intocada.
- [ ] Pontos A e B: `reset-install --dry-run` e boot num projeto descartável com skill do usuário, `tea-*`, e a linha antiga com e sem o comentário.

## Comments

**Leader, 2026-09-12 — entrega do Dev em `5dd8a52`, decisões sobre os desvios:**

1. O update só regenera um bloco que já existe; quem cria é o boot. Aceito: preserva o
   opt-out documentado ("projeto que prefira versionar tudo é respeitado"). O critério
   "o update e o boot escrevem" fica atendido com o boot criando e o update mantendo.
2. A detecção da linha antiga reconhece as duas versões exatas do comentário que o
   boot escreveu ao longo do histórico (com e sem `--force`). O comentário do README
   continua não reconhecido.
3. O passo 10 do boot entra neste ticket: sem a correção, o bloco faria o próximo
   update apagar a skill do usuário como órfã.

Gates pendentes: Review (Standards e Spec) e Tester (pontos A e B).

**Leader, 2026-09-12 — gate Review: APROVADO, sem bloqueante.** O ticket não fecha ainda.
Voltam ao Dev, junto com o resultado do Tester, para corrigir neste ticket:

- **S1** — o passo 9 do boot não é idempotente quando a troca da linha antiga é recusada:
  o segundo boot cria um segundo par de marcadores e o script para com rc=2. Correção: com
  bloco existente, a troca só apaga as duas linhas; a aprovação da troca vale para o bloco.
- **S2** — o passo 10 manda reescrever o lock a partir do disco em qualquer divergência, e
  skill do usuário no disco sempre diverge: ela entraria no lock, passaria a ser ignorada e
  seria apagada como órfã no update seguinte. Correção: divergência é lock ausente ou skill
  do lock fora do disco; exclusão das skills do usuário antes do comando; lock conferido
  antes do bloco, o que também desfaz a ida e volta entre os passos 9 e 10 (P4).
- **Risco (a)** — `--from` com `--gitignore-only` sai com erro (rc=2), como as outras guardas.
- **P2** — o aviso "rode a cópia recém-baixada" vale só para o modo reset.
- **S3** — sem bloco, o update sugere rodar o `/anvil-boot`.

Ficam fora, com motivo: **P1** (identificadores em português — o arquivo inteiro já é assim, e
migrar é mudança à parte), **P3**, **P5** e **P6** (smells sem efeito no comportamento).

Correção da justificativa do desvio 3, pelo Review: quem apaga a skill do usuário é o lock que
a inclui, e isso já existia; o que o bloco acrescenta é passar a ignorá-la, quebrando a user
story 1. É esse o motivo de o passo 10 estar neste ticket.

**Leader, 2026-09-12 — gate Tester: REPROVADO pelo caso adversarial 3.** Os 6 critérios passam,
e o ponto B boot-com foi reproduzido de forma independente. A falha:

- `.gitignore` com CRLF (checkout com `core.autocrlf=true`) ou marcador com espaço no fim: o
  update diz "sem bloco, fica intocado" e o bloco apodrece; o `--gitignore-only` acrescenta
  um segundo bloco. Lock com CRLF gera caminho com `\r`, que o git não ignora.
- Causa: `tem_bloco`, a guarda de marcadores e o awk comparam a linha exata.
- Repro: `workspace/09-gitignore-tester/repro-crlf.sh`.

**Decisão:** entra nas correções deste ticket, junto com S1, S2, (a), P2 e S3. Critério
acrescentado: marcadores reconhecidos com CR e espaço no fim; lock lido sem `\r`; o arquivo
preserva o fim de linha que já tinha.

**Reteste:** `run.sh` do Dev, `adv.sh` e `repro-crlf.sh` do Tester, e o Review conferindo S1 e
S2 no diff novo.

**Leader, 2026-09-13 — correções entregues em `837b7ca` (script) e `7135c05` (boot).**

Nota de numeração: os passos do boot trocaram de ordem nas correções — agora o **9 é o lock** e o
**10 é o gitignore**. Nos comentários acima, escritos antes, "passo 9" é o gitignore (S1) e "passo 10"
é o lock (S2).

Desvios aceitos: (1) marcador `END ` com espaço fecha o par, como decidido para CR e espaço no fim;
(2) o lock é lido sem `\r` também no cálculo do que o anvil possui; (3) com skill faltando no disco o
lock é reescrito do disco com a exclusão das skills do usuário, e a sugestão de `/anvil-boot` fica só
no `SKILL.md` do update, com a ressalva do opt-out.

Entram neste ticket, antes dos gates: **R1** a busca da linha antiga no boot casa em `.gitignore`
com CRLF; **R2** um projeto bootado com o passo antigo pode já ter skill do usuário dentro do lock —
antes de gravar o bloco, o boot confirma com o usuário se alguma skill listada é dele.
Ficam como estão: **R3** fim de linha pela primeira linha em arquivo misto; **R4** intervalo fixo do
`--help`, que já existia.

**Leader, 2026-09-13 — R1 e R2 em `496b155`; reteste do Tester, ponto A: APROVADO.** Suítes `run.sh`,
`adv.sh` (com aval do c3f e o novo c3g) e `adv2.sh` sem falha; `adv2.sh` contra o script de
`5dd8a52` dá 34 falhas, então a suíte distingue as versões. Desvio aceito em R1: o START entra na
mesma busca que ignora `\r`, para a pergunta "o bloco já existe?" também valer em CRLF.
Observações do Tester sem bloqueio: lock com espaço depois do nome (só editado à mão), `--from ""`
aceito, `--from` sem valor sem mensagem (anterior ao ticket).

Pendentes para fechar: reteste do Review sobre `5dd8a52..496b155` e ponto B do boot isolado (R1, R2, S1).

**Leader, 2026-09-13 — reteste do Review sobre `5dd8a52..496b155`: APROVADO.** S1, S2, (a), P2, S3, R1,
R2 e o critério de CRLF resolvidos; os desvios aceitos se sustentam.

**Última rodada deste ticket**, só texto dos `SKILL.md` do boot e do update, sem mudar o script:

- **N1** — com skill do lock faltando no disco, o passo 9 só aponta como candidatas as skills fora do
  lock, e o passo 10 não repete a pergunta: a skill do usuário que já estava no lock volta para ele.
  A pergunta tem de cobrir também as skills que o lock lista.
- **N2** — a busca do boot normaliza o fim de linha como o script (espaço, tab e `\r`).
- **N3** — a troca da linha antiga pelos marcadores mantém o fim de linha do arquivo.
- **N4** — a pergunta é "quais skills não vieram do anvil", não "quais o usuário escreveu".
- **N5** — `MINHAS` vira `USER_SKILLS`: identificador em texto de skill segue a regra do inglês.
- **Receita do update para instalação sem lock** (`ls .claude/skills` para `/tmp`) põe a skill do
  usuário no lock, a mesma falha do S2: passa a excluí-las.

Fica fora: **N6** (ramos sem saída e linha em branco sobrando — cosmético ou anterior ao ticket).
Depois desta rodada, achado não bloqueante vira ideia registrada, não reabertura.
