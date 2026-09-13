# 10: `anvil-distill`: sistema a partir de uma URL

**What to build:** O usuário passa a URL de um repositório e as direções do que interessa. O distill pergunta se o sistema entra passageiro ou versionado, baixa, registra a versão e destila como no caso local.

**Blocked by:** 09

**Status:** ready-for-agent

- [ ] Com URL, o distill pergunta a forma de entrada, sugerindo passageiro.
- [ ] Passageiro: clone raso, com uma linha de exclusão local do git para a pasta; o gitignore do projeto não muda; a Origem registra o commit.
- [ ] Versionado: submodule; a mudança fica para o usuário commitar; a Origem registra o pin.
- [ ] Pasta já presente: sem pergunta e sem atualizar.
- [ ] Repositório privado usa a credencial que o git já tiver; o distill nunca pede credencial.
- [ ] A invariante de escrita do `DISTILL.md` passa a autorizar criar a pasta do sistema em `references/` (hoje só autoriza escrever em `docs/`).
- [ ] Ponto B: uma URL passageira some do `git status`; uma URL versionada aparece como submodule; uma pasta existente não é atualizada.

## Comments

**Leader, 2026-09-13 — entrega do Dev** em `9683696` (URL como sistema de referência) e `4d44e64` (autorrevisão:
clone e exclusão encadeados por `&&`, provado em zsh, bash 5.2 e 3.2; `--git-path` no lugar de `.git/info/exclude`
fixo). A pergunta passageiro/versionado e o download ficam na sessão principal (`SKILL.md` §1 e §3), depois do
destino — branch com número sem pasta para antes de clonar; o subagente recebe a pasta pronta. `GIT_TERMINAL_PROMPT=0`
no clone e no `submodule add`; falha mostra a mensagem do git e para. A Origem passa a detectar submodule por `git
ls-files --stage` (modo 160000), porque um submodule recém-adicionado não está no HEAD. Ponto B isolado, seis runs,
US$ 4,18: com URL pergunta sugerindo passageiro, sem download antes da resposta; passageiro com `clone --depth 1`, uma
linha no exclude, `.gitignore` intacto, `git status` só com o documento, Origem com o commit igual ao `ls-remote`;
versionado com `A .gitmodules` e `A references/p-limit` sem commit, Origem com o pin; pasta presente (resetada para
HEAD~2) sem pergunta e sem fetch, HEAD igual antes e depois; URL inexistente no gitlab falha com "terminal prompts
disabled" e para sem escrever. Documentos com seis seções e ponteiros limpos no verificador estrito do Tester do 09.

Desvios aceitos: download pela sessão principal, com a invariante no `DISTILL.md` descrevendo as duas escritas e o
`SKILL.md` apontando; submodule sem `--depth`. Contradição da spec corrigida pelo Leader: o Ponto B do distill passa a
admitir a linha de exclusão local e o `.gitmodules`, que o bullet URL já autorizava. Riscos registrados:
`GIT_TERMINAL_PROMPT=0` não cobre GCM gráfico nem ssh-askpass instalado; privado com credencial salva não exercitado;
`{sistema}` do último segmento erra com barra final ou URL de navegador (o clone falha e para); fork com o nome de uma
pasta existente cai em "pasta presente" sem comparar o remoto; no interativo, o AskUserQuestion e a permissão do
`git clone` não foram testados. Ideias: comparar `remote get-url origin` com a URL; registrar a URL na Origem.
Gates: Review despachado; Tester depois do gate do 07.

**Leader, 2026-09-13 — gate Review, rodada 1: APROVADO, sem bloqueante.** Critérios atendidos sobre `4d44e64`; o
download pela sessão principal julgado correto; `ls-files --stage` conferido em rascunho sem quebrar o caso local do
09 (submodule commitado, recém-adicionado, cópia versionada no próprio git, clone solto); shell em zsh 5.9 e
`/bin/bash` 3.2 (clone que falha não toca o exclude, linha idempotente, `--git-path` em worktree). Achados: **RV-1**
(média) o `echo >> "$exclude"` não garante quebra de linha antes — exclude sem `\n` final gruda na regra anterior
(`*.log/references/up/`) e desfaz as duas em silêncio; sem `.git/info/` o clone fica e a exclusão falha; correção
testada nos dois shells no relatório do Review. **RV-2** a invariante do `DISTILL.md` abre por "escreve em dois
lugares" para um subagente que escreve um. **RV-3** o que cada forma grava está em três lugares, e a lista de
proibidos em dois (já divergem em `checkout`). **RV-4** o risco registrado acima está errado: URL com barra final dá
segmento vazio, a pasta vira `references/`, que existe, e o fluxo destila `references/` inteiro — "último segmento não
vazio". **RV-5** `ls-files --stage` numa cópia versionada lista todos os arquivos da pasta; filtrar pela entrada
160000. **RV-6** a description não cita URL; o disparo por linguagem natural com URL não foi testado. **RV-7** "as
direções que vieram com a URL" não diz que viram a funcionalidade no despacho.

**Leader, 2026-09-13 — gate Tester, rodada 1: APROVADO.** Isolado, payload de `4d44e64`, projeto Go, `GIT_TRACE2`
gravando todo processo git (subagente inclusive), repositórios diferentes dos do Dev; 11 sessões, US$ 5,83.
Passageiro (`vercel/ms`): pergunta sem git de rede antes da resposta, clone raso, uma linha no exclude, `.gitignore`
igual, Origem = `ls-remote`. Versionado (URL com `.git`): submodule sem commit, Origem com o pin do índice. Pasta
presente atrás do remoto: sem pergunta, sem fetch/pull/checkout no trace, HEAD, refs e mtimes do `.git` iguais; a
segunda execução mantém uma linha no exclude. Credencial: https e ssh inexistentes param sem prompt; repositório
**privado com credencial salva** (osxkeychain) clona e destila. Quebra: barra final não reproduziu o RV-4 neste run
(pasta certa); URL `/tree/main/src` normalizada para o repositório e a funcionalidade recortada em `src/`; branch com
número sem pasta parou antes de clonar. Linguagem natural com URL dispara a skill, mas a funcionalidade pedida ("o
retry") caiu dos args e a destilação cobriu o sistema inteiro. Regressão do 09: submodule commitado com checkout
divergente registra pin e checkout. Achado **T-1** (baixo): clone que falha deixa `references/` vazio quando a pasta
não existia. Observação: `GIT_TERMINAL_PROMPT=0` não cobre o prompt de host key do ssh, mas a ferramenta Bash não tem
terminal de controle e o ssh falha em vez de travar. Não testados: AskUserQuestion e permissão do clone no
interativo; GCM gráfico e ssh-askpass; RV-1 (exclude sem `\n`); fork com nome de pasta existente.

Rodada única de ajuste (depois da do 07): RV-1, RV-4, RV-2, RV-3, RV-5, RV-7 do Review; T-1; e a funcionalidade dita em
linguagem natural junto da URL passa ao despacho.
