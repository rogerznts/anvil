# 06: Spec que não fecha sozinha fica aberta, e a corrente segue pelo que não depende dela

**Blocked by:** 05

**Status:** ready-for-agent

**What to build:** o piloto trata as paradas que não são técnicas. Uma spec sem
`PASS`, com ticket travado ou com conflito de merge fora do `docs/index.md` fica
aberta no branch dela. O piloto volta à `main`, e a corrente segue pelas entradas
que não dependem dela. Num projeto que fecha por PR, o piloto arquiva, abre o PR
pelo `tea-open-pr` e para sem merge. Uma contradição com o roteiro segue a régua
da spec: se o critério ainda é cumprível, o piloto adapta e registra "decidido
sem humano"; se não é, para a entrada. A parada antes de a spec nascer usa o
`--skip` do `roadmap.sh` na mesma execução. Chamado no branch de uma spec aberta,
o piloto retoma a spec pelo `stage.sh` e pelo `frontier.sh` e depois segue a
corrente a partir da `main`. O relatório diz onde a corrente parou, por quê, e o
que ainda espera decisão, com cada item escrito como pergunta.

A pesquisa antes de travar fica com o ticket 07. Aqui a parada técnica vai direto
para o relatório.

- [ ] Uma spec sem `PASS` fica aberta no branch, o piloto volta à `main`, e a
      próxima entrada independente nasce de um branch novo saído da `main`.
- [ ] Uma entrada que depende, direta ou indiretamente, da spec parada não
      começa, e a corrente termina quando o `next` vira `none`.
- [ ] Num projeto que fecha por PR (pela regra do perfil do tracker mais as
      rules), o piloto faz archive, abre o PR e não faz merge. A entrada fica
      `stopped` até o merge, e as dependentes esperam.
- [ ] Um projeto sem remoto fecha por merge local, mesmo que o perfil fale de PR.
- [ ] Um conflito de merge fora do `docs/index.md` aborta o merge e deixa a spec
      parada, sem resolução automática.
- [ ] Antes de criar a spec, o piloto confere a entrada contra o código. Com
      critério incumprível, a entrada vai para o `--skip` desta execução, sem
      `Spec:` e sem branch, e a contradição vai para "o que ainda espera decisão".
- [ ] O piloto nunca edita `Entra:`, `Fica de fora:` nem `Pronto quando:`.
- [ ] Uma contradição achada depois que a spec nasceu, com critério ainda
      cumprível, é adaptada dentro da spec e registrada como "decidido sem
      humano". Com critério incumprível, a spec fica parada.
- [ ] Chamado no branch de uma spec aberta, o piloto retoma do ponto indicado
      pelo disco e depois segue a corrente.
- [ ] O `report.md` é commitado na `main` também quando a spec fica parada ou com
      PR aberto, e quando o piloto para antes de uma spec. Ele diz onde a
      corrente parou e termina em "o que ainda espera decisão", com perguntas.
- [ ] S2: fixture com ticket travado já gravado e comando de verificação saindo
      `1`, em que a dependente não começa e a independente segue; caso de PR sem
      merge; caso de retomada.
