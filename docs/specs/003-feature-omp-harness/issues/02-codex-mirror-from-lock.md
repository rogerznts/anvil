# 02: Espelho do Codex gerado pelo lock

**What to build:** Quem usa Codex continua vendo as skills do anvil em `.agents/skills`, agora mantidas pelo update. O payload deixa de trazer o espelho pronto; o update gera um symlink relativo para `.claude/skills` por linha `skill:` do lock, remove o que saiu do payload e não toca no que é do usuário. Neste repositório, o `dev-link.sh` gera o espelho a partir das skills ligadas, e o link pendurado do `anvil-team` some.

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=e19d774; scope=full; verdict=fail; p1=open

- [x] O payload não traz mais `.agents/`.
- [x] Depois do update, `.agents/skills` tem exatamente um symlink por linha `skill:` do lock, apontando para a skill em `.claude/skills`.
- [x] Symlink cujo nome estava no `skill:` do lock anterior e não está no novo é removido.
- [x] Entrada em `.agents/skills` que não é symlink para `.claude/skills` fica intocada; se tiver nome de skill do payload, aparece como colisão e não é substituída.
- [x] Sem lock, nada em `.agents/skills` é apagado.
- [x] O dry-run e o relatório mostram o que muda em `.agents/skills`.
- [x] O `dev-link.sh` gera `.agents/skills` deste repositório a partir das skills ligadas, e o `--unlink` o desfaz; o link do `anvil-team` não existe mais.
- [x] Numa sessão do omp com o espelho presente, nenhuma skill aparece duplicada.
- [x] Cenário S1 cobre os casos acima; o `verify` sai limpo.

## Comments

- O espelho passa por `classifica` com o predicado `existe_espelho`: só o symlink na forma `../../.claude/skills/<nome>` é do anvil. Órfão, substituído e alheio saem da função. A colisão não sai dela, porque a regra do lock não serve no espelho: lá a colisão é um nome de skill do payload ocupado por uma entrada que não é o nosso symlink. Ela é calculada logo depois da chamada, e a entrada do usuário com nome do lock anterior vai para os alheios. O symlink só é criado onde não existe nenhuma entrada, porque um `ln -s` sobre um diretório criaria o link dentro dele.
- Prova: `workspace/29-codex-mirror/s1.sh` passa inteiro em bash 5 e em bash 3.2 (36 checks cada). O cenário cobre o payload sem `.agents/`, um projeto sem espelho, órfão, alheio, colisão por diretório e por symlink com outro alvo, colisão só de caixa, projeto sem lock, `dev-link` com roster, `--all`, `--unlink` e link pendurado, e o estado deste repositório. `workspace/29-codex-mirror/omp.sh` roda uma sessão headless do omp 18.2.11 num projeto instalado pelo update: cada skill aparece uma vez, lida de `.claude/skills`, e não há aviso de colisão.
- Antes/depois com `workspace/28-reset-classify/capture.sh` (`antes-02`, `depois-02`) nos cenários 03 e 12: nenhuma linha antiga sumiu. As diferenças são o bloco do espelho no relatório, os symlinks de `.agents/skills` no disco das fixtures, a linha do espelho no `dev-link` e o `--unlink`, que agora conta também o symlink do espelho. O `12-run.out` saiu idêntico, com as mesmas 20 falhas que o cenário já tinha. Bash 5 e bash 3.2 saem iguais, antes e depois.
- Neste repositório o `.agents/` saiu do git e o `.agents/skills/*` entrou no `.gitignore`, como `.claude/skills/*`: o espelho agora é derivado pelo `dev-link`. O espelho versionado apontava para o payload inteiro e expunha ao omp e ao Codex a `anvil-update`, que a regra do projeto mantém desligada aqui. Também trazia cópias reais de `anvil-browser-qa` e `anvil-next`.
- Fecha o P3 da rodada 2 do ticket 01: o laço que monta `disco_ag` chama `existe_agente`, e a regra "symlink conta como agente" fica num lugar só.
- Lacuna até o ticket 04: um projeto novo, instalado só pelo `npx degit`, fica sem `.agents/skills` até o primeiro update, porque o degit não roda o `reset-install.sh`. O modo de camadas do boot, no ticket 04, fecha essa lacuna.
- Review round=1 · P1 (Standards e Spec): o reset confere a forma de cada entrada de `.agents/skills`, mas não a do próprio `.agents/skills`. Com `.agents/skills -> ../.claude/skills`, que é a forma comum de expor skills ao Codex, o `ln -s` cai dentro da skill recém-copiada e deixa um link cíclico versionado em `.claude/skills/<s>/<s>`. Com `.agents` como arquivo, ou com `.agents/skills` como link pendurado, o `mkdir -p` aborta depois da troca das skills e antes da escrita do lock, e o próximo update calcula tudo contra um lock velho. O dry-run não mostra nenhum dos três casos.
- Review round=1 · P1 (Spec): o payload anterior entregava `anvil-browser-qa` e `anvil-next` como diretórios reais em `.agents/skills`. Todo projeto instalado por ele fica com essas duas cópias marcadas como colisão, que nunca é substituída, e o Codex continua lendo a cópia congelada depois de cada update. A spec e este ticket mandam não substituir a entrada que não é symlink, então a correção pede uma decisão.
- Review round=1 · P3: o predicado se chama `existe_espelho`, mas testa posse e não existência: devolve falso para uma entrada que existe. Quem ler `if existe_espelho` entende o contrário do que acontece, e no `dev-link` o mesmo teste se chama `nosso_espelho`.
- Review round=1 · P3: das saídas de `classifica "_esp"`, o `substituidos_esp` nunca é lido e o `colisoes_esp` é sobrescrito, e os alheios dependem de um laço de remendo. Uma mudança na regra de colisão de `classifica` altera o espelho em parte e sem aviso.
- Review round=1 · P3: o dry-run diz "(dry-run: nada foi alterado)" e logo abaixo "symlinks criados (N)", no passado. Quem lê pode achar que o espelho já foi escrito.
- Review round=1 · P3: o passo 4 da `anvil-update` manda nomear a colisão do espelho como "skill que o Codex não vai ver". O Codex vê, sim, uma skill com esse nome: a entrada do usuário, e não a do anvil. O aviso engana o operador sobre o que o Codex carrega.
- Correção do P1 da raiz: antes de qualquer escrita, o reset confere `.agents` e `.agents/skills`. Se um dos dois é symlink ou arquivo, o espelho inteiro fica com o usuário: nada é classificado nem escrito ali, e o relatório diz isso numa linha. A seção 2b do S1 cobre três casos: `.agents/skills -> ../.claude/skills`, `.agents` como arquivo e `.agents/skills` pendurado. Nos três, o update sai com rc=0, grava o lock novo e não planta link dentro de skill. Contra a e19d774, os quatro checks da seção falham.
- Decisão do usuário sobre o P1 do legado: a regra fica, e nenhuma entrada real é substituída. No passo 4 da `anvil-update`, cada colisão do espelho é comparada com `diff -r` contra a skill instalada. Se forem idênticas, é cópia de payload antigo: o operador a apaga, e o update põe o symlink no lugar. A seção 2c do S1 cobre esse caminho.
- P3 de nome, rodada 1: o predicado virou `nosso_espelho`, o mesmo nome do `dev-link`. P3 do dry-run: o grupo agora se chama "symlinks novos". P3 do aviso: o texto diz que o Codex lê a entrada do usuário. O P3 das saídas de `classifica "_esp"` fica como acompanhamento: o `substituidos_esp` não é lido e o `colisoes_esp` é recalculado, porque a colisão do espelho vem da forma da entrada e não do lock.
- Prova depois da correção: o S1 passa em bash 5 e em bash 3.2, com 44 checks cada, e o `verify` sai limpo nos dois. A captura `depois-02b` difere da `depois-02` só no rótulo "symlinks novos". O `12-run.out` continua idêntico ao `antes-02`, e bash 5 e bash 3.2 dão a mesma saída.
