# 05: O payload instala, substitui e remove agentes

**What to build:** Com um payload que traz agentes, o update instala, substitui e remove agentes como já faz com skills, e deixa em paz o agente que o usuário escreveu. O lock registra os agentes, o bloco do gitignore os lista, o `verify` pega lock incompleto e agente citando caminho inexistente, e este repositório passa a ligar os agentes do payload.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] O lock ganha linhas `agent:`, e um leitor antigo as ignora sem quebrar.
- [ ] A geração do lock no `vendor-sync` emite os agentes do payload.
- [ ] O `reset-install` classifica agentes em substituídos, órfãos, alheios e preservados, e o dry-run mostra a classificação.
- [ ] O bloco `ANVIL:INSTALLED` lista os agentes instalados.
- [ ] O `verify` reprova um lock sem um agente do payload, e um agente que cita caminho inexistente.
- [ ] O `dev-link` liga os agentes do payload neste repositório.
- [ ] A migração do mosk no boot remove só as personas do mosk, não o diretório de agentes.
- [ ] Contrato de citação com a equipe (desenho, seção 3): num agente, caminho do payload se cita só em crase, relativo à raiz de instalação (`.claude/...`).
- [ ] O `verify` reprova: `name:` do agente diferente do nome do arquivo; span em crase começando com `.claude/` (sem `*`, `{` ou `<`, fora de bloco cercado) que não existe no payload; link markdown relativo num arquivo de agente.
- [ ] Achados do Review no ticket 04 que ficam aqui, porque este ticket mexe no lock e no bloco nos mesmos passos do boot:
- [ ] N1 — com skill do lock faltando no disco, a pergunta do passo do lock cobre também as skills (e agora os agentes) que o lock lista: nada do usuário volta ao lock sem ter sido perguntado.
- [ ] N2 — a busca da linha antiga e do START no passo do gitignore normaliza o fim de linha como o script (espaço, tab e `\r`).
- [ ] N3 — a troca da linha antiga pelos marcadores mantém o fim de linha do arquivo.
- [ ] N4 — a pergunta é "quais não vieram do anvil", não "quais o usuário escreveu".
- [ ] N5 — o identificador `MINHAS` nos `SKILL.md` vira `USER_SKILLS`.
- [ ] A receita do `anvil-update` para instalação sem lock deixa de pôr no lock o que não veio do anvil e não grava em `/tmp` como se fosse o lock.
- [ ] Ponto A: payload de teste com um agente, e projeto descartável com um agente do usuário.

## Comments

**Leader, 2026-09-13 — contrato com a equipe.** Os checks do `verify` deste ticket seguem a seção 3 de
o desenho em `architecture/team-shape.md` (`384fc45`), para o 06 não precisar reabrir o 05.

**Leader, 2026-09-13 — escopo acrescentado.** N1–N5 e a receita do update vêm do reteste do Review no
ticket 04 (detalhe nos comentários de lá). Cobrir no cenário: lock antigo com skill do usuário e skill
do lock faltando no disco; START com espaço no fim; troca em CRLF mantendo CRLF.

**Leader, 2026-09-13 — entrega do Dev** em `bb1f92f..2ebd015` (7 commits): lock com `agent:`, segundo laço no
`reset-install`, bloco com os agentes, `verify` com as checagens do contrato (a, b, c), `dev-link` ligando
agentes, migração do mosk removendo só `mosk-*.md`, N1–N5 e a receita do update. Cenário
`workspace/12-payload-agents/run.sh` limpo em bash 5 e 3.2 (64 falhas antes); suítes do 04 limpas.

Decisões: link de âncora (`](#…)`) continua reprovando no check (c) — isentar só quando houver agente
que precise (ideia registrada); "preservados sempre" continua sendo o grupo fixo; (c) vale no arquivo
inteiro; a adaptação da suíte do 04 ao `USER_SKILLS` é aceita. Gates despachados: Review e Tester
(ponto A e ponto B da migração do mosk, isolado).

**Leader, 2026-09-13 — gate Review: APROVADO, sem bloqueante.** Critérios 1–17 atendidos, com fixtures de
agente (o payload ainda não tem agentes). Entram num ajuste antes de fechar:

- **F1** — a troca da linha antiga no passo 10 do boot grava o `.gitignore` mesmo se o `awk` falhar (duas
  linhas independentes): encadear com `&&`, como o script já faz.
- **F2** — o `SKILL.md` do update manda commitar o lock e, adiante, diz "nunca commite sozinho": pedir ao
  usuário que commite.
- **F3** — agente órfão que é symlink pendurado some do relatório e fica no disco: os testes de existência
  de agente aceitam symlink.
- **F7** — agente do usuário com o nome de um agente do payload, fora do lock, é sobrescrito sem aviso
  explícito (user story 13): o relatório destaca substituído que não estava no lock como possível colisão.

Ficam como ideia: **F4** falsos negativos raros do check (b) (linha com crases inline tratada como cerca,
span em duas linhas); **F5** duplicação do formato do lock entre boot, update e scripts; **F6** alinhar
skills em `grep -qxF`; **F8** symlink velho no `dev-link`; **F9** detalhes do awk e do temporário;
**F10** `name:` com comentário. Aguardando o gate do Tester.

**Leader, 2026-09-13 — gate Tester: APROVADO.** Ponto A: órfão, lock antigo nos dois leitores, lock
CRLF, payload sem `.claude/agents/`, symlinks, `verify` com uma violação por vez e casos que não podem
reprovar, `dev-link` num clone. Ponto B isolado: migração com as 12 personas reais do mosk remove só
elas, o core, as skills `mosk-*` e o hook; o agente do anvil e o do usuário ficam sem diff.

**Ajuste único antes de fechar** (Review + Tester): F1, F2, F3, F7 (= R1 do Tester) e, do Tester, link
markdown por referência (`[p]: PROTOCOL.md`) passa a reprovar no check (c).

Ficam como ideia, além das do Review: `<a href>` relativo, `.claude/../` que resolve fora, cerca
indentada 5 espaços e bloco de 4 espaços conferidos, span com `$VAR` ou `:linha`, `mailto:` tratado
como relativo, agente do usuário chamado `mosk-*` apagado pela migração (o boot mostra o plano antes).

**Leader, 2026-09-13 — F7/R1, pergunta do Dev:** a colisão é destacada no dry-run e nomeada no passo que
avisa e espera, e a sobrescrita continua depois da aprovação. O contrato do update já é dry-run, aviso
nomeando e espera; pular a colisão deixaria o agente do payload sem instalar, em silêncio. As duas
checagens do R1 no `adv.sh` do Tester passam a conferir o destaque — quem ajusta é o Tester, no reteste,
porque a suíte é do gate.

**Leader, 2026-09-13 — ajuste entregue** em `5ba3220` (F1), `c92c122` (F2), `be68ac3` (F3), `5439732` (F7:
destaque "substituídos fora do lock, possível colisão" no dry-run e nomeado no passo 4) e `07d0cfb` (check c
com link por referência). Cenário do 05 com 117 checagens limpo em bash 5 e 3.2; suítes do 04 limpas.
Pedido antes dos gates: o "Contrato" do topo do `SKILL.md` do update ressalva o homônimo fora do lock.
Reteste: Review sobre o ajuste; Tester ajusta as duas checagens do R1 no `adv.sh` para conferir o destaque
e atualiza o clone (o dele está no `vendor-sync` antigo).

**Leader, 2026-09-13 — reteste do Review sobre `2ebd015..cb956b9`: APROVADO.** F1, F2, F3, F7, check (c) e o
contrato resolvidos; o risco do lock escrito pelo leitor antigo (agentes do anvil destacados como colisão)
se sustenta como aviso raro e do lado seguro.

Ficam como ideia, sem nova rodada: **N1** o contrato promete o destaque sem dizer que ele exige lock; **N2**
orientar o aviso de colisão (comparar com a cópia do `$TMP`; se o arquivo for do usuário, parar e renomear);
**N3** o check (c) reprova prosa como `[nota]: veja isto`; **N4** referência indentada 4 espaços passa;
Standards: `{ [ -f ] || [ -L ]; }` repetido três vezes, identificador `alvos` num heredoc Python, "e"/"é"
num comentário. Falta o reteste do Tester (ajuste das duas checagens do R1 para o destaque).
