# 03: `CLAUDE.md` e settings que são symlink com alvo no repositório têm o alvo editado

**What to build:** Num projeto antigo em que o `CLAUDE.md` ou o `.claude/settings.json` é symlink, como no comum `CLAUDE.md → AGENTS.md`, a migração resolve o link. Quando o alvo é um arquivo comum dentro da raiz do repositório e o caminho relativo até ele não passa por diretório symlink, a edição vai no alvo, com as regras do arquivo comum: só o bloco `ANVIL:DIRECTIVES` sai do `CLAUDE.md`, só a entrada do hook da guarda sai do settings. Se o alvo ficaria só com o bloco, ou só com a entrada, ele sai inteiro, e o symlink sai com ele. O usuário revisa a mudança pelo `git status`. Com o alvo fora do repositório, ou com o caminho passando por diretório symlink, o arquivo fica intocado no grupo "passa por symlink". Esse arquivo sozinho não faz o projeto contar como instalação antiga, e o `~/.claude/CLAUDE.md` de quem aponta para ele não exige árvore limpa nem gera relatório vazio. O update e o boot dizem o que fazer com o grupo "passa por symlink".

**Blocked by:** None (can start immediately)

**Status:** resolved

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
