# 01: O verbo `security` grava o registro da auditoria

**What to build:** `/anvil-docs security <diretório da execução>` confere a execução com os validadores da `anvil-security-audit` e, se passa, grava em `docs/security/audit-<data>-run-<N>.md` o registro da auditoria derivado por um script Node do `anvil-docs`, que lê só a lista branca de campos da spec. O registro traz o commit e a árvore auditados, o perfil, o estado da execução, a contagem de unidades do ledger por estado, a contagem de achados por veredito e dos `confirmed` por severidade, uma linha por achado com fingerprint, veredito e severidade, e o caminho do diretório da execução. Ver a spec, "Implementation Decisions".

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=9c127e4; scope=full; verdict=fail; p1=open

- [x] O verbo `security` está na tabela de verbos do `anvil-docs`, com o arquivo próprio do verbo descrevendo argumento, recusas, o que o registro leva e o que nunca leva.
- [x] Sobre um diretório de exemplo cujo `findings.json` e `coverage-ledger.json` passam no `validate-findings.cjs` e no `validate-coverage-ledger.cjs` da cópia vendorizada, com pelo menos um achado de cada veredito e caminhos, trechos de fonte e reprodução preenchidos, o verbo grava o registro em `docs/security/`.
- [x] Nenhum valor de caminho, trecho de fonte, título, descrição, comando ou reprodução de achado do exemplo aparece no registro gravado, nem id de unidade do ledger.
- [x] Faltando um dos três arquivos, o verbo recusa dizendo qual, e nada é gravado.
- [x] Com um validador saindo diferente de `0`, o verbo recusa com a saída dele, e nada é gravado.
- [x] Registrar de novo a mesma execução substitui o registro dela, sem criar um segundo arquivo para o mesmo `run-<N>`.
- [x] O script não lê nem copia o `REPORT.md`, o `FINDINGS-DETAIL.md` ou o `NEEDS-VALIDATION.md`.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Implementação · o verbo é `anvil-docs/SECURITY.md`, e o script é `anvil-docs/scripts/audit-record.cjs`, que acha os validadores na `anvil-security-audit` irmã (`../../anvil-security-audit` a partir dele). Sai com `0` e `record: <caminho>`, ou com `2` e linhas `refusal:`, como o `roadmap.sh`.
- Implementação · rodar o `index` depois de gravar, que a spec põe no verbo, ficou para o ticket 02, que o reivindica ("O verbo `security` termina rodando o `index`").
- Implementação · a prova é o cenário manual `workspace/06-security-record/scenario.cjs`, fora do git: monta um projeto git e uma execução `run-<N>` com um achado de cada veredito e caminhos, trechos, comandos e reprodução marcados com `LEAK`, roda o script e confere o registro, as recusas e a substituição. Os relatórios em Markdown da execução ficam com permissão `000`, e qualquer leitura deles quebraria o script. O ticket 02 pode montar a mesma execução a partir do `confirmed()`/`needsValidation()`/`rejected()` do `validate-findings.test.cjs` e do `unit()` do `validate-coverage-ledger.test.cjs`.
- Observação sobre a spec · o upstream não fixa a forma do `source_ref` do `run-metadata.json` ("the reviewed commit and whether the worktree is dirty"). O script exige `source_ref.commit` (SHA em hexadecimal) e `source_ref.dirty` (booleano), e recusa nomeando o campo quando falta — uma execução real que grave outra forma é recusada até o metadado ser ajustado.
- Observação sobre a spec · o `run_id` e o `incomplete_reason` só entram como ficha sem espaço (`validation_budget_exhausted`); texto livre é recusado, porque poderia nomear um arquivo. Os motivos que o upstream cita são todos fichas.
- Observação sobre a spec · a história 3 pede o "escopo da execução" no registro, e a lista branca não tem o `scope_paths`, que é lista de caminhos. Valeu a lista branca: o registro traz só o perfil.
- Observação sobre a spec · o padrão do `fingerprint` no `report-schema.json` aceita `/` e `:`, e o upstream o descreve como "source-derived": uma execução que derive o fingerprint do caminho, como `src/auth.c:42`, leva esse caminho ao registro pela linha do achado, que a spec manda ter. O exemplo usa fingerprints sem caminho.
- Review round=1 · P1 (Spec): o `report-schema.json` aceita `/`, `.` e `:` no `fingerprint`, e o `audit-record.cjs` o copia como está para a linha do achado — um `findings.json` com `fingerprint: "src/auth.c:42"` passa no `validate-findings.cjs` e grava esse caminho em `docs/security/`, contra a história 9 e o "O que o registro nunca leva" do `SECURITY.md`, e o registro versionado divulga onde está a vulnerabilidade.
- Review round=1 · P3 (Standards): possível Mysterious Name — o `n` que atravessa `runDirectory`, `render` e `recordPath` é o número da execução, e só o comentário do topo diz isso — quem lê precisa rastrear o significado.
- Correção da rodada 1 · o fingerprint só entra na linha do achado quando é ficha de letras, dígitos, `-` e `_`; com `/`, `.`, `:`, `@` ou `+`, a linha leva `_oculto, posição <i>_`, a posição no `findings.json` da execução, e o registro diz por quê. A história 7 pede a linha "sem que o registro revele onde ele está", e foi ela que decidiu entre ocultar e recusar a execução. O `run_id` e o `incomplete_reason` passaram à mesma ficha, sem `.` nem `:`. O `n` virou `runNumber`. O cenário ganhou um achado com `fingerprint: "fp-session/srcleak/auth.c:csrf"`, e nenhum pedaço dele aparece no registro.
