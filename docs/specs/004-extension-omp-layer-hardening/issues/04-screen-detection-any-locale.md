# 04: Tela em qualquer locale e exemplos da `anvil-run`

**What to build:** A detecção de tela do `frontier.sh` passa a funcionar em qualquer locale, e a `anvil-run` dá ao supervisor exemplos do caso que o script não reconhece. O operador de uma spec com tela recebe a recomendação do browser QA mesmo com `LC_ALL=C` ou com a tela descrita em outras palavras. Linhas A4 e A6 do acompanhamento.

**Blocked by:** 01

**Status:** resolved
**Review:** round=1; sha=0e6eb02; scope=full; verdict=pass; p1=none

- [x] A comparação da lista de palavras de tela é feita com `perl` em modo Unicode, sem distinguir maiúsculas e só com palavra inteira; a lista não muda.
- [x] "PÁGINA", "BOTÃO" e "PAINÉIS" numa user story dão `screen: yes` em `LC_ALL=C` e em UTF-8, nos dois bash.
- [x] "paginar" continua sem contar, e palavra de tela fora das User Stories também.
- [x] O item `screen: no` da `anvil-run` usa exemplos que o script não reconhece: gráfico que o usuário filtra, mapa clicável, cards que se arrastam entre colunas.
- [x] Cenário novo no S2 da `anvil-run`: spec resolvida, sem `ui/`, com uma user story de cards que se arrastam entre colunas, recebe `/skill:anvil-browser-qa` citando a história; o cenário B, de somar uma coluna, segue com o archive.
- [x] O `verify` sai limpo.

## Comments

- Leitura: o `frontier.sh` passa a comparar com `LC_ALL=C perl -CSDA`, com o padrão `\b(?:SCREEN_WORDS)\b/i`, e a lista entra por argumento. O `-CSDA` fixa UTF-8 na entrada, na saída e no `@ARGV` sem consultar o locale. O `LC_ALL=C` no perl só evita o aviso de locale ausente. O `\b` do perl trata letra acentuada como letra, por isso "painel" deixa de casar em "painelão", o que o grep em `LC_ALL=C` casava. O texto do `screen:` e as chaves não mudaram, então a tabela da spec fica como está.
- Fixture: `/tmp/anvil-004-01/fx.sh`, com `/usr/bin/grep` e perl 5.34.1, nos casos `f-tela-015-pagina`, `f-tela-016-botao`, `f-tela-017-paineis` e `f-tela-018-sem-tela`. A saída foi escrita à mão, e cada caso rodou em `LC_ALL=pt_BR.UTF-8` e `LC_ALL=C`, em `/opt/local/bin/bash` 5.2.15 e `/bin/bash` 3.2.57. A palavra de tela em caixa alta fica na história 2, e a linha `screen: yes (a user story 2 fala de tela)` mostra qual história contou. O 018 junta "paginar" e "PAGINAR", "painelão", terminal, stderr, código de saída, arquivo, log, API, os cards e uma "PÁGINA" fora das User Stories, e sai `screen: no`. Antes da mudança, os quatro casos falhavam em `C` nos dois bash (015 a 017 com `no`, 018 com `yes` pela "painelão") e passavam em UTF-8. Depois, 36 casos ok e 0 falha. Os casos da 003 seguem comparando com o c2111a5.
- S2 (`workspace/33-omp-run/s2.sh`, haiku): o cenário novo C3, spec 005 resolvida, sem `ui/`, com a única história "cards que se arrastam entre colunas", recebe `screen: no` do script. O supervisor fecha com `/skill:anvil-browser-qa` e cita "cards que se arrastam entre colunas". O B segue com `/skill:anvil-docs archive`. Resultado: `S2: tudo passou`. Uma primeira rodada deu 1 falha na conferência "o repositório do anvil não mudou", porque o commit 0e6eb02 entrou durante a execução. A rodada seguinte, com o repositório parado, passou inteira.
- `vendor-sync.sh verify`: `verify: limpo`.
- Review round=1 · P2 (Spec): o C3 do S2 usa a mesma frase que a `anvil-run` dá de exemplo, e prova só que o supervisor reconhece o exemplo literal, não uma tela descrita com palavras que a skill não lista. Um cenário com um quadro kanban descrito de outro jeito mediria a generalização que a US 14 quer (o supervisor sabe quando subir um `no`).
- Review round=1 · P3 (Standards): o `perl` passa a ser dependência do `frontier.sh`, a primeira do payload. Num host sem perl, a detecção cai em `screen: no` com `command not found` no stderr, e só a leitura das linhas `story` pelo supervisor segura o browser QA.
- Review round=1 · P3 (Standards): uma `spec.md` fora de UTF-8, em Latin-1 por exemplo, faz o perl sair com `Malformed UTF-8 character (fatal)`, e a linha sai `screen: no` mesmo com "tela" em ASCII na história, que o grep antigo em `C` casava. Specs geradas pelo anvil são UTF-8.
