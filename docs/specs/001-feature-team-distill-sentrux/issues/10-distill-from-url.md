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
