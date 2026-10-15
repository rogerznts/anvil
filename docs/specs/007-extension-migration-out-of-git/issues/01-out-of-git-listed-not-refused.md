# 01: O que está fora do git sai listado, não recusado

**What to build:** Num projeto instalado do jeito antigo, com o toolkit ignorado pelo git, o `/anvil-update` e o `/anvil-boot` migram na mesma execução, venha de onde vier a regra de ignore: do `.gitignore`, de `.git/info/exclude`, do excludes global ou de uma linha escrita pelo usuário. A migração divide o que sai em duas partes. A primeira é o que o git conhece, que aparece no `git status` depois da execução. A segunda é o que está fora do git: o item sem nada versionado e o arquivo ignorado dentro de um item versionado, como um `.DS_Store` ou um `__pycache__/`. Essa parte aparece arquivo por arquivo num grupo novo do relatório, **"sai junto, fora do git, sem volta pelo git"**, logo depois dos grupos do que sai, no dry-run e na execução. A aprovação de sempre cobre esse grupo. Os textos passam a dizer a verdade: o versionado aparece no `git status` e o resto aparece, por nome, no dry-run. A recusa por item ignorado, o desvio do boot para o passo 9 e o laço entre os dois deixam de existir.

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=d76c473; scope=full; verdict=pass; p1=none

- [x] Algo que sai e está ignorado não faz mais a migração parar. O código 2 fica para os outros erros (sem git, árvore suja, marcadores quebrados, settings inválido, sem `python3`, argumento ruim), e os códigos 0 e 3 mantêm o sentido.
- [x] O grupo "sai junto, fora do git, sem volta pelo git" lista cada arquivo fora do git, tanto do item sem nada versionado quanto do ignorado dentro de item versionado, no dry-run e na execução.
- [x] Nenhuma mensagem culpa "o .gitignore do projeto" por uma regra de ignore.
- [x] O passo 5 do `anvil-update` e o passo 2 do `anvil-boot` perdem o ramo "Ignorado pelo git" e explicam o grupo fora do git. O passo 2 do boot não desvia mais para o passo 9.
- [x] O relato final do update diz que o que era versionado está no `git status` e que o que estava fora do git foi listado no dry-run.
- [x] O README troca "exige o toolkit fora do `.gitignore`" pela explicação das duas partes.
- [x] O `--help` do `migrate-project.sh` descreve as duas partes e deixa de dizer que nada ignorado é apagado.
- [x] O passo 9 do boot continua sendo o único que tira o bloco `ANVIL:INSTALLED` do `.gitignore`. A migração continua exigindo árvore limpa, passando por dry-run, esperando aprovação e nunca commitando.
- [x] Cenário `workspace/41-legacy-migration/s1.sh`, cada caso falhando antes da correção:
  - o p11 (toolkit ignorado pelo bloco `ANVIL:INSTALLED` e fora do git) migra pelo update e pelo boot, sai com código 0 e põe cada arquivo no grupo fora do git;
  - a mesma regra de ignore em `.git/info/exclude` dá o mesmo resultado;
  - uma skill versionada com um arquivo ignorado dentro põe esse arquivo no grupo fora do git;
  - o p15 (`.DS_Store` solto dentro de skill versionada) continua passando.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Review round=1 · P3 (Standards): o parágrafo das duas partes ("o que o git conhece / o que está fora do git") está quase igual no passo 5 do `anvil-update`, no passo 2 do `anvil-boot`, no README, no cabeçalho do `migrate-project.sh` e no comentário em linha — a próxima mudança nessa regra exige editar cinco lugares, e o que escapar volta a mentir.
- Review round=1 · P3 (Standards): a variável `gone` do `migrate-project.sh` foge da convenção `rm_*` das outras listas do que sai — quem lê precisa abrir a atribuição para saber que é a união das remoções.
- Review round=1 · P3 (Standards): o relato final do boot (passo 10) ainda diz só "com o diff esperando o commit do usuário", sem a parte fora do git que o relato do update ganhou — quem segue o boot não menciona no fim o que saiu fora do git.
- Review round=1 · P3 (Spec): o `git ls-files` do grupo fora do git roda sem `-z`, e o `core.quotePath=false` não desliga as aspas e os escapes de nome com `"`, `\` ou caractere de controle — o nome aparece no grupo diferente do nome no disco, mas continua listado.
- Review round=1 · P3 (Spec): um `CLAUDE.md` ou `.claude/settings.json` ignorado e editado só em parte (sai o bloco ou a entrada da guarda) não aparece no `git status` nem no grupo fora do git — desmente a divisão em duas partes do README e das skills, embora a edição apareça em "sai do projeto" antes da aprovação.
