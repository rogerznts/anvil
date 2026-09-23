# 04: Boot instala a camada

**What to build:** Num projeto novo aberto no omp, o `/skill:anvil-boot` instala a camada omp sem que o operador saiba que ela existe. O `reset-install.sh` ganha um modo que roda só a parte de camadas — camada omp e espelho do Codex —, como o `--unignore` já faz para o `.gitignore`, e o boot o chama num passo novo, depois de registrar o hook do Claude.

**Blocked by:** 03

**Status:** ready-for-agent

- [ ] O modo de camadas produz o mesmo `.omp/`, as mesmas linhas `omp:` e o mesmo `.agents/skills` que o update produziria.
- [ ] O boot chama esse modo e relata o que instalou e por qual sinal.
- [ ] O boot continua registrando o hook do Claude no `.claude/settings.json`, com ou sem camada omp.
- [ ] Projeto sem sinal de omp sai do boot sem `.omp/`.
- [ ] Cenário S1 compara o resultado do modo de camadas com o do update; o `verify` sai limpo.
