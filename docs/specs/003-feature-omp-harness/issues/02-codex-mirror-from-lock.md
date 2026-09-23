# 02: Espelho do Codex gerado pelo lock

**What to build:** Quem usa Codex continua vendo as skills do anvil em `.agents/skills`, agora mantidas pelo update. O payload deixa de trazer o espelho pronto; o update gera um symlink relativo para `.claude/skills` por linha `skill:` do lock, remove o que saiu do payload e não toca no que é do usuário. Neste repositório, o `dev-link.sh` gera o espelho a partir das skills ligadas, e o link pendurado do `anvil-team` some.

**Blocked by:** 01

**Status:** resolved

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
