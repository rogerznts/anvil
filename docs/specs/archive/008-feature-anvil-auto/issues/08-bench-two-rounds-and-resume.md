# 08: Bench com teto de duas rodadas e retomada de construção começada fora dele

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=4adbb7a9f983a08e696ad1353012c0963366de06; scope=full; verdict=pass; p1=none

**What to build:** o bench passa a seguir o orçamento do ADR-0010 (a
verificação tem critério de parada, e a terceira rodada é escolha declarada de um
humano). O teto deixa de ser de três tentativas por ticket e passa a ser de duas
rodadas, também no bench manual. Um ticket travado vira `CONCERNS` e entra como
pendência na entrega. Na fase 2, uma construção começada fora do bench, sem
checklist nem `gates.md`, é retomada refazendo só a fase 4 a partir da spec e
dos tickets existentes. Sem spec, a fase 3 vira entrevista do delta. A entrega
diz em que ponto a retomada entrou.

- [x] O `GATE.md` troca "o teto de três" pelas duas rodadas do ADR-0010, e o
      veredito `CONCERNS` cobre o ticket travado em `round=2`.
- [x] O diagrama e a prosa da fase 5 do `SKILL.md` do bench dizem duas rodadas,
      e nenhum "3 tentativas" sobra no bench.
- [x] A fase 2 ganha o ramo de retomada: com spec e tickets, mas sem checklist
      nem `gates.md`, refaz só a fase 4; sem spec, faz a fase 3 como delta.
- [x] A entrega registra o ponto em que a retomada entrou.
- [x] O material de `unlazy/` não muda, e o `SKILL.md` e o `GATE.md` continuam
      protegidos por `keep` no manifesto.
- [x] `vendor-sync.sh verify` sai `0`.

## Comments

- Implementação · além do `SKILL.md` e do `GATE.md`, mudaram duas frases que a
  troca do teto deixaria mentindo: o `loop-until-green` de
  `anvil-stack-payload/bench/INVARIANTS.md`, que o bench carrega antes de começar
  e é do anvil (`keep: [..., bench]`), e o comentário do Stop hook no
  `anvil-skills.yaml`. Sem isso, o bench leria dois tetos rivais.
- Implementação · conflito na spec para o operador decidir: o
  `anvil-bench/unlazy/VENDOR.md` é nota do anvil (`keep`), mas mora em `unlazy/`,
  que o critério 5 manda não mudar. Ele continua dizendo "teto de três tentativas
  por ticket, em ../GATE.md" como razão para o Stop hook não entrar — o motivo
  (duas condições de parada rivais) segue valendo, só o número ficou velho.
- Implementação · `docs/project/plan.md` (fase 5) e o ADR-0003 ainda citam o
  teto de três; ficaram como estão, por serem histórico do plano e decisão
  registrada.
- Review round=1 · P2 (Standards): `anvil-bench/unlazy/VENDOR.md:32` ainda diz
  "teto de três tentativas por ticket, em ../GATE.md", e o `GATE.md:71` aponta
  para ele; o arquivo é do anvil (`keep` no manifesto, `ADAPT-RULES.md`), então
  nenhum padrão impedia a correção — um agente que siga o link lê um teto rival
  das duas rodadas.
- Review round=1 · P2 (Spec): o critério 2 ("nenhum '3 tentativas' sobra no
  bench") está marcado, mas o `unlazy/VENDOR.md:32` ainda tem o teto de três; a
  spec (l.304-306) define o material de `unlazy/` como o formato do `gates.md` e
  os scripts do gate, e o `VENDOR.md` está no `keep`, então o critério 5 não
  proibia a correção e o conflito registrado acima não existe — a nota contradiz
  o `GATE.md`, ainda que aponte para ele.
- Review round=1 · P3 (Standards): este `## Comments` cita o ADR-0003 sem a
  glosa (sem máquina de fases: o artefato é o estado) — quem lê precisa abrir o
  ADR para saber por que ele não se toca.
- Review round=1 · P3 (Standards): possível Duplicated Code / Shotgun Surgery —
  o `SKILL.md:139-147` repete a regra do teto que o `GATE.md:108-134` já
  define, e as cópias divergem (o gate derrubado depois da rodada 2, que dá
  `FAIL` e para, só está no `GATE.md`); a próxima mudança no teto obriga a
  editar três ou quatro arquivos, e uma cópia esquecida volta a criar teto rival.
- Review round=1 · P3 (Spec): o ramo "com spec aberta" do `SKILL.md:55-61` não
  diz o que fazer quando a spec ainda não tem tickets — quem conduz descobre na
  primeira volta que precisa rodar o `anvil-to-tickets`.
- Review round=1 · P3 (Spec): os ramos do `SKILL.md:53-65` não cobrem o projeto
  com só um dos dois arquivos, o `checklist.yaml` ou o `gates.md` — o caso fica
  sem ramo declarado, e o leitor deduz que deve refazer a fase 4.
