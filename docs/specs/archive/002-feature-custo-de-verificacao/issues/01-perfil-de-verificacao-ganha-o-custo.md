# 01: O perfil de verificação diz quando rodar o gate

**What to build:** Um agente que lê o perfil de verificação sabe que o gate — a suíte inteira mais o typecheck — roda **uma vez por ticket**, nunca uma vez por spec, e sabe por quê: por spec, uma falha vira bissecção entre tickets já entrelaçados. Sabe que o gate roda em background e não bloqueia o próximo passo, e que há uma rodada da suíte inteira antes do merge, sobre o branch completo, para pegar a interação entre tickets. Sabe também que o laço curto é o passo seguinte, a adotar quando o laço passar de ~2 min, e não na instalação, e que a seleção do laço curto adia a descoberta, nunca dispensa o gate. Nenhum número de projeto aparece no perfil: o custo de cada projeto está no `anvil.md` dele.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved
**Review:** round=1; sha=2ffd1c7; scope=full; verdict=pass; p1=none

- [x] O template do perfil no `anvil-docs` tem a seção do custo, ao lado de classe, orçamento e persistência.
- [x] A seção diz: gate por ticket, com o argumento da bissecção; gate em background; rodada antes do merge; sinal de adoção do laço curto (~2 min); forma genérica do laço curto (o barato e transversal roda inteiro, só o caro se seleciona, numa invocação só); a seleção adia e não dispensa o gate.
- [x] Nenhum número medido de projeto aparece na seção.
- [x] `docs/agents/verification.md` do anvil é idêntico ao template.
- [x] O `verify` sai limpo.

## Comments

- Rebase · decisão: a User Story 9 da spec pedia o gate em background "enquanto
  sigo com commit e documentação". No rebase sobre a `main`, o perfil passou a
  dizer que o commit que fecha o ticket espera o verde, para não contradizer o
  `anvil-implementer`, que roda o comando de verificação antes de cada commit
  (`anvil-update/.omp-layer/agents/anvil-implementer.md:54`). A documentação
  segue em background; o commit, não.
- Review round=1 · P2: o implementer roda o comando, que é o gate, antes de cada
  commit, e um ticket tem dois a quatro commits (implementação, registro da
  revisão, correção) — sob o `anvil-auto`, o gate roda mais de uma vez por
  ticket, bloqueante, ao contrário do "uma vez por ticket" do perfil. Decidir
  entre restringir o implementer ao commit que fecha o ticket ou aceitar o custo.
- Review round=1 · P2: o perfil afirma que o custo "está medido e datado no
  `.claude/rules/anvil.md`", mas o `anvil-bench` instala o perfil e grava um
  `anvil.md` sem seção de verificação, e o `anvil.md` do próprio anvil não tem
  custo — nesses projetos o agente procura o número e não acha.
- Review round=1 · P3: a convenção "o bloco `bash` é o `gate`, o `laço` vai em
  prosa" e o limiar de ~2 min estão no perfil e no `anvil-boot` — mudar um sem o
  outro faz os dois divergirem.
- Review round=1 · P3: a descrição do perfil em `anvil-docs/SKILL.md` ainda diz
  só "critério de parada" — quem procura onde mora a cadência da suíte não acha
  pelo índice da skill.
- Review round=1 · P3: "Três rodadas bloqueantes por ticket" não diz de onde vêm
  as três — o leitor não sabe o que foi contado.
- Review round=1 · P3: as *Further Notes* da spec citam o ADR `0011` como
  candidato para a decisão do gate, mas o ADR-0011 — o omp como harness, com
  camada própria — já existe; o próximo livre é o `0020`. Quem segue o número
  cai noutra decisão.
