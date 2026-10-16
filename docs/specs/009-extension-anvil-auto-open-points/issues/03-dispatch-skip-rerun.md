# 03: O piloto não despacha de novo o ticket que pulou

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**What to build:** quando um implementer termina sem mudar o estado do ticket, o
piloto o anota como pulado e roda o `frontier.sh` mais uma vez, já com o
`--skip`, antes de voltar ao começo do despacho, como o passo 5 da `anvil-run`
faz. O `next` que ele segue nunca aponta um ticket já pulado.

- [ ] No "Despacho" do `anvil-auto`, com pulado novo, o piloto roda o
      `frontier.sh` de novo com o `--skip` de todos os pulados e volta ao passo 1
      com essa saída.
- [ ] Um ticket pulado não é despachado de novo na mesma execução.
- [ ] O `frontier.sh` e a `anvil-run` não mudam.
- [ ] Prova S2 (prior art `workspace/47-auto-chain/`), num diretório novo de
      `workspace/`: um ticket que o implementer termina sem mudar o estado é
      despachado uma vez só, e o `frontier.sh` roda com o `--skip` antes do
      despacho seguinte, visto no jsonl. O S2 registra o modelo que de fato
      respondeu.
- [ ] `vendor-sync.sh verify` sai `0`.
