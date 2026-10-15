# 03: `CLAUDE.md` e settings que são symlink com alvo no repositório têm o alvo editado

**What to build:** Num projeto antigo em que o `CLAUDE.md` ou o `.claude/settings.json` é symlink, como no comum `CLAUDE.md → AGENTS.md`, a migração resolve o link. Quando o alvo é um arquivo comum dentro da raiz do repositório e o caminho relativo até ele não passa por diretório symlink, a edição vai no alvo, com as regras do arquivo comum: só o bloco `ANVIL:DIRECTIVES` sai do `CLAUDE.md`, só a entrada do hook da guarda sai do settings. Se o alvo ficaria só com o bloco, ou só com a entrada, ele sai inteiro, e o symlink sai com ele. O usuário revisa a mudança pelo `git status`. Com o alvo fora do repositório, ou com o caminho passando por diretório symlink, o arquivo fica intocado no grupo "passa por symlink". Esse arquivo sozinho não faz o projeto contar como instalação antiga, e o `~/.claude/CLAUDE.md` de quem aponta para ele não exige árvore limpa nem gera relatório vazio. O update e o boot dizem o que fazer com o grupo "passa por symlink".

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=1e782ef68085fc010d9a19ea87584a8c94cd7801; scope=full; verdict=pass; p1=none

- [x] Com `CLAUDE.md → AGENTS.md` e o bloco no `AGENTS.md`, o bloco sai do `AGENTS.md`, o resto fica byte a byte e a mudança aparece no `git status`.
- [x] Com `CLAUDE.md → AGENTS.md` e o `AGENTS.md` só com o bloco, os dois saem.
- [x] Com o `.claude/settings.json` symlink para um arquivo dentro do repositório, a entrada da guarda sai do alvo pela mesma regra do settings comum.
- [x] Com o `CLAUDE.md` ou o settings symlink para um arquivo fora do repositório, o alvo fica intocado. Sem outro sinal de instalação antiga, o projeto não migra e não exige árvore limpa. Com outro sinal, o arquivo aparece no grupo "passa por symlink".
- [x] O caminho que passa por diretório symlink continua intocado, como hoje.
- [x] O passo 5 do `anvil-update` e o passo 2 do `anvil-boot` dizem que o item do grupo "passa por symlink" ficou porque a migração não escreve fora do projeto. Se o alvo é do próprio projeto, o usuário tira à mão o bloco ou a entrada. Se é da instalação de usuário (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`), deixa como está.
- [x] O `--help` do `migrate-project.sh` descreve o tratamento de symlink com alvo no repositório.
- [x] Cenário `workspace/41-legacy-migration/s1.sh`, cada caso falhando antes da correção: os quatro primeiros critérios acima, com o alvo de fora carregando o bloco.
- [x] O `vendor-sync.sh verify` sai limpo.

## Comments

- Implementação: o cenário ganhou a seção 6 (p18–p24) e o p13 passou a conferir o grupo "passa por symlink". Antes da correção, falharam os seis casos novos dos critérios 1 a 4 — bloco no `AGENTS.md`, `AGENTS.md` só com o bloco, settings symlink no repositório (entrada e arquivo inteiro), `CLAUDE.md` para o `~/.claude/CLAUDE.md` e settings para fora, sem outro sinal. Os casos "com outro sinal" (p13, p23) e o de diretório symlink (p24) já passavam, como o critério 5 descreve. A resolução segue um salto só: alvo que é ele mesmo symlink fica intocado no grupo "passa por symlink".
- Review round=1 · P2 (Standards): no grupo "passa por symlink", a linha do `CLAUDE.md` e a do settings não mostram o alvo do link. As skills mandam decidir pelo alvo, se é do projeto ou da instalação de usuário. Consequência: o agente tem de rodar `readlink` para saber o que dizer ao usuário.
- Review round=1 · P3 (Standards): os trios `claude_rel/claude_link/claude_out` e `settings_rel/settings_link/settings_out` são resolvidos por dois blocos quase iguais (Data Clumps/Duplicated Code). Consequência: um terceiro arquivo resolvido por symlink copiaria o bloco mais uma vez.
- Review round=1 · P3 (Standards): `claude_out` e `settings_out` não dizem que o item fica intocado, com o alvo fora do repositório ou atrás de symlink (Mysterious Name). Consequência: quem mantém o código precisa ler o bloco de resolução para entender os testes.
- Review round=1 · P3 (Standards): a regra do symlink está escrita em quatro comentários. O da linha da remoção do link está no relatório, e não na execução. Consequência: quando a regra mudar, uma das cópias fica desatualizada.
- Review round=1 · P3 (Standards): o título do grupo, "o caminho passa por symlink", não descreve bem o `CLAUDE.md` que é ele mesmo o link. Consequência: o título engana um pouco, mas não muda nenhuma decisão.
- Review round=1 · P3 (Standards/Spec): um link absoluto escrito por um prefixo que é symlink, como `/var` → `/private/var` no macOS, conta como fora do repositório, porque o `ROOT` vem de `pwd -P`. Consequência: o bloco ou a entrada fica para ser tirado à mão. A falha é conservadora e não escreve nada indevido.
- Review round=1 · P3 (Spec): uma cadeia de links dentro do repositório (`CLAUDE.md → A.md → B.md`) fica intocada, e as skills dizem que isso acontece "porque a migração não escreve fora do projeto". Consequência: o motivo está errado, mas a ação indicada, tirar à mão o que é do próprio projeto, continua certa.
- Review round=1 · P3 (Spec): quando o alvo está ignorado pelo git, a edição não aparece no `git status` nem no grupo fora do git, embora as skills digam que a mudança aparece no `git status`. A lacuna já existia para o `CLAUDE.md` comum ignorado. Consequência: o usuário não encontra a mudança onde o texto manda procurar, mas nenhuma linha dele se perde.
- Fechamento (archive): o P2 virou A20; os P3 do alvo ignorado, do prefixo symlink, da cadeia de links e da regra em quatro comentários viraram A21, A24, A25 e A26 em `docs/project/acompanhamento.md`. Os blocos quase iguais, os nomes `claude_out`/`settings_out` e o título do grupo foram aceitos.
