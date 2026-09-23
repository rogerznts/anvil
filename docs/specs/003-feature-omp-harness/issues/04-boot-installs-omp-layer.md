# 04: Boot instala a camada

**What to build:** Num projeto novo aberto no omp, o `/skill:anvil-boot` instala a camada omp sem que o operador saiba que ela existe. O `reset-install.sh` ganha um modo que roda só a parte de camadas — camada omp e espelho do Codex —, como o `--unignore` já faz para o `.gitignore`, e o boot o chama num passo novo, depois de registrar o hook do Claude.

**Blocked by:** 03

**Status:** resolved

- [x] O modo de camadas produz o mesmo `.omp/`, as mesmas linhas `omp:` e o mesmo `.agents/skills` que o update produziria.
- [x] O boot chama esse modo e relata o que instalou e por qual sinal.
- [x] O boot continua registrando o hook do Claude no `.claude/settings.json`, com ou sem camada omp.
- [x] Projeto sem sinal de omp sai do boot sem `.omp/`.
- [x] Cenário S1 compara o resultado do modo de camadas com o do update; o `verify` sai limpo.

## Comments

- A seção "Lock" da spec ganhou a regra da raiz do usuário em `.omp/`, com as linhas `omp:` preservadas, e a frase "Quem escreve `omp:`" passou a dizer que o script também as grava quando preserva. Fecha o achado médio da revisão do ticket 03.
- O modo é `reset-install.sh --layers --to <projeto> [--dry-run]` e roda da cópia instalada, como o `--unignore`. Ele não copia lógica: põe `FROM_ABS` no próprio projeto, troca o conjunto de skills do payload pelas linhas `skill:` do lock, e o resto do caminho é o do update — `fora_do_lugar`, `confere_raiz_omp`, `classifica`, relatório e execução do espelho e da camada. Pula a classificação e a execução de skill e agente, o `.gitignore` e o `BOOT PENDENTE`.
- As skills saem do lock, e não do disco, porque `.claude/skills` tem também as skills do usuário, e o espelho ganharia um symlink para cada uma.
- Do lock, só as linhas `omp:` mudam: `installed_at`, `skill:` e `agent:` são do último update. As linhas `omp:` saem da mesma função do update, `linhas_omp`, extraída do `conteudo_lock`.
- Sem lock, o modo sai com 2 e não toca em nada: não há linhas `skill:` de onde o espelho sai, nem como separar a camada do que é do usuário. Por isso o passo novo do boot é o 11, depois do passo 9, que confere o lock. O passo 8, do hook do Claude, fica sem mudança.
- O boot roda o modo sem perguntar e só para diante de colisão da camada omp, que seria substituída. A frase de abertura do boot, "Nada é escrito sem aprovação", ganhou essa exceção.
- O passo 9 do boot reescrevia o lock só com `skill:` e `agent:`. Num boot repetido com lock divergente, as linhas `omp:` sumiriam, e a camada perderia a regra pegajosa antes do passo 11. O comando agora as copia para o lock novo. Smoke em bash 3.2 e 5: lock CRLF com duas linhas `omp:`, lock sem elas e sem lock.
- No relatório do modo, a camada nova sai como "nova", sem o "neste update".
- Prova: o S1 (`workspace/29-codex-mirror/s1.sh`) passa com 86 checks em `/opt/local/bin/bash` e em `/bin/bash`, 13 deles novos, na seção 7i. Cada caso roda o update e o modo sobre cópias do mesmo projeto e compara `.omp/`, linhas `omp:` e `.agents/skills`: lock com camada numa máquina sem omp, com órfão, colisão e alheio em `.omp/` e com refeito, pendurado do degit, colisão e alheio no espelho; boot típico com omp no `PATH`; sem sinal nenhum; raiz do usuário com a linha `omp:` no lock; e sem lock, que recusa. O dry-run dos dois dá blocos idênticos de espelho e camada. Uma mutação que faz o modo tirar as skills do disco derruba 7 checks.
- Antes/depois com `workspace/28-reset-classify/capture.sh` (`depois-03`, `depois-04`): a saída do update não mudou em bash 5 nem em bash 3.2. A única diferença é o hash da cópia do script na árvore das fixtures.
