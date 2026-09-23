# 03: O boot tira arquivo gerado do diff da revisão

**What to build:** Na varredura, o `/anvil-boot` encontra os arquivos gerados que o projeto versiona — snapshots de migration, lockfiles, saída de codegen, ou arquivo marcado como gerado — e mostra quanto cada um pesa no diff recente. Com achado relevante, ele propõe as linhas `-diff linguist-generated=true` num `.gitattributes`, espera aprovação, e mescla com o arquivo existente em vez de sobrescrevê-lo. Depois disso, o `git diff` que o `anvil-code-review` captura esconde o gerado e mostra o arquivo escrito à mão ao lado dele. O boot diz que a mudança é de apresentação, não de conteúdo, e como ver o arquivo quando preciso (`git diff --text`). Sem achado relevante, não propõe nada.

**Blocked by:** Nenhum — pode começar agora.

**Status:** resolved

- [x] O boot lista os gerados achados, com tamanho e proporção do diff.
- [x] A proposta espera aprovação; um `.gitattributes` existente é mesclado, nunca sobrescrito.
- [x] Sem achado relevante, o boot não propõe nada.
- [x] O boot explica que o arquivo continua versionado e como vê-lo com `git diff --text`.
- [x] O `anvil-code-review` não muda.
- [x] Exercitado num projeto descartável em `workspace/` com um snapshot grande: o `git diff` esconde o gerado e mostra o arquivo escrito à mão.
- [x] O `verify` sai limpo.

## Comments

- Cenário em `workspace/03-boot-gerados/`, fora do git: dois commits com
  migration `.ts` e snapshot `.json` de ~3 mil chaves, e um `.gitattributes`
  prévio do projeto. A medição do boot deu os dois snapshots com 100% das linhas
  mudadas. A linha proposta entrou por mescla, e a linha do projeto ficou. Depois
  dela, o diff do último commit caiu de 9.304 linhas para 783 bytes, com o `.ts`
  da migration e o `src/app.ts` visíveis e o `.json` como `Binary files differ`.
  `git diff --text` ainda mostra o snapshot inteiro.
