# 02: A saída 3 marca o que tem conteúdo fora do git

**What to build:** Num projeto antigo sem lock, a migração para com a saída 3 e pergunta quais skills e agentes não vieram do anvil. Nessa lista, a skill ou o agente que tem conteúdo fora do git vem marcado, e o usuário decide o `--keep-skills` e o `--keep-agents` sabendo o que não vai recuperar pelo git. Uma rodada de resposta basta: depois dela, nenhuma segunda parada por causa do ignore, e o que está fora do git do que sai aparece no grupo "sai junto, fora do git, sem volta pelo git".

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=2b3c66a; scope=full; verdict=pass; p1=none

- [x] Sem lock e sem resposta, a lista de skills e agentes da saída 3 marca os que têm conteúdo fora do git e não marca os outros. Nada é alterado, como hoje.
- [x] A resposta continua em `--keep-skills` e `--keep-agents`, juntos.
- [x] Com a resposta, a migração chega ao dry-run e à execução sem outra parada, e o conteúdo fora do git do que sai aparece no grupo fora do git.
- [x] Cenário `workspace/41-legacy-migration/s1.sh`, falhando antes da correção: sem lock, a saída 3 marca a skill que tem conteúdo fora do git, e depois uma rodada de resposta basta para migrar.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Review round=1 · P3 (Standards): a variável `oog` do ramo da saída 3 do `migrate-project.sh` repete a ideia que logo abaixo se chama `out_of_git` — quem lê perde um ciclo para decifrar o nome, sem mudança de comportamento.
- Review round=1 · P3 (Standards): a função `marcados` do cenário `s1.sh` reconhece a marca pelo trecho literal "fora do git", contra o "nunca o texto exato de uma mensagem" das Testing Decisions — se a redação da marca mudar, o cenário quebra com o comportamento certo.
- Review round=1 · P3 (Spec): uma skill que é ela mesma symlink ignorado recebe a marca "se sair, não volta pelo git", mas a migração apaga só o link e o alvo fica [inferência, não testado] — o aviso diz mais do que se perde, sem levar a perda nenhuma.
- Fechamento (archive): os três P3 foram aceitos. O `oog` é forma; o `marcados` vive no cenário, fora do git; a marca da skill que é symlink ignorado é inferência não testada e exagera o aviso sem levar a perda.
